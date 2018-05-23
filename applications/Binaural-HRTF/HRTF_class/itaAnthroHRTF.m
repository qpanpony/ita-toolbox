classdef itaAnthroHRTF  < itaHRTF

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    properties (Access = private)
        mHeadRadius = 0.1;
        mHeadHeight = 0.1;
        mHeadWidth = 0.1;
        mHeadDepth = 0.1;
    end
    
    properties(Dependent = true, Hidden = false)
        headHeight = 0.1;
        headWidth = 0.1;
        headDepth = 0.1;
        calcEllipsoid = false;
    end
    
    properties (Dependent = true, Hidden = true)
        
    end
    
    properties (Dependent = true, SetAccess = private)
        headRadius = 0.1;
        initAn;
    end
    
    methods % Special functions that implement operations that are usually performed only on instances of the class
        %% Input
        function this = itaAnthroHRTF(varargin)
            if nargin >1              
                    this.initAn = varargin;
               
            elseif nargin == 1
                if isa(varargin{1},'itaAnthroHRTF')
                    this = varargin{1};
                    this.domain = 'time';
                elseif isa(varargin{1},'itaHRTF')
                    prop = properties(varargin{1});
                    for iProp = 1:numel(prop)
                        try
                            this.(prop{iProp}) = varargin{1}.(prop{iProp});
                        end
                    end
                    this.data = varargin{1}.data;
                elseif nargin ==1 && isstruct(varargin{1}) % only for loading
                    obj = varargin{1};
                    this.data = obj.data;
                    
                    this.signalType = 'energy';
                    % additional itaHRTF data
                    objFNload = this.propertiesLoad;
                    objFNsaved = this.propertiesSaved;
                    for i1 = 1:numel(objFNload)
                        this.(objFNload{i1}) = obj.(objFNsaved{i1});
                    end
                    % saving itaCoordinates in itaHRTF does not work at the
                    % moment
                    this.dirCoord.sph = this.mCoordSave;
                    % saving channelNames in itaHRTF does not work at the
                    % moment
                    for iCh = 1:this.dimensions
                       this.channelNames{iCh} = this.mChNames(iCh,:);
                    end
                end
            end
        end
        
        %% .................GET............................................
        % GET
        %..................................................................
        function headHeight = get.headHeight(this)
            headHeight = this.mHeadHeight; end
        
        function headWidth = get.headWidth(this)
            headWidth  = this.mHeadWidth ; end
        
        function headDepth = get.headDepth(this)
            headDepth   = this.mHeadDepth ; end
        
        function hr = get.headRadius(this)
            hr = this.mHeadRadius; end
        
        %% ..................SET PRIVAT....................................
        % SET PRIVATE
        %..................................................................       
        function this = set.initAn(this,var)
            % signal data
            for iIn = 1:nargin
                if isa(var{iIn},'itaHRTF')
                    fn = properties(var{iIn});
                    this.domain = 'time';
                    %this.data = var{iIn}.timeData;
                    this.signalType = 'energy';
                    for iFn = 1:numel(fn)
                        try %#ok<TRYNC>
                            this.(fn{iFn}) = var{iIn}.(fn{iFn});
                        end
                    end
                    
                    if var{iIn}.domain == 'time'                        
                        this.data = var{iIn}.timeData; 
%                        -> error when input is freq domain
                    end
                    break
                 end
            end
            
            if this.dimensions == 0
                phi = deg2rad(0:5:355);
                r = ones(size(phi));
                theta = r*pi/2;
                coord = itaCoordinates([r' theta' phi'],'sph');

                this.domain = 'time';
                this.data = zeros(256,numel(phi)*2);
                this.signalType = 'energy';

                this.dirCoord = coord;
            end
            
            % head dimensions
            if ~isempty(find(strcmpi(var,'h')==1, 1))
                h = var{find(strcmpi(var,'h')==1)+1};
                w = var{find(strcmpi(var,'w')==1)+1};
                d = var{find(strcmpi(var,'d')==1)+1};
            elseif ~isempty(find(strcmpi(var,'head')==1, 1))
                head = var{find(strcmpi(var,'head')==1)+1};
                h = head(1);
                w = head(2);
                d = head(3);
            end
                        
            this.mHeadHeight = h;
            this.mHeadWidth = w;
            this.mHeadDepth = d;
            this.mHeadRadius = test_rbo_Ellipse2mSphere(this); %changed 7.5.14
        end
        
        %% ....................SET.........................................
        % SET
        %..................................................................
        function this = set.headDepth(this,HeadDepth)
            this.mHeadDepth = HeadDepth;
            this.mHeadRadius = test_rbo_Ellipse2Sphere(this);
        end
        
        function this = set.headWidth(this,HeadWidth)
            this.mHeadWidth = HeadWidth;
            this.mHeadRadius = test_rbo_Ellipse2Sphere(this);
        end
        
        function this = set.headHeight(this,HeadHeight)
            this.mHeadHeight = HeadHeight;
            this.mHeadRadius = test_rbo_Ellipse2mSphere(this);
        end
        
        function this = set.headRadius(this,r)
            this.headRadius= r;
        end
        
        function this = set.calcEllipsoid(this,calc)
           if calc == true
                this = test_rbo_pressureEllipse(this); 
                set.calcEllipsoid = false;
           end
        end
        

        %% ..................FUNCTIONS.....................................
        % FUNCTIONS
        %..................................................................

        
        function objHRTF = anthro2HRTF(this)
            objHRTF = itaHRTF;
            
%            propH = properties(objHRTF);
%            for iProp = 1:numel(propH)
                objHRTF.data = this.data;
                objHRTF.dirCoord = this.dirCoord;
%                disp(num2str(iProp))
%                 try %#ok<TRYNC>
%                     objHRTF.(propH{iProp}) = this.(propH{iProp});
%                 end
%            end
        end
        
        function obj = direction(this, idxCoord)
            objHRTF = anthro2HRTF(this);
            objHRTF_New = objHRTF.direction(idxCoord);
            obj = itaAnthroHRTF(objHRTF_New);
        end
        
        function obj = findnearestHRTF(this,varargin)
            objHRTF = anthro2HRTF(this);
            objHRTF_New = objHRTF.findnearestHRTF(varargin{:});
            obj = itaAnthroHRTF(objHRTF_New);
        end
        
        function slice = sphericalSlice(this,varargin)
            objHRTF = anthro2HRTF(this);
            objHRTF_New = objHRTF.sphericalSlice(varargin{:});
            slice = itaAnthroHRTF(objHRTF_New);
        end
        %% Functions of this class

        %% ITA Toolbox Functions
        
        function display(this)
            this.displayLineStart
            this.disp

            % this block adds the class name
            dir = num2str(this.nDirections,5);
            stringD = [dir ' Directions (Type = ' this.TF_type ')'];
            middleLine = this.LINE_MIDDLE;
            middleLine(3:(2+length(stringD))) = stringD;
            fprintf([middleLine '\n']);
        end
        
        function disp(this)
            disp@itaHRTF(this)
            d = num2str(this.headDepth);
            w = num2str(this.headWidth);
            h = num2str(this.headHeight);
            string = ['      Head          = width (' w 'm), height (' h 'm), depth (' d 'm)'];
            % this block adds the class name           
            classnamestring = ['^--|' mfilename('class') '|'];
            fullline = repmat(' ',1,this.LINE_LENGTH);
            fullline(1:numel(string)) = string;
            startvalue = length(classnamestring);
            fullline(length(fullline)-startvalue+1:end) = classnamestring;
            disp(fullline);     
        end
               
       
    end
    methods(Hidden = true)
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % have to get save objects for both base classes
            
            % Both options doesn't work at the moment...
            this.mAnthroCoordSave = this.AnthroCoord.sph;
            sObj = saveobj@itaHRTF(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaHRTF.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            this = itaAnthroHRTF(sObj);
        end
        
        
        function result = propertiesSaved
            result = {'headHeight','headWidth','headDepth','headRadius'};
        end
        
        function result = propertiesLoad
            result = {'mHeadHeight','mHeadWidth','mHeadDepth','mHeadRadius'};
        end

%         function result = propertiesInit
%             result = {'channelCoordinates','domain','data'};
%         end
    end
end



