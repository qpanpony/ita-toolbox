function test_ita_isincellstr()
%Tests a few cases for isincellstr
%
% RSC - 15 Jan 2009 - created

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if isincellstr('test',{'test1','allesgela'});
    error('isincellstr: false return');
end
if ~isincellstr('test',{'test1','allesgela'},'substring');
    error('isincellstr: false return');
end
if ~isincellstr({'test','alles'},{'test1','allesgela'},'substring');
    error('isincellstr: false return');
end
if ~isincellstr({'test','aleles'},{'test1','allesgela'},'substring','any');
    error('isincellstr: false return');
end
if isincellstr({'test','aleles'},{'test1','allesgela'},'substring');
    error('isincellstr: false return');
end
if isincellstr({'Test'},{'test','allesgela'},'substring','casesensitive');
    error('isincellstr: false return');
end
if ~isincellstr({'Test'},{'test','allesgela'},'substring','casesensitive',false);
    error('isincellstr: false return');
end


end