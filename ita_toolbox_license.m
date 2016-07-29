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
disp(['*** This License can be found at ' ita_toolbox_path filesep 'license.txt ***' ])
fprintf(2,'********************************************************************************\n')

%% ask
if usejava('desktop') %Only if jvm available (non_cluster)
    commandwindow();
    choice = questdlg('Do you agree to the terms of the license agreement? A text file with this License Information is located at the root of the ITA-Toolbox folder called license.txt','License Agreement - ITA-Toolbox:', ...
        'Yes','No','No');
    switch lower(choice)
        case 'yes'
            fprintf(2,'You have agreed to the license agreement of ITA-Toolbox for MATLAB\n');
        case 'no'
            fprintf(2,'You have NOT agreed to the license agreement of ITA-Toolbox for MATLAB\n');
            error('License Agreement not accepted.')
    end
end

%% set accepted flag in preferences
ita_preferences('license',true);

%%
% tmphandle = figure;
% axis([0 180 0 150]);axis('off')
% set(tmphandle,'Position',[100 100 1000 700 ],'NumberTitle','off','Name','ITA Toolbox License')
% text(70,150,'ITA Toolbox   Shortcuts','FontName','Arial Black','FontSize',13)
% % for counter = 1:numel(ShortCutList)
% counter = 1;
% text(3,0*counter,funcTemplate,'FontName','Courier')
% % end