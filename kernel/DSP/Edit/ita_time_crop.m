function [ varargout ] = ita_time_crop( varargin )
%ITA_TIME_CROP - Cropping a time signal
%
%   Syntax: ita_time_crop(itaAudio, interval)
%   Syntax: ita_time_crop(itaAudio, interval, usedUnit)
%
%   the syntax for the interval is: [signalBegin signalEnd]
%        a positive interval (signalBegin < signalEnd) preserves the interval
%        a negative interval (signalBegin > signalEnd) cuts out the interval
%
%   usedUnit: can be 'samples' or 'time'
%
%   See also ita_time_window, ita_extract_dat, ita_extend_dat.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  24-Sep-2008


%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Init and Input parsing
% Number of Input Arguments
if nargin == 0 % generate GUI
    
    if ita_preferences('plotcursors')
        vec = ita_plottools_cursors();
        start_time = vec(1);
        end_time = vec(2);
    else
        start_time = 0;
        end_time = 1;
    end
    
    ele = 1;
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the first itaAudio for addition';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Beginning [s]';
    pList{ele}.helptext    = 'start cropping here';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = start_time;
    
    ele = 3;
    pList{ele}.description = 'End [s]';
    pList{ele}.helptext    = 'end cropping here';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = end_time;
    
    ele = 4;
    pList{ele}.datatype    = 'line';
    
    ele = 5;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Add two itaAudio objects']);
    if ~isempty(pList)
        result = ita_time_crop(pList{1},[pList{2} pList{3}],'time');
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{4}, result);
    end
    return;
end


narginchk(2,3);

sArgs   = struct('pos1_num','itaAudioTime');
[audioObj, sArgs] = ita_parse_arguments(sArgs,varargin(1)); 

if numel(audioObj) > 1
    ita_verbose_info([thisFuncStr 'Calling for all instances.'],1)
    result = itaAudio(size(audioObj));
    for idx = 1:numel(audioObj)
        result(idx) = ita_time_crop(audioObj(idx),varargin{2:end}); 
    end
    varargout{1} = result;
    return
end

interval = varargin{2};

% set the used unit type
if (nargin > 2) && ischar(varargin{3})
    usedUnit = varargin{3};
else
    if ~all(rem(interval,1) == 0) % if interval is no integer => time
        usedUnit = 'time';
    else                          % else default unit => samples
        usedUnit = 'samples';
    end
end

%% Define Interval

if strcmpi(usedUnit, 'time')
    % convert from time to number of samples
    interval = round(interval .* audioObj.samplingRate) + 1; %BMA: round inserted
    if isnatural( diff(interval) /2 )
        ita_verbose_info('ita_time_crop:preventing odd sample numbers',1);
        interval(2) = interval(2)-1;
    end
elseif ~strcmpi(usedUnit, 'samples')
    error('ITA_TIME_CROP:InputArgument','I don''t know this Unit type!')
end

if numel(interval) ~=2
    error('ITA_TIME_CROP:InputArgument','I need two limit values!') 
end

if any(interval < 0)
    error('ITA_TIME_CROP:InputArgument','Limit values must be positive!') 
end

if any(interval > audioObj.nSamples)
    error('ITA_TIME_CROP:Limist',['Given limits are not valid. \n' ...
        'Audio object is only ' num2str(audioObj.trackLength) ' (' ...
        num2str(audioObj.nSamples) ' samples) long.']);
end

%% Apply Cropping
if (interval(2) > interval(1))
    audioObj.time = audioObj.time(round(interval(1)):round(interval(2)),:);
else
    audioObj.time = audioObj.time([1:(interval(2)-1) (interval(1)+1):end],:);
end

%% Add History Line
audioObj = ita_metainfo_add_historyline(audioObj,mfilename,varargin);

%% Find Output parameter
varargout{1} = audioObj;