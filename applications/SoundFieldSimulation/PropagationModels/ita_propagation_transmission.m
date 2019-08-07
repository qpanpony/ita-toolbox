function T = ita_propagation_transmission( m_dash, f, Z )
%ITA_RPOPAGATION_TRANSMISSION Calculates transmission factor T (linear value, complex)
% based on mass law using material mass-per-area m_dash, frequency f and wave
% impedance Z

assert( m_dash > 0 )
assert( numel( f ) > 0 )

if nargin < 3
    ita_propagation_load_defaults
    Z = ita_propagation_defaults.air.wave_impedance;
end

if any( f == 0 )
    error 'Can''t calculate a transmission factor for frequency value ''0'' / DC component'
end

omega = 2 * pi * f;
T = 1i .* omega .* m_dash ./ ( 2 .* Z + 1i .* omega .* m_dash ) - 1;

% R = 10 log10( 1 + ( omega m' / ( 2 rh0_0 c ) ^2 )
