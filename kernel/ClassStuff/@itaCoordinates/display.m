function display(this, varargin)
% function can be call with or without additional parameter

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if numel(this) > 1
    disp('multi instance class, TODO: implement this in itaCoordinates.display');
    return;
end

nPoints = size(this.mCoord,1);

% check for the optional additional diplay string
if nargin > 1
    additionalInput = varargin{1};
    if numel(additionalInput) ~= nPoints
        error([mfilename('class') '.display  invalid additional display argument from subclass'])
    end
    useAdditionalInput = true;
else
    useAdditionalInput = false;
end

if nPoints == 0
    % empty object
    disp(['**** empty ' class(this) ' object ****       initialize with:   object = ' class(this) '(nPoints)'])
elseif nPoints > 5000
    disp(['**** ' class(this) ' object with ' num2str(nPoints) ' elements ****         please pick a few entries by using .n(index)' ])
else
    % there are points
    switch this.mCoordSystem
        case 'cart'
            prefix = '[ x  y  z ] = [';
        case 'sph'
            prefix = '[ r  theta  phi ] = [';
        case 'cyl'
            prefix = '[ rho  phi  z ] = [';
        case 'pol'
            prefix = '[ r  alpha  beta ] = [';
    end
    
    % maximum entry
    maxVal = max(max(abs(this.mCoord)));
    if isnan(maxVal) || (maxVal == 0)
        maxVal = 1;
    end
    digitsBehind = 2;
    
    % how much space is needed
    coordString = num2str(floor(log10(maxVal)) + 4 + digitsBehind);
    digitsString = num2str(digitsBehind);
    coordStyle = ['%' coordString '.' digitsString 'f'];
    numberString = num2str(floor(log10(nPoints))+1);
    numberStyle = ['%0' numberString 'g'];
    
    for iPoint = 1:nPoints
        fprintf(1, [inputname(1) '.n(' numberStyle  ') = ' prefix '  ' coordStyle '  ' coordStyle '  ' coordStyle ' ]'], iPoint, this.mCoord(iPoint,:));
        if useAdditionalInput
            fprintf(1, additionalInput{iPoint});
        end
        fprintf(1,'\n');
    end
    
    if nPoints > 3
        disp(['=========== in total ' num2str(nPoints) ' points ===========']);
    end    
end
end