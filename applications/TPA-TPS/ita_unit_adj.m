function varargout = ita_unit_adj(varargin)
%ITA_UNIT_DET - Physical Units of Determinant
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_unit_adj(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_unit_det(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_unit_det">doc ita_unit_det</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  21-Jul-2011 



%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaValue');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% 
% minorante = repmat(itaValue,size(input,1),size(input,2));
% for idx = 1:size(input,1)
%     for jdx = 1:size(input,2)
%         minorante(idx,jdx) = ita_unit_det(input([1:idx-1 idx+1:end],[1:jdx-1 jdx+1:end]));
%     end
% end
%     
% % transpose
% adj = minorante';

%% better ? 
adj = input; % repmat(itaValue,size(input,1),size(input,2));
N   = size(input,1);
for idx = 1:N
    for jdx = 1:N
        idxx = [1:idx-1 idx+1:N];
        jdxx = [1:jdx-1 jdx+1:N];
        
        determinant = input(idxx(1),jdxx(1)).unit;
        for jj = 2:numel(idxx)
            determinant = ita_deal_units( determinant,input(idxx(jj),jdxx(jj)).unit ,'*');
        end
%         determinant / ita_unit_det(input(idxx,jdxx))
        adj(jdx,idx) =  determinant; %ita_unit_det(input(idxx,jdxx));
        
% %         ita_unit_det(input([1:idx-1 idx+1:end],[1:jdx-1 jdx+1:end]));
    end
end


%% Set Output
varargout(1) = {adj}; 

%end function
end