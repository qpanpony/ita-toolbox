function varargout = ita_demosound(varargin)
%ITA_DEMOSOUND - Load song for demonstrations 
%
%  Syntax: audioObj = ita_demosound()
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_demosound">doc ita_demosound</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  16-Aug-2011 

result = ita_resample(ita_read('itademosong.ita'),ita_preferences('samplingRate'));
% make even samples
result.nSamples = floor(result.nSamples/2)*2;

%% Find output parameters
varargout(1) = {result};
end