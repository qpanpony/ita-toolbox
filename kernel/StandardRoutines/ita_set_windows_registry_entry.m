function ita_set_windows_registry_entry(varargin)
%ITA_SET_WINDOWS_REGISTRY_ENTRY - Set MS Windows Registry for ITA Toolbox
%  This function generates a registry file and excetues this to
%  set the ITA formats (.ita,.spk,.dat) to be opened directly with Matlab.
%
%  This is only used on MS Windows platforms
%
%  Syntax: ita_set_windows_registry_entry()
%
%   See also ita_read, ita_remove_registry_entry.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_set_windows_registry_entry">doc ita_set_windows_registry_entry</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Sep-2008 


%% Initialization
% Number of Input Arguments
narginchk(0,0);
if ~ispc
    disp('this only works for Windows Systems.')
    return;
end

robo_path     = which('ITA16x16.ico'); %path for icon file
robo_path     = strrep(robo_path,'\','\\');
txt_file_path = which('ita_toolbox_format.txt');
reg_file_path = [txt_file_path(1:end-3) 'reg'];

%% find out if user has admin priveledges
try
    data    = System.Security.Principal.WindowsIdentity.GetCurrent();
    data    = System.Security.Principal.WindowsPrincipal(data);
    isAdmin = data.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
catch %#ok<CTCH>
    isAdmin = false;
end
if ~isAdmin
    disp('You have no administrator priveledges, no registry entry set. The ITA-Toolbox will still work')
    return;
end

%% open file
fid      = fopen(txt_file_path);
funCode  = fread(fid, 'uint8=>char');
funCode  = funCode(:)';
fclose(fid);

%% String replacement      
funCode = strrep(funCode, 'ROBO_CONTROL_CENTER_PATH', robo_path);

%% convert
funCode = native2unicode(funCode,'latin3');
funCode = funCode(4:end);

%% Write file
fid = fopen(reg_file_path , 'w' );
fwrite( fid, funCode,'char');
fclose( fid );

%% Call Reg File
try
    system(reg_file_path)
end

%end function
end