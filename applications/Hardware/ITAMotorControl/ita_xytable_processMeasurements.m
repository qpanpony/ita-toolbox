function varargout = ita_xytable_processMeasurements(varargin)
%ITA_XYTABLE_PROCESSMEASUREMENTS - +++ Short Description here +++
%  This function processes all the measurement files to reduce the amount
%  of data and do some windowing in time domain to reduce noise.
%  Input arguments are the directory where the files have been saved, a vector
%  with starting time and end time for windowing.
%  The result contains each node as a channel, the node IDs are saved in
%  the user data.
%
%  Syntax:
%   audioObjOut = ita_xytable_processMeasurements(directory,timeVector, options)
%
%  Options:
%        fraction ([])         : fraction to define the bandwith for evaluation
%                              (if empty, no frequency sampling is applied)
%        freqVec ([125 16000]) : frequency limits for the evaluation
%        type ('lin')          : type of frequency sampling ('lin'/'log')
%
%  Example:
%   audioObjOut = ita_xytable_processMeasurements('test',[0.015 0.016])
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_xytable_processMeasurements">doc ita_xytable_processMeasurements</a>

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  17-Feb-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_directory','anything','pos2_timeVec','vector','freqVec',ita_ANSI_center_frequencies([125 16000],12));
[directory,timeVec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Body
comeFrom = pwd;                     % save current directory to return when finished
cd(directory)

files       = dir('*.ita');
nNodes      = size(files,1);            % number of nodes
% get the center frequencies with indices related to the original frequency vector
tmp = ita_read(files(1).name);

if isempty(sArgs.freqVec)
    ids = 1:tmp.nBins;
    result = itaAudio();
    result.samplingRate = tmp.samplingRate;
    result.signalType = 'energy';
else
    ids = tmp.freq2index(sArgs.freqVec);
    result  = itaResult();
    result.freqVector = f; % frequency bins
    result.resultType = 'processed data';
end
% a channel per node
data = zeros(numel(ids),nNodes);
result.freqData = data;
channelCoordinates = itaMicArray(nNodes);
channelCoordinates.ID = -nNodes:-1;
channelNames = result.channelNames;
channelUnits = result.channelUnits;

for i=1:nNodes                              % for each measurement
    filename         = files(i).name;
    ita_verbose_info([thisFuncStr 'Processing file: ' filename],1);
    [direc,fname]    = fileparts(filename);  %#ok<NASGU>
    ind = regexp(filename,'\.');
    ID = str2double(filename(ind(1)+1:ind(2)-1));
    tmp = ita_read(filename);
    coordinateResult = split(tmp,1);
    windowResult     = ita_time_window(split(tmp,2).',timeVec,'time'); % windowing
    coordinateResult.channelCoordinates.ID = ID;
    channelCoordinates = merge(channelCoordinates,coordinateResult.channelCoordinates); 
    channelNames(i)  = windowResult.channelNames(1);
    channelUnits(i)  = windowResult.channelUnits(1);
    data(:,i)        = windowResult.freqData(ids); % values at center frequencies   
end

result.comment                 = 'processed vibro data';
result.channelUnits            = channelUnits;
result.channelCoordinates      = channelCoordinates;
result.channelCoordinates.cart = result.channelCoordinates.cart./1000;
result.channelNames            = channelNames;
result.freqData                = data;
result.userData                = {'nodeN',result.channelCoordinates.ID};
cd(comeFrom);                        % back to where we came from

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Set Output
varargout(1) = {result}; 

%end function
end