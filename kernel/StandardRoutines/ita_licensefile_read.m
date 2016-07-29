function userinfo = ita_licensefile_read(filename)
% Returns info on the user, read from the license file. licensefile can be specified or will be found automatic

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Read file
if nargin == 1 % Filename given

elseif nargin == 0 % Find License automatically
   filename = rdir([ita_toolbox_path filesep 'Licenses' filesep '**' filesep 'License*.txt'] );
   
   if numel(filename) > 1
      ita_verbose_info('!!! More than one license found !!!',0);
      ita_verbose_info('!!! Using first one found       !!!',0);
      filename = filename(1);
   end
   
   if numel(filename) == 0
       ita_verbose_info(' No license found ',1); % ToDo: Increase verbose level after everything is checked
       userinfo = struct();
       return;
   end
   
   filename = filename.name;
   
end

fid = fopen(filename); 
uinfo = textscan(fid, '%s%[^\n]'); 
fclose(fid);

%% Add empty passphrase if passphrase is empty
while size(uinfo{2},1) < size(uinfo{1},1)
    uinfo{2} = [uinfo{2}; {''}];
end

%% Merge fielnames and values, replacing ':' with '' on occurence
userinfo = cell2struct(uinfo{2}, strrep(uinfo{1},':',''));

%% Add missing fields
if ~isfield(userinfo,'Comment')
    userinfo.Comment = '';
end

end