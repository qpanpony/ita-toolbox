function ita_plot_solvercmp(varargin)
%ITA_PLOT_SOLVERCMP - Compare Solver imports with itaAudio. (spkphase plot)
%  This function plots the amplitude and phase of a Solver export file and
%  compares it with an arbitrary itaAudio object.
%
%  Syntax:
%   ita_plot_solvercmp(import,compare,mode)
%   import                      :   itaAudio
%   compare                     :   itaAudio
%   mode                        :   string
%
%  Modes:
%   spk         :   Amplitude plot like ita_plot_spk
%   spkphase    :   Amplitude and phase plot like ita_plot_spkphase
%   cmplx       :   Real and imaginary part plot like ita_plot_cmplx
%
%  Example:
%   import = ita_import_solver(44100,'Pa','Solver Import','./solver.txt');
%   compare=ita_generate('pinknoise',2^40,44100,15);
%   ita_plot_solvercmp(import,compare,'spkphase');
%
%   See also: ita_plot_freq, ita_plot_freq_phase, ita_plot_cmplx
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_solvercmp">doc ita_plot_solvercmp</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  15-Jul-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(3,3);
sArgs        = struct('pos1_import','itaAudio','pos2_compare','itaAudio','pos3_mode','string');
[import,compare,mode,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Get paramters

name_import     =   import.channelNames{1};
name_compare    =   compare.channelNames{1};

unit_import     =   import.channelUnits{1};
unit_compare    =   compare.channelUnits{1};

identifier_import   =   [name_import ' [dB re ' unit_import ']'];
identifier_compare  =   [name_compare ' [dB re ' unit_compare ']'];

%% Plotting
switch mode
    case 'spk'
        figure   =   ita_plot_freq(compare);
        ita_plot_freq(import,'figure_handle',figure,'hold','on');
        lines = findobj(figure,'Type','line');
        set(lines(5),'Color','r');  % import amplitude color
        set(lines(6),'Color','b');  % compare amplitude color
        legend(identifier_compare,identifier_import);
        
    case 'spkphase'
        [figure, axh]   =   ita_plot_freq_phase(compare);
        ita_plot_freq_phase(import,'figure_handle',figure,'axes_handle',axh,'hold','on');
        lines = findobj(figure,'Type','line');
        set(lines(4),'Color','b');  % compare amplitude color
        set(lines(8),'Color','b');  % compare phase color
        set(lines(3),'Color','r');  % import amplitude color
        set(lines(7),'Color','r');  % import phase color
        legend(axh(1),identifier_compare,identifier_import);
        
    case 'cmplx'
        [figure, axh]   =   ita_plot_cmplx(compare);
        ita_plot_cmplx(import,'figure_handle',figure,'axes_handle',axh,'hold','on');
        lines = findobj(figure,'Type','line');
        set(lines(6),'Color','b');  % compare real color
        set(lines(10),'Color','b'); % compare imag color
        set(lines(5),'Color','r');  % import real color
        set(lines(9),'Color','r');  % import imag color
        legend(axh(1),identifier_compare,identifier_import);
        
    otherwise
        error([thisFuncStr ' Mode ' mode ' unknown']);
end

      

%end function
end