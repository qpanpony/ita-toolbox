function Info = writeuff(fileName, UffDataSets, action)
%WRITEUFF Writes UFF (Universal File Format) files of five types:
%   151, 15, 55, 58, 82, 164, 2420, and also the hybrid one, 58b
%   Info = writeuff(fileName, UffDataSets, action)
%
%   - fileName:     name of the uff file to write data to (add or replace - see action parameter)
%   - UffDataSets:  an array of structures; each structure holds one data set
%                   (the data set between -1 and -1; Each structure,
%                   UffDataSets{i}, has the field
%                       .dsType
%                       .binary
%                   and some additional, data-set dependent fields (some of
%                   them are optional) and are as follows:
%                   #58 - for measurement data - function at dof (58). This
%                   data is always saved as double precision data:
%                       .x (time or frequency)  .measData               .d1 (descrip. 1)
%                       .d2 (descrip. 2)        .date                   .functionType (see notes) 
%                       .rspNode                .rspDir                 .refNode       
%                       .refDir                 
%                       (Optional fields):
%                       .ID_4                   .ID_5                   .loadCaseId  
%                       .rspEntName             .refEntName             .abscDataChar           .ordDataChar  
%                       .ordDenomDataChar       .abscissaUnitsLabel
%                       .ordinateNumUnitsLabel  .ordinateDenumUnitsLabel
%                       .zUnitsLabel            .zAxisValue
%
%                   #15 - coordinate data (15)  (Grid pts):
%                       .nodeN                  .x                      .y
%                       .z
%                       (Optional fields):      
%                       .defCS                  .dispCS                 .color
%
%                   #82 - display Sequence data (82):
%                       .traceNum               .lines
%                       (Optional fields):
%                       .color                  .ID
%
%                   #55 - data at nodes (55):
%                       Common fields:
%                       .analysisType           .dataCharacter = 1      .r1
%                       .r2                     .r3                     .responseType
%                       (Optional fields):
%                       .r4                     .r5                     .r6
%                       Normal modes specific fields (analysisType = 2)
%                       .modeNum                .modeFreq               .modeMass 
%                       .mode_v_damping_ratio   .mode_h_damping_ratio                   
%                       ...or, for complex modes specific fields (analysisType = 3 or 7)
%                       .modeNum                .eigVal                 .modalA        
%                       .modalB                 
%                       ...or, for frequency response specific fields (analysisType = 5)
%                       .freqNum                .freq
%
%                   #151 - header data (151):
%                       .modelName              .description            .dbApp
%                       .dbVersion              .uffApp
%
%                   #164 - units (164):
%                       .unitsCode              .tempMode
%                       Unit factors for converting universal file units to SI. To convert from
%                       universal file units to SI divide by the appropriate factor listed below:
%                       .facLength              .facForce               .facTemp            
%                       .facTempOffset
%                       (Optional fields):
%                       .unitsDescription
%
%                   #2420 - coordinate systems (2420):
%                       .partUID                .partName
%                       .csLabels (array)       .csTypes (0=cart. 1=sph. 2=cyl.)
%                       .csColors (array)
%                       .csTrMatrices (cell array of 4x3 transformation matrices for each cs)
%                       (optional)
%                       .csNames (cell array)
%
%   - action:       (optional) 'add' (default) or 'replace'
%
%   - Info:         (optional) structure with the following fields:
%                   .errcode    -   an array of error codes for each data
%                                   ment to be written; 0 = no error otherwise an error occured in data
%                                   set being written - see errmsg
%                   .errmsg     -   error messages (cell array of strings) for each
%                                   data set - empty if no error occured at specific data set
%                   .nErrors    -   number of errors found (unsupported
%                                   datasets, error writing data set,...)
%                   .errorMsgs  -   error messages (empty if no error is found)
%
%   NOTES: r1..r6 are response vectors with node numbers in ROWS and
%   direction in COLUMN (r1=x, r2=y,...,r6=rz).
%
%   functionType can be one of the following:
%               0 - General or Unknown
%               1 - (supported) Time Response
%               2 - (supported) Auto Spectrum
%               3 - (supported) Cross Spectrum
%               4 - (supported) Frequency Response Function
%               5 - Transmissibility
%               6 - (supported) Coherence
%               7 - Auto Correlation
%               8 - Cross Correlation
%               9 - Power Spectral Density (PSD)
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
%   See also: READUFF
%
%   SOURCES:    [1] Bryce Gardner's read_uff obtained from the internet
%               [2] http://www.sdrl.uc.edu/uff/SDRChelp/LANG/English/unv_ug/book.htm
%
%
%   FREE SOFTWARE - please refer the source
%   Copyright (c) 2004-2005 by Primoz Cermelj
%   First release on 02.02.2004
%   Primoz Cermelj, Slovenia
%   Contact: primoz.cermelj@email.si
%   Download location: http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6395&objectType=file
%
%   Version:  0.9.8b3
%   Last revision: 08.01.2008
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
% WRITEUFF history
%----------------
% [v.0.9.8b3] 08.01.2008
% - FIX: correct number of bytes written for 58b when uneven data
% [v.0.9.8b2] 31.01.2006
% - NEW: uneven abscissa data-writing is now supported
% - NEW: 2420 data-set added (coordinate systems)
% [v.0.9.5b1] 06.06.2005
% - NEW: hybrid binary-58 format (58b) is now supported
% - NEW: binary field was added to UffDataSets structures
% [v.0.9.4] 24.05.2005
% - NEW: dsType field is added to UffDataSets structures; dsTypes parameter
%        is no longer needed
%
%----------------


%--------------
% Check input arguments
%--------------
narginchk(2,3);
if nargin < 3 || isempty(action)
    action = 'add';
end
if ~iscell(UffDataSets)
    error('UffDataSets must be given as a cell array of structures');
end

%--------------
% Open the file for writing
%--------------
if strcmpi(action,'replace')
    [fid,ermesage] = fopen(fileName,'w');
else
    [fid,ermesage] = fopen(fileName,'a');
end
if fid == -1,
    error(['could not open file: ' fileName]);
end

%--------------
% Go through all the data sets and write each data set according to its type
%--------------
nDataSets = length(UffDataSets);

Info.errcode = zeros(nDataSets,1);
Info.errmsg = cell(nDataSets,1);
Info.nErrors = 0;

for ii=1:nDataSets
    try
        %
        switch UffDataSets{ii}.dsType
            case {15,82,55,58,151,164,2420}
                fprintf(fid,'%6i%74s\n',-1,' ');
                switch UffDataSets{ii}.dsType
                    case 15
                        Info.errmsg{ii} = write15(fid,UffDataSets{ii});
                    case 82
                        Info.errmsg{ii} = write82(fid,UffDataSets{ii});
                    case 55
                        Info.errmsg{ii} = write55(fid,UffDataSets{ii});
                    case 58
                        Info.errmsg{ii} = write58(fid,UffDataSets{ii});
                    case 151
                        Info.errmsg{ii} = write151(fid,UffDataSets{ii});
                    case 164
                        Info.errmsg{ii} = write164(fid,UffDataSets{ii});
                    case 2420
                        Info.errmsg{ii} = write2420(fid,UffDataSets{ii});                        
                end
                fprintf(fid,'%6i%74s\n',-1,' ');
            otherwise
                Info.errmsg{ii} = ['Unsupported data set: ' num2str(UffDataSets{ii}.dsType)];
        end
        %
    catch
        fclose(fid);
        error(['Error writing uff file: ' fileName ': ' lasterr]);
    end
end
fclose(fid);

for ii=1:nDataSets
    if ~isempty(Info.errmsg{ii})
        Info.errcode(ii) = 1;
    end
end
Info.nErrors = length(find(Info.errcode));
Info.errorMsgs = Info.errmsg(find(Info.errcode));








%==========================================================================
%                       SUBFUNCTIONS SECTION
%==========================================================================

%--------------------------------------------------------------------------
function errMessage = write15(fid,UFF)
% #15 - Write data-set type 15 data
errMessage = [];
if ispc
    F_13 = '%13.4e';
else
    F_13 = '%13.5e';
end
try
    n = length(UFF.nodeN);
    if ~isfield(UFF,'defCS');   UFF.defCS = zeros(n,1);  end;
    if ~isfield(UFF,'dispCS');  UFF.dispCS = zeros(n,1); end;
    if ~isfield(UFF,'color');   UFF.color = zeros(n,1);  end;
    fprintf(fid,'%6i%74s\n',15,' ');
    for ii=1:n
        fprintf(fid,['%10i%10i%10i%10i' F_13 F_13 F_13 '\n'],UFF.nodeN(ii),UFF.defCS(ii),UFF.dispCS(ii),UFF.color(ii), ...
            UFF.x(ii),UFF.y(ii),UFF.z(ii));
    end
catch
    errMessage = ['error writing coordinate data: ' lasterr];
end
%-----------------------------------------------------------------

%--------------------------------------------------------------------------
function errMessage = write82(fid,UFF)
% #82 - Write data-set type 82 data
errMessage = [];
try
    if ~isfield(UFF,'ID');      UFF.ID = 'NONE'; end;
    if ~isfield(UFF,'color');   UFF.color = 0;  end;
    fprintf(fid,'%6i%74s\n',82,' ');
    fprintf(fid,'%10i%10i%10i\n',UFF.traceNum,length(unique(UFF.lines(UFF.lines>0))),UFF.color);  % line 1
    fprintf(fid,'%-80s\n',UFF.ID); % line 2
    fprintf(fid,'%10i%10i%10i%10i%10i%10i%10i%10i\n',UFF.lines); % line 3
    if rem(length(UFF.lines),8)~=0,
        fprintf(fid,'\n');
    end
catch
    errMessage = ['error writing display-sequence data: ' lasterr];
end
%-----------------------------------------------------------------


%--------------------------------------------------------------------------
function errMessage = write55(fid,UFF)
% #55 - Write data-set type 55 data
if ispc
    F_13 = '%13.4e';
else
    F_13 = '%13.5e';
end
errMessage = [];
try
    if isfield(UFF,'r4') & isfield(UFF,'r5') & isfield(UFF,'r6')
        num_data_per_pt = 6;
    else
        num_data_per_pt = 3;
    end

    fprintf(fid,'%6i%74s\n',55,' ');
    fprintf(fid,'%-80s\n','NONE'); %line 1
    fprintf(fid,'%-80s\n','NONE'); %line 2
    fprintf(fid,'%-80s\n','NONE'); %line 3
    fprintf(fid,'%-80s\n','NONE'); %line 4
    fprintf(fid,'%-80s\n','NONE'); %line 5
    if imag(UFF.r1)~=0 & imag(UFF.r2)~=0 & imag(UFF.r3)~=0,
        data_type = 2;
    else
        data_type = 3;
    end
    fprintf(fid,'%10i%10i%10i%10i%10i%10i\n',1,UFF.analysisType,UFF.dataCharacter, ...
        UFF.responseType,data_type,num_data_per_pt); %line 6
    if UFF.analysisType == 2,                               % Normal modes
        fprintf(fid,'%10i%10i%10i%10i\n',2,4,0,UFF.modeNum); %line 7
        fprintf(fid,[F_13 F_13 F_13 F_13 '\n'], ...
            UFF.modeFreq,UFF.modeMass,UFF.mode_v_damping,UFF.mode_h_damping); %line 8
    elseif UFF.analysisType == 5,                           % Frequency Response
        fprintf(fid,'%10i%10i%10i%10i\n',2,1,0,UFF.freqNum); %line 7
        fprintf(fid,'%13.4e\n', UFF.freq); %line 8
    elseif UFF.analysisType == 3 | UFF.analysisType == 7,   % Complex modes
        fprintf(fid,'%10i%10i%10i%10i\n',2,6,0,UFF.modeNum); %line 7
        fprintf(fid,[F_13 F_13 F_13 F_13 F_13 F_13 '\n'], ...
            real(UFF.eigVal),imag(UFF.eigVal),real(UFF.modalA),imag(UFF.modalA), ...
            real(UFF.modalB),imag(UFF.modalB)); %line 8
    else
        errMessage = ['Unsupported analysis type: ' num2str(UFF.analysisType)];
        return
    end
    if data_type == 2,  % real data
        if num_data_per_pt == 3,
            for k=1:length(UFF.nodeNum);
                fprintf(fid,'%10i\n',UFF.nodeNum(k));
                fprintf(fid,[F_13 F_13 F_13 '\n'],UFF.r1(k),UFF.r2(k),UFF.r3(k));
            end
        else
            for k=1:length(UFF.nodeNum);
                fprintf(fid,'%10i\n',UFF.nodeNum(k));
                fprintf(fid,[F_13 F_13 F_13 F_13 F_13 F_13 '\n'], ...
                    UFF.r1(k),UFF.r2(k),UFF.r3(k),UFF.r4(k),UFF.r5(k),UFF.r6(k));
            end
        end
    else               % complex data
        for k=1:length(UFF.nodeNum);
            fprintf(fid,'%10i\n',UFF.nodeNum(k));
            fprintf(fid,[F_13 F_13 F_13 F_13 F_13 F_13 '\n'], ...
                real(UFF.r1(k)),imag(UFF.r1(k)), real(UFF.r2(k)),imag(UFF.r2(k)), ...
                real(UFF.r3(k)),imag(UFF.r3(k)));
        end
    end

catch
    errMessage = ['error writing modal data: ' lasterr];
end
%-----------------------------------------------------------------


%--------------------------------------------------------------------------
function errMessage = write58(fid,UFF)
% #58 - Write data-set type 58 data
if ispc
    F_13 = '%13.4e';
    F_20 = '%20.11e';
else
    F_13 = '%13.5e';
    F_20 = '%20.12e';
end
errMessage = [];
try
    if isempty(find(UFF.functionType == [1 2 3 4 6]))
        errMessage = ['Unsupported function type: ' num2str(UFF.functionType)];
        return
    end
    if ~isfield(UFF,'ID_4');  UFF.ID_4 = 'NONE'; end;
    if ~isfield(UFF,'ID_5');  UFF.ID_5 = 'NONE'; end;
    if ~isfield(UFF,'loadCaseId');  UFF.loadCaseId = 0; end;
    if ~isfield(UFF,'rspEntName');  UFF.rspEntName = 'NONE'; end;
    if ~isfield(UFF,'refEntName');  UFF.refEntName = 'NONE'; end;
    if ~isfield(UFF,'abscissaUnitsLabel');  UFF.abscissaUnitsLabel= 'NONE'; end;
    if ~isfield(UFF,'ordinateNumUnitsLabel');  UFF.ordinateNumUnitsLabel= 'NONE'; end;
    if ~isfield(UFF,'ordinateDenumUnitsLabel');  UFF.ordinateDenumUnitsLabel= 'NONE'; end;
    if ~isfield(UFF,'zUnitsLabel');  UFF.zUnitsLabel= 'NONE'; end;
    if ~isfield(UFF,'zAxisValue');  UFF.zAxisValue= 0; end;
    if UFF.functionType == 1    % time response
        if ~isfield(UFF,'abscDataChar');  UFF.abscDataChar = 17; end;
        if ~isfield(UFF,'ordDataChar');  UFF.ordDataChar = 8; end;
        if ~isfield(UFF,'ordDenomDataChar');  UFF.ordDenomDataChar = 0; end;
    else
        if ~isfield(UFF,'abscDataChar');  UFF.abscDataChar = 18; end;
        if ~isfield(UFF,'ordDataChar');  UFF.ordDataChar = 12; end;
        if ~isfield(UFF,'ordDenomDataChar');  UFF.ordDenomDataChar = 13; end;
    end
    %
    isXEven = ( length(unique(UFF.x(2:end)-UFF.x(1:end-1)))==1 );
    %
    if UFF.binary
        [filename, mode, machineformat] = fopen(fid);
        if strcmpi(machineformat(1:7),'ieee-le')
            byteOrdering = 1;
        else
            byteOrdering = 2;
        end
        if imag(UFF.measData)==0
            nBytes = length(UFF.measData)*8;
        else
            nBytes = length(UFF.measData)*16;
        end
        if ~isXEven
            nBytes = nBytes + length(UFF.measData)*8;
        end
        fprintf(fid,'%6i%1s%6i%6i%12i%12i%6i%6i%12i%12i\n',58,'b',byteOrdering,2,11,nBytes,0,0,0,0);
    else
        fprintf(fid,'%6i%74s\n',58,' ');
    end
    if length(UFF.d1)<=80,
        fprintf(fid,'%-80s\n',UFF.d1);   %  line 1
    else
        fprintf(fid,'%-80s\n',UFF.d1(1:80));   %  line 1
    end
    if length(UFF.d2)<=80,
        fprintf(fid,'%-80s\n',UFF.d2);   %  line 2
    else
        fprintf(fid,'%-80s\n',UFF.d2(1:80));   %  line 2
    end
    if length(UFF.date)<=80,
        fprintf(fid,'%-80s\n',UFF.date);   %  line 3
    else
        fprintf(fid,'%-80s\n',UFF.date(1:80));   %  line 3
    end
    if length(UFF.ID_4)<=80,
        fprintf(fid,'%-80s\n',UFF.ID_4);   %  line 4
    else
        fprintf(fid,'%-80s\n',UFF.ID_4(1:80));   %  line 4
    end
    if length(UFF.ID_5)<=80,
        fprintf(fid,'%-80s\n',UFF.ID_5);   %  line 5
    else
        fprintf(fid,'%-80s\n',UFF.ID_5(1:80));   %  line 5
    end
    %
    fprintf(fid,'%5i%10i%5i%10i %-10s%10i%4i %-10s%10i%4i\n',UFF.functionType,0,0,UFF.loadCaseId,UFF.rspEntName,...
        UFF.rspNode,UFF.rspDir,UFF.refEntName,UFF.refNode,UFF.refDir);    % line 6
    numpt = length(UFF.measData);
    % line 7
    dx = UFF.x(2) - UFF.x(1);
    if imag(UFF.measData)==0
        % Always save as double precision
        fprintf(fid,['%10i%10i%10i' F_13 F_13 F_13 '           \n'],4,numpt,isXEven,isXEven*UFF.x(1),isXEven*dx,UFF.zAxisValue);
    else
        % Always save as double precision
        fprintf(fid,['%10i%10i%10i' F_13 F_13 F_13 '           \n'],6,numpt,isXEven,isXEven*UFF.x(1),isXEven*dx,UFF.zAxisValue);
    end
    % line 8
    fprintf(fid,'%10i%5i%5i%5i %-20s %-20s             \n',UFF.abscDataChar,0,0,0,'NONE',UFF.abscissaUnitsLabel);
    % line 9
    fprintf(fid,'%10i%5i%5i%5i %-20s %-20s             \n',UFF.ordDataChar,0,0,0,'NONE',UFF.ordinateNumUnitsLabel);
    %                                                      ^--acceleration data
    % line 10
    % others: 0=unknown,8=displacement,11=velocity,13=excitation force,15=pressure
    fprintf(fid,'%10i%5i%5i%5i %-20s %-20s             \n',UFF.ordDenomDataChar,0,0,0,'NONE',UFF.ordinateDenumUnitsLabel);
    %                                                      ^--excitation force data
    % line 11
    % others: 0=unknown,8=displacement,11=velocity,12=acceleration,15=pressure
    fprintf(fid,'%10i%5i%5i%5i %-20s %-20s             \n',0,0,0,0,'NONE',UFF.zUnitsLabel);
    %
    % line 12: % always as double precision
    nOrdValues = length(UFF.measData);
    if imag(UFF.measData)==0
        if isXEven
            newdata = UFF.measData;
        else
            newdata = zeros(2*nOrdValues,1);
            newdata(1:2:end-1) = UFF.x;
            newdata(2:2:end) = UFF.measData;
        end
    else
        if isXEven
            newdata = zeros(2*nOrdValues,1);
            newdata(1:2:end-1) = real(UFF.measData);
            newdata(2:2:end)   = imag(UFF.measData);
        else
            newdata = zeros(3*nOrdValues,1);
            newdata(1:3:end-2) = UFF.x;
            newdata(2:3:end-1) = real(UFF.measData);
            newdata(3:3:end)   = imag(UFF.measData);
        end
    end
    if UFF.binary
        if imag(UFF.measData)==0
            fwrite(fid,newdata, 'double');
        else
            fwrite(fid,newdata, 'double');
        end
    else    % ascii
        if imag(UFF.measData)==0    % real data
            if isXEven
                fprintf(fid,[F_20 F_20 F_20 F_20 '\n'],newdata);
            else
                fprintf(fid,[F_13 F_20 F_13 F_20 '\n'],newdata);
            end
            if rem(length(newdata),4)~=0,
                fprintf(fid,'\n');
            end
        else                        % complex data
            if isXEven
                fprintf(fid,[F_20 F_20 F_20 F_20 '\n'],newdata);
                if rem(length(newdata),4)~=0,
                    fprintf(fid,'\n');
                end
            else
                fprintf(fid,[F_13 F_20 F_20 '\n'],newdata);
                if rem(length(newdata),3)~=0,
                    fprintf(fid,'\n');
                end
            end
        end
    end

catch
    errMessage = ['error writing measurement data: ' lasterr];
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function errMessage = write151(fid,UFF)
% #151 - Write data-set type 151 data
errMessage =[];
try
    fprintf(fid,'%6i%74s\n',151,' ');
    fprintf(fid,'%-80s\n',UFF.modelName); % line 1
    fprintf(fid,'%-80s\n',UFF.description); % line 2
    fprintf(fid,'%-80s\n',UFF.dbApp); % line 3
    d = datestr(now,1);
    d(end-3:end-2) = [];
    if ischar(UFF.dbVersion); UFF.dbVersion = str2num(UFF.dbVersion); end;
    if isempty(UFF.dbVersion); UFF.dbVersion = 0; end;
    fprintf(fid,'%-10s%-10s%10i%10i%10i\n',d,datestr(now,13),UFF.dbVersion,UFF.dbVersion,0); % line 4
    fprintf(fid,'%-10s%-10s\n',d,datestr(now,13)); % line 5
    fprintf(fid,'%-80s\n',UFF.uffApp); % line 6
    fprintf(fid,'%-10s%-10s\n',d,datestr(now,13)); % line 7
catch
    errMessage = ['error writing header data: ' lasterr];
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function errMessage = write164(fid,UFF)
% #164 - Write data-set type 164 data
errMessage = [];
try
    if ~isfield(UFF,'unitsDescription'); UFF.unitsDescription = ' '; end;
    fprintf(fid,'%6i%74s\n',164,' ');
    if ischar(UFF.tempMode); UFF.tempMode = str2num(UFF.tempMode); end;
    if isempty(UFF.tempMode); UFF.tempMode = 1; end;
    fprintf(fid,'%10i%-20s%10i\n',UFF.unitsCode,UFF.unitsDescription,UFF.tempMode); % line 1
    %
    str = lower(sprintf('%25.17e%25.17e%25.17e',UFF.facLength,UFF.facForce,UFF.facTemp)); % line 2
    str = strrep(str,'e+','D+');
    str = strrep(str,'e-','D-');
    fprintf(fid,'%s\n',str);
    str = lower(sprintf('%25.17e',UFF.facTempOffset)); % line 3
    str = strrep(str,'e+','d+');
    str = strrep(str,'e-','d-');
    fprintf(fid,'%s\n',str);
catch
    errMessage = ['error writing units data: ' lasterr];
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function errMessage = write2420(fid,UFF)
% #2420 - Write data-set type 2420 data
errMessage = [];
if ispc
    F_25 = '%25.15e';
else
    F_25 = '%25.16e';
end
try
    n = length(UFF.csLabels);
    if ~isfield(UFF,'csNames'); UFF.csNames = cell(n,1); UFF.csNames(1:n) = {' '}; end;
    fprintf(fid,'%6i%74s\n',2420,' ');
    fprintf(fid,'%10i%10i\n',UFF.partUID,0);       % line 1
    fprintf(fid,'%-40s\n',UFF.partName);            % line 2
    for ii=1:n
        fprintf(fid,'%10i%10i%10i%10i\n',...
            UFF.csLabels(ii),UFF.csTypes(ii),UFF.csColors(ii),0);     % line 3
        fprintf(fid,'%-40s\n',UFF.csNames{ii});     % line 4
        fprintf(fid,[F_25 F_25 F_25 '\n'],UFF.csTrMatrices{ii}(1,1:3)); % line 5
        fprintf(fid,[F_25 F_25 F_25 '\n'],UFF.csTrMatrices{ii}(2,1:3)); % line 6
        fprintf(fid,[F_25 F_25 F_25 '\n'],UFF.csTrMatrices{ii}(3,1:3)); % line 7
        fprintf(fid,[F_25 F_25 F_25 '\n'],UFF.csTrMatrices{ii}(4,1:3)); % line 8
    end
    
catch
    errMessage = ['error writing coordinate system data: ' lasterr];
end
%--------------------------------------------------------------------------
