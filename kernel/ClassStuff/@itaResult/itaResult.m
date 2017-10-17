classdef itaResult < itaSuper


    %   ITARESULT - class for results with reduced data in one domain,
    %               hence no longer playable, no transformations possible.
    %
    % This class should be used for the output of ita-toolbox functions
    % that analyse time/frequency signals and output a single value or a
    % group of single values, like the calculation of loudness of a signal
    % or the calculation of room acoustic parameters of an impulse response.
    %
    %   %   Reference page in Help browser
    %       <a href="matlab:doc itaResult">doc itaResult</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    
    properties(Access = private)
        % Internal fields, no access from outside the class
        mAbscissa = 0;
        mResultType = '';
    end
    
    properties(Constant, Hidden = true)
        % record here all (dependent) properties that need to be saved
    end
    
    properties(Dependent = true, Hidden = false)
        freqVector %frequency Vector (x-Axis)
        timeVector %time Vector (x-Axis)
        resultType %what is it?
    end
    
    properties(Dependent = true, Hidden = true)
        abscissa
    end
    
    methods
        function this = itaResult(varargin)
            % Constructor
            %   itaResult(itaAudioObj) - typecast
            %   itaResult(itaResultObj) - copy constructor
            %   itaResult(dataMatrix/dataVector,freqVector/timeVector/SR,domainString) - like deprecated ita_import
            
            isSpecialCase = false;
            doCast = false; doSampling = false;
            if nargin && isa(varargin{1},'itaAudio')
                % does the typecast from itaAudio to itaResult
                % is not a cast -> does not change the data
                audioInput = varargin{1};
                if nargin >= 2 % abscissa also given
                    abscissaInput = varargin{2};
                    if isTime(audioInput) && max(abscissaInput) > double(audioInput.trackLength)
                        error('%s:sampling points out of range (domain is time)',upper(mfilename));
                    elseif isFreq(audioInput) && max(abscissaInput) > max(audioInput.freqVector)
                        error('%s:sampling points out of range (domain is freq)',upper(mfilename));
                    end
                    doSampling = true;
                else
                    abscissaInput = audioInput.([audioInput.domain 'Vector']);
                end
                doCast = true;
                varargin = {};
            elseif nargin && isa(varargin{1},mfilename)
                % copying/sampling of an itaResult object
                resultInput = varargin{1};
                domain = resultInput.domain;
                isSpecialCase = true;
                if nargin == 2 % also sample the result with a given vector
                    abscissaInput   = varargin{2};
                    switch domain
                        case 'time'
                            domainData = resultInput.time2value(abscissaInput);
                        case 'freq'
                            domainData = resultInput.freq2value(abscissaInput);
                    end
                else % just copy
                    abscissaInput = resultInput.([domain 'Vector']);
                    domainData      = resultInput.(domain);                    
                end
                varargin = {resultInput};
            elseif nargin == 3
                domainData = varargin{1};
                abscissaInput = varargin{2};
                domain = varargin{3};
                if size(domainData,1) ~= numel(abscissaInput)
                    error('%s:data and abscissa dimensions do not match!',upper(mfilename));
                end
                isSpecialCase = true;
                varargin = {};
            elseif nargin && isstruct(varargin{1}) && isfield(varargin{1},'freqVector')
                domainData = varargin{1}.data;
                domainData = reshape(domainData,[size(domainData,1),varargin{1}.dimensions]);
                abscissaInput = varargin{1}.freqVector;
                domain = varargin{1}.domain;
                isSpecialCase = true;
                varargin{1} = rmfield(varargin{1},'freqVector');
            end
            this = this@itaSuper(varargin{:});
            
            if isSpecialCase
                this.domain = domain;
                this.abscissa = abscissaInput(:);
                this.(this.domain) = domainData;
            elseif doCast % copy all data from the audio Object
                sObj = saveobj(audioInput);
                sObj = rmfield(sObj,[{'classname','classrevision'},itaAudio.propertiesSaved]);
                this = itaResult(sObj);
                if doSampling % abscissa was given
                    this.abscissa = abscissaInput(:);
                    switch audioInput.domain
                        case 'time'
                            this.time = audioInput.time2value(abscissaInput(:));
                        case 'freq'
                            this.freq = audioInput.freq2value(abscissaInput(:));
                    end
                else
                    this.abscissa = abscissaInput(:);
                end
            end
        end
        
        
        %% Get/set Stuff
        function result = get.abscissa(this)
            result = this.mAbscissa(:);
        end
        
        function this = set.abscissa(this,value)
            this.mAbscissa = value(:);
            this.dateModified = datevec(now);
        end
        
        function result = get.freqVector(this)
            if isFreq(this)
                result = this.abscissa;
            else
                result = [];
                error([upper(mfilename) ':your result is not in the frequency domain!']);
            end
        end
        
        function result = get.timeVector(this)
            if isTime(this)
                result = this.abscissa;
            else
                result = [];
                error([upper(mfilename) ':your result is not in the time domain!']);
            end
        end
        
        function this = set.freqVector(this,value)
            this.mAbscissa = value;
            this.dateModified = datevec(now);
            if isTime(this)
                ita_verbose_info([upper(mfilename) ':switching domain from time to freq, I hope you know what you are doing!'],2);
                this.domain = 'freq';
            end
        end
        
        function this = set.timeVector(this,value)
            this.mAbscissa = value;
            this.dateModified = datevec(now);
            if isFreq(this)
                ita_verbose_info([upper(mfilename) ':switching domain from freq to time, I hope you know what you are doing!'],2);
                this.domain = 'time';
            end
        end
        
        function result = get.resultType(this)
            result = this.mResultType;
        end
        
        function this = set.resultType(this,value)
            if ischar(value)
                this.mResultType = value;
            else
                error('%s:resultType has to be a string!',upper(mfilename));
            end
        end
        
        
        %% logs
        function this = log(this)
            %redirect log
            this.data = log(this.data);
        end
        function this = log10(this)
            %redirect log10
            this.data = log10(this.data);
        end
        
        
        %% min max
        function res = min(this)
            %minimum
            res = this;
            res.data = min(this.data,[],2);
        end
        function res = max(this)
            %maximum
            res = this;
            res.data = max(this.data,[],2);
        end
    end
    
    %% Hidden methods
    
    methods(Hidden = true)
        
        function [this1, this2] = prepare4merge(this1, this2)
            % Prepare two object for merge, check if compatible and try to fix problems
            
            if ~strcmpi(this1.domain,this2.domain) 
                error('Merge: These itaResults wont work together: ill-suited  domain');
            end
            
            if  numel(this1.abscissa) ~= numel(this2.abscissa) || any(round(this1.abscissa(:).*1e6) ~= round(this2.abscissa(:).*1e6)) % also check for resultType? || ~strcmp(this.resultType,this2.resultType)
                error('Merge: These itaResults wont work together: ill-suited abscissa ');
            end

            [this1, this2] = prepare4merge@itaSuper(this1, this2);
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSuper(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaResult.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
        %% conversion nSamples <=> nBins
        % these two functions are supposed to define the behaviour if the
        % user wants time data from the frequency domain object or vice
        % versa
        function nBins = nSamples2nBins(this)
            %             warning([upper(mfilename) ': please check the conversions of bins into samples and vice versa']);
            nBins = this.nSamples;
        end
        function nSamples = nBins2nSamples(this)
            %             warning([upper(mfilename) ': please check the conversions of bins into samples and vice versa']);
            nSamples = this.nBins;
        end
        
    end
    
    
    %% static methods
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            superclass = false;
            % change mpo: not relying on svn properties anymore
            try
                if sObj.classrevision > 2600 ...
                        || isnan(sObj.classrevision) % for non-SVN clients
                    superclass = true;
                end
            catch
                % all right: it was NO superclass
            end
            
            if ~superclass
                if isfield(sObj,'header') %has header
                    this = ita_import_old(sObj);
                    return
                else    % is headerless
                    sObj.dimensions = sObj.dims;
                    sObj.channelCoordinates = itaCoordinates(sObj.channelcoordinates);
                    sObj.channelOrientation = itaCoordinates(sObj.channelorientation);
                    sObj = rmfield(sObj,{'dims','channelcoordinates','channelorientation'});
                end
            end
            
            % change mpo: not relying on svn properties anymore
            try
                sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            catch
                % fields were not there obviously
            end
            
            % change mpo: not relying on svn properties anymore
            if isstruct(sObj)
                this = itaResult(sObj); % Just call constructor, he will take care
            else
                this = sObj;
            end
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 12902 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'abscissa', 'resultType'};
        end
        
    end
end