classdef itaMicArray < itaMeshNodes

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    
    % Class for mic arrays for e.g. beamforming
    % represented by a unique ID, coordinates and a weight factor
    % inherited from itaMeshNodes
    % mmt, 15.8.09
    %
    % This class allows to store the ID, coordinates and weights of a microphone array.
    
    properties(Access = private)
        mWeight;
    end
    
    properties(Dependent)
        w;
    end
    
    methods
        function this = itaMicArray(varargin)
            % call superclass constructor
            this = this@itaMeshNodes(varargin{:});
            % default
            this.mWeight = ones(numel(this.x),1)./max(1,numel(this.x));
            if nargin
                if isa(varargin{1},'itaMicArray')
                    % copy fields (copy constructor)
                    this = varargin{1};
                elseif isa(varargin{1},'itaMeshNodes')
                    this = varargin{1};
                    this.mWeight = ones(numel(varargin{1}.x),1)./max(1,numel(varargin{1}.x));
                elseif isa(varargin{1},'itaCoordinates')
                    this = varargin{1};
                    this.ID = (1:numel(varargin{1}.x)).';
                    this.mWeight = ones(numel(varargin{1}.x),1)./max(1,numel(varargin{1}.x));
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
        
        function display(this)
            % additional input as cell array of strings
            nPoints = this.nPoints;
            additionalInput = cell(nPoints,1);
            weights = this.w;
            for ind = 1:nPoints
                additionalInput{ind} = ['  [weight = ' num2str(weights(ind),3) ']'];
            end
            % call motherf....  unction
            display@itaMeshNodes(this,additionalInput);
        end
        
        % replaces subsref
        function result = n(this, index)
            tmpWeight = this.w(index);
            result = n@itaMeshNodes(this, index);
            result.mWeight = tmpWeight;
        end
        
        function this = set.w(this, value)
            if numel(value) == this.nPoints
                this.mWeight = value;
            else
                error('itaMicArray:numer of weights must match the number of microphones!');
            end
        end
        
        function value = get.w(this)
            % consitency check
            if this.nPoints ~= numel(this.mWeight)
                ita_verbose_info([upper(mfilename) '.w: data sizes are inconsistent, recalculating weights!'],0);
                this.mWeight = ones(this.nPoints,1)./this.nPoints;
            end
            value = this.mWeight(:);
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
                    tmpWeight = this.w(:);
                    this = merge@itaMeshNodes(this,input);
                    this.w = [tmpWeight(:); input.w(:)];
                end
            end
        end
        
         %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaMeshNodes(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaMicArray.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded            
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMicArray(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2804 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
            
        function result = propertiesSaved
            result = {'w'};
        end
    end
end