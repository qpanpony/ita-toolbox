function spreading_loss_factor = ita_propagation_spreading_loss( distance, wave_type )
%ITA_RPOPAGATION_SPREADING_LOSS Calculates spreading loss for different
%wave types for a given distance (straight line between emitter center
%point and sensor point)

if nargin == 1
    wave_type = 'spherical';
end

if distance <= 0
    error 'Distance cannot be zero or negative'
end

switch( wave_type )
    
    case 'plain'
        spreading_loss_factor = 1;
        
    case 'line'
        spreading_loss_factor = 1 / sqrt( distance );
        
    otherwise
        spreading_loss_factor = 1 / distance;
    
end

end