function [ freqs, mags, metadata ] = dfMIROMS( alpha, beta, miro_obj )
    
    if strcmp( miro_obj.angles, 'DEG' )
        [ irID, azimuth, elevation ] = closestIr( miro_obj, alpha, beta );
    else
        [ irID, azimuth, elevation ] = closestIr( miro_obj, deg2rad( alpha ), deg2rad( beta ) );
    end
    hrir = getIR( miro_obj, irID );
        
    nResidual = mod( size( hrir, 1 ), 4 );
    if nResidual > 0
        mags = abs( fft( [ hrir' zeros( 2, 4 - nResidual ) ] ) );
    else
        mags = abs( fft( hrir' ) );
    end
    
    freqs = ( 1:size( mags, 2 ) ) * miro_obj.fs / 2 / size( mags, 2 );
        
    metadata = [];
    if strcmp( miro_obj.angles, 'RAD' )
        azimuth = rad2deg( azimuth );
        elevation = rad2deg( elevation );
    end
    
    angle_threshold_deg = 0.2;
    if abs( diff( [ azimuth alpha ] ) ) < angle_threshold_deg || ...
       abs( diff( [ elevation beta ] ) < angle_threshold_deg )
        daffv17_add_metadata( metadata, 'MIRO Nearest Neighbour Search Applied', 'Bool', true );
        daffv17_add_metadata( metadata, 'MIRO Nearest Neighbour Azimuth', 'Float', azimuth );
        daffv17_add_metadata( metadata, 'MIRO Nearest Neighbour Elevation', 'Float', elevation );
    end
end
