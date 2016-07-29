function ita_load_default_variables(varargin)
%ITA_LOAD_DEFAULT_VARIABLES - Load some Audio variables for DSP
%  This function creates or loads some nice variables to fill your
%  workspace.
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_load_default_variables">doc ita_load_default_variables</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  22-Aug-2011 


%% Initialization and Input Parsing
fftDegree = 14;
sr = ita_preferences('samplingRate');
assignin('base','default_sweep',ita_generate_sweep('fftDegree',fftDegree, 'samplingRate',sr));
assignin('base','default_sine',ita_generate('sine',1,1000,sr,fftDegree));
assignin('base','default_impulse',ita_generate('impulse',1,sr,fftDegree));
assignin('base','default_bandpass',ita_mpb_filter(ita_generate('impulse',1,sr,fftDegree),[100 4000]));
assignin('base','demosound', ita_demosound);

%end function
end