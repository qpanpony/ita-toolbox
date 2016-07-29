function varargout = ita_roomacoustics_lateral_EDC(varargin)
%ITA_ROOMACOUSTICS_LATERAL - calculates LFC, LF and LE
%
%  This function calculates lateral energy parameters of a given impulse
%  response after ISO 3382. In order to compute this parameter a measurement of the
%  impulse response with omnidirectional and bidirectional microphones is
%  required. This funtion analyses the input data and looks for the words
%  "Omni" and "Eight" (or "acht" or "gradient") in the channel names. If
%  this names are not included, then the first and second channel of the input
%  data will be selected as omnidirectional and bidirectional respectively.
%
%
%  LFC (lateral fraction coefficient)   ( (lateral energy 5..80 ms  ) .* (omni energy 5..80 ms  ) ) / (omni engergy 0...80 ms)
%  LF (lateral fraction)                (lateral energy 5..80 ms  ) / (omni engergy 0...80 ms)
%  LE (lateral efficiency)              (lateral energy 25..80 ms ) / (omni engergy 0...80 ms)
%
%  Syntax:
%    outStruct           = ita_roomacoustics_lateral(rir, options)
%
%   Options (default):
%           'freqRange'      ([125 8000]) : description
%           'bandsPerOctave' (1)          : description
%           'edcMethod' 
%
%  Example:
%   LFC = ita_roomacoustics_lateral(rir)
%
%  See also:
%   ita_roomacoustics
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_lateral">doc ita_roomacoustics_lateral</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  08-Sep-2011

%% Initialization and Input Parsing

sArgs           = struct('pos1_data','itaAudio', 'bandsPerOctave', 1, 'freqRange', [125 8000],  'edcMethod', 'cutWithCorrection');
[input,sArgs]   = ita_parse_arguments(sArgs,varargin);


% identify channels
[idxOmni idxEight] = ita_identify_channels(input, 'omni', {'eight' 'acht' 'gradient'});

if ~isempty(intersect(idxOmni, idxEight))
    error('Channel %i contains both keywords!\n', intersect(idxOmni, idxEight))
end

nFoundChannels = [numel(idxOmni) numel(idxEight)];
if any(nFoundChannels == 0)  % one or two channels not found
    error('Failed to identify the channels. Channel names must contain EIGHT and OMNI to identify them.')
elseif any(nFoundChannels > 1)  % more than one match
    error('Failed to identify the channels. More than one match for  EIGHT or OMNI.')
else
    ita_verbose_info(sprintf('Found omnidirectional microphone channel: ''%s''', input.channelNames{idxOmni} ), 1)
    ita_verbose_info(sprintf('Found figure-of-eight microphone channel: ''%s''', input.channelNames{idxEight} ),1)
end

%%
timeIdxVec = (input.time2index([5 25 80]/1000));
idx0ms  =1; idx5ms = timeIdxVec(1); idx25ms  = timeIdxVec(2); idx80ms = timeIdxVec(3);

% time shifting (reference channel is omni, both channles shifted by same time)
[omniChannel shiftTime] = ita_time_shift(input.ch(idxOmni),'-20dB');
eightChannel = ita_time_shift(input.ch(idxEight), shiftTime, 'time');


[ omniFilter  freqVec ]  = ita_fractional_octavebands(omniChannel,  'bandsPerOctave', sArgs.bandsPerOctave, 'freqRange', sArgs.freqRange, 'zerophase');
eightFilter              = ita_fractional_octavebands(eightChannel, 'bandsPerOctave', sArgs.bandsPerOctave, 'freqRange', sArgs.freqRange, 'zerophase');



if strcmpi(sArgs.edcMethod, 'nocut')
    dataOmni  = omniFilter.timeData(1:idx80ms,:);
    dataEight = eightFilter.timeData(1:idx80ms,:);
    
    E_0_80   = sum(dataOmni(idx0ms:idx80ms,:).^2);
    
    LF_data  = sum(dataEight(idx5ms:idx80ms,:).^2)                                      ./ E_0_80;
    LFC_data = sum(abs(dataEight(idx5ms:idx80ms,:) .* dataOmni(idx5ms:idx80ms,:)))      ./ E_0_80;
    LE_data  = sum(dataEight(idx25ms:idx80ms,:).^2)                                     ./ E_0_80;
    
else
    [RT_lundeby PSNR_omni Intersection_Time_Lundeby NoiseLundeby PSPNR] = ita_roomacoustics_reverberation_time_lundeby(omniFilter ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);
    omniFilterEDC = ita_roomacoustics_EDC(omniFilter, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    
    [RT_lundeby PSNR_eight Intersection_Time_Lundeby NoiseLundeby PSPNR] = ita_roomacoustics_reverberation_time_lundeby(eightFilter ,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);
    eightFilterEDC = ita_roomacoustics_EDC(eightFilter, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    
    E_omni_0_80 = omniFilterEDC.timeData(1,:) - omniFilterEDC.timeData(idx80ms,:);
    
    LF_data = ( eightFilterEDC.timeData(idx5ms,:) - eightFilterEDC.timeData(idx80ms,:) ) ./ E_omni_0_80;
    LE_data =  ( eightFilterEDC.timeData(idx25ms,:) - eightFilterEDC.timeData(idx80ms,:) ) ./ E_omni_0_80;
    
    omniMultEight = sqrt(abs(eightFilter .* omniFilter));
    [RT_lundeby PSNR_omniEight Intersection_Time_Lundeby NoiseLundeby PSPNR] = ita_roomacoustics_reverberation_time_lundeby( omniMultEight,'freqRange', sArgs.freqRange, 'bandsPerOctave', sArgs.bandsPerOctave);
    omniMultEightFilterEDC = ita_roomacoustics_EDC(omniMultEight, 'method', sArgs.edcMethod, 'intersectionTime', Intersection_Time_Lundeby, 'lateRevEstimation', RT_lundeby, 'noiseRMS', NoiseLundeby, 'calcCenterTime', false, 'normTo0dB', false);
    
    LFC_data = ( omniMultEightFilterEDC.timeData(idx5ms,:) - omniMultEightFilterEDC.timeData(idx80ms,:) ) ./ E_omni_0_80;
    
    

end

%% Set Output


resultDummy = itaResult(zeros(length(freqVec),1), freqVec, 'freq');
resultDummy.channelNames        = input.channelNames(idxEight);
resultDummy.allowDBPlot         = false;
resultDummy.plotAxesProperties  = {'yLimit', [0 1], 'ylabel', ''};


outStruct.LFC                     = resultDummy;
outStruct.LFC.freqData            = LFC_data.';
outStruct.LFC.comment             = [input.comment ' -> LF(C) '] ;

outStruct.LF                 = resultDummy;
outStruct.LF.freqData        = LF_data.';
outStruct.LF.comment         = [input.comment ' -> LF'];


outStruct.LE                 = resultDummy;
outStruct.LE.freqData        = LE_data.';
outStruct.LE.comment         = [input.comment ' -> LE'];


if ~strcmpi(sArgs.edcMethod, 'nocut')
    outStruct.PSNR_omni = PSNR_omni;
    outStruct.PSNR_eight = PSNR_eight;
    outStruct.PSNR_omniEight = PSNR_omniEight;
end

varargout(1) = {outStruct};


%end function
end