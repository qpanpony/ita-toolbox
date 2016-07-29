function results = ita_get_absorption_from_rev_chamber_measurement(varargin)
% ITA_GET_ABSORPTION_FROM_REV_CHAMBER_MEASUREMENT -  Calculates the absorption and absorption coefficient of an object from
% measured impulse responses in a reverberation chamber.
% 
% Syntax:    result = ita_get_absorption_from_rev_chamber_measurement(reference_measurement,object_measurement, options)
% 
% e.g.:    result = ita_get_absorption_from_rev_chamber_measurement(refMeas,objMeas, 't20')
%  
% options = 'edt','t10','t20'(default),'t30','t40','t50','t60'
%
% reference_measurement: n Channel itaAudio containing all reverberation chamber IRs without the object
% object_measurement:    m Channel itaAudio containing all reverberation chamber IRs with the object
%
% Parameters like temperature, humidity, surfaces and volume are required for
% this function and must be stored in the itaAudios .userData and .channelUserData fields.
% If the GUI application "ita_revchamber_aborptionmeasurement_GUI" was used to
% record the impulse responses this data is automatically stored in the
% right format. It is therefore recommended to use the mentioned GUI application,
% for TF meansurements in the reverberation chamber
% 
% The order in userData is:
% { Name of measured object , room volume in m^3, room surface in m^2, object volume in m^3, object surface in m^2 }
% room volume and room surface must be the same in the itaAudio for the
% measurements with and without absorber object
% The volume and surface of the measurement object are extracted from the
% userData of the itaAudio containing the measurements with object
%
% Each channel contains the following channelUserData:
% [ Temperature , Humidity, Adiabatic Pressure ]
%
% The result returned by this function is a multi-instance itaResult and contains:
% mean absorption coefficient (1), 
% standard error of the absorption coefficient (2),
% mean equivalent absorption area (total absorption) (3), 
% standard error of the equivalent absorption area (total absorption) (4)
% mean reverberation time of the empty chamber (5),
% standard error of the reverberation time of the empty chamber (6),
% mean reverberation time of the chamber with object (7), 
% standard error of the reverberation time of the chamber with object (8)
%
% All itaResults in the results multiinstance contain a struct with the metaData of the measurements that
% is stored in the userData of the itaResult and contains the following entries:
%
% userData.objectName 
% userData.roomVolume
% userData.roomSurface
% userData.objectVolume
% userData.objectSurface
% userData.meanTempAtRefMeas
% userData.stdTempAtRefMeas
% userData.meanHumidityAtRefMeas
% userData.stdHumidityAtRefMeas
% userData.meanAdiabaticPressureAtRefMeas
% userData.stdAdaibaticPressureAtRefMeas
% userData.meanTempAtObjMeas
% userData.stdTempAtObjMeas
% userData.meanHumidityAtObjMeas
% userData.stdHumidityAtObjMeas
% userData.meanAdiabaticPressureAtObjMeas
% userData.stdAdiabaticPressureAtObjMeas

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% parse arguments
if numel(varargin) == 3 && isa(varargin{1},'itaAudio') && isa(varargin{2},'itaAudio')
    refMeas = varargin{1};
    objMeas = varargin{2};
    rtArg   =  varargin{3};
elseif numel(varargin) == 2 && isa(varargin{1},'itaAudio') && isa(varargin{2},'itaAudio')
    refMeas = varargin{1};
    objMeas = varargin{2};
    rtArg   =  't20';
else
    error([thisFuncStr ' Wrong input arguments. See help to this function.']);
end

%% check surface/volume, have to be the same
if ~isequal(refMeas.userData{2},objMeas.userData{2})
    error([thisFuncStr ' Different values for room volume in .userData.']);
elseif ~isequal(refMeas.userData{3},objMeas.userData{3})
    error([thisFuncStr ' Different values for room surface in .userData.']);
end

objectName    = objMeas.userData{1};
roomVolume    = objMeas.userData{2};
roomSurface   = objMeas.userData{3};
objectVolume  = objMeas.userData{4};
objectSurface = objMeas.userData{5};

%% Roomacoustics
% freqRange = ita_preferences('freqRange');
% bandsPerOctave = ita_preferences('bandsPerOctave');
% RASettings = [ freqRange(1), freqRange(2), bandsPerOctave, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
% if strcmpi(rtArg, 'edt')
%     RASettings(5) = 1;
% elseif strcmpi(rtArg, 't10')
%     RASettings(6) = 1;
% elseif strcmpi(rtArg, 't20') 
%     RASettings(7) = 1;
% elseif strcmpi(rtArg, 't30') 
%     RASettings(8) = 1;
% elseif strcmpi(rtArg, 't40') 
%     RASettings(9) = 1;
% elseif strcmpi(rtArg, 't50') 
%     RASettings(10) = 1;
% elseif strcmpi(rtArg, 't60') 
%     RASettings(11) = 1;
% end
% ita_preferences('roomacousticParameters',RASettings);

refMeas = ita_time_window(refMeas, [0.8 0.85]*refMeas.trackLength.value, 'time');  % this has proven to be useful to prevent the noisedetect function 
                                                                                   % in ita_roomacoustics to do stupid stuff in certain cases
objMeas = ita_time_window(objMeas, [0.8 0.85]*objMeas.trackLength.value, 'time');  % this has proven to be useful to prevent the noisedetect function 
                                                                                   % in ita_roomacoustics to do stupid stuff in certain cases

refMeas_RA = ita_roomacoustics(refMeas, rtArg);
objMeas_RA = ita_roomacoustics(objMeas, rtArg);
% refMeas_RA = ita_roomacoustics(refMeas);
% objMeas_RA = ita_roomacoustics(objMeas);


refMeas_RA = refMeas_RA(1);
objMeas_RA = objMeas_RA(1);
refMeas_RA.comment = [refMeas_RA.comment ' without object'];
objMeas_RA.comment = [objMeas_RA.comment ' with object'];

%% calculate absorption coefficient for every channel
%%% Evtl. Formel einbauen, die auch den adiabatischen Druck berücksichtigt...

freqVector = refMeas_RA.freqVector;
for i = 1:refMeas_RA.nChannels
    temperatureAtRefMeas(i) = refMeas.channelUserData{i}(1);
    humidityAtRefMeas(i) = refMeas.channelUserData{i}(2);
    adiabaticPressureAtRefMeas(i) = refMeas.channelUserData{i}(3);
    
    [c_ref,m_ref] = ita_constants({'c','m'},'medium','air', 'T', temperatureAtRefMeas(i), 'phi', humidityAtRefMeas(i), 'f', freqVector);
    
    % Achtung ita_sabine berechnet eigentlich nach Eyring-Formel und das ist auch gut so!!!
    alpha_act = ita_sabine('c',c_ref, 'm',m_ref, 'v',roomVolume, 's',roomSurface,'t60',refMeas_RA.ch(i), 'mode', 'eyring');
    if i==1
        refMeas_alpha = alpha_act;
    else
        refMeas_alpha = merge(refMeas_alpha,alpha_act);
    end
end

freqVector = objMeas_RA.freqVector;
for i = 1:objMeas_RA.nChannels
    temperatureAtObjMeas(i) = objMeas.channelUserData{i}(1);
    humidityAtObjMeas(i) = objMeas.channelUserData{i}(2);
    adiabaticPressureAtObjMeas(i) = objMeas.channelUserData{i}(3);
    
    [c_obj,m_obj] = ita_constants({'c','m'},'medium','air', 'T', temperatureAtObjMeas(i), 'phi', humidityAtObjMeas(i), 'f', freqVector);
    
    % Achtung ita_sabine berechnet eigentlich nach Eyring-Formel und das ist auch gut so!!!
    alpha_act = ita_sabine('c',c_obj, 'm',m_obj, 'v',roomVolume, 's',roomSurface,'t60',objMeas_RA.ch(i), 'mode', 'eyring');
    if i==1
        objMeas_alpha = alpha_act;
    else
        objMeas_alpha = merge(objMeas_alpha,alpha_act);
    end
end


%% calculate object absorption coefficient and error
RT_refMeas_mean = mean(refMeas_RA);
RT_objMeas_mean = mean(objMeas_RA);
RT_refMeas_sem  = std(refMeas_RA)/sqrt(refMeas_RA.nChannels);
RT_objMeas_sem  = std(objMeas_RA)/sqrt(objMeas_RA.nChannels);

alpha_refMeas_mean = mean(refMeas_alpha);
alpha_objMeas_mean = mean(objMeas_alpha);
alpha_refMeas_sem  = std(refMeas_alpha)/sqrt(refMeas_alpha.nChannels);
alpha_objMeas_sem  = std(objMeas_alpha)/sqrt(objMeas_alpha.nChannels);

AObj         = ( itaValue(roomSurface,'m^2')*alpha_objMeas_mean - itaValue(roomSurface-objectSurface,'m^2')*alpha_refMeas_mean );
AObj_sem     = sqrt( itaValue(roomSurface,'m^2')^2 * alpha_objMeas_sem^2 + itaValue(roomSurface-objectSurface,'m^2')^2 * alpha_refMeas_sem^2 );
alphaObj     = 1/itaValue(objectSurface,'m^2') * AObj;
alphaObj_sem = 1/itaValue(objectSurface,'m^2') * AObj_sem;


metaData.objectName    = objectName;
metaData.roomVolume    = roomVolume;
metaData.roomSurface   = roomSurface;
metaData.objectVolume  = objectVolume;
metaData.objectSurface = objectSurface;
metaData.meanTempAtRefMeas = mean(temperatureAtRefMeas);
metaData.stdTempAtRefMeas  = std(temperatureAtRefMeas);
metaData.meanHumidityAtRefMeas = mean(humidityAtRefMeas);
metaData.stdHumidityAtRefMeas  = std(humidityAtRefMeas);
metaData.meanAdiabaticPressureAtRefMeas = mean(adiabaticPressureAtRefMeas);
metaData.stdAdaibaticPressureAtRefMeas  = std(adiabaticPressureAtRefMeas);
metaData.meanTempAtObjMeas = mean(temperatureAtObjMeas);
metaData.stdTempAtObjMeas  = std(temperatureAtObjMeas);
metaData.meanHumidityAtObjMeas = mean(humidityAtObjMeas);
metaData.stdHumidityAtObjMeas  = std(humidityAtObjMeas);
metaData.meanAdiabaticPressureAtObjMeas = mean(adiabaticPressureAtObjMeas);
metaData.stdAdiabaticPressureAtObjMeas  = std(adiabaticPressureAtObjMeas);

alphaObj.channelNames        = {'mean absorption coefficient'};
alphaObj_sem.channelNames    = {'standard error (std/sqrt(n)) of the absorption coefficient'};
AObj.channelNames            = {'mean total absorption'};
AObj_sem.channelNames        = {'standard error (std/sqrt(n)) of the total absorption'};
RT_refMeas_mean.channelNames = {'mean reverberation time of measurement without object'};
RT_refMeas_sem.channelNames  = {'standard error (std/sqrt(n)) of reverberation time of measurement without object'};
RT_objMeas_mean.channelNames = {'mean reverberation time of measurement with object'};
RT_objMeas_sem.channelNames  = {'standard error (std/sqrt(n)) of reverberation time of measurement without object'};

alphaObj.channelUnits        = {''};
alphaObj_sem.channelUnits    = {''};
AObj.channelUnits            = {'m^2'};
AObj_sem.channelUnits        = {'m^2'};
RT_refMeas_mean.channelUnits = {'s'};
RT_refMeas_sem.channelUnits  = {'s'};
RT_objMeas_mean.channelUnits = {'s'};
RT_objMeas_sem.channelUnits  = {'s'};

alphaObj.userData        = metaData;
alphaObj_sem.userData    = metaData;
AObj.userData            = metaData;
AObj_sem.userData        = metaData;
RT_refMeas_mean.userData = metaData;
RT_objMeas_mean.userData = metaData;
RT_refMeas_sem.userData  = metaData;
RT_objMeas_sem.userData  = metaData;


%% output
results = itaResult();
results(1) = alphaObj;
results(2) = alphaObj_sem;
results(3) = AObj;
results(4) = AObj_sem;
results(5) = RT_refMeas_mean;
results(6) = RT_refMeas_sem;
results(7) = RT_objMeas_mean;
results(8) = RT_objMeas_sem;
