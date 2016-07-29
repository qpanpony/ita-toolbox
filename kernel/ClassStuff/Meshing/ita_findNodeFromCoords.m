function varargout = ita_findNodeFromCoords(varargin)
%ITA_FINDNODEFROMCOORDS - extract the node ID at a specific location
%  This function takes the (x,y,z) coordinates of a node of a given mesh 
%  and returns the ID of that node.
%
%  Syntax: nodeID = ita_findNodeFromCoords(mesh,xval,yval[,zval])
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_change_header, ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_beam_beamforming.m, ita_beam_beamforming, ita_beam_manifoldVector, ita_beam_mapDataToMesh.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_findNodeFromCoords">doc ita_beam_findNodeFromCoords</a>

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Jan-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(4,4);
sArgs        = struct('pos1_dStruct','itaMeshNodes','pos2_xval','numeric','pos3_yval','numeric','pos4_zval','numeric');
[dStruct,xval,yval,zval,sArgs] = ita_parse_arguments(sArgs,varargin);

%%
nodeN = dStruct.ID(:); % node IDs
x = dStruct.x(:); % x-coordinates
y = dStruct.y(:); % y-coordinates
z = dStruct.z(:); % z-coordinates

% try to find the node at that location
idx = find(x == xval);
idy = find(y == yval);
idz = find(z == zval);
index = intersect(idx,idy);
index = intersect(index,idz);

d = -1;
if isempty(index) % if there is no node at the exact location
    % find the closest node
    d = sqrt(sum([x-xval,y-yval,z-zval].^2,2));
    [d,index] = min(d);
    if d > 10^-3 % more than a millimeter away
        ita_verbose_info([thisFuncStr 'exact location not found, searching the vicinity'],1);
        ita_verbose_info([thisFuncStr 'distance from exact search location: ' num2str(d)],1);
    end
end
node = nodeN(index);

%% Find output parameters
if nargout > 0
    % Write Data
    varargout(1) = {node};
    if nargout == 2
        varargout(2) = {d};
    end
end

%end function
end