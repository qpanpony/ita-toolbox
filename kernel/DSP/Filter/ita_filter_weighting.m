function varargout = ita_filter_weighting(varargin)
%ITA_FILTER_WEIGHTING - apply weighting filters
%  This function applies the weighting filters according to ISO DIN 61672-1
%  to the given input object, be it itaAudio or itaResult.
%
%  Syntax:
%   audioObjOut = ita_filter_weighting(objIn, options)
%
%   Options (default):
%           'type' ('A') : which filter, 'A' or 'C'
%
%  Example:
%   audioObjOut = ita_filter_weighting(test)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_filter_weighting">doc ita_filter_weighting</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  12-Aug-2013


%% Initialization and Input Parsing
% please see the documentation for more details
sArgs        = struct('pos1_data','itaSuper', 'type', 'A');
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

% weighting according to DIN 61672-1
% normalization constants and pole frequencies (D.4)
f1 = 20.6; % Hz
f2 = 107.7; % Hz
f3 = 737.9; % Hz
f4 = 12194; % Hz
A1000 = -2.000; % dB
C1000 = -0.062; % dB

switch lower(sArgs.type)
    case 'a'
        weightFunc = @(f) (f4^2 .* f.^4./((f.^2 + f1.^2).*sqrt(f.^2 + f2.^2).*sqrt(f.^2 + f3.^2).*(f.^2 + f4.^2))).*10^(-A1000/20);
    case 'c'
        weightFunc = @(f) (f4^2 .* f.^2./((f.^2 + f1.^2).*(f.^2 + f4.^2))).*10^(-C1000/20);
    otherwise
        error(['Wrong weighting type:' sArgs.type]);
end
input.freq = bsxfun(@times,input.freq,weightFunc(input.freqVector));

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input};

%end function
end