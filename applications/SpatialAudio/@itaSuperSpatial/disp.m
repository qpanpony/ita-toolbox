function disp(this)
% shows the Object
% beware: as this is the implementaion of an abstract class, this should
% never be triggered as real class disp-function

% <ITA-Toolbox>
% This file is part of the application SpatialAudio for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
if isa(this.spatialSampling,'itaCoordinates')
    s = this.spatialSampling;
    
    strCoord = num2str(size(s.cart));
    if numel(s.cart) == 0, strCoord = ''; end
    
    strCS = s.coordSystem;
    while numel(strCS) < 4
        strCS = [strCS ' ']; %#ok<AGROW>
    end
    
    string = ['      spatialSampling.' strCS ' = [' strCoord ']'];
else
    string = ['      spatialSampling      = (undefined)  ' ''];
end

% this block adds the class name
classnamestring = ['^--|' mfilename('class') '|'];
fullline = repmat(' ',1,this.LINE_LENGTH);
fullline(1:numel(string)) = string;
startvalue = length(classnamestring);
fullline(length(fullline)-startvalue+1:end) = classnamestring;
disp(fullline);