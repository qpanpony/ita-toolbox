function varargout = ita_unit_inv(varargin)
%ITA_UNIT_INV - Physical Units of Inverse of Matrix
%  This function finds the physical units of the inverse of a given matrix
%  as itaValue
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

%% old but works
% adj = ita_unit_adj(input);
% det = ita_unit_det(input);
% res = adj;
% for idx = 1:size(adj,1)
%     for jdx = 1:size(adj,2)
%         aux = (1/det) * adj(idx,jdx);
%         res(idx,jdx) = aux;
%     end
% end

%% better?
adj  = ita_unit_adj(input);
det = ita_unit_det(input);
det = det.unit;
res  = adj;
for idx = 1:size(adj,1)
    for jdx = 1:size(adj,2)
        res(idx,jdx).unit = ita_deal_units( adj(idx,jdx).unit,det,'/');
    end
end

% % % adj = ita_unit_adj(input);
% % % det = ita_unit_det(input);
% % % res = adj;
% % % aux = itaValue;
% % % for idx = 1:size(adj,1)
% % %     for jdx = 1:size(adj,2)
% % %         aux.unit = ita_deal_units(adj(idx,jdx).unit, det.unit, '/');
% % %         res(idx,jdx) = aux;
% % %     end
% % % end


%% Set Output
varargout(1) = {res}; 

%end function
end