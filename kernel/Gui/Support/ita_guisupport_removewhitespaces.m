function out = ita_guisupport_removewhitespaces(varargin)
% Remove white spaces from strings
%
% Call: string = ita_guisupport_removewhitespaces(string)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


narginchk(1,1);
out = varargin{1};
if iscell(out)
    for idx = 1:numel(out)
        out{idx} = ita_guisupport_removewhitespaces(out{idx});
    end
    return
else
    out = strrep(out,'-','_');
    idx = find(out == ' ');
    idx(idx+1 > length(out)) = [];
    out(idx+1) = upper(out(idx+1));
    
    out = out(isstrprop(out,'alphanum')|out=='_');
end
end