function varargout = ita_mapDataToMesh(varargin)
%ITA_MAPDATATOMESH - maps two-dimensional data onto a given mesh
%  This function takes an audio object and a mesh object and returns an
%  audio object with two-dimensional data per frequency.
%
%  Syntax: itaAudio = ita_mapDataToMesh(itaAudio,Mesh)
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_change_header, ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_beam_beamforming.m, ita_beam_beamforming, ita_beam_manifoldVector.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_beam_mapDataToMesh">doc ita_beam_mapDataToMesh</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  22-Jan-2009

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_dataStruct','itaSuper','pos2_meshStruct','itaCoordinates');
[dataStruct,meshStruct,sArgs] = ita_parse_arguments(sArgs,varargin);  %#ok<ASGLU>

if ~isa(meshStruct,'itaMeshNodes')
   meshStruct = itaMeshNodes(meshStruct.cart,'cart'); 
end

%% Body
% get coordinates with 0.1mm precision
meshStruct.cart = round((meshStruct.cart).*10^4)./10^4;
x_n = unique(meshStruct.x); % x-coordinates
y_n = unique(meshStruct.y); % y-coordinates
z_n = unique(meshStruct.z); % z-coordinates

data = dataStruct.([dataStruct.domain 'Data']); % the old data
if isa(dataStruct.channelCoordinates,'itaMeshNodes') && all(~isnan(dataStruct.channelCoordinates.ID))
    oldNodes = dataStruct.channelCoordinates.ID;
elseif ~isempty(find(strcmpi(dataStruct.userData,'nodeN')==1,1))
    oldNodes = dataStruct.userData{find(strcmpi(dataStruct.userData,'nodeN')==1)+1}(:); % old node IDs
else
    oldNodes = 1:dataStruct.nChannels;
end

searchCoords = zeros(numel(x_n)*numel(y_n)*numel(z_n),3);
% build the search database for faster searching
meshStruct = build_search_database(meshStruct);

if numel(x_n)*numel(y_n)*numel(z_n) > 1.1*dataStruct.nChannels
    ita_verbose_info([thisFuncStr 'mesh is not rectangular and evenly-spaced,' ...
        'will only map according to IDs'],0);
    permuteIndices = zeros(numel(oldNodes),1);
    newNodes = meshStruct.ID;
    for i=1:numel(oldNodes)
        permuteIndices(i) = find(oldNodes(i) == newNodes);
    end
    dataStruct.channelCoordinates = meshStruct.n(permuteIndices);
else
    ita_verbose_info([thisFuncStr 'mapping ...'],1);
    for i=1:numel(x_n)
        for j=1:numel(y_n)
            for k=1:numel(z_n)
                searchCoords(sub2ind([numel(x_n),numel(y_n),numel(z_n)],i,j,k),:) = [x_n(i),y_n(j),z_n(k)];
            end
        end
    end
    
    ind  = findnearest(meshStruct,searchCoords,'cart',1);
    newNodes = meshStruct.ID(ind);
    permuteIndices = zeros(numel(newNodes),1);
    
    for i=1:numel(newNodes)
        permuteIndices(i) = find(newNodes(i) == oldNodes);
    end
    
    newData = data(:,permuteIndices);
    meshStruct = meshStruct.n(permuteIndices);
    vec = [dataStruct.domain 'Vector'];
    % maybe some node has been mapped more than once
    if numel(unique(newNodes)) ~= numel(x_n)*numel(y_n)*numel(z_n)
        error([thisFuncStr 'problems while mapping data'],0);
    else
        dataStruct.(dataStruct.domain) = squeeze(reshape(newData,[numel(dataStruct.(vec)) numel(x_n) numel(y_n) numel(z_n)]));
        dataStruct.channelCoordinates = meshStruct;
        dataStruct.userData = {'nodeN',newNodes(:),'x',x_n,'y',y_n,'z',z_n};
    end
end
%% Add history line
dataStruct = ita_metainfo_add_historyline(dataStruct,mfilename,varargin);

%% Find output parameters
varargout(1) = {dataStruct};
%end function
end