%ccx - Tidy up everything
% This script tidies up all open figure, all variables except for the
% standard working directory setting used in open/write file GUIs.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de - 2007

try %#ok<TRYNC>
    dbquit all
end
warning off %#ok<WNOFF>
clear classes %RSC - needed to clean class references in case of changes
clear global %RSC - needed to clean up global variables from preferences or mpb_filter and free memory
clear java %RSC - reduces trouble with figures 

if usejava('jvm') %Only if jvm available (non_cluster)
s_obj = instrfind();
if ~isempty(s_obj)
   for idx = 1:length(s_obj)
        if strcmpi(s_obj(idx),'closed')
            
        elseif strcmpi(s_obj(idx),'open')
            fclose(s_obj(idx));
        end
        disp(['   deleting: ' s_obj(idx).Name '...']);
        delete(s_obj(idx));
   end
end
end

if exist('playrec','file')
   if playrec('isInitialised') 
      playrec('reset'); 
   end
end

fclose all;
close all
close all hidden

clear all

%% JAVA
% heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory/1024/1024;
% heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory/1024/1024;
if usejava('jvm') % bugfix mpo
    java.lang.Runtime.getRuntime.gc; %clear java heap space
end

clc
warning on %#ok<WNON>
warning off MATLAB:log:logOfZero 
warning off MATLAB:pfileOlderThanMfile
