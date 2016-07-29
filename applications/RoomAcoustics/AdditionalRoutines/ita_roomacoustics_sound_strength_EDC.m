function varargout = ita_roomacoustics_sound_strength(varargin)
%ITA_ROOMACOUSTICS_SOUND_STRENGTH - calculate sound strength
%  This function calculates the sound strength.
%
%
%
%  Syntax:
%    G               = ita_roomacoustics_sound_strength(irMeasurement, irReference,  options)
%   [G refIntegral]  = ita_roomacoustics_sound_strength(irMeasurement, irReference,  options)
%
%   Options (default):
%           'distanceOfReference' (10)                                : distance of reference measurement in meter
%           'freqRange'           (ita_preferences('freqRange'))      : frequncy range for analysis
%           'bandsPerOctave'      (ita_preferences('bandsPerOctave')) : bands per octave for filtering
%           'opt3' (defaultopt1)                                      :
%
%  Example:
%   [G1 refIntegral] = ita_roomacoustics_sound_strength(irMeasurement1, irReference, 'distanceOfReference', 7)
%   G2               = ita_roomacoustics_sound_strength(irMeasurement2, refInegral,  'distanceOfReference', 7);  % reuse the reference integral
%
%  See also:
%   ita_roomacoustics, ita_roomacoustics_lateral, ita_roomacoustics_IACC
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_sound_strength">doc ita_roomacoustics_sound_strength</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  09-Aug-2011

% TODO:
% - warnung wenn dynamik vpn p kleiner als 30 dB
% - output ref ist nicht um distanz korregiert

%% Initialization and Input Parsing

sArgs           = struct('pos1_data','itaAudio', 'pos2_reference','anything', 'distanceOfReference', 10, 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave') , 'linearConvolution', true, 'useSinglePrecision', false, 'waitBar', false, 'edcMethod', 'cutWithCorrection');
[input, reference, sArgs]   = ita_parse_arguments(sArgs,varargin);

%% reference

if isa(sArgs.reference, 'itaAudio')
    
    if reference.nChannels ~= 1
        error('nChannels of reference is %i', reference.nChannels)
    end
    
    %
    if strcmpi(reference.signalType, 'power')
        reference.signalType = 'energy';
        ita_verbose_info('changing signal type of reference to ENERGY',1)
    end
    
    % calc filter
    nReferenceSamples = reference.nSamples;
    if sArgs.linearConvolution
        nSamplesFilter = reference.nSamples + 2^15 - 1;  % default filter length of mpb_filter
        nSamplesFilter = nSamplesFilter+ rem(nSamplesFilter,2);
        reference = ita_extend_dat(reference, nSamplesFilter, 'forcesamples');
    else
        nSamplesFilter = reference.nSamples;
    end
    
    imp     = ita_generate('impulse',1,reference.samplingRate, nSamplesFilter);
    if sArgs.useSinglePrecision
        imp.dataType = 'single';
    end
    [filterSPK freqVec]  = ita_fractional_octavebands(imp,'bandsperoctave',sArgs.bandsPerOctave, 'freqRange', sArgs.freqRange, 'zerophase' ,false);
    
   
    % calc ref values
    refGefiltert       = reference * filterSPK;
    refGefiltert = ita_extract_dat(refGefiltert, nReferenceSamples, 'forceSamples');   % get valid part of linear convolution
    
    
    % calc EDC
    [RT_lundeby PSNR Intersection_Time_Lundeby NoiseLundeby PSPNR] = ita_roomacoustics_reverberation_time_lundeby(refGefiltert ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);%  'broadbandAnalysis', sArgs.broadbandAnalysis);
    edc = ita_roomacoustics_EDC(refGefiltert, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    L_ref = edc.timeData(1,:).';    
    
elseif isa(sArgs.reference, 'itaResult')
    freqVec = ita_ANSI_center_frequencies( sArgs.freqRange,  sArgs.bandsPerOctave);
    
    if ~isequal(sArgs.reference.freqVector(:), freqVec(:))
        error('frequency vector of reference and freqRange/bandsPerOctave parameter do not match')
    end
    L_ref = sArgs.reference.freqData;
    
    % elseif ischar(sArgs.reference)
    %     switch sArgs.reference
    %         case 'itaDode'
    %
    %         case 'itaDodeOld'
    %
    %         otherwise
    %             error('unknown source')
    %     end
else
    error('invalid reference (can be itaAudio or itaResult)')
end


%% measurement

if strcmpi(input.signalType, 'power')
    input.signalType = 'energy';
    ita_verbose_info('changing signal type of measurement to ENERGY',1)
end


nChannels = input.nChannels;
L  = zeros(numel(freqVec),nChannels);


nInputSamples = input.nSamples;
if sArgs.linearConvolution
    nSamplesFilter = input.nSamples + 2^15 - 1;  % default filter length of mpb_filter
    nSamplesFilter = nSamplesFilter+ rem(nSamplesFilter,2);
    input = ita_extend_dat(input, nSamplesFilter, 'forcesamples');
else
    nSamplesFilter = input.nSamples;
end

imp     = ita_generate('impulse',1,input.samplingRate, nSamplesFilter);
if sArgs.useSinglePrecision
    imp.dataType = 'single';
end
[filterSPK freqVec]  = ita_fractional_octavebands(imp,'bandsperoctave',sArgs.bandsPerOctave, 'freqRange', sArgs.freqRange, 'zerophase' ,false);

if sArgs.waitBar
    wbh = itaWaitbar(nChannels, 'ita_roomacoustics_sound_strength', {'channel'});
end

for iCh = 1:nChannels
    
    if sArgs.waitBar
        wbh.inc
    end
    % filter
    rirBands = input.ch(iCh) * filterSPK;
    rirBands = ita_extract_dat(rirBands, nInputSamples, 'forceSamples');   % get valid part of linear convolution
    
    
    
    % calc EDC
    [RT_lundeby PSNR Intersection_Time_Lundeby NoiseLundeby PSPNR] = ita_roomacoustics_reverberation_time_lundeby(rirBands ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);%  'broadbandAnalysis', sArgs.broadbandAnalysis);
    edc = ita_roomacoustics_EDC(rirBands, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    L(:, iCh) = edc.timeData(1,:);

    
    
    
    
% % %     % integration limits
% % %     idxStart = ita_start_IR(rirBands);
% % %     
% % %     [del1 snr intersectionTime] = ita_roomacoustics_reverberation_time_lundeby(rirBands, 'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);
% % %     idxEnd = round(rirBands.samplingRate * intersectionTime.freqData);
% % %     
% % %     
% % %     
% % %         idxLowSNR = find(snr.freqData_dB < 30);
% % %         for iChLowSNR = idxLowSNR(:)'
% % %             ita_verbose_info(sprintf('Low SNR in ch %i (%2.1f dB) ', iChLowSNR, 20*log10(snr.freqData(iChLowSNR)) ), 0)
% % %             [idxStart(iChLowSNR) idxEnd(iChLowSNR)] = deal(nan);
% % %         end
% % %     
% % %     % integrate
% % %     rirBandsData = rirBands.timeData.^2 ;
% % %     for iFreq = 1:numel(freqVec)
% % %         if any(isnan([idxStart(iFreq) idxEnd(iFreq)]))
% % %             L(iFreq) = nan;
% % %         else
% % %             L(iFreq, iCh) = sum(rirBandsData(idxStart(iFreq):idxEnd(iFreq), iFreq));
% % %         end
% % %     end
% % %     
end
% % % L = L ./ input.samplingRate;


% % %% try to use EDC
% % possibleMethods = {'noCut' 'justCut' 'cutWithCorrection' 'subtractNoise' 'subtractNoiseAndCutWithCorrection' 'unknownNoise' };
% % 
% % edcResult = zeros(rirBands.nChannels, numel(possibleMethods));
% % for iMethod = 1:numel(possibleMethods )
% %     edc = ita_roomacoustics_EDC(rirBands,'method', possibleMethods{iMethod}, 'normTo0dB', false)
% %     edcResult(:, iMethod) = edc.timeData(1,:);
% % end
% % 
% % cmpRes = itaResult(10*log10(edcResult), freqVec, 'freq');
% % cmpRes.allowDBPlot = false;
% % cmpRes.channelNames = possibleMethods;
% % cmpRes.pf

%%

% correct reference distance if necessary
if sArgs.distanceOfReference ~= 10
    L_ref = L_ref  * sArgs.distanceOfReference / 10;
    ita_verbose_info(sprintf('using correction of reference source distance form %2.1f m to 10 m', sArgs.distanceOfReference) ,1)
end

%% calc sound strength
G_data = 10*log10( L ./ repmat(L_ref,1,nChannels));


%% Set Output
G               = itaResult(G_data, freqVec, 'freq');
G.allowDBPlot   = false;
G.channelNames  = input.channelNames;
G.comment       = [input.comment ' => G[dB]'];
G.channelUnits(:) = {'dB'};

varargout(1) = {G};

if nargout == 2
    refResult = itaResult(L_ref, freqVec, 'freq');
    refResult.channelNames = reference.channelNames;
    refResult.comment = [reference.comment ' => integrated engergy (in 10 m)'];
    refResult.channelUnits(:) = {''};
    
    varargout(2) = {refResult};
end


if sArgs.waitBar
    wbh.close
end

%end function
end