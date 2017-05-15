function [ data, samplerate, metadata ] = dfitaHRIRDAFFDataFunc( alpha, beta, itaHRTF_obj )

    samplerate = itaHRTF_obj.samplingRate;    
    
    hrtf = itaHRTF_obj.findnearestHRTF( 180 - beta, alpha );
    
    % DAFF requires data alignment by multiple of 4
    nResidual = mod( hrtf.nSamples, 4 );
    data = [ hrtf.timeData', zeros( hrtf.nChannels, mod(4 - nResidual,4) ) ];
    
    metadata = [];
end
