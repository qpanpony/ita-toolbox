classdef itaMeshNodes < itaMeta & itaCoordinates

    
    % Class for mesh nodes, represented by a unique ID and coordinates
    % inherited from itaCoordinates
    %
    % This class allows to store the ID and coordinates of a mesh node.
    
    % <ITA-Toolbox>
    % This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
    % You can find the license for this m-file in the application folder. 
    % </ITA-Toolbox>
    
    %Author: mmt
    %Created: 15.8.09
    
    properties(Access = private)
        mID;
    end
    
    properties(Dependent)
        ID; %Unique IDs of the stored nodes
    end
    
    methods
        function this = itaMeshNodes(varargin)
            this = this@itaMeta();
            this = this@itaCoordinates(varargin{:});
            % default
            this.mID = 1:numel(this.x);
            if nargin
                if isa(varargin{1},'itaMeshNodes')
                    % copy fields (copy constructor)
                    this = varargin{1};
                elseif isa(varargin{1},'itaCoordinates')
                    this = varargin{1};
                    this.mID = 1:numel(varargin{1}.x);
                elseif isstruct(varargin{1}) % Struct input/convert
                    fieldName = fieldnames(varargin{1});
                    for ind = 1:numel(fieldName);
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            disp(errmsg);
                        end
                    end
                end
            end
        end
        
        function display(this,varargin)
            % additional input as cell array of strings
            % varargin is the additional input from child classes
            if nargin > 1
                childInput = varargin{:};
                useAdditionalInput = true;
            else
                useAdditionalInput = false;
            end
            nPoints = this.nPoints;
            additionalInput = cell(nPoints,1);
            IDs = this.ID;
            for ind = 1:nPoints
                if useAdditionalInput
                    additionalInput{ind} = ['  (ID: ' num2str(IDs(ind)) ')' childInput{ind}(:).'];
                else
                    additionalInput{ind} = ['  (ID: ' num2str(IDs(ind)) ')'];
                end
            end
            % call motherf....  unction
            display@itaCoordinates(this,additionalInput);
        end
        
        % replaces subsref
        function result = n(this, index)
            tmpID = this.ID(index);
            result = n@itaCoordinates(this, index);
            result.mID = tmpID;
        end
        
        function this = set.ID(this, value)
            if numel(unique(value)) == this.nPoints
                this.mID = value;
            else
                error('itaMeshNodes:numer of (unique) IDs must match the number of nodes!');
            end
        end
        
        function value = get.ID(this)
            % consitency check
            if this.nPoints ~= numel(this.mID)
                ita_verbose_info([upper(mfilename) '.ID: data sizes are inconsistent, renumbering!'],0);
                this.mID = 1:this.nPoints;
            end
            value = this.mID(:);
        end
                
        function result = split(this,index)
            result = this.n(index);
        end
        
        function this = merge(varargin)
            if numel(varargin) == 1 && numel(varargin{1}) == 1 %Only one element
                this = varargin{1};
            else
                this = merge(varargin{1});
                varargin(1) = [];
                for idx = 1:numel(varargin)
                    input = merge(varargin{idx});
                    tmpID = this.ID(:);
                    this = merge@itaCoordinates(this,input);
                    if strcmpi(class(input),'itaCoordinates')
                        this.ID = [tmpID(:); max(tmpID(:)) + (1:input.nPoints).'];
                    else
                        if numel(unique([tmpID(:); input.ID(:)])) < numel(tmpID(:))+numel(input.ID(:))
                            ita_verbose_info('itaMeshNodes.merge:elements have been renumbered due to ID conflicts',0);
                            this.ID = [tmpID(:); input.ID(:)+max(tmpID)];
                        else
                            this.ID = [tmpID(:); input.ID(:)];
                        end
                    end
                end
            end
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % have to get save objects for both base classes
            sObj = saveobj@itaCoordinates(this);
            sObj2 = saveobj@itaMeta(this);
            metaFieldnames = fieldnames(sObj2);
            % copy fields
            for i = 1:numel(metaFieldnames)
                sObj.(metaFieldnames{i}) = sObj2.(metaFieldnames{i});
            end
            
            
            % Copy all properties that were defined to be saved
            propertylist = itaMeshNodes.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded            
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMeshNodes(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2804 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
            
        function result = propertiesSaved
            result = {'ID'};
        end
    end
end