function varargout = ita_readunv2412(varargin)
%ITA_READUNV2412 - reads unv2412 datasets that contain mesh element information 
%  This function takes the filename of a unv-file as an input argument and
%  returns a structure with element IDs and corresponding node numbers
%
%  Call: result = ita_readunv2412(unvFilename)
%
%   See also ITA Wiki and search for unv for detail or the pdf in the zip
%   file downloaded from FileExchange of Mathworks
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunv2414">doc ita_readunv2414</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  10-Jun-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_unvFilename','anything');
[unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>


%%  'result' is an itaAudio object and is given back 
ita_verbose_info([thisFuncStr 'reading ...'],2);
[DataSet,Info,errmsg] = readuff(unvFilename,[],2412); % use readuff to get the datasets
err2412 = 0;
if ~isempty(find(Info.dsTypes==2412, 1))
   err2412 = Info.errcode(Info.dsTypes==2412); 
end

if err2412 < 1
    i = 1;
    while (DataSet{i}.dsType ~= 2412) % only process 2412 datasets
        if i == numel(DataSet)
            error([thisFuncStr 'found no valid DataSet']);
        end
        i = i+1;
    end
    % element nodes and ID
    feDescriptor = DataSet{i}.FEDescriptor;
    elemLabel = DataSet{i}.ElementLabel;
    elemNodes = DataSet{i}.Element;
else
    error([thisFuncStr 'error ' errmsg{:}]);
end

linTetraShellElements = zeros(numel(find(feDescriptor==91)),4);
parTetraShellElements = zeros(numel(find(feDescriptor==92)),7);
linQuadShellElements = zeros(numel(find(feDescriptor==94)),5);
parQuadShellElements = zeros(numel(find(feDescriptor==95)),9);
linTetraVolumeElements = zeros(numel(find(feDescriptor==111)),5);
parTetraVolumeElements = zeros(numel(find(feDescriptor==118)),11);
linQuadVolumeElements = zeros(numel(find(feDescriptor==115)),9);
parQuadVolumeElements = zeros(numel(find(feDescriptor==116)),21);
n91 = 0; n92 = 0; n94 = 0; n95 = 0;
n111 = 0; n118 = 0; n115 = 0; n116 = 0;
% store the data
for i=1:numel(elemLabel)
    tmp = elemNodes(i,:);
    switch feDescriptor(i)
        case 91 % linear tetra shell elements
            n91 = n91 + 1;
            linTetraShellElements(n91,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 92 % parabolic tetra shell elements
            n92 = n92 + 1;
            parTetraShellElements(n92,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 94 % linear quad shell elements
            n94 = n94 + 1;
            linQuadShellElements(n94,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 95 % parabolic quad shell elements
            n95 = n95 + 1;
            parQuadShellElements(n95,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 111 % linear tetra volume elements
            n111 = n111 + 1;
            linTetraVolumeElements(n111,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 118 % parabolic tetra volume elements
            n118 = n118 + 1;
            parTetraVolumeElements(n118,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 115 % linear quad volume elements
            n115 = n115 + 1;
            linQuadVolumeElements(n115,:) = [elemLabel(i),tmp(~isnan(tmp))];
        case 116 % parabolic quad volume elements
            n116 = n116 + 1;
            parQuadVolumeElements(n116,:) = [elemLabel(i),tmp(~isnan(tmp))];
        otherwise
            error([thisFuncStr 'unknown element type']);
    end
end

idx = 1;
if n91 > 0 % linear tetra shell
    result{idx}       = itaMeshElements(n91);
    result{idx}.ID    = linTetraShellElements(:,1);
    result{idx}.nodes = linTetraShellElements(:,2:end);
    result{idx}.shape = 'tetra';
    result{idx}.type  = 'shell';
    result{idx}.order = 'linear';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing shell elements (linear tetra)';
    idx = idx + 1;
end

if n92 > 0 % parabolic tetra shell
    result{idx}       = itaMeshElements(n92);
    result{idx}.ID    = parTetraShellElements(:,1);
    result{idx}.nodes = parTetraShellElements(:,2:end);
    result{idx}.shape = 'tetra';
    result{idx}.type  = 'shell';
    result{idx}.order = 'parabolic';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing shell elements (parabolic tetra)';
    idx = idx + 1;
end

if n94 > 0 % linear quad shell
    result{idx}       = itaMeshElements(n94);
    result{idx}.ID    = linQuadShellElements(:,1);
    result{idx}.nodes = linQuadShellElements(:,2:end);
    result{idx}.shape = 'quad';
    result{idx}.type  = 'shell';
    result{idx}.order = 'linear';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing shell elements (linear quad)';
    idx = idx + 1;
end

if n95 > 0 % parabolic quad shell
    result{idx}       = itaMeshElements(n95);
    result{idx}.ID    = parQuadShellElements(:,1);
    result{idx}.nodes = parQuadShellElements(:,2:end);
    result{idx}.shape = 'quad';
    result{idx}.type  = 'shell';
    result{idx}.order = 'parabolic';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing shell elements (parabolic quad)';
    idx = idx + 1;
end

if n111 > 0 % linear tetra volume
    result{idx}       = itaMeshElements(n111);
    result{idx}.ID    = linTetraVolumeElements(:,1);
    result{idx}.nodes = linTetraVolumeElements(:,2:end);
    result{idx}.shape = 'tetra';
    result{idx}.type  = 'volume';
    result{idx}.order = 'linear';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing volume elements (linear tetra)';
    idx = idx + 1;
end

if n118 > 0 % parabolic tetra volume
    result{idx}       = itaMeshElements(n118);
    result{idx}.ID    = parTetraVolumeElements(:,1);
    result{idx}.nodes = parTetraVolumeElements(:,2:end);
    result{idx}.shape = 'tetra';
    result{idx}.type  = 'volume';
    result{idx}.order = 'parabolic';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing volume elements (parabolic tetra)';
    idx = idx + 1;
end

if n115 > 0 % linear quad volume
    result{idx}       = itaMeshElements(n115);
    result{idx}.ID    = linQuadVolumeElements(:,1);
    result{idx}.nodes = linQuadVolumeElements(:,2:end);
    result{idx}.shape = 'quad';
    result{idx}.type  = 'volume';
    result{idx}.order = 'linear';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing volume elements (linear quad)';
    idx = idx + 1;
end

if n116 > 0 % parabolic quad volume
    result{idx}       = itaMeshElements(n116);
    result{idx}.ID    = parQuadVolumeElements(:,1);
    result{idx}.nodes = parQuadVolumeElements(:,2:end);
    result{idx}.shape = 'tetra';
    result{idx}.type  = 'volume';
    result{idx}.order = 'parabolic';
    result{idx}.fileName = unvFilename;
    result{idx}.comment = 'unv2412 data file containing volume elements (parabolic tetra)';
end

if numel(result) == 1
    result = result{1};
end

%% Find output parameters
varargout(1) = {result}; 

%end function
end