function [z,p,k] = ita_zpk_smooth(z,p,k,varargin)
%ITA_ZPK_SMOOTH - Shift poles/zeros too near to unity circle away from it.
%
%  Syntax:
%   audioObjOut = ita_zpk_smooth(audioObjIn, options)
%
%   Options (default):
%           'threshold' (1e-2) : Limit of proximity to the unity circle
%
%  Example:
%   [z,p,k] = ita_zpk_smooth(z,p,k)
%
%  See also:
%   ita_zpk_reduce, ita_plot_zplanepz, ita_prony_analysis
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zpk_smooth">doc ita_zpk_smooth</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  01-Sep-2010 



%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('threshold','0.01');
sArgs = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% Body

% distance from poles and zeros to the unity circle
dp = abs(p) - 1;
dz = abs(z) - 1;

idx_p = find(abs(dp) < sArgs.threshold);
idx_z = find(abs(dz) < sArgs.threshold);

%TO DO: find a better curve so substitute this hard threshold \__

p(idx_p) = (1 +sign(dp(idx_p))*sArgs.threshold) .* exp(1i*angle(p(idx_p)));
z(idx_z) = (1 +sign(dz(idx_z))*sArgs.threshold) .* exp(1i*angle(z(idx_z)));

%end function
end