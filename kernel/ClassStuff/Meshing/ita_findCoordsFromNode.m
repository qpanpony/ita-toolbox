function varargout = ita_findCoordsFromNode(varargin)
%ITA_FINDCOORDSFROMNODE - extract coordinates from a given mesh
%  This function takes the ID of a node of a given mesh as input and
%  returns the (x,y,z) coordinates of that node.
%
%  Syntax: [xval,yval,zval] = ita_findCoordsFromNode(mesh,nodeID)
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_change_header, ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_beam_beamforming.m, ita_beam_beamforming, ita_beam_manifoldVector, ita_beam_mapDataToMesh, ita_beam_findNodeFromCoords.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_findCoordsFromNode">doc ita_beam_findCoordsFromNode</a>

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Jan-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];    % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,2);
sArgs        = struct('pos1_dStruct','itaMeshNodes','pos2_nodeID','numeric');
[dStruct,nodeID,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Body
nodeN = dStruct.ID(:); % node IDs
x = dStruct.x(:); % x-coordinates
y = dStruct.y(:); % y-coordinates
z = dStruct.z(:); % z-coordinates

nodeIdx = find(nodeN == nodeID); % get index of node
if ~isempty(nodeIdx) % if found get the coordinates
    xval = x(nodeIdx);
    yval = y(nodeIdx);
    zval = z(nodeIdx);
else
    error([thisFuncStr 'nothing found']);
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {xval};
    if nargout > 1
        varargout(2) = {yval};
        if nargout > 2
            varargout(3) = {zval};
        end
    end
end

%end function
end