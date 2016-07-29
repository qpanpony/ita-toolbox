function [UffDataSets, Info, errmsg] = readuff(varargin)
%READUFF Reads UFF (Universal File Format) files of types:
%   151, 15, 55, 58, 82, 164, 2411, 2412, 2414 and also the hybrid one, 58b
%
%   Usage:
%   [UffDataSets, Info, errmsg] = readuff(fileName, 'InfoOnly')  Extract only the
%                   basic information from the file. UffDataSets will be returned
%                   empty in this case.
%
%   [UffDataSets, Info, errmsg] = readuff(fileName) Extract the basic
%                   information from the file as well as the whole file
%                   contents - see the description for the UffDataSets
%                   below.
%
%   [UffDataSets, Info, errmsg] = readuff(fileName, recs) Extract only the
%                   records and their information requested by the recs
%                   array - the array of indices, e.g., recs=[1 3 10]. If
%                   empty, all the records are considered.
%
%   [UffDataSets, Info, errmsg] = readuff(..., recs, dsTypes) Extract only the
%                   records that meet the criterria of the dsTypes where
%                   dsTypes is an array of data-set types that are to be
%                   read - actually, this is another filter in addition to
%                   the recs one; e.g. dsTypes = [58 55]
%
%   The ouput values are:
%   - UffDataSets:  an array of structures; each structure holds one data set
%                   (the data set between -1 and -1; Each structure,
%                   UffDataSets{i}, has the fields
%                       .dsType
%                       .binary
%                   and some additional field which are data-set dependant
%                   and are
%                   as follows:
%                   #58 - for measurement data - function at dof (58):
%                       .d1 (description 1)     .d2 (description 2)     .date
%                       .ID_4                   .ID_5                   .functionType (see notes)
%                       .loadCaseId             .measData               .refEntName
%                       .refDir                 .refNode                .rspDir
%                       .rspEntName             .rspNode                .x (time or frequency)
%                       .dx (abscissa spacing)   .abscissaUnitsLabel
%                       .ordinateNumUnitsLabel  .ordinateDenumUnitsLabel
%                       .zUnitsLabel            .zAxisValue
%
%                   #58b - for measurement data - the same as 58 but the data
%                   is written in binary format
%
%                   #15 - coordinate data (15)  (Grid points):
%                       .nodeN                  .defCS                  .dispCS
%                       .color                  .x                      .y
%                       .z
%
%                   #2411 - coordinate data (2411)  (Grid points):
%                       .nodeN                  .defCS                  .dispCS
%                       .color                  .x                      .y
%                       .z
%
%                   #2412 - element data (2412):
%                       .ElementLabel           .FEDescriptor           .PhysicalProp
%                       .MaterialProp           .ElementColour          .NumNodes
%                       .Elements
%
%                   #82 - display Sequence data (82):
%                       .traceNum               .nNodes                 .color
%                       .ID                     .lines
%
%                   #151 - header data (151):
%                       .modelName              .description            .dateCreated
%                       .timeCreated            .dateSaved              .timeSaved
%                       .dbApp                  .dbVersion              .uffApp
%
%                   #164 - units (164):
%                       .unitsCode              .unitsDescription       .tempMode (1=absoulute, 2=relative)
%                       Unit factors for converting universal file units to SI. To convert from
%                       universal file units to SI divide by the appropriate factor listed below:
%                       .facLength              .facForce               .facTemp            
%                       .facTempOffset
%
%                   #55 - data at nodes (55):
%                       /Common fields:/
%                       .analysisType           .dataCharacter = 1      .r1
%                       .r2                     .r3                     .responseType
%                       .r4                     .r5                     .r6
%                       /Normal modes specific fields (analysisType = 2)/
%                       .modeNum                .modeFreq               .modeMass 
%                       .mode_v_damping_ratio   .mode_h_damping_ratio                   
%                       /...or, for complex modes specific fields (analysisType = 3 or 7)/
%                       .modeNum                .eigVal                 .modalA        
%                       .modalB                 
%                       /...or, for frequency response specific fields (analysisType = 5)/
%                       .freqNum                .freq
%
%   - Info:         (optional) structure with the following fields:
%                   .dsTypes    -   an array of data-set types read
%                   .binary     -   an array of 1s (binary format) and 0s (ascii format)
%                   .nDataSets  -   number of data sets found
%                   .errcode    -   an array of error codes for each data
%                                   set; 0 = no error otherwise an error occured in data
%                                   set read - see errmsg
%                   .errmsg     -   error messages (cell array of strings) for each
%                                   data set - empty if no error occured at specific data set
%                   .nErrors    -   number of errors found (unsupported
%                                   datasets, error reading data set,...)
%                   .errorMsgs  -   all the error messages (empty if no error is found)
%   - errmsg:       (optional) general (overall), file-based error
%                   messages - to enable reading of uncorrupted data for
%                   example,...
%
%
%   NOTES: r1..r6 are response vectors with node numbers in ROWS and
%   direction in COLUMN (r1=x, r2=y,...,r6=rz).
%
%   functionType can be one of the following:
%               0 -  General or Unknown
%               1 -  Time Response
%               2 -  (supported) Auto Spectrum
%               3 -  (supported) Cross Spectrum
%               4 -  (supported) Frequency Response Function
%               5 -  Transmissibility
%               6 -  (supported) Coherence
%               7 -  Auto Correlation
%               8 -  Cross Correlation
%               9 -  Power Spectral Density (PSD)
%               10 - Energy Spectral Density (ESD)
%               11 - Probability Density Function
%               12 - Spectrum
%               13 - Cumulative Frequency Distribution
%               14 - Peaks Valley
%               15 - Stress/Cycles
%               16 - Strain/Cycles
%               17 - Orbit
%               18 - Mode Indicator Function
%               19 - Force Pattern
%               20 - Partial Power
%               21 - Partial Coherence
%               22 - Eigenvalue
%               23 - Eigenvector
%               24 - Shock Response Spectrum
%               25 - Finite Impulse Response Filter
%               26 - Multiple Coherence
%               27 - Order Function
%
%   analysisType can be one of the following:
%               0: Unknown
%               1: Static
%               2: (supported) Normal Mode
%               3: (supported) Complex eigenvalue first order
%               4: Transient
%               5: (supported) Frequency Response
%               6: Buckling
%               7: (supported) Complex eigenvalue second order
%
%   dataCharacter can be one of the following:
%               0: Unknown
%               1: Scalar
%               2: 3 DOF Global Translation Vector
%               3: 6 DOF Global Translation & Rotation Vector
%               4: Symmetric Global Tensor
%
%   unitsCode can be one of the following:
%               1 - SI: Meter (newton)
%               2 - BG: Foot (pound f)
%               3 - MG: Meter (kilogram f)
%               4 - BA: Foot (poundal)
%               5 - MM: mm (milli newton)
%               6 - CM: cm (centi newton)
%               7 - IN: Inch (pound f)
%               8 - GM: mm (kilogram f)
%
%   functionType as well as other parameters are described in
%   Test_Universal_File_Formats.pdf
%
%   Examples:
%       [Data, Info, errmsg] = readuff('test.unv', 'InfoOnly');
%           Extracts only the information on the content of the test.unv.
%       [Data, Info, errmsg] = readuff('test.unv', [1 3 10]);
%           Reads the 1st, 3rd and 10th data-set from the test.unv, while
%       [Data, Info, errmsg] = readuff('test.unv', [1 3 10], [55, 58]);
%           Reads the 1st, 3rd and 10th data-set from the test.unv, but,
%           only those sets whose type is either 55 or 58.
%       [Data, Info, errmsg] = readuff('test.unv');
%           Reads the whole file content - all the data-sets.
%
%   See also: WRITEUFF
%
%   SOURCES:    [1] Bryce Gardner's read_uff obtained from the internet
%               [2] http://www.sdrl.uc.edu/uff/SDRChelp/LANG/English/unv_ug/book.htm
%
%
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

%----------------
% READUFF history
%----------------
%
% [v.1.0.1-1.0.2] 12.03.2008-31.03.2008
% - FIX: uint8=>char instead of char=>char in fread fixes a problem on
%        some Linux systems
% - FIX: minor bug removed (related to the extracted abscissa values for
%        the 58, complex case of data)
% [v.1.0.0] 10.03.2008
% - NEW: datasets 2411 and 2412 added
% [v.0.9.9b1-5] 08.01.2008
% - NEW: additional checking when reading 58b data
% - NEW: additional filter added - dsTypes
% - FIX: minor bug removed concerning the finding of the "    -1" tags
% - FIX: previously, when reading data-set 58b, some data-sets were
%        skipped; this bug is now removed
% - NEW: new functionality to read only a portion of file and to extract
%        the information only
% [v.0.9.7-v.0.9.8b7] 28.02.2006
% - FIX: a bug reading even abscissa data from the 58 set removed
% - NEW: uneven abscissa data-reading is now supported
% - FIX: removing leading and trailing spaces from the strings read
% - NEW: hybrid binary-58 format (58b) is now supported
% - NEW: binary field was added to UffDataSets structures
% [v.0.9.7] 24.05.2005
% - NEW: dsType field was added to UffDataSets structures
% [v.0.9.6b4] 11.05.2005
% - FIX: Matlab version down to 5.3 is now supported
% - FIX: Some minor bugs removed
% - NEW: Speed improvement; reading is much faster now
%
%----------------

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
            error('Max block number to be read is too high');
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
                get_block_prop(blocks(ii,1), blocks(ii,2), FILE_DATA);
        if ~isempty(errMessage)
            errN = errN + 1;
            errmsg{errN,1} = errMessage;
            continue
        end

        ds_errmsg = [];
        if readMode~=0
            % First check if dataSetN is meets the filter
            if ~isempty(dsTypes)
                if isempty(find(dsTypes==data_set_type, 1))
                    continue
                else
                    dataSetN = dataSetN + 1;
                end
            else
                dataSetN = dataSetN + 1;
            end
            % Now, read the record
            if data_set_type == 58      % Function at nodal dof
                [ds_data,ds_errmsg] = extract58(fileName, FILE_DATA, blockLines, DataSetProp);
            elseif data_set_type == 15  % Coordinate data
                [ds_data,ds_errmsg] = extract15(FILE_DATA, blockLines);
            elseif data_set_type == 2411  % Node Coordinate data
                [ds_data,ds_errmsg] = extract2411(FILE_DATA, blockLines);
            elseif data_set_type == 2412  % Element data
                [ds_data,ds_errmsg] = extract2412(FILE_DATA, blockLines);
            elseif data_set_type == 151 % Header data
                [ds_data,ds_errmsg] = extract151(FILE_DATA, blockLines);
            elseif data_set_type == 164 % Units data
                [ds_data,ds_errmsg] = extract164(FILE_DATA, blockLines);
            elseif data_set_type == 82  % Display sequence data
                [ds_data,ds_errmsg] = extract82(FILE_DATA, blockLines);
            elseif data_set_type == 55  % Modal data file
                [ds_data,ds_errmsg] = extract55(FILE_DATA, blockLines);
            elseif data_set_type == 2414  % Analysis Data from Simulation
                [ds_data,ds_errmsg] = extract2414(FILE_DATA, blockLines);
            else
                ds_data = [];
                ds_errmsg = ['unknown data-set (' num2str(data_set_type)  ') found in ' num2str(ii) '-th data-set '];
            end
            UffDataSets{dataSetN} = ds_data;
            UffDataSets{dataSetN}.dsType = data_set_type;
            UffDataSets{dataSetN}.binary = DataSetProp.binary;
        else
            dataSetN = dataSetN + 1;
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
Info.errorMsgs = Info.errmsg(find(Info.errcode)); %#ok<FNDSB>

if ~isempty(errmsg)
    for ii=1:length(errmsg)
        disp(errmsg{ii});
    end
end




%==========================================================================
%                       SUBFUNCTIONS SECTION
%==========================================================================



%--------------------------------------------------------------------------
function [dataSet, DataSetProp, blockLines, errMessage] = get_block_prop(so, eo, FILE_DATA)
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
%    if size(blockLines,1) < 2
%        return;
%         disp(blockData(blockLines));
%    end
    % The data-set line; get the data-set number
    dataSetLine = blockData(blockLines(2,1):blockLines(2,2));
    dataSet = sscanf(dataSetLine(1:6), '%i', 1);
    if isempty(dataSet)
        errMessage = 'invalid data-set type specification found';
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
    errMessage = ['error reading basic info about data-set: ' lasterr];
    return
end




%--------------------------------------------------------------------------
function [UFF, errMessage] = extract58(fileName, DATA, blockLines, DataSetProp)
% #58 - Extract data-set type 58 data

UFF = [];
UFF.measData = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines, 1);

try
    % Line 1
    UFF.d1 = strim(sscanf(DATA(blockLines(1,1):blockLines(1,2)), '%c', 80));
    lineN = lineN + 1;
    % Line 2
    UFF.d2 = strim(sscanf(DATA(blockLines(2,1):blockLines(2,2)), '%c', 80));
    lineN = lineN + 1;
    % Line 3
    UFF.date = strim(sscanf(DATA(blockLines(3,1):blockLines(3,2)), '%c', 80));
    lineN = lineN + 1;
    % Line 4
    UFF.ID_4 = strim(sscanf(DATA(blockLines(4,1):blockLines(4,2)), '%c', 80));
    lineN = lineN + 1;
    % Line 5
    UFF.ID_5 = strim(sscanf(DATA(blockLines(5,1):blockLines(5,2)), '%c', 80));
    lineN = lineN + 1;
    % Line 6
    tmpLine = DATA(blockLines(6,1):blockLines(6,2));
    tmpLine = [tmpLine repmat(' ', 1, 80-length(tmpLine))];
    UFF.functionType = sscanf(tmpLine(1:5), '%i', 1);    
    tmp = sscanf(tmpLine(6:15),'%i', 1);
    tmp = sscanf(tmpLine(16:20),'%i', 1);
    UFF.loadCaseId = sscanf(tmpLine(21:30), '%i', 1);
%     if UFF.loadCaseId ~= 0,
%         errMessage = ['need single point excitation at: ' num2str(lineN)];
%         return
%     end
    UFF.rspEntName = sscanf(tmpLine(32:41), '%s', 1);
    UFF.rspNode = sscanf(tmpLine(42:51), '%i', 1);
    UFF.rspDir = sscanf(tmpLine(52:55), '%i', 1);
    UFF.refEntName = sscanf(tmpLine(57:66), '%s', 1);
    UFF.refNode = sscanf(tmpLine(67:76),'%i', 1);
    UFF.refDir = sscanf(tmpLine(77:80),'%i', 1);
    lineN = lineN + 1;

    % Line 7; data form
    tmpLine = DATA(blockLines(7,1):blockLines(7,2));
    tmpLine = [tmpLine repmat(' ', 1, 80-length(tmpLine))];
    ordDataType = sscanf(tmpLine(1:10), '%i', 1);
    numpt = sscanf(tmpLine(11:20),'%i', 1);  % # of points if even spacing or # of pairs if uneven spacing
    spacingType = sscanf(tmpLine(21:30), '%i', 1);
    UFF.xmin = sscanf(tmpLine(31:43), '%g', 1);
    UFF.dx = sscanf(tmpLine(44:56), '%g', 1);
    UFF.zAxisValue = sscanf(tmpLine(57:69), '%g', 1);
    lineN = lineN + 1;

    % Line 8; abscissa data characteristics
    tmpLine = DATA(blockLines(8,1):blockLines(8,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    abDataType = sscanf(tmpLine(1:10),'%i',1);
    if ~(abDataType == 18 | abDataType == 17 | abDataType),  % Frequency, time, or unknown
        errMessage = ['need frequency, time, or unknown data on abcissa at:' num2str(lineN)];
        return
    end
    tmp = sscanf(tmpLine(11:15),'%i',1);
    tmp = sscanf(tmpLine(16:20),'%i',1);
    tmp = sscanf(tmpLine(21:25),'%i',1);
    temp = sscanf(tmpLine(27:46),'%s',1);
    UFF.abscissaUnitsLabel = sscanf(tmpLine(48:end),'%s',1);
    lineN = lineN + 1;

    % Line 9; Ordinate (or ordinate numerator) Data Characteristics
    tmpLine = DATA(blockLines(9,1):blockLines(9,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    ordNumeratorDataType = sscanf(tmpLine(1:10),'%i',1);
    %  if or_num_data_type(loop) ~= 12,  %Acceleration
    %    ermessage = 'expected acceleration data in the ordinate numerator';
    %    disp(ermessage);
    %  end
    tmp = sscanf(tmpLine(11:15),'%i',1);
    tmp = sscanf(tmpLine(16:20),'%i',1);
    tmp = sscanf(tmpLine(21:25),'%i',1);
    tmp = sscanf(tmpLine(27:46),'%s',1);
    UFF.ordinateNumUnitsLabel = sscanf(tmpLine(48:end),'%s',1);
    lineN = lineN + 1;

    % Line 10; Ordinate Denominator Data Characteristics
    tmpLine = DATA(blockLines(10,1):blockLines(10,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    ordDenominatorDataType = sscanf(tmpLine(1:10),'%i',1);
    %  if or_den_data_type(loop) ~= 13,  % Excitation force
    %    ermessage = 'expected force data in the ordinate denominator';
    %    disp(ermessage);
    %  end
    tmp = sscanf(tmpLine(11:15),'%i',1);
    tmp = sscanf(tmpLine(16:20),'%i',1);
    tmp = sscanf(tmpLine(21:25),'%i',1);
    temp = sscanf(tmpLine(27:46),'%s',1);
    UFF.ordinateDenumUnitsLabel = sscanf(tmpLine(48:end),'%s',1);
    lineN = lineN + 1;

    % Line 11; Z-axis Data Characteristics
    tmpLine = DATA(blockLines(11,1):blockLines(11,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    tmp = sscanf(tmpLine(1:10),'%i',1);
    tmp = sscanf(tmpLine(11:15),'%i',1);
    tmp = sscanf(tmpLine(16:20),'%i',1);
    tmp = sscanf(tmpLine(21:25),'%i',1);
    temp = sscanf(tmpLine(27:46),'%s',1);
    UFF.zUnitsLabel = sscanf(tmpLine(48:end),'%s',1);
    lineN = lineN + 1;

    % Line 12 ...; Data Values
    if DataSetProp.binary   % binary
        if DataSetProp.byteOrdering == 1; format = 'l'; else; format = 'b'; end;
        if (ordDataType==2 | ordDataType==5)
            prec = 'float32';   % single precision
            numLen = 4;
        else
            prec = 'double';    % double precision
            numLen = 8;
        end
        fid = fopen(fileName,'r',format);
        if fid == -1
            errMessage = ['could not reopen file for binary data reading: ' fileName];
            return
        end
        status = fseek(fid, blockLines(12,1)-1, 'bof');
        if status
            errMessage = ['could not start reading binary data from ' fileName];
            return
        end

        % It was observed that some programs write some inconsistent values
        % to the header concerning the number of data and/or bytes the data
        % is to occupy. In case such incosistency is found, the max number
        % will be used and a warning displayed.
        % According to the UFF documentation, in the case of uneven
        % abscissa, the abscissa is always stored as real, single
        % precision.
        complexOrd = (ordDataType == 5 | ordDataType == 6);
        if spacingType == 0  % uneven
            n_ord_vals_to_read = (DataSetProp.nBytes - numpt*4)/numLen;
        else                 % even
            n_ord_vals_to_read = DataSetProp.nBytes/numLen;
        end
        n_ord_vals_to_read = n_ord_vals_to_read/(1+complexOrd);
        if numpt ~= n_ord_vals_to_read
            warning('The number of bytes does not correspond to the number of values specified');
        end
        
        n_ord_vals_to_read = max(numpt, n_ord_vals_to_read)*(1+complexOrd);
        try
            if spacingType == 0 % uneven spacing
                absc_values = fread(fid, numpt, 'float32', numLen*(1+complexOrd*1));                
                fseek(fid, blockLines(12,1)-1+4, 'bof');
                values = fread(fid, n_ord_vals_to_read, prec, 4);
                if complexOrd
                    values = [absc_values; reshape(values, 2, numpt)];
                    values = reshape(values, numpt*3, 1);
                else
                    values = [absc_values; reshape(values, 1, numpt)];
                    values = reshape(values, numpt*2, 1);
                end
            else
                values = fread(fid, n_ord_vals_to_read, prec);
            end
        catch
            errMessage = ['error while reading binary data from ' fileName];
            return
        end
        fclose(fid);
    else                    % ascii
        values = sscanf(DATA(blockLines(12,1):blockLines(end,2)),'%g');
    end

    % Abscissa and ordinate values
    if (ordDataType == 2 | ordDataType == 4)        % non-complex ordinate data
        if spacingType == 0 % uneven abscissa
            UFF.x = values(1:2:end-1);
            UFF.measData = values(2:2:end);
        else                % even abscissa
            UFF.measData = values;
            nVal = length(UFF.measData);
            UFF.x = [ UFF.xmin : UFF.dx : UFF.xmin + (nVal-1)*UFF.dx ];
        end
    elseif (ordDataType == 5 | ordDataType == 6)    % complex ordinate data
        if spacingType == 0 % uneven abscissa
            UFF.measData = values(2:3:end-1) + j*values(3:3:end);
            UFF.x = values(1:3:end-2);
        else                % even abscissa
            UFF.measData = values(1:2:end-1) + j*values(2:2:end);
            nVal = length(UFF.measData);
            UFF.x = [ UFF.xmin : UFF.dx : UFF.xmin + (nVal-1)*UFF.dx ];
        end
    else
        errMessage = ['error reading measurement data at:' num2str(lineN)];
        return
    end
    
catch
    errMessage = ['error reading measurement data: ' lasterr];
    return
end


%--------------------------------------------------------------------------
function [UFF,errMessage] = extract151(DATA,blockLines)
% #151 - Extract data-set type 151 data

UFF = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines,1);

try
    % Line 1
    UFF.modelName = strim(sscanf(DATA(blockLines(1,1):blockLines(1,2)),'%c',80));
    lineN = lineN + 1;
    % Line 2
    UFF.description = strim(sscanf(DATA(blockLines(2,1):blockLines(2,2)),'%c',80));
    lineN = lineN + 1;
    % Line 3
    UFF.dbApp = strim(sscanf(DATA(blockLines(3,1):blockLines(3,2)),'%c',80));
    lineN = lineN + 1;
    % Line 4
    tmpLine = DATA(blockLines(4,1):blockLines(4,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.dateCreated = sscanf(tmpLine(1:10),'%s',10);
    UFF.timeCreated = sscanf(tmpLine(11:20),'%s',10);
    UFF.dbVersion = sscanf(tmpLine(21:30),'%i',10);
    lineN = lineN + 1;       
    % Line 5
    tmpLine = DATA(blockLines(5,1):blockLines(5,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.dateSaved = sscanf(tmpLine(1:10),'%s',10);
    UFF.timeSaved = sscanf(tmpLine(11:20),'%s',10);
    lineN = lineN + 1;       
    % Line 6
    UFF.uffApp = strim(sscanf(DATA(blockLines(6,1):blockLines(6,2)),'%c',80));
    % Line 7
    tmpLine = DATA(blockLines(7,1):blockLines(7,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.dateWritten = strim(sscanf(tmpLine(1:20),'%c',20));
catch
    errMessage = ['error reading header data at line ' num2str(lineN) ' relatively to current data-set'];
    return
end


%--------------------------------------------------------------------------
function [UFF,errMessage] = extract164(DATA,blockLines)
% #164 - Extract data-set type 164 data
UFF = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines,1);
try
    % Line 1
    tmpLine = DATA(blockLines(1,1):blockLines(1,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.unitsCode = sscanf(tmpLine(1:10),'%i');    
    UFF.unitsDescription = strim(sscanf(tmpLine(11:31),'%c'));
    UFF.tempMode = sscanf(tmpLine(32:41),'%i');
    lineN = lineN + 1;
    % Line 2
    tmpLine = DATA(blockLines(2,1):blockLines(2,2));
    tmpLine = lower([tmpLine repmat(' ',1,80-length(tmpLine))]);
    tmpLine = strrep(tmpLine,'d-','e-');
    tmpLine = strrep(tmpLine,'d+','e+');
    UFF.facLength = sscanf(tmpLine(1:25),'%f');
    UFF.facForce = sscanf(tmpLine(26:50),'%f');
    UFF.facTemp = sscanf(tmpLine(51:75),'%f');
    lineN = lineN + 1;
    % Line 3
    tmpLine = DATA(blockLines(3,1):blockLines(3,2));
    tmpLine = lower([tmpLine repmat(' ',1,80-length(tmpLine))]);
    tmpLine = strrep(tmpLine,'d-','e-');
    tmpLine = strrep(tmpLine,'d+','e+');
    UFF.facTempOffset = sscanf(tmpLine(1:25),'%f');
catch
    errMessage = ['error reading units data at line' num2str(lineN) ' relatively to current data-set: ' lasterr];
    return
end



%--------------------------------------------------------------------------
function [UFF,errMessage] = extract15(DATA,blockLines)
% #15 - Extract data-set type 15 data

UFF = [];
errMessage = [];
nLines = size(blockLines,1);

try
    values = sscanf(DATA(blockLines(1,1):blockLines(end,2)),'%g');
    nVals = length(values);
    nNodes = round(nVals/7);
    values = reshape(values,7,nNodes).';
    %
    UFF.nodeN = round(values(:,1));
    UFF.defCS = round(values(:,2));
    UFF.dispCS = round(values(:,3));
    UFF.color = round(values(:,4));
    UFF.x = values(:,5);
    UFF.y = values(:,6);
    UFF.z = values(:,7);
catch
    errMessage = ['error reading coordinate data: ' lasterr];
    return
end


%--------------------------------------------------------------------------
function [UFF,errMessage] = extract82(DATA,blockLines)
% #82 - Extract display sequence data-set type 82 data

UFF = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines,1);
try
    % Line 1
    tmpLine = DATA(blockLines(1,1):blockLines(1,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.traceNum = sscanf(tmpLine(1:10),'%i',1);
    UFF.nNodes = sscanf(tmpLine(11:20),'%i',1);
    UFF.color = sscanf(tmpLine(21:30),'%i',1);
    lineN = lineN + 1;
    % Line 2
    UFF.ID = strim(sscanf(DATA(blockLines(2,1):blockLines(2,2)),'%c'));
    lineN = lineN + 1;
    % Line 3
    UFF.lines = sscanf(DATA(blockLines(3,1):blockLines(end,2)),'%g');
catch
    errMessage = ['error reading trace-line data at line' num2str(lineN) ' relatively to current data-set: ' lasterr];
    return

end




%--------------------------------------------------------------------------
function [UFF,errMessage] = extract55(DATA,blockLines)
% #55 - Extract modal data-set type 55 data

UFF = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines,1);
errN = 0;

try
    % Line 1
    UFF.d1 = strim(sscanf(DATA(blockLines(1,1):blockLines(1,2)),'%c',80));
    lineN = lineN + 1;
    % Line 2
    UFF.d2 = strim(sscanf(DATA(blockLines(2,1):blockLines(2,2)),'%c',80));
    lineN = lineN + 1;
    % Line 3
    UFF.date = strim(sscanf(DATA(blockLines(3,1):blockLines(3,2)),'%c',80));
    lineN = lineN + 1;
    % Line 4
    UFF.IDs = strim(sscanf(DATA(blockLines(4,1):blockLines(4,2)),'%c',80));
    % Line 5
    temp = sscanf(DATA(blockLines(5,1):blockLines(5,2)),'%s',1);
    lineN = lineN + 1;
    % Line 6
    tmpLine = DATA(blockLines(6,1):blockLines(6,2));
    tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    UFF.modelType = sscanf(tmpLine(1:10),'%i',1);
    lineN = lineN + 1;
    if UFF.modelType ~=1,
        errMessage = ['not structural model type (line: ' num2str(lineN) ' relatively to current data-set)'];
        return
    end
    UFF.analysisType = sscanf(tmpLine(11:20),'%i',1);
    UFF.dataCharacter = sscanf(tmpLine(21:30),'%i',1);
    UFF.responseType = sscanf(tmpLine(31:40),'%i',1);
    UFF.dataType = sscanf(tmpLine(41:50),'%i',1);
    num_data_per_pt = sscanf(tmpLine(51:60),'%s',1);

    % Read records 7 and 8 which are analysis-type dependent
    if UFF.analysisType == 2  % Normal Mode
        % Line 7
        tmpLine = DATA(blockLines(7,1):blockLines(7,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        two = sscanf(tmpLine(1:10),'%i',1);
        lineN = lineN + 1;
        if two ~= 2,
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        four = sscanf(tmpLine(11:20),'%i',1);
        if four ~= 4,
            errMessage = ['unexpected value at line: ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        tmp = sscanf(tmpLine(21:30),'%i',1);
        UFF.modeNum = sscanf(tmpLine(31:40),'%i',1);
        % Line 8
        tmpLine = DATA(blockLines(8,1):blockLines(8,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        UFF.modeFreq = sscanf(tmpLine(1:13),'%g',1);
        UFF.modeMass = sscanf(tmpLine(14:26),'%g',1);
        UFF.mode_v_damping_ratio = sscanf(tmpLine(27:39),'%g',1);
        UFF.mode_h_damping_ratio = sscanf(tmpLine(40:52),'%g',1);

    elseif UFF.analysisType == 3, % Complex Eigenvalue, First Order (Displacement)
        % Line 7
        tmpLine = DATA(blockLines(7,1):blockLines(7,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        two = sscanf(tmpLine(1:10),'%i',1);
        if two ~= 2,
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        six = sscanf(tmpLine(11:20),'%i',1);
        if six ~= 6,
            errMessage = ['unexpected value at line: ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        tmp = sscanf(tmpLine(21:30),'%i',1);
        UFF.modeNum = sscanf(tmpLine(31:40),'%i',1);

        % Line 8
        tmpLine = DATA(blockLines(8,1):blockLines(8,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        real_part = sscanf(tmpLine(1:13),'%g',1);
        imaginary_part = sscanf(tmpLine(14:26),'%g',1);
        UFF.eigVal = real_part + j * imaginary_part;
        real_part = sscanf(tmpLine(27:39),'%g',1);
        imaginary_part = sscanf(tmpLine(40:52),'%g',1);
        UFF.modalA = real_part + j * imaginary_part;
        real_part = sscanf(tmpLine(53:65),'%g',1);
        imaginary_part = sscanf(tmpLine(66:78),'%g',1);
        UFF.modalB = real_part + j * imaginary_part;

    elseif UFF.analysisType == 5, % Frequency Response
        % Line 7
        tmpLine = DATA(blockLines(7,1):blockLines(7,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        two = sscanf(tmpLine(1:10),'%i',1);
        if two ~= 2,
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        one = sscanf(tmpLine(11:20),'%i',1);
        if one ~= 1,            
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        tmp = sscanf(tmpLine(21:30),'%i',1);
        UFF.freqNum = sscanf(tmpLine(31:40),'%i',1);

        % Line 8
        tmpLine = DATA(blockLines(8,1):blockLines(8,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        UFF.freq = sscanf(tmpLine(1:13),'%g',1);    % in Hz

    elseif UFF.analysisType == 7  % Complex Eigenvalue, Second Order (Velocity)
        % Line 7
        tmpLine = DATA(blockLines(7,1):blockLines(7,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        two = sscanf(tmpLine(1:10),'%i',1);
        if two ~= 2,
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        six = sscanf(tmpLine(11:20),'%i',1);
        if six ~= 6,
            errMessage = ['unexpected value at line ' num2str(lineN) ' relatively to current data-set'];
            return
        end
        tmp = sscanf(tmpLine(21:30),'%i',1);
        UFF.modeNum = sscanf(tmpLine(31:40),'%i',1);

        % Line 8
        tmpLine = DATA(blockLines(8,1):blockLines(8,2));
        tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        lineN = lineN + 1;
        real_part = sscanf(tmpLine(1:13),'%g',1);
        imaginary_part = sscanf(tmpLine(14:26),'%g',1);
        UFF.eigVal = real_part + j * imaginary_part;
        real_part = sscanf(tmpLine(27:39),'%g',1);
        imaginary_part = sscanf(tmpLine(40:52),'%g',1);
        UFF.modalA = real_part + j * imaginary_part;
        real_part = sscanf(tmpLine(53:65),'%g',1);
        imaginary_part = sscanf(tmpLine(66:78),'%g',1);
        UFF.modalB = real_part + j * imaginary_part;

    else
        errMessage = ['analysis type is not supported at line ' num2str(lineN) ' relatively to current data-set'];
        return
    end

    % Read response data by x,y,...components into r1..r6
    ii = 0;
    nnodes = floor((nLines-9)/2)+1;
    r1 = zeros(nnodes,1);
    r2 = r1;
    r3 = r1;
    r4 = r1;
    r5 = r1;
    r6 = r1;
    nodeNum = r1;
    for lne = 9:2:nLines-1,
        ii = ii + 1;
        %========
        %    line = 9; % line 9 type of line
        %========
        lineRead = lne;
        tmpLine = DATA(blockLines(lineRead,1):blockLines(lineRead,2));
        nodeNum(ii) = sscanf(tmpLine(1:10),'%i',1);
        lineN = lineN + 1;

        %========
        %    line = 10; % line 9 type of line
        %========
        lineRead = lne + 1;
        lineN = lineN + 1;
        tmpLine = DATA(blockLines(lineRead,1):blockLines(lineRead,2));
%         tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
        if UFF.dataType == 2,       % real data
            r1(ii) = sscanf(tmpLine(1:13),'%g',1);
            r2(ii) = sscanf(tmpLine(14:26),'%g',1);
            r3(ii) = sscanf(tmpLine(27:39),'%g',1);
            if num_data_per_pt == 6,
                r4(ii) = sscanf(tmpLine(40:52),'%g',1);
                r5(ii) = sscanf(tmpLine(53:65),'%g',1);
                r6(ii) = sscanf(tmpLine(66:78),'%g',1);
            end
        elseif UFF.dataType == 5,   % complex data
            p1 = sscanf(tmpLine(1:13),'%g',1);
            p2 = sscanf(tmpLine(14:26),'%g',1);
            r1(ii) = p1 + j * p2;
            p3 = sscanf(tmpLine(27:39),'%g',1);
            p4 = sscanf(tmpLine(40:52),'%g',1);
            r2(ii) = p3 + j * p4;
            p5 = sscanf(tmpLine(53:65),'%g',1);
            p6 = sscanf(tmpLine(66:78),'%g',1);
            r3(ii) = p5 + j * p6;
            if num_data_per_pt == 6,
                errMessage = ['not setup to handle six coordinate of complex data at line ' num2str(lineN) ' relatively to current data-set'];
                return
            end
        else
            errMessage = ['what kind of data type was that at line ' num2str(lineN) ' relatively to current data-set?'];
            return
        end
    end
    UFF.r1 = r1;
    UFF.r2 = r2;
    UFF.r3 = r3;
    UFF.r4 = r4;
    UFF.r5 = r5;
    UFF.r6 = r6;
    UFF.nodeNum = nodeNum;
catch
    errMessage = ['error reading modal data: ' lasterr];
    return
end



%--------------------------------------------------------------------------
function outstr = strim(str)
% Removes leading and trailing spaces (spaces, tabs, endlines,...)
% from the str string.
if isnumeric(str);
    outstr = str;
    return
end
ind = find( ~isspace(str) );        % indices of the non-space characters in the str    
if isempty(ind)
    outstr = [];        
else
    outstr = str( ind(1):ind(end) );
end







%--------------------------------------------------------------------------
function [UFF,errMessage] = extract2411(DATA,blockLines)
% #2411 - Extract data-set type 2411 data
% Added by Ben Cazzolato, 10/3/2008
% Modified by Haike Brick, 6/10/2008
%
% Universal Dataset Number 2411
% by zopeown � last modified 2007-05-02 06:56
% 
% Name:   Nodes - Double Precision
% Status: Current
% Owner:  Simulation
% Revision Date: 23-OCT-1992 
% ----------------------------------------------------------------------------
% 
% Record 1:        FORMAT(4I10)
%                  Field 1       -- node label
%                  Field 2       -- export coordinate system number
%                  Field 3       -- displacement coordinate system number
%                  Field 4       -- color
% Record 2:        FORMAT(1P3D25.16)
%                  Fields 1-3    -- node coordinates in the part coordinate
%                                   system
%  
% Records 1 and 2 are repeated for each node in the model.
%  
% Example:
%  
%     -1
%   2411
%        121         1         1        11
%    5.0000000000000000D+00   1.0000000000000000D+00   0.0000000000000000D+00
%        122         1         1        11
%    6.0000000000000000D+00   1.0000000000000000D+00   0.0000000000000000D+00
%     -1
%  
% ----------------------------------------------------------------------------
UFF = [];
errMessage = [];
nLines = size(blockLines,1);

values1 = zeros(nLines/2,4);
values2 = zeros(nLines/2,3);
try
    for lne = 1:nLines/2
        values1(lne,:) = sscanf(DATA(blockLines(2*lne-1,1):blockLines(2*lne-1,2)),'%i');
        string = DATA(blockLines(2*lne,1):blockLines(2*lne,2));
        ii = strfind(string, 'D');
        string(ii)='E';
        values2(lne,:) = sscanf(string,'%e');
    end
    %
    UFF.nodeN = values1(:,1);
    UFF.defCS = values1(:,2);
    UFF.dispCS = values1(:,3);
    UFF.color = values1(:,4);
    UFF.x = values2(:,1);
    UFF.y = values2(:,2);
    UFF.z = values2(:,3);
catch
    errMessage = ['error reading coordinate data: ' lasterr];
    return
end


%--------------------------------------------------------------------------
function [UFF,errMessage] = extract2412(DATA,blockLines)
% #2412 - Extract display sequence data-set type 82 data
% Added by Ben Cazzolato, 10/3/2008
%
% Universal Dataset Number 2412
% by zopeown � last modified 2007-05-02 06:56
% 
% Name:   Elements
% Status: Current
% Owner:  Simulation
% Revision Date: 14-AUG-1992
% -----------------------------------------------------------------------
%  
% Record 1:        FORMAT(6I10)
%                  Field 1       -- element label
%                  Field 2       -- fe descriptor id
%                  Field 3       -- physical property table number
%                  Field 4       -- material property table number
%                  Field 5       -- color
%                  Field 6       -- number of nodes on element
%  
% Record 2:  *** FOR NON-BEAM ELEMENTS ***
%                  FORMAT(8I10)
%                  Fields 1-n    -- node labels defining element
%  
% Record 2:  *** FOR BEAM ELEMENTS ONLY ***
%                  FORMAT(3I10)
%                  Field 1       -- beam orientation node number
%                  Field 2       -- beam fore-end cross section number
%                  Field 3       -- beam  aft-end cross section number
%  
% Record 3:  *** FOR BEAM ELEMENTS ONLY ***
%                  FORMAT(8I10)
%                  Fields 1-n    -- node labels defining element
%  
% Records 1 and 2 are repeated for each non-beam element in the model.
% Records 1 - 3 are repeated for each beam element in the model.
%  
% Example:
%  
%     -1
%   2412
%          1        11         1      5380         7         2
%          0         1         1
%          1         2
%          2        21         2      5380         7         2
%          0         1         1
%          3         4
%          3        22         3      5380         7         2
%          0         1         2
%          5         6
%          6        91         6      5380         7         3
%         11        18        12
%          9        95         6      5380         7         8
%         22        25        29        30        31        26        24        23
%         14       136         8         0         7         2
%         53        54
%         36       116        16      5380         7        20
%        152       159       168       167       166       158       150       151
%        154       170       169       153       157       161       173       172
%        171       160       155       156
%     -1
% 
% FE Descriptor Id definitions
% ____________________________
% 
%    11  Rod
%    21  Linear beam
%    22  Tapered beam
%    23  Curved beam
%    24  Parabolic beam
%    31  Straight pipe
%    32  Curved pipe
%    41  Plane Stress Linear Triangle
%    42  Plane Stress Parabolic Triangle
%    43  Plane Stress Cubic Triangle
%    44  Plane Stress Linear Quadrilateral
%    45  Plane Stress Parabolic Quadrilateral
%    46  Plane Strain Cubic Quadrilateral
%    51  Plane Strain Linear Triangle
%    52  Plane Strain Parabolic Triangle
%    53  Plane Strain Cubic Triangle
%    54  Plane Strain Linear Quadrilateral
%    55  Plane Strain Parabolic Quadrilateral
%    56  Plane Strain Cubic Quadrilateral
%    61  Plate Linear Triangle
%    62  Plate Parabolic Triangle
%    63  Plate Cubic Triangle
%    64  Plate Linear Quadrilateral
%    65  Plate Parabolic Quadrilateral
%    66  Plate Cubic Quadrilateral
%    71  Membrane Linear Quadrilateral
%    72  Membrane Parabolic Triangle
%    73  Membrane Cubic Triangle
%    74  Membrane Linear Triangle
%    75  Membrane Parabolic Quadrilateral
%    76  Membrane Cubic Quadrilateral
%    81  Axisymetric Solid Linear Triangle
%    82  Axisymetric Solid Parabolic Triangle
%    84  Axisymetric Solid Linear Quadrilateral
%    85  Axisymetric Solid Parabolic Quadrilateral
%    91  Thin Shell Linear Triangle
%    92  Thin Shell Parabolic Triangle
%    93  Thin Shell Cubic Triangle
%    94  Thin Shell Linear Quadrilateral
%    95  Thin Shell Parabolic Quadrilateral
%    96  Thin Shell Cubic Quadrilateral
%    101 Thick Shell Linear Wedge
%    102 Thick Shell Parabolic Wedge
%    103 Thick Shell Cubic Wedge
%    104 Thick Shell Linear Brick
%    105 Thick Shell Parabolic Brick
%    106 Thick Shell Cubic Brick
%    111 Solid Linear Tetrahedron
%    112 Solid Linear Wedge
%    113 Solid Parabolic Wedge
%    114 Solid Cubic Wedge
%    115 Solid Linear Brick
%    116 Solid Parabolic Brick
%    117 Solid Cubic Brick
%    118 Solid Parabolic Tetrahedron
%    121 Rigid Bar
%    122 Rigid Element
%    136 Node To Node Translational Spring
%    137 Node To Node Rotational Spring
%    138 Node To Ground Translational Spring
%    139 Node To Ground Rotational Spring
%    141 Node To Node Damper
%    142 Node To Gound Damper
%    151 Node To Node Gap
%    152 Node To Ground Gap
%    161 Lumped Mass
%    171 Axisymetric Linear Shell
%    172 Axisymetric Parabolic Shell
%    181 Constraint
%    191 Plastic Cold Runner
%    192 Plastic Hot Runner
%    193 Plastic Water Line
%    194 Plastic Fountain
%    195 Plastic Baffle
%    196 Plastic Rod Heater
%    201 Linear node-to-node interface
%    202 Linear edge-to-edge interface
%    203 Parabolic edge-to-edge interface
%    204 Linear face-to-face interface
%    208 Parabolic face-to-face interface
%    212 Linear axisymmetric interface
%    213 Parabolic axisymmetric interface
%    221 Linear rigid surface
%    222 Parabolic rigid surface
%    231 Axisymetric linear rigid surface
%    232 Axisymentric parabolic rigid surface
% 
% ------------------------------------------------------------------------------

% Define all "beam like" elements since these have a different structure
beam_like = [11,21:24,31:32,121:122];
Largest_Num_Nodes = 20;     % This is used to zero pad the data if different element types present
UFF = [];
errMessage = [];
% Initialise matrices containing field types
ElementLabel = [];
FEDescriptor = [];
PhysicalProp = [];
MaterialProp = [];
ElementColour = [];
NumNodes = [];
Element = [];
try
    values = sscanf(DATA(blockLines(1,1):blockLines(end,2)),'%g');
    nVals = length(values);
    data_remaining = 1;
    while data_remaining
        ElementLabel = [ElementLabel;round(values(1))];
        FEDescriptor = [FEDescriptor;round(values(2))];
        PhysicalProp = [PhysicalProp;round(values(3))];
        MaterialProp = [MaterialProp;round(values(4))];
        ElementColour = [ElementColour;round(values(5))];
        NumNodes = [NumNodes;round(values(6))];
        % Check for beam elements
        if sum(round(values(2))==beam_like)
            % Beam Element
            %disp('Beam Elements')
            Element = [Element;[[round(values(7:6+3+round(values(6))))]',NaN*zeros(1,Largest_Num_Nodes-3-round(values(6)))]];
            values = values(7+3+round(values(6)):end);   % Remove the element from the table
        else
            % Not Beam Element
            Element = [Element;[[round(values(7:6+round(values(6))))]',NaN*zeros(1,Largest_Num_Nodes-round(values(6)))]];
            values = values(7+round(values(6)):end);   % Remove the element from the table
        end
        if isempty(values)      % Check if any data remaining
            data_remaining=0;
        end
    end
    UFF.ElementLabel = ElementLabel;
    UFF.FEDescriptor = FEDescriptor;
    UFF.PhysicalProp = PhysicalProp;
    UFF.MaterialProp = MaterialProp;
    UFF.ElementColour = ElementColour;
    UFF.NumNodes = NumNodes;
    % Strip unnecessary columns from element matrix
    temp = find(sum(~isnan(Element))>0);
    if length(Element(:,1))==1
        UFF.Element = Element;
    else
        UFF.Element = Element(:,temp);
    end
catch
    errMessage = ['error reading trace-line data at line' num2str(lineN) ' relatively to current data-set: ' lasterr];
    return
end


%--------------------------------------------------------------------------
function [UFF,errMessage] = extract2414(DATA,blockLines)
% #2414 - Extract display sequence data-set type 82 data
% Added by Haike Brick, 16/9/2008
%
% Universal Dataset
% Number: 2414
% Name:   Analysis Data
% Status: Current
% Owner:  Simulation
% Revision Date: 3-OCT-1994
%
% by zopeown � last modified 2007-05-02 06:56
% 
% -----------------------------------------------------------------------
%  Description:
%  http://www.sdrl.uc.edu/universal-file-formats-for-modal-analysis-testing-1/file-format-storehouse/unv_2414.htm
%
% ------------------------------------------------------------------------------

UFF = [];
errMessage = [];
lineN = 1;
nLines = size(blockLines,1);
errN = 0;

try
    % Line 1
    UFF.d1 = strim(sscanf(DATA(blockLines(1,1):blockLines(1,2)),'%c',80));
    lineN = lineN + 1;
    % Line 2
    UFF.d2 = strim(sscanf(DATA(blockLines(2,1):blockLines(2,2)),'%c',80));
    lineN = lineN + 1;
    % Line 3
    UFF.location = sscanf(DATA(blockLines(3,1):blockLines(3,2)),'%i',1);
    lineN = lineN + 1;
    % Line 4
    UFF.ID1 = strim(sscanf(DATA(blockLines(4,1):blockLines(4,2)),'%c',80));
    lineN = lineN + 1;
    % Line 5
    UFF.ID2 = strim(sscanf(DATA(blockLines(5,1):blockLines(5,2)),'%c',80));
    lineN = lineN + 1;
    % Line 6
    UFF.ID3 = strim(sscanf(DATA(blockLines(6,1):blockLines(6,2)),'%c',80));
    lineN = lineN + 1;
    % Line 7
    UFF.ID4 = strim(sscanf(DATA(blockLines(7,1):blockLines(7,2)),'%c',80));
    lineN = lineN + 1;
    % Line 8
    UFF.ID5 = strim(sscanf(DATA(blockLines(8,1):blockLines(8,2)),'%c',80));
    lineN = lineN + 1;
    % Line 9
    %tmpLine = DATA(blockLines(9,1):blockLines(9,2));
    %tmpLine = [tmpLine repmat(' ',1,80-length(tmpLine))];
    tmpLine = sscanf(DATA(blockLines(9,1):blockLines(9,2)),'%i',6);
    lineN = lineN + 1;
    %UFF.modelType = sscanf(tmpLine(1:10),'%i',1);
    UFF.modelType = tmpLine(1);
    UFF.analysisType = tmpLine(2);
    UFF.dataCharacter = tmpLine(3);
    UFF.resultType = tmpLine(4);
    UFF.dataType = tmpLine(5);
    NVALDC = tmpLine(6);
    
    % Reading records 10 and 11 
    tmpLine10 = sscanf(DATA(blockLines(10,1):blockLines(10,2)),'%i',8);
    tmpLine11 = sscanf(DATA(blockLines(11,1):blockLines(11,2)),'%i',2);
    % Reading data from record 12 und 13
    tmpLine12 = sscanf(DATA(blockLines(12,1):blockLines(12,2)),'%e',6);
    tmpLine13 = sscanf(DATA(blockLines(13,1):blockLines(13,2)),'%e',6);
    if UFF.analysisType == 2  % Normal Mode
        UFF.DesignSetID = tmpLine10(1);
        UFF.IterationNumber = tmpLine10(2);
        UFF.SolutionSetID = tmpLine10(3);
        UFF.BoundCond = tmpLine10(4);
        UFF.modeNum = tmpLine10(6);
        UFF.Freq = tmpLine12(2);
        UFF.modalMass = tmpLine12(4);
        UFF.v_damping_ratio = tmpLine12(5);
        UFF.h_damping_ratio = tmpLine12(6); 
    elseif UFF.analysisType == 5  % frequency response
        UFF.DesignSetID = tmpLine10(1);
        UFF.SolutionSetID = tmpLine10(3);
        UFF.BoundCond = tmpLine10(4);
        UFF.LoadSet = tmpLine10(5);
        UFF.FreqNum = tmpLine10(8);
        UFF.CreationOpt = tmpLine11(1);
        UFF.retainNum = tmpLine11(2);
        UFF.Freq = tmpLine12(2);
    else
        errMessage = ['analysis type can not be extracted, please augment readuff.m for this analysis type'];
        return
    end
    clear tmpLine*
    if UFF.location == 1 % data at nodes
        node = sscanf(DATA(blockLines(14,1):blockLines(14,2)),'%i',1);        
    else 
        errMessage = ['Data set location', int2str(UFF.location) ,'can not be extracted, please augment readuff.m for this analysis type'];
        return
    end
    % Read response data by x,y,...components into r1..r6
    if UFF.dataType == 5,   % complex data
        nLinesR15 = ceil(NVALDC * 2/ 6);
        ndata = NVALDC*2;
        ii = 0;
        nnodes = floor((nLines-13)/(1+nLinesR15));
        data = zeros(nnodes,NVALDC);
        nodeNum = zeros(nnodes,1);
        for lne = 14 : (1+nLinesR15) : nLines-1,
            ii = ii + 1;
            nodeNum(ii) = sscanf(DATA(blockLines(lne,1):blockLines(lne,2)),'%i',1);
            ndata = NVALDC*2;
            tmpLine = sscanf(DATA(blockLines(lne+1,1):blockLines(lne+nLinesR15,2)),'%e',ndata);
            for iii = 1:NVALDC
                data(ii,iii) = complex(tmpLine(2*iii-1),tmpLine(2*iii));
            end
        end
    elseif UFF.dataType == 2, %real data
        nLinesR15 = ceil(NVALDC * 1/ 6);
        ndata = NVALDC;
        ii = 0;
        nnodes = floor((nLines-13)/(1+nLinesR15));
        data = zeros(nnodes,NVALDC);
        nodeNum = zeros(nnodes,1);
        for lne = 14 : (1+nLinesR15) : nLines-1,
            ii = ii + 1;
            nodeNum(ii) = sscanf(DATA(blockLines(lne,1):blockLines(lne,2)),'%i',1);
            tmpLine = sscanf(DATA(blockLines(lne+1,1):blockLines(lne+nLinesR15,2)),'%e',ndata);
            for iii = 1:NVALDC
                data(ii,iii) = tmpLine(iii);
            end
        end
    else
        errMessage = ['Can not handle data type ', int2str(UFF.dataType), ' please augment readuff.m for this data type by yourself.'];
        return
    end
    UFF.data = data;
    UFF.nodeNum = nodeNum;
catch
    errMessage = ['error reading modal data: ' lasterr];
    return
end


