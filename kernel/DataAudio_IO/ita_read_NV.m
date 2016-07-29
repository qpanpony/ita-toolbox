function varargout = ita_read_NV(varargin)
%ITA_READ_NV - read ANSYS NV displacement files
%  This function reads ANSYS NV files with displacements in it and returns
%  an ITA object with velocities.
%
%  Syntax:
%   audioObjOut = ita_read_NV(filename, options)
%
%  Example:
%   audioObjOut = ita_read_NV(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_read_NV">doc ita_read_NV</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% based on file by Julian Blum
% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  07-Jan-2011


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_filename','string', 'frequencies', []);
[filename,sArgs] = ita_parse_arguments(sArgs,varargin);

%% get frequencies
if isempty(sArgs.frequencies)
    % get frequencies from file
    fidfreq = fopen('frequencies.in','r');
    
    if fidfreq == -1
        error([thisFuncStr 'frequency file not found']);
    end
    frequencies_temp=textscan(fidfreq,'%*s %f','delimiter','=');
    freqVector = frequencies_temp{1}(3).';
else
    freqVector = sArgs.frequencies(:);
end

nFreq = numel(freqVector);

if freqVector(1) == 0
    freqNumber = 2;
else
    freqNumber = 1;
end

str = num2str(freqVector(freqNumber),'%05g');
Filename_REAL = [filename '.' str 'Hz.REAL.DISP.NV'];
Filename_IMAG = [filename '.' str 'Hz.IMAG.DISP.NV'];

%% read REAL part
fid=fopen(Filename_REAL,'r');
if fid == -1
    error([thisFuncStr 'file for REAL part not found']);
end
A=textscan(fid,'%d64 %f \n %d64 %f \n %d64 %f \n','delimiter',',');
fclose(fid);

ID = A{1}; %reshape(A{1},3,[]);
nNodes = numel(ID);
freqData2REAL = zeros(nFreq,nNodes,3);
freqData2IMAG = zeros(nFreq,nNodes,3);
freqData2REAL(freqNumber,:,:) = [A{2}(:) A{4}(:) A{6}(:)];

%% read IMAGinary part
fid=fopen(Filename_IMAG,'r');
if fid == -1
    error([thisFuncStr 'file for IMAGinary part not found']);
end;
A=textscan(fid,'%d64 %f \n %d64 %f \n %d64 %f \n','delimiter',',');
fclose(fid);

freqData2IMAG(freqNumber,:,:) = [A{2}(:) A{4}(:) A{6}(:)];

%% read for all frequencies
startfreq=freqNumber+1;
for freqNumber = startfreq:nFreq
    str = num2str(freqVector(freqNumber),'%05g');
    Filename_IMAG = [filename '.' str 'Hz.IMAG.DISP.NV'];
    Filename_REAL = [filename '.' str 'Hz.REAL.DISP.NV'];
    
    % read REAL part
    fid=fopen(Filename_REAL,'r');
    if fid == -1
        error([thisFuncStr 'file for REAL part not found']);
    end
    
    A=textscan(fid,'%d64 %f \n %d64 %f \n %d64 %f \n','delimiter',',');
    fclose(fid);
    freqData2REAL(freqNumber,:,:) = [A{2}(:) A{4}(:) A{6}(:)];
    
    % read IMAGinary part
    fid=fopen(Filename_IMAG,'r');
    if fid == -1
        error([thisFuncStr 'file for IMAGinary part not found']);
    end;
    
    A=textscan(fid,'%d64 %f \n %d64 %f \n %d64 %f \n','delimiter',',');
    fclose(fid);
    freqData2IMAG(freqNumber,:,:) = [A{2}(:) A{4}(:) A{6}(:)];
end

%% convert displacement to velocity
freqVector3d = repmat(freqVector,[1 nNodes 3]);
freqVelocity = freqData2REAL.*1i.*freqVector3d.*2.*pi - freqData2IMAG.*freqVector3d.*2.*pi;

v = itaResult();
v.freqVector = freqVector;
v.freq = freqVelocity;
v.userData = {'nodeN',ID};
v.channelUnits(:) = {'m/s'};

%% Add history line
v = ita_metainfo_add_historyline(v,mfilename,varargin);

%% Set Output
varargout(1) = {v};

%end function
end