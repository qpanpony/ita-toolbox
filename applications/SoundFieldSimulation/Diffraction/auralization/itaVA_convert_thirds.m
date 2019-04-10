function [ ir ] = itaVA_convert_thirds( mags, ir_length, fs, freqs )
%ITAVA_CONVERT_THIRDS Converts third octave magnitude spectra to an impulse response
%
% Defaults to third octave spectrum resolution (31 mags) returning an
% impulse response of 1024 samples at 44.1kHz
%
% mags          magnitude spectrum (factors)
% ir_length     length of impulse response (samples)
% fs            sampling rate (Hertz)
% freqs         supporting / base vector of frequencies (Hertz)

if nargin < 4
    % ita_ANSI_center_frequencies
    freqs = [ 20 25 31.5000000000000 40 50 62.5000000000000 80 100 125 155 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6350 8000 10000 12500 16000 20000 ];
end
if nargin < 3
    fs = 44100;
end
if nargin < 2
    ir_length = 1024;
end

assert( numel( freqs ) >= 2 )
freq_vec = linspace( freqs( 1 ), freqs( end ), ir_length / 2 );

mags_p = interp1( freqs, mags, freq_vec, 'pchip' )';
mags_P = itaAudio( mags_p, fs, 'freq' );
mags_P.signalType = 'energy';
ir_mp = ita_minimumphase( mags_P );
ir = ir_mp.timeData;

end
