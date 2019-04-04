classdef  itaMeshGroupProperties < itaMeta

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Access = private)
        mID = 1;
        mName = [];
        mValue = 0;
        mType = 'Admittance';
        mFreq
        mFreqInputFilename
        mgroupID
        mC=343.7;
        mRho=1.2;
    end
    
    properties(Dependent)
        ID
        Name
        Type
        Value
        Freq
        FreqInputFilename
        groupID 
        rho 
        c
        Unit
    end
        
    methods
        function this = itaMeshGroupProperties(varargin)
            if nargin < 4
                if isa(varargin{1},'itaMeshGroupProperties')
                    this = varargin{1};
                    if nargin >= 2
                        if isnumeric(varargin{2})
                            this.mFreq=varargin{2};
                        elseif isa(varargin{2},'itaMeshGroup')
                            this = isGroup(this, varargin{1});
                        elseif isstruct(varargin{2})
                            this = isPropStruct(this,varargin{1});
                        end
                        if nargin == 3 && isnumeric(varargin{3})
                            this.mFreq = varargin{3};
                        end
                    end
                elseif isstruct(varargin{1})
                    this = isPropStruct(this,varargin{1});
                    if nargin == 2, this = isGroup(this, varargin{2}); end
                elseif isa(varargin{1},'itaMeshGroup')
                    this = isGroup(this, varargin{1});
                    if nargin == 2, this = isPropStruct(this, varargin{2}); end
                end
            elseif nargin > 3
                if ischar(varargin{1}), this.mName = varargin{1}; end
                if ischar(varargin{2}), this.mType = varargin{2}; end
                if isnumeric(varargin{3}), this.mValue = varargin{3}; end
                if isnumeric(varargin{4}), this.mFreq = varargin{4}; end
                if nargin == 5 && ischar(varargin{5})
                    this.mFreqFilename = varargin{5};
                end
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
        function this = set.ID(this, value), this.mID = value; end
        
        function this = set.Name(this, value)
            if ischar(value)
                this.mName = value;
            else
                error('itaMeshGroupProperties::Name has to be string');
            end
        end
        
        function this = set.Type(this,value)
            switch this.mType
                case 'Admittance',this.mType = value; this.mUnit ='m/(Pa s)';
                case 'Impedance', this.mType = value; this.mUnit ='(Pa s)/m';
                case 'Reflection', this.mType = value; this.mUnit ='';
                case 'Absorption', this.mType = value; this.mUnit ='';
                case 'Displacement', this.mType = value ; this.mUnit ='m';
                case 'Velocity', this.mType = value; this.mUnit ='m/s';
                case 'Acceleration', this.mType = value; this.mUnit ='m/s²';
                case 'Point Source', this.mType = value; this.mUnit ='m³/s';
                case 'Pressure', this.mType = value; this.mUnit ='Pa';
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
        function this = set.rho(this,value),this.mRho=value;end
        function this = set.c(this,value),this.mC=value;end
        % GET
        %------------------------------------------------------------------
        function value = get.ID(this), value = this.mID; end
        function value = get.Name(this), value = this.mName; end
        function value = get.Type(this), value = this.mType; end
        function value = get.Value(this), value = this.mValue; end
        function value = get.Freq(this)
            if isnumeric(this.mFreq)
                value =this.mFreq;
            end
        end
               
        function value = get.FreqInputFilename(this), value = this.mFreqInputFilename; end

        
        function value = get.groupID(this); value = this.mgroupID; end
        function value = get.rho(this),value = this.mRho;end
        function value = get.c(this),value = this.mC;end
        
        function value = get.Unit(this)
            switch this.mType
                case 'Admittance',value ='m/(Pa s)';
                case 'Impedance', value ='(Pa s)/m';
                case 'Reflection', value ='';
                case 'Absorption', value ='';
                case 'Displacement', value ='m';
                case 'Velocity', value ='m/s';
                case 'Acceleration', value ='m/s²';
                case 'Point Source', value ='m³/s';
                case 'Pressure', value ='Pa';
            end
            
        end

        %% other functions
        function this = isGroup(this,mGroup)
            this.mgroupID = mGroup.groupID;
            this.mID = mGroup.groupID;
            this.mName = mGroup.groupName;
        end
        
        function this = isPropStruct(this,mPropStruct)
            propFieldname = fieldnames(mPropStruct);
            if length(propFieldname)==6
                if isnumeric(mPropStruct.(propFieldname{1})) &&...
                        ischar(mPropStruct.(propFieldname{2})) && ...
                        ischar(mPropStruct.(propFieldname{3}))&&...
                        isnumeric(mPropStruct.(propFieldname{4}))&&...
                        isnumeric(mPropStruct.(propFieldname{5}))&&...
                        ischar(mPropStruct.(propFieldname{6}))
                    
                    this.mID = mPropStruct.(propFieldname{1});
                    this.mName = mPropStruct.(propFieldname{2});
                    this.mType = mPropStruct.(propFieldname{3});
                    this.mValue= mPropStruct.(propFieldname{4});
                    this.mFreq = mPropStruct.(propFieldname{5});
                    this.mFreqInputFilename = mPropStruct.(propFieldname{6});
                end
            end
        end
    end
end
