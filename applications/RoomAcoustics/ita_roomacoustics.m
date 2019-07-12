function varargout = ita_roomacoustics(varargin)
%ITA_ROOMACOUSTICS - Calculates reverberation times (EDT, Txx) and engergy parameters (Cxx, Dxx, t_s)
%
%  This function takes a Room Impulse Response (RIR) and calculates specified
%  room acoustic parameters according to ISO 3382-1 [3]. If no options are
%  given which parameter to calculate, the default options (defined in
%  ita_roomacoustics_parameters) will be taken.
%  The Lundeby-Algorithm [1] is used for noise detection. The algorithm uses
%  the last part of the RIR to estimate the noise level. It is recommended
%  not to use fadeout windows, but a simple cut of the measurement to remove non-
%  linearities. For noise compensation the impulse response is truncated at
%  intersection time and a correcten for truncation is applied
%  ('edcMethod', 'cutWithCorrection') according ISO 3382.
%
%
%  Call:  raResultStruct                  = ita_roomacoustics(RIR, options)
%         [raResultStruct filteredSignal] = ita_roomacoustics(RIR, options)
%
%   Options (default):
%           'freqRange'           (ita_preferences('freqRange'))      : frequncy range for analysis
%           'bandsPerOctave'      (ita_preferences('bandsPerOctave')) : bands per octave for filtering
%           'broadbandAnalysis'   (false)                             : deactivate the fractional octave band filtering
%           'startThreshold'      (20)                                : threshold below maximum in dB to detect starting point for impulse response
%           'timeShift'           (true)                              : shift broadband RIR according to ISO 
%           'edcMethod'           ('cutWithCorrection')               : Used noise compensation technique (see [5] for overview)
%                                      'cutWithCorrection'                  : truncate impulse response at intersection time and apply compensation for cut (accorrding ISO 3382-1:2009)
%                                      'justCut'                            : truncate impulse response at intersection time (also ISO 3382-1 compliant)
%                                      'noCut'                              : take full impulse response for EDC calculation   (also ISO 3382-1 compliant)
%                                      'subtractNoise'                      : subtract noise energy from impulse response [4]
%                                      'subtractNoiseAndCutWithCorrection'  : subtract noise energy [4], truncate IR and compensate
%                                      'unknownNoise'                       : apply moving average window with width T/5 (according (old) ISO 3382:2000 )
%
%           'normalizeEDC'       (true)                               : whether to normalize the EDC
%           'cutTailingZeros'    (true)                               : detect tailing zeros and crop RIR
%           'plotLundebyResults' (false)                              : plot lundeby results (reverberation time, intersection time and noise level)
%           'useSinglePrecision' (false)                              : Use single precision to avoid memory errors
%           'oldOutput'          (false)                              : old ouput format: multi-instance of itaResults instead of struct
%
%
%    Currently available parameters [ output from ita_roomacoustics_parameters('getAvailableParameters') ]:
%                   EDT, LDT, T10, T15, T20, T30, T40, T50, T60             % reverberation times
%                                                                             LDT: Late Decay Time (see [6])
%                   C50, C80, D50, D80, Center_Time                         % energy parameters
%                   T_Huszty                                                % reverberation time with Huszty method [2] (not in public BSD version)
%                   T_Lundeby, PSNR_Lundeby, Intersection_Time_Lundeby      % Lundeby et al. method [1]
%                   EDC                                                     % energy decay curve
%
%
%    Select the parameters to be calculated:
%
%       res = ita_roomacoustics(asRIR)                            => take parameters specified in ita_roomacoustics_parameters()
%       res = ita_roomacoustics(asRIR, 'T20')                     => calculate only T20; values in ita_roomacoustics_parameters() will be ignored
%       res = ita_roomacoustics(asRIR,'EDT','C80','PSNR_Lundeby') => calculate EDT, C80 & PSNR
%
%
%  See also:
%   ita_roomacoustics_parameters, ita_roomacoustics_tonal_color
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics">doc ita_roomacoustics</a>

% References
%  [1] Lundeby, Virgran, Bietz and Vorlaender - Uncertainties of Measurements in Room Acoustics - ACUSTICA Vol. 81 (1995)
%  [2] Huszty - Application of calculating the reverberation time from room impulse responses without using regression - Frum Acusticum 2011
%  [3] ISO EN DIN 3382 - Measurement of the reverberation time of rooms with reference to other acoustical parameters
%  [4] Chu - Comparison of reverberation measurements using Schroeder's impulse method and decay-curve averaging method - JASA 1978
%  [5] Guski - Measurement Uncertainties of Reverberation Time caused by Noise - AIA-DAGA 2013
%  [6] Bradley and Wang - Quantifying the Double Slope Effect in Coupled Volume Room Systems, 2009, https://doi.org/10.1260/135101009788913275

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
%         Lukas Aspöck -- Email: las@akustik.rwth-aachen.de
% Created: 08-Jan-2009


%%  call GUI
if ~nargin
    if nargout 
        varargout{1} = ita_roomacoustics_gui();
    else
       ita_roomacoustics_gui();
    end
    return
elseif nargin == 1 
    varargout{1} = ita_roomacoustics_gui(varargin{1});
    return
end

%% Initialization and Parsing
sArgs  = struct('pos1_data','itaAudio', 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave'), ...
    'useSinglePrecision', false, 'linearConvolution', true,  'edcMethod', 'cutWithCorrection', 'normalizeEDC', true, 'startThreshold', 20, ...
    'cutTailingZeros', true, 'plotLundebyResults', false, 'broadbandAnalysis', false,'oldOutput',false, 'timeShift' , true);

% dynamic parameter options
possibleParameters = ita_roomacoustics_parameters('getAvailableParameters');
for iPar = 1:numel(possibleParameters)
    sArgs.(possibleParameters{iPar}) = false;
end

% parse input
[ir,sArgs]   = ita_parse_arguments(sArgs,varargin);

if numel(ir) > 1
    error('no support for multi instances. please merge input first....')
end

par2calc = false(numel(possibleParameters),1);
for iPar = 1:numel(possibleParameters)
    par2calc(iPar) = sArgs.(possibleParameters{iPar});
end
parametersFromUser = possibleParameters(par2calc);

% check if huszty alogrithm is available
if ~ exist('ita_roomacoustics_reverberation_time_huszty', 'file')
    sArgs.T_Huszty = false;
    parametersFromUser(strcmpi(parametersFromUser, 'T_Huszty')) = [];
    ita_verbose_info('Huszty algorithm niot included in BSD version.')
end

if isempty( parametersFromUser) % use default values from ita_roomacoustics_parameters()
    parametersFromUser = possibleParameters(cell2mat(ita_roomacoustics_parameters(possibleParameters{:})));
    
    if isempty(parametersFromUser) % nothing to do
        varargout{1} =[];
        ita_verbose_info('no parameters specified',0)
        return;
    end
    
    for iPar = 1:numel(parametersFromUser)
        sArgs.(parametersFromUser{iPar}) =  true;
    end
    
    ita_verbose_info('no input parameter specified. using default values from ita_roomacoustic_parameters',1)
end

parameterForReverberation = intersect(parametersFromUser,  ita_roomacoustics_parameters('getAvailableParameters', 'Reverberation_Times'));
parametersForEnergy       = intersect(parametersFromUser,  ita_roomacoustics_parameters('getAvailableParameters', 'Clarity_and_Definition'));

% reverberation without huszty und lundeby
parameterForReverberationTraditional = setdiff(parameterForReverberation, {'T_Huszty', 'T_Lundeby'});

freqRange               = sArgs.freqRange;
bandsPerOctave          = sArgs.bandsPerOctave;

% return the filtered data?
returnBandpassSignals = nargout >= 2;
if returnBandpassSignals
    bandPassfilterData = itaAudio(ir.nChannels,1);
end

if sArgs.EDC
    outputStruct.EDC = itaAudio(ir.nChannels,1);
end

nChannels = ir.nChannels ;
showWaitbar = nChannels > 5;
if showWaitbar
    wbh = itaWaitbar([ir.nChannels], 'ita_roomacoustics()', {'Channel '});
end


%% Bring impulse to the beginning & cut tailing zeros
if sArgs.timeShift
    [ir, shiftTime]  = ita_time_shift(ir, [num2str(sArgs.startThreshold) 'dB'] );              	% ISO 3382-1: Min. 20dB before max peak
    ir = ita_metainfo_rm_historyline(ir);
else 
    shiftTime = zeros(1, ir.nChannels);
end

nInputSamples   = ir.nSamples + round(shiftTime*ir.samplingRate)+rem(round(shiftTime*ir.samplingRate),2);  % cut shifted samples later


% search for tailing zeros (they will disturb noise detect)
tmpData = ir.timeData;
for iCh = 1:ir.nChannels
    tmpData(nInputSamples(iCh):end,iCh) = 0;
    if sArgs.cutTailingZeros
        startValue = nInputSamples(iCh);
        % cut tailing zeros
        while  tmpData(nInputSamples(iCh)-1,iCh) == 0
            nInputSamples(iCh) = nInputSamples(iCh)-1;
            if nInputSamples(iCh) == 1
                error(['Channel ' num2str(iCh) ' is empty'])
            end
            
        end
        if ~isequal(startValue, nInputSamples(iCh))
            if nInputSamples(iCh) < 5
                nInputSamples(iCh) = startValue;
                ita_verbose_info('cutting tailing zeros would leave less than 5 samples => cancel cutting', 1)
            else
                ita_verbose_info(sprintf('Cutting tailing zeros (Channel %i: %2.2f ms). Be carefull! Windowing distorts noise detection. Use ita_extract_dat() ',iCh, (startValue - nInputSamples(iCh))*1000/ir.samplingRate),0)
            end
        end
    end
end
ir.timeData = tmpData;


%% Generate Octave band filter
if sArgs.broadbandAnalysis
    sArgs.linearConvolution = false; % no need
    nSamplesFilter = ir.nSamples;
%     filterSPK     = ita_generate('impulse',1,ir.samplingRate, nSamplesFilter);
    filterSPK = 1;
else            % use fractional octaveband filtering
    if sArgs.linearConvolution
        nSamplesFilter = ir.nSamples + 2^15 - 1;  % default filter length of mpb_filter
        nSamplesFilter = nSamplesFilter+ rem(nSamplesFilter,2);
    else
        nSamplesFilter = ir.nSamples;
    end
    
    imp     = ita_generate('impulse',1,ir.samplingRate, nSamplesFilter); imp.channelNames = {''};
    if sArgs.useSinglePrecision
        imp.dataType = 'single';
    end
    filterSPK = ita_fractional_octavebands(imp,'bandsperoctave',bandsPerOctave, 'freqRange', freqRange, 'zerophase');
end


%% loop for all input channels

for iCh = 1:nChannels
    if showWaitbar
        wbh.inc;
    else
        ita_verbose_info([' Processing channel ' num2str(iCh)],1);
    end
    
    %% filter current channel
    if sArgs.broadbandAnalysis
        data = ir.ch(iCh);
    else
        if sArgs.linearConvolution
            data = ita_extend_dat(ir.ch(iCh), nSamplesFilter, 'forcesamples') * filterSPK;
        else
            data = ir.ch(iCh) * filterSPK;
        end
        data = ita_ifft(data);
    end
    
    % discard cyclic shifted samples at the end
    data.timeData = data.timeData(1:nInputSamples(iCh),:);
    
    % lundeby parameter
    [RT_lundeby, PSNR, Intersection_Time_Lundeby, NoiseLundeby, PSPNR] = ita_roomacoustics_reverberation_time_lundeby(data ,'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'plot', sArgs.plotLundebyResults, 'broadbandAnalysis', sArgs.broadbandAnalysis);
    
    % copy wanted data in output struct
    if sArgs.T_Lundeby
        outputStruct.T_Lundeby(iCh) = RT_lundeby;
    end
    if sArgs.PSNR_Lundeby
        outputStruct.PSNR_Lundeby(iCh) = PSNR;
    end
    if sArgs.PSPNR_Lundeby
        outputStruct.PSPNR_Lundeby(iCh) = PSPNR;
    end
    if sArgs.Intersection_Time_Lundeby
        outputStruct.Intersection_Time_Lundeby(iCh) = Intersection_Time_Lundeby - shiftTime(iCh);
    end
    
    %% huszty reverberation time
    if sArgs.T_Huszty
        outputStruct.T_Huszty(iCh)= ita_roomacoustics_reverberation_time_huszty(data,'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'shift', true, 'deltaT',50e-3);
    end
    
    %%   reverberation and energy parameter
    if ~isempty(parameterForReverberationTraditional) || sArgs.EDC || ~isempty(parametersForEnergy)
        
        % calculate EDC
        [edc, centerTimeData ] = ita_roomacoustics_EDC(data, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', sArgs.Center_Time, 'normTo0dB', sArgs.normalizeEDC);
        
        if sArgs.EDC % save EDC
            outputStruct.EDC(iCh) = edc;
            outputStruct.EDC(iCh).comment = [outputStruct.EDC(iCh).comment ' -> EDC'];
        end
        
        % normalize EDC for further calculations
        if ~sArgs.normalizeEDC
            edc.timeData =  bsxfun(@rdivide, edc.timeData, edc.timeData(1,:));
        end
        
        % calculate reverberation time
        if numel(parameterForReverberationTraditional)
            RTs  = ita_roomacoustics_reverberation_time(edc,'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'calcEdc', false,  parameterForReverberationTraditional{:});
            % copy data in output struct
            for iPar = 1:numel( parameterForReverberationTraditional)
                outputStruct.(parameterForReverberationTraditional{iPar})(iCh) = RTs.(parameterForReverberationTraditional{iPar});
            end
        end
        
        % calculate energy parameter
        if ~isempty(parametersForEnergy)
            CTs  = ita_roomacoustics_energy_parameters(edc,'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'centerTimeMat', centerTimeData, parametersForEnergy{:});
            
            % copy data in putput struct
            for iPar = 1:numel( parametersForEnergy)
                outputStruct.(parametersForEnergy{iPar})(iCh) = CTs.(parametersForEnergy{iPar});
            end
        end
    end
    
    if returnBandpassSignals
        bandPassfilterData(iCh) = ita_time_shift(data, -shiftTime(iCh), 'time');
    end
    
end


%% generate output variables
%  build struct: merge channels and copy channelnames
for iPar = parametersFromUser(:)'
    parName = cell2mat(iPar);
    if ~strcmp(parName, 'EDC') % engergy decay curves can have different length => do not merge
%         outputStruct.(parName) = merge(outputStruct.(parName));                                                                % merge channels
        freqData = [ outputStruct.(parName)(:).freqData];
        outputStruct.(parName) = outputStruct.(parName)(1);                                                                      % faster: merge channels by hand
        outputStruct.(parName).freqData = freqData;
        channelUnits = outputStruct.(parName).channelUnits(1);
        
        outputStruct.(parName) = ita_metainfo_copy(outputStruct.(parName), ir, 'excludeMetaInfoS', {'channelUnits', 'comment'});     % copy metaData
        outputStruct.(parName).channelUnits(:) = channelUnits;
        vararginExtenstion = {'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave, 'edcMethod', sArgs.edcMethod};   % add history
        outputStruct.(parName) = ita_metainfo_add_historyline(outputStruct.(parName),mfilename,[varargin vararginExtenstion]);
    end
end

varargout{1} = outputStruct;


% convert into old format of output
if sArgs.oldOutput
    resOld = itaResult(1, numel(parametersFromUser));
    for iPar = 1:numel(parametersFromUser)
        resOld(iPar) = outputStruct.(parametersFromUser{iPar});
    end
    varargout{1} = resOld;
end

% return bandpass signal
if returnBandpassSignals
    varargout{2} = bandPassfilterData;
end


% close waitbar
if showWaitbar
    wbh.close;
end


%end function
end