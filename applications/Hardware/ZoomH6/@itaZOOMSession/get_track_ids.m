function [ track_ids ] = get_track_ids( obj, channels )
    % Returns the tracks that correspond to a certain audio channel
    % on the ZOOM device (track ids are not necessarily in the same order
    % as channels and there might be less tracks than the used
    % channel number (i.e. if only channel 3 has been recorded)
    track_ids = [];
    for t = 1:numel( obj.tracks )
        if obj.tracks{ t }.channel_idx == channels
            track_ids( end + 1 ) = t;
        end
    end
end
