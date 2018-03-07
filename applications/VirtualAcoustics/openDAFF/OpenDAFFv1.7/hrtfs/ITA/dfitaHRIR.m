function [ data, samplerate, metadata ] = dfitaHRIR( alpha, beta, itaHRTF_obj )

    samplerate = itaHRTF_obj.samplingRate;    
    
    hrtf = itaHRTF_obj.findnearestHRTF( 180 - beta, alpha );
    
    % DAFF requires data alignment by multiple of 4
    nResidual = mod( hrtf.nSamples, 4 );
    data = [ hrtf.timeData', zeros( hrtf.nChannels, nResidual ) ];
    
    metadata = [];
end
