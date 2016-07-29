function res = ita_playrec_show_strings(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


folder = fileparts(which('playrec'));
if isempty(folder)
    res = 1; 
    return;
end
a = dir([folder filesep 'playrec*' mexext]);
res = [];
for idx = 1:numel(a)
    res  = [res  a(idx).name '|']; %#ok<AGROW>
end
if ~isempty(res)
    res = res(1:end-1);
end

if nargin == 1
   [pathh, res, ext] = fileparts(a(varargin{1}).name); 
   res = eval(['@' res]);
end

end