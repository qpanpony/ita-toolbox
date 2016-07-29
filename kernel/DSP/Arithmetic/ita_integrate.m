function data = ita_integrate(varargin)
%ITA_INTEGRATE - Integrate signal in time or frequency domain
% This function integrates the signal in time or frequency domain
%
%  Syntax:
%   audioObj = ita_integrate(audioObj,options)
%
%  Options(default): 'domain' ('freq'):  Integration in time or frequency
%                                        domain
%  Example:
%   audioObj = ita_integrate(audioObj)
%
%   See also: ita_differentiate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_integrate">doc ita_integrate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  13-Jul-2009

%% Initialization and Input Parsing
narginchk(1,3);
sArgs        = struct('pos1_data','itaSuper','domain','freq');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Integration
switch sArgs.domain
    case 'freq'
        denum = 1i * 2 * pi * data.freqVector;
        denum = 1./denum;
        if data.freqVector(1) == 0;
            denum(1,:) = 0;
        end
        data.freqData = bsxfun(@times, data.freqData, denum);
    case 'time'
        if isa(data,'itaResult')
            error([upper(mfilename) ':time domain integration only for itaAudios for now']);
        end
        ita_verbose_info([upper(mfilename) ':Under Construction!'],0)
%         bin_dist = data.samplingRate/data.nSamples;
%         data.timeData = cumsum(data.timeData)*bin_dist;
        data.timeData = cumsum(data.timeData)/data.samplingRate;
    otherwise
        error([mfilename ': Cant integrate in that domain']);
end

channelNames = data.channelNames;
for idx = 1:data.nChannels
    channelNames{idx} = ['int (' channelNames{idx} ')'];
end
data.channelNames = channelNames;

%% TODO this part should move to deal_unit function
channelUnits = data.channelUnits;
res = cell(numel(channelUnits),1);
uniqueVals = unique(channelUnits);
if numel(uniqueVals) == 1
    res(:)          = {ita_deal_units(uniqueVals{1}, 's', '*')};
else
    for i = 1:numel(uniqueVals)
        tmpVal = ita_deal_units(uniqueVals{i} , 's', '*');
        res(strcmpi(channelUnits,uniqueVals{i})) = {tmpVal};
    end
end
data.channelUnits = res;

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

end