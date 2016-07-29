%   FREE SOFTWARE - please refer the source
%   Copyright (c) 2004-2007 by Primoz Cermelj
%   First release on 30.05.2004
%   Primoz Cermelj, Slovenia
%   Contact: primoz.cermelj@gmail.com
%   Download location: http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6395&objectType=file
%
%   Version: 1.0.2
%   Last revision: 31.03.2008
%
%   Special thanks: Ben Cazzolato for adding 2411 and 2412 datasets.
%
%   Bug reports, questions, etc. can be sent to the e-mail given above.
%
%   This programme is free software; you can redistribute it and/or
%   modify it under the terms of the GNU General Public License
%   as published by the Free Software Foundation; either version 2
%   of the License, or any later version.
%
%   This programme is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%--------------------------------------------------------------------------
%
% Modified version of readuff to read 2435,2452,2467 and 2477 datasets (mesh groups)
% Author: Ramona Bomhardt/MMT (mmt@akustik.rwth-aachen.de)


function [UffDataSets, Info, errmsg] = readuff_groups(varargin)
narginchk(1, 3);
%--------------
% Default outputs
%--------------
UffDataSets = [];
Info.errcode = [];
Info.nDataSets = 0;
Info.dsTypes = [];
Info.binary = [];
Info.errmsg = [];
Info.nErrors = 0;
errmsg = [];
%--------------
% Handle input parameters
%--------------
recs = [];
dsTypes = [];
fileName = varargin{1};
readMode = 1;   % 0=info only, 1=read all, 2=read filtered data-sets
if nargin > 1
    if isnumeric(varargin{2}) || isempty(varargin{2})
        recs = varargin{2};
        readMode = 2;
    elseif strcmpi(varargin{2}, 'infoonly')
        readMode = 0;
    else
        error('Unknown request in the second parameter');
    end
end
if nargin > 2
    if isnumeric(varargin{3}) || isempty(varargin{3})
        dsTypes = varargin{3};
        readMode = 2;
    else
        error('Unknown request in the third parameter');
    end
end


%--------------
% Some variables
%--------------
errN = 0;               % current global error number (data-set number independent)


%--------------
% Read the whole file data into an array of characters
%--------------
try
    fid = fopen(fileName, 'r');
    if fid == -1,
        errN = errN + 1;
        errmsg{errN,1} = ['could not open file: ' fileName];
        disp(errmsg{errN});
        return
    end
    FILE_DATA = (fread(fid, 'uint8=>char')).';
catch
    errN = errN + 1;
    errmsg{errN,1} = ['error reading file contents: ' lasterr];
    disp(errmsg{errN});
    % Close the file
    fclose(fid);
    return
end
% Close the file
err = fclose(fid);
if err == -1
    errN = errN + 1;
    errmsg{errN,1} = 'error while closing file';
    disp(errmsg{errN});
end


%--------------
% Find all valid blocks, data between -1 and -1; pointers to blocks of
% data; include the first -1 but exclude the last -1;
% the first -1 will be skipped further later on in get_block_prop
%--------------
ind = strfind(FILE_DATA, '    -1');
data_len = length(FILE_DATA);
for ii=length(ind):-1:1
    if ind(ii) == data_len
        continue
    end
    if ~isspace(FILE_DATA(ind(ii)+6))
        ind(ii) = [];
    end
end
nBlocks = floor(length(ind)/2);
if nBlocks < 1
    errN = errN + 1;
    errmsg{errN,1} = 'No valid blocks found';
    disp(errmsg{errN});
    return
end
blocks = zeros(nBlocks, 2);
blocks(:,1) = ind(1:2:2*nBlocks)';
blocks(:,2) = ind(2:2:2*nBlocks)'-1;

%=============================
% MAIN FILE LOOP - go through all the blocks and extract data from each
% block according to the data type
%=============================
dataSetN = 0;       % counts VALID data-sets (including non-supported ones)
if isempty(recs)
    recs = 1:nBlocks;
end

try
    if readMode==2
        readScope = recs;
        if max(recs) > nBlocks
            error('Max block number to be read is too high (%d)', max(recs));
        end
    else
        readScope = 1:nBlocks;
    end
    
    for ii=readScope
        
        % Skips the first  -1, detects the data-set type and any possible
        % properties (e.g., for 58b there are some additional fields in the data-set
        % id record), and also returns blockLines - pointers to start and
        % end offsets of lines of the data-set-block data
        [data_set_type, DataSetProp, blockLines, errMessage] = ...
                get_block_prop(ii, blocks(ii,1), blocks(ii,2), FILE_DATA);
        if ~isempty(errMessage)
            errN = errN + 1;
            errmsg{errN,1} = errMessage;
            continue
        end
        
        dataSetN = dataSetN + 1;
        ds_errmsg = [];
        if readMode~=0
            % First check if dataSetN is meets the filter
            if ~isempty(dsTypes)
                if ~find(dsTypes==data_set_type)
                    continue
                end
            end
            % Now, read the record
            correct_dstype = (data_set_type == 2435) || (data_set_type == 2452) || (data_set_type == 2467) || (data_set_type == 2477);
            if correct_dstype  % Modal data file
                [ds_data,ds_errmsg] = extractgroups(FILE_DATA, blockLines);          
            else
                ds_data = [];
                ds_errmsg = ['unknown data-set (' num2str(data_set_type)  ') found in ' num2str(ii) '-th data-set '];
            end
            UffDataSets{dataSetN} = ds_data;
            UffDataSets{dataSetN}.dsType = data_set_type;
            UffDataSets{dataSetN}.binary = DataSetProp.binary;
        end
        
        Info.errmsg{dataSetN} = ds_errmsg;
        Info.dsTypes(dataSetN) = data_set_type;
        Info.binary(dataSetN) = DataSetProp.binary;
        if isempty(ds_errmsg)
            Info.errcode(dataSetN) = 0;
        else
            Info.errcode(dataSetN) = 1;
        end
    end
    
catch
    errN = errN + 1;
    errmsg{errN,1} = lasterr;      
end
%=============================
% END OF MAIN FILE LOOP
%=============================


Info.nErrors = length(find(Info.errcode));
Info.nDataSets = dataSetN;
Info.errorMsgs = Info.errmsg(find(Info.errcode));

if ~isempty(errmsg)
    for ii=1:length(errmsg)
        disp(errmsg{ii});
    end
end


%==========================================================================
%                       SUBFUNCTIONS SECTION
%==========================================================================



%--------------------------------------------------------------------------
function [dataSet, DataSetProp, blockLines, errMessage] = get_block_prop(ds_num, so, eo, FILE_DATA)
% Extract block-data lines' pointers (start and end for each line) and also
% returns the data-set number identified along with any additional
% parameters such as in the case of 58b data-set. so points to the first -1 tag
% (designated by o): o___-1 while eo points to the end -1 tag: o___-1.
% blockLInes are start and end offsets of each line in the current data-set
% starting from the line right after the data-set id line.
% Empty lines are skipped.

% Scans for block data and returns lines' pointers (start and end offsets
% in a 2-column matrix).

dataSet = [];
DataSetProp = [];
blockLines = [];
errMessage = [];
try
    % For a two-column matrix of start and end indices designating the
    % start and end for each line of the data set
    blockData = FILE_DATA(so:eo);
    dataLen = length(blockData);
    lineBreaks = blockData==sprintf('\n') | blockData==sprintf('\r');
    lineBreaksInd = find(lineBreaks);
    toInd = zeros(length(lineBreaksInd)+1, 1);
    fromInd = zeros(length(lineBreaksInd)+1, 1);
    
    toInd(1:length(lineBreaksInd)) = lineBreaksInd-1;
    if lineBreaksInd(end) < dataLen
        toInd(length(lineBreaksInd)+1) = dataLen;
    end
    toInd = toInd(toInd>0);
    indToRemove = find(lineBreaks(toInd)==1);
    toInd(indToRemove) = [];

    if lineBreaksInd(1) > 1
        fromInd(1) = 1;
        fromInd(2:length(lineBreaksInd)+1) = lineBreaksInd+1;
    else
        fromInd(1:length(lineBreaksInd)) = lineBreaksInd+1;
    end
    if lineBreaksInd(end) == dataLen
        fromInd(length(lineBreaksInd)+1) = 0;
    end
    fromInd = fromInd(fromInd>0 & fromInd<=dataLen);
    indToRemove = find(lineBreaks(fromInd)==1);
    fromInd(indToRemove) = [];

    blockLines = [fromInd toInd];
    
    % The data-set line; get the data-set number
    dataSetLine = blockData(blockLines(2,1):blockLines(2,2));
    if isempty(dataSetLine) || length(dataSetLine) < 6
        warning('Badly formatted data-set id for data-set # %d', ds_num);
        dataSet = sscanf(dataSetLine, '%i', 1);
    else
        dataSet = sscanf(dataSetLine(1:6), '%i', 1);
    end
    if isempty(dataSet)
        errMessage = 'no valid data-set type found';
        return
    end
    
    % Get the format
    if length(dataSetLine) < 7
        format = '';
    else
        format = sscanf(dataSetLine(7), '%c', 1);
    end
    if strcmpi(format, 'b')
        DataSetProp.binary = 1;
        DataSetProp.byteOrdering = sscanf(dataSetLine(8:13),'%i',1);
        DataSetProp.fpFormat = sscanf(dataSetLine(14:19),'%i',1);
        DataSetProp.nAsciiLines = sscanf(dataSetLine(20:31),'%i',1);
        DataSetProp.nBytes = sscanf(dataSetLine(32:43),'%i',1);
        DataSetProp.d1 = sscanf(dataSetLine(44:49),'%i',1);
        DataSetProp.d2 = sscanf(dataSetLine(50:55),'%i',1);
        DataSetProp.d3 = sscanf(dataSetLine(56:67),'%i',1);
        DataSetProp.d4 = sscanf(dataSetLine(68:end),'%i',1);
    else
        DataSetProp.binary = 0;
    end
    
    % Global blockLines (with respect to FILE_DATA)
    blockLines = blockLines(3:end,:) + so - 1;
    if size(blockLines,1) < 2
        errMessage = 'empty data block found';
        return
    end
    
catch
    errMessage = ['error while reading the header info at data set #: ' num2str(ds_num) ' (' lasterr ')'];
    return
end

function [UFF,errMessage] = extractgroups(DATA,blockLines)
% Define all "beam like" elements since these have a different structure
Largest_Num_Nodes = 20;     % This is used to zero pad the data if different element types present
UFF = [];
errMessage = [];
% Initialise matrices containing field types

%1.row 
IDGroup = [];
ActiveConstraint = [];
ActiveRestraint = [];
ActiveLoad = [];
ActiveDof = [];
ActiveTemperature =[];
ActiveContact =[];
NumElements = [];
%2.row
GroupName = cell(0,0);
%3.row
TypeCode = [];
Tag = [];
NodeLeafID = [];
Component =[];

try
    data_remaining =1;
    blocklines2 = blockLines;
    i=1;
    while data_remaining==1
        values = sscanf(DATA(blocklines2(1,1):blocklines2(1,2)),'%g');     
        IDGroup = [IDGroup;round(values(1))];
        ActiveConstraint = [ActiveConstraint;round(values(2))];
        ActiveRestraint = [ActiveRestraint;round(values(3))];
        ActiveLoad = [ActiveLoad;round(values(4))];
        ActiveDof = [ActiveDof;round(values(5))];
        ActiveTemperature = [ActiveTemperature;round(values(6))];
        ActiveContact = [ActiveContact;round(values(7))];        
        NumElements = [NumElements;round(values(8))];
       
        names = sscanf(DATA(blocklines2(2,1):blocklines2(2,2)),'%c');
        GroupName=[GroupName,names];        
        
        elements = 3+round(NumElements/2);
        values2 = sscanf(DATA(blocklines2(3,1):blocklines2(elements(i)-1,2)),'%g');

        for k=1:NumElements(i)
            TypeCode = [TypeCode;round(values2(1+4*(k-1)))];
            Tag = [Tag;round(values2(2+4*(k-1)))];
            NodeLeafID = [NodeLeafID;round(values2(3+4*(k-1)))];
            Component = [Component;round(values2(4+4*(k-1)))];
        end
    
        blocklines2 = blocklines2(elements(i):end,:);
        if isempty(blocklines2)
           data_remaining = 0;
        end
        i=i+1;
    end
    
    UFF.IDGroup = IDGroup;
    UFF.ActiveConstraint = ActiveConstraint;
    UFF.ActiveRestraint = ActiveRestraint;
    UFF.ActiveLoad = ActiveLoad;
    UFF.ActiveDof = ActiveDof;
    UFF.ActiveTemperature = ActiveTemperature;
    UFF.ActiveContact = ActiveContact;
    UFF.NumElements = NumElements;
    
    UFF.GroupName = GroupName;
    
    UFF.TypeCode = TypeCode;
    UFF.Tag = Tag;
    UFF.NodeLeafID = NodeLeafID;
    UFF.Component = Component;
    % Strip unnecessary columns from element matrix
%     temp = find(sum(~isnan(Element))>0);
%    UFF.Element = Element(:,temp);
catch
    lineN=1;
    errMessage = ['error reading trace-line data at line' num2str(lineN) ' relatively to current data-set: ' lasterr];
    return
end
