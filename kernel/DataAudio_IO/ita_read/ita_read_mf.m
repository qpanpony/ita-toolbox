function result = ita_read_mf(filename,varargin)
%% Help

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if nargin == 0
    result{1}.extension = '.dat';
    result{1}.comment = 'MF Time Signals (*.dat)';
    result{2}.extension = '.DAT';
    result{2}.comment = 'MF Time Signals (*.DAT)';
    result{3}.extension = '.spk';
    result{3}.comment = 'MF Spectra (*.spk)';
    result{4}.extension = '.SPK';
    result{4}.comment = 'MF Spectra (*.SPK)';
    return
else
    % initialize standard values
    sArgs = struct('interval','vector',...
                   'isTime',false,...
                   'channels','vector',...
                   'metadata',false);
    sArgs = ita_parse_arguments(sArgs,varargin); 
    
end

%% Parse remaining input parameters
[junk, MFname, fileExt] = fileparts(filename);

[fileID, message] = fopen(filename,'r','l');
if (fileID == -1)
    error(['Oh Lord. Could not open file, message: ', message]);    
end

%% Read MF header
header = read_header(fileID);


%% Determine used sample size
fseek(fileID,0,'eof');  % Jump to end of file
header.SampleSize = ... % Calculate Bytes per Sample
    (ftell(fileID)-256)/header.Samples/header.nChannels;
fseek(fileID,256,'bof');  % Jump after file header

%% Read data
if ~sArgs.metadata
    result = itaAudio(1);
    switch lower(fileExt)
        case '.dat'
            if exist('interval','var')
                warning('TO DO: implement to read a part of a .dat file (reading all the data now)'); %#ok<WNTAG>
            end
            [data, header] = read_dat(fileID, header, sArgs);
            result.time   = data.';
            result.domain = 'time';
        case '.spk'
            [data, header] = read_spk(fileID, header, sArgs);
            result.freq   = data;
            result.domain = 'freq';
        otherwise
            fclose(fileID); %pdi added - the file is open at this point, close first!
            error(['No SPK, no DAT, what the heck is it...? (' message ')']);
    end
else
    result = itaAudioDevNull(1);
    switch lower(fileExt)
        case '.dat'
            result.domain = 'time';
            result.time   = zeros(header.nSamples,header.nChannels);
        case '.spk'
            result.domain = 'freq';            
            result.time   = zeros(header.nSamples,header.nChannels);
        otherwise
            fclose(fileID); %pdi added - the file is open at this point, close first!
            error(['No SPK, no DAT, what the heck is it...? (' message ')']);
    end
end
fclose(fileID); %close the file, and everything is fine!

% Parse hidden channel information in comment line
% header = ita_comment2names(header); % get name information
% TODO: correct behaviour with interval

% set output
result.samplingRate = header.samplingRate;
result.signalType   = header.signalType;
result.dateCreated  = header.dateVector;
result.comment      = header.comment;
% result.channelNames = header.channelNames;
% result.channelUnits = header.channelUnits;
result.fileName     = filename;

%% Set coordinates for polar data 
 % if name is a V...H... file
if strcmp(MFname(1),'V') && strcmp(MFname(5),'H')
    V = str2double(MFname(2:4)); % theta in itaCoordinates
    H = str2double(MFname(6:8)); % phi in itaCoordinates
    % now bring it to spherical coordinates ((0,0) at northpole)
    if V > 180; V = 360 - V; end; % V: min=0deg, max=180deg     H: min=0deg, max=360deg
    result.channelCoordinates.sph = repmat([1, pi/180 * V, pi/180 * H], result.nChannels ,1);
end
end
%EOF

function [header] = read_header(fileID)
    %% Read MF Header
    %unimportant data is written to header.

    header.Samples        = fread (fileID,1,'long');   % can be nSamples or nBins:
    header.samplingRate    = fread (fileID,1,'double');
    header.ADoffset        = fread (fileID,1,'ushort'); % will be compensated in the data and the struct entry will be deleted later
    header.nChannels       = fread (fileID,1,'schar');

    header.KanalNr         = fread (fileID,1,'schar');
    header.alleBearb       = fread (fileID,1,'char');
    header.Preemph         = fread (fileID,1,'char');
    header.LiCursAct       = fread (fileID,1,'char');
    header.CursCross       = fread (fileID,1,'char');
    header.CursLock        = fread (fileID,1,'char');
    header.DrawMode        = fread (fileID,1,'char');
    header.ODrawMode       = fread (fileID,1,'char');
    header.Wei             = fread (fileID,1,'char');
    header.nur0            = fread (fileID,1,'char');
    header.NormMax0dB      = fread (fileID,1,'char');
    header.Yzoom           = fread (fileID,1,'char');
    header.Xlog            = fread (fileID,1,'char');
    header.Ylog            = fread (fileID,1,'char');
    header.VerNr           = fread (fileID,1,'char');

    FFTnorm           = fread (fileID,1,'char');
    switch (FFTnorm)
        case {0}
            header.signalType = 'power';
        case {1}
            header.signalType = 'energy';
        case {2}
            header.signalType = 'bandpass';
    end

    header.VoltageRange = fread (fileID,1,'double');

    header.Reserviert        = fread (fileID,52,'schar');

    Hun                 = fread (fileID,1,'schar');
    Sec                 = fread (fileID,1,'schar');
    Min                 = fread (fileID,1,'schar');
    Hour                = fread (fileID,1,'schar');
    Day                 = fread (fileID,1,'schar');
    Month               = fread (fileID,1,'schar');
    Year                = fread (fileID,1,'ushort');

    header.dateVector   = [Year Month Day Hour Min Sec Hun];

    header.Start        = fread (fileID,1,'long');
    header.xAxUnit      = fread_string(fileID,3);
    header.yAxUnit      = fread_string(fileID,3);
    header.Rand         = fread (fileID,2,'long');
    header.Cursor       = fread (fileID,2,'long');
    header.MainDelay    = fread (fileID,1,'double');

    header.OnTopdB      = fread (fileID,1,'double');
    header.Dyn          = fread (fileID,1,'double');
    header.Volt0dB      = fread (fileID,1,'double');

    header.LcursOld     = fread (fileID,1,'ushort');
    header.RcursOld     = fread (fileID,1,'ushort');
    header.ADDAident    = fread_string(fileID,20);
    % header.Bits         = str2num(header.ADDAident(1:2)); %#ok<ST2NM>
    header.comment      = fread_string(fileID,71);

    %Check for wrong channel setting
    if header.nChannels == 0
        header.nChannels = 1;
    end

end % end read_header


function [StringText] = fread_string(fileID, StringLength)
    %% function to read longer parts of header
    StrLen = fread(fileID,1,'char');
    if StrLen == 0
        StringText = '';
    else
        StringText = fgets(fileID,StringLength);
    end
end %end fread_string


function [data, header] = read_dat(fileID, header, sArgs)
    %% Read time data
    % set number of samples and number of bins to right values
    header.domain = 'time';
    data = zeros(header.nChannels,header.Samples);
    % Read time signal
    switch header.SampleSize
        case 1                                 % 1 Byte per Sample
            buff= fread (fileID,header.nChannels*header.Samples,'schar');
            header.nBits = 8;
        case 2                                 % 2 Bytes per Sample
            buff= fread (fileID,header.nChannels*header.Samples,'short');
            header.nBits = 16;
        case 3                                 % 3 Bytes per Sample
            %         buff = fread (fileID,data.nChannels*data.nSamples*3,'schar');
            %         buff = buff (1:3:data.nChannels*data.nSamples*3)+...
            %             buff (2:3:data.nChannels*data.nSamples*3)*256+...
            %             buff (3:3:data.nChannels*data.nSamples*3)*65536;
            buff = fread (fileID,header.nChannels*header.Samples*3,'bit24'); %pdi: new solution
            header.nBits = 24;
        case 4                                 % 4 Bytes per Sample
            buff= fread (fileID,header.nChannels*header.Samples,'int32'); %pdi: was long before
            header.nBits = 32;
        otherwise
            fclose(fileID); %always close file first
            error(['Oh Lord. Header is wrong! Samplesize is: ' num2str(SampleSize)]);
    end;

    for k = 1:header.nChannels,
        data(k,:) = buff(k:header.nChannels:header.Samples*header.nChannels)';
    end;

    data = data - header.ADoffset;
    if header.nBits
        data = data / 2^(header.nBits-1) * header.VoltageRange;
    else % if 'Quantization' is empty, calculate with Bytes/Sample
        data = data / 2^(header.SampleSize*8-1) * header.VoltageRange; %(Maltes Version)
        %         disp('Oh Lord. Header: ''Quantization'' has not been set => Calculate by Bytes/Sample.');
    end

end %end  read_dat


function [data, header] = read_spk(fileID, header,sArgs)
    %% Read frequency data
    % Read Spectrum - read all Re-Im-data and merge to complex values
    header.domain = 'freq';


    switch header.SampleSize
        case 8 %in MF SampleSize of 4
            readbyte = 'float32';
            header.nBits = 32;
        case 16 %in MF SampleSize of 8
            readbyte = 'float64'; %pdi: was single
            header.nBits = 64;
        otherwise
            fclose(fileID); %always close file before exiting with error
            error(['Oh Lord. MF File Header wrong! Samplesize is: ' num2str(header.SampleSize)]);
    end

    % number of data points
    nr_points = 2 .* header.nChannels .* header.Samples;

    % read SPK file, data structure: [Re{ch1} Im{ch1} Re{ch2} ... Im{chn}]
    filedata  = fread(fileID, nr_points, readbyte);
    data_ReIm = reshape(filedata, [2*header.Samples, header.nChannels]);
%     data  = data_ReIm(:,1:header.Samples) + 1i.*data_ReIm(:,(header.Samples+1):end);
    data  = data_ReIm(1:header.Samples,:) + 1i.*data_ReIm((header.Samples+1):end,:);

end %end read_spk
