function varargout = ita_polhemus_calibrate(varargin)
%ITA_POLHEMUS_CALIBRATE - +++ Calibrates the polhemus tracker to head center +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   ita_polhemus_calibrate
%
%
%  Example:
%   ita_polhemus_calibrate
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_polhemus_calibrate">doc ita_polhemus_calibrate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  19-May-2015 


%%

% calibration works by doing two things.
% the first step is to make two measurements with the stylus on the
% subjects ear
% this will calculate the head-center point
%
% the second step is to instruct the subject to look in front with the head
% not tilted. a measuement there will calibrate the sensors rotation
%
% to register button clicks, a callback is defined. the tracker is polled
% using a timer

trackerHelper = itaPolhemusCalibrateHelper();     


calibrateEars(trackerHelper);


%end function
end

function calibrateEars(trackerHelper)

% first, calibrate the left ear:
disp('Calibrate the left ear:');
leftEar = trackerHelper.waitForButtonClicked();

disp('Calibration point taken')
% x = input('Press a key to continue');
% second, calibrate the right ear:
disp('Calibrate the right ear:');
rightEar = trackerHelper.waitForButtonClicked();
disp('Calibration point taken')
% x = input('Press a key to continue');

% third: get the head rotation
disp('Please look straight in front:');
frontDir = trackerHelper.waitForButtonClicked();


% get the numbering for head sensor and stylus sensor. stylus should be the
% one that is clicked

stylusNumber = 0;
headNumber = 0;

for n=1:length(leftEar)
    s = leftEar{n};
    % Only show last sensor that has a button
    if (s.buttonPressed)
        stylusNumber = n;
    end
    if ~(s.buttonPressed)
        headNumber = n;
    end
end

% calculate head translation
% first, calculate the ear position relative to the headsensor
leftEarRelative = itaCoordinates(1);
leftEarRelative.cart = (leftEar{stylusNumber}.pos - leftEar{headNumber}.pos).';

rightEarRelative = itaCoordinates(1);
rightEarRelative.cart = (rightEar{stylusNumber}.pos - rightEar{headNumber}.pos).';

% take the mean of both positions
headCenter = (leftEarRelative + rightEarRelative) ./2;


% head rotation is the ypr information from the last measurement
headRotation = frontDir{headNumber}.orient;

% calculate orientation and translation offsets and set them to the tracker
% TODO.. The ITAPolhemus.mex has to be changed for this
ITAPolhemusD('SetSensorRotation',1,headRotation);
ITAPolhemusD('SetSensorTranslation',1,headCenter.cart);

end










