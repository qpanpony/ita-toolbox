function ita_writeunv58(varargin)
%ITA_WRITEUNV58 - write data as frequency response per mesh node as a unv58 dataset
%  This function takes a struct of measurement data as input and writes the
%  frequency response for each node of a mesh into the specified file.
%
%  An optional third argument 'action', value 'add' or 'replace', controls
%  whether the data is appended to a file (if it already exists).
%  By default, the file contents are replaced.
%
%  Call: ita_writeunv58(Data,unvFilename)
%  Call: ita_unvwrite58(Data,unvFilename,'action','add')
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_unv2unv, ita_readunv58, ita_readunv2414.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_writeunv58">doc ita_writeunv58</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 23-Nov-2008

%% Initialization
% Number of Input Arguments
narginchk(2,4);
sArgs        = struct('pos1_Data','itaSuper','pos2_unvFilename','string','action','replace');
[Data,unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Gather meta data
ita_verbose_info('ITA_WRITEUNV58::preparing ...',2);
if isa(Data.channelCoordinates,'itaMeshNodes') && ~any(isnan(Data.channelCoordinates.ID))
    nodes = Data.channelCoordinates.ID;
else
    uData = Data.userData;
    if ~isempty(find(strcmpi(uData,'nodeN')==1,1))
        nodes = uData{find(strcmpi(uData,'nodeN')==1)+1}(:); % node IDs
    else
        error([upper(mfilename) ':could not find node IDs']);
    end
end

if ispc
    zeroString = '0.0000e+000';
    format      = '%1.4e';
else
    zeroString = '0.00000e+00';
    format      = '%1.5e';
end

dateStr = ['Date (DD/MM/YYYY)      ' datestr(now,24)];

%% gather actual data

switch Data.domain
    case 'time'
        X = Data.timeVector;
        Y = Data.timeData;
    case 'freq'
        X = Data.freqVector;
        Y = Data.freqData;
    otherwise
        error('Input has a non-supported domain')
end

nodes     = nodes(:);
[nodes,sortIds] = sort(nodes);
Y         = Y(:,sortIds);

nNodes    = numel(nodes);
nNodesStr = num2str(nNodes);
nX        = size(X,1);
nXStr     = num2str(nX);
spacer    = ' ';
spacerX   = spacer(:,ones(1,max(2,10-size(nXStr,2))));

% this is really stupid but necessary
line1    = ['    -1' spacer(:,ones(1,80-6))]; % delimiter
line2    = ['    58' spacer(:,ones(1,80-4))]; % dataset
line3    = ['ita_writeunv58' spacer(:,ones(1,80-11))]; % ID
line4    = ['NONE' spacer(:,ones(1,80-4))]; % ID
line5    = [dateStr spacer(:,ones(1,80-33))]; % date
line7    = ['Trust no one.' spacer(:,ones(1,80-13))]; % ID

switch Data.domain
    case 'time'
        if isa(Data,'itaAudio')
            dataDivider = 6;
            line9str = ['         2' spacerX nXStr '         1  ' zeroString '  ' num2str(1/Data.samplingRate,format) '  ' zeroString];
        else
            dataDivider = 3;
            line9str = ['         2' spacerX nXStr '         0  ' zeroString '  ' zeroString '  ' zeroString];
        end
        line10   = ['        17    0    0    0 NONE                  s' spacer(:,ones(1,80-49))];
    case 'freq'
        dataDivider = 2;
        
        line9str = ['         5' spacerX nXStr '         0  ' zeroString '  ' zeroString '  ' zeroString];
        line10   = ['        18    0    0    0 NONE                 Hz' spacer(:,ones(1,80-49))];
end
xNum      = floor(nX/dataDivider);
xLeft     = mod(nX,dataDivider);

line9    = [line9str spacer(:,ones(1,max(0,80-length(line9str))))];
line11 = ['         1    0    0    0 NONE                 ' Data.channelUnits{1} spacer(:,ones(1,80-50))];
line12 = ['         0    0    0    0 NONE                 NONE' spacer(:,ones(1,80-51))];
line13 = ['         0    0    0    0 NONE                 NONE' spacer(:,ones(1,80-51))];

if strcmp(sArgs.action,'add')
    fid = fopen(unvFilename,'at');
else
    fid = fopen(unvFilename,'wt');
end
% based on free memory use the fast version or the one that has less memory usage
if fid ~= -1
    if numel(Y) < 0.5*1024*1024
        if strcmpi(Data.domain,'time')
            timeValStr = num2str(Y(:),format);
            nodesStr   = num2str(nodes);
            xStr       = num2str(X,format);
            iStr       = num2str((1:nNodes).');
            spNod      = spacer(:,ones(1,max(2,16-size(nodesStr,2))));
            line6sp = spacer(:,ones(1,max(0,80-11-size(nodesStr,2)))); % separator
            line8sp = spacer(:,ones(1,max(0,80-35-length(spNod)-size(nodesStr,2)-29))); % separator
            for i = 1:nNodes
                ita_verbose_info(['ITA_WRITEUNV58::writing ' nXStr ' samples for node: ' nodesStr(i,:) ' (' iStr(i,:) ' of ' nNodesStr ')'],2);
                fprintf(fid,'%s\n',line1);
                fprintf(fid,'%s\n',line2);
                fprintf(fid,'%s\n',line3);
                fprintf(fid,'%s\n',line4);
                fprintf(fid,'%s\n',line5);
                fprintf(fid,'%s\n',['node ' nodesStr(i,:) line6sp]); % ID
                fprintf(fid,'%s\n',line7);
                fprintf(fid,'%s\n',['    1         0    1         0 NONE' spNod nodesStr(i,:) '   3 NONE               0   3' line8sp]);
                fprintf(fid,'%s\n',line9);
                fprintf(fid,'%s\n',line10);
                fprintf(fid,'%s\n',line11);
                fprintf(fid,'%s\n',line12);
                fprintf(fid,'%s\n',line13);
                for k = 1:xNum
                    switch dataDivider
                        case 6
                            fprintf(fid,'%s\n',['  ' timeValStr(dataDivider*k-5+(i-1)*nX,:) ' ' timeValStr(dataDivider*k-4+(i-1)*nX,:) ' ' timeValStr(dataDivider*k-3+(i-1)*nX,:) ' ' timeValStr(dataDivider*k-2+(i-1)*nX,:) ' ' timeValStr(dataDivider*k-1+(i-1)*nX,:) ' ' timeValStr(dataDivider*k+(i-1)*nX,:)]);
                        case 3
                            fprintf(fid,'%s\n',['  ' xStr(dataDivider*k-2,:) ' ' timeValStr(dataDivider*k-2+(i-1)*nX,:) '  ' xStr(dataDivider*k-1,:) ' ' timeValStr(dataDivider*k-1+(i-1)*nX,:) '  ' xStr(dataDivider*k,:) ' ' timeValStr(dataDivider*k+(i-1)*nX,:)]);
                    end
                end
                if xLeft
                    switch dataDivider
                        case 6
                            oddStr = ['  ' timeValStr(dataDivider*xNum + 1 + (i-1)*nX,:)];
                            for iLeft = 2:xLeft
                                oddStr = [oddStr ' ' timeValStr(dataDivider*xNum + iLeft + (i-1)*nX,:)]; %#ok<AGROW>
                            end
                        case 3
                            oddStr = ['  ' xStr(dataDivider*xNum + 1,:) ' ' timeValStr(dataDivider*xNum + 1 + (i-1)*nX,:)];
                            for iLeft = 2:xLeft
                                oddStr = [oddStr ' ' xStr(dataDivider*xNum + iLeft,:) ' ' timeValStr(dataDivider*xNum + iLeft + (i-1)*nX,:)]; %#ok<AGROW>
                            end
                    end
                    fprintf(fid,'%s\n',[oddStr spacer(:,ones(1,max(0,80-length(oddStr))))]);
                end
                fprintf(fid,'%s\n',line1);
            end
        else
            realStr  = num2str(real(Y(:)),format);
            imagStr  = num2str(imag(Y(:)),format);
            nodesStr = num2str(nodes);
            xStr     = num2str(X,format);
            iStr     = num2str((1:nNodes).');
            spNod    = spacer(:,ones(1,max(2,16-size(nodesStr,2))));
            line6sp  = spacer(:,ones(1,max(0,80-11-size(nodesStr,2)))); % separator
            line8sp  = spacer(:,ones(1,max(0,80-35-length(spNod)-size(nodesStr,2)-29))); % separator
            for i = 1:nNodes
                ita_verbose_info(['ITA_WRITEUNV58::writing ' nXStr ' frequency bins for node: ' nodesStr(i,:) ' (' iStr(i,:) ' of ' nNodesStr ')'],2);
                fprintf(fid,'%s\n',line1);
                fprintf(fid,'%s\n',line2);
                fprintf(fid,'%s\n',line3);
                fprintf(fid,'%s\n',line4);
                fprintf(fid,'%s\n',line5);
                fprintf(fid,'%s\n',['node ' nodesStr(i,:) line6sp]); % ID
                fprintf(fid,'%s\n',line7);
                fprintf(fid,'%s\n',['    1         0    1         0 NONE' spNod nodesStr(i,:) '   3 NONE               0   3' line8sp]);
                fprintf(fid,'%s\n',line9);
                fprintf(fid,'%s\n',line10);
                fprintf(fid,'%s\n',line11);
                fprintf(fid,'%s\n',line12);
                fprintf(fid,'%s\n',line13);
                for k = 1:xNum
                    fprintf(fid,'%s\n',['  ' xStr(2*k-1,:) ' ' realStr(2*k-1+(i-1)*nX,:) ' ' imagStr(2*k-1+(i-1)*nX,:) '  ' xStr(2*k,:) ' ' realStr(2*k+(i-1)*nX,:) ' ' imagStr(2*k+(i-1)*nX,:) '  ']);
                end
                if xLeft
                    oddStr = ['  ' xStr(end,:) ' ' realStr(i*nX,:) ' ' imagStr(i*nX,:)];
                    fprintf(fid,'%s\n',[oddStr spacer(:,ones(1,max(0,80-length(oddStr))))]);
                end
                fprintf(fid,'%s\n',line1);
            end
        end
    else
        for i = 1:nNodes
            if strcmpi(Data.domain,'time')
                ita_verbose_info(['ITA_WRITEUNV58::writing ' nXStr ' samples bins for node: ' num2str(nodes(i)) ' (' num2str(i) ' of ' nNodesStr ')'],2);
                fprintf(fid,'%s\n',line1);
                fprintf(fid,'%s\n',line2);
                fprintf(fid,'%s\n',line3);
                fprintf(fid,'%s\n',line4);
                fprintf(fid,'%s\n',line5);
                fprintf(fid,'%s\n',['node ' num2str(nodes(i)) spacer(:,ones(1,max(0,80-11-size(num2str(nodes(i)),2))))]); % ID
                fprintf(fid,'%s\n',line7);
                fprintf(fid,'%s\n',['    1         0    1         0 NONE' spacer(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))) num2str(nodes(i)) '   3 NONE               0   3' spacer(:,ones(1,max(0,80-35-length(spacer(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))))-size(num2str(nodes(i)),2)-29)))]);
                fprintf(fid,'%s\n',line9);
                fprintf(fid,'%s\n',line10);
                fprintf(fid,'%s\n',line11);
                fprintf(fid,'%s\n',line12);
                fprintf(fid,'%s\n',line13);
                for k = 1:xNum
                    switch dataDivider
                        case 6
                            fprintf(fid,'%s\n',['  ' num2str(Y(dataDivider*k-5+(i-1)*nX),format) ' ' num2str(Y(dataDivider*k-4+(i-1)*nX),format) ' ' num2str(Y(dataDivider*k-3+(i-1)*nX),format) ' ' num2str(Y(dataDivider*k-2+(i-1)*nX),format) ' ' num2str(Y(dataDivider*k-1+(i-1)*nX),format) ' ' num2str(Y(dataDivider*k+(i-1)*nX),format)]);
                        case 3
                            fprintf(fid,'%s\n',['  ' num2str(X,(dataDivider*k-2),format) ' ' num2str(Y(dataDivider*k-2+(i-1)*nX),format) '  ' num2str(X(dataDivider*k-1),format) ' ' num2str(Y(dataDivider*k-1+(i-1)*nX),format) '  ' num2str(X(dataDivider*k),format) ' ' num2str(Y(dataDivider*k+(i-1)*nX),format)]);
                    end
                end
                if xLeft
                    switch dataDivider
                        case 6
                            oddStr = ['  ' num2str(Y(dataDivider*xNum + 1 + (i-1)*nX),format)];
                            for iLeft = 2:xLeft
                                oddStr = [oddStr ' ' num2str(Y(dataDivider*xNum + iLeft + (i-1)*nX),format)]; %#ok<AGROW>
                            end
                        case 3
                            oddStr = ['  ' num2str(X(dataDivider*xNum + 1),format) ' ' num2str(Y(dataDivider*xNum + 1 + (i-1)*nX),format)];
                            for iLeft = 2:xLeft
                                oddStr = [oddStr ' ' num2str(X(dataDivider*xNum + iLeft),format) ' ' num2str(Y(dataDivider*xNum + iLeft + (i-1)*nX),format)]; %#ok<AGROW>
                            end
                    end
                    fprintf(fid,'%s\n',[oddStr spacer(:,ones(1,max(0,80-length(oddStr))))]);
                end
                fprintf(fid,'%s\n',line1);
            else
                ita_verbose_info(['ITA_WRITEUNV58::writing ' nXStr ' frequency bins for node: ' num2str(nodes(i)) ' (' num2str(i) ' of ' nNodesStr ')'],2);
                fprintf(fid,'%s\n',line1);
                fprintf(fid,'%s\n',line2);
                fprintf(fid,'%s\n',line3);
                fprintf(fid,'%s\n',line4);
                fprintf(fid,'%s\n',line5);
                fprintf(fid,'%s\n',['node ' num2str(nodes(i)) spacer(:,ones(1,max(0,80-11-size(num2str(nodes(i)),2))))]); % ID
                fprintf(fid,'%s\n',line7);
                fprintf(fid,'%s\n',['   12         0    1         0 NONE' spacer(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))) num2str(nodes(i)) '   3 NONE               0   3' spacer(:,ones(1,max(0,80-35-length(spacer(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))))-size(num2str(nodes(i)),2)-29)))]);
                fprintf(fid,'%s\n',line9);
                fprintf(fid,'%s\n',line10);
                fprintf(fid,'%s\n',line11);
                fprintf(fid,'%s\n',line12);
                fprintf(fid,'%s\n',line13);
                for k = 1:xNum
                    fprintf(fid,'%s\n',['  ' num2str(X(2*k-1),format) ' ' num2str(real(Y(2*k-1+(i-1)*nX)),format) ' ' num2str(imag(Y(2*k-1+(i-1)*nX)),format) '  ' num2str(X(2*k),format) ' ' num2str(real(Y(2*k+(i-1)*nX)),format) ' ' num2str(imag(Y(2*k+(i-1)*nX)),format) '  ']);
                end
                if xLeft
                    oddStr = ['  ' num2str(X(end),format) ' ' num2str(real(Y(i*nX)),format) ' ' num2str(imag(Y(i*nX)),format)];
                    fprintf(fid,'%s\n',[oddStr spacer(:,ones(1,max(0,80-length(oddStr))))]);
                end
                fprintf(fid,'%s\n',line1);
            end
        end
    end
    fclose(fid);
else
    error('ITA_WRITEUNV58::cannot create file');
end

%end function
end