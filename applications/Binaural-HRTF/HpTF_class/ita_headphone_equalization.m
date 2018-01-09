function output = ita_headphone_equalization(HPTF,type)


% <ITA-Toolbox>
% This file is part of the application HRTF_Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

output = HPTF(1,1);
output.channelUnits(:) = {''};
for cdx = 1:HPTF(1,1).nChannels
    
    hp = merge(HPTF.ch(cdx));
    
    switch type
        case 'mean'
            hp.freqData = mean(abs(hp.freqData),2);
        case 'max'
            hp.freqData = max(abs(hp.freqData),[],2);
        case 'mSTD'
            hp.freqData = mean(abs(hp.freqData),2) + 2*std(abs(hp.freqData),0,2);
        otherwise
            error('Unknown type');
    end
    
    %% Short Filter with no correction for low freqs and minimun phase
    R = hp;
    % R = ke4;
    n = R.nSamples;
    aux = max(abs(R.freqData),[],2);
    
    % find first maximum and truncate low freq correction at this point
    idx1 = find(R.freqVector > 100,1,'first');
    idx2 = find(R.freqVector < 300,1,'last');
    d_aux = diff(aux(idx1:idx2));
    idx = find(diff(sign(d_aux)) ~= 0,1,'first');
    aux(1:idx1+idx+1) = aux(idx1+idx+2);
    aux(aux==0) = rand(1)*eps;
    R.freqData = aux;
    
    % do smoothing
    R = ita_smooth(R,'LogFreqOctave1',1/6,'Abs');
    R = ita_invert_spk_regularization(R,[0 18000],'beta',.01);
    
    % minimum phase
    R = ita_time_shift(R,n/2,'samples');
    R = ita_extend_dat(R,R.nSamples*2);
    R = ita_time_shift(R,-n/2,'samples');
    N = 2*n;
    aux = R.timeData;
    R.timeData = ifft(log(abs(fft(aux))));
    T = 2^16;
    if T >= N-3
        T = N-3;
    end
    if rem(T-1,2) == 1
        T = T+1;
    end
    u = [1; 2*ones((N-T-1)/2,1); cos(pi*(0:T-1)'/T)+1; zeros((N-T-1)/2,1)]; %pode colocar uma transicao mais suave no meio.
    R.timeData = R.timeData.*u;
    H = R;
    H.timeData = ifft(exp(fft(R.timeData)),'symmetric');
    H = ita_time_crop(H,[1 n],'samples');
    % H = ita_time_window(H,[2^12 2^13],'samples');
    % H = ita_time_window(H,[0.1 0.2],'time','dc',true);
    H = ita_time_window(H,[2^9 2^10],'samples');
    % It is necessary to correct the overall level of the filter
    % we can either guaranty no gain
    % H = H/max(abs(H.freqData));
    
%     spl = ita_spk2level(H,3,'averaged');
%     H = H/mean(spl.data);

    output.freqData(:,cdx) = H.freqData;
end

% or guaranty that the average level of the signal is not altered
% this also means that the overall loudness of the signal will not be
% considerably altered.
output = output/mean(output.rms);