function result = ita_HRTFarc_postProcessContinuous(varargin)
%ITA_HRTFARC_POSTPROCESSCONTINUOUS - +++ Short Description here +++
%  This function gives a short example on how to postProcess a continuous
%  HRTF
%
%  Syntax:
%   audioObjOut = ita_HRTFarc_postProcessContinuous(data,data_raw, options)
%
%   Options (default):
%           'refFile'       ('')    : location of an ita audio file with reference
%           'twait'         (0.03)  : twait of measurement
%           'dataChannel'   (1:2)   : left and right data channel
%           'ttChannel'     (3)     : motor switch data channel
%           'freqRange'     ([500 22050]):freqrange of measurement
%           'tw'            ([0.006 0.008])   : the time window edges
%           'rotationDirection'   (-1)   : rotation direction
%           'normalize'     ([])      : normalization factors
%           'itdMethod'     ('xcorr')      : method for itd calculation

%           'nmax'          (75)    : maximum sh transformation order
%           'epsilon'       (1e-8)  : regularization epsilon
%           'offset'        ([-0.0725 0.0725]): offset for ears in m
%           'reconstructSampling'([]): sampling of interpolated hrtf
%
%  Example:
%   audioObjOut = ita_HRTFarc_postProcessContinuous(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_HRTFarc_postProcessContinuous">doc ita_HRTFarc_postProcessContinuous</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  04-Oct-2018 


%% Initialization and Input Parsing
sArgs        = struct(  'pos1_data','itaAudio',  ...
                        'pos2_data','itaAudio',  ...
                        'refFile','',...
                        'twait', 0.03, ...
                        'dataChannel',1:2, ...
                        'ttChannel',3, ...
                        'freqRange',[500 22050], ...
                        'tw',[0.006 0.008], ...
                        'rotationDirection',-1, ...
                        'normalize',[], ...
                        'itdMethod','xcorr', ...
                        'nmax',75, ...
                        'epsilon',1e-8,...
                        'offset',[-0.0725 0.0725],...
                        'reconstructSampling',[]);
[data,data_raw,options] = ita_parse_arguments(sArgs,varargin); 


%% prepare some options
nOutputChannels = 64; 
nInputChannels = 2;


%calculate the number of repetitions from the signal length
nSamplesWait = options.twait* data_raw.samplingRate; 
% count number of sweep repetitions
repetitions = floor(data_raw.nSamples/(nSamplesWait*nOutputChannels)); % 1566280 / ( 1323 * 64 )
obj.repetitions = repetitions; % 18 repetitions


%% extract data from motor channel
% this data is used to determine the exact measurement speed and the time
% points where the arc is at defined positions
dataMotor = data_raw.ch(options.ttChannel);
motorTime =  triggerTime(dataMotor);

%triggerTime only triggers on positive edge
if numel(motorTime) ~= 2
    error('could not find two switch positions in motor data. please take a look')
end

% dataMotor.timeData = dataMotor.timeData*0.9; 
% 
% dataMotor.timeData = reshape(dataMotor.timeData,length(dataMotor.timeData)/2,2);
% dataMotor.timeData(:,2) = fliplr(dataMotor.timeData(:,2).' ).';
% 
% motorPoints = ita_start_IR(dataMotor);
% 
% [~,tmp] = max(dataMotor.timeData);
% 
% if any(abs(tmp - motorPoints) > 250)
%     disp('Something is wrong with the motorPoint detection');
%     disp('Using max values - Handle with care');
%     motorPoints = tmp;
% end
% 
% motorTime = motorPoints/dataMotor.samplingRate;
% % the second motor time gets one tracklength to correct for the cut in half
% motorTime(2) = dataMotor.trackLength - motorTime(2);
% motorTime(2) = motorTime(2) + dataMotor.trackLength;

% get the first and last sweep repetition (globally)
exactStartAndEndRepetition = motorTime/options.twait/nOutputChannels;
firstAndLastNeededRepetition = floor(exactStartAndEndRepetition);
firstAndLastNeededRepetition(1) = firstAndLastNeededRepetition(1) + 1;

options.repetitions = diff(firstAndLastNeededRepetition);

%% prepare the data
% this includes time window, crop to length and reshuffle into a sane order

% to crop, a new measurement setup is created
obj = itaMSTFinterleaved;
obj.inputChannels = 1:3;
obj.outputChannels = 1:nOutputChannels;
obj.repetitions = repetitions;
obj.freqRange = options.freqRange;
[~,options.sweepRate] = obj.optimize;
obj.twait = options.twait;
result = obj.crop(data.ch(options.dataChannel));


result_tw      =   ita_time_window(result,options.tw,'time');
% make end sample be div by 4 for daff export
endSample = round(options.tw(2) .* result(1).samplingRate)+1;
endSample = endSample + mod(endSample,4);
result_tw      =    ita_time_crop(result_tw,[1 endSample],'samples');


% remove unwanted repetitions
% first, split into the micchannels
for index = 1:nInputChannels
    result_tmp(:,index) = result_tw.ch((index-1)*repetitions + 1:(index)*repetitions);
end % result_tmp does now contain two instances of itaAudio

% throw measurement beyond the scope of first and last needed repetition
result_cut_tmp = result_tmp.ch((firstAndLastNeededRepetition(1):firstAndLastNeededRepetition(2)));

for index = 1:nOutputChannels
    result_cut(index) = merge(result_cut_tmp(index,:));
end

%% prepare the reference

ref = ita_read(options.refFile);
ref = merge(ref);

ref_tw      =   ita_time_window(ref,options.tw,'time');
% make end sample be div by 4 for daff export
endSample = round(options.tw(2) .* ref(1).samplingRate)+1;
endSample = endSample + mod(endSample,4);
ref_tw      =    ita_time_crop(ref_tw,[1 endSample],'samples');



ref_finished = ita_smooth_notches(ref_tw,'bandwidth',1/2,...
    'threshold', 3);

clear tmp;
% create a multi instance again
for index = 1:ref_finished.nChannels
    tmp(index) = ref_finished.ch(index);
end
ref_finished = tmp;
    
if ref_finished(1).nChannels > 1
    for index = 1:length(result_cut)
       tmp = ref_finished(index);
       tmp2 = tmp;
       repmatNumber = result_cut(index).nChannels/2;
       tmp.freqData = repelem(tmp.freqData,1,repmatNumber);
       tmp.channelNames = repelem(tmp2.channelNames,repmatNumber,1);
       tmp.channelUnits = repelem(tmp2.channelUnits,repmatNumber,1);
       ref_finished(index) = tmp;
    end

end
    

%% divide by reference
for index = 1:length(result_cut)
    results_div(index) = ita_divide_spk(result_cut(index),ref_finished(index) ,'regularization',[100,20000]);
end
 
%% rearange the results
for index = 1:results_div(1).nChannels
    results_final(index) = merge(results_div.ch(index));
end

results_split(1) = merge(results_final(1:(options.repetitions+1)));
for index = 2:length(options.dataChannel)
    results_split(index) = merge(results_final((options.repetitions + 1)*(index-1)+1:(options.repetitions+1)*index));
end


%% calculate the base coordinate system
% every elevation has a different location

usedTime = diff(motorTime); % time consumed for whole cycle
rotationSpeed = 360/usedTime;
options.rotationSpeed = rotationSpeed;
waitTimes = [0;cumsum(repmat(options.twait,nOutputChannels-1,1))];

baseCoords = ita_HRTFarc_returnIdealNewArcCoordinates;

% correctForContinuousRotation
baseCoords.phi_deg = baseCoords.phi_deg + options.rotationDirection*(rotationSpeed*waitTimes);

anglePerRepetition = nOutputChannels*options.twait*rotationSpeed;

fullCoords = itaCoordinates(baseCoords.nPoints*options.repetitions);
for index = 1:options.repetitions + 1
    startIndex = 1+(index-1)*nOutputChannels;
    endIndex = 64+(index-1)*nOutputChannels;
    tmpCoords = baseCoords;
    tmpCoords.phi_deg = tmpCoords.phi_deg + options.rotationDirection*anglePerRepetition*(index-1);
    fullCoords.cart(startIndex:endIndex,:) = tmpCoords.cart;
end




% add the startTime and latency to the angle

timePerRepetition = nOutputChannels*options.twait;
fullCoords.phi_deg = mod(fullCoords.phi_deg + options.rotationDirection*timePerRepetition*(firstAndLastNeededRepetition(1)-exactStartAndEndRepetition(1))*rotationSpeed,360);

% correction for time delay
% the arc will have rotated further until the signal arrived
fullCoords.phi_deg = fullCoords.phi_deg - options.rotationDirection*1.2/344*rotationSpeed;
    



% smooth the coordinates by rounding to 2 decimals
fullCoords.phi_deg = round(fullCoords.phi_deg,2);
fullCoords.theta_deg = round(fullCoords.theta_deg,2);


%% some post processing

% normalize
if ~isempty(options.normalize)
    results_split(1).freqData = results_split(1).freqData ./ options.normalize(1);
    results_split(2).freqData = results_split(2).freqData ./ options.normalize(2); 
end



% shift to avoid anticausal time values
for index = 1:2
    results_split(index)      = ita_time_shift(results_split(index) , 0.0035);
end


% calculate ITD and shift to 0 -- search for "ITD == 0"
[centerPoint,itdData] = ita_HRTFarc_pp_itdInterpolate(results_split,fullCoords,options);
if itdData.error > 0.01
    disp('warning: itd match does not look good. something is wrong in either the data, or the itd method');
end
options.itdCenterCorrection = centerPoint;
fullCoords.phi_deg = fullCoords.phi_deg -centerPoint;


% smooth low frequencies
results_split = ita_HRTF_postProcessing_smoothLowFreq(results_split,'cutOffFrequency',700,'upperFrequency',1200,'timeShift',0);

%% spherical post-processing

% do spherical harmonics correction -- (because of movement)
clear result;
centerPoints = [];
shCoeffs = [];
for index = 1:length(options.dataChannel)
    results_split(index).channelCoordinates = fullCoords;
    [result(index), centerPoints, shCoeffs{index},options.epsilon] = ita_HRTFarc_pp_process_spherical(results_split(index),fullCoords,options,options.offset(index),index);
end

%% add metadata to result
% append options to userdata
for index = 1:length(result)
    result(index).userData = options;
end

% append commit id to history
commitID = ita_git_getMasterCommitHash;
for index = 1:length(result)
    if ~isempty(commitID)
        result(index) = ita_metainfo_add_historyline(result(index),'ita_HRTFarc_postProcessContinuous',commitID);
    end    
end

end

function triggerTimeOut = triggerTime(dataMotor)
    %% find location of first positive edge in motor data and avoid ringing!
    % looks for positive peaks, taking the first one within a 1 secong 
    % with a magnitude > 0.95 max value in timeData - helps with bouncing
    
    %plot peak locations for debug: peakfind(dataMotor)
    
    [~,triggerTimeOut] = findpeaks(dataMotor.timeData,dataMotor.samplingRate,'MinPeakDistance',1,'MinPeakHeight',0.95*max(abs(dataMotor.timeData)));
    
end
