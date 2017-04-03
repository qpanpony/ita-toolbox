function itamenu = ita_guimenuentries(varargin)
%ITA_GUISUPPORT_MENULIST - Create menu-entries
%   This function creates a list of ita_menu entries, as used in ita_menu
%   Additionally, this function will search and call all functions starting with 'ita_guimenuentries_'
%   Menu-entries for applications should go into the applications folder itself, so they will only appear when the application itself is available
%   Examples e.g. in ita_guimenuentries_roomacoustics 
%
% Syntax for entries:
%       itamenu{idx}.type - submenu or function
%       itamenu{idx}.text - Text that will be displayed in the menu
%       itamenu{idx}.parent - submenu the entrie should go into ( the .text entrie of the parent is correct)
%       itamenu{idx}.accelerator - Hotkey for the function
%       itamenu{idx}.seperator - true/false, inserts a seperator line above the entry
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_guimenuentries">doc ita_guimenuentries</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009


%% Initialization and Input Parsing


%% Cache result (faster)
persistent itamenu_cache

if isempty(itamenu_cache)    
    %% ITA
    idx = 1;
    itamenu{idx}.type = 'submenu';
    itamenu{idx}.text = 'ITA';
    itamenu{idx}.accelerator = 'I';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Read';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = 'O';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Write';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = 'S';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Preferences';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = ',';
    itamenu{idx}.separator = true;
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Save this plot (GLE)';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = '';
    itamenu{idx}.separator = true;
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Save this plot';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Close';
    itamenu{idx}.parent = 'ITA';
    itamenu{idx}.accelerator = 'C';
    itamenu{idx}.separator = true;
    
    % %% View % ToDo - not working yet
    % if sArgs.domain
    %     idx = idx+1;
    %     itamenu{idx}.type = 'submenu';
    %     itamenu{idx}.text = 'View';
    %     itamenu{idx}.parent = '';
    %     itamenu{idx}.accelerator = '';
    %
    %     idx = idx+1;
    %     itamenu{idx}.type = 'function';
    %     itamenu{idx}.text = 'Remember window position';
    %     itamenu{idx}.parent = 'View';
    %     itamenu{idx}.accelerator = '';
    % end
    
    %% Workspace, List of variables, (will be created by ita_menu)
    idx = idx+1;
    itamenu{idx}.type           = 'varlist';
    itamenu{idx}.text           = 'Workspace';
    itamenu{idx}.parent         = '';
    itamenu{idx}.accelerator    = '';
    
% % %     idx = idx+1;
% % %     itamenu{idx}.type           = 'function';
% % %     itamenu{idx}.text           = 'Delete Current Object';
% % %     itamenu{idx}.parent         = 'Workspace';
% % %     itamenu{idx}.accelerator    = '';
% % %     
    %% Domain - Now with Accelerators (defined in ita_guisupport_domainlist)
    idx = idx+1;
    itamenu{idx}.type = 'domainlist'; % edit ita_guisupport_domainlist.m for details
    itamenu{idx}.text = 'Domain';
    itamenu{idx}.parent = '';
    itamenu{idx}.accelerator = '';
    
    %% Edit
    idx = idx+1;
    itamenu{idx}.type           = 'submenu';
    itamenu{idx}.text           = 'Edit';
    
    idx = idx+1;
    itamenu{idx}.type           = 'submenu';
    itamenu{idx}.text           = 'MetaInfo';
    itamenu{idx}.parent         = 'Edit';
     
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Channel Settings';
    itamenu{idx}.parent         = 'MetaInfo';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Remove Channel Settings';
    itamenu{idx}.parent         = 'MetaInfo';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Clear History';
    itamenu{idx}.parent         = 'MetaInfo';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Merge';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Split';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Generate';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = '';
        itamenu{idx}.separator      = true;

    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Generate Sweep';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Window';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = 'N';
        itamenu{idx}.separator      = true;

    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Time Shift';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
        idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Time Crop';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
     idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Normalize';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
            itamenu{idx}.separator      = true;

    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Amplify';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Add';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = 'A';
    itamenu{idx}.separator      = true;
    
    idx = idx+1;
    itamenu{idx}.type           = 'function';
    itamenu{idx}.text           = 'Subtract';
    itamenu{idx}.parent         = 'Edit';
    itamenu{idx}.accelerator    = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Divide Spectrum';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Multiply Spectrum';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Multiply Time';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
   
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Complex cepstrum';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    itamenu{idx}.separator = true;

    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Inverse complex cepstrum';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
        
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Minimumphase';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Zerophase';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Resample';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    itamenu{idx}.separator = true;
   
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Quantize';
    itamenu{idx}.parent = 'Edit';
    itamenu{idx}.accelerator = '';
    
 %% Filtering
    idx = idx+1;
    itamenu{idx}.type   = 'submenu';
    itamenu{idx}.text   = 'Filtering';
    itamenu{idx}.parent = '';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Fractional Octave Bands';
    itamenu{idx}.parent = 'Filtering';
    %itamenu{idx}.separator = true;
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Bandpassfiltering';
    itamenu{idx}.parent = 'Filtering';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Peak Filter';
    itamenu{idx}.parent = 'Filtering';
    
    itamenu{idx}.separator = true;
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'A-Weighting';
    itamenu{idx}.parent = 'Filtering';
    itamenu{idx}.separator = true;
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'C-Weighting';
    itamenu{idx}.parent = 'Filtering';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Fractional Octave Band Levels';
    itamenu{idx}.parent = 'Filtering';
    
    % Coming soon
    % Jens-Kristian Mende Mai 2011
    
    % idx = idx+1;
    % itamenu{idx}.type   = 'function';
    % itamenu{idx}.text   = 'Shelving';
    % itamenu{idx}.parent = 'Filtering';
    % %itamenu{idx}.separator = true
    %
    % idx = idx+1;
    % itamenu{idx}.type   = 'function';
    % itamenu{idx}.text   = 'Parametric EQ';
    % itamenu{idx}.parent = 'Filtering';
    
    %% Applications (there should be nothing in here, application entries go into their directories
    idx = idx+1;
    itamenu{idx}.type   = 'submenu';
    itamenu{idx}.text   = 'Applications';
    itamenu{idx}.parent = '';
    
    
    %% Tools
    idx = idx+1;
    itamenu{idx}.type = 'submenu';
    itamenu{idx}.text = 'Tools';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Simple Playback and Record';
    itamenu{idx}.parent = 'Tools';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Listen (DA only)';
    itamenu{idx}.parent = 'Tools';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Input Channel Monitor';
    itamenu{idx}.parent = 'Tools';
    
    idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Frequency Generator';
    itamenu{idx}.parent = 'Tools';
    
        idx = idx+1;
    itamenu{idx}.type   = 'function';
    itamenu{idx}.text   = 'Batch Processor';
    itamenu{idx}.parent = 'Tools';
    
    
    %% Help
    idx = idx+1;
    itamenu{idx}.type = 'submenu';
    itamenu{idx}.text = 'Help';
    itamenu{idx}.parent = '';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Show Shortcuts';
    itamenu{idx}.parent = 'Help';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Open ITA-Toolbox Website';
    itamenu{idx}.parent = 'Help';
    
        idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Open Tutorial.m';
    itamenu{idx}.parent = 'Help';
    
            idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Open Tutorial.m HTML';
    itamenu{idx}.parent = 'Help';
    
    idx = idx+1;
    itamenu{idx}.type = 'function';
    itamenu{idx}.text = 'Show Help';
    itamenu{idx}.parent = 'Help';
    
    %% Search for more ita_guimenuentries and call them
    guifiles = rdir([ita_toolbox_path filesep '**' filesep 'ita_guimenuentries_*.m']);
    for idgui = 1:numel(guifiles)
        functionname = strtok(fliplr(strtok(fliplr(guifiles(idgui).name),filesep)),'.');    %Get function name without path (feval wont work with full path?)
        itamenu = [itamenu feval(functionname)];                                 %#ok<AGROW> % Call function
    end
    itamenu_cache = itamenu;
else
    itamenu = itamenu_cache;
end

%% init all entries to not valid - pdi
for idx = 1:numel(itamenu)
   itamenu{idx}.valid = false; 
end
end