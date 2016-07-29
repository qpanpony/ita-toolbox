function varargout = ita_mic_KE4_equalization(varargin)
%ITA_MIC_KE4_EQUALIZATION - KE4 Equalization
%  This function calculates the KE4 Calibration Curves based on an RF model
%  data set.
%
%  Syntax:
%   audioObjOut = ita_mic_KE4_equalization(options)
%
%   Options (default):
%           'fftDegree' (16) : fft degree of final result
%           'sammplingRate' (preferences sr) : sampling rate of result
%           'micNumber' (all) : number vec of mics
%   Example:
%      ita_mic_KE4_equalization('micNumber',[1 5 9],'fftDegree',19,'samplingRate',96000)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_mic_KE4_equalization">doc ita_mic_KE4_equalization</a>

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-Nov-2010 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('fftDegree',16, 'samplingRate', ita_preferences('samplingRate'),'micNumber',[]);
[sArgs] = ita_parse_arguments(sArgs,varargin); 

%% reconstruct 
res = load('KE4_fit_data_rf.mat');

if isempty(sArgs.micNumber)
    sArgs.micNumber = 1:length(res.fit_data);
end

result              = itaAudioAnalyticRational();
result.samplingRate = sArgs.samplingRate;
result.fftDegree    = sArgs.fftDegree;
result.signalType   = 'energy';
result.analyticData = res.fit_data;

if isempty(sArgs.micNumber)
   sArgs.micNumber = 1:numel(result.analyticData); 
end

for idx = 1:numel(sArgs.micNumber)
%     result(idx).freq = res.fit_data(sArgs.micNumber(idx)).freqresp(freqVector);
    result.channelNames{idx} = ['KE4 mic - no. ' num2str(sArgs.micNumber(idx))];
end

%% Set Output
varargout(1) = {result}; 

%end function
end