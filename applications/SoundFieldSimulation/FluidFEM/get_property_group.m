function [material] =get_property_group(fileName)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% get boundary condition from propertyfile
errN = 0;

% data from propertyfile
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
    % Close file
    fclose(fid);
    return
end
% Close file
err = fclose(fid);
if err == -1
    errN = errN + 1;
    errmsg{errN,1} = 'error while closing file';
    disp(errmsg{errN});
end
ind = strfind(FILE_DATA, '    -1');
if length(ind)~=2
    errN = errN + 1;
    errmsg{errN,1} = 'error reading file';
    disp(errmsg{errN});
end
DATA = FILE_DATA(ind(1)+6:ind(2));
lineBreaks = DATA==sprintf('\n') | DATA==sprintf('\r');
lineBreaksInd = find(lineBreaks);
l_lineBreaksInd=length(lineBreaksInd);
blocklines=zeros(l_lineBreaksInd/2-1,2);
for k=1:l_lineBreaksInd/2-1
    blocklines(k,:)=lineBreaksInd(2*k:2*k+1);
end


% Initialise matrices containing field types
try
    for k=1:4:length(blocklines(:,1))
        values = sscanf(DATA(blocklines(k,1):blocklines(k,2)),'%g');
        properties.ID    = round(values(1));

        names = sscanf(DATA(blocklines(k+1,1)+1:blocklines(k+1,2)-1),'%c');
        properties.GroupName=names;
        names =  sscanf(DATA(blocklines(k+2,1)+1:blocklines(k+2,2)-1),'%c');
        properties.Type = names;
        properties.Value =  values(2)+1j*values(3);
        properties.freq = 0;
        names =  sscanf(DATA(blocklines(k+3,1)+1:blocklines(k+3,2)-1),'%c');
        properties.GroupFilename = names;
        if ~strcmp(names,'none') && ~strcmp(names,'Acceleration')
            Data = get_freq_property(names);
            properties.Type = Data.Type;
            properties.Value = Data.Value;
            properties.freq = Data.freq;
        elseif ~strcmp(names,'none') && strcmp(names,'Acceleration')
            Data = get_freq_excitation(names);
            properties.Type = Data.Type;
            properties.Value = Data.Value;
            properties.freq = Data.freq;
        end
        material{(k-1)/4+1}=itaMeshBoundaryC(properties); %#ok<*AGROW>
    end

catch %#ok<*CTCH>
    error('error reading trace-line data');
end


function [Data, comment] = get_freq_excitation(varargin)
% The function reads the frequency dependend data sheets of the acceleration
% from a *txt file. The function gets the name of the file and returns the 
% data from the data sheet.

% Initialization
% --------------------------------------------------------------------------
% Number of input arguments
narginchk(1,1);
Find Data
if ischar(varargin{1})
    fileName = varargin{1};
else
    error('get_freq_excitation::Something is wrong with the filename.')
end

errN = 0;
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
    errmsg{errN,1} = ['get_freq_excitation::error reading file contents: '...
        lasterr]; 
    disp(errmsg{errN});
    % Close the file
    fclose(fid);
    return
end

% Body
posHash     = findstr('#',FILE_DATA);
if isempty(posHash)
    posHash = findstr('%',FILE_DATA); % different formats
end
Values      = sscanf(FILE_DATA(posHash(2)+1:end),'%g');

comment.character.freqDep = Values(1);
comment.character.CompReal= Values(2);
comment.character.NumPara = Values(3);
Data.freq =Values(4:2:end);
Data.Value=Values(5:2:end);