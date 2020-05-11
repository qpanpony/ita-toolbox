function varargout = ita_roomacoustics_kurtosis(varargin)
%ITA_ROOMACOUSTICS_KURTOSIS - +++ Short Description here +++
% This function calculates the kurtosis of room impulse responses as a
% diffuseness measure as proposed by Jeong for reverberation chambers in
% Cheol-Ho Jeong "Kurtosis of room impulse responses as a diffuseness
% measure for reverberation chambers" J. Acoust. Soc. Am. 139 (5), May 2016
%
%  Syntax:
%   varargout = ita_roomacoustics_kurtosis(audioObjIn, options)
%
%   Options (default):
%           'freqRange'      [125*2^(-1/2) 4e3*2^(1/2)]  : preferred frequncy range
%           'timeRange'      [10e-3 100e-3] : preferred time range
%
%  Example:
%   audioObjOut = ita_roomacoustics_kurtosis(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_kurtosis">doc ita_roomacoustics_kurtosis</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Ernesto Accolti -- Email: eac@akustik.rwth-aachen.de
% Created:  08-Jan-2020


%% Initialization and Input Parsing
fr=[125*2^(-1/2) 4e3*2^(1/2)]; % default frequncy range
tr=[10e-3 100e-3]; % default time range
sArgs         = struct('pos1_data','itaAudio','freqRange',fr,'timeRange',tr);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Main code

% filter
input=ita_filter_bandpass(input,'zerophase', true,'order',10,'upper', ...
    sArgs.freqRange(2),'lower', sArgs.freqRange(1));

% time shift 
nShiftSamples = ita_start_IR(input);
input=ita_time_shift(input,-nShiftSamples,'samples'); 
% MAIN
Nr=sArgs.timeRange*input.samplingRate;
k = kurtosis(input.timeData((Nr(1):Nr(2)),:));


%% Output
varargout={k};

%end function
end