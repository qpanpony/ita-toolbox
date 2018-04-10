classdef itaMeshGroup < itaMeta

    
    % Class for mesh groups
    %
    % This class groups a set of itaMeshNodes or itaMeshElements using
    % their IDs. The group itself has an ID, a name and a type. The latter
    % defines the data it contains (nodes, shell elements or volume elements)
    
    % <ITA-Toolbox>
    % This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
    % You can find the license for this m-file in the application folder. 
    % </ITA-Toolbox>
    
    %Author: mmt
    %Created: 04.1.10
    
    properties(Access = private)
        mID = [];
        mGroupID = 1;
        mGroupName = '';
        mType = 'nodes'; % what is stored in the group
    end
    
    properties(Constant)
        VALID_GROUP_TYPES = {'nodes', 'shell elements','volume elements'}; %Valid strings for the type property
    end
    
    properties(Dependent)
        ID          %IDs of the nodes belonging to this group
        groupID;    %ID of this group
        groupName   %name of this group
        type        %indicates what is stored in the group (nodes/shell elements/volume elements)
        nNodes      %number of nodes
        nElements   %number of elements
    end
    
    methods
        function this = itaMeshGroup(varargin)
            if nargin
                if nargin > 1
                    if ischar(varargin{2})
                        this.mGroupName = varargin{2};
                    end
                    if nargin > 2 && ischar(varargin{3})
                        if ismember(varargin{3},this.VALID_GROUP_TYPES)
                            this.mType = varargin{3};
                        else
                            error('itaMeshGroup:wrong group type');
                        end
                    end
                end
                if isa(varargin{1},'itaMeshGroup')
                    % this is the copy constructor
                    this = varargin{1};
                elseif isscalar(varargin{1}) && isnumeric(varargin{1})
                    % user gave number of nodes
                    this.mID = 1:varargin{1};
                elseif isstruct(varargin{1}) % Struct input/convert
                    fieldName = fieldnames(varargin{1});
                    for ind = 1:numel(fieldName)
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            disp(errmsg);
                        end
                    end
                end
            end
        end
        
        function display(this)
            %   DISPLAY(X) is called for the object X when the semicolon is not used
            %   to terminate a statement. [overloaded function]
            IDs = this.mID(:);
            idStr = cellstr(num2str(IDs));
            nIDs = numel(IDs);
            for idx = 1:nIDs
                disp(['' num2str(idx) ' [ID] = [' idStr{idx} ']']);
            end
            if nIDs == 1
                disp(['=========== in total ' num2str(nIDs) ' ' this.mType(1:end-1) ' in group: ' this.mGroupName ' (groupID: ' num2str(this.mGroupID) ')']);
            else
                disp(['=========== in total ' num2str(nIDs) ' ' this.mType ' in group: ' this.mGroupName ' (groupID: ' num2str(this.mGroupID) ')']);
            end
        end
        
        % replaces subsref
        function result = n(this, index)
            %Grants access to the node IDs of given index (internal indexing)
            %
            %Example:   obj.n([1 2 3]) returns an itaMeshGroup object
            %           containing the first three node IDs
            result = this;
            result.mID = this.mID(index);
        end
        
        function this = set.ID(this, value), this.mID = value; end
        function this = set.groupID(this,value), this.mGroupID = value; end
        function this = set.groupName(this, value)
            if ischar(value)
                this.mGroupName = value;
            else
                error('itaMeshGroup::groupName has to be a string!');
            end
        end
        
        function this = set.type(this,value)
            if ismember(value,this.VALID_GROUP_TYPES)
                this.mType = value;
            else
                error('itaMeshGroup:wrong group type!');
            end
        end
        
        function value = get.ID(this), value = this.mID(:); end
        function value = get.groupID(this), value = this.mGroupID; end
        function value = get.groupName(this), value = this.mGroupName; end
        function value = get.type(this), value = this.mType; end
        function value = get.nElements(this)
            if strcmpi(this.mType,'nodes')
                value = 0;
            else
                value = numel(this.mID);
            end
        end
        
        function value = get.nNodes(this)
            if ~strcmpi(this.mType,'nodes')
                value = 0;
            else
                value = numel(this.mID);
            end
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaMeta(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaMeshGroup.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMeshGroup(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2804 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'ID','groupID','groupName','type'};
        end
    end
end