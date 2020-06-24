function phase_by_delay = phase_delay( obj, distance )
%PHASE_DELAY Calculates phase delay for the distance for all frequency bins

if distance <= 0
    error 'Distance cannot be zero or negative'
end

lambda = obj.c ./ obj.freq_vec( 2:end ); % Wavelength
k = 2 * pi ./ lambda; % Wavenumber

phase_by_delay = [ 0; exp( -1i .* k .* distance ) ]; % Note: DC value set to ZERO

end
