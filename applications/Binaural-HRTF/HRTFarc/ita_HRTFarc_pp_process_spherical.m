function [results,shift,shCoeffs,epsilon] = ita_HRTFarc_pp_process_spherical(data,fullCoords,options,shift,dataIndex)
    % for each frequency, a spherical harmonic transformation has to be
    % done
    % as each frequency occures to a specific time in the sweep, the
    % coordinate system is rotated by that degree

    nSH = (options.nmax+1).^2;

    
    %% shift off center
    data = ita_HRTFarc_pp_moveFullDataSet(data,fullCoords,options,shift,1);

    epsilon = options.epsilon;
    
    %% sh transformation
    tmpCoords = fullCoords;


   [~,w]= tmpCoords.spherical_voronoi;  
    W = sparse(diag(w));                                      % diagonal matrix containing weights                               % decomposition order-dependent Tikhonov regularization
    Y = ita_sph_base(tmpCoords,options.nmax,'orthonormal',true);

    I = sparse(eye(nSH));
    n = ita_sph_linear2degreeorder(1:nSH).';
    D = I .* diag(1 + n.*(n+1));

    shCoeffs = complex(nan(nSH,data.nBins)); 
    
     
    wb = itaWaitbar(length(data.freqVector),'SH Transformation');
    tmpFreq = data.freqVector;
    tmpFreqData = data.freqData;
    newPhiData = 0:360/(options.repetitions+1):359;
    for index = 1:length(tmpFreq)
        wb.inc;
        tmpCoords = fullCoords;
        tmpOptions = options;
%         tmpData = data;
        
        frequency = tmpFreq(index);
        freqData = tmpFreqData(index,:);
                
        
        timeOffset = getTimeOffsetFromFrequency(frequency,options);
        if timeOffset > 0
            tmpCoords.phi_deg = fullCoords.phi_deg + options.rotationDirection*timeOffset*options.rotationSpeed;
        end

         % as the spherical harmonic decomposition fails, a linear
        % interpolation for each theta level is applyed first

        thetaValues = uniquetol(tmpCoords.theta_deg);
        for thetaIndex = 1:length(thetaValues)
           thetaSlice = (abs(tmpCoords.theta_deg-thetaValues(thetaIndex)) < 0.1);
           sliceData = freqData(thetaSlice);
           slice_phi = tmpCoords.n(thetaSlice).phi_deg;
           [sortedPhi,order] = sort(mod(slice_phi+360,360));

           repData = repmat(sliceData(order),1,3);
           repPhiData = [sortedPhi-360; sortedPhi; sortedPhi+360];


           newData = interp1(repPhiData,repData,newPhiData);
           freqData(thetaSlice) = newData;
           tmpCoords.phi_deg(thetaSlice) = newPhiData;
        end
        [~,w]= tmpCoords.spherical_voronoi;  
        W = sparse(diag(w));                                      % diagonal matrix containing weights
        Y = ita_sph_base(tmpCoords,options.nmax,'orthonormal',true);

        
        % bigger epsilon for lower frequencies
        if tmpFreq(index) < 1000
           epsilon = 10^-6; 
        else
           epsilon = tmpOptions.epsilon; 
        end
        nominator = (Y'*W*Y + epsilon*D);
        denominatorMatrix = Y'*W ;
        shCoeffs(:,index)              =  nominator\ denominatorMatrix * freqData.';

    end
    wb.delete
    %% reconstruction
    if isempty(options.reconstructSampling)
        newSampling = ita_sph_sampling_equiangular(37,72,'theta_type','[]');
    else
        newSampling = itaSamplingSph(options.reconstructSampling);
    end
  
    newSampling.nmax = options.nmax;
    reconstructedData = newSampling.Y*shCoeffs;

    results = data;
    results.freqData = reconstructedData.';
    results.channelCoordinates = newSampling;
    
    %% back to center
    results = ita_HRTFarc_pp_moveFullDataSet(results,newSampling,options,shift,2);    
end

function [time] = getTimeOffsetFromFrequency(frequency,options)
    sweepRate = options.sweepRate;
    f0 = options.freqRange(1); % this is not 100 % correct
    % this does not apply for ita-sweeps check diss dietrich
%     time = log(frequency/sweepOpts.f0)/log(sweepOpts.k);

    L = log2(exp(1))/sweepRate;
    
    time = log(frequency/f0)*L;
    
end