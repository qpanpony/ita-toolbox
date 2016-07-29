function varargout = ita_roomacoustics_late_lateral_sound_level(varargin)
%ITA_ROOMACOUSTICS_LATE_LATERAL_SOUND_LEVEL - calculates the late lateral sound level
%  This function calculates the relative level of late-arriving lateral sound
%  energy (LG) according ISO 3382-1. 
%
%  Syntax:
%   LG                     = ita_roomacoustics_late_lateral_sound_level(figOf8_measurement, referenceMeasurement, options)
%   [LG, referenceResult]  = ita_roomacoustics_late_lateral_sound_level(figOf8_measurement, referenceMeasurement, options)
%
%   Options (default):
%           'distanceOfReference' (10)                                : distance of reference measurement in meter
%           'freqRange'           (ita_preferences('freqRange'))      : frequncy range for analysis
%           'bandsPerOctave'      (ita_preferences('bandsPerOctave')) : bands per octave for filtering
%           'startThreshold'      (20)                                : threshold below maximum in dB to detect starting point for impulse response
%           'edcMethod'           ('cutWithCorrection')               : Used noise compensation technique (see [5] for overview)
%                                      'cutWithCorrection'                  : truncate impulse response at intersection time and apply compensation for cut (accorrding ISO 3382-1:2009)
%                                      'justCut'                            : truncate impulse response at intersection time (also ISO 3382-1 compliant)
%                                      'noCut'                              : take full impulse response for EDC calculation   (also ISO 3382-1 compliant)
%                                      'subtractNoise'                      : subtract noise energy from impulse response [4]
%                                      'subtractNoiseAndCutWithCorrection'  : subtract noise energy [4], truncate IR and compensate
%                                      'unknownNoise'                       : apply moving average window with width T/5 (according (old) ISO 3382:2000 )
%
%           'waitBar'            (false)                              : show progress bar for calculation
%           'useSinglePrecision' (false)                              : Use single precision to avoid memory errors
%  
%  Example:
%  LG = ita_roomacoustics_late_lateral_sound_level(figOf8_measurement, referenceMeasurement
%
%  See also:
%   ita_roomacoustics, ita_roomacoustics_lateral, ita_roomacoustics_IACC
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_roomacoustics_late_lateral_sound_level">doc ita_roomacoustics_late_lateral_sound_level</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  30-Oct-2012 

%% Initialization and Input Parsing

sArgs           = struct('pos1_data','itaAudio', 'pos2_reference','anything', 'distanceOfReference', 10, 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave') , 'linearConvolution', true, 'useSinglePrecision', false, 'waitBar', false, 'edcMethod', 'cutWithCorrection', 'startThreshold', 20);
[input, reference, sArgs]   = ita_parse_arguments(sArgs,varargin);

%% reference measurement: calculate engergy

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
    [RT_lundeby, ~ ,Intersection_Time_Lundeby, NoiseLundeby, ~] = ita_roomacoustics_reverberation_time_lundeby(refGefiltert ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);%  'broadbandAnalysis', sArgs.broadbandAnalysis);
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
elseif strcmpi(sArgs.reference, 'calibratedSource')
    freqVec = ita_ANSI_center_frequencies( sArgs.freqRange,  sArgs.bandsPerOctave);
    L_ref = ones(numel(freqVec), 1);
else
    error('invalid reference (can be itaAudio or itaResult)')
end


%% figure of eight measurement: calculate energy

% time shift
[input shiftTime]  = ita_time_shift(input, [num2str(sArgs.startThreshold) 'dB'] );              	% iso 3382 - min. 20dB before max peak
idx80ms = input.time2index(0.08);

nInputSamples   = input.nSamples + round(shiftTime*input.samplingRate)+rem(round(shiftTime*input.samplingRate),2);

if strcmpi(input.signalType, 'power')
    input.signalType = 'energy';
    ita_verbose_info('changing signal type of measurement to ENERGY',1)
end

nChannels = input.nChannels;
L  = zeros(numel(freqVec),nChannels);

% create filters
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
    wbh = itaWaitbar(nChannels, mfilename , {'channel'});
end


% loop for every channel
for iCh = 1:nChannels
    
    if sArgs.waitBar
        wbh.inc
    end
    
    % filter
    rirBands = input.ch(iCh) * filterSPK;
    rirBands = ita_extract_dat(rirBands, nInputSamples(iCh), 'forceSamples');   % get valid part of linear convolution
    
    % calc EDC
    [RT_lundeby, ~,  Intersection_Time_Lundeby NoiseLundeby, ~] = ita_roomacoustics_reverberation_time_lundeby(rirBands ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);%  'broadbandAnalysis', sArgs.broadbandAnalysis);
    edc = ita_roomacoustics_EDC(rirBands, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    L(:, iCh) = edc.timeData(idx80ms,:);
end


%% correct reference distance if necessary
if sArgs.distanceOfReference ~= 10
    L_ref = L_ref  * sArgs.distanceOfReference / 10;
    ita_verbose_info(sprintf('using correction of reference source distance form %2.1f m to 10 m', sArgs.distanceOfReference) ,1)
end

%% calc late lateral sound level
LG_data = 10*log10( L ./ repmat(L_ref,1,nChannels));

%% Set Output
LG               = itaResult(LG_data, freqVec, 'freq');
LG.allowDBPlot   = false;
LG.channelNames  = input.channelNames;
LG.comment       = [input.comment ' => LG[dB]'];
LG.channelUnits(:) = {'dB'};

varargout(1) = {LG};

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