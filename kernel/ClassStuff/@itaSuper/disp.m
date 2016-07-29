function disp(this)
% get a nice dimensions string

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if ita_preferences('nakedClasses')
    builtin('disp',this)
else
    disp(['      domain        = ' this.domain '     (nBins = ' num2str(this.nBins) ', nSamples = ' num2str(this.nSamples) ', dimensions = ' num2str(this.dimensions) ') '])
    comment = this.comment;
    nMax = 36;
    if length(comment) > nMax
        comment = [comment(1:round((nMax-3)/2)) '...' comment(end-round((nMax-3)/2):end)];
    end
    string = ['      comment       = ''' comment ''''];
    
    % this block adds the class name
    classnamestring = ['^--|' mfilename('class') '|'];
    fullline = repmat(' ',1,this.LINE_LENGTH);
    fullline(1:numel(string)) = string;
    startvalue = length(classnamestring);
    fullline(length(fullline)-startvalue+1:end) = classnamestring;
    disp(fullline);
end
end
