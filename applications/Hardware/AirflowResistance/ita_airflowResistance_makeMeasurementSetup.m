function varargout = ita_airflowResistance_makeMeasurementSetup()
%ITA_AIRFLOWRESISTANCE_MAKEMEASUREMENTSETUP - Creates not calibrated standard measurement setup for airflow resistance measurement @2Hz
%  This function creates a calibrated Measurement Setup, for measurements with
%  the ITA Airflow Resistance Measurement Tube. The measurement setup is fully calibrated for
%  the following measurement chain:
%
%  AD:      PreSonus Firerobo 2 hwch1-PotiLeft, Sens. @ 2Hz = 0.09 [1/V]
%  PreAmp:  B&K 2610, SN:1501530, InputGain +40 dB, Sens. @2Hz = 30 [V/V]
%  Sensor:  B&K mic 1" Type 4146 SN:256882, Sens. @ 2 Hz = 4.3e-3 [V/Pa]
%
%  An extensive documentation of the airflow resistance measurement
%  equipment can be found on \\Verdi\share\Messplaetze\Stroemungswiderstand
%
%  Syntax:
%   MS = ita_airflowResistance_makeMeasurementSetup()
%

% <ITA-Toolbox>
% This file is part of the application AirflowResistance for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%
%  Example:
%   MS = ita_airflowResistance_makeMeasurementSetup()
%   ita_airflowResistance_measurementGUI(MS)
%
%  See also:
%   ita_airflowResistance_measurementGUI, ita_airflowResistance
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_airflowResistance_makeMeasurementSetup">doc ita_airflowResistance_makeMeasurementSetup</a>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  12-Jan-2011



%% create measurement setup @ 2 Hz inkl. Mic

inputCh     = 1;
fftSize     = 18;
pause       = 0;
averages    = 1;
comment = 'Amp, AD und Mic  kalibiert auf 2 Hz.';

% chainStruct   = struct( 'Name',         'HWch1',                                                                                              ...
%                         'hw_ch',         1,                                                                                                   ...
%                         'AD',           'PreSonus Firebox PDI_hwch1-PotiLeft @ 2Hz',  'Sensitivity_AD',       itaValue(0.0897,     '1/V'),    ...
%                         'PreAmp',       'B&K 2610 @ 2Hz +40 dB  SN:1501530',          'Sensitivity_PreAmp',   itaValue(0.312*100),            ...
%                         'Sensor',       'B&K mic 1" Type 4146 SN:256882 @ 2 Hz',      'Sensitivity_Sensor',   itaValue(4.3683e-3, 'V/Pa'),    ...
%                         'Coordinates',   itaCoordinates(),                                                                                    ...
%                         'Orientation',   itaCoordinates(),                                                                                    ...
%                         'UserData',  ''                                                 );

chainStruct   = struct( 'Name',         'HWch1',                                                                                              ...
                        'hw_ch',         1,                                                                                                   ...
                        'AD',           'PreSonus Firerobo 2 hwch1-PotiLeft @ 2Hz',   'Sensitivity_AD',       itaValue(0.09,     '1/V'),    ...
                        'PreAmp',       'B&K 2610 @ 2Hz +40 dB  SN:1501530',          'Sensitivity_PreAmp',   itaValue(0.3*100),            ...
                        'Sensor',       'B&K mic 1" Type 4146 SN:256882 @ 2 Hz',      'Sensitivity_Sensor',   itaValue(4.3e-3, 'V/Pa'),    ...
                        'Coordinates',   itaCoordinates(),                                                                                    ...
                        'Orientation',   itaCoordinates(),                                                                                    ...
                        'UserData',  ''                                                 );

mChain = itaMeasurementChain(chainStruct);
mChain.elements(1).calibrated = 0;
mChain.elements(2).calibrated = 0;
mChain.elements(3).calibrated = 0;

MS2Hz = itaMSRecord('inputChannels', inputCh, 'fftDegree', fftSize, 'comment',comment ,'pause',pause ,'averages',averages, 'inputMeasurementChain', mChain);





%% Set Output
varargout(1) = {MS2Hz};

%end function
end