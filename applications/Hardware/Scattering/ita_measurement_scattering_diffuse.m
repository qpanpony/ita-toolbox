function varargout = ita_measurement_scattering_diffuse(varargin)
%ITA_MEASUREMENT_SCATTERING_DIFFUSE - routine for scattering measurements in a diffuse sound field
% This function executes the measurements for calculating the scattering
% coefficient.
% nr_meas defines which measurement among the four will be done
%

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%                        Test sample         |   Turning table
% - nr_meas = 1     |        NO              |      NO
% - nr_meas = 2     |        YES             |      NO
% - nr_meas = 3     |        NO              |      YES
% - nr_meas = 4     |        YES             |      YES
%
% The climate conditions will be logged during the measurements and the
% mean values are the second output argument. Those can be used in
% ita_scattering_coefficient_diffuse
%
%  Syntax:
%   audioObjOut = ita_measurement_scattering_diffuse(measurementSetup, nr_meas, filename, radii, options)
%
%           'filename' : a string that will be inserted in the name of the
%                        file when it is written.
%
%   Options (default):
%           'arduinoComPort' (COM5): enables the user to specify which
%                                    port to use for the arduino
%
%           'positions' (standard_positions): enables the user to give an
%                                             ita_coordinate object to
%                                             specify positions for the
%                                             robot
%
%           'turntable_degree' (7): the amount the turntable will
%                                       rotate each time.
%
%
%  Example:
%   result = ita_measurement_scattering_diffuse(MS,3,'testing123',[.185,.185])

%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_measurement_scattering_diffuse">doc ita_measurement_scattering_diffuse</a>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  28-Jul-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_inMS','itaMSTF', 'pos2_nr_meas','double','pos3_filename','string', 'arduinoComPort','COM5','motorComPort','COM8','plot',false,'positions',scattering_box_standard_positions([1 3 5 7 9]), 'turntable_degree', 6, 'singleAverages',1);

[MS,nr_meas,filename,sArgs] = ita_parse_arguments(sArgs,varargin);

% add the measurement number to the filename
filenameTemp        = ['scatterMeasTemp_' filename '.mat'];
filenameComplete    = [filename '_measNr' num2str(nr_meas)];

%% INITIALIZING ROBOT and MOTOR
robot = itaScatteringRobot(sArgs.arduinoComPort);
robot.reset;

motor = motor_setup(sArgs.motorComPort,1);

%% DIRECTORY
datum = datestr(now,'yyyy-mmm-dd');
if ~exist(datum,'dir')
    mkdir(datum);
end

switch nr_meas
    case 1
        ita_verbose_info([thisFuncStr 'remove the sample from the room; table will not be turning'],0);
        nAverage = 16;
    case 2
        ita_verbose_info([thisFuncStr 'put the sample into the room; table will not be turning'],0);
        nAverage = 16;
    case 3
        ita_verbose_info([thisFuncStr 'remove the sample from the room; table will be turning'],0);
        nAverage = 64;
    case 4
        ita_verbose_info([thisFuncStr 'put the sample into the room; table will be turning'],0);
        nAverage = 64;
    otherwise
        error([thisFuncStr 'wrong value for measurement case']);
end

%% Build the measurement vector
MS.averages = sArgs.singleAverages;

%% FOR TEMP & HUMIDITY
tempMeasIndex = unique(min(max(round(nAverage.*(0.2:0.2:1)),1),nAverage));
initial_conditions = [20;50];
measurement_conditions = bsxfun(@times,initial_conditions,ones(2,sArgs.positions.nPoints,numel(tempMeasIndex)));

%% Measurement
temp_measurements = itaAudio([sArgs.positions.nPoints,1]);

% determine the SNR first and only once
SNR = MS.run_snr;
SNR.plot_freq('ylim',[0 60]);

for iPosition=1:sArgs.positions.nPoints
    disp(strcat('Moving to position :',' ', int2str(iPosition)));
    robot.move_robot(sArgs.positions.n(iPosition)); % move robot
    tempIdx = 1;
    result = itaAudio();
    nErrors = 0;
    for iMeasure=1:nAverage
        if ismember(iMeasure,tempMeasIndex)
            % measure temperature and humidity
            [measurement_conditions(1,iPosition,tempIdx),measurement_conditions(2,iPosition,tempIdx)] = robot.get_temperature_humidity(2);
            tempIdx = tempIdx + 1;
        else % wait to ensure enough time between measurements
            pause(1);
        end

        progressString = [thisFuncStr '# ' num2str(iMeasure + (iPosition-1)*nAverage) ' of ' num2str(nAverage*sArgs.positions.nPoints)];
        if nr_meas == 3 || nr_meas == 4
            ita_verbose_info([progressString ', corresponding to angle ' num2str(iMeasure*sArgs.turntable_degree)],1);
%             robot.move_turn_table(sArgs.turntable_degree); % move turn table
            motor_move(motor,1,500,90,2,sArgs.turntable_degree,0);
            pause(0.5);
        else
            ita_verbose_info(progressString,1);
        end
        
        tmp = MS.run;
        % check for clipping or other errors
        if ~isempty(tmp.errorLog)
            nErrors = nErrors + 1;
        else % only use valid responses
%             ita_write(tmp,['measNr' num2str(nr_meas) '_micPosition' num2str(iPosition) '_iMeasure' num2str(iMeasure)]);
            if isempty(result)
                result = tmp;
            else
                result = result + tmp;
            end
        end
    end
    
    if nErrors > nAverage/3
        error('Too many measurement results with errors, no reliable result will come out of this');
    else
        temp_measurements(iPosition) = result/(nAverage-nErrors);
        save(filenameTemp,'temp_measurements','measurement_conditions');
    end
end

%% organizing and formatting the results
nMics = temp_measurements(1).nChannels;
mic_result = itaAudio([nMics 1]);
for iMic = 1:nMics
    mic_result(iMic) = merge(temp_measurements.ch(iMic));
    mic_result(iMic).channelNames = cellstr([repmat([ 'Mic' num2str(iMic) ', Position #'],mic_result(iMic).nChannels,1) num2str((1:mic_result(iMic).nChannels).')]);
    mic_result(iMic).userData = {mean(measurement_conditions(1:2,:),2)};
    mic_result(iMic).channelCoordinates = sArgs.positions;
end

% writing the results to file.
c = clock;
ita_write(mic_result, [datum filesep , filenameComplete '_' num2str(c(4),'%02d') 'h' num2str(c(5),'%02d') '_' num2str(c(1),'%4.0d') '.ita'],'overwrite','export',false);
delete(filenameTemp);
pause(0.5);

display('All positions measured. The robot will reset before making the next measurements');
robot.reset; % robot reset
robot.close;

%% postprocessing (calculate mean and std)
stdTemp = std(measurement_conditions(1,:));
meanTemp = mean(measurement_conditions(1,:));
stdHumid = std(measurement_conditions(2,:));
meanHumid = mean(measurement_conditions(2,:));

% check the climate conditions during the measurements
% if more than 1 percent temperature or humidity drift occurred, 
% warn the user
if stdTemp/meanTemp > 0.03 || stdHumid/meanHumid > 0.03
    sArgs.plot = true;
    ita_verbose_info([thisFuncStr 'climate conditions have changed considerably during the measurement, be careful with the result'],0);
else
    ita_verbose_info([thisFuncStr 'std(T) = ' num2str(stdTemp) ' (C), std(RH) = ' num2str(stdHumid) ' (%)'],1);
end

if sArgs.plot
    figure;
    plotyy(1:numel(tempMeasIndex),squeeze(mean(measurement_conditions(1,:,:),2)),1:numel(tempMeasIndex),squeeze(mean(measurement_conditions(2,:,:),2)));
    xlim([1 nAverage]);
    axis tight;
    legend('Temperature [C]','Rel. Humidity [%]');
    grid on;
end

varargout(1) = {mic_result};
%end function
end