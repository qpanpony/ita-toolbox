% ex2.m             
%
% -Creating an 18th order frequency response f(s) of 2 elements.
% -Fitting f(s) using vectfit3.m 
%   -Initial poles: 9 linearly spaced complex pairs (N=18)
%   -3 iterations
%
% This example script is part of the vector fitting package (VFIT3.zip) 
% Last revised: 08.08.2008. 
% Created by:   Bjorn Gustavsen.
%
hp = ita_read('D:\Users\masiero\Documents\Measurements\Headphones\HeadPhones on Head\AnalogsKK\Sennheiser HD600\senn_right.ita');

% ita_zpk_vectorfit_relax(hp.ch(1),'order', 100, 'tol', 0.01, 'MaxIteration', 40,...
%                'relax', 1, 'weights', 1);

f = hp.freqData(:,1).';
w = 2*pi*hp.freqVector.';
delayvector = -diff(unwrap(angle(f))) ./ (2*pi*diff(w/hp.samplingRate));
delay = ceil(max([mean(delayvector), 0]));
hp = ita_time_shift(hp,-delay,'samples');
f = hp.freqData(:,1).';

M = 400;

lim = [20 20000];
ind_l = find(hp.freqVector < lim(1),1,'last');
ind_h = find(hp.freqVector > lim(2),1,'first');

m = logspace(log10(w(ind_l)/hp.samplingRate),log10(w(ind_h)/hp.samplingRate),M);
ind_a = 0;
count = 1;
F = []; W = [];
for idx = 1:M
    [~,ind] = min(abs(w/hp.samplingRate-m(idx)));
    if ind ~= ind_a
        F(count) = f(ind);
        W(count) = w(ind);
        count = count + 1;
    end
    ind_a = ind;
end

f = [F ];
w = [W ];

s = 1i*w;   %jw
z = exp(s/hp.samplingRate);
z_1 = exp(-s/hp.samplingRate);
f = f(1,:);
%=====================================
% Rational function approximation of f(s):
%=====================================


N=2; %Order of approximation 

%Complex starting poles :
% bet=linspace(w(1),w(Ns),N/2);
% poles=[];
% for n=1:length(bet)
%   alf=-bet(n)*1e-2;
%   poles=[poles (alf-1i*bet(n)) (alf+1i*bet(n)) ]; 
% end
% theta = logspace(-4,pi,floor(N/2));
% theta = [-theta(end-1:-1:1) 0 theta];
% poles = .8*exp(1i*theta);
poles = .9*exp(2i*pi*(0:N-1)/N);
poles = cplxpair(poles);

% Real starting poles :
%poles=-linspace(w(1),w(Ns),N); 
 
%Parameters for Vector Fitting : 

weight= 1./w; weight(1) = weight(2);
% weight = ones(size(weight));

opts.relax=0;      %Use vector fitting with relaxed non-triviality constraint
opts.stable=1;     %Enforce stable poles
opts.asymp=2;      %Include only D in fitting    
opts.skip_pole=0;  %Do NOT skip pole identification
opts.skip_res=0;   %DO skip identification of residues (C,D,E) 
opts.cmplx_ss=0;   %Create real-only state space model

opts.spy1=0;       %No plotting for first stage of vector fitting
opts.spy2=1;       %Create magnitude plot for fitting of f(s) 
opts.logx=1;       %Use linear abscissa axis
opts.logy=1;       %Use logarithmic ordinate axis 
opts.errplot=1;    %Include deviation in magnitude plot
opts.phaseplot=0;  %Do NOT produce plot of phase angle
opts.legend=1;     %Include legends in plots
opts.ortho = 0;

disp('vector fitting...')
Niter=100;
rms = zeros(1,Niter);
err = inf*ones(1,10);
Z = [];
P = [];
F = f;
for idx = 1:50
    for iter=1:Niter
      if iter==Niter, opts.skip_res=0; end
      disp(['   Iter ' num2str(iter)])
      [SER,poles,rmserr,fit]=vectfitZ(F,z,poles,weight,opts);
      rms(iter)=rmserr;

      zs = eig(SER.A - SER.B*SER.C/SER.D);

      if rms(iter) >= mean(err)
          break
      end
      err = [err(2:end) rms(iter)];
    end
    P = [P poles];
    Z = [Z zs];
    N = prod(1 - z_1(:) * zs(:).',2);
    Q = prod(1 - z_1(:) * poles(:).',2);
    H = N./Q;
    F = F./H.';
    semilogx(w/2/pi,20*log10(abs([F])))
end
