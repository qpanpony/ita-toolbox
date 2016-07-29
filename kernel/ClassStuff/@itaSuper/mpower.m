function varargout = mpower(varargin)
%operation power in freq domain

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

narginchk(2,2);

exponent = varargin{2};
for ind = 1:numel(varargin{1})
    audioObj = varargin{1}(ind);
    
    if isa(exponent,'itaSuper') %the exponent is an itaAudio, wow
        
        result = exponent;
        if isa(audioObj,'itaSuper')
            data_mat = audioObj.data;
        else
            data_mat = audioObj;
        end
        result.data = data_mat .^ exponent.data;
        varargout{1} = result;
        
    else
        
        if exponent == -1
            varargout{1} = ita_invert_spk(audioObj);
        else
            audioObj.freqData = audioObj.freqData.^exponent;
            channelUnits = audioObj.channelUnits;
            if numel(unique(channelUnits)) == 1
                channelUnits(:) = {ita_deal_units(channelUnits{1},['^' num2str(exponent)])};
            else
                for idx=1:audioObj.nChannels
                    channelUnits{idx} = ita_deal_units(channelUnits{idx},['^' num2str(exponent)]); %TODO
                end
            end
            audioObj.channelUnits = channelUnits;
            audioObj.channelNames = ita_sprintf('(%s)^%s', audioObj.channelNames, num2str(exponent));
            % Add history line
            varargout{1}(ind) = ita_metainfo_add_historyline(audioObj,'itaSuper.mpower',{audioObj,num2str(exponent)});
        end
    end
end
