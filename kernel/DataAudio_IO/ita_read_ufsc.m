function result = ita_read_ufsc(filename)
%ITA_READ_UFSC - Import data used in UFSC to save its beamforming
%                measurements.
%  Import raw data saved in both the National Instruments .dat file type as
%  also the UFSC "home made" .bin format.
%  This function directly converts the date into ITA representation.
%
%  Call: spk/dat = ita_read_usfc([filename])
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  18-Jan-2010

[fileID, message] = fopen(filename,'r','s');
if (fileID == -1)
    error(['Oh Lord. Could not open file, message: ', message]);    
end

% The National Instruments .dat format starts with a known name.
% First we check if the file is a NI file.

name = fgetl(fileID);

if strcmp(name,'[NI-MIC-ARRAY-START-UP-KIT]')
    % Is a NI file
    header = local_read_header(fileID);
    data = fread(fileID,'float');
    data = reshape(data,length(data)/header.NumOfChannels,header.NumOfChannels);
    result = itaAudio(data,header.SampleRate,'time');
    
    for idx = 1:result.nChannels
        result.channelUnits(idx) = {header.ChannelInfo{idx}.EU};
    end
    result.channelUserData = header.ChannelInfo;
else
    frewind(fileID)
    % If not, then we try to read the compact .bin format defined at UFSC
    SampleRate = fread(fileID,1,'double');
    nChannels = fread(fileID,1,'int');
    nSamples = fread(fileID,1,'int');
    nChannels2 = fread(fileID,1,'int');
    nSamples2 = fread(fileID,1,'int');
    
    if (nChannels == nChannels2) && (nSamples == nSamples2)
        data = fread(fileID,'float');
        if length(data) ~= nSamples*nChannels
            fclose(fileID);
            error('ITA_READ_UFSC','Ooops! The number of samples read does not match with the header information.');
        end
        
        data = reshape(data,nSamples,nChannels);
        result = itaAudio(data,SampleRate,'time');
    else
        fclose(fileID);
        error('ITA_READ_UFSC','Ooops! This file does not seem to be a UFSC .bin file.');
    end    
end

fclose(fileID);

function header = local_read_header(fileID)

header.version = local_get_char(fileID);
header.headerSize = local_get_double(fileID);
header.type = local_get_char(fileID);

%[DAQ Info]  
junk = fgetl(fileID);
header.NumOfTasks = local_get_double(fileID);    
header.SamplesPerChannel = local_get_double(fileID);
header.SampleRate = local_get_double(fileID);
header.SensorTypes = local_get_char(fileID);
header.SensorNums = local_get_double(fileID);
header.Comment = local_get_char(fileID);

%[Task Info<0>]  
junk = fgetl(fileID);
header.NumOfChannels = local_get_double(fileID);               
header.BlockSizeInBytes = local_get_double(fileID);         
header.All446x = local_get_char(fileID);                 
header.RawSampleResolution = local_get_double(fileID);          
header.RawSampleSizeInBits = local_get_double(fileID);          
header.RawSampleJustification = local_get_char(fileID);   
header.SignedNumber = local_get_char(fileID);              
header.CompressionByteOrder = local_get_char(fileID);

%[Task Info<0>Channel Info<0>]  
for idx = 1:header.NumOfChannels
    junk = fgetl(fileID);
    ChannelInfo{idx}.SensorIndex = local_get_double(fileID);
    ChannelInfo{idx}.Sensitivity = local_get_double(fileID);
    ChannelInfo{idx}.EU = local_get_char(fileID);
    ChannelInfo{idx}.PolynomialScalingCoeffs = local_get_double(fileID);
end
header.ChannelInfo = ChannelInfo;

%[BinaryData]
junk = fgetl(fileID);

%Begin=Here  
junk = fgetl(fileID);

function out = local_get_char(fileID)
out = fgetl(fileID);
out = out(find(out == '=')+1:end);
semicollon = find(out == ';');
if semicollon
    semicollon = [0 semicollon];
    for idx = 1:length(semicollon)-1
        aux{idx} = out(semicollon(idx)+1:semicollon(idx+1)-1);
    end
    out = aux;
    clear aux
end

function out = local_get_double(fileID)
out = local_get_char(fileID);

if ~iscell(out)
    out = {out};
end
for idx = 1:length(out)
    local = out{idx};
    local(local == ',') = '.';
    d_out = double(local);
    d_out = local(d_out > 47 & d_out < 58 | d_out == 46);
    aux(idx) = str2double(d_out);
end
out = aux;


