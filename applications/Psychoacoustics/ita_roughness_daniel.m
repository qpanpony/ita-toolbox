function varargout = ita_roughness_daniel(varargin)
%ITA_ROUGHNESS_DANIEL - Implementation of the Roughness calculation
%  This function calculates the roughness after Daniel.
%  Comment MMT: after a major bugfixing the values more or less match those
%  of the paper by Daniel.
%
%  Syntax:
%   [R, ri] = ita_roughness_daniel(audioObjIn)
%
%
%  See also:
%   ita_loudness
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roughness_daniel">doc ita_roughness_daniel</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Daniel Cragg -- Email: daniel.cragg@akustik.rwth-aachen.de
% Created:  16-Jun-2010


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

if input.trackLength > 0.2
    nSlices = floor(input.trackLength/0.2);
    Rout = zeros(nSlices,1);
    Riout = zeros(nSlices,47);
    for iSlice = 1:nSlices
        [tmp1,tmp2] = ita_roughness_daniel(ita_time_crop(input,[(iSlice-1) iSlice].*0.2,'time'));
        Rout(iSlice) = double(tmp1);
        Riout(iSlice,:) = double(tmp2);
    end
    Rout = itaValue(Rout);
    Rout.unit = 'asper';
    varargout(1) = {Rout};
    if nargout == 2
        varargout(2) = {Riout};
    end
    return;
end

%% get some settings straight
y        = input.time;
sampfrq  = input.samplingRate;
Nsampfrm = input.nSamples;
cnorm = 0.25; % mmt after bugfixing
Ncritbnd = 47;
Ndeltaz  = 241;

% -----------------------------------------------------------
% calculating sample numbers and time and frequency
% intervals and number of components

% signal length in seconds
tsfrme = Nsampfrm / sampfrq;

% deltaf in Hz
deltaf = (1/tsfrme);

% number of frequency components of the envelope spectrum
% up to 640 Hz
nfenvspc = ceil(646 / deltaf)-1;

% number of frequency components of the frame spectrum
% up to 16000 Hz
N6deltaf = ceil(16000 / deltaf)-1;

% number of frequency components of the frame spectrum
% up to 15500 Hz
N5deltaf = ceil( 15500 / deltaf)-1;

% -------------------------------------------------------------
% initialisation of stuff used for the roughness calculation
% -------------------------------------------------------------

% weighting for the specific roughness as a function
% of the critical band rate
gx = [0.60, 0.68, 0.78, 0.88, 0.98,...
    1.01, 1.05, 1.09, 1.15, 1.08,...
    1.03, 1.00, 0.96, 0.88, 0.82,...
    0.80, 0.75, 0.74, 0.73, 0.69,...
    0.64, 0.64, 0.64, 0.64];

% distributing the weightings on the Ncritbnd (47) subdivisions
gr = repmat(gx,2,1);
gr = gr(1:end-1);

% calculation of the damping free a0(f) field
% -> inner ear and the hearing threshold excitation
% level lethr(f) and the critical band rate zf(f)
% for the frequencies f = i*deltaf
a0 = a0damp(N6deltaf,deltaf);

% calculation of the hearing threshold lethr(f) for frequencies
lethr = lhs(N5deltaf,deltaf);

% calculation of the critical band rate zf(f) for frequencies
zf = f2z(N5deltaf,deltaf);

% calculation of the frequencies fz(z) for the critical
% band rate j*deltaz , j = 0,...,Ndeltaz-1,
% deltaz  = 0.1 Bark
fz = z2f(Ndeltaz);

% calculation of the lower limiting frequencies fzlolim,
% the center frequencies fzcenter and the upper limiting
% frequencies fzhilim for the Ncritbnd critical bands.
% They overlap by 0.5 Bark
ivfg = 5;

izlolim = (0:Ncritbnd-1).*ivfg;
izhilim = (2:Ncritbnd+1).*ivfg;
fzlolim = fz(izlolim+1);
fzhilim = fz(izhilim + 1);

% calculating the window weights for a frame
windwght = blackman(Nsampfrm).'; % signal processing toolbox

% weighting the frame with the blackman window
framecal = y.' .* windwght;

% calculating the levels of the weighted and unweighted frames
% to correct for the decrease by the windowing
framecal = framecal .* norm(y)./norm(framecal);

% calculation of the spectrum of the weighted frame
framecal = fft(framecal);

% calculating Amplitude and phase of the spectrum
specframecalampl = abs (framecal(2:Nsampfrm/2+1));
specframecalphase = angle(framecal(2:Nsampfrm/2+1));

% calculating the power of the amplitudespectrum
Power = 20.*log10(specframecalampl.*sqrt(2)/(2e-5*Nsampfrm));

% weighting of the spectrum with the gain a0 ( free field -> inner ear )
speca0(1:N6deltaf) = Power(1:N6deltaf) - a0;
speca0(N6deltaf+1:Nsampfrm/2) = bsxfun(@minus,Power(N6deltaf+1:Nsampfrm/2),a0(N6deltaf));

% calc weighting functions
Hfmod = hfmod(deltaf,nfenvspc);

% =============================================================================
% Main loop
%

% ------------------------------------------------------------------------------------------------
% excitation pattern as a function of the critical band rate
cbpower = zeros(Ncritbnd,1);
tsenv = zeros(Ncritbnd,nfenvspc*2);
rmsenv = zeros(Ncritbnd,1);
h0 = zeros(Ncritbnd,1);
for iBand = 1:round(Ncritbnd)    
    zlolim=izlolim(iBand)/10;
    zhilim=izhilim(iBand)/10;
    flolim=fzlolim(iBand);
    fhilim=fzhilim(iBand);
    
    [leiz,komp] = lez(speca0,Nsampfrm/2,N5deltaf,deltaf,zf,zlolim,zhilim,flolim,fhilim,lethr(2:end));
    cbpower(iBand) = sum(leiz.^2);
    cblevel = max(-20,10.*log10(cbpower(iBand)));    
    
    % determination of the complex spectral components lec for the
    % excitation in the critical band
    % underlying asumption: the determination of the excitation signal
    % at the critical band i does not affect the phase    
    lecCmplx = leiz .* exp(1i.*specframecalphase);
    lec = [lecCmplx, conj(lecCmplx(Nsampfrm/2:-1:2))];
    % calculation of the time function of the excitation at the place i
    % by inverse fft
    envexcit = abs(ifft(lec.*(2e-5*Nsampfrm)./sqrt(2),Nsampfrm));
    % demodulation of temporal excitation function: calculating |ifft|
    
    if cblevel < 0
        h0(iBand) = 0;
    elseif komp < 2
        h0(iBand) = 0;
    else
        h0(iBand) = mean(envexcit);
    end;
    
    % fft of the envelope 'envexcit'
    spexcit = fft(envexcit./Nsampfrm,Nsampfrm);
    
    % bandpass filtering of the excitation spectrum by multiplication
    % with hx(icritbnd)
    hx = Hfmod(iBand,:);
    spexcitbpf = spexcit(2:nfenvspc+1) .* hx;
    
    % ifft of the bandpass filtered envelope below 640 Hz
    % DC-Value = 0
    spexcitbpf = [0, spexcitbpf(1:nfenvspc), conj(spexcitbpf(nfenvspc:-1:2))]; 
    % Klemenz (new): best results with IMAG(IFFT) - don't ask why!!
    tfexcitbpf = abs(ifft(spexcitbpf.*nfenvspc*2));
    % Klemenz (new): Realmin yielded many DIVbyZERO errors, 1e-50 is also very small
    tfexcitbpf(tfexcitbpf == 0) = 1e-50;
    
    tsenv(iBand,:) = tfexcitbpf(1:nfenvspc*2); %Matrix with Ncritbnd envelopes
    
    % calculating the rms-value of the bandpass filtered envelope
    % Klemenz (new)% factor (1.16) for a true ratio rmsenv / h0
    rmsenv(iBand) = norm(tfexcitbpf)/sqrt(nfenvspc*2);
end; % of loop for Ncritbnd critical bands

% calculation of the correlation of the excitation envelopes
cors = ones(1,Ncritbnd);
for bnd = 3:Ncritbnd-2
    corp2 = corrcoef(tsenv(bnd,:),tsenv(bnd+2,:));
    corm2 = corrcoef(tsenv(bnd,:),tsenv(bnd-2,:));
    cors(bnd) = corp2(1,2) .* corm2(1,2);
end;
corp21 = corrcoef(tsenv(1,:),tsenv(3,:));
cors(1) = corp21(1,2);
corp22 = corrcoef(tsenv(2,:),tsenv(4,:));
cors(2) = corp22(1,2);
corm2Ncritbnd = corrcoef(tsenv(Ncritbnd-1,:),tsenv(Ncritbnd-3,:));
cors(Ncritbnd-1) = corm2Ncritbnd(1,2);
corm2Ncritbnd = corrcoef(tsenv(Ncritbnd,:),tsenv(Ncritbnd-2,:));
cors(Ncritbnd) = corm2Ncritbnd(1,2);

% calculation of the modulation depth m*
% h0(icritbnd) > 0 -> ms(icritbnd) = rmsenv(icritbnd)/h0(icritbnd)
ms = zeros(1,Ncritbnd);
for iBand = 1:Ncritbnd
    % Riemann (old) % if (rmsenv(i) == h0(i)) & (rmsenv(i) < 1e-300)
    % Klemenz (new) % adapted to change in rmsenv, rms == h0 not possible (round error)
    if (rmsenv(iBand) < 1e-49)
        ms(iBand) = 0;
    else
        ms(iBand) = rmsenv(iBand) ./ h0(iBand);
    end;
end;

ms(ms > 1) = 1;

% calculation of the specific roughnesses ri
% weighted with gr(z)  and normalisation
ri = ((cors .* gr .* ms)).^2;
ri = ri .* cnorm;
ri(isnan(ri)) = 0;

% calculation of the total roughness
R = sum(ri);

% end of Main loop

%% Set Output
R = itaValue(R);
R.unit = 'asper';
varargout(1) = {R};
if nargout == 2
    varargout(2)= {ri};
end

%end function
end