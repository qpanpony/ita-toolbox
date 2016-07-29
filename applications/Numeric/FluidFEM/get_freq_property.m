function [Data, comment] = get_freq_property(varargin)
% The function reads the frequency dependent data sheets of the Impedance/
% Adminttance/ Reflection/ Absorption from a *txt or *.ita file. The function gets
% the name of the file and returns the data from the data sheet. 

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
%--------------------------------------------------------------------------
% Number of Input Arguments
narginchk(1,1);
% Find Data
if ischar(varargin{1})
    fileName = varargin{1};
else
    error('get_freq_property::Something is wrong with the filename.')
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
    errmsg{errN,1} = ['error reading file contents: ' lasterr];
    disp(errmsg{errN});
    % Close the file
    fclose(fid);
    return
end

%% Body

posComment  = findstr('Comments',FILE_DATA);
posDate     = findstr('Datum',FILE_DATA);
posComponent= findstr('KOMPONENTEN',FILE_DATA);
posFormat   = findstr('FORMAT',FILE_DATA);
posData     = findstr('Data',FILE_DATA);
posHash     = findstr('#',FILE_DATA);
if isempty(posHash)
    posHash = findstr('%',FILE_DATA); % different formats
end
if ~isempty(posHash) &&  isempty(findstr('.ita',fileName))
    Values      = sscanf(FILE_DATA(posHash(2)+1:posComment-6),'%d');
    Date        = sscanf(FILE_DATA(posDate+7:posComponent-4),'%c');
    Component   = sscanf(FILE_DATA(posComponent+16:posFormat-6),'%c');
    posColon    = findstr(':', Component);
    Format      = sscanf(FILE_DATA(posFormat+10:posData-4),'%c');

    comment.character.freqDep = Values(1);
    comment.character.CompReal= Values(2);
    comment.character.NumPara = Values(3);
    comment.Date      = Date(1:20);
    comment.Extra     = Date(22:end);
    if posColon ==6
        comment.Component.Name        = Component(posColon(1)+1:posColon(2)-9);
        comment.Component.Material    = Component(posColon(2)+1:posColon(3)-8);
        comment.Component.Dicke       = Component(posColon(3)+1:posColon(4)-10);
        comment.Component.Poroesitaet = Component(posColon(4)+1:posColon(5)-12);
        comment.Component.Raumgewicht = Component(posColon(5)+1:posColon(6)-14);
        comment.Component.Stroemung   = Component(posColon(6)+1:end-7);
    end

    if Values(1)==1 &&strcmp(Format(15:19),'alpha')
        Data_temp = sscanf(FILE_DATA(posData+10:end),'%g');
        Data.Type = 'Absorption';
        Data.freq =Data_temp(1:2:end);
        Data.Value=Data_temp(2:2:end);

    elseif Values(1)==1&&strcmp(Format(15:21),'real(Z)')&&strcmp(Format(28:34),'imag(Z)')
        Data_temp = sscanf(FILE_DATA(posData+10:end),'%g');
        Data.Type = 'Impedance';
        Data.freq =Data_temp(1:3:end);
        Data.Value=Data_temp(2:3:end)+1j*Data_temp(3:3:end);
    elseif Values(1)==1&&strcmp(Format(15:21),'real(Y)')&&strcmp(Format(28:34),'imag(Y)')
        Data_temp = sscanf(FILE_DATA(posData+10:end),'%g');
        Data.Type = 'Admittance';
        Data.freq =Data_temp(1:3:end);
        Data.Value=Data_temp(2:3:end)+1j*Data_temp(3:3:end);
    elseif Values(1)==1&&strcmp(Format(15:21),'real(R)')&&strcmp(Format(28:34),'imag(R)')
        Data_temp = sscanf(FILE_DATA(posData+10:end),'%g');
        Data.Type = 'Reflection';
        Data.freq =Data_temp(1:3:end);
        Data.Value=Data_temp(2:3:end)+1j*Data_temp(3:3:end);
    else
        errN = errN + 1;
        errmsg{errN,1} = ['error reading file data: ' lasterr];
        disp(errmsg{errN});
    end
elseif strfind(fileName,'.ita') 
    obj = ita_read(fileName);
    if isa(obj,'itaAudio') ||  isa(obj,'itaResult')
        channelPos =  strcmp(obj.channelNames,'Admittance');
        if isempty(channelPos)
            error('Please export an *.ita file with admittance!')
        end
        Data.freq = obj.freqVector;
        Data.Value = obj.freqData;
        Data.Type = 'Admittance';
        comment = [];
    end
else
    try
        posFormat= strfind('FORMAT',FILE_DATA);
        posDaten = strfind('DATEN',FILE_DATA);
        comment =  sscanf(FILE_DATA(1:posFormat-1),'%c');
        TypeTmp = sscanf(FILE_DATA(posFormat+8:posDaten-1),'%c');
        Values   = sscanf(FILE_DATA(posDaten+8:end),'%g');
        if strfind(TypeTmp, 'alpha')
            Data.Type = 'Absorption';
            Data.freq = Values(1:2:end);
            Data.Value= Values(2:2:end);
        elseif strfind(TypeTmp, 'real(R)')
            Data.Type = 'Reflection';
            Data.freq = Values(1:3:end);
            Data.Value= Values(2:3:end)+1j*Values(3:3:end);
        elseif strfind(TypeTmp, 'real(Y)')
            Data.Type = 'Admittance';
            Data.freq = Values(1:3:end);
             Data.Value= Values(2:3:end)+1j*Values(3:3:end);
        elseif strfind(TypeTmp, 'real(Z)')
            Data.Type = 'Impedance';
            Data.freq = Values(1:3:end);
            Data.Value= Values(2:3:end)+1j*Values(3:3:end);
        else error('get_freq_property:: File is not readable!')
        end
 
    catch
        error('get_freq_property:: File is not readable!')
    end
end
