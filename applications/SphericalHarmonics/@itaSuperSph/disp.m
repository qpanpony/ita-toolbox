function disp(this)
% shows the Object
% beware: as this is the implementaion of an abstract class, this should
% never be triggered as real class disp-function

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
disp@itaSuperSpatial(this)
if isa(this.spatialSampling,'itaCoordinates')
    strCS = this.spatialSampling.coordSystem;
    while numel(strCS) < 4
        strCS = [strCS ' ']; %#ok<AGROW>
    end
    s = this.spatialSampling;
    strNmax = num2str(s.nmax);
    strY = num2str(size(s.Y));
    if numel(s.Y) == 0, strY = ''; end
    
    disp(['      spatialDomain        = ' this.spatialDomain ''])
    disp(['      spatialSampling.nmax = ' strNmax ]);
    disp(['      spatialSampling.Y    = [' strY ']']);
    string = ['      sht_handle    = @' char(this.sht_handle) ''];
    
    % this block adds the class name
    classnamestring = ['^--|' mfilename('class') '|'];
    fullline = repmat(' ',1,this.LINE_LENGTH);
    fullline(1:numel(string)) = string;
    startvalue = length(classnamestring);
    fullline(length(fullline)-startvalue+1:end) = classnamestring;
    disp(fullline);
end
