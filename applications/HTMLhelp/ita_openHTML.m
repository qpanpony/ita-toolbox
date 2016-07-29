function [data_begin, data_end] = ita_openHTML(file)
%ITA_OPENHTML - helpfunction for ita_generate_helpOverview.
%opens File and searches specific strings to get 2 parts of the file, see implementation
%
%   See also ita_generate_helpOverview

% <ITA-Toolbox>
% This file is part of the application HTMLhelp for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

%
% Author: Jonas Tumbrägel -- Email: jonas.tumbraegel@akustik.rwth-aachen.de
% Created:  18-May-2012

data_searchStringBEG='<!-- DO NOT DELETE ME! MATLAB CODE INSERT POINT BEGINN -->';
data_searchStringEND='<!-- DO NOT DELETE ME! MATLAB CODE INSERT POINT END -->';
data_ID = fopen(file,'r'); %r read only
data = fread(data_ID, 'uint8=>char');
fclose(data_ID);
data = data(:)'; %get class.html as string
data_posBEG = strfind(data,data_searchStringBEG);
data_posEND = strfind(data,data_searchStringEND);

data_begin = data(1:data_posBEG+length(data_searchStringBEG)); %code before insertpoint
data_end = data(data_posEND:end); %code after insertpoint
end