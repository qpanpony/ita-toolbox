function [CTC,Horig] = ita_CTC_filter(varargin)
%ITA_CTC_FILTER - Generate Cross Cancellation Filters
%
%  This function receives a set of HRTF or HRIR. The input must be a set of
%  transfer functions followed by the type of CTC filter realization.
%
%  Possible filter realizations:
%  ZPK: approximation by poles and common zeros e then generation of CTC
%  Time: Time Domain LMS
%  Minimax_time: Time Domain Minimax
%  Minimax_freq: Frequeny Domain Minimax
%  Takeushi: Frequency independent filter
%  Wiener:  Wiener Filter approach (causa filter)
%  Wiener_reg: Causal Wiener Filter with frequency regularization
%  SVD: decomposition of transfer matrix in SVD and control of SV inversion
%  Weighted: For many loudspeakers, resulting in a overdetermined system, we can provide weigths to adequate speakers. For a more smooth filter transition.
%  Truncated: Truncation of sum series. (Not causal)
%  Regularized: Frequency regularization (Not causal)
%
%
%  The output is a set of CTC filters to be used in a crosstalk
%  cancellation network and the original transfer functions packed in a
%  multi-intance itaAudio object.
%
%  Related functions: channelSeparation, filterCTC
%
% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  29-Sep-2009
%$ENDHELP$
%% Get ITA Toolbox preferences

% <ITA-Toolbox>
% This file is part of the application Binaural for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
warning('No longer supported version that is reported to be bugged, consider using ita_ctc_filter_regularized.')
if nargin < 2
    error('CTC:InputArguments','Man! We need at least two loudspeakers for CTC! The input variable must be itaAudio objects.');
end

for idx = 1:nargin
    if isa(varargin{idx},'itaAudio')
        input = varargin{idx};
        input.signalType = 'energy';
        if input.nChannels ~=2
            error('CTC:InputArguments','We need two channels! First for left ear, second for right ear.')
        end
        H(:,idx) = [input.ch(1); input.ch(2)];
        jdx = idx;
    end
end

Horig = H;
[rows,cols] = size(H);
CTC = itaAudio(cols,rows);


% options
opts.alpha           = 1e-10; % intern regularization for the wiener case
opts.beta            = 0.001; % regularization parameter
opts.delay           = 400; % required delay to allow for causal filter
opts.winLim          = [0.7 0.85]; % limits for windowing (suppress artifacts at the end of HRIR caused by time shifting)
opts.filterType      = 'reg'; %
opts.warping         = 0;
opts.smoothing       = 0;
opts.smoothingType   = 'lifter';
opts.smoothingWinLim = [.4 .5]; % suppress artefacts of smoothed HRIR
opts.truncationOrder = 2; % for Lentz filter type
opts.lifterWinLength = 32;
opts.lifterWinRate   = 0.3;
opts.filterLength    = H(1).nSamples; %define filter length
opts.threshold       = 20; % threshold for ita_start_IR()
opts = ita_parse_arguments(opts, varargin(jdx+1:end));


%% Compensate for acoustic opts.delay
% The acoustic path should not be compensated for. Thus the general delay
% is extracted, leaving only the relative delay between paths, that is
% important for the CTC.
% fundalewicz: Comment out for comparison with SPAX
ind = zeros(size(H));
for idx = 1:numel(H)
    ind(idx) = ita_start_IR(H(idx),'threshold',opts.threshold);
end

IND = min(ind(:))-1;
for idx = 1:numel(H)
    H(idx) = ita_time_shift(H(idx),-ind(idx),'samples');
    H(idx) = ita_time_window(H(idx),opts.winLim*H(idx).trackLength,'time');
    H(idx) = ita_time_shift(H(idx),ind(idx)-IND,'samples');
end
Horig = H;

%% Warping
% regular warping filter from WarpTB
if opts.warping
    lambda = barkwarp(H(idx).samplingRate);
    for idx = 1:numel(H)
        H(idx).timeData = warp_impres(H(idx).timeData,lambda).';
    end
    
    %     % Log weighting
    %     freq = H(1,1).freqVector;
    %     freq_new = [freq(1) logspace(log10(300),log10(20000),round(length(freq)/4)-2) freq(end)]';
    %
    %     for idx = 1:size(H,1)
    %         for jdx = 1:size(H,2)
    %             H(idx,jdx).freqData = interp1(freq,H(idx,jdx).freqData,freq_new,'spline');
    %         end
    %     end
end


%% Smooth HRTFs
if opts.smoothing
    switch lower(opts.smoothingType)
        
        case 'balasz'
            % according to Balasz Bank filter matching algorithm
            H = smooth_balasz(H);
            
        case 'gammatone'
            % according to Breebards Gamatone Smoothing algorithm
            H = ita_smooth(H,'gammatoneSmooth',1,'abs+gopts.delay');
            
        case 'lifter'
            % according to Kulkarni&Colburn lifting operation
            H = ita_lifter(H,opts.lifterWinLength,opts.lifterWinRate);
            
        case 'regular'
            % With ITA-Toolbox standard smoothing
            for idx = 1:numel(H)
                H(idx) = ita_smooth( H(idx),'LogFreqOctave1',1/12,'abs');
                H(idx) = ita_smooth_notches( H(idx),'bandwidth',1);
            end
    end
    % suppress smoothing artefacts at least at the end of HRIR
    H = ita_time_window(H,opts.smoothingWinLim*H(idx).trackLength,'time');
end
Horig = H;
%% Make minimum phase
% IND = min(ind(:));
% for idx = 1:size(H,1)
%     for jdx = 1:size(H,2)
%         H(idx,jdx) = ita_time_shift(H(idx,jdx),-(ind(idx,jdx)-IND),'samples');
%         H(idx,jdx) = ita_time_window(H(idx,jdx),opts.winLim*H(idx,jdx).trackLength.value,'time');
%         N = H(idx,jdx).nSamples;
%         H(idx,jdx) = ita_extend_dat(H(idx,jdx),4800,'forceSamples');
%         H(idx,jdx) = ita_uncle_hilbert(H(idx,jdx));
%         H(idx,jdx) = ita_extract_dat(H(idx,jdx),N,'forceSamples');
%         H(idx,jdx) = ita_time_window(H(idx,jdx),opts.winLim*H(idx,jdx).trackLength.value,'time');
%         H(idx,jdx) = ita_time_shift(H(idx,jdx),ind(idx,jdx)-IND,'samples');
%     end
% end
%% Make minimum magnitude
% for idx = 1:size(H,1)
%     for jdx = 1:size(H,2)
%         H(idx,jdx) = ita_minimumamplitude (H(idx,jdx));
%     end
% end



%% CTC filters generation
switch lower(opts.filterType)
    
    case {'zpk'}
        aux = merge(H);
        h = aux.freqAmp.';
        
        w = 2*pi*aux.freqVector.';
        s = 1i*w;   %jw
        
        weight= (1./w);
        if w(1) == 0
            weight(1) = 2*weight(2) - weight(3);
        end
        % weight = ones(size(f));
        
        opts.relax=1;      %Use vector fitting with relaxed non-triviality constraint
        opts.stable=1;     %Enforce stable poles
        opts.asymp=3;      %Include only D in fitting
        opts.skip_pole=0;  %Do NOT skip pole identification
        opts.skip_res=0;   %DO skip identification of residues (C,D,E)
        opts.cmplx_ss=0;   %Create real-only state space model
        
        opts.spy1=0;       %No plotting for first stage of vector fitting
        opts.spy2=1;       %Create magnitude plot for fitting of f(s)
        opts.logx=1;       %Use linear abscissa axis
        opts.logy=1;       %Use logarithmic ordinate axis
        opts.errplot=1;    %Include deviation in magnitude plot
        opts.phaseplot=1;  %Do NOT produce plot of phase angle
        opts.legend=1;     %Include legends in plots
        opts.ortho = 0;
        
        
        Niter=15;
        N=10; %Order of approximation
        
        P = .9*exp(2i*pi*(0:N-1)/N);
        P = cplxpair(P);
        % Real starting poles :
        %poles=-linspace(w(1),w(Ns),N);
        
        rmserr = zeros(1,Niter);
        
        for iter=1:Niter
            if iter==Niter, opts.skip_res=0; end
            
            [SER,P,rmserr(iter),fit] = vectfit3(h,s,P,weight,opts);
        end
        
        %TO DO: Still not working. Check what is wrong!
        
        for idx = 1:size(h,1)
            Z(idx,:) = cplxpair(eig(SER.A - SER.B*SER.C(idx,:))/(SER.D(idx)+10*eps));
        end
        
        D1 = [Z(1,:),Z(4,:)];
        D2 = [Z(2,:),Z(3,:)];
        
        n(1,:) = [Z(4,:),P];
        n(2,:) = -[Z(2,:),P];
        n(3,:) = -[Z(3,:),P];
        n(4,:) = [Z(1,:),P];
        
        clear N
        for idx = 1:size(n,1)
            N(idx,:) = freqs(poly(n(idx,:)),1,w);
        end
        Q1 = freqs(poly(D1),1,w);
        Q2 = freqs(poly(D2),1,w);
        
        h = bsxfun(@rdivide,N,(Q1-Q2));
        
        
    case {'time'}
        M = opts.filterLength;
        HH = [];
        for idx = 1:rows
            hh = [];
            for jdx = 1:cols
                hh = [hh convmtx(H(idx,jdx).timeData,M)];
            end
            HH = [HH; hh];
        end
        
        mn1 = size(HH,1);
        
        e = zeros(mn1,2); e(1+opts.delay,1) = 1; e(mn1/2+1+opts.delay,2) = 1;
        
        %         c = HH\e;
        c = (HH'*HH + opts.beta*eye(size(HH,2)))\HH'*e;
        
        for idx = 1:rows
            for jdx = 1:cols
                CTC(jdx,idx).timeData = c((jdx-1)*M+(1:M),idx);
                CTC(jdx,idx).signalType = 'energy';
                CTC(jdx,idx).samplingRate = H(idx,jdx).samplingRate;
            end
        end
        
    case {'minimax_time'}
        M = opts.filterLength; %length of CTC filters
        HH = [];
        for idx = 1:rows
            hh = [];
            for jdx = 1:cols
                hh = [hh convmtx(H(idx,jdx).timeData,M)];
            end
            HH = [HH; hh];
        end
        
        mn1 = size(HH,1);
        e = zeros(mn1,2); e(1+opts.delay,1) = 1; e(mn1/2+1+opts.delay,2) = 1;
        C = zeros(cols*M,rows);
        
        for nCh = 1:size(e,2)
            cvx_begin
            variable c(cols*M,1)
            minimize( norm(e(:,nCh) - HH*c,inf) )
            cvx_end
            C(:,nCh) = c;
        end
        
        for idx = 1:rows
            for jdx = 1:cols
                CTC(jdx,idx).timeData = C((jdx-1)*M+(1:M),idx);
                CTC(jdx,idx).signalType = 'energy';
                CTC(jdx,idx).samplingRate = H(idx,jdx).samplingRate;
            end
        end
        
    case {'sparse_freq'}    %equivalent to Optimal Source Distribution
        
        aux = merge(H);
        nBins = aux.nBins;
        h = reshape(aux.freqAmp.',rows,cols,nBins);
        
        I = eye(rows);
        C = zeros(cols,rows,aux.nBins);
        
        for iFreq = 1:aux.nBins
            cvx_begin
            variable c(cols,rows) complex
            minimize( norm(c(:,1),1) + norm(c(:,2),1) );
            
            subject to
            I == h(:,:,iFreq)*c;
            
            cvx_end
            C(:,:,iFreq) = c;
        end
        
        for idx = 1:rows
            for jdx = 1:cols
                CTC(jdx,idx).freqAmp = squeeze(C(jdx,idx,:));
                CTC(jdx,idx).signalType = 'energy';
                CTC(jdx,idx).samplingRate = H(idx,jdx).samplingRate;
            end
        end
        
    case {'takeuchi'}
        a = size(H,2);
        if a ~=2
            error('CTC:Takeuchi','This kind of filter only works for two loudspeakers.')
        end
        CTC = H;
        CTC(1,1).freqData(:) = 1;
        CTC(2,1).freqData(:) = 1i;
        CTC(1,2).freqData(:) = 1i;
        CTC(2,2).freqData(:) = 1;
        
        
    case {'wiener'}
        
        %         ita_matrixfun
        
        aux = merge(H);
        nBins = aux.nBins;
        h = reshape(aux.freqAmp.',rows,cols,nBins);
        
        N = zeros(cols,rows,nBins);
        detD = zeros(nBins,1);
        for idx = 1:aux.nBins
            D = h(:,:,idx)*h(:,:,idx)' + opts.beta*eye(rows);
            detD(idx) = det(D);
            N(:,:,idx) = h(:,:,idx)'*adj(D);
        end
        
        aux.freqAmp = real(detD);
        [Aplus,Aminus] = ita_wiener_hopf_factorization(aux);
        Aplus = 1/Aplus;
        Aminus = 1/Aminus;
        
        for idx = 1:cols
            for jdx = 1:rows
                aux.freqAmp = squeeze(N(idx,jdx,:));
                aux = aux*Aminus;
                aux = ita_time_shift(aux,opts.delay,'samples');
                %aux = ita_time_window(aux,round(opts.winLim*aux.nSamples),'samples');
                aux = ita_time_window(aux,round([.45 .5]*aux.nSamples),'samples');
                CTC(idx,jdx) = aux*Aplus;
            end
        end
        
        
    case {'wiener_cpp'}
        
        %         ita_matrixfun
        
        aux = merge(H);
        nBins = aux.nBins;
        
        %         N = zeros(cols,rows,nBins);
        %         detD = zeros(nBins,1);
        %         h = reshape(aux.freqAmp.',rows,cols,nBins);
        %         for idx = 1:aux.nBins
        %             D = h(:,:,idx)*h(:,:,idx)' + opts.beta*eye(rows);
        %             detD(idx) = det(D);
        %             N(:,:,idx)= h(:,:,idx)'*adj(D);
        %         end
        
        h = merge(H);
        h = ita_extend_dat(h,1024);
        f = h.nBins;
        h = h.freqData;
        [hm,hn] = size(H);
        c = zeros(hn,hm,f);
        
        
        %%% D = h(:,:,idx)*h(:,:,idx)' + opts.beta*eye(rows);
        % Mem:
        % hm = 2 (L,R)
        % h = zeros(f,hm*hn);
        hConj = conj(h); % (f,hm*hn) complex
        hhProd = zeros(f,4); % complex
        hhAdj = zeros(f,4); % complex
        hhAux = zeros(1,f); % complex
        hhAux2 = zeros(1,f); % complex
        tAux = zeros(1,f);
        tAux2 = zeros(1,f);
        
        % H*H', IN: h [fx(2*n)] , OUT: hhProd [fx4]
        for i=1:hn
            % (1,1):(L*L')
            hhAux = h(:,2*i-1);
            hhAux = hhAux .* hConj(:,2*i-1);
            hhProd(:,1) = hhProd(:,1) + hhAux;
            % (1,2):(L*R')
            hhAux = h(:,2*i-1);
            hhAux = hhAux .* hConj(:,2*i);
            hhProd(:,2) = hhProd(:,2) + hhAux;
            % (2,1):(R*L')
            hhAux = h(:,2*i);
            hhAux = hhAux .* hConj(:,2*i-1);
            hhProd(:,3) = hhProd(:,3) + hhAux;
            % (2,2):(R*R')
            hhAux = h(:,2*i);
            hhAux = hhAux .* hConj(:,2*i);
            hhProd(:,4) = hhProd(:,4) + hhAux;
        end
        
        % + beta*I, IN: hhProd [fx{1,4}], OUT: hhProd [fx{1,4}]
        hhProd(:,1) =  hhProd(:,1) + opts.beta*ones(f,1);
        hhProd(:,4) =  hhProd(:,4) + opts.beta*ones(f,1);
        
        %%% N(:,:,idx)= h(:,:,idx)'*adj(D);
        % adj(a b; c d) = (d -b; -c a)
        hhAdj(:,[1,4]) = hhProd(:,[4,1]);
        hhAdj(:,[2,3]) = -hhProd(:,[2,3]);
        
        % H' * adj, IN: hConj [fx(2*n)], hhProd [fx(2x2)]
        for i=1:hn
            hhAux = hConj(:,2*i-1);
            hhAux = hhAux .* hhAdj(:,1);
            c(i,1,:) = hConj(:,2*i);
            c(i,1,:) = squeeze(c(i,1,:)) .* hhAdj(:,3);
            c(i,1,:) = squeeze(c(i,1,:)) + hhAux;
            hhAux = hConj(:,2*i-1);
            hhAux = hhAux .* hhAdj(:,2);
            c(i,2,:) = hConj(:,2*i);
            c(i,2,:) = squeeze(c(i,2,:)) .* hhAdj(:,4);
            c(i,2,:) = squeeze(c(i,2,:)) + hhAux;
        end
        
        %%% det(D); = det(HH*+betaI)
        % (a*d - b*c)
        hhAux = hhProd(:,1);
        hhAux = hhAux.*hhProd(:,4);
        hhAux2 = hhProd(:,2);
        hhAux2 = hhAux2.*hhProd(:,3);
        hhAux = hhAux - hhAux2;
        
        %%%
        %aux.freqAmp = real(hhAux);
        %[Aplus,Aminus] = ita_wiener_hopf_factorization(aux);
        
        % Enter cepstral domain
        % origFreq_exp = log(abs(origFreq))+1i*angle(origFreq(:));
        %%  log(abs(real(hhAux))) same as log(hhAux), as hhAux real
        hhAux = log(abs(hhAux));
        
        % IFFT
        % origCeps = ifft(origFreq_exp);
        aux.freqAmp = hhAux
        tAux = aux.timeData;
        
        % Aplus
        % plusCeps(2:M,:) = origCeps(2:M,:);
        % plusCeps(1,:) = origCeps(1,:)/2;
        tAux2 = zeros(size(tAux));
        tAux2(1:ceil(size(tAux,1)/2)) = tAux(1:ceil(size(tAux,1)/2));
        tAux2(1) = tAux2(1)/2;
        
        % Aminus
        % minusCeps(end-M+2:end,:) = origCeps(end-M+2:end,:);
        % minusCeps(1,:) = origCeps(1,:)/2;
        tAux(2:ceil(size(tAux,1)/2) -1) = zeros(ceil(size(tAux,1)/2) -2, 1);
        tAux(1) = tAux(1)/2;
        
        % Correction for overlapping part in middle for even number of
        % samples
        % if rem(N,2) == 0
        %     plusCeps(M+1,:) = origCeps(M+1,:)/2;
        %     minusCeps(M+1,:) = origCeps(M+1,:)/2;
        % end
        if rem(size(tAux,1),2) == 0
            tAux2(ceil(size(tAux,1)/2)) = tAux2(ceil(size(tAux,1)/2)) /2;
            tAux(ceil(size(tAux,1)/2)) = tAux(ceil(size(tAux,1)/2)) /2;
        end
        
        % Leave cepstral domain
        % FFT
        % plusFreq_exp = fft(plusCeps);
        % minusFreq_exp = fft(minusCeps);
        aux.timeData = tAux;
        hhAux = aux.freqData;
        aux.timeData = tAux2;
        hhAux2 = aux.freqData;
        
        % Exponential
        % plusFreq = exp(plusFreq_exp);
        % minusFreq = exp(minusFreq_exp);
        hhAux = exp(hhAux);
        hhAux2 = exp(hhAux2);
        
        % Aplus = 1/Aplus;
        % Aminus = 1/Aminus;
        
        for idx = 1:cols
            for jdx = 1:rows
                % det(HH*) / Aminus
                % aux.freqAmp = squeeze(N(idx,jdx,:));
                % aux = aux*Aminus;
                c(idx,jdx,:) = squeeze(c(idx,jdx,:))./hhAux;
                aux.freqAmp = squeeze(c(idx,jdx,:));
                
                % Time shift
                % aux = ita_time_shift(aux,opts.delay,'samples');
                tAux = aux.timeData;
                tAux = circshift(tAux,opts.delay);
                
                % Extract causal part (first half)
                %aux = ita_time_window(aux,round(opts.winLim*aux.nSamples),'samples');
                % aux = ita_time_window(aux,round([.45 .5]*aux.nSamples),'samples');
                tAux(round(.5*size(tAux,1)):end) = 0;
                
                % <causalPart> / Aplus
                aux.timeData = tAux;
                c(idx,jdx,:) = aux.freqData;
                c(idx,jdx,:) = squeeze(c(idx,jdx,:))./hhAux2;
                
                aux.freqData = squeeze(c(idx,jdx,:));
                CTC(idx,jdx) = itaAudio(aux.timeData,44100,'time');
            end
        end
        
    case {'wiener_reg'}
        
        %         ita_matrixfun
        
        aux = merge(H);
        nBins = aux.nBins;
        h = reshape(aux.freqAmp.',rows,cols,nBins);
        
        n = zeros(rows,rows,nBins);
        N = zeros(cols,rows,nBins);
        detD = zeros(nBins,1);
        detd = zeros(nBins,1);
        
        for idx = 1:aux.nBins
            d = h(:,:,idx)*h(:,:,idx)';
            D = d + opts.beta*eye(rows);
            detd(idx) = det(d);
            detD(idx) = det(D);
            n(:,:,idx) = adj(D);
            N(:,:,idx) = h(:,:,idx)'*n(:,:,idx);
        end
        %         aux.freqAmp = reshape(N,rows*cols,nBins).';
        A = aux;
        A.freqAmp = real(detd)./real(detD);
        Am = ita_minimumphase(A);
        %         Am = A;
        %         aux.freqAmp = real(detD);
        DET = aux;
        DET.freqAmp = real(detd);
        %         [Aplus,Aminus] = ita_wiener_hopf_factorization(DET,'invert');
        [Aplus,Aminus] = ita_wiener_hopf_factorization(DET);
        %
        %          Aplus = 1/(Aplus);
        Aminus = 1/(Aminus);
        %         Aplus = conj(Aplus)/(Aplus*conj(Aplus) + sqrt(opts.beta));
        %         Aminus = conj(Aminus)/(Aminus*conj(Aminus) + sqrt(opts.beta));
        %         Aplus = ita_invert_spk_regularization(Aplus,[300 16000],'beta',sqrt(opts.beta));
        %         Aminus = ita_invert_spk_regularization(Aminus,[300 16000],'beta',sqrt(opts.beta));
        %         Aplus = ita_invert_spk_minphase_regularization(Aplus,[200 16000],'beta_pass',opts.alpha,'beta_stop',opts.alpha);
        %         Aminus = ita_invert_spk_minphase_regularization(Aminus,[200 16000],'beta_pass',opts.alpha,'beta_stop',opts.alpha);
        %         Aplus = ita_invert_spk_minphase_regularization(Aplus,[300 16000],'beta_pass',sqrt(opts.beta),'beta_stop',sqrt(opts.alpha));
        %         Aminus = ita_invert_spk_minphase_regularization(Aminus,[300 16000],'beta_pass',sqrt(opts.beta),'beta_stop',sqrt(opts.alpha));
        
        for idx = 1:cols
            for jdx = 1:rows
                aux.freqAmp = squeeze(N(idx,jdx,:)) ;
                aux = aux*Aminus;
                aux = ita_time_shift(aux,opts.delay,'samples');
                %aux = ita_time_window(aux,round(opts.winLim*aux.nSamples),'samples');
                aux = ita_time_window(aux,round([.45 .5]*aux.nSamples),'samples');
                CTC(idx,jdx) = aux/(Aplus/Am);
            end
        end
        
        %                 aux = merge(H);
        %         aux1 = merge(CTC);
        %         nBins = aux.nBins;
        %         h = reshape(aux.freqAmp.',rows,cols,nBins);
        %         ctc = reshape(aux1.freqAmp.',rows,cols,nBins);
        %         for idx = 1:aux.nBins
        %             C_(idx) = cond(ctc(:,:,idx));
        %             C(idx) = cond(h(:,:,idx));
        %
        %         end
        %         plot(20*log10(abs([C;C_]')))
        
        
        
    case {'wiener_reg_cpp'}
        
        %         ita_matrixfun
        
        aux = merge(H);
        nBins = aux.nBins;
        
        %         N = zeros(cols,rows,nBins);
        %         detD = zeros(nBins,1);
        %         h = reshape(aux.freqAmp.',rows,cols,nBins);
        %         for idx = 1:aux.nBins
        %             D = h(:,:,idx)*h(:,:,idx)' + opts.beta*eye(rows);
        %             detD(idx) = det(D);
        %             N(:,:,idx)= h(:,:,idx)'*adj(D);
        %         end
        
        h = merge(H);
        f = h.nBins;
        h = h.freqData;
        [hm,hn] = size(H);
        c = zeros(hn,hm,f);
        
        
        %%% D = h(:,:,idx)*h(:,:,idx)' + opts.beta*eye(rows);
        % Mem:
        % hm = 2 (L,R)
        % h = zeros(f,hm*hn);
        hConj = conj(h); % (f,hm*hn) complex
        hhProd = zeros(f,4); % complex
        hhAdj = zeros(f,4); % complex
        hhMinPh = zeros(f,4); % complex
        hhAux = zeros(1,f); % complex
        hhAux2 = zeros(1,f); % complex
        hhAux3 = zeros(1,f); % complex
        hhAux4 = zeros(1,f); % complex
        tAux = zeros(1,f);
        tAux2 = zeros(1,f);
        
        % H*H', IN: h [fx(2*n)] , OUT: hhProd [fx4]
        for i=1:hn
            % (1,1):(L*L')
            hhAux = h(:,2*i-1);
            hhAux = hhAux .* hConj(:,2*i-1);
            hhProd(:,1) = hhProd(:,1) + hhAux;
            % (1,2):(L*R')
            hhAux = h(:,2*i-1);
            hhAux = hhAux .* hConj(:,2*i);
            hhProd(:,2) = hhProd(:,2) + hhAux;
            % (2,1):(R*L')
            hhAux = h(:,2*i);
            hhAux = hhAux .* hConj(:,2*i-1);
            hhProd(:,3) = hhProd(:,3) + hhAux;
            % (2,2):(R*R')
            hhAux = h(:,2*i);
            hhAux = hhAux .* hConj(:,2*i);
            hhProd(:,4) = hhProd(:,4) + hhAux;
        end
        
        %%% det(d);
        % (a*d - b*c)
        hhAux = hhProd(:,1);
        hhAux = hhAux.*hhProd(:,4);
        hhAux2 = hhProd(:,2);
        hhAux2 = hhAux2.*hhProd(:,3);
        hhAux3 = hhAux - hhAux2;
        
        % + beta*I, IN: hhProd [fx{1,4}], OUT: hhProd [fx{1,4}]
        hhProd(:,1) =  hhProd(:,1) + opts.beta*ones(f,1);
        hhProd(:,4) =  hhProd(:,4) + opts.beta*ones(f,1);
        
        %%% N(:,:,idx)= h(:,:,idx)'*adj(D);
        % adj(a b; c d) = (d -b; -c a)
        hhAdj(:,[1,4]) = hhProd(:,[4,1]);
        hhAdj(:,[2,3]) = -hhProd(:,[2,3]);
        
        % H' * adj, IN: hConj [fx(2*n)], hhProd [fx(2x2)]
        for i=1:hn
            hhAux = hConj(:,2*i-1);
            hhAux = hhAux .* hhAdj(:,1);
            c(i,1,:) = hConj(:,2*i);
            c(i,1,:) = squeeze(c(i,1,:)) .* hhAdj(:,3);
            c(i,1,:) = squeeze(c(i,1,:)) + hhAux;
            hhAux = hConj(:,2*i-1);
            hhAux = hhAux .* hhAdj(:,2);
            c(i,2,:) = hConj(:,2*i);
            c(i,2,:) = squeeze(c(i,2,:)) .* hhAdj(:,4);
            c(i,2,:) = squeeze(c(i,2,:)) + hhAux;
        end
        
        %%% det(D);
        % (a*d - b*c)
        hhAux = hhProd(:,1);
        hhAux = hhAux.*hhProd(:,4);
        hhAux2 = hhProd(:,2);
        hhAux2 = hhAux2.*hhProd(:,3);
        hhAux4 = hhAux - hhAux2;
        
        %         A = aux;
        %         A.freqAmp = real(hhMinPh)./real(hhAux3);
        %         Am = ita_minimumphase(A);
        
        % A.freqAmp = real(detd)./real(detD);
        hhMinPh = hhAux3 ./ hhAux4;
        
        %%%
        % Am = ita_minimumphase(A);
        
        % Enter cepstral domain
        % origFreq_exp = log(abs(origFreq))+1i*angle(origFreq(:));
        %%  log(abs(real(hhAux))) same as log(hhAux), as hhAux real
        hhAux = log(hhMinPh);
        
        % IFFT
        % origCeps = ifft(origFreq_exp);
        aux.freqAmp = hhAux
        tAux = aux.timeData;
        
        % |1|2222222222|<1,if even>|0000000000|
        tAux2 = zeros(size(tAux));
        tAux2(1:ceil(size(tAux,1)/2)) = tAux(1:ceil(size(tAux,1)/2)) *2;
        tAux2(1) = tAux2(1)/2;
        
        % Correction for overlapping part in middle for even number of
        % samples
        if rem(size(tAux,1),2) == 0
            tAux2(ceil(size(tAux,1)/2)) = tAux2(ceil(size(tAux,1)/2)) /2;
        end
        
        % Leave cepstral domain
        % FFT
        aux.timeData = tAux2;
        hhAux = aux.freqData;
        
        % Exponential
        hhMinPh = exp(hhAux);
        
        %% Call ita Minphase
        %         hhMinPh = ita_minimumphase(itaAudio(hhMinPh,44100,'freq'));
        %         hhMinPh = hhMinPh.freqData;
        
        
        
        
        %%%
        %aux.freqAmp = real(hhAux);
        %[Aplus,Aminus] = ita_wiener_hopf_factorization(aux);
        
        % Enter cepstral domain
        % origFreq_exp = log(abs(origFreq))+1i*angle(origFreq(:));
        %%  log(abs(real(hhAux))) same as log(hhAux), as hhAux real
        hhAux = log(abs(hhAux3));
        
        % IFFT
        % origCeps = ifft(origFreq_exp);
        aux.freqAmp = hhAux
        tAux = aux.timeData;
        
        % Aplus
        % plusCeps(2:M,:) = origCeps(2:M,:);
        % plusCeps(1,:) = origCeps(1,:)/2;
        tAux2 = zeros(size(tAux));
        tAux2(1:ceil(size(tAux,1)/2)) = tAux(1:ceil(size(tAux,1)/2));
        tAux2(1) = tAux2(1)/2;
        
        % Aminus
        % minusCeps(end-M+2:end,:) = origCeps(end-M+2:end,:);
        % minusCeps(1,:) = origCeps(1,:)/2;
        tAux(2:ceil(size(tAux,1)/2) -1) = zeros(ceil(size(tAux,1)/2)-2, 1);
        tAux(1) = tAux(1)/2;
        
        
        
        % Correction for overlapping part in middle for even number of
        % samples
        % if rem(N,2) == 0
        %     plusCeps(M+1,:) = origCeps(M+1,:)/2;
        %     minusCeps(M+1,:) = origCeps(M+1,:)/2;
        % end
        if rem(size(tAux,1),2) == 0
            tAux2(ceil(size(tAux,1)/2)) = tAux2(ceil(size(tAux,1)/2)) /2;
            tAux(ceil(size(tAux,1)/2)) = tAux(ceil(size(tAux,1)/2)) /2;
        end
        
        % Leave cepstral domain
        % FFT
        % plusFreq_exp = fft(plusCeps);
        % minusFreq_exp = fft(minusCeps);
        aux.timeData = tAux;
        hhAux = aux.freqData;
        aux.timeData = tAux2;
        hhAux2 = aux.freqData;
        
        % Exponential
        % plusFreq = exp(plusFreq_exp);
        % minusFreq = exp(minusFreq_exp);
        hhAux = exp(hhAux);
        hhAux2 = exp(hhAux2);
        
        % Aplus = 1/Aplus;
        % Aminus = 1/Aminus;
        
        for idx = 1:cols
            for jdx = 1:rows
                % det(HH*) / Aminus
                % aux.freqAmp = squeeze(N(idx,jdx,:));
                % aux = aux*Aminus;
                c(idx,jdx,:) = squeeze(c(idx,jdx,:))./hhAux;
                aux.freqAmp = squeeze(c(idx,jdx,:));
                
                % Time shift
                aux = ita_time_shift(aux,opts.delay,'samples');
                %tAux = aux.timeData;
                %tAux = circshift(tAux,opts.delay);
                
                % Extract causal part (first half)
                %aux = ita_time_window(aux,round(opts.winLim*aux.nSamples),'samples');
                aux = ita_time_window(aux,round([.45 .5]*aux.nSamples),'samples');
                %tAux(round(.5*size(tAux,1)):end) = 0;
                
                % <causalPart> / Aplus * Aminphase
                %aux.timeData = tAux;
                c(idx,jdx,:) = aux.freqData;
                %c(idx,jdx,:) = squeeze(c(idx,jdx,:)) ./(hhAux2 ./ Am.freqData);
                c(idx,jdx,:) = squeeze(c(idx,jdx,:)) ./hhAux2 .* hhMinPh;
                
                aux.freqData = squeeze(c(idx,jdx,:));
                CTC(idx,jdx) = itaAudio(aux.timeData,44100,'time');
            end
        end
        
    case 'svd'
        aux = merge(H);
        nBins = aux.nBins;
        h = reshape(aux.freqAmp.',rows,cols,nBins);
        
        N = zeros(cols,rows,nBins);
        
        for idx = 1:aux.nBins
            [s,v,d] = svd(h(:,:,idx));
            V = zeros(size(v));
            V(v > beta) = 1./v(v > beta);
            N(:,:,idx) = d*V.'*s';
        end
        
        for idx = 1:cols
            for jdx = 1:rows
                aux.freqAmp = squeeze(N(idx,jdx,:)) ;
                CTC(idx,jdx) = aux;
            end
        end
        
    case 'weighted'
        
        aux = merge(H);
        nBins = aux.nBins;
        h = reshape(aux.freqAmp.',rows,cols,nBins);
        
        N = zeros(cols,rows,nBins);
        
        % Weights: zero will take loudspeaker out of solution, the higher
        % the value, the more important is this loudspeaker to the
        % solution.
        %         W = tukeywin(cols+1,0.5); W(end) = [];
        %         W = diag(W);
        
        %         r = logspace(-15,0,aux.nBins-1);
        %         r = [0 r];
        W = diag([1 1 1 0]);
        for idx = 1:aux.nBins
            %             W = tukeywin(cols+1,r(idx)); W(end) = [];
            %             W = diag(W);
            
            H = h(:,:,idx);
            N(:,:,idx) = (W*H')/(H*W*H' + opts.beta*eye(rows));
        end
        
        for idx = 1:cols
            for jdx = 1:rows
                aux.freqAmp = squeeze(N(idx,jdx,:)) ;
                CTC(idx,jdx) = aux;
            end
        end
        
    case {'truncated','iterative'}
        a = size(H,2);
        if a ~=2
            error('CTC:Truncated','This kind of filter only works for two loudspeakers.')
        end
        order = opts.truncationOrder;
        K = H(1,2)*H(2,1)*ita_invert_spk_regularization(H(1,1)*H(2,2),[200 16000]);
        KPow = K;
        KPow.timeData = zeros(KPow.nSamples,1);
        KPow.timeData(1,1) = 1;
        
        for n=1:order
            KPow = KPow*K + 1;
        end
        
        CTC(1,1) = KPow * ita_invert_spk_regularization(H(1,1),[1000 1000],'beta',opts.beta);
        CTC(2,2) = KPow * ita_invert_spk_regularization(H(2,2),[1000 1000],'beta',opts.beta);
        CTC(1,2) = -CTC(1,1) * H(1,2) * ita_invert_spk_regularization(H(2,2),[1000 1000],'beta',opts.beta);
        CTC(2,1) = -CTC(2,2) * H(2,1) * ita_invert_spk_regularization(H(1,1),[1000 1000],'beta',opts.beta);
        %         [Aplus,Aminus] = ita_wiener_hopf_factorization(H(1,1)*conj(H(1,1)));
        %         aux = ita_time_shift(KPow*conj(H(1,1)) * ita_invert_spk_regularization(Aminus,[200 16000]),opts.delay,'samples');
        %         CTC(1,1) = ita_time_window(aux,round(opts.winLim*aux.nSamples+opts.delay),'samples')* ita_invert_spk_regularization(Aplus,[200 16000]);
        %         CTC(2,2) = KPow * ita_invert_spk_regularization(H(2,2),[200 16000]);
        %         CTC(1,2) = -CTC(1,1) * H(1,2) * ita_invert_spk_regularization(H(2,2),[200 16000]);
        %         CTC(2,1) = -CTC(2,2) * H(2,1) * ita_invert_spk_regularization(H(1,1),[200 16000]);
        
        
    case {'regularized','reg'}
        h = merge(H);
        N = h.nSamples;
        h = ita_time_window(h,round(opts.winLim*h.nSamples),'samples'); % this was commented out, but leads to errors if the inital shift due to start IR cycles something from the impulse to the end. MKO
        h = ita_extend_dat(h,max(2*N,2^12),'forceSamples');
        
        %speed up for 2x2 matrices
        if size(H) == [2 2]
            % [a b; c d] = H'.H + beta*I
            a = h.ch(1)*conj(h.ch(1)) + h.ch(3)*conj(h.ch(3)) + opts.beta;
            b = h.ch(2)*conj(h.ch(1)) + h.ch(4)*conj(h.ch(3));
            c = h.ch(1)*conj(h.ch(2)) + h.ch(3)*conj(h.ch(4));
            d = h.ch(2)*conj(h.ch(2)) + h.ch(4)*conj(h.ch(4)) + opts.beta;
            determinant = a*d - b*c;
            
            % [LL RL; LR RR] = inv(H'.H +beta) H'
            CTC(1,1) = (d*conj(h.ch(1)) - b*conj(h.ch(2)))/determinant;
            CTC(1,2) = (a*conj(h.ch(2)) - c*conj(h.ch(1)))/determinant;
            CTC(2,1) = (d*conj(h.ch(3)) - b*conj(h.ch(4)))/determinant;
            CTC(2,2) = (a*conj(h.ch(4)) - c*conj(h.ch(3)))/determinant;
            
        else
            [hm,hn] = size(H);
            f = h.nBins;
            hfq = h.freqData;
            c = zeros(hn,hm,f);
            CTC = itaAudio(hn,hm);
            for fdx = 1:f
                hh = reshape(hfq(fdx,:),hm,hn);
                c(:,:,fdx) = hh'/(hh*hh' + opts.beta*eye(hm));
            end
            aux = H(1,1);
            for idx = 1:hn
                for jdx = 1:hm
                    aux.freqData = squeeze(c(idx,jdx,:));
                    CTC(idx,jdx) = aux;
                end
            end
        end
        
        %         for idx = 1:numel(CTC)
        %             CTC(idx) = ita_time_shift(CTC(idx),opts.delay,'samples');
        % %             CTC(idx) = ita_time_window(,...
        % %                         [round(0.8*N) N],'samples','crop');
        %             CTC(idx) = ita_extract_dat(CTC(idx),opts.filterLength,'forcesamples');
        %         end
        FilterWindow = itaAudio;
        FilterWindow.time = hann(h.nSamples);
        FilterWindow.samplingRate = CTC(1).samplingRate;
        FilterWindow.samplingRate = CTC(1).samplingRate;
        FilterWindow.time = hann(CTC(1).nSamples);
        for idx = 1 : numel(CTC)
            CTC(idx) = ita_time_shift(CTC(idx), h.nSamples/2, 'samples');
            CTC(idx) = CTC(idx) .* FilterWindow;
        end
        
    case 'reg_cpp'
        h = merge(H);
        N = h.nSamples;
        %         h = ita_time_window(h,round(opts.winLim*h.nSamples),'samples');
        % Extend to double or more
        %h = ita_extend_dat(h,max(2*N,2^12),'forceSamples');
        
        %speed up for 2x2 matrices
        if size(H) == [2 2]
            % [a b; c d] = H'.H + beta*I
            a = h.ch(1)*conj(h.ch(1)) + h.ch(3)*conj(h.ch(3)) + opts.beta;
            b = h.ch(2)*conj(h.ch(1)) + h.ch(4)*conj(h.ch(3));
            c = h.ch(1)*conj(h.ch(2)) + h.ch(3)*conj(h.ch(4));
            d = h.ch(2)*conj(h.ch(2)) + h.ch(4)*conj(h.ch(4)) + opts.beta;
            determinant = a*d - b*c;
            
            % [LL RL; LR RR] = inv(H'.H +beta) H'
            CTC(1,1) = (d*conj(h.ch(1)) - b*conj(h.ch(2)))/determinant;
            CTC(1,2) = (a*conj(h.ch(2)) - c*conj(h.ch(1)))/determinant;
            CTC(2,1) = (d*conj(h.ch(3)) - b*conj(h.ch(4)))/determinant;
            CTC(2,2) = (a*conj(h.ch(4)) - c*conj(h.ch(3)))/determinant;
            
        else
            [hm,hn] = size(H);
            f = h.nBins;
            % FFT => spectrum
            h = h.freqData;
            c = zeros(hn,hm,f);
            % Prepare result of CTC
            CTC = itaAudio(hn,hm);
            
            %for fdx = 1:f
            %    hh = reshape(h(fdx,:),hm,hn);
            %    c(:,:,fdx) = hh'/(hh*hh' + opts.beta*eye(hm));
            %end
            
            % Mem:
            % hm = 2 (L,R)
            % h = zeros(f,hm*hn);
            hConj = conj(h); % (f,hm*hn) complex
            hhProd = zeros(f,4); % complex
            hhAux = zeros(1,f); % complex
            hhAux2 = zeros(1,f); % complex
            
            % H*H', IN: h [fx(2*n)] , OUT: hhProd [fx4]
            for i=1:hn
                % (1,1):(L*L')
                hhAux = h(:,2*i-1);
                hhAux = hhAux .* hConj(:,2*i-1);
                hhProd(:,1) = hhProd(:,1) + hhAux;
                % (1,2):(L*R')
                hhAux = h(:,2*i-1);
                hhAux = hhAux .* hConj(:,2*i);
                hhProd(:,2) = hhProd(:,2) + hhAux;
                % (2,1):(R*L')
                hhAux = h(:,2*i);
                hhAux = hhAux .* hConj(:,2*i-1);
                hhProd(:,3) = hhProd(:,3) + hhAux;
                % (2,2):(R*R')
                hhAux = h(:,2*i);
                hhAux = hhAux .* hConj(:,2*i);
                hhProd(:,4) = hhProd(:,4) + hhAux;
            end
            
            % beta*I, IN: hhProd [fx{1,4}], OUT: hhProd [fx{1,4}]
            hhProd(:,1) =  hhProd(:,1) + opts.beta*ones(f,1);
            hhProd(:,4) =  hhProd(:,4) + opts.beta*ones(f,1);
            
            % Inversion, IN: hhProd [fx4], OUT: hhProd [fx4]
            % [a b; c d]^-1 = [d -b; -c a] / (a*d - b*c)
            % [1 2; 3 4]^-1 = [4 -2; -3 1] / (1*4 - 2*3)
            % [d -b; -c a]
            hhAux = hhProd(:,1);
            hhProd(:,1) = hhProd(:,4);
            hhProd(:,4) = hhAux;
            hhAux = hhProd(:,2);
            hhProd(:,2) = -hhProd(:,2);
            hhProd(:,3) = -hhProd(:,3);
            % (a*d - b*c)
            hhAux = hhProd(:,1);
            hhAux = hhAux.*hhProd(:,4);
            hhAux2 = hhProd(:,2);
            hhAux2 = hhAux2.*hhProd(:,3);
            hhAux = hhAux - hhAux2;
            % []/[]
            for i=1:4
                hhProd(:,i) = hhProd(:,i)./hhAux;
            end
            
            % H' * result, IN: hConj [fx(2*n)], hhProd [fx4]
            for i=1:hn
                hhAux = hConj(:,2*i-1);
                hhAux = hhAux .* hhProd(:,1);
                c(i,1,:) = hConj(:,2*i);
                c(i,1,:) = squeeze(c(i,1,:)) .* hhProd(:,3);
                c(i,1,:) = squeeze(c(i,1,:)) + hhAux;
                hhAux = hConj(:,2*i-1);
                hhAux = hhAux .* hhProd(:,2);
                c(i,2,:) = hConj(:,2*i);
                c(i,2,:) = squeeze(c(i,2,:)) .* hhProd(:,4);
                c(i,2,:) = squeeze(c(i,2,:)) + hhAux;
            end
            
            aux = H(1,1);
            for idx = 1:hn
                for jdx = 1:hm
                    aux.freqData = squeeze(c(idx,jdx,:));
                    CTC(idx,jdx) = aux;
                end
            end
        end
        
        for idx = 1:numel(CTC)
            CTC(idx) = ita_time_shift(CTC(idx),opts.delay,'samples');
            %             CTC(idx) = ita_time_window(,...
            %                         [round(0.8*N) N],'samples','crop');
            CTC(idx) = ita_extract_dat(CTC(idx),opts.filterLength,'forcesamples');
        end
        
    otherwise
        error('Unknown calculation algorithm')
        
end


%% Dewarping
if opts.warping
    for idx = 1:numel(CTC)
        CTC(idx).timeData = warp_impres(CTC(idx).timeData,-lambda).';
    end
    
    % Delog
    % if flag_delog
    %     for jdx = 1:size(H,1)
    %         for idx = 1:size(H,2)
    %             if idx == idx
    %                 CTC(idx,jdx).freqData(1,:) = sqrt(2)*CTC(idx,jdx).freqData(2,:);
    %             else
    %                 CTC(idx,jdx).freqData(1,:) = 0;
    %             end
    %             CTC(idx,jdx).freqData = interp1(freq_new,CTC(idx,jdx).freqData,freq,'spline');
    %         end
    %     end
    % end
end

%% Output
% assign channel names (according to dissertation)
if (numel(CTC) ==4)
    CTC(1,1).channelNames = {'CTC-1L'};
    CTC(2,1).channelNames = {'CTC-2L'};
    CTC(1,2).channelNames = {'CTC-1R'};
    CTC(2,2).channelNames = {'CTC-2R'};
elseif (numel(CTC) ==8)
    CTC(1,1).channelNames = {'CTC-1L'};
    CTC(2,1).channelNames = {'CTC-2L'};
    CTC(1,2).channelNames = {'CTC-1R'};
    CTC(2,2).channelNames = {'CTC-2R'};
    CTC(3,1).channelNames = {'CTC-3L'};
    CTC(4,1).channelNames = {'CTC-4L'};
    CTC(3,2).channelNames = {'CTC-3R'};
    CTC(4,2).channelNames = {'CTC-4R'};
end

% result = ita_merge(CTC_LL,CTC_LR,CTC_RL,CTC_RR);
% result.channelNames = {'CTC_LL','CTC_LR','CTC_RL','CTC_RR'};
% % normalize filter to avoid clipping
% maximum = max(max(abs(result.freq)));
% if maximum > 1
%     result.freq = result.freq/maximum;
% end
% % result = ita_time_shift(result,1);
% result = ita_metainfo_rm_historyline(result,'all');
% result = ita_metainfo_add_historyline(result,'ita_CTC_filter',{TF_left,TF_right,type});

%EOF ita_CTC_filter