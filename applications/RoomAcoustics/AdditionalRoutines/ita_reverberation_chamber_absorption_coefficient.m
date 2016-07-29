function varargout = ita_reverberation_chamber_absorption_coefficient(varargin)
%ITA_REVERBERATION_CHAMBER_ABSORPTION_COEFFICIENT - calculates the
%absorption coefficient out of 2 reverberation time measurements
% 
%  This function calculates the absorption coefficient out of 2
%  reverberation time measurements (with/without absorption material in the
%  room) in the reverbaration chamber.
%
%  Syntax:
%   audioObjOut = ita_reverberation_chamber_absorption_coefficient(T_empty,T_material,options)
%  Options (default):
%   'V_0' (124)         :       room volume
%   'S_0' (181)         :       surface of reverberatiion chamber
%   'material_area'     :       surface of absorption material
%
%  Example:
%   audioObjOut = ita_reverberation_chamber_absorption_coefficient(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_reverberation_chamber_absorption_coefficient">doc ita_reverberation_chamber_absorption_coefficient</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  24-Jun-2010 



%% Initialization and Input Parsing
sArgs        = struct('pos1_T_empty', 'itaSuper', 'pos2_T_material', 'itaSuper', 'V_0', 124, 'S_0', 181, 'material_area', 10.5);
[T_empty,T_material,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% calculate absorption
revT_empty = ita_mean(T_empty);
revT_material = ita_mean(T_material);

alpha0 = 0.163 * sArgs.V_0/(revT_empty * sArgs.S_0);
alpha0.channelNames{1} = 'alpha0 (room)';
[alpha1] = 0.163 * (sArgs.V_0/sArgs.material_area) * (1/revT_material - 1/revT_empty) + alpha0;
alpha1.channelNames{1} = 'alpha1 (material)';
ita_plot_spk(merge(alpha0,alpha1),'nodb');
ylim([0 1]);

%% Set Output
varargout(1) = {alpha1}; 

%end function
end