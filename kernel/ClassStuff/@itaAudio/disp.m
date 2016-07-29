function disp(this)
%show the Obj

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if ita_preferences('nakedClasses')
    builtin('disp',this)
else
    disp@itaSuper(this)
    sr = [num2str(this.samplingRate,5) ' Hz'];
    sr = [sr repmat(' ',1,8-numel(sr))];
    disp(['      samplingRate  = ' sr '  (signalType = ' this.signalType ')'])
    trackLength = num2str(itaValue(this.trackLength,'s'),4);
    trackLength = [trackLength repmat(' ',1,9-length(trackLength))];
    string = ['      trackLength   = ' trackLength '  (fftDegree = ' num2str(this.fftDegree) ')'];
    
    % this block adds the class name
    classnamestring = ['^--|' mfilename('class') '|'];
    fullline = repmat(' ',1,this.LINE_LENGTH);
    fullline(1:numel(string)) = string;
    startvalue = length(classnamestring);
    fullline(length(fullline)-startvalue+1:end) = classnamestring;
    disp(fullline);
end