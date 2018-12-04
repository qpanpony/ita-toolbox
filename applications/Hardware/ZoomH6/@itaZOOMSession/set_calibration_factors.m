function set_calibration_factors( obj, cal_ref_factor, channels )
    % Sets the calibration factor (number time data has to be
    % devided) for given channels (or all if channels option
    % missing)
    if nargin < 3
        channels = obj.channels;
    end

    if cal_ref_factor <= 0
        error( 'Calibration factor has to be greater zero, was %f', cal_ref_factor )
    end

    track_ids = obj.get_track_ids( channels );
    for i=1:track_ids
        obj.tracks{ i }.cal_ref_factor = cal_ref_factor;
    end
end
