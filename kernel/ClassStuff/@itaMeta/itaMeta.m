classdef itaMeta

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

    %ITAMeta - GrandMother of all itas
    %   Nobody acutally needs this class directly, it is actually an
    %   abstract class.
    %

    
    properties(Access = private, Hidden = true)
        % Internal fields, no access from outside the class
        %mData = [];
        mComment = '';
        mHistory = {};
        mErrorLog = {};
        mUserData = {};
        mFileName = '';
        mDateCreated = datevec(now);
        mDateModified = nan(1,6);
        mDateSaved = nan(1,6);
        mPlotAxesProperties = {};
        mPlotLineProperties = {};
        mUserName = ita_preferences('AuthorStr');
    end
    
    properties(Constant)
        % record here all (dependent) properties that need to be saved
    end
    
    properties(Abstract)
        % Properties that all sub-classes have but are not used in this class
    end
    
    properties(Dependent = true, Hidden = false)
        comment %comment describing your object (string)
        history %history showing you what had happened to your Obj (cell array)
        userData %you can store any kind of data here. but it is unsave!
        errorLog %what went wrong? clipping?
        plotAxesProperties %axis settings
        plotLineProperties %line style settings
    end
    properties(Dependent = true, Hidden = true)
        fileName %filename associated with this object
        dateCreated %time of first creation (born)
        dateModified %last modification date
        dateSaved %last saved date
        userName % name of user that created this object
    end
    methods
        %% Constructor
        function this = itaMeta(varargin)
            % Constructor
            % Calls:
            %   itaMeta() - Empty object
            %   itaMeta(n) or itaMeta([x y z]) - Preinitialize n*n or x*y*z objects
            %   itaMeta(itaMeta) - Copy-Constructor
            %   itaMeta(Struct) - convert/import struct
            %   itaMeta( ... ,n) or itaMeta(... , [a b c]) - Prinitialize with datafield size a*b*c
            
            if nargin == 0
                %Nothing to do
            elseif nargin >= 1 %One input
                if isnumeric(varargin{1}) % Preinitialize n-Instances
                    this = repmat(this,varargin{1});
                end
                if strcmpi(class(varargin{1}),mfilename) % Copy-Constructor
                    this = varargin{1};
                end
                if isstruct(varargin{1}) % Struct input/convert
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
            if nargin == 2 % Two inputs, preinitialze data-size
                [this(:).mData] = deal(nan(varargin{2}));
            end
            
            % problem with cached date
            for i = numel(this)
                this(i).dateCreated = deal(now); %#ok<AGROW>
            end
        end
        
        %% Get/Set Functions
        function result = get.comment(this)
            result = this.mComment;
        end
        function this = set.comment(this,value)
            this.mComment = value;
        end
        
        function result = get.history(this)
            result = this.mHistory;
        end
        function this = set.history(this,value)
            this.mHistory = value;
        end
        
        function result = get.errorLog(this)
            result = this.mErrorLog;
        end
        function this = set.errorLog(this,value)
            this.mErrorLog = value;
        end
        
        function result = get.userData(this)
            result = this.mUserData;
        end
        function this = set.userData(this,value)
            this.mUserData = value;
        end
        
        function result = get.fileName(this)
            result = this.mFileName;
        end
        function this = set.fileName(this,value)
            this.mFileName = value;
        end
        
        function result = get.dateCreated(this)
            result = this.mDateCreated;
        end
        function this = set.dateCreated(this,value)
            this.mDateCreated = value;
        end
        
        function result = get.dateModified(this)
            result = this.mDateModified;
        end
        function this = set.dateModified(this,value)
            this.mDateModified = value;
        end
        
        function result = get.dateSaved(this)
            result = this.mDateSaved;
        end
        function this = set.dateSaved(this,value)
            this.mDateSaved = value;
        end
        
        function result = get.plotAxesProperties(this)
            result = this.mPlotAxesProperties;
        end
        function this = set.plotAxesProperties(this,value)
            this.mPlotAxesProperties = value;
        end
        
        function result = get.plotLineProperties(this)
            result = this.mPlotLineProperties;
        end
        function this = set.plotLineProperties(this,value)
            this.mPlotLineProperties = value;
        end
        
        function result = get.userName(this)
            result = this.mUserName;
        end
        function this = set.userName(this,value)
            stack = dbstack;
            if numel(stack) > 1 && (strcmpi(stack(2).name,'itaMeta.itaMeta') || strcmpi(stack(2).name,'itaSuper.itaSuper') || strcmpi(stack(2).name,'itaCoordinates.itaCoordinates') || strcmpi(stack(2).name,'itaMeshNodes.itaMeshNodes'))  % Only constructor may change this
                this.mUserName = value;
            else 
                ita_verbose_info('itaMeta: UserName cannot be changed',0);
            end     
        end
           
    end
    
    methods(Hidden = true)
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            
            % Store class name and class revision
            sObj.classname = class(this);
            sObj.classrevision = this.classrevision;

            % Copy all properties that were defined to be saved
            propertylist = itaMeta.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end            
            
            % Set DateSaved
            sObj.dateSaved = datevec(now);
        end
    end
    
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMeta(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 12377 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'comment','history','errorLog',...
                'fileName','dateCreated','dateModified','dateSaved','userData','plotAxesProperties','plotLineProperties','userName'};
        end
    end
    
end

