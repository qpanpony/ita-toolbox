function varargout = times(varargin)
% nice multiplication

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% inarg parsing
narginchk(2,2);
if isa(varargin{1},'itaValue') || isnumeric(varargin{1})
    varargout{1} = ita_amplify(varargin{2},varargin{1});
    return;
elseif isa(varargin{2},'itaValue') || isnumeric(varargin{2})
    varargout{1} = ita_amplify(varargin{1},varargin{2});
    return;
elseif isFreq(varargin{1})
    varargin{1} = ifft(varargin{1});
end

if isa(varargin{2},'itaSuper') && isFreq(varargin{2})
    varargin{2} = ifft(varargin{2});
end
%% multiplication in time domain
ita_verbose_info('itaSuper.times: Multiplication in Time domain, when using .* operator',2)
num = varargin{1};
den = varargin{2};

if isa(num,'itaAudio') && isa(den,'itaAudio')
    % Check if signals are compatible
    ita_check_compatibility(num,den,'samplingRate','size');
end

%% Multiplication
result = num;
result.data    = zeros(num.nSamples,max(num.nChannels,den.nChannels)); %pre-allocation
numChannelNames = num.channelNames;
numChannelUnits = num.channelUnits;
denChannelNames = den.channelNames;
denChannelUnits = den.channelUnits;
resChannelNames = result.channelNames;
resChannelUnits = result.channelUnits;

if num.nChannels == den.nChannels
    result.data    = num.data .* den.data;
    for idx = 1:num.nChannels
        if isequal(numChannelNames{idx},'') %no channel name
            resChannelNames{idx} = [denChannelNames{idx}];
        elseif isequal(denChannelNames{idx},'') %no channel name
            resChannelNames{idx} = [numChannelNames{idx}];
        else %standard case
            resChannelNames{idx} = [numChannelNames{idx} ' * ' denChannelNames{idx}];
        end
        
        if isequal(numChannelUnits{idx},'')
            resChannelUnits{idx} = [denChannelUnits{idx}];
        elseif isequal(denChannelUnits{idx},'')
            resChannelUnits{idx} = [numChannelUnits{idx}];
        else
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{idx},denChannelUnits{idx},'*');
        end
    end
elseif num.nChannels == 1 % only one numerator channel
    result.data = bsxfun(@times,num.data,den.data);
    for idx = 1:den.nChannels
        if isequal(numChannelNames{1},'')
            resChannelNames{idx} = [denChannelNames{idx}];
        elseif isequal(denChannelNames{idx},'')
            resChannelNames{idx} = [numChannelNames{1}];
        else
            resChannelNames{idx} = [numChannelNames{1} ' * ' denChannelNames{idx}];
        end
        
        if isequal(numChannelUnits{1},'')
            resChannelUnits{idx} = [denChannelUnits{idx}];
        elseif isequal(denChannelUnits{idx},'')
            resChannelUnits{idx} = [numChannelUnits{1}];
        else
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{1},denChannelUnits{idx},'*');
        end
    end
elseif den.nChannels == 1 % only one denumerator channel
    result.data = bsxfun(@times,num.data,den.data);
    for idx = 1:num.nChannels
        if isequal(denChannelNames{1},'')
            resChannelNames{idx} = [numChannelNames{idx}];
        elseif isequal(numChannelNames{idx},'')
            resChannelNames{idx} = [denChannelNames{1}];
        else
            resChannelNames{idx} = [numChannelNames{idx} ' * ' denChannelNames{1}];
        end
        
        if isequal(numChannelUnits{idx},'')
            resChannelUnits{idx} = [denChannelUnits{1}];
        elseif isequal(denChannelUnits{1},'')
            resChannelUnits{idx} = [numChannelUnits{idx}];
        else
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{idx},denChannelUnits{1},'*');
        end
    end
else
    error('itaSuper.times:Number of channels does not match in any way.')
end

result.channelNames = resChannelNames;
result.channelUnits = resChannelUnits;

%% Add history line
result = ita_metainfo_rm_historyline (result,'all');
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.times',varargin,'withSubs');
end