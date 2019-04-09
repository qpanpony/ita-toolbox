function [ ret ] = has_channels( obj, channels )
    % Checks if given channels are available 
    ret = zeros( numel( channels ), 1 );
    for t = 1:numel( obj.tracks )
        for c = 1:numel( channels )
            if obj.tracks{ t }.channel_idx == channels( c )
                ret( c ) = true;
            end
        end
    end
end