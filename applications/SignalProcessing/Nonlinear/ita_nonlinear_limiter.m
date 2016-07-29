function varargout = ita_nonlinear_limiter(s, limitValue,varargin)
%ITA_NONLINEAR_LIMITER - Limiting a time signal 
%  This function limits the amplitude of a signal in time domain. Please be
%  aware that this might result in aliasing. Hence, an oversampling factor
%  can be defined (standard: 10) that increases the sampling rate by this
%  factor before applying the limiter.
%
%  Syntax:
%   audioObjOut = ita_nonlinear_limiter(audioObjIn, LimitValue,'oversampling',10)
%
%  Example:
%   audioObjOut = ita_nonlinear_limiter(audioObjIn,0.5)
%
%  See also:
%   ita_nonlinear_harmonic_series, ita_nonlinear_power_series
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_limiter">doc ita_nonlinear_limiter</a>

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Sep-2012 

%% parse input
sArgs = struct('oversampling',10);
sArgs = ita_parse_arguments(sArgs,varargin);

limitValue = abs(double(limitValue));

%% nothing to do? just leave!
if isempty(limitValue)
    varargout{1} = s;
    return;
end

%% oversampling
s_orig = s; 
s  = ita_oversample(s,sArgs.oversampling);

%% limiter
s.time = max(min(s.time,limitValue),-limitValue);

%% downsampling
s_orig.freq = s.freq(1:s_orig.nBins);

%% Add history line
s_orig = ita_metainfo_add_historyline(s_orig,mfilename,limitValue);

%% Set Output
varargout(1) = {s_orig}; 

%end function
end