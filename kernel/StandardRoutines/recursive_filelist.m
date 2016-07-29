function filelist = recursive_filelist(path, filter,modulus)
%Create recursive file list, using filter and modulus
%
% Call fileList = recursive_filelist(startpath,filter)
% Call fileList = recursive_filelist(startpath,filter,modulus) 
%        For VxxxHxxx- files, can read only 5Deg-steps... 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



if ~exist('modulus','var')
    modulus = [];
end
% Find subdirs
list = dir(path);
filelist = {};
for idx = 1:numel(list)
    if list(idx).isdir && ~strcmpi(list(idx).name(1),'.')
        filelist = [filelist recursive_filelist([path filesep list(idx).name],filter,modulus)]; %#ok<AGROW> %Recursive calling for subdirs
    end
end

% Add files from current dir
list = dir([path filesep filter]);
for idx = 1:numel(list)
    if ~list(idx).isdir
        if isempty(modulus)
            rest = 0;
        else
            V = str2double(list(idx).name(end-10:end-8));
            H = str2double(list(idx).name(end-6:end-4));
            rest = mod(V,modulus) + mod(H,modulus);
        end
        if rest == 0
            filename = [path filesep list(idx).name]; %Full path filename
            filelist = [filelist {filename}]; %#ok<AGROW>
        end
    end
end
end