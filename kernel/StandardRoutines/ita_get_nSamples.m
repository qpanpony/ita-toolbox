function varargout = ita_get_nSamples(varargin)
%ITA_GET_NSAMPLES - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   nSamples         = ita_get_nSamples(fftDegree, options)
%   [nSamples nBins] = ita_get_nSamples(fftDegree, options)
%
%   Options (default):
%           'nSamplesEven' (true) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_get_nSamples(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_get_nSamples">doc ita_get_nSamples</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  02-May-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_fftDegree','double', 'nSamplesEven', true);
[fftDegree,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 

if fftDegree < 30
    nSamples = round(2^fftDegree);
else
    nSamples = round(fftDegree);
end

if sArgs.nSamplesEven && rem(nSamples,2)
    nSamples = nSamples + 1;
end


%% Set Output
varargout(1) = {nSamples}; 

if nargout == 2
    varargout(2) = {nSamples/2+1}; 
end

%end function
end