function test_ita_all(varargin)
%ITA_TEST_ALL - Test for the ita toolbox
%  runs all funktions called test_ita_* to find any error within the toolbox
%  you dont need to change anything in here, all test_ita_ routines will be found automatically
%
%  Call: test_ita_all(Options)
%
%       Options:
%           'kernel' [false] - Check only kernel functions, no applications
%
%   See also  ita_sqrt, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers.
%
%   Reference page in Help browser
%        <a href="matlab:doc test_ita_all">doc test_ita_all</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  15-Jan-2009

%% get the path information

sArgs = struct('kernel',false);
sArgs = ita_parse_arguments(sArgs,varargin);


filename_workspace = 'workspace_tmp.mat';
test_path = which('test_ita_all.m'); %Find the test directory
ind = strfind(test_path,'test_ita_all.m');
test_path(ind-1:end) = []; %Remove filename from path

% save all variables in a temp file
save([test_path filesep filename_workspace]); 
% clear everythin including the class definition
% ccx; 
clear classes;

% as we cleared all variables we have to look again for the path
filename_workspace = 'workspace_tmp.mat';
test_path = which('test_ita_all.m'); %Find the test directory
ind = strfind(test_path,'test_ita_all.m');
test_path(ind-1:end) = []; %Remove filename from path
load([test_path filesep filename_workspace]); % restore arguments


tic;
disp('********************************************************************')
disp('********************* TESTING ITA TOOLBOX **************************')
disp('********************************************************************')

%old_path = cd; %Save old working directory
%cd(test_path); %Change directory to the test directory

%test_files = dir('*test_*.m'); %Find all files with *test_*
if sArgs.kernel
    test_files = rdir([ita_toolbox_path filesep 'Debug' filesep '**' filesep 'test_ita_*.m']); % Recursive find of all files with 'test_ita_*.m'
else
    test_files = rdir([ita_toolbox_path filesep '**' filesep 'test_ita_*.m']); % Recursive find of all files with 'test_ita_*.m'
end

errors = {};
tic;
for test_number = 1:length(test_files)
    functionname = strtok(fliplr(strtok(fliplr(test_files(test_number).name),filesep)),'.'); %Find the function name in the filename (everything bevor the first '.')

    if ~strcmp(functionname,'test_ita_all') %Exclude test_ita_all
        disp(['Testing: ' functionname '...'])
        try
            feval(functionname); %Run the test function
        catch ME
            ME_test = MException('test_ita_all:error', [functionname ' returned the above error(s)']);
            ME = addCause(ME,ME_test);
            errors(end+1) = {ME}; %Get all errors first, we can deal with them later
        end
    end

end

toc;
% cd(old_path); %Restore old working directory
% restore old workspace variables
load([test_path filesep filename_workspace]);
delete([test_path filesep filename_workspace]);

disp('********************************************************************')
if ~isempty(errors)
    fprintf(2,'The following errors occured:\n');
    for i = 1:length(errors)
        ita_verbose_info('********************************************************************',0);
        ita_verbose_info(getReport(errors{i}),0);
        ita_verbose_info('********************************************************************',0);
    end
else
    disp('Congratulations! No Errors occurred!');
    disp(['Test took ' num2str(toc,3) ' sec']);
end

commandwindow()



end