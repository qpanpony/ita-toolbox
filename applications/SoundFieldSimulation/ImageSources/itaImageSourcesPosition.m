classdef itaImageSourcesPosition < itaImageSources
   properties (Access = private)
      mOrder =[];
      mPosition = [];
      mWalls = [];
      mAngles = [];
      mSourceID = []
      mReceiverPosition = [];
      mDistance = [];
   end
   
   properties(Dependent)
      Order =[];
      Position = [];
      Walls = [];
      Angles = [];
      SourceID = []
      ReceiverPosition = [];
   end
   
   properties(SetAccess = private)
       Distance = [];
   end
      
   methods % Special functions that implement operations that are usually performed only on instances of the class
      
        function this = itaImageSourcesPosition(varargin)
            this = this@itaImageSources(varargin{:});
            if nargin >=2
                if sum(strcmp(varargin,'position'))==1
                    if sum(strcmp(varargin,'walls'))==1
                        if sum(strcmp(varargin,'angles'))==1
                            this.mPosition = varargin{find(strcmp(varargin,'position')==1)+1}; % noch nicht richtig implementiert
                            if size(this.mPosition,2) ~= 3, error('itaImageSources:Input', 'The Position of the IS must have a xyz coordinate.'); end;
                            this.mWalls = varargin{find(strcmp(varargin,'walls')==1)+1};  % noch nicht richtig implementiert
                            this.mAngles = varargin{find(strcmp(varargin,'angles')==1)+1};  % noch nicht richtig implementiert
                            if abs(this.mAngles)>1, error('itaImageSources:Input', ' Angles must be between -1...1'); end
                            
                            orderTmp = length(this.mWalls);
                            if orderTmp == length(this.mAngles)
                                this.mOrder = orderTmp;
                            else
                                error('itaImageSources:Input', ' Wrong number of input. Image source order, number of angles and walls must be equal.')
                            end
                        else
                            error('itaImageSources:Def', ' Wrong type of input.')
                        end
                    end
                end
                
                if sum(strcmp(varargin,'receiver position'))==1
                    if size(this.mPosition,2) ~= 3, error('itaImageSources:Input', 'The Position of the receiver must have a xyz coordinate.'); end;
                    this.mReceiverPosition = varargin{find(strcmp(varargin,'receiver position')==1)+1};
                    this.mDistance = distance(this);
                    if sum(strcmp(varargin,'source ID'))==1
                        this.mSourceID = varargin{find(strcmp(varargin,'source ID')==1)+1};
                    else
                        this.mSourceID = 1;
                    end
                end
            elseif nargin ==1 && isa(varargin{1},'itaImageSources')
                this = varargin{1};                    
            elseif isempty(nargin)
                this.mID = 1;
                this.mOrder =[];
                this.mPosition = [];
                this.mWalls = [];
                this.mAngles = [];
                this.mReceiverID = [];
                this.mReceiverPosition = [];
                this.mDistance = [];
            end
        end
         
        function Order = get.Order(this), Order = this.mOrder; end
        function Position = get.Position(this), Position = this.mPosition; end
        function Walls = get.Walls(this), Walls = this.mWalls; end
        function Angles = get.Angles(this), Angles = this.mAngles; end
        function SourceID = get.SourceID(this),SourceID = this.mSourceID; end
        function ReceiverPosition = get.ReceiverPosition(this), ReceiverPosition = this.mReceiverPosition; end
        function Distance = get.Distance(this), Distance = this.mDistance; end
        
        function this = set.Order(this,Order),this.mOrder = Order;end
        function this = set.Position(this,Position)
            this.mPosition = Position; 
            this.mDistance = distance(this);
        end
        function this = set.Walls(this,Walls),this.mWalls = Walls;end
        function this = set.Angles(this,Angles), this.mAngles = Angles; end
        function this = set.SourceID(this,SourceID)
            this.mSourceID = SourceID;
            this.mDistance = distance(this);
        end
        function this = set.ReceiverPosition(this,ReceiverPosition), this.mReceiverPosition = ReceiverPosition; end
        
        function display(this)
            disp(['(ID: ' num2str(this.ID) ')  File: ' this.name]);
            disp( '==================================================')
            if ~isempty(this.mOrder)
                disp(['Order IS: ' sprintf('\t\t\t') '    ' num2str(this.mOrder)]);
                disp(['Walls:    ' sprintf('\t\t\t') '    ' num2str(this.mWalls)]);
                disp(['Position IS x: ' sprintf('\t\t\t') sprintf('%3.2f',this.mPosition(1)) 'm']);
                disp(['            y: ' sprintf('\t\t\t') sprintf('%3.2f',this.mPosition(2)) 'm']);
                disp(['            z: ' sprintf('\t\t\t') sprintf('%3.2f',this.mPosition(3)) 'm']);
                disp(['Source ID: ' sprintf('\t\t\t') '    ' num2str(this.mSourceID)]);
                disp(['Position receiver x: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(1)) 'm']);
                disp(['                  y: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(2)) 'm']);
                disp(['                  z: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(3)) 'm']);
                disp(['Distance S-R: ' sprintf('\t\t\t') sprintf('%3.2f',this.mDistance) 'm']);
                disp(['cos(a) for Wall ' num2str(this.mWalls(1)) ': ' sprintf('\t\t') sprintf('%3.2f',this.mAngles(1))]);
                for i1 = 2:this.mOrder
                disp(['cos(a) for Wall ' num2str(this.mWalls(i1)) ': ' sprintf('\t\t') sprintf('%3.2f',this.mAngles(i1))]);   
                end
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

function dist = distance(this)
    dist = norm(this.mPosition-this.mReceiverPosition,2);
end
