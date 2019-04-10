classdef  itaMeshProperties < itaMeta

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Access = private)
        mID = 1;
        mName = [];
    end
    
    properties(Dependent)
        ID
        Name
    end
        
    methods
        function this = itaMeshProperties(varargin)
            if nargin == 1
                if isa(varargin{1},'itaMeshProperties')
                    this = varargin{1};
                elseif isstruct(varargin{1})
                    this = isPropStruct(this,varargin{1});
                elseif isa(varargin{1},'itaMeshGroupProperties')
                    this = varargin{1};
                elseif isa(varargin{1},'itaMeshGroup')
                    this = isGroup(varargin{1});
                elseif ischar(varargin{1}), this.mName = varargin{1};
                end
            elseif nargin >1
                disp('Blubb')
            end
                               
        end
        
        function display(this)
            disp([this.Name '  (ID: ' num2str(this.ID) ')']);           
        end

        % SET
        %------------------------------------------------------------------
        function this = set.ID(this, value), this.mID = value; end 
        function this = set.Name(this, value)
            if ischar(value), this.mName = value;
            else error('itaMeshProperties::Name has to be string'); end
        end
        
        % GET
        %------------------------------------------------------------------
        function value = get.ID(this), value = this.mID; end
        function value = get.Name(this), value = this.mName; end


        %% other functions
        function this = isGroup(mGroup)
            this.mgroupID = mGroup.groupID;
            this.mID = mGroup.groupID;
            this.mName = mGroup.groupName;
        end
        
        function this = isPropStruct(this,sObj)
            propFieldname = fieldnames(sObj);
            if length(propFieldname)==6
                if isnumeric(sObj.(propFieldname{1})) &&...
                        ischar(sObj.(propFieldname{2}))                  
                    this.mID = sObj.(propFieldname{1});
                    this.mName = sObj.(propFieldname{2});
                end
            elseif sum(strcmp(propFieldname,'Name')) == 1
                this.mName = sObj.(propFieldname{find(strcmp(propFieldname,'Name') ==1)});
            end
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % have to get save objects for both base classes
            sObj = saveobj@itaMeta(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaMeshProperties.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
           this = itaMeshProperties(sObj); % Just call constructor, he will take care
        end
        
        function result = propertiesSaved
            result = {'Name'};
        end
    end
end
