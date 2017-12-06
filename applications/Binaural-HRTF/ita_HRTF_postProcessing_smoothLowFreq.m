function varargout = ita_HRTF_postProcessing_smoothLowFreq(varargin)
%ITA_HRTF_POSTPROCESSING_SMOOTHLOWFREQ - Fills low frequency of HRTF measurement
%  This function will take a HRTF measurement and fills in low frequency content.
%  Data is interpolated to 1 at 0 Hz
%  Phase information is preserved.
%
%  Syntax:
%   audioObjOut = ita_HRTF_postProcessing_smoothLowFreq(audioObjIn, options)
%
%   Options (default):
%           'cutOffFrequency' (100) : The lowest point of measured data
%           'upperFrequency' (300)  : Frequency information up to this frequency is used during interpolation but not changed
%           'timeShift' (0)         : Time shift the data to zero to help
%                                       with unwrap phase
%
%  Example:
%   audioObjOut = ita_HRTF_postProcessing_smoothLowFreq(audioObjIn,'cutOffFrequency',100)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_HRTF_postProcessing_smoothLowFreq">doc ita_HRTF_postProcessing_smoothLowFreq</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  21-Aug-2017


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'cutOffFrequency', 100,'upperFrequency',300,'timeShift',0);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% body

% for multi instances, do a for loop
for instIndex = 1:length(input)
  % first, shift the HRTF to 0. This will allow better phase interpolation

  if sArgs.timeShift
    shiftSamples = ita_start_IR(input(instIndex));
    [tmp] = ita_time_shift(input(instIndex),-shiftSamples,'samples');
  else
      tmp = input(instIndex);
  end

  
  % interpolate to 0
  binIdxAtLower    = tmp.freq2index(sArgs.cutOffFrequency);
  binIdxAtUpper    = tmp.freq2index(sArgs.upperFrequency);
  dataFromLowerToUpper = tmp.freqData(binIdxAtLower:binIdxAtUpper,:);
  interpValues1 = interp1([0 tmp.freqVector(binIdxAtLower:binIdxAtUpper)], [ones(1,tmp.nChannels); abs(dataFromLowerToUpper)], tmp.freqVector(1:binIdxAtUpper));
  interpPhase = interp1(tmp.freqVector(binIdxAtLower:binIdxAtUpper),unwrap(angle(dataFromLowerToUpper)),tmp.freqVector(1:binIdxAtUpper),'linear','extrap');

  % set the interpolated values into the shifted audio
  tmp.freqData(1:binIdxAtUpper,:) = interpValues1.*exp(1i.*interpPhase);

  %% Add history line
  tmp = ita_metainfo_add_historyline(tmp,mfilename,varargin);
  if sArgs.timeShift
      % shift the audio back to its original position
      data_full(instIndex) = ita_time_shift(tmp,shiftSamples,'samples');
  else
     data_full(instIndex) = tmp; 
  end

end

%% Set Output
varargout(1) = {data_full};

%end function
end
