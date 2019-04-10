%
%  OpenDAFF - A free, open-source software package for directional audio data,
%  OpenDAFF is distributed under the terms of the GNU Lesser Public License (LGPL)
%
%  Copyright (C) Institute of Technical Acoustics, RWTH Aachen University
%
%  Visit the OpenDAFF homepage: http://www.opendaff.org
%
%  -------------------------------------------------------------------------------
%
%  File:    daff_write.m
%  Purpose: Writer DAFF files
%  Author:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: daff_write.m,v 1.7 2010/03/08 14:32:41 stienen Exp $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



% Jan 2014 - Pascal Dietrich - changed strcmp() to strcmpi() - BUGFIX

function [] = daffv15_write( varargin )
%DAFF_WRITE Writes DAFF files
%   ...
%
%  --= General parameters =--
%
%  pretend      none        Do not write a DAFF file, just analyze
%  quiet        none        Suppress information and warning messages
%  verbose      none        Extra informative output
%
%  --= Required parameters =--
%
%  filename     char        Output filename (*.daff)
%  content      char        Content type
%                           ('IR' => Impulse responses,
%                            'MS' => Magnitude spectra,
%                            'PS' => Phase spectra,
%                            'MPS' => Magnitude phase spectra,
%                            'DFT' => discrete Fourier spectra)
%  datafunc     function    Data function (delivers the data for a direction)
%  dataset      function    Dataset containing all records
%  orient       vector-3    Orientation [yaw pitch roll] angles [°]
%  channels     int         Number of channels
%
%  alphares     float       Resolution of alpha-angles
%  betares      float       Resolution of beta-angles
%  alphapoints  int         Number of points in alpha direction
%  betapoints   int         Number of points in beta direction
%
%  You must either specify a dataset or a data function, but not both.
%  You must either specify resolutions or points, but not both.
%
%  --= Optional parameters =--
%
%  basepath     char        Base path for all input files
%  metadata     struct      Global metadata
%
%  alpharange   vector-2    Range of alpha-angles
%  betarange    vector-2    Range of beta-angles
%
%  --= IR content parameters =--
%
%  samplerate       float   Sampling rate [Hertz]
%  quantization     char    Quantization (int16|int24|float32)
%  zthreshold       float   Detection threshold for zero-coefficients (default: -inf)
%
%  --= DFT content parameters =--
%
%  transformsize    int     Discrete Fourier transform size
%  symmetric        logical Complex-conjugate symmetric spectra
%                           Write only first ceil(N+1/2) DFT coefficients
%                           Used for real-valued input data
%
%  --= MS|PS|MPS content parameters =--
%
%  freqs            vector  Support frequencies [Hertz]
%

% --= Option definitions =--

% Options with logical arguments (true|false)
boolarg = {};

% Options with integer number > 0 arguments
ingzarg = {'alphapoints', 'betapoints', 'channels', 'transformsize'};

% Options with floating point number arguments
floatarg = {'zthreshold'};

% Options with floating point number >= 0 arguments
pfloatarg = {'alphares', 'betares', 'samplerate'};

floatvecarg = {'alpharange', 'betarange', 'freqs', 'orient'};

% Options with string parameters
strarg = {'filename', 'basepath', 'content', 'quantization'};

% Options without an argument
nonarg = {'pretend', 'quiet', 'verbose', 'symmetric'};

% Options with one argument
onearg = [boolarg ingzarg floatarg pfloatarg floatvecarg strarg 'datafunc' 'dataset', 'metadata'];

% Required options
reqarg = {'filename', 'content'};


% +------------------------------------------------+
% |                                                |
% |   Parsing and validation of input parameters   |
% |                                                |
% +------------------------------------------------+

% Parse the arguments
args = struct();
for i=1:length(nonarg), args.(nonarg{i}) = false; end

i=1;
while i<=nargin
    if ~ischar(varargin{i}), error(['Parameter ' num2str(i) ': String expected']); end
    key = lower(varargin{i});
    i = i+1;
    r = nargin-i+1; % Number of remaining arguments
    
    switch key
        % Flag options without argument
        case nonarg
            args.(key) = true;
            
            % Options with one argument
        case onearg
            if (r < 1), error(['Option ''' key ''' requires an argument']); end
            args.(key) = varargin{i};
            i = i+1;
            
        otherwise
            error(['Invalid option (''' key ''')']);
    end
end

% Validate the arguments
for i=1:length(reqarg)
    key = reqarg{i};
    if ~isfield(args, key), error(['Option ''' key ''' must be specified']); end
end

for i=1:length(boolarg)
    key = boolarg{i};
    if isfield(args, key)
        if ~islogical(args.(key))
            error(['Argument for option ''' key ''' must be logical']);
        else
            % Type cast
            args.(key) = logical( args.(key) );
        end
    end
end

for i=1:length(ingzarg)
    key = ingzarg{i};
    if isfield(args, key)
        if (~isscalar(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)) || (ceil(args.(key)) ~= args.(key)) || (args.(key) <= 0))
            error(['Argument for option ''' key ''' must be an integer > 0']);
        else
            % Type cast
            args.(key) = int32( args.(key) );
        end
    end
end

for i=1:length(floatarg)
    key = floatarg{i};
    if isfield(args, key)
        if (~isscalar(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)))
            error(['Argument for option ''' key ''' must be a real number']);
        else
            % Type cast
            args.(key) = double( args.(key) );
        end
    end
end

for i=1:length(pfloatarg)
    key = pfloatarg{i};
    if isfield(args, key)
        if (~isscalar(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)) || (args.(key) < 0))
            error(['Argument for option ''' key ''' must be a non-negative real number']);
        else
            % Type cast
            args.(key) = double( args.(key) );
        end
    end
end

for i=1:length(floatvecarg)
    key = floatvecarg{i};
    if isfield(args, key)
        if (~isvector(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)))
            error(['Argument for option ''' key ''' must be a vector of real numbers']);
        else
            % Type cast
            args.(key) = double( args.(key) );
        end
    end
end

for i=1:length(strarg)
    key = strarg{i};
    if isfield(args, key)
        if (~ischar(args.(key)) || (isempty(args.(key))))
            error(['Argument for option ''' key ''' must be a non-empty string']);
        end
    end
end

% More validation ;-)

% Note: We validate fields in 'args' and compile a seperate 'props' structure
% from all the necessary arguments.

props.filename = args.filename;
props.quiet = args.quiet;
props.verbose = args.verbose;

% Verbose overrides quiet
if (props.verbose)
    props.quiet = false;
end

% Content
props.content = upper(args.content);
switch props.content
    case 'IR'
        props.contentStr = 'Impulse responses';
        props.contentType = 0; % DAFF_IMPULSE_RESPONSE
    case 'MS'
        props.contentStr = 'Magnitude spectra';
        props.contentType = 1; % DAFF_MAGNITUDE_SPECTRUM
    case 'PS'
        props.contentStr = 'Phase spectra';
        props.contentType = 2; % DAFF_PHASE_SPECTRUM
    case 'MPS'
        props.contentStr = 'Magnitude phase spectra';
        props.contentType = 3; % DAFF_MAGNITUDE_PHASE_SPECTRUM
    case 'DFT'
        props.contentStr = 'Discrete Fourier spectra';
        props.contentType = 4; % DAFF_DFT_SPECTRUM
        
    otherwise
        error(['Invalid content type (' args.content ')']);
end

% Data function or dataset
props.hasDatafunc = isfield(args, 'datafunc');
props.hasDataset = isfield(args, 'dataset');

if (~xor(props.hasDatafunc, props.hasDataset))
    error('You must specify either ''datafunc'' or ''dataset'', but not both');
end

if (props.hasDataset)
    % Case: Dataset supplied
    
    % Note: Some arguments are not applicable when using datasets
    
    if (isfield(args, 'channels'))
        error('When using a dataset you cannot not specify ''channels''');
    end
    
    if (isfield(args, 'alphapoints'))
        error('When using a dataset you cannot not specify ''alphapoints''');
    end
    
    if (isfield(args, 'alphares'))
        error('When using a dataset you cannot not specify ''alphares''');
    end
    
    if (isfield(args, 'alpharange'))
        error('When using a dataset you cannot not specify ''alpharange''');
    end
    
    if (isfield(args, 'betapoints'))
        error('When using a dataset you cannot not specify ''betapoints''');
    end
    
    if (isfield(args, 'betares'))
        error('When using a dataset you cannot not specify ''betares''');
    end
    
    if (isfield(args, 'betarange'))
        error('When using a dataset you cannot not specify ''betarange''');
    end
    
    % Copy values from the dataset
    props.dataset = args.dataset;
    
else
    
    % Case: Data function supplied
    
    props.datafunc = args.datafunc;
    
    if (~isfield(args, 'channels'))
        error('When using a data function you must specify ''channels''');
    end
    props.channels = args.channels;
    
    % TODO: Check the number of arguments
    % Momentarily deactivated
    %     if nargin(args.datafunc) ~= 1
    %         error('Argument for option ''datafunc'' must be a function which takes exactly one input argument');
    %     end
    %
    %     if nargout(args.datafunc) ~= 1
    %         error('Argument for option ''datafunc'' must be a function which returns exactly one output argument');
    %     end
    
    % Angular ranges default values
    if isfield(args, 'alpharange')
        props.alpharange = args.alpharange;
    else
        % Default range
        props.alpharange = [0 360];
    end
    
    if isfield(args, 'betarange')
        props.betarange = args.betarange;
    else
        % Default range
        props.betarange = [0 180];
    end
    
    % Check range specifications
    if (length(props.alpharange) ~= 2)
        error('Argument for ''alpharange'' must be a two element vector');
    end
    
    if (length(props.betarange) ~= 2)
        error('Argument for ''betarange'' must be a two element vector');
    end
    
    % Correct angular range ordering
    props.alphastart = props.alpharange(1);
    props.alphaend = props.alpharange(2);
    props.betastart = min(props.betarange);
    props.betaend = max(props.betarange);
    
    if ((props.alphastart < 0) || (props.alphastart > 360))
        error('Alpha range values must lie within the interval [0, 360]');
    end
    
    if ((props.betastart < 0) || (props.betastart > 180))
        error('Beta range values must lie within the interval [0, 180]');
    end
    
    if (props.alphastart>  props.alphaend)
        props.alphaspan = 360 - props.alphastart + props.alphaend;
    else
        props.alphaspan = props.alphaend - props.alphastart;
    end
    props.betaspan = props.betaend - props.betastart;
    
    % Alpha points and resolution
    hasAlphaPoints = isfield(args, 'alphapoints');
    hasAlphaRes = isfield(args, 'alphares');
    if (~xor(hasAlphaPoints, hasAlphaRes))
        error('You must specify either ''alphapoints'' or ''alphares'', but not both');
    end
    
    if isfield(args, 'alphares')
        % Alpha resolution speficied
        props.alphares = args.alphares;
        
        % [fwe] Bugfix 2011-07-05
        % If the azimuth span does not wrap around the whole sphere
        % we need to add another point. Otherwise there will not be
        % a point at alphaend. Moreover we need to cast to double
        % explicitly, otherwise the division is evaluated in integers.
        
        if (props.alphaspan == 360)
            % Full alpha coverage
            % Last point of the interval (360°) coincides with the first (0°)
            props.alphapoints = props.alphaspan / double( props.alphares );
        else
            % Partial alpha coverage
            % First and last point do not coincide.
            % Therefore the last point is within the span
            props.alphapoints = props.alphaspan / double( props.alphares ) + 1;
        end
        
        if (ceil(props.alphapoints) ~= props.alphapoints)
            error('Alpha range and alpha resolution are not an integer multiple')
        end
        
    else
        % Alpha points speficied
        props.alphapoints = args.alphapoints;
        
        % [fwe] Bugfix 2011-07-05 (see above)
        if (props.alphaspan == 360)
            props.alphares = props.alphaspan / double( props.alphapoints );
        else
            props.alphares = props.alphaspan / double( props.alphapoints - 1 );
        end
    end
    
    % Beta points and resolution
    hasBetaPoints = isfield(args, 'betapoints');
    hasBetaRes = isfield(args, 'betares');
    if (~xor(hasBetaPoints, hasBetaRes))
        error('You can specify either ''betapoints'' or ''betares'', but not both');
    end
    
    if isfield(args, 'betares')
        % Beta resolution specified
        props.betares = args.betares;
        
        % [fwe] Bugfix 2011-07-05
        % We need to cast to double explicitly, otherwise
        % the division is evaluated in integers.
        
        props.betapoints = (props.betaspan / double( props.betares )) + 1;
        if (ceil(props.betares) ~= props.betares)
            error('Beta range and beta resolution are not an integer multiple')
        end
    else
        % Beta points specified
        props.betapoints = args.betapoints;
        
        props.betares = props.betaspan / double( props.betapoints-1 );
    end
    
    % Create an empty helper dataset, which contains all directions
    % (angular pairs). Then we can just iterate over all records,
    % making iteration over directions a lot less complicated
    props.dataset = daffv15_create_dataset('channels', props.channels, ...
        'alpharange', props.alpharange, ...
        'alphapoints', props.alphapoints, ...
        'betarange', props.betarange, ...
        'betapoints', props.betapoints, ...
        'quiet');
end % -- Endif: Case: Dataset | data function --

% Sampling rate
if isfield(args, 'samplerate')
    props.dataset.samplerate = args.samplerate;
end

% Frequency support
if isfield(args, 'freqs')
    props.dataset.freqs = args.freqs;
end

% Tranform size support
if isfield(args, 'transformsize')
    props.dataset.transformsize = args.transformsize;
end

% Symmetric spectra
if isfield(args, 'symmetric')
    props.symmetric = args.symmetric;
end

% Metadata
if isfield(args, 'metadata')
    props.dataset.metadata = args.metadata;
end

% Orientation
if isfield(args, 'orient')
    if (length(args.orient) ~= 3)
        error('Argument for ''orient'' must be a three element vector [yaw pitch roll]');
    end
    props.orient = args.orient;
else
    % Default orientation
    props.orient = [0 0 0];
end

% Default quantization
if ~isfield(args, 'quantization')
    if (props.contentType == 0)
        % For time-domain data => 16-Bit signed integer
        props.quantization = 'int16';
    else
        % For all other data => 32-Bit floating points
        props.quantization = 'float32';
    end
else
    props.quantization = lower(args.quantization);
end

% Validate quantization
switch props.quantization
    case 'int16'
        props.quantizationStr = '16-bit signed integer';
        props.quantizationType = 0; % DAFF_INT16
        
    case 'int24'
        props.quantizationStr = '24-bit signed integer';
        props.quantizationType = 1; % DAFF_INT24
        
    case 'float32'
        props.quantizationStr = '32-bit floating point';
        props.quantizationType = 2; % DAFF_FLOAT32
        
    otherwise
        error(['Invalid quantization (' args.quantization ')']);
end

% --= Content specific validations =--

if strcmpi(props.content, 'IR')
    % Validation for IR content
    
    % Sampling rate must be provided
    if (~isfield(props.dataset, 'samplerate'))
        error('When writing impulse response content, you must specify ''samplerate''');
    end
    
    % Note: All quantizations are allowed for IR content
    
    % Zero-threshold
    if isfield(args, 'zthreshold')
        props.zthreshold = args.zthreshold;
        props.zthreshold_value = 10^(props.zthreshold/20);
    else
        % Default value = 0 (disabled)
        props.zthreshold = -inf;
        props.zthreshold_value = 0;
    end;
end

if strcmpi(props.content, 'MS')
    % Validation for MS content
    
    % Frequencies must be provided
    if ~isfield(props.dataset, 'freqs')
        warning('When writing magnitude spectrum content, you should specify ''freqs''');
        warning('Frequency vector set to ANSI center frequencies (20 Hz - 20 kHz)');
        props.dataset.freqs = ita_ANSI_center_frequencies;
    end
    props.numfreqs = length(props.dataset.freqs);
    
    % Allowed quantizations for MS content: Only float32
    if ~strcmpi(props.quantization, 'float32')
        error('MS content may only be quantized with 32-bit floating points (float32)');
    end
end

if strcmpi(props.content, 'PS')
    % Validation for PS content
    
    % Frequencies must be provided
    if ~isfield(props.dataset, 'freqs')
        error('When writing phase spectrum content, you must specify ''freqs''');
    end
    props.numfreqs = length(props.dataset.freqs);
    
    % Allowed quantizations for PS content: Only float32
    if ~strcmpi(props.quantization, 'float32')
        error('PS content may only be quantized with 32-bit floating points (float32)');
    end
end

if strcmpi(props.content, 'MPS')
    % Validation for MPS content
    
    % Frequencies must be provided
    if ~isfield(props.dataset, 'freqs')
        error('When writing magnitude-phase spectrum content, you must specify ''freqs''');
    end
    props.numfreqs = length(props.dataset.freqs);
    
    % Allowed quantizations for MPS content: Only float32
    if ~strcmpi(props.quantization, 'float32')
        error('MPS content may only be quantized with 32-bit floating points (float32)');
    end
end

if strcmpi(props.content, 'DFT')
    % Validation for DFT content
    
    % Sampling rate must be provided
    if (~isfield(props.dataset, 'samplerate'))
        error('When writing impulse response content, you must specify ''samplerate''');
    end
    
    % Transform size must be provided
    if ~isfield(props.dataset, 'transformsize')
        error('When writing DFT spectrum content, you must specify ''transformsize''');
    end
    
    if isfield(props, 'symmetric') && props.symmetric
        % Compute the number of complex-conjugate symmetric DFT coefficients
        props.numDFTCoeffs = ceil( (double(props.dataset.transformsize) + 1) / 2 );
    else
        props.numDFTCoeffs = props.dataset.transformsize;
    end
    
    % Allowed quantizations for DFT content: Only float32
    if ~strcmpi(props.quantization, 'float32')
        error('DFT content may only be quantized with 32-bit floating points (float32)');
    end
end

% Default value for base path
if isfield(args, 'basepath')
    props.basepath = args.basepath;
else
    props.basepath = '';
end

% Now all parameters are parsed
% Clear all arguments. Everything we need is now stored in 'props'.
clear args;

%% --= End of parameter parsing and validation =--


% +------------------------------------------------+
% |                                                |
% |   Writing of the output file                   |
% |                                                |
% +------------------------------------------------+

% File format version of this daff_write
% Current version = 0.105
fileFormatVersion = 0105;

% Very important! 'l' -> little endian
% (DAFF files are always little endian)
fid = fopen(props.filename, 'wb', 'l');

% Structure for remembering offsets in the file
% for inserting values later
fpos = struct;

% Structure for file block data
fblocks = struct;

%
%  1st step: Write the file header
%

fwrite(fid, 'FW', 'char');
fwrite(fid, fileFormatVersion, 'int32');
fpos.numFileBlocksOffset = ftell(fid);
fwrite(fid, 0, 'int32'); % Placeholder

% File block entries
% Note: We write placeholders for yet unknown block sizes
%       and update the offsets and sizes later.

% Main header entry (FILEBLOCK_DAFF1_MAIN_HEADER = 0x0001)
fwrite(fid, hex2dec('0001'), 'int32');
fpos.mainHeaderOffset = ftell(fid);
fwrite(fid, 0, 'uint64');
fpos.mainHeaderSize = ftell(fid);
fwrite(fid, 0, 'uint64');

% Content header entry (FILEBLOCK_DAFF1_CONTENT_HEADER = 0x0002)
fwrite(fid, hex2dec('0002'), 'int32');
fpos.contentHeaderOffset = ftell(fid);
fwrite(fid, 0, 'uint64');
fpos.contentHeaderSize = ftell(fid);
fwrite(fid, 0, 'uint64');

% Record descriptor block entry (FILEBLOCK_DAFF1_RECORD_DESC = 0x0003)
fwrite(fid, hex2dec('0003'), 'int32');
fpos.recordDescOffset = ftell(fid);
fwrite(fid, 0, 'uint64');
fpos.recordDescSize = ftell(fid);
fwrite(fid, 0, 'uint64');

% Data block entry (FILEBLOCK_DAFF1_DATA  = 0x0004)
fwrite(fid, hex2dec('0004'), 'int32');
fpos.dataOffset = ftell(fid);
fwrite(fid, 0, 'uint64');
fpos.dataSize = ftell(fid);
fwrite(fid, 0, 'uint64');

% Metadata block entry (FILEBLOCK_DAFF1_METADATA = 0x0005)
fwrite(fid, hex2dec('0005'), 'int32');
fpos.metadataOffset = ftell(fid);
fwrite(fid, 0, 'uint64');
fpos.metadataSize = ftell(fid);
fwrite(fid, 0, 'uint64');

%
%  2nd step: Write a placeholder for the main header
%

fblocks.mainHeaderOffset = ftell(fid);

% Main header: 15*4 = 60 Bytes
fwrite(fid, zeros(1, 60, 'uint8'), 'uint8');

fblocks.mainHeaderSize = ftell(fid) - fblocks.mainHeaderOffset;

%
%  3rd step: Write a placeholder for the content specific header
%

fblocks.contentHeaderOffset = ftell(fid);

if strcmpi(props.content, 'IR')
    % Impulse response content header: 4+4+4 = 12 Bytes
    fwrite(fid, zeros(1, 12, 'uint8'), 'uint8');
end

if strcmpi(props.content, 'MS')
    % Magnitude spectra content header: 4+4+(numfreqs*4) Bytes
    fwrite(fid, zeros(1, 8+props.numfreqs*4, 'uint8'), 'uint8');
end

if strcmpi(props.content, 'PS')
    % Phase spectra content header: 4+(numfreqs*4) Bytes
    fwrite(fid, zeros(1, 4+props.numfreqs*4, 'uint8'), 'uint8');
end

if strcmpi(props.content, 'MPS')
    % Magnitude-phase spectra content header: 4+4+(nfreqs*4) Bytes
    fwrite(fid, zeros(1, 8+props.numfreqs*4, 'uint8'), 'uint8');
end

if strcmpi(props.content, 'DFT')
    % DFT spectra content header: 4+4+4+4 = 16 Bytes
    fwrite(fid, zeros(1, 16, 'uint8'), 'uint8');
end

fblocks.contentHeaderSize = ftell(fid) - fblocks.contentHeaderOffset;

%
%  4th step: Write a placeholder for the record descriptor table
%

% Start at a 16-Byte boundary
daffv15_fpad16(fid);
fblocks.recordDescOffset = ftell(fid);

% Note: Each record has a channel desc for each channel

if strcmpi(props.content, 'IR')
    % A single IR record channel desc is 4+4+4+8 Byte = 20 Bytes
    fwrite(fid, zeros(1, 20*props.dataset.numrecords*props.dataset.channels, 'uint8'), 'uint8');
else
    % All other content use a default record channel desc (MS/PS/MPS/DFT)
    % which is 8 Bytes
    fwrite(fid, zeros(1, 8*props.dataset.numrecords*props.dataset.channels, 'uint8'), 'uint8');
end

% Finally we write a placeholder for the list of record metadata indices
% Each entry is 4 Bytes
fpos.recordMetadataList = ftell(fid);
fwrite(fid, zeros(1, 4*props.dataset.numrecords, 'uint8'), 'uint8');

% Now the record descriptor block ends
fblocks.recordDescSize = ftell(fid) - fblocks.recordDescOffset;

%
%  5th step: Write the data itself
%

% Start at a 16-Byte boundary
daffv15_fpad16(fid);
fblocks.dataOffset = ftell(fid);

% Structure for record information
recordDesc = cell(1, props.dataset.numrecords);

props.globalPeak = 0;
props.minEffFilterOffset = -1;
props.maxEffFilterLength = -1;

for i=1:props.dataset.numrecords
    record = props.dataset.records{i};
    
    if (props.hasDatafunc)
        % Obtain the record data using the data function
        
        if strcmpi(props.content, 'IR')
            [data, samplerate, metadata] = props.datafunc(record.alpha, record.beta, props.basepath);
            record.data = data;
            record.metadata = metadata;
            
            % Recheck sampling rate
            if (samplerate ~= props.dataset.samplerate)
                error('For record %d (A%0.1f°, B%0.1f°): Data function delivered different samplerate then expected', i, record.alpha, record.beta);
            end
        end
        
        if strcmpi(props.content, 'MS')
            [freqs, mags, metadata] = props.datafunc(record.alpha, record.beta, props.basepath);
            record.data = mags;
            record.metadata = metadata;
            
            % Recheck sampling rate
            if (isequal(freqs, props.dataset.freqs))
                error('For record %d (A%0.1f°, B%0.1f°): Data function delivered different frequencies then expected', i, record.alpha, record.beta);
            end
        end
        
        % TODO: Implement other datafunctions
    end
    
    
    % --= Validate the data =--
    
    % Empty data is now allowed
    if isempty(record.data)
        error('For record %d (A%0.1f°, B%0.1f°): No data provided', i, record.alpha, record.beta);
    end
    
    if ~isnumeric(record.data)
        error('For record %d (A%0.1f°, B%0.1f°): Data must be numerical', i, record.alpha, record.beta);
    end
    
    % Implicit datatype conversion to double
    if ~strcmpi(class(record.data), 'double')
        data = double( record.data );
    else
        data = record.data;
    end
    
    % Check metadata types
    if isfield(record, 'metadata')
        if ~isstruct(record.metadata)
            error('For record %d (A%0.1f°, B%0.1f°): Metadata must be at least an empty structure', i, record.alpha, record.beta);
        end
    end
    
    
    % Note: From here we use local data variable: data
    
    [channels, numelements] = size(data);
    
    % Test for correct numnber of channels
    if (channels ~= props.dataset.channels)
        error('For record (A%0.1f°, B%0.1f°): Wrong number of channels', i, record.alpha, record.beta);
    end
    
    % Elements per records
    if isfield(props, 'elementsPerRecord')
        if (numelements ~= props.elementsPerRecord)
            error('For record (A%0.1f°, B%0.1f°): Wrong data size', i, record.alpha, record.beta);
        end
    else
        % The first record defines the number of elements/record
        props.elementsPerRecord = numelements;
    end
    
    
    % Test for real-valued data (IR, MS)
    if (strcmpi(props.content, 'IR') || strcmpi(props.content, 'MS'))
        if ~isreal(data)
            error('For record (A%0.1f°, B%0.1f°): Data must be real-valued', i, record.alpha, record.beta);
        end
    end
    
    % Peak detection
    recordDesc{i}.peak = max(max(abs(data)));
    props.globalPeak = max([props.globalPeak  recordDesc{i}.peak]);
    
    if props.verbose && (recordDesc{i}.peak > 1)
        %         fprintf('For record (A%0.1f°, B%0.1f°): Peak value %0.3f greater then 1', i, record.alpha, record.beta, recordDesc{i}.peak);
        fprintf('For record %d: Peak value %0.3f greater then 1\n', i, recordDesc{i}.peak);
    end
    
    % --= Write the data =--
    
    % Vectors storing the data offsets for each channel
    recordDesc{i}.dataOffset = zeros(1, props.dataset.channels);
    
    if strcmpi(props.content, 'IR')
        
        % Vectors for offsets, effective lengths, etc.
        recordDesc{i}.effOffset = zeros(1, props.dataset.channels);
        recordDesc{i}.effLength = zeros(1, props.dataset.channels);
        recordDesc{i}.scaling = zeros(1, props.dataset.channels);
        
        for c=1:props.dataset.channels
            % Remember the offset of this channel data
            % Important: Relative to the beginning of the data block
            recordDesc{i}.dataOffset(c) = ftell(fid) - fblocks.dataOffset;
            
            % Scan the effective boundaries (Matlab indices!)
            [lwr, upr] = daffv15_effective_filter_bounds(data(c,:), props.zthreshold_value);
            
            % Keep the offset and length a modulo of 4 (16-byte alignment)
            % (Note: lwr-1 => switch from Matlab indexing to C-indexing)
            elen = upr-lwr+1;
            recordDesc{i}.effOffset(c) = daffv15_lwrmul(lwr-1, 4);
            recordDesc{i}.effLength(c) = daffv15_uprmul(elen, 4);
            
            props.minEffFilterOffset = min([props.minEffFilterOffset recordDesc{i}.effOffset(c)]);
            props.maxEffFilterLength = max([props.maxEffFilterLength recordDesc{i}.effLength(c)]);
            
            % Back to Matlab indices (+1)
            i1 = recordDesc{i}.effOffset(c) + 1;
            i2 = min(length(data),i1 + recordDesc{i}.effLength(c) - 1);
            
            % Write down the filter coefficients
            switch props.quantization
                case 'int16'
                    % Peak detection within the effective filter coefficients
                    % which defines the scaling for integer quantizations
                    peak = max(abs( data(c,i1:i2) ));
                    
                    % Division by zero protection
                    if (peak == 0)
                        peak = 1;
                    end
                    
                    recordDesc{i}.scaling(c) = peak;
                    
                    % Note: We normalize the data so that -1, +1 maps
                    % to -32767, +32767. The when reading the content
                    % later, we transform -32767, +32767 back to -1, +1
                    % and THEN apply the scaling factor, which is
                    % nothing but the detected peak value in the effective
                    % filter coefficients ...
                    
                    % int16 dynamic range: 2^15-1 = 32767
                    idata = int16( data(c,i1:i2) ./ peak * 32767 );
                    fwrite(fid, idata, 'bit16');
                    clear idata;
                    
                case 'int24'
                    % Peak detection within the effective filter coefficients
                    % which defines the scaling for integer quantizations
                    peak = max(abs( data(c,i1:i2) ));
                    
                    % Division by zero protection
                    if (peak == 0)
                        peak = 1;
                    end
                    
                    recordDesc{i}.scaling(c) = peak;
                    
                    % Note: We normalize the data so that -1, +1 maps
                    % to -8388607, +8388607. The when reading the content
                    % later, we transform -8388607, +8388607 back to -1, +1
                    % and THEN apply the scaling factor, which is
                    % nothing but the detected peak value in the effective
                    % filter coefficients ...
                    
                    % int24 dynamic range: 2^23-1 = 8388607
                    idata = int32( data(c,i1:i2) ./ peak * 8388607 );
                    fwrite(fid, idata, 'bit24');
                    clear idata;
                    
                case 'float32'
                    % Note: Scaling factors are unused for floating points.
                    recordDesc{i}.scaling(c) = 1;
                    fwrite(fid, data(c,i1:i2), 'float32');
            end
        end
    end
    
    if strcmpi(props.content, 'MS') || strcmpi(props.content, 'PS')
        
        for c=1:props.dataset.channels
            % Remember the offset of this channel data
            % Important: Relative to the beginning of the data block
            recordDesc{i}.dataOffset(c) = ftell(fid) - fblocks.dataOffset;
            
            if (props.elementsPerRecord ~= props.numfreqs)
                error('For record (A%0.1f°, B%0.1f°): Data size does not match the number of frequencies', i, record.alpha, record.beta);
            end
            
            % Write down the magnitudes
            switch props.quantization
                case 'float32'
                    fwrite(fid, data(c,:), 'float32');
            end
        end
        
        clear data;
    end % End-if: Case MS|PS content
    
    if strcmpi(props.content, 'MPS')
        
        for c=1:props.dataset.channels
            % Remember the offset of this channel data
            % Important: Relative to the beginning of the data block
            recordDesc{i}.dataOffset(c) = ftell(fid) - fblocks.dataOffset;
            
            if (props.elementsPerRecord ~= props.numfreqs)
                error('For record (A%0.1f°, B%0.1f°): Data size does not match the number of frequencies', i, record.alpha, record.beta);
            end
            
            % Write down the magnitudes
            switch props.quantization
                case 'float32'
                    % Write down complex numbers in interleaved format:
                    % Re(1), Im(1), Re(2), Im(2), ...
                    cdata = zeros(1, props.numfreqs*2);
                    for k=1:props.numfreqs
                        cdata(2*(k-1)+1) = real( data(c,k) );
                        cdata(2*(k-1)+2) = imag( data(c,k) );
                    end
                    
                    % Write the real and imaginary parts
                    fwrite(fid, cdata, 'float32');
            end
        end
        
        clear data;
    end % End-if: Case MPS content
    
    if strcmpi(props.content, 'DFT')
        
        for c=1:props.dataset.channels
            % Remember the offset of this channel data
            % Important: Relative to the beginning of the data block
            recordDesc{i}.dataOffset(c) = ftell(fid) - fblocks.dataOffset;
            
            if (~((props.elementsPerRecord == props.dataset.transformsize) || ...
                    (props.elementsPerRecord == props.numDFTCoeffs)) )
                error('For record (A%0.1f°, B%0.1f°): Data size does not match transform size or number of symmetric coefficients', i, record.alpha, record.beta);
            end
            
            % Write down the magnitudes
            switch props.quantization
                case 'float32'
                    % Write down complex numbers in interleaved format:
                    % Re(1), Im(1), Re(2), Im(2), ...
                    cdata = zeros(1, props.numDFTCoeffs*2);
                    for k=1:props.numDFTCoeffs
                        cdata(2*(k-1)+1) = real( data(c,k) );
                        cdata(2*(k-1)+2) = imag( data(c,k) );
                    end
                    
                    % Write the real and imaginary parts
                    fwrite(fid, cdata, 'float32');
            end
        end
        
        clear data;
    end % End-if: Case DFT content
    
end % End-for: Writing record data

if (props.minEffFilterOffset == -1)
    props.minEffFilterOffset = 0;
end

if (props.maxEffFilterLength == -1)
    props.maxEffFilterLength = props.elementsPerRecord;
end

fblocks.dataSize = ftell(fid) - fblocks.dataOffset;


%
%  6th step: Write the metadata
%

fblocks.metadataOffset = ftell(fid);

props.globalMetadataIndex = -1;
hasMetadata = false;
metadataIndex = 0;

% Write global metadata
if isfield(props.dataset, 'metadata')
    % Test for empty metadata
    if ~isempty(fieldnames(props.dataset.metadata))
        daffv15_write_metadata(fid, props.dataset.metadata);
        props.globalMetadataIndex = metadataIndex;
        metadataIndex = metadataIndex + 1;
        hasMetadata = true;
    end
end

% Write record metadata

for i=1:props.dataset.numrecords
    record = props.dataset.records{i};
    
    recordDesc{i}.metadataIndex = -1;
    
    if isfield(record, 'metadata')
        if ~isempty(fieldnames(record.metadata))
            daffv15_write_metadata(fid, record.metadata);
            recordDesc{i}.metadataIndex = metadataIndex;
            metadataIndex = metadataIndex + 1;
            hasMetadata = true;
        end
    end
end

fblocks.metadataSize = ftell(fid) - fblocks.metadataOffset;
props.filesize = ftell(fid);

%
%  Xth step: Update offsets and sizes in the file header
%

fseek(fid, fpos.mainHeaderOffset, 'bof');
fwrite(fid, fblocks.mainHeaderOffset, 'uint64');

fseek(fid, fpos.mainHeaderSize, 'bof');
fwrite(fid, fblocks.mainHeaderSize, 'uint64');

fseek(fid, fpos.contentHeaderOffset, 'bof');
fwrite(fid, fblocks.contentHeaderOffset, 'uint64');

fseek(fid, fpos.contentHeaderSize, 'bof');
fwrite(fid, fblocks.contentHeaderSize, 'uint64');

fseek(fid, fpos.recordDescOffset, 'bof');
fwrite(fid, fblocks.recordDescOffset, 'uint64');

fseek(fid, fpos.recordDescSize, 'bof');
fwrite(fid, fblocks.recordDescSize, 'uint64');

fseek(fid, fpos.dataOffset, 'bof');
fwrite(fid, fblocks.dataOffset, 'uint64');

fseek(fid, fpos.dataSize, 'bof');
fwrite(fid, fblocks.dataSize, 'uint64');

if hasMetadata
    % 5 file blocks, when there is metadata
    fseek(fid, fpos.numFileBlocksOffset, 'bof');
    fwrite(fid, 5, 'int32');
    
    fseek(fid, fpos.metadataOffset, 'bof');
    fwrite(fid, fblocks.metadataOffset, 'uint64');
    
    fseek(fid, fpos.metadataSize, 'bof');
    fwrite(fid, fblocks.metadataSize, 'uint64');
else
    % Just 4 file blocks, when there is no metadata
    fseek(fid, fpos.numFileBlocksOffset, 'bof');
    fwrite(fid, 4, 'int32');
end


%
%  7th step: Update the main header
%

fseek(fid, fblocks.mainHeaderOffset, 'bof');
fwrite(fid, props.contentType, 'int32');
fwrite(fid, props.quantizationType, 'int32');
fwrite(fid, props.dataset.channels, 'int32');
fwrite(fid, props.dataset.numrecords, 'int32');
fwrite(fid, props.elementsPerRecord, 'int32');
fwrite(fid, props.globalMetadataIndex, 'int32');
fwrite(fid, props.dataset.alphapoints, 'int32');
fwrite(fid, props.dataset.alpharange(1), 'float32');
fwrite(fid, props.dataset.alpharange(2), 'float32');
fwrite(fid, props.dataset.betapoints, 'int32');
fwrite(fid, props.dataset.betarange(1), 'float32');
fwrite(fid, props.dataset.betarange(2), 'float32');
fwrite(fid, props.orient(1), 'float32');
fwrite(fid, props.orient(2), 'float32');
fwrite(fid, props.orient(3), 'float32');

%
%  8th step: Update the content header
%

fseek(fid, fblocks.contentHeaderOffset, 'bof');

if strcmpi(props.content, 'IR')
    % Impulse response content header
    fwrite(fid, props.dataset.samplerate, 'float32');
    fwrite(fid, props.minEffFilterOffset, 'int32');
    fwrite(fid, props.maxEffFilterLength, 'int32');
end

if strcmpi(props.content, 'MS')
    % Magnitude spectra  content header
    fwrite(fid, props.globalPeak, 'float32');
    fwrite(fid, props.numfreqs, 'int32');
    fwrite(fid, props.dataset.freqs, 'float32');
end

if strcmpi(props.content, 'PS')
    % Phase spectra content header
    fwrite(fid, props.numfreqs, 'int32');
    fwrite(fid, props.dataset.freqs, 'float32');
end

if strcmpi(props.content, 'MPS')
    % Magnitude-phase spectra content header
    fwrite(fid, props.globalPeak, 'float32');
    fwrite(fid, props.numfreqs, 'int32');
    fwrite(fid, props.dataset.freqs, 'float32');
end

if strcmpi(props.content, 'DFT')
    % DFT spectra content header
    fwrite(fid, props.numDFTCoeffs, 'int32');
    fwrite(fid, props.dataset.transformsize, 'int32');
    fwrite(fid, props.dataset.samplerate, 'int32'); % stienen: really? Why not float/double?
    fwrite(fid, props.globalPeak, 'float32');
end


%
%  9th step: Update the record descriptors
%

fseek(fid, fblocks.recordDescOffset, 'bof');

for i=1:props.dataset.numrecords
    if strcmpi(props.content, 'IR')
        % Impulse response content
        
        % Important: For IR content we write an individual descriptor
        % for each channel. This is necessary when we perform zero-compression.
        
        for c=1:props.dataset.channels
            fwrite(fid, recordDesc{i}.effOffset(c), 'int32');
            fwrite(fid, recordDesc{i}.effLength(c), 'int32');
            fwrite(fid, recordDesc{i}.scaling(c), 'float32');
            fwrite(fid, recordDesc{i}.dataOffset(c), 'uint64');
        end
    else
        % All other content (MS,PS,MPS,DFT) uses the default desc
        
        % Also here we write an individual descriptor for each channel
        for c=1:props.dataset.channels
            fwrite(fid, recordDesc{i}.dataOffset(c), 'uint64');
        end
    end
    
    % Afterwards we write the index of the metadata
    fwrite(fid, recordDesc{i}.metadataIndex, 'int32');
end

% Writing is finished
fclose(fid);

if ~props.quiet
    fprintf('\n--= DAFF write summary =----------------------------------------------\n\n');
    
    % Print a intermediate summary of the information
    
    fprintf('  Filename:               \t%s\n', props.filename);
    fprintf('  Filesize:               \t%d Bytes\n', props.filesize);
    fprintf('  Content type:           \t%s\n', props.contentStr);
    fprintf('  Num channels:           \t%d\n', props.dataset.channels);
    fprintf('  Num records:            \t%d\n', props.dataset.numrecords);
    fprintf('  Alpha range:            \t[%0.1f°, %0.1f°]\n', props.dataset.alpharange(1), props.dataset.alpharange(2));
    fprintf('  Alpha resolution:       \t%0.1f°\n', props.dataset.alphares);
    fprintf('  Num alpha points:       \t%d\n', props.dataset.alphapoints);
    fprintf('  Beta range:             \t[%0.1f°, %0.1f°]\n', props.dataset.betarange(1), props.dataset.betarange(2));
    fprintf('  Beta resolution:        \t%0.1f°\n', props.dataset.betares);
    fprintf('  Num beta points:        \t%d\n', props.dataset.betapoints);
    fprintf('  Orientation:            \t(Y%+0.1f°, P%+0.1f°, R%+0.1f°)\n\n', ...
        props.orient(1), props.orient(2), props.orient(3));
    
    if strcmpi(props.content, 'IR')
        fprintf('  Sampling rate:          \t%0.1f Hz\n', props.dataset.samplerate);
        fprintf('  Quantization:           \t%s\n', props.quantizationStr);
        fprintf('  Zero threshold:         \t%+0.1f dB (%0.6f)\n', props.zthreshold, props.zthreshold_value);
    end
    
    if strcmpi(props.content, 'MS')
        fprintf('  Frequencies:            \t%s Hz\n', mat2str(props.dataset.freqs));
    end
    
    if strcmpi(props.content, 'PS')
        fprintf('  Frequencies:            \t%s Hz\n', mat2str(props.dataset.freqs));
    end
    
    if strcmpi(props.content, 'MPS')
        fprintf('  Frequencies:            \t%s Hz\n', mat2str(props.dataset.freqs));
    end
    
    if strcmpi(props.content, 'DFT')
        fprintf('  Sampling rate:          \t%0.1f Hz\n', props.dataset.samplerate);
        fprintf('  Transform size:         \t%d\n', props.dataset.transformsize);
        fprintf('  DFT coefficients stored:\t%d\n', props.numDFTCoeffs);
    end
    
    fprintf('  Global peak:            \t%+0.1f dB (%0.6f)\n\n', 20*log10(props.globalPeak), props.globalPeak);
    
    if props.verbose
        fprintf('  Content header size:    \t%d Bytes\n', fblocks.contentHeaderSize);
        fprintf('  Record descriptor size: \t%d Bytes\n', fblocks.recordDescSize);
        fprintf('  Data size:              \t%d Bytes\n', fblocks.dataSize);
        fprintf('  Metadata size:          \t%d Bytes\n', fblocks.metadataSize);
        fprintf('  Metadata blocks:        \t%d\n\n', metadataIndex);
    end
    
    fprintf('----------------------------------------------------------------------\n\n');
    
    % What we all been waiting for...
    fprintf('DAFF file ''%s'' successfully written\n\n', props.filename);
end
end
