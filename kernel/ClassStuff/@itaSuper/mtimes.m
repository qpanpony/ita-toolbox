function varargout = mtimes(varargin)
%multiplication in frequency domain

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% if isa(varargin{1},'itaSuper') && numel(varargin{1})>1 && ~isa(varargin{2},'itaSuper') % Multi-Instance multiplied by factor

if isa(varargin{1},'itaSuper') && ~isa(varargin{2},'itaSuper') % Multi-Instance multiplied by factor
    data   = varargin{1};
    factor = varargin{2};
    if ~all(size(data) == size(factor))
        %try to adapt factor
        factor = repmat(factor, size(data));
    end
    for idx = 1:size(data,1)
        for jdx = 1:size(data,2)
            data(idx,jdx) = ita_amplify(data(idx,jdx),factor(idx,jdx));
        end
    end
    varargout{1} = data; %directly leave function, we are ready here
    return
elseif isa(varargin{2},'itaSuper') && ~isa(varargin{1},'itaSuper') % factor multiplied by Multi-Instance
    data   = varargin{2};
    factor = varargin{1};
    if ~all(size(data) == size(factor))
        %try to adapt factor
        factor = repmat(factor, size(data));
    end
    for idx = 1:size(data,1)
        for jdx = 1:size(data,2)
            data(idx,jdx) = ita_amplify(data(idx,jdx),factor(idx,jdx));
        end
    end
    varargout{1} = data; %directly leave function, we are ready here
    return
elseif max(size(varargin{1})) > 1 && max(size(varargin{2})) == 1 % multi instance times single instance
    ita_verbose_info('Elementwise-multiplication of multi instances.',0)
    for idx = 1:size(varargin{1},1)
        for jdx = 1:size(varargin{1},2)
            varargout{1}(idx,jdx) = varargin{1}(idx,jdx) * varargin{2};
        end
    end
    return
elseif max(size(varargin{1})) == 1 && max(size(varargin{2})) > 1 % single instance times multi instance
    ita_verbose_info('Elementwise-multiplication of multi instances.',0)
    for idx = 1:size(varargin{2},1)
        for jdx = 1:size(varargin{2},2)
            varargout{1}(idx,jdx) = varargin{2}(idx,jdx) * varargin{1};
        end
    end
    return
    
elseif numel(varargin{1})>1 && (size(varargin{1},2) == size(varargin{2},1)) % Really: Multi-Instance times Multi-Instance
    
    if max(size(varargin{1})) == 1 && max(size(varargin{2})) == 1 %pdi: was min before - I think this is useless!
        ita_verbose_info('Elementwise-multiplication of multi instances.',0)
        for idx = 1:numel(varargin{1})
            varargout{1}(idx) = varargin{1}(idx) * varargin{2}(idx);
        end
        
        return
    else
        
        ita_verbose_info('3d Matrix-multiplication of multi instances.')
        A = zeros(size(varargin{1},1),size(varargin{1},2),varargin{1}(1,1).nBins);
        B = zeros(size(varargin{2},1),size(varargin{2},2),varargin{2}(1,1).nBins);
        
        dataA = varargin{1};
        dataB = varargin{2};
        
        for ind = 1:size(A,1)
            for jnd = 1:size(A,2)
                A(ind,jnd,:) = dataA(ind,jnd).freq;
            end
        end
        
        for ind = 1:size(B,1)
            for jnd = 1:size(B,2)
                B(ind,jnd,:) = dataB(ind,jnd).freq;
            end
        end
        
        C = zeros(size(A,1),size(B,2),size(A,3)); %init, for speed reasons
        
        for l = 1:size(A,3)
            C(:,:,l) = A(:,:,l)*B(:,:,l);
        end
        
        %% norm
        unitsRes = dataA.unit * dataB.unit;
        new_norm = correct_norm(dataA(1,1).signalType,dataB(1,1).signalType);
        
        %% allocation
        audioObj = dataA(1,1); %pdi: fixed for itaSuper
        audioObj.signalType = new_norm;
        audioObj = repmat(audioObj,size(A,1),size(B,2));
        
        %% unit handling
        
        for idx = 1:size(A,1)
            for jdx = 1:size(B,2)
                audioObj(idx,jdx).freq = squeeze(C(idx,jdx,:));
                audioObj(idx,jdx).channelUnits = unitsRes(idx,jdx).unit;
            end
        end
        
        varargout{1} = audioObj;
        return
    end
    
elseif numel(varargin{1})>1 && numel(varargin{2})>1 % Multi-Instance times Multi-Instance (element wise)
    ita_verbose_info('Elementwise-multiplication of multi instances.',0);
    szVec1 = size(varargin{1});
    szVec2 = size(varargin{2});
    
    if ~all(szVec1 == szVec2)
        error('multiplication with different dimensions of multi-instances not implemented yet');
    end
    
    for idx = 1:numel(varargin{1})
        varargout{1}(idx) = varargin{1}(idx)*varargin{2}(idx);
    end
    return
    
elseif max(size(varargin{1})) > 1 || max(size(varargin{2})) > 1 
    error('Multiplication something went wrong')
end

%% inarg parsing
narginchk(2,2);
if isa(varargin{1},'itaValue') || isnumeric(varargin{1})
    varargout{1} = ita_amplify(varargin{2},varargin{1});
    return;
elseif isa(varargin{2},'itaValue') || isnumeric(varargin{2})
    varargout{1} = ita_amplify(varargin{1},varargin{2});
    return;
elseif isTime(varargin{1})
    varargin{1} = fft(varargin{1});
end

if isa(varargin{2},'itaSuper') && any(isTime(varargin{2}))
    varargin{2} = fft(varargin{2});
end

%% multiplication in frequency domain
ita_verbose_info('itaSuper.mtimes: Multiplication in Frequency domain, when using * operator',2)
num = varargin{1}';
den = varargin{2}';

if isa(num,'itaAudio') && isa(den,'itaAudio')
    % Check if signals are compatible
    ita_check_compatibility(num,den,'samplingRate','size');
end

%% Multiplication and Unit/Name handling
result = num;
result.data     = zeros(num.nBins,max(num.nChannels,den.nChannels)); %pre-allocation
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
    end
    uniqueNumUnits = unique(numChannelUnits);
    uniqueDenUnits = unique(denChannelUnits);
    if numel(uniqueNumUnits) == 1 && numel(uniqueDenUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'*')};
    else
        for idx = 1:num.nChannels
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
    end
    uniqueDenUnits = unique(denChannelUnits);
    if numel(uniqueDenUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'*')};
    else
        for idx = 1:den.nChannels
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
    end
    uniqueNumUnits = unique(numChannelUnits);
    if numel(uniqueNumUnits) == 1
        resChannelUnits(:) = {ita_deal_units(numChannelUnits{1},denChannelUnits{1},'*')};
    else
        for idx = 1:num.nChannels
            resChannelUnits{idx} = ita_deal_units(numChannelUnits{idx},denChannelUnits{1},'*');
        end
    end
else
    error('itaSuper.mtimes:Oh Lord. Number of channels or number of bins do not fit.')
end

result.channelNames = resChannelNames;
result.channelUnits = resChannelUnits;

if isa(num,'itaAudio') || isa(den,'itaAudio')
    % Check FFT norm
    result.signalType = correct_norm(num.signalType,den.signalType);
elseif isa(num,'itaResult') || isa(den,'itaResult')
    % what to do with the resultType
    result.resultType = num.resultType;
end

%% Check for NaN
result.data(~isfinite(result.data)) = 0;

%% Add history line
% result = ita_metainfo_rm_historyline (result,'all');
varargout{1} = ita_metainfo_add_historyline(result,'itaSuper.mtimes',varargin,'withSubs');
end

%% Additional Functions
function result = correct_norm(num,den)
% check the FFTnorm. power/power = energy !
% if isnumeric(num)
%     switch num
%         case 0
%             num = 'power';
%         case 1
%             num = 'energy';
%         case 2
%             num = 'passband';
%     end
% end
num = lower(num);

% if isnumeric(den)
%     switch den
%         case 0
%             den = 'power';
%         case 1
%             den = 'energy';
%         case 2
%             den = 'passband';
%     end
% end
den = lower(den);

if (strcmp(den,'power') && strcmp(num,'energy')) || ...
        (strcmp(num,'power') && strcmp(den,'energy'))
    result = 'power';
elseif strcmp(den,'power') && strcmp(num,'power')
    ita_verbose_info('itaSuper.mtimes:Convolution of two power signals !!!',1);
    result = den;
else%pdi - THIS IS IMPORTANT!!! - both are equal
    result = den;
end
end