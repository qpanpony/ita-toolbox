function [ ao_mp ] = ita_HRTFarc_minimum_phase_IR( ai )
%MINIMUM_PHASE_IR returns minimum-phase IR using Hilbert transformation
% 
% ao_mp = MINIMUM_PHASE_IR( itaAudio ) 

% Author: Stefan Zillekens
% Created: 2013-06-19

% check the input
if ~isa(ai, 'itaAudio')
    error('Expecting an itaAudio.')
end

% hilbert transform
X = hilbert(-log(abs(ai.freqData)));

% minimal phase
mp = imag(X); 

% minimal-phase version of ai
ao_mp = ai;
ao_mp.freqData = abs(ai.freqData) .* exp(1i*mp);

end

