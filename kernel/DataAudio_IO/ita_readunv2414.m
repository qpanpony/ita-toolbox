function varargout = ita_readunv2414(varargin)
%ITA_READUNV2414 - reads unv2414 datasets that contain data per frequency
%  This function takes the filename of a unv-file as input argument and
%  returns the result as a cell array of itaAudio variables in the
%  following order:
%
%  result{1,1:3/6}  - velocity with 3/6 DOFs
%  result{2,1}      - pressure
%  result{3,1:3/6}  - intensity with 3/6 DOFs
%
%  Each variable has the number of nodes as the number of channels.
%
%  Call: result = ita_readunv2414(unvFilename)
%
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunv2414">doc ita_readunv2414</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  09-Feb-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_unvFilename','anything');
[unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Body
ita_verbose_info([thisFuncStr 'reading ...'],2);
[DataSet,Info,errmsg] = readuff(unvFilename,[],2414); %#ok<ASGLU>

result = cell(1,1);
if isempty(errmsg)
    i = 1;
    while DataSet{i}.dsType ~= 2414 % only 2414 datasets
        if i == numel(DataSet)
            error([thisFuncStr 'found no valid DataSet']);
        end
        i = i+1;
    end
    j = 0;
    while (i <= numel(DataSet))     % for each type of v,p or I
        j = j+1;                    % index of v,p or I
        c = i;
        resType             = DataSet{i}.resultType;
        nodeN               = DataSet{i}.nodeNum;
        nData               = size(DataSet{i}.data,2);  % DOF
        nNodes              = numel(nodeN);             % no of nodes
        data                = zeros(nNodes,nData);
        fcentre             = 0;
        tmpResult           = itaResult();         
        tmpResult.domain    = 'freq'; % clean result
        tmpResult.userData  = {'nodeN'; nodeN};      % store the nodeIDs in UserData
        tmpResult.resultType = 'simulation';
        tmpResult.comment   = 'unv2414 datafile (frequency response)';
        tmpResult.fileName  = unvFilename;
        
        % read in data per frequency
        while (i <= numel(DataSet)) && (DataSet{i}.dsType == 2414) && (DataSet{i}.resultType == resType)
            data(:,:,i-c+1)       = DataSet{i}.data;
            fcentre(i-c+1) = DataSet{i}.Freq; %#ok<AGROW>
            i = i+1;
        end
        % distinguish between result type and DOF
        switch resType
            case 11 % velocity 3/6 DOF
                channelUnits = {'m/s'};
                if DataSet{i-1}.dataCharacter == 2 % 3 DOF
                   prefix = {'velocity (x) at node ', 'velocity (y) at node ', 'velocity (z) at node '};
                elseif DataSet{i-1}.dataCharacter == 3 % 6 DOF
                    prefix = {'velocity (x) at node ', 'velocity (y) at node ', 'velocity (z) at node ', 'velocity (rx) at node ', 'velocity (ry) at node ', 'velocity (rz) at node '};
                end
            case 117 % pressure, 1 DOF
                channelUnits = {'Pa'};
                prefix = {'pressure at node '};
            case 303 % intensity, 3/6 DOF
                channelUnits = {'W/m^2'};
                if DataSet{i-1}.dataCharacter == 2 % 3 DOF
                    prefix = {'intensity (x) at node ', 'intensity (y) at node ', 'intensity (z) at node '};
                elseif DataSet{i-1}.dataCharacter == 3 % 6 DOF
                    prefix = {'intensity (x) at node ', 'intensity (y) at node ', 'intensity (z) at node ', 'intensity (rx) at node ', 'intensity (ry) at node ', 'intensity (rz) at node '};
                end
            otherwise     
                channelUnits = {'1'};
                prefix = cellstr(repmat('undefined',nData,1))';
        end
        % Add history line
        tmpResult = ita_metainfo_add_historyline(tmpResult,'ita_readunv2414','ARGUMENTS');
        % split the data into single audioObjs
        channelNames = cell(1,nNodes);
        for k = 1:nData
            for l = 1:nNodes
                channelNames{l} = [prefix{k} num2str(nodeN(l))];
            end
            result{j,k} = tmpResult;
            result{j,k}.freqVector = fcentre;
            result{j,k}.freq = squeeze(data(:,k,:)).';
            result{j,k}.channelUnits = repmat(channelUnits,1,nNodes);
            result{j,k}.channelNames = channelNames;
        end
        
        % do this for all result types
        if (i > numel(DataSet)) || (DataSet{i}.dsType ~= 2414)
            break;
        end
    end
else
    error([thisFuncStr 'error ' errmsg{:}]);
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end