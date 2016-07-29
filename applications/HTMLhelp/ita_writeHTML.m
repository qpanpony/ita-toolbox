function ita_writeHTML(file, content)
%ITA_WRITEHTML - helpfunction for ita_generate_helpOverview.
%(over)writes string into file, see implementation
% -->ita_writeHTML(fileDestination, string)
% Example: ita_writeHTML('C:\Users\HansPeter\Desktop\myFile.txt','Hello World')
%   See also ita_generate_helpOverview

% <ITA-Toolbox>
% This file is part of the application HTMLhelp for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

%
% Author: Jonas Tumbrägel -- Email: jonas.tumbraegel@akustik.rwth-aachen.de
% Created:  18-May-2012

file_ID = fopen(file,'w');%write rights
fwrite(file_ID, content, 'char');
fclose(file_ID);
end