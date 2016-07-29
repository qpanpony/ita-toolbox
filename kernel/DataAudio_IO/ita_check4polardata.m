function folderInfo = ita_check4polardata(varargin)
%ITA_CHECK4POLARDATA - Type of files in the folder
%  This function checks the audio data for a polar data set and if found
%  exports the folderInfo struct, containing...
%       .type = 'polar'
%       .nBins              : number of frequency bins
%       .VxxxHxxx           : arrangement of filenames
%       .theta              : elevational angles (radians)
%       .phi                : azimuthal angles (radians)
%
%  Syntax: info = ita_check4polardata(fileList)
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_check4polarInfo">doc ita_check4polarInfo</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created: 16-Sep-2008

%% Initialization
% Number of Input Arguments
narginchk(1,1);

%% make a cell array
if iscell(varargin{1})
    audioCell = varargin{1};
elseif isstruct(varargin{1})
    audioCell = {varargin{1}};
end

nAudioCell = numel(audioCell);

%% Get ITA Toolbox preferences
% mpo: batch commenting of: "Mode % global variable is loaded very fast" 
verboseMode = ita_preferences('verboseMode'); % mpo, batch replacement, 15-04-2009

%% check folder types

% make the list of files
fileList = cell(1,nAudioCell);
for n = 1:nAudioCell
    fileList(n) = {audioCell{n}.Filename};
end

% folderInfo.type = 'mixed'; %mixed is the starting point, until proven otherwise
% if length(fileList) == 1
%     folderInfo.type = 'single'; % only one file is always single
%     return; % finished...!
% end;

% search for all polar data in cell array
VxxxHxxx = [];
folderInfo.nBins = 0;
for n = 1:numel(fileList)
    if (lower(fileList{n}(1))=='v') && (lower(fileList{n}(5))=='h')
        % this is polar data
        if verboseMode, disp(['Polar Data detected:' fileList{n}]), end
        VxxxHxxx = [VxxxHxxx fileList(n)];
        
        % if nBins not yet set... set it and SR
        if ~folderInfo.nBins
            folderInfo.nBins = audioCell{n}.nBins;
            folderInfo.samplingRate = audioCell{n}.samplingRate;
        end
    end
end

% if less than 10 polar data sets detected -> stop function
if numel(VxxxHxxx) < 10
    return;
end

folderInfo.type = 'polar';
% and sort polar data alphabetically
VxxxHxxx = sort(VxxxHxxx);

% get all angles (H, V)
nPolardata = numel(VxxxHxxx);
if verboseMode && (nPolardata ~= nAudioCell)
    warning('There are also some other files in directory.');
end

V = zeros(nPolardata,1);
H = V;
for n = 1:numel(VxxxHxxx)
    V(n) = str2double(VxxxHxxx{n}(2:4));
    H(n) = str2double(VxxxHxxx{n}(6:8));
%     % take care of strange MF angles:
%     if V(n) > 90
%         V(n) = 270 - V(n);
%     end
end

% search the last element which is V000Hxxx
nH = find(~V,1,'last');
% and the number of element which are VxxxH000
nV = numel(find(~H));

% sort the elements like normal people use it
lastNorth = find(V == 90, 1, 'last');
V(1:lastNorth) = 90 - V(lastNorth:-1:1); % swap northern hemisphere
H(1:lastNorth) = H(lastNorth:-1:1);
VxxxHxxx(1:lastNorth) = VxxxHxxx(lastNorth:-1:1);
if numel(V) > lastNorth
    firstSouth = lastNorth+1;
    V(firstSouth:end) = 360 - V(end:-1:firstSouth) + 90; % swap southern hemisphere
    H(firstSouth:end) = H(end:-1:firstSouth);
    VxxxHxxx(firstSouth:end) = VxxxHxxx(end:-1:firstSouth);
end 

if (nH * nV) == nPolardata
    disp('Okidoki, all data for a regular polar grid seem to be there.');
else
    disp('This is polar data, but not a regular grid.');
    return; % jump out of this function
end

% create a matrix with all the polar data file names
folderInfo.VxxxHxxx = fliplr(rot90(reshape(VxxxHxxx, [nH nV])));

% angles now given in radians
conversion2radians = pi/180;
% folderInfo.V = num2str flipud(rot90(reshape(V, [nH nV]),3));
folderInfo.theta = conversion2radians * fliplr(flipud(rot90(reshape(V, [nH nV]),3)));
folderInfo.phi = conversion2radians * fliplr(flipud(rot90(reshape(H, [nH nV]))));

end