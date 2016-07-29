function varargout = ita_tps(varargin)
%ITA_TPS - Transfer Path Synthesis
%  This function realises a standard transfer path synthesis based on
%  exciting blocked forces (F), Transfer Paths (TP) and Source and Receiver
%  Admittance (Y_S, Y_R)
%   
%   F and TP must have the same number of channels (one paths, several
%   sources), or TP could be a multi instance itaAudio containing paths up
%   to different receiving position. The number of channels still has to be
%   the same as in the first case.
%
%   Admittances can be of same size as F and TP or the can be quadratic
%   including cross coupling.
%   
%   Output is sound pressure (p) and optionally acceleration (a)
%
%  Syntax:
%   [p,a] = ita_tps(F, TP, Y_S, Y_R)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%
%  See also:
%   ita_otpa
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tps">doc ita_tps</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  11-Nov-2010 


%% Initialization and Input Parsing
sArgs        = struct('pos1_F','itaAudio','pos2_TP','itaAudio','pos3_YS','itaAudio','pos4_YR','itaAudio');
[F_b,TP,Y_S,Y_R ,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% calculate coupling matrix
K = pinv(Y_R +  Y_S) * Y_S ; %%% Fehler !!!! Y_S im Zähler muss da hin

% result =  1 ./ ( (a21 + a22*Y_R) / Y_S  + a11  + a12*Y_R );



%% predict insitu forces
F_insitu = K * F_b;

%% calculate acceleration at all points
v = Y_R * F_insitu;
a = ita_differentiate(v);

%% sum up contributions
for idx = 1:numel(TP)
    p(idx) = sum(TP(idx) * F_insitu(idx));
end
p = merge(p);

%% Set Output
varargout(1) = {p};
if nargout == 2
    varargout(2) = {a};
end

%end function
end