function paraStruct = ita_sph_plot_parser(varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% default parameters
def.type = 'magnitude'; % 'complex', 'sphere', 'spherephase', 'dB'
def.facealpha = 0.9;
def.edgealpha = 0.1;
def.sampling = [];
% def.samplingpoints = [];
% def.sampledvalues = [];
def.geometrypoints = [];
def.axes = 'outer';
def.fontsize = 12;
def.onballoon = 'none'; % 'smaller', 'greater', 'all'
% def.angunit = 'rad'; % ToDo: Winkeldarstellung Bogenmaß/Grad ('deg')
% def.plottype = 'ita_sph_plot'; evtl. noch für update-Funktion
def.caxis = [];
def.rlim = [];
def.line = false;

% stuff for the dot plot
def.symbol = 'o';
def.MarkerEdgeColor = 'k';
def.dotColor = [0 0 0]; % black
def.dotSampling = itaSamplingSph;
def.MarkerSize = 10;

% take over parameters from arguments (varargin)
paraStruct = ita_parse_arguments(def,varargin{:});
