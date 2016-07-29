function varargout = ita_thd(varargin)
%ITA_THD - Compute max THD and its frequency position.
%
%  This function computes the max THD and its frequency position from a given
%  harmonic distortion analysis audio object and its measurement setup.
%
%  Syntax:
%   [thd freq] = ita_thd(MS, MS.run_HD)
%
%   Options (default):
%           -
%
%  See also:
%   itaMSTF, ita_nonlinearities_find_harmonics
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_thd">doc ita_thd</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  06-Sep-2011 

%% TODO pdi: calculate correct THD spectrum!

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaMSTF','pos2_data','itaAudio','freqRange',[]);
[MS, a, sArgs] = ita_parse_arguments(sArgs,varargin);

if ~isempty(sArgs.freqRange)
    freqRange = sArgs.freqRange;
else
    freqRange = [(MS.freqRange(1)*1.5) (MS.freqRange(2)*0.95)];
end

binRange = a.freq2index(freqRange);
bins = binRange(1):binRange(end);
            
h1 = abs(a.ch(1).freqData(bins));
hx = sqrt(sum((abs(a.freqData(bins,2:a.dimensions))).^2,2));
            
[thd, sample]= max(hx./h1);
freq = a.freqVector(sample + binRange(1));

varargout(1) = {thd}; 
varargout(2) = {freq}; 