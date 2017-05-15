         
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
% hp = ita_read('D:\Users\masiero\Documents\Measurements\Headphones\HeadPhones on Head\AnalogsKK\Sennheiser HD600\senn_right.ita');
% hp.timeData = hp.timeData(:,2:19);
% % % d = ita_start_IR(hp, 'threshold','60');
% hp = ita_time_shift(hp,-1223+1,'samples');
% hp.timeData(1,:) = 0;
% hp = ita_time_window(hp,[2^14 2^15],'samples');

% ita_zpk_vectorfit_relax(hp.ch(1),'order', 100, 'tol', 0.01, 'MaxIteration', 40,...
%                'relax', 1, 'weights', 1);

% f = hp.freqData(:,1).';
w = 2*pi*hp.freqVector.';
% delayvector = -diff(unwrap(angle(f))) ./ (2*pi*diff(w/hp.samplingRate));
% delay = ceil(max([mean(delayvector), 0]));
% hp = ita_time_shift(hp,-delay-3,'samples');
% hp.timeData(end-10:end,:) = 0;
% f = hp.freqData(:,1:5).';

M = 300;

lim = [10 3000];
ind_l = find(hp.freqVector < lim(1),1,'last');
if ind_l == 1
    ind_l = 2;
end
ind_h = find(hp.freqVector > lim(2),1,'first');

m = logspace(log10(w(ind_l)/hp.samplingRate),log10(w(ind_h)/hp.samplingRate),M);
ind_a = 0;
count = 1;
weight = var(10*log10(abs(hp.freqData)),0,2);

% weight = var(abs(hp.freqData),0,2);
% f = mean(hp.freqData,2).';
f = hp.freqData.';
% f = a.freqData.';
F = []; W = []; Weight = [];
for idx = 1:M
    [~,ind] = min(abs(w/hp.samplingRate-m(idx)));
    if ind ~= ind_a
        F(:,count) = f(:,ind);
        W(count) = w(ind);
        Weight(count) = weight(ind);
        count = count + 1;
    end
    ind_a = ind;
end

f = [0 F];
w = [0 W];
% f = [F(1,:)];
% f = F;
% w = [W];

weight = (1./Weight)*mean(Weight);
% weight = [max(weight) weight max(weight)];
s = 1i*w;   %jw
% z = exp(s/hp.samplingRate).';

N = 50;
% [d,NoiseVariance,reflect_coeffs]= aryule(hp.timeData(:,1),N);
% D = zeros(size(z));
% for idx = 1:N
%     D = D + d(idx)*z.^-idx;
% end
% D = D*80;
% plot(10*log10(abs([f 1./D f.*D])))
% figure
% plot([phase(f) phase(1./D) phase(f.*D)])

% R = zeros(length(f),N);
% for idx = 1:N
%     R(:,idx) = f.*z.^-idx;
% end
% R = [ones(size(R,1),1) -R];
% % b = ones(size(z));
% b = f;

% W = diag(ones(1,2*length(b)));
% for ite = 1:100
%     d = W*[real(R); imag(R)]\W*[real(b); imag(b)];
% 
% %     D = ones(size(z));
% %     for idx = 1:N
% %         D = D + d(idx)*z.^-idx;
% %     end
% 
%     dd = roots([1 d(2:end).']);
% %     dd(abs(dd) > 1) = 1./dd(abs(dd) > 1);
%     D = ones(size(z));
%     for idx = 1:length(dd)
%         D = D.*(1 - dd(idx)*z.^-1);
%     end
%     e(ite) = norm(f-d(1)./D);
%     plot(10*log10(abs([f d(1)./D f/d(1).*D])))
% %     pause
%     W = diag([abs(d(1)./D); abs(d(1)./D)]);
% end
% d = b\R;
%=====================================
% Rational function approximation of f(s):
%=====================================
 
%Parameters for Vector Fitting : 
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

disp('vector fitting...')
Niter=15;

rms_order = [];
% for idx = 30
    N=4; %Order of approximation
    
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
    
    rms = sqrt(mean(mean(abs(f).^2)));
    rmserr = zeros(1,Niter);
    err = inf*ones(1,50);
    for iter=1:Niter
        if iter==Niter, opts.skip_res=0; end
        disp(['   Iter ' num2str(iter)])
        [SER,poles,rmserr(iter),fit]=vectfit3(f,s,poles,weight,opts);
        
%         if rmserr(iter) < rms*0.1;
            zs = eig(SER.A - SER.B*mean(SER.C,1)/(mean(SER.D)+10*eps));
            
            threshold = 1e-2;
            subset = 30;
            %           if rms(iter) < 1
            [zs,poles,k] = ita_zpk_reduce(zs,poles.',1,'dist',threshold);
            %           end
            %           if rms(iter) >= max(err)
            %         if err(end-1) == err(end)
            %             break
            %         end
            %           err = [err(2:end) rms(iter)];
%         end
    end
%     break
    rms_order = [rms_order rms(end)];
% end
plot(20*log10(rms));
opts.skip_res=0;   %DO skip identification of residues (C,D,E) 
opts.cmplx_ss=1;
[SER,poles,rmserr,fit]=vectfit3(f,s,poles,weight,opts);
% ps = poles(abs(angle(poles))/2/pi*hp.samplingRate < 1 ...
%     | abs(angle(poles))/2/pi*hp.samplingRate > 22000);
% zs = zs(abs(angle(zs))/2/pi*hp.samplingRate < 1 ...
%     | abs(angle(zs))/2/pi*hp.samplingRate > 22000);
figure
ita_plot_zplanepz(zs(:),poles(:),1)

w = 2*pi*hp.freqVector;
s = -1i*w;   %jw


N = prod(bsxfun(@plus,s,zs.'),2);
Q = prod(bsxfun(@plus,s,poles.'),2);
H = N./Q*mean(SER.D);
k = median(abs(hp.freqData(:,1))./abs(H));
H = k*H;

t = hp.timeVector;
resp_imp = impz(zs,poles,1024,hp.samplingRate);

% c = zs(1);
% [a,b] = [-z(:) ones(size(z(:)))]\((z(:)-c).*(z(:)-c^2)./f(:) - z(:).^2);
fs = hp.samplingRate;
[sos,g] = zp2sos(zs(:),poles(:),k,'up');
% sos = [a b];
h = g*ones(size(w));
for idx = 1:size(sos,1)
    hn = freqz(sos(idx,1:3),sos(idx,4:6),w/fs);
    h = h.*hn;
    subplot(3,3,1:6)
    semilogx(hp.freqVector,20*log10(abs([hp.ch(1).freqData h hn])));
    hold all
    semilogx(hp.freqVector,angle([hp.ch(1).freqData h hn]));
    hold off
    subplot(3,3,7)
    zplane(sos(idx,1:3),sos(idx,4:6))
    subplot(3,3,8:9)
    impz(sos(idx,1:3),sos(idx,4:6),hp.timeVector*fs,fs);
    pause
end
    
    
figure
semilogx(w/2/pi,20*log10(abs(H/900)))
hold all
semilogx(w/2/pi,20*log10(abs(hp.freqData)))
I = Q./N;
b = zeros(size(N));

semilogx(w/2/pi,10*log10(abs(bsxfun(@rdivide,hp.freqData,H))))

b = hp.ch(1) * 0;
a = 1000+b';

epsilon = ita_xfade_spk(a,b,[5 20]);
epsilon = ita_xfade_spk(epsilon,a,[20000 21000]);
epsilon = ita_amplify(epsilon^2, max(max(abs(hp.freqData))) / 100);
epsilon = epsilon.freqData + 1*eps;% was 10*eps + 10i*eps;

II = Q .* conj(N).*(abs(N).^2 .*(1 + epsilon)).^-1;
semilogx(w/2/pi,abs([I II epsilon]))
semilogx(w/2/pi,angle([I II]))
b.freqData = II;
% figure
% semilogx(w/2/pi,angle(H))
% zs(abs(zs)>1) = 1./zs(abs(zs)>1);
% cte = .999;
% zs(abs(zs)>cte) = cte*exp(angle(zs(abs(zs)>cte)));
% N = prod(1 - z.^-1 * zs(:).',2);
% Q = prod(1 - z.^-1 * poles(:).',2);
% H = k*N./Q;
% hold all
% semilogx(w/2/pi,angle(H))
% semilogx(w/2/pi,angle(hp.freqData(:,1)))
% figure
% semilogx(w/2/pi,abs(H)); hold all
% semilogx(w/2/pi,abs(hp.freqData(:,1)))

% for f = 1:300
%     ind_low = f;% m.freq2index(f);
%     ind_high = f + 10;%m.freq2index(2*f);
% r(f) = (log(abs(m.freq2value(ind_high)/m.freq2value(ind_low))))/...
%     log(m.freqVector(ind_high)/m.freqVector(ind_low));
% end
ind = m.freq2index(200);
x = m.freqVector(1:ind);
f_m = abs(m.freqData(1:ind));
f_a = phase(m.freqData(1:ind));
magnitude = m.freqData(ind)*((x/x(end)).^(3));
% phase = 
m.freqData(1:27) = ans.'