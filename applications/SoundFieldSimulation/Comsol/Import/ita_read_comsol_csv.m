function structOut = ita_read_comsol_csv(varargin)
%ITA_READ_COMSOL_CSV - reads csv exports from Comsol
%   This function reads a csv data export from comsol and returns a struct
%   with meta-data and itaResults (frequency domain).
%   NOTE:
%   This script will also work for parametric sweep data (where additional
%   parameters than frequency being changed during simulation).
%
%   Syntax:
%   dataStruct = ita_read_comsol_csv(file, options)
%
%   Options (default):
%   freqParameter ('freq'): Parameter used for a frequency sweep
%
%   Output:
%   Struct with fields: metaData, coords, "physics"
%   "physics" is a struct with one data-set per exported "variable".
%   There is one field per exported physics (e.g. pabe.p_t, acpr.Lp).
%   
%   Usually, the data in "physics.variable" is a single itaResult with
%   frequency data.
%   When using data from a parametric sweep the data in
%   "physics.variable" is a struct with the fields: data, parameters,
%   parameterData. Here, data contains an itaResult N-dim matrix with N
%   being the number of parameters. Parameters containing the parameter
%   names and parameterData the corresponding values. Note, that the xth
%   dimension in the itaResult refers to the xth parameter.
%   
%
%  Example:
%   dataStruct  = ita_read_comsol_csv(file, options))
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_read_comsol_csv">doc ita_read_comsol_csv</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Hark Braren -- Email: hbr@akustik.rwth-aachen.de
% Created:  13-Jan-2019 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_fileIn','char', 'freqParameter', 'freq');
[fileIn,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Check Header
fId = fopen(fileIn,'r');
currLine = fgetl(fId);
currLineIdx = 1;
metaData = {};

while currLine(1) == '%'
    %in Header
    metaData = [metaData; currLine];

    
    currLine = fgetl(fId);
    currLineIdx = currLineIdx +1;
end
fclose(fId);
nHeaderLines = currLineIdx-1;

%--Meta Data---
structOut.metaData = metaData(1:end-1,:);

%--Column Headers---
columnHeaders = char(metaData(end));
columnHeaders = strsplit(columnHeaders(3:end),',');
idxExtraParameter = ~contains(columnHeaders, '@') & ~strcmpi(columnHeaders, 'x') & ~strcmpi(columnHeaders, 'y') & ~strcmpi(columnHeaders, 'z');
nMerges = 0;
for idxMerge = find(idxExtraParameter)
    idxSource = idxMerge-nMerges;
    idxTarget = idxSource-1;
    columnHeaders{idxTarget} = [columnHeaders{idxTarget} columnHeaders{idxSource}];
    columnHeaders(idxSource) = [];
    nMerges = nMerges+1;
end

%--Numeric Data---
try
    numericCsvData = csvread(fileIn,nHeaderLines);
catch
    error('Something went wrong, try checking if the number of headerLines is correct.')
end

if size(numericCsvData,2) ~= numel(columnHeaders)
    error('Could not process data header: Number of detected header columns and data sets does not match.')
end

%% parse Data
%% parse coordinates
xCol = find(strcmpi(columnHeaders,'x'));
yCol = find(strcmpi(columnHeaders,'y'));
zCol = find(strcmpi(columnHeaders,'z'));
coordCol = [xCol,yCol,zCol];

tmpCoords = zeros(size(numericCsvData,1),3);
tmpCoords(:,1) = real(numericCsvData(:,xCol));
tmpCoords(:,2) = real(numericCsvData(:,yCol));
tmpCoords(:,3) = real(numericCsvData(:,zCol));

coords = itaCoordinates(tmpCoords,'cart');
structOut.coords = coords;

%% Check frequency data header
colIdxAll = 1:numel(columnHeaders);
colIdxFreqData = ~ismember(colIdxAll,coordCol);

colIdxFreqParameter = contains(columnHeaders, sArgs.freqParameter);
assert(isequal(colIdxFreqData, colIdxFreqParameter),...
    'Specified freqParameter could not be found in at least one freq-data column header');

%% parse DataNames
splitHeadersExpressionAndParameters = cellfun(@(x) strsplit(x,'@ '),...
    columnHeaders(colIdxFreqData),'UniformOutput',0);

%physics, var, unit, freq, additional parameter data
organizedHeaderData = cell(size(splitHeadersExpressionAndParameters,2),5);

physics = {};
freqVector = [];
variables = {};
unit = {};
additionalParameters = {};
additionalParameterValues = {};

for iHeader = 1:numel(splitHeadersExpressionAndParameters)
    currHeader = splitHeadersExpressionAndParameters{iHeader};
    splitExpression = strsplit(currHeader{1},'.');
    currPhysics = splitExpression{1};
    if ~ismember(currPhysics,physics)
        physics = [physics,currPhysics];
    end
    
    splitVariableUnit = strsplit(splitExpression{2});
    currVariable = splitVariableUnit{1};
    currUnit = splitVariableUnit{2}(2:end-1);
    
    if ~ismember(currVariable,variables)
        variables = [variables,currVariable];
        unit = [unit,currUnit];
    end
    
    splitParameters = strsplit(currHeader{2});
    splitParametersAndValue = cellfun(@(x) strsplit(x,'='), splitParameters,'UniformOutput',0);
    parameters = cellfun(@(x) x{1}, splitParametersAndValue,'UniformOutput',0);
    values = cellfun(@(x) str2double(x{2}), splitParametersAndValue);
    
    if ~strcmp(sArgs.freqParameter, 'freq')
        idxObsoleteFreqParam = strcmp(parameters, 'freq');
        parameters(idxObsoleteFreqParam) = [];
        values(idxObsoleteFreqParam) = [];
    end
    
    idxFreqParam = strcmp(parameters, sArgs.freqParameter);
    currentFreq = values(idxFreqParam);
    if ~ismember(currentFreq,freqVector)
        freqVector = [freqVector,currentFreq];
    end
    
    nonFreqParameters = parameters(~idxFreqParam);
    nonFreqValues = values(~idxFreqParam);
    for idxParam = 1:numel(nonFreqParameters)
        if ~ismember(nonFreqParameters(idxParam),additionalParameters)
            additionalParameters = [additionalParameters, nonFreqParameters(idxParam)];
            additionalParameterValues{end+1} = nonFreqValues(idxParam);
        else
            idxParamGlobal = strcmp(additionalParameters, nonFreqParameters(idxParam));
            if ~ismember(nonFreqValues(idxParam),additionalParameterValues{idxParamGlobal})
                additionalParameterValues{idxParamGlobal} =...
                    [additionalParameterValues{idxParamGlobal}, nonFreqValues(idxParam)];
            end
        end
    end
    
    organizedHeaderData(iHeader,:) = {currPhysics,currVariable,currUnit,currentFreq, nonFreqValues};
end


%% parse Data
freqData = numericCsvData(:, colIdxFreqData);
for iPhysic = 1:numel(physics)
    currPhysics = string(physics(iPhysic));
    
    for iVariable = 1:numel(variables)
        currVariable = string(variables(iVariable));
        
        if isempty(additionalParameters)
            structOut.(currPhysics).(currVariable) = parseFreqParameterData(freqData, organizedHeaderData, coords, freqVector, currPhysics, currVariable);
        else
            [parsedData, parameterDataStruct] = parseMultiParameterData(freqData, organizedHeaderData, coords, freqVector, currPhysics, currVariable, additionalParameters, additionalParameterValues);
            structOut.(currPhysics).(currVariable).('data') = parsedData;
            structOut.(currPhysics).(currVariable).('parameters') = additionalParameters;
            structOut.(currPhysics).(currVariable).('parameterData') = parameterDataStruct;
        end
    end
end

%end function
end

function resultData = parseFreqParameterData(freqData, organizedHeaderData, coords, freqVector, currPhysics, currVariable)
idxSamePhysics = strcmp(organizedHeaderData(:,1),currPhysics);
idxSameVariable = strcmp(organizedHeaderData(:,2),currVariable);

freqDataOfCurrentVariable = zeros(size(freqData,1),numel(freqVector));
for iFreq = 1:numel(freqVector)
    idxSameFrequency = cell2mat(organizedHeaderData(:,4)) == freqVector(iFreq);
    idxData = idxSamePhysics & idxSameVariable & idxSameFrequency;
    freqDataOfCurrentVariable(:,iFreq) = freqData(:, idxData);
end
resultData = itaResult(freqDataOfCurrentVariable.',freqVector,'freq');
resultData.channelCoordinates = coords;
%end function
end

function [resultData, parameterDataStruct] = parseMultiParameterData(freqData, organizedHeaderData, coords, freqVector, currPhysics, currVariable, additionalParameters, additionalParameterValues)
%% Parameter Meta Data
parameterDataStruct = cell2struct(additionalParameterValues, additionalParameters, 2);

%% Init
nParameters = numel(additionalParameterValues);
dataSize = cellfun(@(x) numel(x), additionalParameterValues);
if nParameters == 1
    resultData = itaResult([dataSize, 1]);
else
    resultData = itaResult(dataSize);
end

parameterValues = cell(1, nParameters);
[parameterValues{:}] = ndgrid(additionalParameterValues{:});

%% Data filtering
idxSamePhysics = strcmp(organizedHeaderData(:,1),currPhysics);
idxSameVariable = strcmp(organizedHeaderData(:,2),currVariable);
for idxDataSet = 1:numel(resultData)
    currentParameterValues = cellfun(@(x) x(idxDataSet), parameterValues);
    idxSameAdditionalParameters = all(cell2mat(organizedHeaderData(:,5)) == currentParameterValues, 2);
    
    %Skip undefinded parameter combination leaving the result empty
    if ~any(idxSamePhysics&idxSameVariable&idxSameAdditionalParameters); continue; end
    
    freqDataOfCurrentVariable = nan(size(freqData,1),numel(freqVector));
    for iFreq = 1:numel(freqVector)
        idxSameFrequency = cell2mat(organizedHeaderData(:,4)) == freqVector(iFreq);
        idxData = idxSamePhysics & idxSameVariable & idxSameFrequency & idxSameAdditionalParameters;
        if ~any(idxData); continue; end
        
        freqDataOfCurrentVariable(:,iFreq) = freqData(:,idxData);
    end
    
    %Filter out frequencies that were not simulated
    idxInvalidFrequecies = any(isnan(freqDataOfCurrentVariable), 1);
    freqDataOfCurrentVariable = freqDataOfCurrentVariable(:, ~idxInvalidFrequecies);
    freqVectorOfCurrentVariable = freqVector(~idxInvalidFrequecies);
    if isempty(freqVectorOfCurrentVariable); continue; end
    
    resultData(idxDataSet) = itaResult(freqDataOfCurrentVariable.',freqVectorOfCurrentVariable,'freq');
    resultData(idxDataSet).channelCoordinates = coords;
end

%end function
end