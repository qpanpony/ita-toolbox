function ita_disp(numChars, textstr)
% nice function to display formatted lines in the console

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if ~exist('textstr','var')
    textstr = '';
end

if nargin == 0;
    numChars = ita_preferences('nchars');
end
if nargin == 1 && length(numChars) >= 1 && ischar(numChars)
   textstr = numChars;
   numChars = ita_preferences('nchars');
end
if isnumeric(textstr)
   textstr = num2str(textstr); 
end
starChar = '*';
preStars = 3;

outStr = repmat(starChar,1,numChars);

if exist('textstr','var') && numel(textstr)>0
    outStr(preStars+1) = ' ';
outStr(preStars+1+(1:length(textstr))) = textstr;
outStr(preStars + 2 + length(textstr)) = ' ';
end


%% show output
disp(outStr)