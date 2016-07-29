function varargout = ita_time_shift(varargin)
%ITA_TIME_SHIFT - Cyclic time shift
%  This function shifts the audio time data in a cyclic way. The amount of
%  seconds to shift the data has to be specified. If the value is negative,
%  the sequence is shifted to the left. To give the shift time in samples,
%  a flag identifier has to be given.
%  If no shifting time is specified, it tries to shift the first impulse
%  close to the beginning of the audio data.
%
%  Syntax:
%           dat = ita_time_shift(dat, shiftTime)
%           dat = ita_time_shift(dat, shiftTime,'time')
%           dat = ita_time_shift(dat, shiftSamples,'samples')
%           dat = ita_time_shift(dat)
%           dat = ita_time_shift(dat,'10dB')        % TODO: better documentation
%           dat = ita_time_shift(dat,'auto')
%           spk = ita_time_shift(dat, shiftTime,'time','frequencydomain')
%           spk = ita_time_shift(dat, shiftSamples,'samples','frequencydomain')
%           dat = ita_time_shift(dat, '30dB');
%    [dat time] = ita_time_shift(...)                   % return also shifting time
%
%   See also ita_time_window, ita_time_window_sym.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_time_shift">doc ita_time_shift</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 26-Jun-2008

%% GUI required
if nargin == 0
    pList = [];
    
    ele = length(pList) + 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'This is the itaAudio Object for time windowing';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Shifting Time';
    pList{ele}.helptext    = 'Cyclic shift in time domain by this value' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 0;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Unit';
    pList{ele}.helptext    = 'shift samples or seconds' ;
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'time';
    pList{ele}.list        = 'time|samples';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description    = 'Advanced Settings';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Mode';
    pList{ele}.helptext    = 'Normal mode just shifts by the time specified. Auto tries to get the maximum to 0 seconds. Threshold get the point x dBs before the maximum to 0 seconds.' ;
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'normal';
    pList{ele}.list        = 'normal|auto|threshold';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Threshold [dB]';
    pList{ele}.helptext    = 'only used if threshold mode is choosen.' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '30';
    
    pList{ele}.default     = false;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Time Shifting for itaAudio objects']);
    if ~isempty(pList)
        if pList{2} ~= 0; pList{4} = 'normal'; end
        switch lower(pList{4})
            case 'normal'
                result = ita_time_shift(pList{1},pList{2}, pList{3});
            case 'auto'
                result = ita_time_shift(pList{1});
            case 'threshold'
                result = ita_time_shift(pList{1},pList{5});
        end
        if nargout == 1
            varargout{1} = result;
        else
            ita_setinbase(pList{6}, result);
        end
    else
        varargout{1} = [];
    end
    return;
end

%% Initialization and Input Parsing
% narginchk(0,4);
sArgs        = struct('pos1_a','itaAudio','frequencydomain',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin(1));
if nargin == 1 %automatic mode
    ita_verbose_info('ITA_TIME_SHIFT:Auto mode: Try to get maximum close to time zero.',2);
    foundmin_idx = ita_start_IR(data);
    shift_samples = -min(foundmin_idx)+1;
elseif nargin == 2
    if strcmpi(varargin{2},'auto') %automatic mode
        ita_verbose_info('ITA_TIME_SHIFT:Auto mode: Try to get maximum close to time zero.',2);
        foundmin_idx = ita_start_IR(data);
        shift_samples = -min(foundmin_idx)+1;
    else %could be new threshold mode
        if ischar(varargin{2}) && length(varargin{2}) >= 2 && strcmpi(varargin{2}(end-1:end),'dB')
            threshold = str2double(varargin{2}(1:end-2));
            % hier so gut??
            foundmin_idx = ita_start_IR(data,'threshold',threshold);
            shift_samples = -(foundmin_idx)+1; %pdi - without minimum
        elseif isnumeric(varargin{2}) %bma: to agree with help
            shift_time     = varargin{2};
            shift_samples  = round(shift_time .* data.samplingRate);
        else
            error('ITA_TIME_SHIFT:Oh Lord. I do not know this mode')
        end
    end
elseif nargin >= 3
    if ischar(varargin{3})
        switch lower(varargin{3})
            case {'time'}
                shift_time     = varargin{2};
                shift_samples  = round(shift_time .* data.samplingRate);
            case {'samples'}
                shift_samples  = varargin{2};
                shift_time = shift_samples ./ data.samplingRate ;
                if ~isnatural(shift_samples)
                    if ~sArgs.frequencydomain
                        ita_verbose_info('ita_time_shift: Numbers of Samples not a natural number. Be careful.',2)
                    end
                    sArgs.frequencydomain = true;
                end
            otherwise
                error('ITA_TIME_SHIFT:Oh Lord. Please see my syntax.')
        end
    else
        error('ITA_TIME_SHIFT:Oh Lord. Please see my syntax.')
    end
    if nargin == 4
        sArgs.frequencydomain = true;
    end
else% normal mode
    shift_time     = varargin{2};
    shift_samples  = round(shift_time .* data.samplingRate);
end

% %% pdi bug fix:
% if length(shift_samples) ~= data.nChannels
%     shift_samples = repmat(shift_samples(1),1,data.nChannels);
% end

%% Do the Shifting
if ~sArgs.frequencydomain
    if isscalar(shift_samples)
        data.time = circshift(data.time,[double(shift_samples) 0]);
    else
        timeData = data.time;
        for iCh = 1:length(shift_samples)
            timeData(:,iCh) =  circshift(timeData(:,iCh),[double(shift_samples(iCh)) 0]);
        end
        data.time = timeData;
    end
else % if frequencydomain
    %TODO: allow different shift value for different channels also in freq.
    %domain.
    data.freqData = bsxfun(@times, data.freqData , exp(-1i* 2* pi* data.freqVector*shift_time(:)'));
    ita_verbose_info('ita_time_shift: shifting in frequency domain, please be very careful with this one!',1)
end
%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};
if nargout == 2
    varargout(2) = {shift_samples/data.samplingRate};
end
end
