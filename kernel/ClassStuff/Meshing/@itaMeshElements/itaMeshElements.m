classdef itaMeshElements < itaMeta
    
    
    
    % Class for mesh elements
    %
    % This class allows to store the ID and referred nodes of mesh elements
    %
    % the shell element types are:
    %
    %   tetra: 3 nodes (linear), 6 nodes (parabolic)
    %   quad : 4 nodes (linear), 8 nodes (parabolic)
    %
    % the volume element types are:
    %
    %   tetra: 4 nodes (linear), 10 nodes (parabolic)
    %   quad : 8 nodes (linear), 20 nodes (parabolic)
    
    % <ITA-Toolbox>
    % This file is part of the application Meshing for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    %Author: mmt
    %Created: 15.8.09
    
    properties(Access = private)
        mID = [];
        mNodes = nan(0,3);
        mType  = 'shell'; % shell/volume
        mShape = 'tetra'; % tetra/quad
        mOrder = 'linear'; % linear/parabolic
    end
    
    properties(Dependent)
        ID          %Unique IDs of the stored mesh elements
        nodes       %Respective IDs of the nodes for each element
        shape       %Shape of the stored elements (tetra/quad)
        type        %Elementtype (shell/volume)
        nElements   %Total number of elements
        order       %Order of the shape function(linear/parabolic)
    end
    
    methods
        function this = itaMeshElements(varargin)
            if nargin == 1
                % use linear triangles as standard element
                if isa(varargin{1},'itaMeshElements')
                    % this is the copy constructor
                    this = varargin{1};
                elseif isnumeric(varargin{1})
                    if isscalar(varargin{1})
                        % user gave number of elements
                        nElements   = varargin{1};
                        this.mID    = 1:nElements;
                        this.mNodes = nan(nElements,3);
                    elseif ismember(size(varargin{1},2),[3 4 6 8 10 20])
                        % user gave node matrix
                        this.mNodes = varargin{1};
                        this.mID    = 1:size(this.mNodes,1);
                        switch size(varargin{1},2)
                            case 3
                                this.mOrder = 'linear';
                                this.mType = 'shell';
                                this.mShape = 'tetra';
                            case 4
                                this.mOrder = 'linear';
                                ita_verbose_info('Cannot automatically determine type and shape of elements!',1);
                            case 6
                                this.mOrder = 'parabolic';
                                this.mType = 'shell';
                                this.mShape = 'tetra';
                            case 8
                                ita_verbose_info('Cannot automatically determine order, type and shape of elements!',1)
                            case 10
                                this.mOrder = 'parabolic';
                                this.mType = 'volume';
                                this.mShape = 'tetra';
                            case 20
                                this.mOrder = 'parabolic';
                                this.mType = 'volume';
                                this.mShape = 'quad';
                        end
                    end
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
            elseif nargin > 1
                if nargin == 4
                    % user gave order of elements
                    if ismember(varargin{4},{'linear','parabolic'})
                        this.mOrder = varargin{4};
                    else
                        error('itaMeshElements::wrong element order');
                    end
                else
                    this.mOrder = 'linear';
                end
                
                if nargin > 2
                    % user gave shape of elements
                    if ismember(varargin{3},{'tetra','quad'})
                        this.mShape  = varargin{3};
                    else
                        error('itaMeshElements::wrong element shape');
                    end
                else
                    this.mShape  = 'tetra';
                end
                
                if ismember(varargin{2},{'shell','volume'})
                    % user gave type of elements
                    this.mType = varargin{2};
                else
                    error('itaMeshElements::wrong element type');
                end
                
                if strcmpi(this.mOrder,'linear')
                    typeFact = 1;
                else
                    if strcmpi(this.mType,'shell')
                        typeFact = 2;
                    else
                        typeFact = 2.5;
                    end
                end
                
                if strcmpi(this.mType,'shell')
                    if strcmpi(this.mShape,'tetra')
                        connectionSize = 3*typeFact;
                    else
                        connectionSize = 4*typeFact;
                    end
                else
                    if strcmpi(this.mShape,'tetra')
                        connectionSize = 4*typeFact;
                    else
                        connectionSize = 8*typeFact;
                    end
                end
                
                if isscalar(varargin{1})
                    % user gave number of elements
                    nElements   = varargin{1};
                    this.mID    = 1:nElements;
                    this.mNodes = nan(nElements,connectionSize);
                    
                elseif ismember(size(varargin{1},2),[3 4 6 8 10 20])
                    % user gave node matrix
                   
                    if size(varargin{1},2) ~= connectionSize
                        error('itaMeshElements::dimensions of connectivity list do not match element type');
                    else
                        this.mNodes = varargin{1};
                    end
                    this.mID    = 1:size(this.mNodes,1);
                else
                    error('itaMeshElements::first input must be either number of elements or connectivity list!');
                end
                
            end
        end
        
        function display(this) %#ok<DISPLAY>
            %   DISPLAY(X) is called for the object X when the semicolon is not used
            %   to terminate a statement. [overloaded function]
            prefix = '(ID=';
            middlefix = ['[nodes (n=' num2str(size(this.mNodes,2)) ')] = ['];
            elements = this.mNodes;
            for iElem = 1:this.nElements
                disp([num2str(iElem) ' ' prefix num2str(this.mID(iElem)) ') ' middlefix num2str(elements(iElem,:)) ']']);
            end
            disp(['=========== in total ' num2str(this.nElements) ' elements of type: ' this.mType ' (' this.mOrder ' ' this.mShape ')']);
        end
        
        % replaces subsref
        function result = n(this, index)
            %Grants access to elements with given index (internal indexing)
            %
            %Example:   obj.n([1 2 3]) returns an itaMeshElements object
            %           containing the first three mesh elements
            result = this;
            result.mID = this.mID(index);
            result.mNodes = this.mNodes(index,:);
        end

        %% Set / Get functions
        function this = set.ID(this, value)
            if numel(unique(value)) == numel(this.mNodes(:,1))
                this.mID = value;
            else
                error('itaMeshElements:number of (unique) IDs must macht the number of elements!');
            end
        end
        
        function this = set.nodes(this,value)
            if ~ismember(size(value,2),[3,4,6,8,10,20])
                error(['itaMeshElements::wrong element count: ' num2str(size(value,2))]);
            else
                this.mNodes = value;
                this.mID    = 1:size(value,1);
            end
        end
        
        function this = set.type(this,value)
            if ismember(value,{'shell','volume'})
                this.mType = value;
            else
                error('itaMeshElements:wrong element type');
            end
        end
        
        function this = set.shape(this,value)
            if ismember(value,{'tetra','quad'})
                this.mShape = value;
            else
                error('itaMeshElements:wrong element shape');
            end
        end
        
        function this = set.order(this,value)
            if ismember(value,{'linear','parabolic'})
                this.mOrder = value;
            else
                error('itaMeshElements:wrong element order');
            end
        end
        
        function value = get.ID(this), value = this.mID(:); end
        function value = get.nodes(this), value = this.mNodes; end
        function value = get.shape(this), value = this.mShape; end
        function value = get.type(this), value = this.mType; end
        function value = get.order(this), value = this.mOrder; end
        function value = get.nElements(this), value = numel(this.mID); end
        
        
        %% Boolean functions
        function value = isShell(this)
            %Returns true if the stored elements belong to a shell
            value = strcmpi(this.mType,'shell'); end 
        function value = isVolume(this)
            %Returns true if the stored elements belong to a volume
            value = strcmpi(this.mType,'volume'); end
        
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaMeta(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaMeshElements.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMeshElements(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2804 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            % save ID last
            result = {'nodes','shape','type','order','ID'};
        end
    end
end
