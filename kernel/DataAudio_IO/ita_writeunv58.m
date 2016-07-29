function ita_writeunv58(varargin)
%ITA_WRITEUNV58 - write data as frequency response per mesh node as a unv58 dataset
%  This function takes a struct of measurement data as input and writes the
%  frequency response for each node of a mesh into the specified file.
%  
%  The data struct has to have the fields
%       - header.UserData : contains a vector of node IDs
%       - header.fcentre: vector of frequencies
%       - data: complex matrix, size(data) = [numel(freq) numel(nodes)]
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

%% Body  
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
freq = Data.freqVector;
data = Data.freqData.';
sortedArray = zeros(size(data));
for i=1:numel(freq)
    temp = cat(2,squeeze(data(:,i)),nodes(:));
    temp = sortrows(temp,2);
    sortedArray(:,i) = temp(:,1);
end
nodes=temp(:,2);

if ispc
    zeroString = '0.0000e+000';
    format      = '%1.4e';
else
    zeroString = '0.00000e+00';
    format      = '%1.5e';
end

dateStr = ['Date (DD/MM/YYYY)      ' datestr(now,24)];
isFreqOdd  = mod(numel(freq),2);
freqNum    = floor(numel(freq)/2);
nNodes     = numel(nodes);
nNodesStr = num2str(nNodes);
nFreqs      = numel(freq);
nFreqsStr  = num2str(nFreqs);
realVals    = real(sortedArray).';
realVals    = realVals(:);
imagVals   = imag(sortedArray).';
imagVals   = imagVals(:);
sp            = ' ';
spFreqBins = sp(:,ones(1,max(2,10-size(nFreqsStr,2))));

% this is really stupid but necessary
line1 = ['    -1' sp(:,ones(1,80-6))]; % delimiter
line2 = ['    58' sp(:,ones(1,80-4))]; % dataset
line3 = ['ita_writeunv58' sp(:,ones(1,80-11))]; % ID
line4 = ['NONE' sp(:,ones(1,80-4))]; % ID
line5 = [dateStr sp(:,ones(1,80-33))]; % date
line7 = ['Trust no one.' sp(:,ones(1,80-13))]; % ID
line9str = ['         5' spFreqBins nFreqsStr '         0  ' zeroString '  ' zeroString '  ' zeroString];
line9 = [line9str sp(:,ones(1,max(0,80-length(line9str))))];
line10 = ['        18    0    0    0 NONE                 Hz' sp(:,ones(1,80-49))];
line11 = ['        11    0    0    0 NONE                 ' Data.channelUnits{1} sp(:,ones(1,80-50))];
line12 = ['         0    0    0    0 NONE                 NONE' sp(:,ones(1,80-51))];
line13 = ['         0    0    0    0 NONE                 NONE' sp(:,ones(1,80-51))];

if strcmp(sArgs.action,'add')
    fid = fopen(unvFilename,'at');
else
    fid = fopen(unvFilename,'wt');
end
% based on free memory use the fast version or the one that has less memory usage
if fid ~= -1
    if numel(sortedArray) < 0.5*1024*1024
        realStr     = num2str(realVals,format);
        imagStr    = num2str(imagVals,format);
        nodesStr  = num2str(nodes);
        freqStr     = num2str(freq,format);
        iStr          = num2str((1:nNodes).');
        spNod      = sp(:,ones(1,max(2,16-size(nodesStr,2))));
        line6sp = sp(:,ones(1,max(0,80-11-size(nodesStr,2)))); % separator
        line8sp = sp(:,ones(1,max(0,80-35-length(spNod)-size(nodesStr,2)-29))); % separator
        for i = 1:nNodes
            ita_verbose_info(['ITA_WRITEUNV58::writing ' nFreqsStr ' frequency bins for node: ' nodesStr(i,:) ' (' iStr(i,:) ' of ' nNodesStr ')'],2);
            fprintf(fid,'%s\n',line1);
            fprintf(fid,'%s\n',line2);
            fprintf(fid,'%s\n',line3);
            fprintf(fid,'%s\n',line4);
            fprintf(fid,'%s\n',line5);
            fprintf(fid,'%s\n',['node ' nodesStr(i,:) line6sp]); % ID
            fprintf(fid,'%s\n',line7);
            fprintf(fid,'%s\n',['   12         0   19         0 NONE' spNod nodesStr(i,:) '   3 NONE               0   3' line8sp]);
            fprintf(fid,'%s\n',line9);
            fprintf(fid,'%s\n',line10);
            fprintf(fid,'%s\n',line11);
            fprintf(fid,'%s\n',line12);
            fprintf(fid,'%s\n',line13);
            for k=1:freqNum
                fprintf(fid,'%s\n',['  ' freqStr(2*k-1,:) ' ' realStr(2*k-1+(i-1)*nFreqs,:) ' ' imagStr(2*k-1+(i-1)*nFreqs,:) '  ' freqStr(2*k,:) ' ' realStr(2*k+(i-1)*nFreqs,:) ' ' imagStr(2*k+(i-1)*nFreqs,:) '  ']);
            end
            if isFreqOdd
                oddStr = ['  ' freqStr(end,:) ' ' realStr(i*nFreqs,:) ' ' imagStr(i*nFreqs,:)];
                fprintf(fid,'%s\n',[oddStr sp(:,ones(1,max(0,80-length(oddStr))))]);
            end
            fprintf(fid,'%s\n',line1);
        end
    else
        for i = 1:nNodes
            ita_verbose_info(['ITA_WRITEUNV58::writing ' nFreqsStr ' frequency bins for node: ' num2str(nodes(i)) ' (' num2str(i) ' of ' nNodesStr ')'],2);
            fprintf(fid,'%s\n',line1);
            fprintf(fid,'%s\n',line2);
            fprintf(fid,'%s\n',line3);
            fprintf(fid,'%s\n',line4);
            fprintf(fid,'%s\n',line5);
            fprintf(fid,'%s\n',['node ' num2str(nodes(i)) sp(:,ones(1,max(0,80-11-size(num2str(nodes(i)),2))))]); % ID
            fprintf(fid,'%s\n',line7);
            fprintf(fid,'%s\n',['   12         0   19         0 NONE' sp(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))) num2str(nodes(i)) '   3 NONE               0   3' sp(:,ones(1,max(0,80-35-length(sp(:,ones(1,max(2,16-size(num2str(nodes(i)),2)))))-size(num2str(nodes(i)),2)-29)))]);
            fprintf(fid,'%s\n',line9);
            fprintf(fid,'%s\n',line10);
            fprintf(fid,'%s\n',line11);
            fprintf(fid,'%s\n',line12);
            fprintf(fid,'%s\n',line13);
            for k=1:freqNum
                fprintf(fid,'%s\n',['  ' num2str(freq(2*k-1),format) ' ' num2str(realVals(2*k-1+(i-1)*nFreqs),format) ' ' num2str(imagVals(2*k-1+(i-1)*nFreqs),format) '  ' num2str(freq(2*k),format) ' ' num2str(realVals(2*k+(i-1)*nFreqs),format) ' ' num2str(imagVals(2*k+(i-1)*nFreqs),format) '  ']);
            end
            if isFreqOdd
                oddStr = ['  ' num2str(freq(end),format) ' ' num2str(realVals(i*nFreqs),format) ' ' num2str(imagVals(i*nFreqs),format)];
                fprintf(fid,'%s\n',[oddStr sp(:,ones(1,max(0,80-length(oddStr))))]);
            end
            fprintf(fid,'%s\n',line1);
        end
    end
    fclose(fid);
else
    error('ITA_WRITEUNV58::cannot create file');
end

%end function
end