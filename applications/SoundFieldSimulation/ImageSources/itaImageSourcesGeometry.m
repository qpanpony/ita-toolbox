classdef itaImageSourcesGeometry < itaImageSources
    properties (Access = private)
        mCoordinates =[];
        mElements = [];
        mNormals = [];
        mReducedNormal = [];
    end
    
    properties(Dependent)
        Coordinates =[];
        Elements = [];
        Normals = [];
    end
    
    properties(SetAccess = private)
        ReducedNormal = [];
    end
    
    methods % Special functions that implement operations that are usually performed only on instances of the class
        
        function this = itaImageSourcesGeometry(varargin)
            this = this@itaImageSources(varargin{:});
            if nargin >=2
                if sum(strcmp(varargin,'normals'))==1
                    if sum(strcmp(varargin,'coordinates'))==1
                        this.mCoordinates = varargin{find(strcmp(varargin,'coordinates')==1)+1}; % noch nicht richtig implementiert
                        this.mElements = varargin{find(strcmp(varargin,'elements')==1)+1};  % noch nicht richtig implementiert
                        this.mNormals= varargin{find(strcmp(varargin,'normals')==1)+1};  % noch nicht richtig implementiert
                        this.mReducedNormal = reducedNormalForm(this);
                    else
                        error('itaImageSources:Def', ' Wrong type of input.')
                    end
                end
            elseif nargin ==1 && isa(varargin{1},'itaImageSourcesGeometry')
                                this = varargin{1};
            elseif isempty(nargin)
                this.mCoordinates = [];
                this.mElements = [];
                this.mNormals = [];
            end
        end
        
        function Normals = get.Normals(this), Normals = this.mNormals; end
        function Coordinates = get.Coordinates(this), Coordinates = this.mCoordinates; end
        function Elements = get.Elements(this),Elements = this.mElements; end
        function ReducedNormal = get.ReducedNormal(this), ReducedNormal = this.mReducedNormal; end
        
        function this = set.Normals(this,Normals), this.mNormals = Normals;end
        function this = set.Coordinates(this,Coordinates),this.mCoordinates = Coordinates;end
        function this = set.Elements(this,Elements)
            this.mElements = Elements;
            this.mReducedNormal = reducedNormalForm(this);
        end
        
        function display(this)
            disp(['(ID: ' num2str(this.ID) ')  ' this.name]);
            disp( '==================================================')
            if ~isempty(this.mCoordinates)
                disp(['# Coordinates : ' sprintf('%3.0f',length(this.mCoordinates(:,1)))]);
                disp(['# Elements    : ' sprintf('%3.0f',length(this.mElements(:,1)))]);
                disp(['Type Elements : ' sprintf('%3.0f',length(this.mElements(1,:)))]);
                disp(['# Normals     : ' sprintf('%3.0f', length(this.mNormals(:,1)))]);
            else
                disp('Coordinates   : ' );
            end
        end
    end
    
    %
    %         function this = set.Value(this,value)
    %             if isnumeric(value)
    %                 this.mValue = value;
    %             else
    %                 error('itaMeshGroupProperties::Value has to be numeric');
    %             end
    %         end
    %         function value = get.FreqInputFilename(this), value = this.mFreqInputFilename; end
    %
    % function sObj = saveobj(this)
    %             % Called whenever an object is saved
    %             % have to get save objects for both base classes
    %             sObj = saveobj@itaMeshProperties(this);
    %
    %
    %             % Copy all properties that were defined to be saved
    %             propertylist = itaMeshBoundaryC.propertiesSaved;
    %
    %             for idx = 1:numel(propertylist)
    %                 sObj.(propertylist{idx}) = this.(propertylist{idx});
    %             end
    %         end
    %     end
    %     methods(Static)
    %         function this = loadobj(sObj)
    %             % Called when an object is loaded
    %             this = itaMeshBoundaryC(sObj); % Just call constructor, he will take care
    %         end
    %
    %         function result = propertiesSaved
    %             result = {'Type','Value', 'Freq','FreqInputFilename','groupID','Unit'};
    %         end
    %     end
    
    %   end
    %    events % Messages that are defined by classes and broadcast by class instances when some specific action occurs
    %       EventName
    %    end
    %    enumeration
    %       EnumName (arg)
    %    end
    
end

function redNorm = reducedNormalForm(this)
for i1 = 1:size(this.Elements,1)
    coord =  this.Coordinates(this.Elements(i1,:),:);
    
    p1 = coord(1,:); p2 = coord(2,:); p3 = coord(3,:);
    A =  p1(2)*(p2(3)-p3(3)) + p2(2)*(p3(3)-p1(3)) + p3(2)*(p1(3)-p2(3));
    B = -p1(1)*(p2(3)-p3(3)) - p2(1)*(p3(3)-p1(3)) - p3(1)*(p1(3)-p2(3));
    C =  p1(1)*(p2(2)-p3(2)) + p2(1)*(p3(2)-p1(2)) + p3(1)*(p1(2)-p2(2));
    D =  p1(1)*(p3(2)*p2(3)-p2(2)*p3(3))+ p1(2)*(p2(1)*p3(3)-p3(1)*p2(3)) + p1(3)*(p3(1)*p2(2)-p2(1)*p3(2));
    nABC = sqrt(A^2 + B^2+C^2);
    redNorm(i1,1) = A/nABC; redNorm(i1,2) = B/nABC; redNorm(i1,3) = C/nABC; redNorm(i1,4)= D/nABC;
end
end
