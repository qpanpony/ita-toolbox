function varargout = plot(this)
% choose the best plot

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if numel(this) > 1
   [m,n] = size(this);
   count = 1;
   for idx = 1:m
       for jdx = 1:n
           subplot(m,n,count)
           this(idx,jdx).plot
           count = count + 1;
       end
   end
   return
end

if this.nChannels == 0
   disp('No data to plot'); 
   return;
end
if this.isTime
    h = this.plotOverloaded_time;
else
    h = this.plotOverloaded_freqMagnitude;
end

grid on
set(gcf,'Name', this.comment);
title(this.comment);

if nargout > 0
    varargout = {h};
end

end


