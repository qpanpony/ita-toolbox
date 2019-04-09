function relative_times = relativetime( obj, absolute_dates )
% Returns the relative time in seconds from beginning of session to
% given absolute date(s). Handy for extracting data with absolute time
% values, i.e. in combination with datenum( '...' )

    relative_times = ( absolute_dates - obj.startdate ) * 24 * 60 * 60; % seconds
    
    if relative_times > obj.trackLength
        error( 'Absolute date(s) exceed session end time' )
    end
    
    if relative_times < 0
        error( 'Absolute date(s) are earlier than session start time' )
    end

end
