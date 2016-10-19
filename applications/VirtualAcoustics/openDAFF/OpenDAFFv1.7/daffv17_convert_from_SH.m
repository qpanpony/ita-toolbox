function daffv17_convert_from_SH( input_data_sh, export_file_path, additional_metadata )
% Reads a spherical harmonics data set and
% exports a DAFF file
%
% input_data_sh   Input file path to DAFF v1.5 content
% export_file_path  Output file path (will be DAFF v1.7 content)
% additional_metadata   Extend metadata of target file (must be a daffv17 metadata)
%

default_leg_degree = 5; % default value for alphares, betares if not in input struct

if nargin < 3
    additional_metadata = [];
end

metadata_v17 = daffv17_add_metadata( additional_metadata, 'Converter script', 'String', 'daffv17_convert_from_SH' );
metadata_v17 = daffv17_add_metadata( metadata_v17, 'Defita_svn_u', 'String', 'Converted from DAFF version 1.5' );
metadata_v17 = daffv17_add_metadata( metadata_v17, 'Date of conversion', 'String', date );

if ~isfield( input_data_sh, 'radiation' )
    error( 'Invalid input: spherical harmonics data misses "radiation" key.' )
end

if ~isfield( input_data_sh, 'sampling' )
    warning( 'Spherical harmonics data misses \"sampling\" key, using default gaussian grid with %ix%i degree legs.', default_leg_degree, default_leg_degree )
    nmax_grid = 30;
    input_data_sh.sampling = ita_sph_sampling_gaussian( nmax_grid );
    input_data_sh.alphares = default_leg_degree;
    input_data_sh.betares = default_leg_degree;
end

if ~isfield( input_data_sh, 'alphares' )
    input_data_sh.alphares = default_leg_degree;
end

if ~isfield( input_data_sh, 'betares' )
    input_data_sh.betares = default_leg_degree;
end


daffv17_write( 'filename', export_file_path, ...                
            'metadata', metadata_v17, ...
            'datafunc', @dfConvertFromSH, ...
            'userdata', input_data_sh, ...
            'content', 'ms', ...
            'channels', 1, ...
            'alphares', input_data_sh.alphares, ...
            'betares', input_data_sh.betares, ...
            'orient', [ 0 0 0 ] );

end
