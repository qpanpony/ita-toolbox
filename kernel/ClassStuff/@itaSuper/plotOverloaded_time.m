function h = plotOverloaded_time(this)
%fast plot routine in time domain
% ==> that is part of the overloaded time plot function

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


xVec = this.timeVector;
yMax = max(max(abs(this.timeData)));
if yMax == 0
    yLim = [-1 1];
else
    yLim = yMax * [-1.2 1.2];
end
h = plot(xVec, this.timeData);
%     plotbrowser('on')
xlabel('sec');
ylabel('Amplitude');
set(gca,'XLim', xVec([1 end]));
set(gca,'YLim', yLim);
end