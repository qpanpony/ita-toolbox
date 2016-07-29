function varargout = plus(varargin)
%normal plus

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%$DONTCOMPILE$

narginchk(2,3);
if ~isa(varargin{1},'itaSuper')
    a = varargin{2};
    b = varargin{1};
else
    a = varargin{1};
    b = varargin{2};
end

% write minus in channelnames and histoty?
writeMinus = nargin > 2 && strcmpi(varargin{3}, 'writeMinusInMetaData');
if  writeMinus
    operatorString = ' - ';
    historyString = 'itaSuper.minus';
else
    operatorString = ' + ';
    historyString = 'itaSuper.plus';
end

%% multi instance  AND multi instance
if numel(varargin{1})>1 && (numel(varargin{1}) == numel(varargin{2})) % Multi-Instance
    %     res = a; % init %pdi_ out for audio analytic
    for idx = 1:size(a,1)
        for jdx = 1:size(a,2)
            if writeMinus
                res(idx,jdx) = plus(a(idx,jdx), b(idx,jdx), 'writeMinusInMetaData') ;
            else
                res(idx,jdx) = a(idx,jdx) + b(idx,jdx); 
            end 
        end
    end
    varargout{1} = res;
    return;
end


%% single instance or multi instance with factor
if ~isa(b,'itaSuper')
    if isa(b,'itaValue')
        cte = b.value;
        for idx = 1:numel(a)
            if ~strcmpi(a(idx).channelUnits,b.unit)
                ita_verbose_info('Units do not match. Taking first one.',0)
            end
        end
    elseif isnumeric(b)
        cte = b;
        % TODO: Accept vector with the same size of channels
    else
        error('itaSuper.plus:InputArguments','The second input argument must be either a itaSuper object, a itaValue object or a scalar.')
    end
    
    if ~all(size(a) == size(cte)) % try to expand factor
        cte = repmat(cte(1,1),size(a));
    end
    
    for idx = 1:size(a,1)
        for jdx = 1:size(a,2)
            a(idx,jdx).(a(idx,jdx).domain) = a(idx,jdx).(a(idx,jdx).domain) + cte(idx,jdx); %pdi: changed
            for iChannel = 1:a(idx,jdx).nChannels
                a(idx,jdx).channelNames{iChannel} = [a(idx,jdx).channelNames{iChannel} ' + ' num2str(cte(idx,jdx))];
            end
        end
    end
    varargout{1} = a;
    return
end

if a.domain ~= b.domain
    if isa(b,'itaAudio')
        if isTime(b)
            b = fft(b);
        else
            b = ifft(b);
        end
    end
    % Check if signals are compatible
    ita_check_compatibility(a,b,'samplingRate','size');
end

if isa(a,'itaAudioAnalyticRational')
    a = a';
    b = b';
end


%% One channel will be added to all others if one struct has one channel and the other more than one
if a.nChannels == 1 && b.nChannels > 1
    a = split(a,ones(b.nChannels,1));
end
if a.nChannels > 1 && b.nChannels == 1
    b = split(b,ones(a.nChannels,1));
end

%% DATA compatibility checking
result = a;        % This way output-type is equal to input-type and Header settings are taken

%% Adding Data
result.data  = a.data + b.data;

aChannelNames = a.channelNames;
bChannelNames = b.channelNames;
aChannelUnits = a.channelUnits;
bChannelUnits = b.channelUnits;
resChannelNames = result.channelNames;
% Check Units and names
for idx = 1:a.nChannels
    resChannelNames{idx} = [aChannelNames{idx} operatorString bChannelNames{idx}];
    if ~strcmp(aChannelUnits{idx}, bChannelUnits{idx}) && ~isempty(aChannelUnits{idx}) && ~isempty(bChannelUnits{idx}) 
        ita_verbose_info(['itaSuper.plus:Units do not match in Channel ' num2str(idx) ' Do you really know what you do?'],1)
    end
end
result.channelNames = resChannelNames;

%% Add history line
varargout{1} = ita_metainfo_add_historyline(result,historyString ,varargin,'withSubs');
end