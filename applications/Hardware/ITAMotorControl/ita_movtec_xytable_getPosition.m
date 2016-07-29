function varargout = ita_movtec_xytable_getPosition(varargin)
%ITA_MOVTEC_XYTABLE_GETPOSITION - returns the x and y Position (in steps)
%
%   Syntax: [x, y]= ita_movtec_xytable_getPosition
%           ita_movtec_xytable_getPosition
%           x = ita_movtec_xytable_getPosition('x')
%           ita_movtec_xytable_getPosition('x')
%           y = ita_movtec_xytable_getPosition('y')
%           ita_movtec_xytable_getPosition('y')
%   you can also use 'motor2', '2' or 'X' (equals 'x') and 'motor1','1'
%   or 'Y' (equals 'y')

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  02-Feb-2010
thisFuncStr  = [upper(mfilename) ':'];

% check serial-connection
global serial_movtec;
if isempty(serial_movtec)
    ita_movtec_init;
end

% check input arguments
narginchk(0,2);
getXPos = 0;
getYPos = 0;
if nargin == 1
    if nargout>1
        error('Check your in- and output arguments!');
    end
    if strcmp(varargin{1},'motor1') || strcmp(varargin{1},'1') || ...
            strcmp(varargin{1},'y') || strcmp(varargin{1},'Y')
        getYPos = 1;
    end
    if strcmp(varargin{1},'motor2') || strcmp(varargin{1},'2') || ...
            strcmp(varargin{1},'x') || strcmp(varargin{1},'X')
        getXPos = 1;
    end
else
    if nargout==1
        error('Check your in- and output arguments!');
    end
    getXPos = 1;
    getYPos = 1;
end

% get the positions
if getYPos && getXPos
    [posY posX] = ita_movtec_getPosition('getPos1',true,'getPos2',...
        true,'serial_movtec',serial_movtec);
elseif getYPos
    posY= ita_movtec_getPosition('getPos1',true,'getPos2',false,...
        'serial_movtec', serial_movtec);
elseif getXPos
    posX= ita_movtec_getPosition('getPos1',false,'getPos2',true,...
        'serial_movtec', serial_movtec);
end

% check and manage ouput arguments
if nargout == 0
    if getXPos
        disp([thisFuncStr 'The x-position is: ' num2str(posX)]);
    end
    if getYPos
        disp([thisFuncStr 'The y-position is: ' num2str(posY)]);
    end
elseif nargout == 1
    if getXPos
        varargout(1)={posX};
    elseif getYPos
        varargout(1)={posY};
    end
else
    varargout= [{posX} {posY}];
end
%EOF
end