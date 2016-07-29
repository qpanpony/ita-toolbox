function data = ita_differentiate(varargin)
%ITA_DIFFERENTIATE - Differentiate signal in time or frequency domain
%This function differentiates a signal in time or frequency domain
% 
%  Syntax: audioObj = ita_differentiate(audioObj)
%
%  Example: audioObj = ita_differentiate(audioObj)
%
%   See also: ita_integrate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_differentiate">doc ita_differentiate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  13-Jul-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,3);
sArgs        = struct('pos1_data','itaAudioFrequency','domain','freq');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back

if size(data,1)>1 || size(data,2)>1
    
    switch sArgs(1,1).domain
        case  'freq'
            ita_verbose_info('3d Matrix Differentiation of Multi Instances.')
            A = zeros(size(data,1),size(data,2),data(1,1).nBins);
            
            for ind = 1:size(A,1)
                for jnd = 1:size(A,2)
                    A(ind,jnd,:) = data(ind,jnd).freq;
                end
            end
            
            freqVector = data(1,1).freqVector;
            C = zeros(size(A,1),size(A,2),size(A,3)); %init, for speed reasons
            denum = 1i * 2 * pi * freqVector;
            
            for lnd = 1:size(A,3)
                C(:,:,lnd) = A(:,:,lnd)*denum(lnd);
            end
            
            audioObj(size(A,1),size(A,2)) = itaAudio ; %back to itaAudio
            
            for idx = 1:size(A,1)
                for jdx = 1:size(A,2)
                    audioObj(idx,jdx).samplingRate = varargin{1}(1,1).samplingRate ;
                    audioObj(idx,jdx).signalType = 'energy';
                    audioObj(idx,jdx).freq = squeeze(C(idx,jdx,:));
                end
            end
            
            data=audioObj;
            
        case 'time'
            
            A = zeros(size(data,1),size(data,2),data(1,1).nBins);
            
            for ind = 1:size(A,1)
                for jnd = 1:size(A,2)
                    A(ind,jnd,:) = data(ind,jnd).time;
                end
            end
            
            bin_dist = data(1,1).samplingRate/data(1,1).nSamples;
            
            for l = 1:size(A,3)
                C(:,:,l) = A(:,:,l)/bin_dist;
            end
            
            for idx = 1:size(A,1)
                for jdx = 1:size(A,2)
                    audioObj(idx,jdx).time = squeeze(C(idx,jdx,:));
                end
            end
            
              data=audioObj;
              
        otherwise
            error([mfilename ': Cant diferentiate in that domain']);
    end
    return
else
    
    switch sArgs.domain
        case 'freq'
            denum = 1j * 2 * pi * data.freqVector;
            data.freqData = bsxfun(@times, data.freqData, denum);
        case 'time'
            ita_verbose_info([thisFuncStr 'Under Construction!'],0)
            bin_dist = data.samplingRate/data.nSamples;
            data.timeData = [data.timeData(1,:); diff(data.timeData,1,1)]/bin_dist;
        otherwise
            error([mfilename ': Cant diferentiate in that domain']);
    end
    
end

channelNames = data.channelNames;
for idx = 1:data.nChannels
    channelNames{idx} = ['d/dt ' channelNames{idx}];
end
data.channelNames = channelNames;

%% TODO this part should move to deal_unit function
channelUnits = data.channelUnits;
res = cell(numel(channelUnits),1);
uniqueVals = unique(channelUnits);
if numel(uniqueVals) == 1
    res(:)          = {ita_deal_units(uniqueVals{1}, 's', '/')};
else
    for i = 1:numel(uniqueVals)
        tmpVal = ita_deal_units(uniqueVals{i} , 's', '/');
        res(strcmpi(channelUnits,uniqueVals{i})) = {tmpVal};
    end
end
data.channelUnits = res;

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

end