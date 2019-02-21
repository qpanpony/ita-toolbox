function [ result ] = ita_freqBinFun( input, func, extraArgs )
% Apply arbitrary function to frequency bin data along instances/channels
%
% Input:
%   - input: itaObj
%   - func: function handle - first output argument needs to be the
%   information of interest
%   - extraArgs:    extra arguments the function @func requires
%
% Output
%   - result:    Processed data
% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  28-Jan-2019

ni = nargin;
if ni<3
    extraArgs = [];
    
end
result = input;

if numel(result)>1 % multiple instances
    tmp = result(1);
    data = zeros(size(tmp.freqData,1),prod(tmp.dimensions));
    for idInst = 1:numel(result)
        % extract data from each instance
        data(:,:) = result(idInst).freqData;
        
        for idx = 1:size(data,1) % iterate over all dimensions
            if isempty(extraArgs)
                out(idx,:) = func(data(idx,:));
            else
                out(idx,:) = func(data(idx,:),extraArgs);
            end
        end
        
        % write back into itaObj
        result(idInst).freqData = out;
    end
            
    % reset the channel names based on the individual channel instances
    resChannelNames = result.channelNames;
    for idxCh = 1:result(1).nChannels   %alter name field of all channels
        resChannelNames1{idxCh} = [func2str(func),'(' resChannelNames{idxCh} ')'];
    end
    for idInst = 1:numel(result)
        result(idInst).channelNames = resChannelNames1;
    end

else % over channels

    data(:,:) = result.freqData;
    % freq bin is the first dimension
    for idx = 1:size(data,1) % iterate over all dimensions
        if isempty(extraArgs)
            out(idx,:) = func(data(idx,:));
        else
            out(idx,:) = func(data(idx,:),extraArgs);
        end
    end
    % write data back into ita object
    result.freqData = out;
        
    % reset the channel names based on the comment
    resChannelComment = result.comment;
    resChannelNames = {[func2str(func),'(' resChannelComment ')']};
    result.channelNames = resChannelNames;
end


end

