function varargout = ita_toolbox_setup(varargin)
%ITA_TOOLBOX_SETUP - Setup paths for ITA Toolbox
%  This function sets all paths in the RWTH ITA Toolbox folder
%
%  Call: ita_toolbox_setup
%
%   See also ita_toolbox_documentation.

%   Reference page in Help browser
%      <a href="matlab:doc ita_toolbox_setup">doc ita_toolbox_setup</a>
%
% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25 Aug 2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


warning off
close all
clc

%% Check for MATLAB Version, R2008a or higher
if verLessThan('matlab','7.6')
    h = errordlg('MATLAB Version Check...', 'Your MATLAB Version is too old. Please install R2008a or higher.');
    uiwait(h)
    disp('Toolbox Setup stopped.')
    return;
end

%%
v = ver;
signalfound = false;
for k = 1:length(v)
    if strfind(v(k).Name, 'Signal Processing Toolbox')
        signalfound = true;
        disp(sprintf('%s, Version %s', v(k).Name, v(k).Version)) %#ok<*DSPS>
    end
end
if ~signalfound
    fprintf(2,'********************************************************************************\n') %#ok<*PRTCAL>
    fprintf(2,'************* You have to install Signal Processing Toolbox ! ******************\n')
    fprintf(2,'********************************************************************************\n')
end

%% Get root of RWTH-ITA-Toolbox
tb_setup_path = which('ita_toolbox_setup.m');
tb_base_path = fileparts(tb_setup_path);

%% Add path to kernel, so basic functions are available
addpath(tb_base_path);
addpath([tb_base_path, filesep, 'kernel']);

%% Add userpath, here might be our pathdef.m
addpath(userpath);

%% ITA-Toolbox path handling
% this function has to be in the kernel directory!
ita_path_handling();

%% License and Key?
if usejava('desktop') %Only if desktop available (non_cluster) (mpo 5.8.11)
    if ~ita_preferences('license')
        ita_toolbox_license();
    end
end

%% Update lastToolboxVersionNumber date to now
ita_preferences('lastToolboxSetupVerNum',ita_toolbox_version_number());

%% Preferences GUI
% First clean preferences
prefs = ita_preferences(); % Get current prefs
ita_preferences('reset');  % Delete all preferences
ita_preferences(prefs);    % Set all prefs, non-existing ones will be ignored

%% WIN64 and no ASIO sound cards
if strcmpi(mexext,'mexw64')
    % check for sound card list
    [~, devIDsIn, ~, devIDsOut] = ita_portaudio_menuStr();
    if numel(devIDsIn) == 1 && numel(devIDsOut) == 1 && ita_preferences('playrec') > 0
        ita_preferences('playrec',mod(ita_preferences('playrec'),2)+1);
        ccx
        ccx
        disp('Trying different playrec MEX-file to find sound cards...')
        pause(0.5)
        % search with alternative playrec mex-file
        [~, devIDsIn, ~, devIDsOut] = ita_portaudio_menuStr();
        if numel(devIDsIn) == 1 && numel(devIDsOut) == 1 && ita_preferences('playrec') > 0
            ita_preferences('playrec',mod(ita_preferences('playrec'),2)+1);
            ccx
            ccx
            disp('NO sound cards detected!');
        end
    end
end

%% build search database
% Temporarily disabled due to builddocsearchdb in 2014b and newer
% if ~exist([ita_toolbox_path filesep 'HTML' filesep 'helpsearch'],'dir')
%     builddocsearchdb( [ita_toolbox_path filesep 'HTML' ] ); %generate help search
%     rehash toolboxcache
% end

%% start third party APIs
% if ~exist([ita_toolbox_path filesep 'external_packages' filesep 'sofa' filesep 'API_MO' filesep 'conventions' filesep 'GeneralFIR-a.mat' ],'file')
%     disp('Installing SOFA conventions (external module):');
%     ;
% end

%% clean up old filters
ita_delete_filter();

%% Then show gui
if usejava('desktop') %Only if desktop available (non_cluster)
    %     ita_preferences();
    ita_disp()
    disp('<a  href="matlab:ita_preferences"> Click here to start with basic settings ''ita_preferences()'' -configure soundcard...</a>')
    ita_disp()
    disp('<a  href="matlab:ita_preferences(''reset'')"> Click here to reset the basic settings to defaults ''ita_preferences(''reset'')'' ...</a>')
end

%% find output
if nargout > 0
    varargout{1} = 1;
else
    ita_disp()
    disp('<a href="matlab:ita_toolbox_gui"> Click here to start with a GUI ''ita_toolbox_gui()'' to start working...</a>')
    ita_disp()
    disp('<a href="matlab:edit ita_tutorial"> Click here to start with a Tutorial script ''ita_tutorial()''</a>')
    ita_disp()
    disp('<a href="matlab:ita_generate_documentation"> Click here to build the HTML documentation ''ita_generate_documentation()''</a>')
end
ita_disp()

end
