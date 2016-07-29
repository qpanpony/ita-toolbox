classdef itaHeader %Obsolete class for itaHeader
    %    Obsolote class for old header. Necessary for backward compatibility of
    %    old measurements
    %
    %   !!! Don't use for anything !!!
    %		!!! Also don't delete      !!!
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    
    properties(Hidden)
        fieldnames = {};
        old_fields = {'ChannelNames','ChannelUnits','ChannelCoordinates','ChannelSensors',};
    end
    
    properties
        nBins = 0;                  % Int(1) - with the number of bins in itaAudio
        nSamples = 0;               % Int(1) - with the number of Samples in itaAudio
        SamplingRate = 0;           % Int(1) - Sampling Rate
        nChannels = 0;               % Int(1) - Number of Channels
        FFTnorm = '';               % char   - FFT Norm
        DateVector = zeros(1,7);    % Int(1,6) - Date and Time of generation
        Comment = '';               % char - a Comment
        Filename = '';              % char - the name of the file
        Filepath = '';              % char - path to file
        FileExt = '';               % char - extension of file
        History = {};               % Cell - Cell array of strings with history entries
        UserData = {''};            % Cell - UserData, no restrictions
        fcentre = [];               % double - Center-Frequencies for bins (like in frequency bands)
        DataSize = 0;               % Size of data field
        Channel = struct('Name','','Unit','','Coordinates',itaCoordinates,...
            'Orientation',[],'Sensor','','UserData',{''},'Sensitivity',[]); %Struct-Array, one struct for every channel
    end
    
    
    methods
        function header = itaHeader(varargin) %Constructor
            ita_verbose_obsolete('The header is dead');
            header.fieldnames = {'nBins','nSamples','samplingRate','nChannels','FFTnorm','DateVector','Comment','Filename','Filepath','FileExt','History','UserData','Channel','DataSize'};
            %generation time settings
            c = clock; % g et clock settings
            Hun  = 0; Year = c(1); Month = c(2); Day = c(3); Hour = c(4); Min = c(5); Sec = round(c(6));
            header.DateVector = [Year,Month,Day,Hour,Min,Sec,Hun];
            if nargin == 1 %Old header given
                fieldn = fields(varargin{1});
                for idf = 1:numel(fieldn)
                    if any(strcmp(fieldn{idf},header.fieldnames));
                        
                        %% This has to be nicer!
                        if ~strcmpi(fieldn{idf},'Channel'); % ToDO - rsc - make class?
                            header.(fieldn{idf}) = varargin{1}.(fieldn{idf});
                        else
                            input = varargin{1}.Channel;
                            for idch = 1:numel(input)
                                chfields = fields(header.Channel);
                                for idfn = 1:numel(chfields)
                                    if isfield(input(idch),chfields{idfn})
                                        header.Channel(idch).(chfields{idfn}) = input(idch).(chfields{idfn});
                                    end
                                end
                            end
                        end
                        
                    else %Field does not exist, lets see what to do
                        try
                            input = varargin{1}.(fieldn{idf});
                            switch fieldn{idf}
                                case 'ChannelNames'
                                    for idx = 1:numel(input)
                                        header.Channel(idx).Name = input{idx};
                                    end
                                case 'ChannelUnits'
                                    for idx = 1:numel(input)
                                        header.Channel(idx).Unit = input{idx};
                                    end
                                case 'ChannelCoordinates'
                                    for idx = 1:numel(input)
                                        header.Channel(idx).Coordinates = input{idx};
                                    end
                                case 'ChannelOrientation'
                                    for idx = 1:numel(input)
                                        header.Channel(idx).Orientation = input{idx};
                                    end
                                case 'ChannelSensors'
                                    for idx = 1:numel(input)
                                        header.Channel(idx).Sensor = input{idx};
                                    end
                                case 'fcentre'
                                    header.fcentre = input;
                                case 'Samples'
                                    header.nSamples = input;
                                case 'Channels'
                                    header.nChannels = input;
                                otherwise
                                    %if ita_preferences('verboseMode')
                                    %    disp(['itaHeader: Ignoring field: ' fieldn{idf}]);
                                    %end
                            end
                        catch errmsg
                            if ita_preferences('verboseMode')
                                disp(['itaHeader: Ignoring field: ' fieldn{idf}]);
                            end
                        end
                    end
                end
                
            end
        end
        
        function varargout = subsref(audioObj,index)
            %Please be very careful with any changes
            % ToDo - rsc - clean backwards compatibility!
            iIndex = 1;
            old_field = false;
            while iIndex <= numel(index)
                switch index(iIndex).type
                    case '.'    % we are dealing with a command or (pseudo-)field
                        %Wrap old Header-Fields to new ones
                        switch index(iIndex).subs
                            case 'ChannelNames'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                old_field = 1;
                                if numel(index) == 1
                                    varargout = {{audioObj.Channel.Name}};
                                    break;
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Name';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                            case 'ChannelUnits'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                old_field = 1;
                                if numel(index) == 1
                                    varargout = {{audioObj.Channel.Unit}};
                                    break;
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Unit';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                            case 'ChannelCoordinates'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                old_field = 1;
                                if numel(index) == 1
                                    varargout = {{audioObj.Channel.Coordinates}};
                                    break;
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Coordinates';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                
                            case 'ChannelOrientation'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                old_field = 1;
                                if numel(index) == 1
                                    varargout = {{audioObj.Channel.Orientation}};
                                    break;
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Orientation';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                
                            case 'ChannelSensors'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                old_field = 1;
                                if numel(index) == 1
                                    varargout = {{audioObj.Channel.Sensor}};
                                    break;
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Sensor';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                
                            case 'Samples'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                end
                                index(iIndex).subs = 'nSamples';
                                old_field = 1;
                            case 'Channels'
                                %pdi: no warning for channels
                                %                                 if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                %                                     warning(['@itaHeader: subsref for old field is called here: ' index(1).subs]);
                                %                                 end
                                index(iIndex).subs = 'nChannels';
                                old_field = 1;
                            otherwise
                                %Do nothing
                        end
                        if numel(index) >= iIndex+1
                            if isempty(index(iIndex+1).subs)
                                index(iIndex+1).subs = {':'};
                            end
                        end
                        audioObj = builtin('subsref',audioObj,index(iIndex));
                    case '()'
                        audioObj = builtin('subsref',audioObj,index(iIndex));
                    case '{}'
                        audioObj = builtin('subsref',audioObj,index(iIndex));
                    otherwise
                        audioObj = builtin('subsref',audioObj,index(iIndex));
                end
                iIndex = iIndex+1;
                varargout = {audioObj};
            end
        end
        
        function varargout = subsasgn(audioObj,index,value)
            %Please be very careful with any changes
            % ToDo - rsc - clean backwards compatibility!
            old_field = false;
            iIndex = 1;
            tfieldnames = [audioObj.fieldnames 'fcentre'];
            donothing = false; %True for old fields, they will be ignored
            while iIndex <= numel(index)
                switch index(iIndex).type
                    case '.'    % we are dealing with a command or (pseudo-)field
                        %Wrap old Header-Fields to new ones
                        switch index(iIndex).subs
                            case 'ChannelNames'
                                if iscell(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(value)
                                            audioObj.Channel(idch).Name = value{idch};
                                        end
                                        audioObj.Channel(idch+1:end) = [];
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                        end
                                        return
                                    else
                                        value = cell2mat(value);
                                    end
                                elseif ischar(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(audioObj.Channel)
                                            audioObj.Channel(idch).Name = value;
                                        end
                                        %audioObj.Channel(idch+1:end) = [];
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]); %#ok<*WNTAG>
                                        end
                                        return
                                    end
                                    
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Name';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                old_field = 1;
                            case 'ChannelUnits'
                                if iscell(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(value)
                                            audioObj.Channel(idch).Unit = value{idch};
                                        end
                                        audioObj.Channel(idch+1:end) = [];
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                        end
                                        return
                                    else
                                        value = cell2mat(value);
                                    end
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Unit';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                old_field = 1;
                            case 'ChannelCoordinates'
                                if iscell(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(value)
                                            audioObj.Channel(idch).Coordinates = value{idch};
                                        end
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                        end
                                        return
                                    else
                                        value = cell2mat(value);
                                    end
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Coordinates';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                old_field = 1;
                            case 'ChannelOrientation'
                                if iscell(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(value)
                                            audioObj.Channel(idch).Orientation = value{idch};
                                        end
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                        end
                                        return
                                    else
                                        value = cell2mat(value);
                                    end
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Orientation';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                if iscell(value)
                                    value = cell2mat(value);
                                end
                                old_field = 1;
                            case 'ChannelSensor'
                                if iscell(value)
                                    if numel(index) == iIndex
                                        for idch = 1:numel(value)
                                            audioObj.Channel(idch).Sensor = value{idch};
                                        end
                                        varargout{1} = audioObj;
                                        if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                            warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                        end
                                        return
                                    else
                                        value = cell2mat(value);
                                    end
                                end
                                index(iIndex).subs = 'Channel';
                                index(iIndex+2).subs = 'Sensor';
                                index(iIndex+2).type = '.';
                                index(iIndex+1).type = '()';
                                old_field = 1;
                            case 'Samples'
                                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                    warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                end
                                index(iIndex).subs = 'nSamples';
                            case 'Channels'
                                %pdi:no warning for channels
                                %                                 if ita_preferences('developerMode') && ita_preferences('verboseMode')
                                %                                     warning(['@itaHeader: subasgn for old field is called here: ' index(1).subs]);
                                %                                 end
                                index(iIndex).subs = 'nChannels';
                            case {'fieldnames', 'old_fields'}
                                donothing = true;
                                varargout = {};
                            otherwise
                                if ~any(cell2mat(strfind(tfieldnames,index(iIndex).subs))) && iIndex == 1
                                    donothing = true;
                                end
                                old_field = 0;
                        end
                        if numel(index) >= iIndex+1
                            if isempty(index(iIndex+1).subs)
                                index(iIndex+1).subs = {':'};
                            end
                        end
                    case '()'
                    case '{}'
                    otherwise
                end
                iIndex = iIndex+1;
            end
            if ~donothing
                try
                    audioObj = builtin('subsasgn', audioObj, index, value);
                catch errormsg%#ok<CTCH>
                    warning('subsasgn@itaHeader: Something went wrong, please use new header-layout'); %#ok<WNTAG>
                    disp(errormsg.message);
                end
            else
            end
            varargout{1} = audioObj;
            if old_field && ita_preferences('developerMode') && ita_preferences('verboseMode')
                warning(['@itaHeader: subasgn for old field is called here!' index(1).subs]);
            end
        end
        
        function varargout = isfield(itaHeader,fieldname)
            % New isfield, return true for all fields stores in fieldnames
            result = (any(cell2mat(strfind(itaHeader.fieldnames,fieldname))) || any(cell2mat(strfind(itaHeader.old_fields,fieldname))));
            if strcmpi(fieldname,'fcentre')
                if isempty(itaHeader.fcentre)
                    result = false;
                else
                    result = true;
                end
            end
            
            % Warn on old fieldnames
            if any(cell2mat(strfind(itaHeader.old_fields,fieldname))) && ~strcmpi(fieldname,'Channel')
                if ita_preferences('developerMode') && ita_preferences('verboseMode')
                    warning(['@itaHeader: isfield for old field is called here: ' fieldname]);
                end
            end
            
            varargout{1} = result;
        end
        
        function varargout = isstruct(varargin)
            %New isstruct, return always true, to be compatible with old header struct
            varargout{1} = 1;
        end
        
        function varargout = rmfield(varargin)
            %Just do nothing
            varargout = varargin(1);
        end
        
        function varargout = orderfields(varargin)
            %Just do nothing
            varargout = varargin(1);
        end
        
        function varargout = isempty(varargin)
            %Always return false, to be compatible with old header struct
            varargout{1} = 0;
            
        end
        
        function varargout = fields(varargin)
            if isempty(varargin{1}.fcentre)
                varargout{1} = varargin{1}.fieldnames;
            else
                varargout{1} = [varargin{1}.fieldnames {'fcentre'}];
            end
        end
        
        function disp(varargin)
            header = varargin{1};
            builtin('disp',header);
        end
    end
end