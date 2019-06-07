function phase_by_delay = ita_propagation_delay( distance, c, fs, fft_degree )
%ITA_RPOPAGATION_SPREADING_LOSS Calculates spreading loss for different
%wave types for a given distance (straight line between emitter center
%point and sensor point)

if nargin ~= 4
    error 'Expecting 4 arguments'
end

if distance <= 0
    error 'Distance cannot be zero or negative'
end

delay_tf = itaAudio();
delay_tf.samplingRate = fs;
delay_tf.fftDegree = fft_degree;

f = delay_tf.freqVector;
lambda = c ./ f( 2:end ); % Wavelength
k = 2 * pi ./ lambda; % Wavenumber

phase_by_delay = [ 0; exp( -1i .* k .* distance ) ]; % Note: DC value set to ZERO

end
