classdef  itaMeshBoundaryC < itaMeshProperties

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Access = private)
        mValue = 0;
        mType = 'Admittance';
        mFreq
        mFreqInputFilename
        mgroupID
    end
    
    properties(Dependent)
        Type
        Value
        Freq
        FreqInputFilename
        groupID 
        Unit
    end
        
    methods
        function this = itaMeshBoundaryC(varargin)
            if nargin == 1
                if isa(varargin{1},'itaMeshBoundaryC')
                    this = varargin{1};
                elseif isa(varargin{1},'itaMeshGroup')
                    this = isGroup(varargin{1});
                elseif isstruct(varargin{1})
                    propFieldname = fieldnames(varargin{1});
                    if length(propFieldname)==6
                        if isnumeric(varargin{1}.(propFieldname{1})) &&...
                                ischar(varargin{1}.(propFieldname{2})) &&...
                                ischar(varargin{1}.(propFieldname{3}))&&...
                                isnumeric(varargin{1}.(propFieldname{4}))&&...
                                isnumeric(varargin{1}.(propFieldname{5}))&&...
                                ischar(varargin{1}.(propFieldname{6}))
                            this.ID = varargin{1}.(propFieldname{1});
                            this.Name = varargin{1}.(propFieldname{2});
                            this.mType = varargin{1}.(propFieldname{3});
                            this.mValue= varargin{1}.(propFieldname{4});
                            this.mFreq = varargin{1}.(propFieldname{5});
                            this.mFreqInputFilename = varargin{1}.(propFieldname{6});
                        end
                    else
                        this.Name = varargin{1}.(propFieldname{find(strcmp(propFieldname,'Name')==1)});
                        this.mType = varargin{1}.(propFieldname{find(strcmp(propFieldname,'Type')==1)});
                        this.mValue = varargin{1}.(propFieldname{find(strcmp(propFieldname,'Value')==1)});
                        this.mFreq= varargin{1}.(propFieldname{find(strcmp(propFieldname,'Freq')==1)});
                        this.mFreqInputFilename = varargin{1}.(propFieldname{find(strcmp(propFieldname,'FreqInputFilename')==1)});
                        this.mgroupID = varargin{1}.(propFieldname{find(strcmp(propFieldname,'groupID')==1)});
                    end
                end
            elseif nargin > 3
                if ischar(varargin{1}), this.mType = varargin{1}; end
                if isnumeric(varargin{2}), this.mValue = varargin{2}; end
                if isnumeric(varargin{3}), this.mFreq = varargin{3}; end
                if ischar(varargin{4}), this.mFreqFilename = varargin{4}; end
            end                  
        end
        
        function display(this)
            disp([this.Name '  (ID: ' num2str(this.ID) ')']);
            disp( '==================================================')
            disp(['groupID     : ' num2str(this.groupID)]);
            disp(['Type        : ' this.mType  ]);

            if length(this.Value)==1
            disp(['Value       : ' num2str(this.mValue) ' ' num2str(this.Unit) '   '  ...
                  'Frequency   : ' num2str(this.mFreq) 'Hz']);
            else
            disp(['Value       : ' num2str(this.mValue(1)) ' ... ' num2str(this.mValue(end)) ' ' this.Unit]);   
            disp(['Frequency   : ' num2str(this.mFreq(1)) ' ... ' num2str(this.mFreq(end)) ' Hz']);
            end                
        end

        % SET
        %------------------------------------------------------------------       
        function this = set.Type(this,value)
            switch value
                case 'Admittance',this.mType = value; 
                case 'Impedance', this.mType = value; 
                case 'Reflection', this.mType = value; 
                case 'Absorption', this.mType = value;
                case 'Displacement', this.mType = value ;
                case 'Velocity', this.mType = value; 
                case 'Acceleration', this.mType = value;
                case 'Point Source', this.mType = value;
                case 'Pressure', this.mType = value;
                otherwise
                    error(['itaMeshGroupProperties::' this.mType 'is no valid Type'])
            end
        end
        
        function this = set.Value(this,value)
            if isnumeric(value)
                this.mValue = value;
            else
                error('itaMeshGroupProperties::Value has to be numeric');
            end
        end
        
        function this  = set.Freq(this,value),this.mFreq=value; end        
        function this = set.groupID(this,value),this.mgroupID = value;end
        
        % GET
        %------------------------------------------------------------------
        function value = get.Type(this), value = this.mType; end
        function value = get.Value(this), value = this.mValue; end
        function value = get.Freq(this)
            if isnumeric(this.mFreq)
                value =this.mFreq;
            end
        end
               
        function value = get.FreqInputFilename(this), value = this.mFreqInputFilename; end  
        function value = get.groupID(this); value = this.mgroupID; end
        
        function value = get.Unit(this)
            switch this.mType
                case 'Admittance',value ='m/(Pa s)';
                case 'Impedance', value ='(Pa s)/m';
                case 'Reflection', value ='';
                case 'Absorption', value ='';
                case 'Displacement', value ='m';
                case 'Velocity', value ='m/s';
                case 'Acceleration', value ='m/s^2';
                case 'Point Source', value ='m^3/s';
                case 'Pressure', value ='Pa';
            end
            
        end

        %% other functions
        function this = isGroup(mGroup)
            this.mgroupID = mGroup.groupID;
            this.mID = mGroup.groupID;
            this.mName = mGroup.groupName;
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % have to get save objects for both base classes
            sObj = saveobj@itaMeshProperties(this);    

          
            % Copy all properties that were defined to be saved
            propertylist = itaMeshBoundaryC.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            this = itaMeshBoundaryC(sObj); % Just call constructor, he will take care
        end
        
        function result = propertiesSaved
            result = {'Type','Value', 'Freq','FreqInputFilename','groupID','Unit'};
        end
    end
end
