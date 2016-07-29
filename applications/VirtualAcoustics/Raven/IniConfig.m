classdef IniConfig < handle
    %IniConfig - The class for working with configurations of settings and INI-files. 
    % This class allows you to create configurations of settings, and to manage them. 
    % The structure of the storage settings is similar to the structure of 
    % the storage the settings in the INI-file format. 
    % The class allows you to import settings from the INI-file and to export 
    % the settings in INI-file. 
    % Can be used for reading/writing data in the INI-file and managing 
    % settings of application.
    %
    %
    % Using:
    %   ini = IniConfig()
    %
    % Public Properties:
    %   Enter this command to get the properties:
    %   >> properties IniConfig
    %
    % Public Methods:
    %   Enter this command to get the methods:
    %   >> methods IniConfig
    %
    %   Enter this command to get more info of method:
    %   >> help IniConfig/methodname
    %
    %
    % Config Syntax:
    %
    %   ; some comments
    %
    %   [Section1] ; allowed the comment to section
    %   ; comment on the section
    %   key1 = value_1 ; allowed a comment to an individual parameter
    %   key2 = value_2
    %   
    %   [Section2]
    %   key1 = value_1.1, value_1.2     ; array data
    %   key2 = value_2
    %   ...
    %
    % Note:
    %   * There may be spaces in the names of sections and keys
    %   * Keys should not be repeated in the section (will read the last)
    %   * Sections should not be repeated in the config (will read the last)
    %
    % Supported data types:
    %   * numeric scalars and vectors
    %   * logical scalars and vectors
    %   * strings
    %
    %
    % Example:
    %   ini = IniConfig();
    %   ini.ReadFile('example.ini')
    %   ini.ToString()
    %
    % Example:
    %   ini = IniConfig();
    %   ini.ReadFile('example.ini')
    %   sections = ini.GetSections()
    %   [keys, count_keys] = ini.GetKeys(sections{1})
    %   values = ini.GetValues(sections{1}, keys)
    %   new_values(:) = {rand()};
    %   ini.SetValues(sections{1}, keys, new_values)
    %   ini.WriteFile('example1.ini')
    %
    % Example:
    %   ini = IniConfig();
    %   ini.AddSections({'Some Section 1', 'Some Section 2'})
    %   ini.AddKeys('Some Section 1', {'some_key1', 'some_key2'}, {'hello!', [10, 20]})
    %   ini.AddKeys('Some Section 2', 'some_key3', true)
    %   ini.AddKeys('Some Section 2', 'some_key1')
    %   ini.WriteFile('example2.ini')
    %
    % Example:
    %   ini = IniConfig();
    %   ini.AddSections('Some Section 1')
    %   ini.AddKeys('Some Section 1', 'some_key1', 'hello!')
    %   ini.AddKeys('Some Section 1', {'some_key2', 'some_key3'}, {[10, 20], [false, true]})
    %   ini.WriteFile('example31.ini')
    %   ini.RemoveKeys('Some Section 1', {'some_key1', 'some_key3'})
    %   ini.RenameKeys('Some Section 1', 'some_key2', 'renamed_some_key2')
    %   ini.RenameSections('Some Section 1', 'Renamed Section 1')
    %   ini.WriteFile('example32.ini')
    %
    %
    % See also:
    %   textscan, containers.Map
    %
    %
    % Author:         iroln <esp.home@gmail.com>
    % Version:        1.1.2
    % First release:  25.07.09
    % Last revision:  28.12.09
    % Copyright:      (c) 2009 Evgeny Prilepin aka iroln. All rights reserved.
    %
    % Bug reports, questions, etc. can be sent to the e-mail given above.
    %

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    
    properties (GetAccess = 'public', SetAccess = 'private')
        comment_style = ';' % style of comments
        count_sections = 0  % number of sections
        count_all_keys = 0  % number of all keys
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
        config_data_array = {}
        indexes_of_sections
        indexes_of_empty_strings
        
        count_strings = 0
        count_empty_strings = 0
        
        get_keys_param_name = 'AlwaysCellOutput'
        
        is_always_cell_output = false
        is_created_configuration = false
    end
    
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Public Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %------------------------------------------------------------------
        function obj = IniConfig()
            %IniConfig - constructor
            % To Create new object with empty default configuration.
            %
            % Using:
            %   obj = IniConfig()
            %
            % Input:
            %   none
            %
            % Output:
            %   obj - an instance of class IniConfig
            %
            
            obj.CreateIni();
        end
        
        %------------------------------------------------------------------
        function CreateIni(obj)
            %CreateIni - create new empty configuration
            %
            % Using:
            %   CreateIni()
            %
            % Input:
            %   none
            %
            % Output:
            %   none
            %
            
            obj.config_data_array = cell(2,3);
            obj.config_data_array(:,:) = {''};
            
            obj.updateCountStrings();
            obj.updateSectionsInfo()
            obj.updateEmptyStringsInfo()
            
            obj.is_created_configuration = true;
        end
        
        %------------------------------------------------------------------
        function status = ReadFile(obj, filename, comment_style)
            %ReadFile - to read in the object the config data from a INI file
            %
            % Using:
            %   status = ReadFile(filename, comment_style)
            %
            % Input:
            %   filename - INI file name
            %   comment_style - style of comments in INI file
            %
            % Output:
            %   status - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 2)
                error('Not enough input arguments.')
            elseif (nargin == 3)
                obj.comment_style = ValidateCommentStyle(comment_style);
            end
            
            if ~ischar(filename)
                error('Requires string input.')
            else
                % Get data from file
                [file_data, status] = GetDataFromFile(filename);
                
                if (status)
                    obj.count_strings = size(file_data, 1);
                    
                    obj.config_data_array = ParseConfigData(file_data, obj.comment_style);
                    
                    obj.updateSectionsInfo();
                    obj.updateEmptyStringsInfo();
                    obj.updateCountKeysInfo();
                    
                    obj.is_created_configuration = true;
                end
            end
        end
        
        %------------------------------------------------------------------
        function tf = IsSections(obj, section_names)
            %IsSections - determine whether there is a sections
            %
            % Using:
            %   tf = IsSections(section_names)
            %
            % Input:
            %   section_names - name of section(s)
            %
            % Output:
            %   tf - 1 (true) - yes, 0 (false) - no
            %
            
            if (nargin < 2)
                error('Not enough input arguments.')
            end
            
            if (ischar(section_names) || isnumeric(section_names))
                section_names = {section_names};
            end
            
            tf = cellfun(@(x) obj.isSection(x), section_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function [names_sect, count_sect] = GetSections(obj)
            %GetSections - get names of all sections
            %
            % Using:
            %   names_sect = GetSections()
            %   [names_sect, count_sect] = GetSections()
            %
            % Input:
            %   none
            %
            % Output:
            %   names_sect - cell array with the names of sections
            %   count_sect - number of sections in configuration
            %
            
            names_sect = obj.config_data_array(obj.indexes_of_sections, 1);
            count_sect = obj.count_sections;
        end
        
        %------------------------------------------------------------------
        function tf = AddSections(obj, section_names)
            %AddSections - add sections to end configuration
            %
            % Using:
            %   tf = AddSections(section_names)
            %
            % Input:
            %   section_names - name of section
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 2)
                error('Not enough input arguments.')
            end
            
            if (ischar(section_names) || isnumeric(section_names))
                section_names = {section_names};
            end
            
            tf = cellfun(@(x) obj.addSection(x), section_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = InsertSections(obj, positions, section_names)
            %InsertSections - insert sections to given positions
            %
            % Using:
            %   tf = InsertSections(positions, section_names)
            %
            % Input
            %   positions - positions of sections
            %   section_names - names of sections
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(positions) || isnumeric(positions))
                positions = {positions};
            end
            
            if (ischar(section_names) || isnumeric(section_names))
                section_names = {section_names};
            end
            
            if (numel(positions) ~= numel(section_names))
                error('Number of elements in the first and second input arguments must be equal.')
            end
    
            tf = cellfun(@(x, y) obj.insertSection(x, y), positions, section_names, ...
                'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = RemoveSections(obj, section_names)
            %RemoveSections - remove given section
            %
            % Using:
            %   tf = RemoveSections(section_names)
            %
            % Input:
            %   section_names - names of sections
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 2)
                error('Not enough input arguments.')
            end
            
            if (ischar(section_names) || isnumeric(section_names))
                section_names = {section_names};
            end
            
            tf = cellfun(@(x) obj.removeSection(x), section_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = RenameSections(obj, old_section_names, new_section_names)
            %RenameSections - rename given sections
            %
            % Using:
            %   tf = RenameSections(old_section_names, new_section_names)
            %
            % Input:
            %   old_section_names - old names of sections
            %   new_section_names - new names of sections
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(old_section_names) || isnumeric(old_section_names))
                old_section_names = {old_section_names};
            end
            
            if (ischar(new_section_names) || isnumeric(new_section_names))
                new_section_names = {new_section_names};
            end
            
            if (numel(old_section_names) ~= numel(new_section_names))
                error('Number of elements in the first and second input arguments must be equal.')
            end
            
            tf = cellfun(@(x, y) obj.renameSection(x, y), ...
                old_section_names, new_section_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = IsKeys(obj, section_name, key_names)
            %IsKeys - determine whether there is a keys in a given section
            %
            % Using:
            %   tf = IsKeys(section_name, key_names)
            %
            % Input:
            %   key_names - name of keys
            %
            % Output:
            %   tf - 1 (true) - yes, 0 (false) - no
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(key_names) || isnumeric(key_names))
                key_names = {key_names};
            end
            
            section_names = cell(size(key_names));
            section_names(:) = {section_name};
            
            tf = cellfun(@(x, y) obj.isKey(x, y), section_names, key_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function [keys_names, count_keys] = GetKeys(obj, section_name)
            %GetKeys - get names of all keys from given section
            %
            % Using:
            %   keys_names = GetKeys(section_name)
            %   [keys_names, count_keys] = GetKeys(section_name)
            %
            % Input:
            %   section_name - name of section
            %
            % Output:
            %   keys_names - cell array with the names of keys
            %   count_keys - number of keys in given section
            %
            
            if (nargin < 2)
                error('Not enough input arguments.')
            end
            
            section_name = obj.validateSectionName(section_name);
            [keys_indexes, count_keys] = obj.getKeysIndexes(section_name);
            
            if isempty(keys_indexes)
                keys_names = {};
                count_keys = 0;
                return;
            end
            
            keys_names = obj.config_data_array(keys_indexes, 1);
        end
        
        %------------------------------------------------------------------
        function [tf, tf_write_values] = AddKeys(obj, section_name, key_names, key_values)
            %AddKeys - add keys in a end given section
            %
            % Using:
            %   tf = AddKeys(section_name, key_names)
            %   tf = AddKeys(section_name, key_names, key_values)
            %   [tf, tf_write_values] = AddKeys(...)
            %
            % Input:
            %   section_name - name of section
            %   key_names - names of keys
            %   key_values - values of keys (optional)
            %
            % Output:
            %   tf - 1 (true): Success, status - 0 (false): Failed
            %   tf_write_values - 1 (true): Success, status - 0 (false): Failed
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(key_names) || isnumeric(key_names))
                key_names = {key_names};
            end
            
            if (nargin == 3)
                key_values = cell(size(key_names));
                key_values(:) = {''};
            elseif (nargin == 4)
                if (ischar(key_values) || isnumeric(key_values))
                    key_values = {key_values};
                end
            end
            
            if (numel(key_names) ~= numel(key_values))
                error('Number of elements in the second and third input arguments must be equal.')
            end
            
            section_names = cell(size(key_names));
            section_names(:) = {section_name};
            
            [tf, tf_write_values] = cellfun(@(x, y, z) obj.addKey(x, y, z), ...
                section_names, key_names, key_values, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function [tf, tf_write_values] = InsertKeys(obj, section_name, key_positions, key_names, key_values)
            %InsertKeys - insert keys into the specified positions in a given section
            %
            % Using:
            %   tf = InsertKeys(section_name, key_positions, key_names)
            %   tf = InsertKeys(section_name, key_positions, key_names, key_values)
            %   [tf, tf_write_values] = InsertKeys(...)
            %
            % Input:
            %   section_name - name of section
            %   key_positions - positions of keys in section
            %   key_names - names of keys
            %   key_values - values of keys (optional)
            %
            % Output:
            %   tf - 1 (true): Success, status - 0 (false): Failed
            %   tf_write_values - 1 (true): Success, status - 0 (false): Failed
            %
            
            if (nargin < 4)
                error('Not enough input arguments.')
            end
            
            if (ischar(key_positions) || isnumeric(key_positions))
                key_positions = {key_positions};
            end
            
            if (ischar(key_names)  || isnumeric(key_names))
                key_names = {key_names};
            end
            
            if (nargin == 4)
                key_values = cell(size(key_names));
                key_values(:) = {''};
            elseif (nargin == 5)
                if (ischar(key_values)  || isnumeric(key_values))
                    key_values = {key_values};
                end
            end
            
            if (numel(key_positions) ~= numel(key_names))
                error('Number of elements in the second and third input arguments must be equal.')
            end
            
            if (numel(key_names) ~= numel(key_values))
                error('Number of elements in the third and fourth input arguments must be equal.')
            end
            
            section_names = cell(size(key_names));
            section_names(:) = {section_name};
            
            [tf, tf_write_values] = cellfun(@(a, b, c, d) obj.insertKey(a, b, c, d), ...
                section_names, key_positions, key_names, key_values, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = RemoveKeys(obj, section_name, key_names)
            %RemoveKeys - remove the keys from a given section
            %
            % Using:
            %   tf = RemoveKeys(section_name, key_names)
            %
            % Input:
            %   section_name - name of section
            %   key_names - names of keys
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(key_names) || isnumeric(key_names))
                key_names = {key_names};
            end
            
            section_names = cell(size(key_names));
            section_names(:) = {section_name};
            
            tf = cellfun(@(a, b) obj.removeKey(a, b), section_names, key_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function tf = RenameKeys(obj, section_name, old_key_names, new_key_names)
            %RenameKeys - rename the keys in a given section
            %
            % Using:
            %   tf = RenameKeys(section_name, old_key_names, new_key_names)  
            %
            % Input:
            %   section_name - name of section
            %   old_key_names - old names of keys
            %   new_key_names - new names of keys
            %
            % Output:
            %   tf - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 4)
                error('Not enough input arguments.')
            end
            
            if (ischar(old_key_names) || isnumeric(old_key_names))
                old_key_names = {old_key_names};
            end
            
            if (ischar(new_key_names) || isnumeric(new_key_names))
                new_key_names = {new_key_names};
            end
            
            section_names = cell(size(old_key_names));
            section_names(:) = {section_name};
            
            if (numel(old_key_names) ~= numel(new_key_names))
                error('Number of elements in the second and third input arguments must be equal.')
            end
            
            tf = cellfun(@(a, b, c) obj.renameKey(a, b, c), ...
                section_names, old_key_names, new_key_names, 'UniformOutput', 1);
        end
        
        %------------------------------------------------------------------
        function [values, count_read] = GetValues(obj, section_name, keys_names, varargin)
            %GetValues - get values of keys from given section
            %
            % Using:
            %   values = GetValues(section_name, keys_names)
            %   values = GetValues(section_name, keys_names, param_name, param_val)
            %   values = GetValues(section_name, keys_names, default_values)
            %   values = GetValues(section_name, keys_names, default_values, param_name, param_val)
            %   [values, count_read] = GetValues(...)
            %
            % Input:
            %   section_name - name of given section
            %   keys_names - names of given keys
            %
            % Optional Input:
            %   default_values - values of keys that are returned by default
            %   param_name - must be 'AlwaysCellOutput'
            %   param_val - must be 0 or 1
            %
            % Output:
            %   values - cell array with the values of keys
            %   count_read - number of successfully get values
            %
            
            is_unknown_default_values = false;
            
            if (nargin < 3)
                error('Not enough input arguments.')
                
            elseif (nargin == 3)
                is_unknown_default_values = true;
                
                param_name = obj.get_keys_param_name;
                param_val = obj.is_always_cell_output;
                
            elseif (nargin == 4)
                default_values = varargin{1};
                
                param_name = obj.get_keys_param_name;
                param_val = obj.is_always_cell_output;
                
            elseif (nargin == 5)
                is_unknown_default_values = true;
                
                param_name = varargin{1};
                param_val = varargin{2};
                
            elseif (nargin == 6)
                default_values = varargin{1};
                param_name = varargin{2};
                param_val = varargin{3};
            end
            
            if ischar(param_name)
                if strcmpi(obj.get_keys_param_name, param_name)
                    if (param_val == 0 || param_val == 1)
                        is_get_values_always_in_cell = logical(param_val);
                    else
                        error('Param value must be 0 or 1.')
                    end
                else
                    error('Invalid param name: "%s". Must be "%s"', ...
                        param_name, obj.get_keys_param_name)
                end
            else
                error('The method GetValue expects a string "%s".', ...
                    obj.get_keys_param_name)
            end
            
            if is_unknown_default_values
                if iscell(keys_names)
                    count_keys = numel(keys_names);
                elseif ischar(keys_names)
                    count_keys = 1;
                end
                
                if (count_keys == 1)
                    default_values = [];
                else
                    default_values = cell(count_keys, 1);
                end
            end
            
            section_name = obj.validateSectionName(section_name);
            
            [keys_names, default_values] = ...
                ValidateInputsForGetAndSetValues(section_name, ...
                keys_names, default_values);
            
            keys_indexes = obj.getKeysIndexes(section_name);
            
            count_keys = numel(keys_names);
            values = cell(count_keys, 1);
            count_read = 0;
            
            if isempty(keys_indexes)
                values = default_values;
                
                if (length(values) == 1 && ~is_get_values_always_in_cell)
                    values = values{1};
                end
                
                return;
            end
            
            keys_names = strtrim(keys_names);
            keys = obj.config_data_array(keys_indexes, 1);
            vals = obj.config_data_array(keys_indexes, 2);
            
            % Get the names of keys, which are not in the INI file
            % in a given section and specifying this key Defaults
            [not_found_keys, not_found_indexes] = setdiff(keys_names, keys);
            values(not_found_indexes) = default_values(not_found_indexes);
            
            % Getting the names of keys, which is in the INI file in a
            % given section
            [found_keys, found_indexes, found_data_indexes] = intersect(keys_names, keys);
            values(found_indexes) = vals(found_data_indexes);
            count_read = length(found_indexes);
            
            %DEBUG: found_indexes = sort(found_indexes);
            values(found_indexes) = ParseValues(values(found_indexes));
            
            if (length(values) == 1 && ~is_get_values_always_in_cell)
                values = values{1};
            end
        end

        %------------------------------------------------------------------
        function [values, count_read] = GetFloatVector(obj, section_name, keys_names)
            %GetValues - get values of keys from given section without
            %   defaults and check for existance of keys (faster)
            %
            % Using:
            %   values = GetValues(section_name, keys_names)
            %
            % Input:
            %   section_name - name of given section
            %   keys_names - names of given keys
            %
            % Output:
            %   values - cell array with the values of keys
            %   count_read - number of successfully get values
            %
            
            param_name = obj.get_keys_param_name;
            param_val = obj.is_always_cell_output;
                                       
            if iscell(keys_names)
                count_keys = numel(keys_names);
            elseif ischar(keys_names)
                count_keys = 1;
            end
           
            section_name = obj.validateSectionName(section_name);
            
            if ~iscell(keys_names)
                keys_names = {keys_names};
            end
            
            keys_indexes = obj.getKeysIndexes(section_name);
            
            count_keys = numel(keys_names);
            values = cell(count_keys, 1);
            count_read = 0;
            
            if isempty(keys_indexes)
                values = default_values;
                
                if (length(values) == 1)
                    values = values{1};
                end
                
                return;
            end
            
            keys_names = strtrim(keys_names);
            keys = obj.config_data_array(keys_indexes, 1);
            vals = obj.config_data_array(keys_indexes, 2);
                        
            % Getting the names of keys, which is in the INI file in a
            % given section
            [found_keys, found_indexes, found_data_indexes] = intersect(keys_names, keys);
            values(found_indexes) = vals(found_data_indexes);
            count_read = length(found_indexes);
            
            %DEBUG: found_indexes = sort(found_indexes);
            values(found_indexes) = ParseFloatVector(values(found_indexes));
            
            if (length(values) == 1)
                values = values{1};
            end
        end

        %------------------------------------------------------------------
        function [values, count_read] = GetValuesWithoutDefaults(obj, section_name, keys_names)
            %GetValues - get values of keys from given section without
            %   defaults and check for existance of keys (faster)
            %
            % Using:
            %   values = GetValues(section_name, keys_names)
            %
            % Input:
            %   section_name - name of given section
            %   keys_names - names of given keys
            %
            % Output:
            %   values - cell array with the values of keys
            %   count_read - number of successfully get values
            %
            
            param_name = obj.get_keys_param_name;
            param_val = obj.is_always_cell_output;
                                       
            if iscell(keys_names)
                count_keys = numel(keys_names);
            elseif ischar(keys_names)
                count_keys = 1;
            end
           
            section_name = obj.validateSectionName(section_name);
            
            if ~iscell(keys_names)
                keys_names = {keys_names};
            end
            
            keys_indexes = obj.getKeysIndexes(section_name);
            
            count_keys = numel(keys_names);
            values = cell(count_keys, 1);
            count_read = 0;
            
            if isempty(keys_indexes)
                values = [];
                
                return;
            end
            
            keys_names = strtrim(keys_names);
            keys = obj.config_data_array(keys_indexes, 1);
            vals = obj.config_data_array(keys_indexes, 2);
                        
            % Getting the names of keys, which is in the INI file in a
            % given section
            [found_keys, found_indexes, found_data_indexes] = intersect(keys_names, keys);
            values(found_indexes) = vals(found_data_indexes);
            count_read = length(found_indexes);
            
            %DEBUG: found_indexes = sort(found_indexes);
            values(found_indexes) = ParseValues(values(found_indexes));
            
            if (length(values) == 1)
                values = values{1};
            end
        end
        
        %------------------------------------------------------------------
        function count_write = SetValues(obj, section_name, keys_names, values)
            %SetValues - set values for given keys from given section
            %
            % Using:
            %   count_write = SetValues(section_name, keys_names, values)
            %
            % Input:
            %   section_name - name of given section (must be string)
            %   keys_names - names of given keys (must be cell array of strings or string)
            %   values - values of keys (must be cell array or one value)
            %
            % Output:
            %   count_write - number of successfully set values
            %
            
            if (nargin < 4)
                error('Not enough input arguments.')
            end
            
            section_name = obj.validateSectionName(section_name);
            
            [keys_names, values] = ...
                ValidateInputsForGetAndSetValues(section_name, ...
                keys_names, values);
            
            count_keys = numel(keys_names);
            count_write = 0;
            keys_indexes = obj.getKeysIndexes(section_name);
            
            if isempty(keys_indexes)
                return;
            end
            
            [valid_keys, count_valid_keys] = obj.GetKeys(section_name);
            
            if (count_keys > count_valid_keys)
                values = values(1:count_valid_keys);
            end
            
            keys_names = strtrim(keys_names);
            keys = obj.config_data_array(keys_indexes, 1);
            
            % If the key is not unique within the section, it will be
            % processed by the key, which is located the last
            [keys_names, m] = unique(keys_names);
            values = values(m);
            
            [not_found_keys, not_found_indexes] = setdiff(keys_names, keys);
            keys_names_to_add = keys_names(not_found_indexes);
            values_to_add = values(not_found_indexes);
            obj.AddKeys(section_name, keys_names_to_add, values_to_add);
            
            keys_names(not_found_indexes) = [];
            values(not_found_indexes) = [];
            
            [found_keys, found_indexes, found_data_indexes] = intersect(keys_names, keys);
            values(sort(found_indexes)) = values(found_indexes);
            
            % Get string value indices
            str_indexes = cellfun(@(x) ischar(x), values);
            
            % Get numeric value indices
            num_indexes = cellfun(@(x) isnumeric(x), values);
            
            % Get logical value indices
            log_indexes = cellfun(@(x) islogical(x), values);
            
            values(num_indexes | log_indexes) = cellfun(@(x) mat2str(x), ...
                values(num_indexes | log_indexes), 'UniformOutput', 0);
            
            values(~str_indexes & ~num_indexes & ~log_indexes) = [];
            values(str_indexes) = strtrim(values(str_indexes));
            
            values(num_indexes | log_indexes) = ...
                CorrectionNumericArrayStrings(values(num_indexes | log_indexes));
            
            if isempty(values)
                values = {''};
            end
            
            obj.config_data_array(keys_indexes(found_data_indexes), 2) = values;
            count_write = length(values);
        end
        
        %------------------------------------------------------------------
        function varargout = ToString(obj, section_name)
            %ToString - export configuration to string or display
            %
            % Using:
            %   ToString()
            %   ToString(section_name)
            %   str = ToString(...)
            %
            % Input:
            %   section_name - name of sections for export (optional)
            %
            % Output:
            %   str - string with full or section configuration (optional)
            %
            
            if (nargin < 2)
                is_full_export = true;
            else
                section_name = obj.validateSectionName(section_name);
                is_full_export = false;
            end
            
            if is_full_export
                count_str = obj.count_strings;
                indexes = 1:count_str;
            else
                first_index = getSectionIndex(obj, section_name);
                keys_indexes = obj.getKeysIndexes(section_name);
                
                if isempty(keys_indexes)
                    last_index = first_index;
                else
                    last_index = keys_indexes(end);
                end
                
                indexes = first_index:last_index;
            end
            
            indexes_of_sect = obj.indexes_of_sections;
            config_data = obj.config_data_array;
                
            conf_str = sprintf('\n');
                
            for k = indexes
                if isempty(config_data{k,1})
                    if isempty(config_data{k,3})
                        str = sprintf('\n');
                    else
                        comment_str = config_data{k,3};
                        str = sprintf('%s\n', comment_str);
                    end
                    
                elseif ~isempty(indexes_of_sect(indexes_of_sect == k))
                    if isempty(config_data{k,3})
                        section_str = config_data{k,1};
                        
                        str = sprintf('%s\n', section_str);
                    else
                        section_str = config_data{k,1};
                        comment_str = config_data{k,3};
                        
                        str = sprintf('%s    %s\n', section_str, comment_str);
                    end
                    
                elseif ~isempty(config_data{k,1}) && ...
                        isempty(indexes_of_sect(indexes_of_sect == k))
                    if isempty(config_data{k,3})
                        key_str = config_data{k,1};
                        val_str = config_data{k,2};
                        
                        str = sprintf('%s = %s\n', key_str, val_str);
                        
                    else
                        key_str = config_data{k,1};
                        val_str = config_data{k,2};
                        comment_str = config_data{k,3};
                        
                        str = sprintf('%s = %s    %s\n', key_str, val_str, comment_str);
                    end
                end
                
                conf_str = sprintf('%s%s', conf_str, str);
            end
            
            if (nargout == 0)
                fprintf(1, '%s\n', conf_str);
            elseif (nargout == 1)
                varargout{1} = conf_str(2:end);
            else
                error('Too many output arguments.')
            end
        end
        
        %------------------------------------------------------------------
        function status = WriteFile(obj, filename)
            %WriteFile - write to the configuration INI file on disk
            %
            % Using:
            %   status = WriteFile(filename)
            %
            % Input:
            %   filename - name of output INI file
            %
            % Output:
            %   status - 1 (true) - success, 0 (false) - failed
            %
            
            if (nargin < 1)
                error('Not enough input arguments.')
            else
                if ~ischar(filename)
                    error('Requires string input.')
                else
                    fid = fopen(filename, 'wt');
                    
                    if (fid ~= -1)
                        str = obj.ToString();
                        fprintf(fid, '%s', str);
                        
                        fclose(fid);
                        status = true;
                    else
                        status = false;
                        return;
                    end
                end
            end
        end
        
    end % public methods
    
    
    methods (Access = 'private')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %------------------------------------------------------------------
        function num = nameToNumSection(obj, name)
            %nameToNumSection - get number of section
            %
            
            sections = obj.GetSections();
            indexes = find(strcmp(name, sections));
            
            if ~isempty(indexes)
                % If the section is not unique, then choose the latest
                num = indexes(end);
            else
                num = [];
            end
        end
        
        %------------------------------------------------------------------
        function sect_index = getSectionIndex(obj, section_name)
            %getSectionIndex - get index of section in config data
            %
            
            num = obj.nameToNumSection(section_name);
            sect_index = obj.indexes_of_sections(num);
        end
        
        %------------------------------------------------------------------
        function [keys_indexes, count_keys] = getKeysIndexes(obj, section_name)
            %getKeysIndexes - get keys indices from given section
            %
            
            sect_num = obj.nameToNumSection(section_name);
                
            if isempty(sect_num)
                keys_indexes = [];
                count_keys = 0;
                return;
                
            elseif (sect_num == obj.count_sections)
                keys_indexes = ...
                    obj.indexes_of_sections(sect_num)+1:obj.count_strings;
            else
                keys_indexes = ...
                    obj.indexes_of_sections(sect_num)+1:obj.indexes_of_sections(sect_num+1)-1;
            end
            
            indexes_of_empty = obj.indexes_of_empty_strings;
            [i_str, empty_indexes] = intersect(keys_indexes, indexes_of_empty);
            
            keys_indexes(empty_indexes) = [];
            keys_indexes = keys_indexes(:);
            count_keys = length(keys_indexes);
        end
        
        %------------------------------------------------------------------
        function updateSectionsInfo(obj)
            %updateSectionsInfo - update info about sections
            %
            
            keys_data = obj.config_data_array(:,1);
            sect_indexes_cell = regexp(keys_data, '^\[.*\]$');
            obj.indexes_of_sections = find(cellfun(@(x) ~isempty(x), sect_indexes_cell));
            obj.count_sections = length(obj.indexes_of_sections);
        end
        
        %------------------------------------------------------------------
        function updateCountKeysInfo(obj)
            %UpdateCountKeys - update full number of keys
            %
            
            obj.count_all_keys = obj.count_strings - obj.count_sections - obj.count_empty_strings;
        end
        
        %------------------------------------------------------------------
        function updateEmptyStringsInfo(obj)
            %updateEmptyStringsInfo - update info about empty strings
            %
            
            keys_data = obj.config_data_array(:,1);
            indexes_of_empty_cell = strcmp('', keys_data);
            obj.indexes_of_empty_strings = find(indexes_of_empty_cell);
            obj.count_empty_strings = length(obj.indexes_of_empty_strings);
        end
        
        %------------------------------------------------------------------
        function updateCountStrings(obj)
            %updateCountStrings - update full number of sections
            %
            
            obj.count_strings = size(obj.config_data_array, 1);
        end
        
        %------------------------------------------------------------------
        function status = isUniqueKeyName(obj, section_name, key_name)
            %isUniqueKeyName - check whether the name of the key unique
            %
            
            keys = obj.GetKeys(section_name);
            status = ~any(strcmp(key_name, keys));
        end
        
        %------------------------------------------------------------------
        function status = isUniqueSectionName(obj, section_name)
            %isUniqueKeyName - check whether the name of the section a unique
            %
            
            sections = obj.GetSections();
            status = ~any(strcmp(section_name, sections));
        end
        
        %------------------------------------------------------------------
        function status = isSection(obj, section_name)
            %isSection - determine whether there is a section
            %
            
            section_name = obj.validateSectionName(section_name);
            sect_num = obj.nameToNumSection(section_name);
            
            if ~isempty(sect_num)
                status = ~obj.isUniqueSectionName(section_name);
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function section_name = validateSectionName(obj, section_name)
            %validateSectionName - check the name of the section
            %
            
            if (~ischar(section_name) || size(section_name, 1) > 1)
                error('Requires string input for name of section.')
            else
                section_name = strtrim(section_name);

                if isempty(section_name)
                    section_name = [];
                else
                    sect_indexes_cell = regexp(section_name, '^\[.*\]$', 'once');
                    indexes_cell_comment = regexp(section_name, obj.comment_style, 'once');

                    if ~isempty(indexes_cell_comment)
                        section_name = [];
                        return;
                    end

                    if isempty(sect_indexes_cell)
                        section_name = ['[', section_name, ']'];
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function status = addSection(obj, section_name)
            %addSection - add section to end configuration
            %
            
            section_name = obj.validateSectionName(section_name);
            status = obj.insertSection(obj.count_sections+1, section_name);
        end
        
        %------------------------------------------------------------------
        function status = insertSection(obj, pos, section_name)
            %insertSection - insert section to given position
            %
            
            if (nargin < 3)
                error('Not enough input arguments.')
            end
            
            if (ischar(pos) || ~isscalar(pos))
                error('Index must be a scalar.')
            else
                if (pos < 1)
                    error('Index must be a positive integer.')
                elseif (pos > obj.count_sections+1)
                    pos = obj.count_sections+1;
                end
            end
            
            section_name = obj.validateSectionName(section_name);
            
            if ~isempty(section_name)
                is_unique_sect = obj.isUniqueSectionName(section_name);
                if ~is_unique_sect
                    status = false;
                    return;
                end
                
                if (pos <= obj.count_sections && obj.count_sections > 0)
                    sect_ind = obj.indexes_of_sections(pos);
                    
                elseif (pos == 1 && obj.count_sections == 0)
                    sect_ind = 1;
                    obj.config_data_array = {};
                    
                elseif (pos == obj.count_sections+1)
                    sect_ind = obj.count_strings+1;
                end
                
                new_data = cell(2,3);
                new_data(1,:) = {section_name, '', ''};
                new_data(2,:) = {''};
                
                obj.config_data_array = InsertCell(obj.config_data_array, ...
                    sect_ind, new_data);
                
                obj.updateCountStrings();
                obj.updateSectionsInfo();
                obj.updateEmptyStringsInfo();
                
                status = true;
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function status = removeSection(obj, section_name)
            %removeSection - remove given section
            %
            
            section_name = obj.validateSectionName(section_name);
            sect_num = obj.nameToNumSection(section_name);
            
            if ~isempty(sect_num)
                
                if (sect_num < obj.count_sections)
                    first_ind = obj.indexes_of_sections(sect_num);
                    last_ind = obj.indexes_of_sections(sect_num+1)-1;
                    
                elseif (sect_num == obj.count_sections)
                    first_ind = obj.indexes_of_sections(sect_num);
                    last_ind = obj.count_strings;
                end
                
                obj.config_data_array(first_ind:last_ind,:) = [];
                
                obj.updateCountStrings();
                obj.updateSectionsInfo();
                obj.updateEmptyStringsInfo();
                obj.updateCountKeysInfo();
                
                status = true;
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function status = renameSection(obj, old_section_name, new_section_name)
            %renameSection - rename given section
            %
            
            old_section_name = obj.validateSectionName(old_section_name);
            new_section_name = obj.validateSectionName(new_section_name);
            sect_num = obj.nameToNumSection(old_section_name);
            
            if (~isempty(new_section_name) && ~isempty(sect_num))
                sect_ind = obj.indexes_of_sections(sect_num);
                
                obj.config_data_array(sect_ind, 1) = {new_section_name};
                status = true;
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function key_name = validateKeyName(obj, key_name)
            %validateKeyName - check the name of the key
            %

            if (~ischar(key_name) || size(key_name, 1) > 1)
                error('Requires string input for key name.')
            else
                key_name = strtrim(key_name);
                indexes_cell = regexp(key_name, '^\[.*\]$', 'once');
                indexes_cell_comment = regexp(key_name, obj.comment_style, 'once');

                if isempty(key_name) || ~isempty(indexes_cell) || ~isempty(indexes_cell_comment)
                    key_name = [];
                end
            end
        end
        
        %------------------------------------------------------------------
        function status = isKey(obj, section_name, key_name)
            %isKey - determine whether there is a key in a given section
            %
            
            section_name = obj.validateSectionName(section_name);
            key_name = obj.validateKeyName(key_name);
            sect_num = obj.nameToNumSection(section_name);
            
            if (~isempty(sect_num) && ~isempty(key_name))
                status = ~obj.isUniqueKeyName(section_name, key_name);
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function [status, write_value] = addKey(obj, section_name, key_name, key_value)
            %addKey - add key in a end given section
            %
            
            section_name = obj.validateSectionName(section_name);
            [keys_indexes, count_keys] = obj.getKeysIndexes(section_name);
            
            [status, write_value] = obj.insertKey(section_name, count_keys+1, key_name, key_value);
        end
        
        %------------------------------------------------------------------
        function [status, write_value] = insertKey(obj, section_name, key_pos, key_name, key_value)
            %insertKey - insert key into the specified position in a given section
            %
            
            if (ischar(key_pos) || ~isscalar(key_pos))
                error('Index must be a scalar.')
            else
                if (key_pos < 1)
                    error('Index must be a positive integer.')
                end
            end
            
            write_value = 0;
            section_name = obj.validateSectionName(section_name);
            key_name = obj.validateKeyName(key_name);
            sect_num = obj.nameToNumSection(section_name);
            
            if (~isempty(sect_num) && ~isempty(key_name))
                is_unique_key = obj.isUniqueKeyName(section_name, key_name);
                if ~is_unique_key
                    status = false;
                    return;
                end
                
                [keys_indexes, count_keys] = obj.getKeysIndexes(section_name);
                if (count_keys > 0)
                    if (key_pos <= count_keys)
                        insert_index = keys_indexes(key_pos);
                    elseif (key_pos > count_keys)
                        insert_index = keys_indexes(end) + 1;
                    end
                else
                    insert_index = obj.indexes_of_sections(sect_num) + 1;
                end
                
                new_data = {key_name, '', ''};
                
                obj.config_data_array = InsertCell(obj.config_data_array, ...
                    insert_index, new_data);
                
                obj.updateCountStrings();
                obj.updateSectionsInfo();
                obj.updateEmptyStringsInfo();
                obj.updateCountKeysInfo();
                
                if ~isempty(key_value)
                    write_value = obj.SetValues(section_name, key_name, key_value);
                end
                
                status = true;
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function status = removeKey(obj, section_name, key_name)
            %removeKey - remove the key from a given section
            %
            
            section_name = obj.validateSectionName(section_name);
            key_name = obj.validateKeyName(key_name);
            sect_num = obj.nameToNumSection(section_name);
            [keys, count_keys] = obj.GetKeys(section_name);
            
            if (~isempty(sect_num) && ~isempty(key_name) && count_keys > 0)
                is_unique_key = obj.isUniqueKeyName(section_name, key_name);
                if is_unique_key
                    status = false;
                    return;
                end
                
                tf = find(strcmp(key_name, keys), 1, 'last');
                keys_indexes = obj.getKeysIndexes(section_name);
                
                key_index = keys_indexes(tf);
                obj.config_data_array(key_index, :) = [];
                
                obj.updateCountStrings();
                obj.updateSectionsInfo();
                obj.updateEmptyStringsInfo();
                obj.updateCountKeysInfo();
                
                status = true;
            else
                status = false;
            end
        end
        
        %------------------------------------------------------------------
        function status = renameKey(obj, section_name, old_key_name, new_key_name)
            %renameKey - rename the key in a given section
            %
            
            section_name = obj.validateSectionName(section_name);
            old_key_name = obj.validateKeyName(old_key_name);
            new_key_name = obj.validateKeyName(new_key_name);
            sect_num = obj.nameToNumSection(section_name);
            [keys, count_keys] = obj.GetKeys(section_name);
            
            if (~isempty(sect_num) && ~isempty(old_key_name) && ~isempty(new_key_name) && count_keys > 0)
                is_unique_key = obj.isUniqueKeyName(section_name, old_key_name);
                if is_unique_key
                    status = false;
                    return;
                end
                
                tf = find(strcmp(old_key_name, keys), 1, 'last');
                keys_indexes = obj.getKeysIndexes(section_name);
                
                key_index = keys_indexes(tf);
                obj.config_data_array{key_index, 1} = new_key_name;
                
                status = true;
            else
                status = false;
            end
        end
        
    end % private methods
    
end % classdef
%--------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function [file_data, status] = GetDataFromFile(filename)
    %GetDataFromFile - Get data from file
    %
    
    fid = fopen(filename, 'r');
    
    if (fid ~= -1)
%         file_data = textscan(fid, ...
%             '%s', ...
%             'delimiter', '\n', ...
%             'endOfLine', '\r\n', ...
%             'bufsize', 524288);
        
                file_data = textscan(fid, ...
            '%s', ...
            'delimiter', '\n', ...
            'endOfLine', '\r\n');
        
        fclose(fid);
        
        status = true;
        file_data = file_data{1};
    else
        status = false;
        file_data = {};
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function config_data = ParseConfigData(file_data, comment_style)
    %ParseConfigData - parse data from the INI file
    %
    
    % Select the comment in a separate array
    pat = sprintf('^[^%s]+', comment_style);
    comment_data = regexprep(file_data, pat, '');
    
    % Deleting comments
    pat = sprintf('%s.*+$', comment_style);
    file_data = regexprep(file_data, pat, '');
    
    % Select the key value in a separate array
    values_data = regexprep(file_data, '^.[^=]*.', '');
    
    % Select the names of the sections and keys in a separate array
    keys_data = regexprep(file_data, '=.*$', '');
    
    config_data = cell(size(file_data, 1), 3);
    config_data(:,1) = keys_data;
    config_data(:,2) = values_data;
    config_data(:,3) = comment_data;
    config_data = strtrim(config_data);
end
%--------------------------------------------------------------------------

%==========================================================================
function values = ParseValues(values)
    %ParseValues - classify the data types and convert them
    %
    
    start_idx = regexp(values, '^[\-\d\s\,\.\:truefalse]+$');
    number_indexes = cellfun(@(x) ~isempty(x), start_idx);
    
    num_values_strs = values(number_indexes);
%     num_values = cellfun(@(x) str2num(x), num_values_strs, 'UniformOutput', 0);
    num_values = cellfun(@(x) sscanf(x, '%f,')', num_values_strs, 'UniformOutput', 0);
    
    empty_num_indexes = cellfun(@(x) isempty(x), num_values);
    num_values(empty_num_indexes) = num_values_strs(empty_num_indexes);
    values(number_indexes) = num_values;
    
    empty_indexes = cellfun(@(x) isempty(x), values);
    values(empty_indexes) = {[]};
end
%--------------------------------------------------------------------------

%==========================================================================
function values = ParseFloatVector(values)
    %ParseValues - classify the data types and convert them
    %
    
    start_idx = regexp(values, '^[\-\d\s\,\.\:truefalse]+$');
    number_indexes = cellfun(@(x) ~isempty(x), start_idx);
    
    num_values_strs = values(number_indexes);
%     num_values = cellfun(@(x) str2num(x), num_values_strs, 'UniformOutput', 0);
    num_values = cellfun(@(x) sscanf(x, '%f,')', num_values_strs, 'UniformOutput', 0);
    
    empty_num_indexes = cellfun(@(x) isempty(x), num_values);
    num_values(empty_num_indexes) = num_values_strs(empty_num_indexes);
    values(number_indexes) = num_values;
    
    empty_indexes = cellfun(@(x) isempty(x), values);
    values(empty_indexes) = {[]};
end
%--------------------------------------------------------------------------

%==========================================================================
function values = CorrectionNumericArrayStrings(values)
    %CorrectionNumericArrayStrings - correction strings of numeric arrays
    %
    
    values = regexprep(values, '^\[', '');
    values = regexprep(values, '\]$', '');
    values = regexprep(values, '\s', ', ');
end
%--------------------------------------------------------------------------

%==========================================================================
function comment_style = ValidateCommentStyle(comment_style)
    %ValidateCommentStyle - validate style of comments
    %
    
    if ~ischar(comment_style)
        error('Requires char input for comment style.')
    else
        if (length(comment_style) ~= 1)
            error('The style comments should contain the single character')
        end
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function [keys, values] = ValidateInputsForGetAndSetValues(section, keys, values)
    %ValidateInputsForGetAndSetValues - validate input data
    %
    
    if ~ischar(section)
        error('First input argument must be a string.')
    end
    
    if ~ischar(keys) && ~iscellstr(keys)
        error('Second input argument must be a string or cell array of strings_indexes.')
    else
        if ischar(keys)
            keys = {keys};
        end
    end
    
    if ~iscell(values)
        values = {values};
    end
    
    if (numel(keys) ~= numel(values))
        error('Number of elements in the second and third input argument must be equal')
    end
    
    keys = keys(:);
    values = values(:);
end
%--------------------------------------------------------------------------

%==========================================================================
function B = InsertCell(C, i, D)
    %InsertCell - insert a new cell or several cells in a two-dimensional
    % array of cells on the index
    %
    
    [mc, nc] = size(C);
    [md, nd] = size(D);

    j = 1;
    
    mb = mc + md;
    nt = nd - nc + j - 1;
    
    if (nt > 0)
        nb = nc + nt;
    else
        nb = nc;
    end
    
    di = i:i+md-1;
    dj = j:j+nd-1;
    
    B = cell(mb, nb);
    B(di, dj) = D;
    
    if (i <= mc)
        ci = 1:mb;
        ci(di) = [];
    else
        ci = 1:mc;
    end
    
    cj = 1:nc;
    B(ci, cj) = C;
end
%--------------------------------------------------------------------------

