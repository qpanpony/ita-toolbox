function [ data, samplerate, isSymetric, metadata ] = dfitaHRTF( alpha, beta, itaHRTF_obj )

    samplerate = itaHRTF_obj.samplingRate;   
    isSymetric = false;
    
    hrtf = itaHRTF_obj.findnearestHRTF( 180 - beta, alpha );
    
    % DAFF requires data alignment by multiple of 4. Interpolate by zero padding
    % in time domain
    nResidual = mod( hrtf.nSamples, 4 );
    if nResidual ~= 0
        data = ifft( [ hrtf.timeData', zeros( hrtf.nChannels, nResidual ) ] );
    else
        data = hrtf.freqData';
    end
    
    metadata = [];
end
