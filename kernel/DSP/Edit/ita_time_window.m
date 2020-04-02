function [ varargout ] = ita_time_window( varargin )
%ITA_TIME_WINDOW - Applying a time window
%   This function applies a time window to a given input time signal with starting time
%   and length, both in seconds. As a special feature also exponential
%   windows can be used as commonly used by measuring forces and accelerations with impact hammers.
%
%   Syntax: ita_time_window(dat, interval, windowType, usedUnit)
%           usedUnit = 'samples' or 'time'
%   Syntax: ita_time_window(dat, interval, windowType)
%           windowType = @hann, @rectwin, @kaiser ... and not '@hann', '@rectwin', '@kaiser'
%                    (all windows of signal processing toolbox supported)
%   Syntax: ita_time_window(dat, [intervalVector]) assumes @hann window
%   Syntax: ita_time_window(dat, [intervalVector], Options) assumes @hann window
%   Syntax: ita_time_window(dat, tau)      assumes exponantial window
%   Syntax: ita_time_window(dat)      assumes @hann window over the whole track
%           TODO: make this call work again
%
%   Options (default):
%       symmetric (false) - symmetric around zero (for non causal impulse responses)
%       crop      (false) - dumps the zeros and makes the file shorter
%       extract   (false) - same as crop but using symmetric window for the given interval
%       adaptive  (false) - Adjust time/sample interval according to maximum of signal, e.g. use interval [0 0.1 0 -0.1] to extract an impulse resonse with an symmetric window, independent of the delay of the impulse
%       adaptivechno ()   - Channel to use when searching for the maximum of the impulse, if empty, a weighted mean maximum is used (the "middle" of all impulses)
%       channeladaptive (false) - same as adaptive but independent for every channel
%       dc (false) - dc correction after m�ller (bma)
%
%   Example:
%      sweep  = ita_generate_sweep('freqRange',[2 22000]);
%      result = ita_time_window(sweep,[2,1, 19,20],@hann,'time')
%        a left sided Hamming window is applied to the sweep between 1 and
%        2 seconds. The order of the interval is 2,1 and not 1,2. This is
%        so for a left sided window.
%        A right sided window between 19 and 20 seconds.  'time' tells the
%        function to use the values in seconds instead of  samples.
%
%      result = ita_time_window(sweep,[0.4,0.1],'time',@hann,'symmetric')
%       gives as output a window like:   _/xxxx\_
%      result = ita_time_window(sweep,[0.1,0.4],'time','symmetric')
%       also does the same as the [0.4,0.1]
%      result = ita_time_window(sweep,[4,5],'time','crop')
%
%      (the order of the numbers determines whether the window is left sided or right sided)
%
%      The 'symmetric' flag is used to get a symmetric window around the y-axis, i.e.
%       around 0 seconds. That is really useful when an impulse response
%       is slightly non-causal.
%
%
%   the syntax for the intervall is:
%              [beginSlope1 endSlope1 beginSlope2 endSlope2 ... ]
%                   (the function can handle as many slopes as you like)
%
%      window_length = 3*4410; fft_degree = 16;
%      window = [window_length 1 2^fft_degree-window_length 2^fft_degree];
%      itaAudioWin = ita_time_window(itaAudio, window, @hann, 'Samples');
%
%   See also ita_plot_dat, ita_plot_dat_dB.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_time_window">doc ita_time_window</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-May-2008



% TODO % detect non-integer time-samples for window limits. probably user
% typed [0.2 0.4] as vector and meant to say [0.2 0.4], 'time'

% TODO % make a function that only returns a time window, should be applied with
% overloaded operator "*". Faster than always calling ita_time_window.

%% Init
thisFuncStr  = [upper(mfilename) ':'];

%% GUI Required?
if nargin == 0
    cursors = [0 0.1];
    try %#ok<TRYNC>
        aux = ita_plottools_cursors();
        if max(aux < 10) %probable time domain
            cursors = aux;
        end
    end
    
    pList = [];
    
    ele = length(pList) + 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'This is the itaAudio Object for time windowing';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Time Window Start';
    pList{ele}.helptext    = 'start at this time/sample to apply a window. If start time is greater than end time, a left sided window is applied.' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = cursors(1);
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Time Window End';
    pList{ele}.helptext    = 'end at this time/sample to apply a window' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = cursors(2);
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Limit Units';
    pList{ele}.helptext    = 'Are your limits given as samples or in seconds as time?' ;
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'time';
    pList{ele}.list       = 'time|samples';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description    = 'Advanced Settings';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Window Type';
    pList{ele}.helptext    = 'Type of window function' ;
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = '@hann';
    pList{ele}.list        = ['hann|hamming|bartlett|barthannwin|blackman|' ...
        'blackmanharris|bohmanwin|chebwin|gausswin|kaiser|rectwin|taylorwin|triang|expo'];
    
    %     @bartlett       - Bartlett window.
    %     @barthannwin    - Modified Bartlett-Hanning window.
    %     @blackman       - Blackman window.
    %     @blackmanharris - Minimum 4-term Blackman-Harris window.
    %     @bohmanwin      - Bohman window.
    %     @chebwin        - Chebyshev window.
    %     @flattopwin     - Flat Top window.
    %     @gausswin       - Gaussian window.
    %     @hamming        - Hamming window.
    %     @hann           - Hann window.
    %     @kaiser         - Kaiser window.
    %     @nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
    %     @parzenwin      - Parzen (de la Valle-Poussin) window.
    %     @rectwin        - Rectangular window.
    %     @taylorwin      - Taylor window.
    %     @tukeywin       - Tukey window.
    %     @triang
    %
    ele = length(pList) + 1;
    pList{ele}.description = 'Symmetric Window';
    pList{ele}.helptext    = 'Useful for acausal impulse responses. Symmetric around zero.' ;
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Time Crop';
    pList{ele}.helptext    = 'Crop result to windowed ranged' ;
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Time Windowing for itaAudio objects']);
    if ~isempty(pList)
        result = ita_time_window(pList{1},[pList{2} pList{3}],pList{4},'windowtype',pList{5},'symmetric',pList{6},'crop',pList{7});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{8}, result);
    else
        varargout{1} = [];
    end
    return;
end

%% set default values
defaultUsedUnit   = 'samples';
defaultWindowType = @hann; %@rectwin; rectwin does not make sense as standard

%% Initialization and Input Parsing
narginchk(1,20); 

% Where is the window-function handle used
handle_pos = 0;
for iargin = 1:nargin
    if isa(varargin{iargin}, 'function_handle')
        handle_pos = iargin;
    end
end
if handle_pos
    sArgs.windowtype = varargin{handle_pos};
    varargin = varargin([1:handle_pos-1,handle_pos+1:end]);
else
    sArgs.windowtype = defaultWindowType;
end

if nargin == 1 && isa(varargin{1},'itaAudio') % hann window over whole length
    trackLength = double(varargin{1}.trackLength);
    varargin{2} = [0.03 0.001 0.97 0.999].*trackLength;
end

% Define default values
sArgs.pos1_audioObj  = 'itaAudio';
sArgs.pos2_interval     = [];
sArgs.symmetric         = false;
sArgs.crop              = false;
sArgs.extract           = false;
sArgs.time              = false;
sArgs.samples           = false;
sArgs.adaptive          = false;
sArgs.adaptivechno      = [];
sArgs.channeladaptive   = false;
sArgs.dc                = false; % Swen's Colva window
sArgs.DCcorrectionMode  = ''; % could be 'pdi', adaption of Swen's Colva Method
sArgs.returnWindow      = false;


% Parse arguments
[audioObj, interval, sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(audioObj) > 1
    ita_verbose_info([thisFuncStr 'Calling for all instances.'],1)
    result = itaAudio(size(audioObj));
    for idx = 1:numel(audioObj)
        result(idx) = ita_time_window(audioObj(idx),varargin{2:end}); 
    end
    varargout{1} = result;
    return
end

% if no interval is given, use maximum interval size
if isempty(interval)
    ita_verbose_info('ITA_TIME_WINDOW:applying maximum interval',1);
    lengthData = size(audioObj.data,1);
    interval = [lengthData/2 1 (lengthData/2)+1 lengthData];
end

if ~sArgs.samples && ~sArgs.time && (~isnatural(interval(1)) || ~isnatural(interval(2)))
    ita_verbose_info('ITA_TIME_WINDOW:Using time instead of samples, interval does not have natural numbers !!!',0)
    sArgs.time = true;
elseif ~sArgs.samples && ~sArgs.time
    sArgs.samples = true;
end



%% Adaptive window for every channel:
if sArgs.channeladaptive && audioObj.nChannels > 1
    %oldheader = audioObj;
    for idch = 1:audioObj.nChannels
        newargs = {ita_metainfo_rm_historyline(ita_split(audioObj,1)) varargin{2:end} 'adaptive'};
        audioObj = ita_merge(ita_split(audioObj,2:audioObj.nChannels),ita_time_window(newargs{:}));
        audioObj = ita_metainfo_rm_historyline(audioObj);
    end
    %audioObj = oldheader;
else
    
    %% Check if time or samples arguments are set
    if sArgs.time && ~sArgs.samples
        usedUnit = 'time';
    elseif sArgs.samples && ~sArgs.time
        usedUnit = 'samples';
    elseif sArgs.samples && sArgs.time
        error('ITA_TIME_WINDOW:Oh Lord, you have to decide for one of both, time or samples')
    else
        usedUnit = defaultUsedUnit;
    end
    
    symmetric_flag = sArgs.symmetric;
    crop_flag = sArgs.crop;
    extract_flag = sArgs.extract;
    shiftsamples = 0; %Used for adaptive windows
    
    if ~isempty(sArgs.windowtype) && ~strcmpi(sArgs.windowtype,'anything')
        windowType = sArgs.windowtype;
    else
        windowType = defaultWindowType;
    end
    
    if nargin > 1 && numel(varargin{2}) == 1 % then it is the exponantial window
        time_tau = varargin{2};
        windowType = 'expo';
    else % standard window
        %     interval = varargin{2}; :pdi, better input parsing
        
        if strcmp(usedUnit, 'time')
            % convert from time to samples
            %             interval = floor(interval .* audioObj(1).samplingRate); %
            %             mmt: hope this fixes our bug--PDI:no it does not ;)
            %PDI: if the tracklength is given as ending time, that is actually the
            %problem. audio objects have a time vector that stops directly before!!!
            %the trackLength. That is caused by the indexing starting at 0 (seconds)
            %and 1 samples
            interval = round(interval .* audioObj(1).samplingRate)+1; %pdi - otherwise broken samples!
            if interval(2) == audioObj(1).nSamples+1 %pdi: that is a quick and dirty bug fix...
                interval(2) = interval(2)-1;
            end
            interval = interval + mod(interval,2); %RSC - prevent uneven samples
            %interval(find(interval==0))=1; %#ok<FNDSB>
        end
        
        % Adaptive time windows
        if sArgs.adaptive || (sArgs.channeladaptive && audioObj.nChannels == 1)
            % Find maximum
            if isempty(sArgs.adaptivechno) %Weighted mean for all channels
                [maxamplitude, maxpos]  = max(abs(audioObj.dat),[],2); %#ok<ASGLU>
                %                 meanmaxpos = round(sum(maxpos .* maxamplitude) ./ sum(maxamplitude)); %Weighted mean from all peaks
            else %Maximum of selected channel
                [maxamplitude, maxpos]  = max(abs(audioObj.dat(sArgs.adaptivechno,:)),[],2); %#ok<ASGLU>
            end
            
            interval = interval + round(mean(maxpos));
        end
        
        % Compensation for interval < 1 or bigger size of audio
        if any(interval(1:2) < 1)
            shiftsamples = round(audioObj.nSamples / 2);
            audioObj = ita_time_shift(audioObj,shiftsamples,'samples');
            audioObj = ita_metainfo_rm_historyline(audioObj);
            interval = interval + shiftsamples;
        elseif any(interval(1:2) > audioObj.nSamples)
            shiftsamples = round(audioObj.nSamples / 2);
            audioObj = ita_time_shift(audioObj,-shiftsamples,'samples');
            audioObj = ita_metainfo_rm_historyline(audioObj);
            interval = interval - shiftsamples;
        end
        
        if max(interval(:)) > audioObj.nSamples
            ita_verbose_info(['ITA_TIME_WINDOW:Oh Lord. Limits out of signal bounds ' num2str(max(interval(:))) ' samples. Continuing...'])
            interval = min(interval, audioObj.nSamples);
        end
        
        if diff(interval(1:2)) == 0 && interval(1) == audioObj.nSamples
            ita_verbose_info('ITA_TIME_WINDOW:Nothing to be done. Exiting...');
            if sArgs.returnWindow
                varargout{1} = ones(audioObj.nSamples,1);
            else
                varargout{1} = varargin{1};
            end
            return;
        end
        
        if numel(interval) > 2
            if (round(numel(interval)/2) ~= numel(interval)/2)
                ita_verbose_info('ITA_TIME_WINDOW:last recursion will be an exponential window.',0);
            end
            ita_verbose_info('ITA_TIME_WINDOW:Calling ita_time_window recursively.',2);
            audioObj = ita_time_window(audioObj, interval(3:end), windowType, 'samples', 'crop',sArgs.crop,'dc',sArgs.dc);
            %             audioObj = ita_metainfo_rm_historyline(audioObj);
        end
        
        intervalStart = interval(1);
        intervalEnd   = interval(2);
    end
    
    %% Generate Window Vector
    if ischar(windowType) && isequal(windowType, 'expo')
        time_vec        = audioObj.timeVector; %in seconds
        windowVector    = exp(- time_vec ./ time_tau);
    else % other normal windows
        if ~extract_flag
            lengthWindow    = (2 * (abs(intervalEnd - intervalStart) + 1));  % x2 since double sided
            window_part_vec = window(windowType,lengthWindow).';
            
            if crop_flag
                if (intervalStart < intervalEnd)
                    % 111111111 'falling window slope'
                    windowVector = [ones(1,(intervalStart-1)) ...
                        window_part_vec(((end/2)+1):end)];
                    % crop data vector to vector length
                    audioObj.dat = audioObj.dat(:,1:length(windowVector));
%                     if ~isempty(oldWindow)
%                         oldWindow = oldWindow(1:length(windowVector));
%                     end
                else
                    % 'rising window slope' 111111111
                    windowVector = [...
                        window_part_vec(1:((end/2))) ones(1,audioObj.nSamples-intervalStart)];
                    % crop data vector to vector length
                    audioObj.dat = audioObj.dat(:,intervalEnd:end);
%                     if ~isempty(oldWindow)
%                         oldWindow = oldWindow(intervalEnd:end);
%                     end
                end
                % refresh header
                %                audioObj = ita_metainfo_check(audioObj);% header.nSamples = size(dat,2);
                
            else
                if (intervalStart <= intervalEnd)
                    % 111111111 'falling window slope' 000000000
                    windowVector = [ones(1,(intervalStart-1)) ...
                        window_part_vec(((end/2)+1):end) zeros(1,audioObj.nSamples-intervalEnd)];
                else
                    %  000000000 'rising window slope' 111111111
                    windowVector = [zeros(1,(intervalEnd-1)) ...
                        window_part_vec(1:((end/2))) ones(1,audioObj.nSamples-intervalStart)];
                end
            end
        else
            lengthWindow    = ((abs(intervalEnd - intervalStart) + 1));
            windowVector = window(windowType,lengthWindow).';
            
            % crop data vector to vector length
            audioObj.dat = audioObj.dat(:,intervalStart:intervalEnd);
            %            audioObj = ita_metainfo_check(audioObj);% header.nSamples = size(dat,2);
        end
    end
    
    %% Symmetric?
    if symmetric_flag
        windowVector = windowVector + windowVector(end:-1:1);
        windowVector = windowVector - min(min(windowVector));
    end
    
%     if ~isempty(oldWindow)
%         windowVector = windowVector(:) .* oldWindow(:);
%     end
    
    if sArgs.returnWindow
        varargout(1) = {windowVector(:)};
        return
    end
    
    %% apply the window
    windowVector = windowVector(:);
    timeData     = bsxfun(@times, audioObj.timeData, windowVector);
    
    % correct DC component (from Diss. Swen Mueller, pg189) - it is the same
    % is shifting the DC of the raw data before windowing
    if sArgs.dc
        if strcmpi(sArgs.DCcorrectionMode,'pdi') % new DC correction, adaption of Swen's Colva-Window to preserve old DC (useful if diracs are windowed)
            %             timeDataAux = bsxfun(@times, audioObj.timeData, windowVector>0);
            timeDataAux = bsxfun(@times, audioObj.timeData,1);

            dc_correction = windowVector*( (sum(timeData,1) - sum(timeDataAux,1))/sum(windowVector));
        else
            dc_correction = windowVector*(sum(timeData,1)/sum(windowVector));
        end
        audioObj.timeData = timeData - dc_correction; %apply time dependent correction
        
    else
        audioObj.timeData = timeData ;
    end
    
    % Shift back (if necessary)
    if shiftsamples ~= 0
        audioObj = ita_time_shift(audioObj,shiftsamples,'samples');
        audioObj = ita_metainfo_rm_historyline(audioObj);
    end
    
end

%% Add history line
audioObj = ita_metainfo_add_historyline(audioObj,mfilename,varargin);

%% Find appropriate Output paramters
varargout(1) = {audioObj};