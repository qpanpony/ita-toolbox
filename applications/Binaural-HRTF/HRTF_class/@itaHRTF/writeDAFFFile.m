function writeDAFFFile( this, file_path, varargin )
% Exports itaHRTF to a DAFF file using daffv17_write
%
% Will export the entire angle range of the itaHRTF data set from
% minimum angle to maximum angle in theta and phi by an angular 
% resulution of the range divided by the number of available spatial
% points as a equi-angular grid (regular grid, Gaussian sampling).
%
% Input:    file_path (string) [optional]
%           write_daff_args optional arguments (passed to daffv17_write) [optional]
%
% Required: OpenDAFF matlab scripts, http://www.opendaff.org
%           (but included in ITA-Toolbox)
%
% Output: none

hrtf_variable_name = inputname( 1 );
file_name = [ hrtf_variable_name '_' int2str( this.nSamples ) 'samples_' int2str( this.resAzimuth ) 'x' int2str( this.resElevation ) '.daff'];
if nargin >= 2
    file_name = file_path;    
end

if nargin == 0
    error( 'Not enough input arguments' );
end


%% Prepare daff_write arguments

if strcmp( this.domain, 'time' )

    % Content type switcher between time domain (ir) and frequency domain (dft)
    % (requires different data functions and content descriptor)
    
    sIn.content = 'ir';
    sIn.datafunc = @dfitaHRIRDAFFDataFunc;
    sIn.zthreshold = -400; % zero threshold for discarding samples in beginning and end region of IR (where only noise is present)
    
elseif strcmp( this.domain, 'freq' )
    
    sIn.content = 'dft';
    sIn.datafunc = @dfitaHRTFDAFFDataFunc;
    
end

sIn.metadata = this.mMetadata;
sIn.quantization = 'float32';
sIn.userdata = this;
sIn.orient = [ 0 0 0 ];
sIn.quiet = false;

if ~isempty( varargin )
    daff_write_args = ita_parse_arguments( sIn, varargin{ 1 } );
else
    daff_write_args = ita_parse_arguments( sIn, varargin );
end


%% Inject content type indicator 'ir' or 'dft' into file name

ct_indicator = 'ir';
if strcmp( this.domain, 'freq' )
    ct_indicator = 'dft';
end

[ file_path, file_base_name, file_suffix ] = fileparts( file_name );
if ~strcmp( file_suffix, '.daff' ) && ~isempty( file_suffix )
    file_path = fullfile( file_path, strjoin( {file_base_name file_suffix 'v17' ct_indicator 'daff' }, '.' ) );
else
    file_path = fullfile( file_path, strjoin( {file_base_name 'v17' ct_indicator 'daff'}, '.' ) );
end

daff_write_args.filename = file_path;


%% Prepare angle ranges and resolution

theta_start_deg = rad2deg( min( this.channelCoordinates.theta ) );
theta_end_deg = rad2deg( max( this.channelCoordinates.theta ) );
theta_num_elements = size( uniquetol( this.channelCoordinates.theta ), 1 );

phi_start_deg = rad2deg( min( mod( this.channelCoordinates.phi, 2 * pi ) ) );
phi_end_deg = rad2deg( max( mod( this.channelCoordinates.phi, 2 * pi ) ) );
phi_num_elements = size( uniquetol( this.channelCoordinates.phi ), 1 );

assert( phi_num_elements ~= 0 );
alphares = ( phi_end_deg - phi_start_deg ) / phi_num_elements; % phi end does not cover entire circle in this case
alphares_full_circle = ( phi_end_deg - phi_start_deg ) / ( phi_num_elements - 1 ); % phi end does not cover entire circle in this case
if phi_end_deg + alphares_full_circle >= 360.0
    alpharange = [ phi_start_deg 360 ]; % Account for full circle and force end of range to 360 deg
    alphares = alphares_full_circle;
else
    alpharange = [ phi_start_deg phi_end_deg ];
end

assert( alpharange( 1 ) >= 0.0 )
assert( alpharange( 2 ) <= 360.0 )

assert( theta_num_elements ~= 0 );
betares = ( theta_end_deg - theta_start_deg ) / ( theta_num_elements - 1 ); % phi end does not cover entire circle
betarange = 180 - [ theta_start_deg theta_end_deg ]; % Flip poles (DAFF starts at south pole)

assert( betarange( 2 ) >= 0.0 )
assert( betarange( 1 ) <= 180.0 )

daff_write_args.betarange = alpharange;
daff_write_args.alphares = alphares;
daff_write_args.betarange = betarange;
daff_write_args.betares = betares;


%% Assemble metadata (if not already present)

keyname = 'Generation script';
if isempty(daff_write_args.metadata) || ~any( strcmpi( { daff_write_args.metadata(:).name }, keyname ) )
    daff_write_args.metadata = daffv17_add_metadata( daff_write_args.metadata, keyname, 'String', 'writeDAFFFile.m' );
end

keyname = 'Generation toolkit';
if ~any( strcmpi( { daff_write_args.metadata(:).name }, keyname ) )
    daff_write_args.metadata = daffv17_add_metadata( daff_write_args.metadata, keyname, 'String', 'ITA-Toolkit' );
end

keyname = 'Generation date';
if ~any( strcmpi( { daff_write_args.metadata(:).name }, keyname ) )
    daff_write_args.metadata = daffv17_add_metadata( daff_write_args.metadata, keyname, 'String', date );
end

keyname = 'Git Version';
if ~any( strcmpi( { daff_write_args.metadata(:).name }, keyname ) )
    versionHash = ita_git_getMasterCommitHash;
    daff_write_args.metadata = daffv17_add_metadata( daff_write_args.metadata, keyname, 'String', versionHash );
end

keyname = 'Web resource';
if ~any( strcmpi( { daff_write_args.metadata(:).name }, keyname ) )
    daff_write_args.metadata = daffv17_add_metadata( daff_write_args.metadata, keyname, 'String', 'http://www.ita-toolkit.org' );
end


%% Channels

channels=this.nChannels/this.nDirections;
if(channels<1)
    warning('Number of channels per record was not detected correctly, assuming 2 channel records');
    channels = 2;
end

daff_write_args.channels = channels;


%% Call daff_write and pass argument list

daffv17_write( daff_write_args );


end
