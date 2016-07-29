function result = ita_read_blockwise(varargin)
%ITA_READ_BLOCKWISE - reads a wavfile blockwise
%  This function reads a given wavfile blockwise. Call it in a loop over
%  nBlock and you can process your data continuously.
%  Passing nBlock = []�just results in the number of blocks required to
%  process all data.
%
%  Call: audioObj = ita_read_blockwise(filename, nBlock, blocksize, overlapRatio)
%  Call: nBlock = ita_read_blockwise(filename, [], blocksize, overlapRatio)
%
%  Example:
%           nBlock = ita_read_blockwise('sound.wav', [], 2048, 0.5)
%              ao5 = ita_read_blockwise('sound.wav', 5, 2048, 0.5)
%
%   See also ita_read, ita_wavread
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_read_blockwise">doc ita_read_blockwise</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  16-Apr-2009 

verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

narginchk(4,4);

filename = varargin{1};
nBlock = varargin{2};
blocksize = varargin{3};
overlap = varargin{4};

if numel(nBlock) == 0
    % user just wants to know the number of blocks that are needed
    sizeWav = ita_wavread(filename,'size');
    result = ceil(sizeWav(1) ./ (blocksize .* (1-overlap)));
    return;
end

sampleInterval = (nBlock-1) .* blocksize + [1 blocksize] - (nBlock-1) .* blocksize .* overlap;

try
    result = ita_read(filename, sampleInterval);
    
    % fill up the last block with zeros
    if result.nSamples < blocksize
        missingSamples = blocksize - result.nSamples;
        result.nSamples = blocksize;
        result.data = [result.data; zeros(missingSamples ,size(result.data,2))];
    end
    
catch
    error([thisFuncStr ': empty result, as file is not that long.']);
%     result = [];
%     return;
end

%% Add history line only for first loop
if nBlock == 1
    result = ita_metainfo_add_historyline(result,mfilename,varargin);
end