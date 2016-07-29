%% audio data arrives in the variable 'data'

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

data;

%% process data
data = ita_extract_dat(data,14);
data = 0.2 * data;

% your code comes in here...

%% audio data leaves in the variable 'data'
data; 