function varargout = ita_vibro_processMeasurements(varargin)
%ITA_VIBRO_PROCESSMEASUREMENTS - process output of laser measurements
%  This function processes all the measurement files to reduce the amount
%  of data and do some windowing in time domain to reduce noise.
%  Input arguments are the directory where the files have been saved, a vector
%  with starting time and end time for windowing.
%  The result contains each node as a channel, the node IDs are saved in
%  the user data.
%
%  Options:
%        xfade_freq ([])       : used for frequency_dependent windows
%        xfade_range ([])      :                  "
%        fraction ([])         : fraction to define the bandwith for evaluation
%                              (if empty, no frequency sampling is applied)
%        freqVec ([125 16000]) : frequency limits for the evaluation
%        type ('lin')          : type of frequency sampling ('lin'/'log')
%
%  Call: result = ita_vibro_processMeasurements(directory,[t1 t2])
%  Call: result = ita_vibro_processMeasurements(directory,[t1 t2],'fraction',fraction)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_processMeasurements">doc ita_vibro_processMeasurements</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Jan-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_directory','anything','pos2_timeVec','double','pos3_measurementGrid','itaMeshNodes','xfade_freq',1000,'xfade_range',100,'fraction',[],'freqVec',[125 16000],'type','lin','symmetric',true);
[directory,timeVec,measurementGrid,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Body
comeFrom = pwd;                     % save current directory to return when finished
cd(directory)

files       = dir('*.ita');
nNodes      = size(files,1);            % number of nodes
% get the center frequencies with indices related to the original frequency vector
tmp = ita_read(files(1).name);

if ndims(timeVec) == 1 || isempty(sArgs.xfade_freq)
    % actually just regular time windowing
    timeVec = repmat(timeVec(:).',[2 1]);
    sArgs.xfade_freq = tmp.samplingRate/4;
end

if isempty(sArgs.fraction) % no frequency sampling
    ids                 = 1:tmp.nBins;
    result              = itaAudio();
    result.samplingRate = tmp.samplingRate;
    result.signalType   = tmp.signalType;
elseif strcmpi(sArgs.type,'log') % logarithmic frequency sampling
    f                 = ita_ANSI_center_frequencies(sArgs.freqVec,sArgs.fraction);
    ids               = tmp.freq2index(f);
    result            = itaResult();
    result.freqVector = f; % frequency bins
    result.resultType = 'processed vibrometer data';
else % linear frequency sampling
    f                 = min(sArgs.freqVec):sArgs.fraction:max(sArgs.freqVec);
    ids               = tmp.freq2index(f);
    result            = itaResult();
    result.freqVector = f; % frequency bins
    result.resultType = 'processed vibrometer data';
end
% allows for multiple channels per scan point (reference signal)
data = zeros(numel(ids)+1,nNodes,tmp.nChannels);
result.freq = data;
interpolationIndices = zeros(nNodes,1);
channelNames = result.channelNames;
channelUnits = result.channelUnits;
channelCoordinates = itaMeshNodes(tmp.nChannels*nNodes);
channelCoordinates.ID = (-tmp.nChannels*nNodes:-1).';

for i=1:nNodes                              % for each measurement
    filename         = files(i).name;
    ita_verbose_info([thisFuncStr 'Processing file: ' filename],1);
    [direc,fname]    = fileparts(filename); %#ok<ASGLU>
    node             = str2double(fname(4:end)); % get nodeID from filename
    [tmpX,tmpY,tmpZ] = ita_findCoordsFromNode(measurementGrid,node);
    channelCoordinates.ID(i + [0 1]*nNodes) = node + [0 1]*nNodes;
    channelCoordinates.cart(i  + [0 1]*nNodes,:) = repmat([tmpX,tmpY,tmpZ],tmp.nChannels,1);
    windowResult     = ita_frequency_dependent_time_window(ita_read(filename).', ...
        timeVec,sArgs.xfade_freq,'range',sArgs.xfade_range,'symmetric',sArgs.symmetric); % windowing
    channelNames(i + [0 1]*nNodes)  = windowResult.channelNames;
    channelUnits(i + [0 1]*nNodes)  = windowResult.channelUnits;
    data(1,i,:)      = node + [0 1]*nNodes; % nodeID
    data(2:end,i,:)  = windowResult.freqData(ids,:); % values at (center) frequencies
    
    % try to detect noisy measurements 
    % TODO: improve detection
    if (max(abs(diff(data(2:end,i,1)))) <= 10^-10) % || (20*log10(abs(windowResult.freq2value(200))) < -20)
        ita_verbose_info([thisFuncStr 'warning, noisy measurements detected for node ' fname(4:end) ', will try interpolation later'],1);
        interpolationIndices(i) = 1;
        data(2:end,i,1) = (10^-10);
    end
end

[data,sortIdx]      = sortrows(reshape(data,[numel(ids)+1,nNodes*tmp.nChannels]).',1); % sort per node ID
result.userData{1}  = 'nodeN';       % save the node IDs in UserData
result.userData{2}  = data(:,1).';   % save the node IDs in UserData
result.comment      = 'processed vibro data';
result.channelUnits = channelUnits(sortIdx);

% save the temporary data before trying to interpolate the noisy
% measurements
data               = reshape(data(:,2:end).',[numel(ids),nNodes,tmp.nChannels]);
channelCoordinates = channelCoordinates.n(sortIdx);
channelNames       = channelNames(sortIdx);

interpolateIdx = find(interpolationIndices~=0);
nInterpolate   = numel(interpolateIdx);

if nInterpolate > 0
    ita_verbose_info([thisFuncStr 'interpolating noisy measurement points'],1);
    mesh = build_search_database(channelCoordinates);
    for i = 1:nInterpolate
        % find the 6 closest other points (7 including the current one)
        [tmpIdx,dist] = mesh.findnearest(mesh.n(interpolateIdx(i)),'cart',7);
        tmpIdx = tmpIdx(dist<=0.005);
        tmpIdx = tmpIdx(~ismember(tmpIdx,interpolateIdx));
        tmpIdx = tmpIdx(tmpIdx~=i);
        if numel(tmpIdx > 0)
            data(:,interpolateIdx(i)) = mean(data(:,tmpIdx),2);
            channelNames{interpolateIdx(i)} = [channelNames{interpolateIdx(i)} ' (interpolated)'];
        end
    end
end

result.freq               = data;
result.channelCoordinates = channelCoordinates;
result.channelNames       = channelNames;
cd(comeFrom);               % back to where we came from

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end