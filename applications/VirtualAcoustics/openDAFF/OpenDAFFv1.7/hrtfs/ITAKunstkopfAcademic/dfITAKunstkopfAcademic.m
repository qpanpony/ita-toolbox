function [ data, samplerate, metadata ] = dfITAKunstkopfAcademic( a, b, config )

	file_base_name = sprintf( 'E%0.3dA%0.3d', b-90, a );
		
    % Hack: unfortunately, there is no alpha 45° at elevation 135°. Map to front/back.
    if b == 135
        mapped_a = a;
        if mod( a, 90 ) ~= 0
            if a == 45 || a == 315
                mapped_a = 0;
            elseif a == 135 || a == 225
                mapped_a = 180;
            end
        end
        file_base_name = sprintf( 'E%0.3dA%0.3d', b-90, mapped_a );
    end
    
	file_path = fullfile( config.basepath, [ file_base_name '.WAV' ] );
    
	if ~exist( file_path, 'file' ) 
		error( [ 'Could not find path "' file_path '", aborting.' ] )
    end
    
    [ y, Fs ] = audioread( file_path );
    samplerate = Fs;
    data = y';

    % We have to align to a multiple of 4 (OpenDAFF requires this for
    % efficient data storage)
    residual_samples = mod( size( data, 2 ), 4 );
    if residual_samples
        data = [ data zeros( 2, 4 - residual_samples ) ];
    end
		
    metadata = [];
    metadata = daff_add_metadata( metadata, 'FileBaseName', 'String', file_base_name );
    
end
