function ita_verbose_obsolete(mesg)
% show a nice message/warning for obsolete functions
% ita_verbose_obsolete(mesg)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


x = dbstack;
if numel(x) < 3
    name = 'workspace';
    line = 0;
else
    name = x(3).name;
    line = x(3).line;
end
    
fname = x(2).name;

if usejava('jvm') && exist('cdisp','file')
    
    niceColor = [.5 .2 .8];
    cdisp(niceColor,'*******************************************************************')
    cdisp(niceColor,['Function **  ' fname ' ** is obsolete!'])
    cdisp(niceColor,['Function called in Line: ' num2str(line) ' in function ' name ]);
    
    if exist('mesg','var')
        cdisp(niceColor,mesg);
    end
    
    cdisp(niceColor,'*******************************************************************')
else
    disp('*******************************************************************');
    disp(['Function **  ' fname ' ** is obsolete!']);
    disp(['Function called in Line: ' num2str(line) ' in function ' name ]);
    
    if exist('mesg','var')
        disp(mesg);
    end
    
    disp('*******************************************************************');
end

end