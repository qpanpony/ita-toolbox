function varargout = rdivide(varargin)
% writing to varargin ensures identical dimensions for in- and output

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

for ind = 1:numel(varargin{1})
    varargout{1}(ind) = divide_dat(varargin{1}(ind), varargin{2}(ind));
end

end % function
%

function varargout = divide_dat(varargin)
narginchk(2,2);
a = varargin{1};
b = varargin{2};

if isa(b,'itaValue') || isnumeric(b)
    varargout{1} = ita_amplify(a,1/b);
    return;
elseif isa(a,'itaValue') || isnumeric(a)
    varargout{1} = ita_amplify(power(b,-1),a);
    return;
end

if isFreq(varargin{1}) || isFreq(varargin{2})
    error('itaResult.rdivide:your signals are not in the time domain, use operator / instead!');
else
    ita_verbose_info('itaResult.rdivide:division in time domain, I hope you know what you are doing!',1);
end

%% One channel will be added to all others if one struct has one channel and the other more than one
if a.nChannels == 1 && b.nChannels > 1
    a.data = repmat(a.data,1,b.nChannels);
    a.channelNames(2:b.nChannels) = a.channelNames(1);
    a.channelUnits(2:b.nChannels) = a.channelUnits(1);
    a.channelCoordinates(2:b.nChannels) = a.channelCoordinates(1);
    a.channelOrientation(2:b.nChannels) = a.channelOrientation(1);
    a.channelSensors(2:b.nChannels) = a.channelSensors(1);
    a.channelUserData(2:b.nChannels) = a.channelUserData(1);
end
if a.nChannels > 1 && b.nChannels == 1
    b.data = repmat(b.data,1,a.nChannels);
    b.channelNames(2:a.nChannels) = b.channelNames(1);
    b.channelUnits(2:a.nChannels) = b.channelUnits(1);
    b.channelCoordinates(2:a.nChannels) = b.channelCoordinates(1);
    b.channelOrientation(2:a.nChannels) = b.channelOrientation(1);
    b.channelSensors(2:a.nChannels) = b.channelSensors(1);
    b.channelUserData(2:a.nChannels) = b.channelUserData(1);
end

%% Divide Data
result = a;
result.(a.domain)  = a.(a.domain) ./ b.(b.domain);

%% Check last character in Channel Units and set channel names
aChannelUnits = a.channelUnits;
aChannelNames = a.channelNames;
bChannelUnits = b.channelUnits;
bChannelNames = b.channelNames;
resChannelUnits = result.channelUnits;
resChannelNames = result.channelNames;
for idx = 1:result.nChannels
    try %#ok<TRYNC> %pdi added. empty string has problems
        if isequal(resChannelUnits{idx}(end), '/')
            resChannelUnits{idx} = resChannelUnits{idx}(1:end-1);
        end
        if isequal(resChannelNames{idx}(end), '/')
            resChannelNames{idx} = resChannelNames{idx}(1:end-1);
        end
    end
    %% Channels
    resChannelNames{idx} = [aChannelNames{idx} ' / ' bChannelNames{idx}];
    resChannelUnits{idx} = ita_deal_units(aChannelUnits{idx},bChannelUnits{idx},'/');
end
result.channelUnits = resChannelUnits;
result.channelNames = resChannelNames;

%% Check for singularties
result.(result.domain)(~isfinite(result.(result.domain))) = 0;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,'itaResult.rdivide',varargin,'withSubs');
end