function obj = load_ac3d(varargin)
%LOAD_AC3D - Creates an itaAc3dModel obj
%   This is a wrapper to support the former itaAc3dModel classname
%   "load_ac3d". In future, just use itaAc3dModel directly.
%
%   See also itaAc3dModel.
%
%   Autor: Philipp Schäfer -- Email: psc@akustik.rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


obj = itaAc3dModel(varargin{:});