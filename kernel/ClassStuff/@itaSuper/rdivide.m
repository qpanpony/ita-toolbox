function varargout = rdivide(varargin)
%nice division

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);
% is it is const/itaAudio reroute to power and amplify
if isa(varargin{1},'itaValue') || isnumeric(varargin{1})
   varargout{1} = ita_amplify(varargin{2}^-1,varargin{1});
   return;
elseif isa(varargin{2},'itaValue') || isnumeric(varargin{2})
    varargout{1} = ita_amplify(varargin{1},1/varargin{2});
    return;
end

%% Initialization
num = varargin{1}.';
den = varargin{2}.';

result = num;
result.data = zeros(size(result.data,1),max(num.nChannels,den.nChannels)); %pre allocation

%% Division and Check length
numChannelNames = num.channelNames;
denChannelNames = den.channelNames;
resChannelNames = result.channelNames;
numChannelUnits = num.channelUnits;
denChannelUnits = den.channelUnits;
resChannelUnits = result.channelUnits;

if num.nChannels == den.nChannels %#ok<*BDSCI>
    result.data    = num.data ./ den.data;
    for idx = 1:num.nChannels
        if isequal(numChannelNames{idx},'') %no channel name
            resChannelNames{idx} = [denChannelNames{idx}];
        elseif isequal(denChannelNames{idx},'') %no channel name
            resChannelNames{idx} = [numChannelNames{idx}];
        else %standard case
            resChannelNames{idx} = [numChannelNames{idx} ' / ' denChannelNames{idx}];
        end
    end
    uniqueNumUnits = unique(numChannelUnits);
    uniqueDenUnits = unique(denChannelUnits);
    if numel(uniqueNumUnits) == 1 && numel(uniqueDenUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'/')};
    else
        for idx = 1:num.nChannels
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{idx},denChannelUnits{idx},'/');
        end
    end
elseif num.nChannels == 1 % only one numerator channel
    result.data = bsxfun(@rdivide,num.data,den.data);
    for idx = 1:den.nChannels
        if isequal(numChannelNames{1},'')
            resChannelNames{idx} = [denChannelNames{idx}];
        elseif isequal(denChannelNames{idx},'')
            resChannelNames{idx} = [numChannelNames{1}];
        else
            resChannelNames{idx} = [numChannelNames{1} ' / ' denChannelNames{idx}];
        end
    end
    uniqueDenUnits = unique(denChannelUnits);
    if numel(uniqueDenUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'/')};
    else
        for idx = 1:den.nChannels
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{1},denChannelUnits{idx},'/');
        end
    end
elseif den.nChannels == 1 % only one denumerator channel
    result.data = bsxfun(@rdivide,num.data,den.data);
    for idx = 1:num.nChannels
        if isequal(denChannelNames{1},'')
            resChannelNames{idx} = [numChannelNames{idx}];
        elseif isequal(numChannelNames{idx},'')
            resChannelNames{idx} = [denChannelNames{1}];
        else
            resChannelNames{idx} = [numChannelNames{idx} ' / ' denChannelNames{1}];
        end
    end
    uniqueNumUnits = unique(numChannelUnits);
    if numel(uniqueNumUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'/')};
    else
        for idx = 1:num.nChannels
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{idx},denChannelUnits{1},'/');
        end
    end
else
    error('itaSuper.rdivide:Oh Lord. Number of channels or number of bins do not fit.')
end

result.channelNames = resChannelNames;
result.channelUnits = resChannelUnits;

%% Check for singularties
result.data(~isfinite(result.data)) = 0;

if isa(result,'itaAudio')
    % Leave FFTnorm of numerator as it is
    result.signalType = num.signalType;
    if isequal(num.signalType,'power') && isequal(den.signalType,'power') % we will get an impulse response
        result.signalType = 'energy';
    end
elseif isa(result,'itaResult')
   % take the resultType from the numerator
   result.resultType = num.resultType;
end

%% Add history line
result = ita_metainfo_rm_historyline (result,'all');
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.mrdivide',varargin,'withSubs');
end