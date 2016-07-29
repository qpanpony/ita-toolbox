classdef itaImageSourcesSourcePosition < itaImageSources
    properties (Access = private)
        mSourcePosition = [];
        mReceiverPosition = [];
        mDistance = [];
    end
    
    properties(Dependent)
        SourcePosition = [];
        ReceiverPosition = [];
    end
    
    properties(SetAccess = private)
        Distance = [];
    end
    
    methods % Special functions that implement operations that are usually performed only on instances of the class
        
        function this = itaImageSourcesSourcePosition(varargin)
            this = this@itaImageSources(varargin{:});
            if nargin >=2
                if sum(strcmp(varargin,'source position'))==1
                    this.mSourcePosition = varargin{find(strcmp(varargin,'source position')==1)+1}; % noch nicht richtig implementiert
                    if size(this.mSourcePosition,2) ~= 3
                        error('itaImageSourcesSourcePosition:Input', 'The source position must be in cartesian coordinates.');
                    end;
   
                else
                    error('itaImageSourcesSourcePosition:Def', ' Wrong type of input.')
                end

                if sum(strcmp(varargin,'receiver position'))==1
                    this.mReceiverPosition = varargin{find(strcmp(varargin,'receiver position')==1)+1};
                    if size(this.mReceiverPosition,2) ~= 3
                        error('itaImageSourcesSourcePosition:Input', 'The receiver position must be in cartesian coordinates.');
                    end
                    this.mDistance = distance(this);
                end
            elseif nargin ==1 && isa(varargin{1},'itaImageSourcesSourcePosition')
                this = varargin{1};
            elseif isempty(nargin)
                this.mID = 1;
                this.mSourcePosition = [];
                this.mReceiverPosition = [];
                this.mDistance = [];
            end
        end
        
        function SourcePosition = get.SourcePosition(this), SourcePosition = this.mSourcePosition; end
        function ReceiverPosition = get.ReceiverPosition(this), ReceiverPosition = this.mReceiverPosition; end
        function Distance = get.Distance(this), Distance = this.mDistance; end
        
        function this = set.SourcePosition(this,SourcePosition)
            this.mSourcePosition = SourcePosition;
            this.mDistance = distance(this);
        end

        function this = set.ReceiverPosition(this,ReceiverPosition), this.mReceiverPosition = ReceiverPosition; end
        
        function display(this)
            disp(['(ID: ' num2str(this.ID) ')  File: ' this.name]);
            disp( '==================================================')
            disp(['Position source x: ' sprintf('\t\t') sprintf('%3.2f',this.mSourcePosition(1)) 'm']);
            disp(['                y: ' sprintf('\t\t') sprintf('%3.2f',this.mSourcePosition(2)) 'm']);
            disp(['                z: ' sprintf('\t\t') sprintf('%3.2f',this.mSourcePosition(3)) 'm']);
            disp(' ');
            disp(['Position receiver x: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(1)) 'm']);
            disp(['                  y: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(2)) 'm']);
            disp(['                  z: ' sprintf('\t') sprintf('%3.2f',this.mReceiverPosition(3)) 'm']);
            disp(['Distance S-R: ' sprintf('\t\t\t') sprintf('%3.2f',this.mDistance) 'm']);
        end
    end
end
function dist = distance(this)
dist = norm(this.mSourcePosition-this.mReceiverPosition,2);
end
