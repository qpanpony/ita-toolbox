function [ao, s] = ita_read_polar(frequency, dirname, dirnameSouth, rotAngleSouth)
%ITA_READ_POLAR - Reads a directory of polar data .spk files
%   This function reads a directory of polar data .spk file as made
%   by Monkey Forest, optionally you can give a southern hemisphere as well
%   The discrete frequency values given in first parameter are processed.
%
%   Call: [ao, s] = ita_read_polar(frequency,dirname [,dirnameSouth])
%       ao is the itaResult that is plotted
%       s is the itaSampling grid calculated from the MF files
%
%   See also ita_read, itaSampling
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_read">doc ita_read</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  06-Jul-2009 


if nargin == 0
    pList = gui();
    pause(0.01)
    
    frequency = pList{1};
    dirname  = pList{2};
    dirnameSouth = pList{3};
    rotAngleSouth = pList{4};
end

[data, s] = readSPKs(frequency, dirname);

if exist('dirnameSouth','var')
    [dataSouth, sSouth] = readSPKs(frequency, dirnameSouth);

    if ~exist('rotAngleSouth','var'), rotAngleSouth = 0; end;
    rotAngleSouth_rad = rotAngleSouth * pi/180;

    % transform south to north
    sSouth.theta = pi - sSouth.theta;
    sSouth.phi = mod(rotAngleSouth_rad - sSouth.phi, 2*pi);

    s.sph = [s.sph; sSouth.sph];
    data = [data dataSouth];
end

% nmax is an educated guess
% nmax = floor(sqrt(numel(s.theta,1)./4))-1;
nmax = 15;
s.Y = ita_sph_base(s,nmax);

ao = itaResult();
ao.freqVector = frequency;
ao.data = data;
% ao.dimensions = {'frequency','channels'}; % pdi: obsolete
% ao.fcenter = frequency;
% ao = ita_metainfo_check(ao);

if nargout == 0
    maxValue = max(max(abs(data)));
    % now plot it
    nFreqs = numel(frequency);    
    for iFreq = 1:nFreqs
        figure;
        ita_sph_plot_SH(maxValue,{data(iFreq,:).',s},'onballoon','all','FaceAlpha',0.1);
        title(['f = ' num2str(frequency(iFreq),'%d') 'Hz'])
    end
end
end

function [data, s] = readSPKs(frequency, dirname)
fileList = dir(dirname);
nFiles = numel(fileList);

% work from the end to the start, to be able to keep the index when
% deleting entries
for ind = nFiles:-1:1
    if ~isPolar(fileList(ind).name)
        fileList(ind) = [];
    end
end

nSpk = numel(fileList);
nFreq = length(frequency);
disp([num2str(nSpk) ' polar files detected.']);
data = zeros(nFreq,nSpk);
s = itaSamplingSph(nSpk);
% s.type = 'sph';

% initialize angles
theta = zeros(nSpk,1);
phi = theta;

for ind = 1:nSpk
    % read every .spk or .ita file in directory
    ao = ita_read([dirname filesep fileList(ind).name]);
    
    % convert to frequency domain if necessary 
    ao = ao';
    
    % get angles for that file
    [theta(ind), phi(ind)] = getPos(fileList(ind).name);
    
    freq = ao.freqVector;
    if ao.nChannels > 1
        warning('more than one channel, I just use first one');
    end
    for iFreq = 1:nFreq
        % process all given frequencies
        indFreq = find(freq >= frequency(iFreq),1);
        data(iFreq,ind) = ao.data(indFreq,1);
    end
end
% now set all sampling information
s.theta = theta;
s.phi = phi;

function bool = isPolar(filename)
% check if it is a V???H???.* file
bool = strcmpi(filename(1),'v') && ...
        strcmpi(filename(5),'h');% && ...
        %strcmpi(filename(9:end),'.spk');
end

function [theta, phi] = getPos(filename)
v = str2num(filename(2:4)); %#ok<ST2NM>
h = str2num(filename(6:8)); %#ok<ST2NM>

if v < 180
    theta_deg = 90 - v;
else
    theta_deg = 450 - v;
end 
theta = pi/180 * theta_deg;
phi = pi/180 * h;
end
end

function pList = gui()
    pList = [];
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Read a set of SPK polar data.';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'at which frequency';
    pList{ele}.helptext    = 'Data at that frequency is read.';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '1000';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Directory North';
    pList{ele}.helptext    = 'In that directory the files will be read.';
    pList{ele}.datatype    = 'path';
    pList{ele}.default     = '';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Directory South';
    pList{ele}.helptext    = 'That directory contains the southern data, they will be flipped. (optional)';
    pList{ele}.datatype    = 'path';
    pList{ele}.default     = '';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Rotate the southern part by ... degree';
    pList{ele}.helptext    = 'Useless text for a sometimes usefull operation.';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '0';
    
    pList = ita_parametric_GUI(pList,[mfilename ' - Calibration with Pistonphone']);
end
