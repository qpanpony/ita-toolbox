function varargout = ita_amplify(varargin)
%ITA_AMPLIFY - Amplify audio data
%  This function amplifies the given audio data with the given factor.
%
%  Syntax: asData = ita_amplify(itaAudio, factor)
%
%  factor: is a linear scaling factor (float32) or a string - such as '3dB'
%
%  Examples:
%   asData = ita_amplify(itaAudio,3) amplifies the signal by 9.5 dB or 20log(3)
%   asData = ita_amplify(itaAudio,[3 1 2]) amplifies different channels with different factors
%   asData = ita_amplify(itaAudio,[0 3 6],'dB') amplifies different channels with different factors in dB
%   asData = ita_amplify(itaAudio,'3dB') amplifies the signal by 3dB
%
%   See also ita_normalize, ita_multiply_spk, ita_add.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_amplify">doc ita_amplify</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  03-Sep-2008



%% GUI Required?
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'This is the itaAudio Object for amplification or attenuation';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Factor';
    pList{ele}.helptext    = 'Factor can be e.g. ''0dB'' or ''1+5j'' or ''20 Pa'' ' ;
    pList{ele}.datatype    = 'char';
    pList{ele}.default     = '0dB';
    
    ele = 3;
    pList{ele}.datatype    = 'line';
    
    ele = 4;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Amplify an itaAudio object']);
    if ~isempty(pList)
        result = ita_amplify(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end


%% Initialization
narginchk(2,3);
sArgs   = struct('pos1_a','itaSuper','pos2_mult','anything');
[data,multFactor,sArgs] = ita_parse_arguments(sArgs,varargin(1:2)); 

dB_flag = false;
if nargin == 3
    if strcmpi(varargin{3},'db')
        dB_flag = true;
    else
        error('Third input argument not accepted. Please check the help file.');
    end
end

% Find the Factor
multUnit = ''; 
if isa(multFactor,'itaValue')
    multUnit   = multFactor.unit;
    multFactor = multFactor.value;
end

if ischar(multFactor)
    try
        if isequal(lower(varargin{2}(end-1:end)),'db')
            if length(multFactor) == 2 %dB without prefix bugfix
                multFactor = 1; % only dB given
            else
                multFactor = str2num(multFactor(1:end-2)); %#ok<ST2NM>
            end
            dB_flag = true;
        elseif isequal(lower(varargin{2}(end-3:end)),'dbfs')
            multFactor = str2num(multFactor(1:end-4)); %#ok<ST2NM>
            dB_flag = true;
        else
            multFactor = str2double(multFactor);
        end
    catch %#ok<CTCH>
        multFactor = str2double(multFactor);
    end
else
    sizeData = size(data.(data.domain));
    if length(multFactor) == 1  % make a vector out of multFactor if only one value is given
        %         multFactor = repmat(multFactor,sizeData); %pdi: do nothing, this
        %         is saving computation time
        
    elseif length(multFactor) == data.nChannels
        multFactor = multFactor(:)';
        %         reps = size(data.(data.domain),1);
        %        multFactor = repmat(multFactor,reps,1);
        
    elseif length(multFactor) == sizeData(1) %mpo
        ita_verbose_info('ita_amplify:Please report to PDI if you use this option !',0)
        % this is a time window
        multFactor = multFactor(:);
        % enlarge to fit the size of the data
        multFactor = repmat(multFactor,[1 sizeData(2:end)]);
    else
        error([mfilename, ': The multiplication vector does not fit to the amount of channels in the audio struct.'])
    end
end

%% In case the amplification was given in dB (BMA)
if dB_flag
    multFactor = 10.^(multFactor./20); % sfi factor./20 instead ./10
end

%% Amplify
data.(data.domain) = bsxfun(@times,data.(data.domain), multFactor);

%% Handle Units
if ~isempty(multUnit)
    channelUnits = data.channelUnits;
    res = cell(numel(channelUnits),1);
    uniqueVals = unique(channelUnits);
    if numel(uniqueVals) == 1
        res(:)          = {ita_deal_units(uniqueVals{1}, multUnit, '*')};
    else
        for i = 1:numel(uniqueVals)
            tmpVal = ita_deal_units(uniqueVals{i} , multUnit, '*');
            res(strcmpi(channelUnits,uniqueVals{i})) = {tmpVal};
        end
    end
    data.channelUnits = res;
end

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};
%end function
end