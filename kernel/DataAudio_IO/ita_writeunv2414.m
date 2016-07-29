function ita_writeunv2414(varargin)
%ITA_WRITEUNV2414 - write data for a mesh per frequency as a unv2414 dataset
%  This function takes a struct of measurement data as input and writes the
%  data for the complete mesh for each frequency into the specified file.
%
%  The data struct has to have the fields
%       - UserData: vector of node IDs
%       - fcentre: vector of frequencies
%       - data: complex matrix, size(data) = [numel(freq) numel(nodes)]
%
%  An optional argument 'action', value 'add' or 'replace', controls whether
%  the data is appended to a file (if it already exists).
%  By default, the file contents are replaced.
%
%  Call: ita_writeunv2414(Data,unvFilename)
%  Call: ita_unvwrite2414(Data,unvFilename,'action','add')
%
%  The function can be used to convert from unv58 dataset to unv2414 dataset:
%
%  Call: Data = ita_readunv58(unv58file);
%         ita_writeunv2414(Data,unv2414file);
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_writeunv2414">doc ita_writeunv2414</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 23-Nov-2008

%% Initialization
% Number of Input Arguments
narginchk(2,4);
sArgs        = struct('pos1_data','itaSuper','pos2_unvFilename','string','action','replace');
[Data,unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Body
ita_verbose_info('ita_writeunv2414::preparing ...',1);
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
freq = Data.freqVector(:);
writeMode = 'regular';
% for velocity there are three degrees of freedom
if strcmpi(Data.channelUnits{1},'m/s') && numel(Data.dimensions) > 1
    data = Data.freq;
    switch Data.dimensions(2)
        case 2
            writeMode = 'xy';
        case 3
            writeMode = 'xyz';
    end
    nodes = nodes(1:Data.dimensions(1));
else
    data = Data.freqData.';
end


% Number format definition
zeroString = '0.0000E+000';
format      = '%1.4E';

% Model type (1=Structural), Analysis type (5=Frequency response), Data
% characteristic (1=scalar, 2=3 DOF translation), Result type (11=Velocity, ...
% 117=Pressure,94=unknown scalar), Data type (5=Single complex),
% Number of data values (for 3 DOF = 3)
switch Data.channelUnits{1}
    case 'Pa'
        settingsStr = '         1         5         1       117         5         1';
    case 'm/s'
        settingsStr = '         1         5         2        11         5         3';
    otherwise
        settingsStr = '         1         5         1        94         5         1';
end


nNodes      = numel(nodes);
nNodesStr   = num2str(nNodes);
nFreqs      = numel(freq);
nFreqsStr   = num2str(nFreqs);
realVals    = real(data);
imagVals    = imag(data);
if strcmpi(writeMode,'regular')
    realVals    = realVals(:);
    imagVals    = imagVals(:);
end
sp          = ' ';

if strcmp(sArgs.action,'add')
    fid = fopen(unvFilename,'at');
else
    fid = fopen(unvFilename,'wt');
end
% based on free memory use the fast version or the one that has less memory usage
if fid ~= -1
    if numel(data) < 1024*1024 && strcmpi(writeMode,'regular')
        realStr     = num2str(realVals,format);
        imagStr     = num2str(imagVals,format);
        nodesStr    = num2str(nodes);
        freqStr     = num2str(freq,format);
        iStr        = num2str((1:nFreqs).');
        idxStr      = num2str((0:nFreqs-1).');
        spIdx       = sp(:,ones(1,max(1,10 - size(idxStr,2))));
        spNod       = sp(:,ones(1,max(1,10 - size(nodesStr,2))));
        
        for i=1:nFreqs
            ita_verbose_info(['write_unv2414::writing ' nNodesStr ' nodes at frequency: ' freqStr(i,:) ' Hz (' iStr(i,:) ' of ' nFreqsStr ')'],1);
            fprintf(fid,'%s\n','    -1'); % delimiter
            fprintf(fid,'%s\n','  2414'); % dataset
            fprintf(fid,'%s\n',['       ' iStr(i,:)]); % frequency bin
            fprintf(fid,'%s\n','ITA-Toolbox DATA'); % analysis dataset name
            fprintf(fid,'%s\n','         1'); % dataset location, 1 = Data at nodes
            fprintf(fid,'%s\n','ita_writeunv2414'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n',settingsStr);
            fprintf(fid,'%s\n',['         0         0         0         0         0         0         0' spIdx idxStr(i,:)]);
            fprintf(fid,'%s\n','         0         0');
            fprintf(fid,'%s\n',['  ' zeroString '  ' freqStr(i,:) '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
            fprintf(fid,'%s\n',['  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
            for k=1:nNodes
                fprintf(fid,'%s\n',[spNod nodesStr(k,:)]);
                fprintf(fid,'%s\n',['  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString [' ' realStr(k+(i-1)*nNodes,:)] [' ' imagStr(k+(i-1)*nNodes,:)]]);
            end
            fprintf(fid,'%s\n','    -1');
        end
    else
        for i=1:nFreqs
            ita_verbose_info(['write_unv2414::writing ' nNodesStr ' nodes at frequency: ' num2str(freq(i),format) ' Hz (' num2str(i) ' of ' nFreqsStr ')'],1);
            fprintf(fid,'%s\n','    -1'); % delimiter
            fprintf(fid,'%s\n','  2414'); % dataset
            fprintf(fid,'%s\n',['       ' num2str(i)]); % frequency bin
            fprintf(fid,'%s\n','VELOCITY DATA'); % analysis dataset name
            fprintf(fid,'%s\n','         1'); % dataset location, 1 = Data at nodes
            fprintf(fid,'%s\n','ita_writeunv2414'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n','NONE'); % ID
            fprintf(fid,'%s\n',settingsStr);
            fprintf(fid,'%s\n',['         0         0         0         0         0         0         0' sp(:,ones(1,max(1,10 - size(num2str(i),2)))) num2str(i)]);
            fprintf(fid,'%s\n','         0         0');
            fprintf(fid,'%s\n',['  ' zeroString '  ' Edigit3(num2str(freq(i),format)) '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
            fprintf(fid,'%s\n',['  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
            for k=1:numel(nodes)
                fprintf(fid,'%s\n',[sp(:,ones(1,max(1,10 - size(num2str(nodes(k)),2)))) num2str(nodes(k))]);
                switch lower(writeMode)
                    case 'regular'
                        fprintf(fid,'%s\n',['  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString [repmat(' ',1,min(sign(realVals(k+(i-1)*nNodes))+1,1)+1) num2str(realVals(k+(i-1)*nNodes),format)] [repmat(' ',1,min(sign(imagVals(k+(i-1)*nNodes))+1,1)+1) num2str(imagVals(k+(i-1)*nNodes),format)]]);
                    case 'xy'
                        fprintf(fid,'%s\n',[[repmat(' ',1,min(sign(realVals(i,k,1))+1,1)+1) Edigit3(num2str(squeeze(realVals(i,k,1)),format))] [repmat(' ',1,min(sign(imagVals(i,k,1))+1,1)+1) Edigit3(num2str(squeeze(imagVals(i,k,1)),format))] [repmat(' ',1,min(sign(realVals(i,k,2))+1,1)+1) Edigit3(num2str(squeeze(realVals(i,k,2)),format))] [repmat(' ',1,min(sign(imagVals(i,k,2))+1,1)+1) Edigit3(num2str(squeeze(imagVals(i,k,2)),format))] '  ' zeroString '  ' zeroString]);
                    case 'xyz'
                        fprintf(fid,'%s\n',[[repmat(' ',1,min(sign(realVals(i,k,1))+1,1)+1) Edigit3(num2str(squeeze(realVals(i,k,1)),format))] [repmat(' ',1,min(sign(imagVals(i,k,1))+1,1)+1) Edigit3(num2str(squeeze(imagVals(i,k,1)),format))] [repmat(' ',1,min(sign(realVals(i,k,2))+1,1)+1) Edigit3(num2str(squeeze(realVals(i,k,2)),format))] [repmat(' ',1,min(sign(imagVals(i,k,2))+1,1)+1) Edigit3(num2str(squeeze(imagVals(i,k,2)),format))] [repmat(' ',1,min(sign(realVals(i,k,3))+1,1)+1) Edigit3(num2str(squeeze(realVals(i,k,3)),format))] [repmat(' ',1,min(sign(imagVals(i,k,3))+1,1)+1) Edigit3(num2str(squeeze(imagVals(i,k,3)),format))]]);
                end
            end
            fprintf(fid,'%s\n','    -1');
        end
    end
    fclose(fid);
else
    error('ita_unvwrite2414::cannot create file');
end

% Replace the number of exponent digits from 2 to 3 ##ROP
    function [strout] = Edigit3(strin)
        strout = strrep(strrep(strin,'E+','E+0'),'E-','E-0');
    end

%end function
end