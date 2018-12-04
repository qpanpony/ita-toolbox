function [ ref_factor, ref_db ] = get_calibration_factors( obj, channels )
    % Returns the calibration factor (number time data has to be
    % devided) and level to be subtrated for given channels 
    % (or all if channels option missing)
    if nargin < 2
        channels = 1:obj.channels;
    end

    ref_factor = zeros( numel( channels ), 1 );

    for c=1:channels
        assert( numel( c ) == 1 );
        track_id = obj.get_track_ids( c );
        ref_factor( c ) = obj.tracks{ track_id }.cal_ref_factor;
    end

    ref_db = 20 * log10( ref_factor );
end
