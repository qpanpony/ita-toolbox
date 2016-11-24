function varargout = ita_preferences(varargin)
%ITA_PREFERENCES - Switch Preference Mode Flag
%  This function switches the flag of the preference mode requested.
%  0 means off and 1 means on. In case no preference exists, it simply
%  returns all the RWTH_ITA_Toolbox preferences, together with their
%  values.
%
%  struct = ita_preferences() - return all existing preferences
%  ita_preferences() - show GUI
%  ita_prefences(struct) - set all fields specified in struct, can be used to restore/load settings (e.g. from another computer)
%  ita_prefernces('reset') - reset all preferences to default
%
%
%  Call: ita_preferences('pref_name') - returns the value of the preference named pref_name.
%  Call: [pref1, pref2] = ita_preferences({'pref1','pref2'}) - returns the values of all preferences in the argument cell
%  Call: s = ita_preferences('s*') - returns all preferences starting with s
%
%  Call: ita_preferences('pref_name',value) - Set preference pref_name to
%  the given value;
%
%  Remarks: ita_preferences_verbose(preference,value) - If preference
%  doesn't exist yet, add it to the preferences and set it to value
%  (value -> 'on'|'off')
%
%   See also ita_toolbox_setup
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_preferences">doc ita_preferences</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%pdi: this function only takes care about the settings itself and how they
%are stored. The GUI is nested in a separate function as a graphical
%frontend only

%% Number of Input Arguments
narginchk(0,2);
persistent defined_preferences %pdi:sorry, but speed reasons led me to this decision:-) % Persistens is better than global!
persistent userInfo; % Stores infos from LicenseFile

if isempty(defined_preferences)
    %% Define known preferences with their associated default settings and the type in here
    defined_preferences = ita_defined_preferences();
    ita_check4toolboxsetup; %pdi - moved here to avoid strange recursion
end

samplingRateChanged = false; % for playrec init

%% Define Tab Names to use for the numbers specified above
tab_names = {'General Settings','IO Settings','Expert Stuff','Apps'};

%% Check for existing preferences
if nargin == 0
    %% just return everything
    value = getpref('RWTH_ITA_ToolboxPrefs');%Preference now contains all the preference fields of the %RWTH_ITA_Toolbox
    
    % If empty (first call ever or after reset) set all default preferences
    if isempty(value)
        for idx = 1:size(defined_preferences,1)
            if ~strcmpi(defined_preferences{idx,3},'LicenseFile') && ~strcmpi(defined_preferences{idx,3},'*LicenseFile') % Dont save preferences from license file
                value = defined_preferences{idx,2};
                className = defined_preferences{idx,3};
                % bugfix for boolean values, do a cast
                if ~isempty(strfind(className,'bool')) || ~isempty(strfind(className,'logic'))
                    value = cast(value,'logical');
                end
                setpref('RWTH_ITA_ToolboxPrefs',defined_preferences{idx,1},value);
            end
        end
        value = getpref('RWTH_ITA_ToolboxPrefs');%Preference now contains all the preference fields of the %RWTH_ITA_Toolbox
    end
elseif nargin == 1
    %% User is asking for a particular preference.
    % If the preference is set without the value, check if it is already
    % a pref - if yes, return its value, otherwise an error.
    
    if ischar(varargin{1})
        if strcmpi(varargin{1},'reset') % Reset all settings (by simply deleting them)
            try
                rmpref('RWTH_ITA_ToolboxPrefs');
            catch errmsg %#ok<NASGU>
                ita_verbose_info('ITA_PREFERENCES: could not delete your preferences',0);
            end;
            clear global;
            return;
        elseif strcmp(varargin{1}(end),'*')
            searchStr = varargin{1}(1:end-1);
            returnPrefs = defined_preferences(strncmp(defined_preferences(:,1),searchStr,numel(searchStr)),1);
            result = struct();
            for idx = 1:numel(returnPrefs)
                result.(returnPrefs{idx}) = ita_preferences(returnPrefs{idx});
            end
            varargout{1} = result;
            return;
        else % Get preference
            preference_name = varargin{1};
            prefidx = strcmpi(defined_preferences(:,1),preference_name);
            if any(prefidx)
                preference_name = defined_preferences{prefidx,1}; %Get the case right!
                global_preference_name = ['RWTH_ITA_' preference_name];
                eval(['persistent ' global_preference_name ';']); %Persistent is better than global because it is only visible and changeable by this function
            else
                % try to update the defined preferences, maybe something
                % changed after an update
                defined_preferences = ita_defined_preferences();
                prefidx = strcmpi(defined_preferences(:,1),preference_name);
                if ~any(prefidx)
                    ita_verbose_info(['ITA_PREFERENCES:Sorry, I dont know that preference: ' preference_name '.'],0);
                    varargout{1} = [];
                    return;
                else % if it is found now, continue
                    preference_name = defined_preferences{prefidx,1};
                    global_preference_name = ['RWTH_ITA_' preference_name];
                    eval(['persistent ' global_preference_name ';']);
                end
            end
        end
    elseif iscellstr(varargin{1})
        input = varargin{1};
        for idx = 1:numel(input)
            varargout{idx} = ita_preferences(input{idx}); %#ok<AGROW>
        end
        return
    elseif isstruct(varargin{1}) % All setting as a struct
        fields = fieldnames(varargin{1});
        for idx = 1:numel(fields)
            ita_preferences(fields{idx},varargin{1}.(fields{idx}));
        end
        return
    else
        error('ITA_PREFERENCES:no name string specified');
    end
    %get value from global variable
    value = eval(global_preference_name);
    if isempty(value)
        if any(strcmpi(defined_preferences(:,1),preference_name))
            % Read from git configuration, but only if name and email
            % haven't been set already or are the same as the default
            % values given in ita_defined_preferences
            if isempty(userInfo) && (strcmp(preference_name,'AuthorStr') || strcmp(preference_name,'EmailStr'))
                if ispref('RWTH_ITA_ToolboxPrefs',preference_name)
                    if isempty(getpref('RWTH_ITA_ToolboxPrefs',preference_name)) ||  ...
                            strcmp(getpref('RWTH_ITA_ToolboxPrefs',preference_name),'@') 
                        userInfo = ita_git_read_config;
                        
                    else
                        userInfo.(preference_name) = getpref('RWTH_ITA_ToolboxPrefs',preference_name);
                    end
                else
                    userInfo = ita_git_read_config;
                end            
            end
            if isfield(userInfo,preference_name)
                value = userInfo.(preference_name);
                eval([global_preference_name ' = value;']); %Set global for faster access the next time
                setpref('RWTH_ITA_ToolboxPrefs',preference_name, value);
            else
                if ispref('RWTH_ITA_ToolboxPrefs',preference_name) % try to read preference
                    value = getpref('RWTH_ITA_ToolboxPrefs',preference_name);
                else
                    % return default values if preferences is not set
                    is_defined = strcmpi(defined_preferences(:,1),preference_name);
                    [idx,jdx]  = find(is_defined,1);
                    value = defined_preferences{idx,jdx+1};
                end
                eval([global_preference_name ' = value;']); %Set global for faster access the next time
            end
            
        elseif ispref('RWTH_ITA_ToolboxPrefs',preference_name)
            value = getpref('RWTH_ITA_ToolboxPrefs',preference_name);
            eval([global_preference_name ' = value;']); %Set global for faster access the next time
        elseif any(strcmpi(defined_preferences(:,1),preference_name))
            is_defined = strcmpi(defined_preferences(:,1),preference_name);
            value = defined_preferences{find(is_defined,1),2};
            %pdi: in this case the preference has to be set
            setpref('RWTH_ITA_ToolboxPrefs',preference_name,value);
            eval([global_preference_name ' = value;']); %Set global for faster access the next time
        elseif isfield
            
        else
            error('Preference does not exist!');
        end
    end
    
elseif nargin == 2
    %% check if name is in list
    if ~ischar(varargin{1})
        error('ITA_PREFERENCES:No name string specified.');
    end
    
    preference_name = varargin{1};
    idx_list = strcmpi(defined_preferences(:,1),preference_name);
    if any(idx_list)
        preference_name = defined_preferences{idx_list,1}; %Get the case right!
    else
        warning(['ITA_PREFERENCES:Sorry, I dont know that preference: ' preference_name]); %#ok<WNTAG>
        return
    end
    
    global_preference_name = ['RWTH_ITA_' preference_name];
    value      = varargin{2};
    value_type = defined_preferences{idx_list,3};
    
    switch(value_type)
        case {'path','*path'}
            if (~ischar(value) ||  ~isdir(value)) && ~isempty(value)
                value = ita_preferences(preference_name);
                ita_verbose_info(sprintf('Preferences: %s. Path invalid. Using old (%s).', upper(preference_name), value)  ,0);
            end
            
        case {'logical','bool','*bool','bool_ispc','*bool_ispc'}
            if value < 0 || value > 1 || isempty(value) || ~isnatural(value)
                error('ITA_PREFERENCES:bool value expected')
            end
            if strcmpi(value,'off')
                value = false;
            end
            if strcmpi(value,'on')
                value = true;
            end
            
            %% check if bool
        case {'numeric','double','int','*int','matrix','int_portMidi','popup_double'}
            if ~isnumeric(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications');
            end
            if isnan(value)
                value = [];
            end;
        case {'int_verboseMode'}
            if ~isnumeric(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications');
            end
            if ~isempty(value) && (value<-1 || value>2)
                error('ITA_PREFERENCES:verboseModeLevel could be between 0-2');
            end
            if isnan(value)
                value = [];
            end
        case {'playrecFunctionHandle'}
            if ~isnumeric(value) || value == 0
                value = 1;
            end
        case {'int_portAudio'}
            %% handle port audio IDs and strings
            if ischar(value)
                value = ita_portaudio_string2deviceID(value);
            end
            if ~isnumeric(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications');
            end
            if isnan(value)
                value = [];
            end
        case {'string','char','char*','*char','popup_char'}
            if ~ischar(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications');
            end
        case {'password'}
            value = value(value ~= ' ');
            if length(value) ~= 40
                disp('Be careful! Your passphrase does not seem to be valid.')
            end
            if ~ischar(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications')
            end
        case {'str_comPort'}
            if ~ischar(value) && ~isempty(value)
                error('ITA_PREFERENCES:type does not match specifications')
            end
            if ~isincellstr(value,ita_get_available_comports())
                error('ITA_PREFERENCES:this COM Port is not available');
            end
        case {'LicenseFile', '*LicenseFile'}
            ita_verbose_info('Sorry, this cannot be changed!',2)
            return;
        case '*struct'
            if ~isstruct(value)
                error('%s must be of type struct (not %s)', preference_name, class(value))
            end
        otherwise
            error(['ITA_PREFERENCES:what type should this be? ' value_type])
    end
    
    %% generate global variable and set preference
    % check if samplingRate has changed
    if strcmpi(preference_name,'samplingRate')
        pr = getpref('RWTH_ITA_ToolboxPrefs');
        if isfield(pr,'samplingRate') && (getpref('RWTH_ITA_ToolboxPrefs',preference_name) ~= value)
            samplingRateChanged = true;
        end
    end
    setpref('RWTH_ITA_ToolboxPrefs',preference_name,value);
    eval(['persistent ' global_preference_name ';']);
    eval([global_preference_name ' = value;']);
end


if samplingRateChanged
    recID = getpref('RWTH_ITA_ToolboxPrefs','recDeviceID');
    playID = getpref('RWTH_ITA_ToolboxPrefs','playDeviceID');
    if ~all([playID,recID] == -1)
        if playrec('isInitialised')
            playrec('reset');
        end
        sr = getpref('RWTH_ITA_ToolboxPrefs','samplingRate');
        % seems to work this way, tell portaudio the sampling rate ...
        playrec('init',sr,playID,recID);
        % ... but then kill the playrec part in matlab
        clear mex; %#ok<CLMEX>
    end
end

%% Show result
if nargout == 1
    %just return result
    varargout{1} = value;
elseif nargout == 0
    if nargin == 0
        %show gui
        ita_verbose_info('ita_preferences::clearing mex functions first...',2);
        clear mex %#ok<CLMEX> %clear for playrec & pdi
        if usejava('jvm') %Only if jvm available (non_cluster)
            ita_preferences_gui_tabs(defined_preferences,tab_names);
        else
            disp(ita_preferences);
        end
        ita_delete_filter;
    elseif nargin == 1
        %show value
        disp(value);
    else
        %return value
        varargout{1} = value;
    end
end


end% end function
