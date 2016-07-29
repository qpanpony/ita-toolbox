function ita_licensefile_write(filename,userinfo)
% Write license file
% Usage: ita_licensefile_write(filename,userinfo)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Open file
fid = fopen(filename,'w'); 

%% Write every field to file
fieldnames = fields(userinfo);
for idx = 1:numel(fieldnames)
   fprintf(fid, '%s\n' ,[fieldnames{idx} ': ' userinfo.(fieldnames{idx}) ]);
end

fclose(fid);
end