function varargout = ita_readunv58(varargin)
%ITA_READUNV58 - reads unv58 datasets that contain frequency responses per mesh node
%  This function takes the filename of a unv-file as an input argument and
%  returns an itaResult or itaAudio object.
%
%  Call: result = ita_readunv58(unvFilename)
%
%   See also ITA Wiki and search for unv for detail or the pdf in the zip
%   file downloaded from FileExchange of Mathworks
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_readunv58">doc ita_readunv58</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 23-Nov-2008


%% Initialization
% Number of Input Arguments
narginchk(1,1);
unvFilename = varargin{1};

%% 'result' is an audioObj and is given back
ita_verbose_info('ITA_READUNV58::reading ...',2);
[DataSet,Info,errmsg] = readuff(unvFilename,[],58); %#ok<ASGLU>
if ~isempty(errmsg)
    ita_verbose_info([upper(mfilename) ':' errmsg{:}],0);
end

while (DataSet{1}.dsType ~= 58)
    if numel(DataSet) == 1
        error([upper(mfilename) ':found no valid DataSet']);
    end
    DataSet = DataSet(2:end);
end
nDataSet = numel(DataSet);
ds = DataSet{1};
abscissa = ds.x(:);
nAbscissa = numel(abscissa);
resultArray = zeros(nAbscissa,nDataSet);
channelNames = cell(1,nDataSet);
channelUnits = cell(1,nDataSet);
nodes = zeros(nDataSet,1);
switch ds.abscissaUnitsLabel
    case 's' % data from B&K Pulse or other measurement systems
        if ~isempty(ds.dx)
            SamplingRate = 1./ds.dx;
        else
            SamplingRate = median(1./diff(unique(abscissa)));
        end
        SamplingRate = round(SamplingRate,-1);
        for i=1:nDataSet %Read the data into the variables
            y = DataSet{i}.measData(:);
            if ~isempty(y)
                nodes(i) = DataSet{i}.rspNode;
                channelNames(i) = {DataSet{i}.d1};
                channelUnits(i) = {DataSet{i}.ordinateNumUnitsLabel};
                resultArray(:,i) = [y; zeros(nAbscissa-numel(y),1)];
            else
                ita_verbose_info([upper(mfilename) ':dataset ' num2str(i) ' is empty'],1);
                nodes(i) = -1;
                channelNames(i) = {'empty'};
                channelUnits(i) = {''};
            end
        end
%         if numel(unique(nodes)) == 1
%             resultArray = resultArray(:);
%             channelNames = channelNames(1);
%             channelUnits = channelUnits(1);
%             nodes = nodes(1);
%         end
        result = itaAudio(resultArray,SamplingRate,'time');
        result.channelNames = channelNames;
        result.channelUnits = channelUnits;
        result.comment = 'measurement (Pulse)';
    otherwise % simulation data
        for i=1:nDataSet %Read the data into the variables
            resultArray(:,i) = DataSet{i}.measData(:);
        end
        nodes = cellfun(@(x) x.rspNode,DataSet).';
        channelNames = cellstr([repmat('Response node ', numel(nodes),1), num2str(nodes)]);
        channelUnits = cellfun(@(x) x.ordinateNumUnitsLabel,DataSet,'UniformOutput',0);
        result = itaResult(resultArray,abscissa,'freq');
        result.resultType = 'simulation';
        result.channelNames = channelNames;
        result.channelUnits = channelUnits;
        result.comment = 'unv58 data file. Frequency response data';
        if ~isempty(DataSet{1}.ID_5)
            caseStr = cellfun(@(x) x.ID_5,DataSet,'UniformOutput',0);
            result.userData = {caseStr};
        end
end
result.userData = [result.userData,{'nodeN', nodes(:)}];

if ~isempty(ds.date)
    if strcmpi(ds.date(1:4),'Date') && length(ds.date) > 10
        try
            result.dateCreated = datevec(datenum(ds.date(end-10:end), 'mm/dd/yyyy'));
        catch %#ok<CTCH>
            result.dateCreated = datevec(datenum(datestr(now),'dd-mmm-yyyy HH:MM:SS'));
        end
    else
        try
            result.dateCreated = datevec(datenum(ds.date, 'ddd mmm dd HH:MM:SS yyyy'));
        catch %#ok<CTCH>
            result.dateCreated = datevec(datenum(datestr(now),'dd-mmm-yyyy HH:MM:SS'));
        end
    end
end
result.fileName = unvFilename;


%% Find output parameters
varargout(1) = {result};

%end function
end