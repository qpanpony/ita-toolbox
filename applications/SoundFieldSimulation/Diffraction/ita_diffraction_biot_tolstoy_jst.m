function att = ita_diffraction_biot_tolstoy_jst( wedge, source_pos, receiver_pos, sampling_rate, filter_length_samples )

if nargin < 4
    sampling_rate = 44100;
end
if nargin < 5
    filter_length_samples = 1024;
end

T = 1 / sampling_rate;

att = itaAudio();
att.samplingRate = sampling_rate;
att.nSamples = filter_length_samples;

Tau = 1:T:filter_length_samples;
att.timeData = - s * 1 / sinh( Tau ); 

end
