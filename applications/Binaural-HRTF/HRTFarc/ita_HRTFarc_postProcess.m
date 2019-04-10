function result = ita_HRTFarc_postProcess(varargin)
%ITA_HRTF_ARC_POSTPROCESS - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_HRTF_arc_postProcess(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example: 
%   audioObjOut = ita_HRTF_arc_postProcess(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_HRTF_arc_postProcess">doc ita_HRTF_arc_postProcess</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  05-Oct-2018


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct(  'dataFolder','',  ...
                        'refFile','',...
                        'ms',[], ...
                        'tw',[0.006 0.008], ...
                        'rotationDirection',-1, ...
                        'normalize',[], ...
                        'itdMethod','xcorr', ...
                        'dataChannel',1:2);
[options] = ita_parse_arguments(sArgs,varargin);

%% first, load and prepare the reference
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

ref_finished = ref_finished.merge;
%% load all measurements
files = dir([options.dataFolder filesep 'data']);
numFiles = length(files)-2;
idealCoords = ita_HRTFarc_returnIdealNewArcCoordinates;
wb = itaWaitbar(numFiles);
for index = 1:numFiles
    data = ita_read_ita(sprintf('%s/data/%d.ita',options.dataFolder,index));
    if length(data) == 1
        data_tmp = options.ms.crop(data);
    else
        data_tmp = data;
    end
    
    for dataIndex = 1:length(options.dataChannel)
        data(dataIndex) = merge(data_tmp.ch(dataIndex));
    end
    
    for index2 = 1:length(options.dataChannel)
        tmp = data(index2);
        coordinates = tmp.channelCoordinates;
        if options.rotationDirection == -1
            phi = mod(0 - mean(unique(coordinates.phi)),2*pi);
        else
            phi = mod(mean(unique(coordinates.phi)),2*pi);            
        end
        coordinates = idealCoords;
        coordinates.phi = phi;
        
        tmp.channelCoordinates = coordinates;
        allMeasurementsRaw(index,index2) = tmp;
        

        data_crop      =   ita_time_window(tmp,options.tw,'time');% Q: options.tw = [6ms 8ms]
        % make end sample be div by 4 for daff export
        endSample = round(options.tw(2) .* tmp(1).samplingRate)+1;
        endSample = endSample + mod(endSample,4);
        data_crop      =    ita_time_crop(data_crop,[1 endSample],'samples');

        
        
        % divide by reference
        data_full = ita_divide_spk(data_crop,ref_finished,'regularization',[100 20000]);

        allMeasurements(index,index2) = data_full;
    end
    wb.inc;
end
for dataIndex = 1:length(options.dataChannel)
    allMeasurements_full(dataIndex) = merge(allMeasurements(:,dataIndex));
end

wb.close;

%% additional postprocessing
% time shift, itd correction and normalization
% shift analog zu ramona
for index = 1:2
    allMeasurements_full(index)      = ita_time_shift(allMeasurements_full(index) , 0.0035);
end


tmpCoords = allMeasurements_full(1).channelCoordinates;
% calculate ITD and shift to 0 -- search for "ITD == 0"
[centerPoint,itdData] = ita_HRTFarc_pp_itdInterpolate(allMeasurements_full,tmpCoords,options);
if itdData.error > 0.01
    disp('warning: itd match does not look good. something is wrong in either the data, or the itd method');
end

for dataIndex = 1:length(options.dataChannel)
    tmpCoords = allMeasurements_full(dataIndex).channelCoordinates;
    tmpCoords.phi_deg = mod(tmpCoords.phi_deg -centerPoint,360);
    allMeasurements_full(dataIndex).channelCoordinates = tmpCoords;
end
    


% normalize
if ~isempty(options.normalize)
    allMeasurements_full(1).freqData = allMeasurements_full(1).freqData ./ options.normalize(1);
    allMeasurements_full(2).freqData = allMeasurements_full(2).freqData ./ options.normalize(2);
end

allMeasurements_full = ita_HRTF_postProcessing_smoothLowFreq(allMeasurements_full,'cutOffFrequency',500,'upperFrequency',1200,'timeShift',0);

%% add metadata to result
% append options to userdata
for index = 1:length(allMeasurements_full)
    allMeasurements_full(index).userData = options;
end

% append commit id to history
commitID = ita_git_getMasterCommitHash;
for index = 1:length(allMeasurements_full)
    if ~isempty(commitID)
        allMeasurements_full(index) = ita_metainfo_add_historyline(allMeasurements_full(index),'ita_HRTFarc_postProcessContinuous',commitID);
    end
end

result = allMeasurements_full;
end