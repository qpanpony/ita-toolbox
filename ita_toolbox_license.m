%% Show the license and its location;

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


fid = fopen([ita_toolbox_path filesep 'license.txt']);
funcTemplate = fread(fid, 'uint8=>char')';
disp(funcTemplate(1:end-1))
fclose(fid);
fprintf(2,'********************************************************************************\n')
disp(['*** The license can be found at ' ita_toolbox_path filesep 'license.txt ***' ])
fprintf(2,'********************************************************************************\n')

%% ask
if usejava('desktop') %Only if jvm available (non_cluster)
    commandwindow();
    choice = questdlg('Do you agree to the terms of the license agreement? The complete license ("license.txt") can be found in the root directory of the ITA-Toolbox.','License Agreement - ITA-Toolbox:', ...
        'Yes','No','No');
    switch lower(choice)
        case 'yes'
            fprintf(2,'You accepted the ITA-Toolbox license agreement\n');
        case 'no'
            fprintf(2,'You did NOT accept to the ITA-Toolbox license agreement\n');
            error('License Agreement not accepted.')
    end
end

%% set accepted flag in preferences
ita_preferences('license',true);
