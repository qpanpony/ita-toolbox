function data_old = ita_toolbox_version_number(vernum)
% return the number of the current version of the ITA-Toolbox

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


folder = fileparts(which(mfilename));
% read old/current version number from file
fid      = fopen([folder filesep 'itaToolboxVersionStatus']);
data     = fread(fid);
fclose(fid);
data_old = native2unicode(data,'UTF-8')'; %#ok<N2UNI>
data_old = str2double(data_old);

if nargin == 1
    data = unicode2native(num2str(vernum),'UTF-8');
    fid = fopen([folder filesep 'itaToolboxVersionStatus'],'w');
    fwrite(fid,data);
    fclose(fid);
    nChar = 100;
    ita_disp(nChar);
    ita_disp(nChar,['Toolbox Version set from ' num2str(data_old) ' to ' data '.']);
    ita_disp(nChar);
    
    data_old = vernum;
end


end