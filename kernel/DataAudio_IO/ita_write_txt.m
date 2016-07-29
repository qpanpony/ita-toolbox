function [varargout] = ita_write_txt(audioObj, filename, varargin)
%ITA_WRITE_TXT - Write audioObj to txt-File
%   This functions writes audio structs (frequency or time domain) to a txt-file. 
%
%   Call: ita_write_txt (audioObj, filename)
%         ita_write_txt (audioObj,filename, 'dlm', delimiter, 'idxArray', chIdxArr)
%
%   Parameter pairs for specification of a specific delimiter and an array, 
%   which specifies the channels to be written are optional and can ce
%   specified in arbitrary order
%
%   Default delimiter :  simple whitespace
%   Default chIdxArray: All channels in data struct
%
%   Examples: ita_write_txt (audioObj,'test.txt', 'dlm', '\t','idxArray', [1 3 5])
%             ita_write_txt (audioObj,'test.txt', 'idxArray', [1 2])
%             ita_write_txt (audioObj,'test.txt', 'idxArray', [1 3 5], 'dlm', ';')
%
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_write">doc ita_write</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created:  29-September-2008


%% CONSTANTS
MAXNOCHANNELS = 64; % Maximum number of channels in MF-File

%% READ INPUT ARGUMENTS
if nargin < 2
    error('ITA_WRITE_TXT:Oh Lord. Function requires at least two arguments!')
end

% First input argument must be a struct with data in time or frequency domain.
% -------------------------------------------------------------------------
data         = audioObj.data;
% Check Number of Channels in struct.
isValid = (audioObj.nChannels >= 1) && (audioObj.nChannels <= MAXNOCHANNELS);
if isValid
    nChannels = audioObj.nChannels;
else
    error('ITA_WRITE_TXT:Oh Lord. Number of channels in header and data does not match');
end

% Second input argument must be a valid filename and specifies file where data is written.
% -------------------------------------------------------------------------
if ~ischar(filename)
    error('ITA_WRITE_TXT:Oh Lord. Second argument must be a valid filename!')
end

% Read optional input arguments
%--------------------------------------------------------------------------
[dlm,chIdxArr] = parseoptionalinput(length(varargin),varargin);
% If chIdxArr not specified as optional input, write all channels
if chIdxArr == -1
    chIdxArr = 1:audioObj.nChannels;
end
% Check if idxArray is valid
isValid = ( (min(chIdxArr)>=1) && (max(chIdxArr)<=nChannels) );
if ~isValid
    error('ITA_WRITE_TXT:Oh Lord. Channels specified in "idxArray" exceed data dimension.')
end

%% WRITE DATA TO TXT-FILE

nChArr = size(chIdxArr,2);
nData  = size(data,2);

if audioObj.isFreq
    % Get Frequency Vector
    xAxis = audioObj.freqVector;
else
    % Get TimeScale Vector
    xAxis = audioObj.timeVector;
end

% Preformat data for writing
iCol = 1;
if audioObj.isFreq
    audioData = zeros(length(xAxis),2*nChArr+1);
else % time data
    audioData = zeros(length(xAxis),  nChArr+1);
end    
    audioData(:,1) = xAxis;
    formatString = '%8.4e';
for k = 1:nChArr
    iCol = iCol+1;
    audioData(:,iCol)   = real(data(:,chIdxArr(k)));
    formatString = [ formatString, dlm, '%8.4e' ];
    if (audioObj.isFreq)      % only frequency domain data is complex
        iCol = iCol+1;
        audioData(:,iCol) = imag(data(:,chIdxArr(k)));
        formatString = [ formatString, dlm, '%8.4e' ];
    end
end
formatString = [ formatString, '\n' ];

% Open File to write data
[fid,message] = fopen(filename, 'wt');

if (fid ~= -1)
    % Write Header
 %   fprintf(fid, '# Header:\n');
    fprintf(fid, '# Channels: %u\n', audioObj.nChannels);
    fprintf(fid, '# Comment: %s\n', audioObj.comment);
    fprintf(fid, '# DateVector: Year:%u, Month:%u, Day:%u, Hour:%u, Minute:%u, Second:%u \n', audioObj.dateModified);
 %   fprintf(fid, '# FFTnorm: %s\n', audioObj.signalType);
 %   fprintf(fid, '# SamplingRate: %u\n', audioObj.samplingRate);
 %   fprintf(fid, '# nBins: %u\n', audioObj.nBins);
 %   fprintf(fid, '# nSamples: %u\n', audioObj.nSamples);
 %   fprintf(fid, '# Filename: %s\n', audioObj.fileName);
    fprintf(fid, '# ChannelNames: ');
    for k = 1:nChArr, fprintf(fid, [dlm,'%s'], audioObj.channelNames{k}); end
    fprintf(fid, '\n');
    fprintf(fid, '# ChannelUnits: ');
    for k = 1:nChArr, fprintf(fid, [dlm,'%s'], cell2mat(audioObj.channelUnits(k))); end
    fprintf(fid, '\n');
    
    % Write Data
    fprintf(fid, '# \n');
    fprintf(fid, '# Data:\n');

    if audioObj.isFreq
        % Frequency domain data.
        fprintf(fid, '# Freq');
        for k = 1:nChArr, fprintf(fid, [dlm,'Real(Ch%u)',dlm,'Imag(Ch%u)'], chIdxArr(k), chIdxArr(k)); end
        fprintf(fid, '\n\n');
        fprintf(fid, formatString, audioData.');
    
    elseif audioObj.isTime
        % Time domain data.
        fprintf(fid, '# Time');
        for k = 1:nChArr, fprintf(fid, [dlm,'Ch%u'], chIdxArr(k)); end
        fprintf(fid, '\n\n');
        fprintf(fid, formatString, audioData.');
    end
    fclose(fid);

else
    error(['ITA_WRITE_TXT:Oh Lord.', message]);
end

if nargout == 1
    varargout = {1};
end
%end function
end

function [dlm,chIdxArr] = parseoptionalinput(varInputLength,varargin)

% Initialization of optional input parameter pairs
chIdxArr = -1;                               % default
dlm      = ' ';                             % default

varargin = varargin{:}; % extract cell array input from varargin

isValid = varInputLength>=0 && varInputLength<=4;
isPair  = (mod(varInputLength,2)==0);
if isValid && isPair 
    optInputPairs = varInputLength/2; % number of optional input parameter pairs
else
    error('ITA_WRITE_TXT:Oh Lord. Invalid specification of optional input parameters.')
end

for k = 1:optInputPairs                     % If optInputPairs == 0, for-loop is skipped
    iInput = 2*(k-1) + 1;
    if ischar(varargin{iInput})
        specifier = varargin{iInput};
        if strcmpi(specifier,'dlm')
            if ischar(varargin{iInput+1})
                dlm = setdlm(varargin{iInput+1});
            else
                error('ITA_WRITE_TXT:Oh Lord. Input argument following "dlm" specifier must be of type char.')
            end
        elseif strcmp(specifier,'idxArray')
            if isnumeric(varargin{iInput+1})
                chIdxArr = varargin{iInput+1};
            else
                error('ITA_WRITE_TXT:Oh Lord. Input argument following "dlm" specifier must be of type char.')
            end
        end
    else
        error('ITA_WRITE_TXT:Oh Lord. Optional even input argument must be a valid specifier of type char.')
    end
end
%end function
end


function out = setdlm(in)
tmp = sprintf(in);
if ischar(in) && length(tmp) <= 1
    out = tmp;
else
    error('MATLAB:dlmwrite:delimiter',...
        ['%s is not a valid attribute or delimiter.\n'...
        'Delimiter must be a single character.'],in);
end
%end function
end