function daffv17_convert_from_itaHRTF( itaHRTF_obj, file_path, metadata_user )
% Exports itaHRTF to a DAFF file
%
% Input:    file_path (string) [optional]
%           user metadata (struct created with daff_add_metadata) [optional]
%
% Required: ITA-Toolbox, http://www.ita-toolbox.org
%           (includes itaHRTF class)
%
% Output: none

metadata = [];
if nargin >= 3
    metadata = metadata_user;
end

hrtf_variable_name = inputname( 1 );
file_name = [ hrtf_variable_name '_' int2str( itaHRTF_obj.nSamples ) 'samples_' int2str( itaHRTF_obj.resAzimuth ) 'x' int2str(itaHRTF_obj.resElevation) '.daff'];
if nargin >= 2
    file_name = file_path;    
end

if nargin == 0
    error( 'Not enough input arguments' );
end


%% Inject content type indicator 'ir' or 'dft' into file name

ct_indicator = 'ir';
if strcmp( itaHRTF_obj.domain, 'freq' )
    ct_indicator = 'dft';
end

file_path_base = strsplit( file_name, '.' );
if ~strcmp( file_path_base(end), 'daff' )
    file_path = strjoin( [ file_path_base(:) 'v17' ct_indicator 'daff' ], '.' );
else
    file_path = strjoin( [ file_path_base(1:end-1) 'v17' ct_indicator 'daff' ], '.' );
end


%% Prepare angle ranges and resolution

theta_start_deg = rad2deg( min( itaHRTF_obj.channelCoordinates.theta ) );
theta_end_deg = rad2deg( max( itaHRTF_obj.channelCoordinates.theta ) );
theta_num_elements = size( unique( itaHRTF_obj.channelCoordinates.theta ), 1 );

phi_start_deg = rad2deg( min( mod( itaHRTF_obj.channelCoordinates.phi, 2*pi ) ) );
phi_end_deg = rad2deg( max( mod( itaHRTF_obj.channelCoordinates.phi, 2*pi ) ) );
phi_num_elements = size( unique( itaHRTF_obj.channelCoordinates.phi ), 1 );

assert( phi_num_elements ~= 0 );
alphares = ( phi_end_deg - phi_start_deg ) / phi_num_elements; % phi end does not cover entire circle in this case
alphares_full_circle = ( phi_end_deg - phi_start_deg ) / ( phi_num_elements - 1 ); % phi end does not cover entire circle in this case
if phi_end_deg + alphares_full_circle >= 360.0
    alpharange = [ phi_start_deg ( phi_end_deg + alphares_full_circle ) ]; % Account for full circle
    alphares = alphares_full_circle;
else
    alpharange = [ phi_start_deg phi_end_deg ];
end

assert( theta_num_elements ~= 0 );
betares = ( theta_end_deg - theta_start_deg ) / ( theta_num_elements - 1 ); % phi end does not cover entire circle
betarange = 180 - [ theta_start_deg theta_end_deg ]; % Flip poles (DAFF starts at south pole)

%% Assemble metadata

metadata = daffv17_add_metadata( metadata, 'Generation script', 'String', 'daffv17_convert_from_itaHRTF.m' );
metadata = daffv17_add_metadata( metadata, 'Generation date', 'String', date );

channels = 2; % this.nChannels < does not work?

% Content type switcher between time domain (ir) and frequency domain (dft)
% (requires different data functions)
if strcmp( itaHRTF_obj.domain, 'time' )

    daffv17_write('filename', file_path, ...
               'content', 'ir', ...
               'datafunc', @dfitaHRIR, ...
               'channels', channels, ...
               'alphares', alphares, ...
               'alpharange', alpharange, ...
               'betares', betares, ...
               'betarange', betarange, ...
               'orient', [ 0 0 0 ], ...
               'metadata', metadata, ...
               'userdata', itaHRTF_obj, ...
               'quantization', 'float32' );
           
elseif strcmp( itaHRTF_obj.domain, 'freq' )
    
    daffv17_write('filename', file_path, ...
               'content', 'dft', ...
               'datafunc', @dfitaHRTF, ...
               'channels', channels, ...
               'alphares', alphares, ...
               'alpharange', alpharange, ...
               'betares', betares, ...
               'betarange', betarange, ...
               'orient', [ 0 0 0 ], ...
               'metadata', metadata, ...
               'userdata', itaHRTF_obj, ...
               'quantization', 'float32' );
           
end
