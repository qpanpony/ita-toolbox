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
% hp = ita_read('V:\masiero\KK\senn_left.ita');

% ita_zpk_vectorfit_relax(hp.ch(1),'order', 100, 'tol', 0.01, 'MaxIteration', 40,...
%                'relax', 1, 'weights', 1);

% f = hp.freqData(:,1).';
hp = c
w = 2*pi*hp.freqVector.';
% delayvector = -diff(unwrap(angle(f))) ./ (2*pi*diff(w/hp.samplingRate));
% delay = ceil(max([mean(delayvector), 0]));
% hp = ita_time_shift(hp,-delay-3,'samples');
% hp.timeData(end-10:end,:) = 0;
% f = hp.freqData(:,1:5).';

M = 30;

% lim = [200 46000];
% ind_l = find(hp.freqVector < lim(1),1,'last');
% ind_h = find(hp.freqVector > lim(2),1,'first');
% 
% m = logspace(log10(w(ind_l)/hp.samplingRate),log10(w(ind_h)/hp.samplingRate),M);
% ind_a = 0;
% count = 1;
% weight = var(abs(hp.freqData),0,2);
% % f = mean(hp.freqData,2).';
% f = hp.freqData.';
% F = []; W = []; Weight = [];
% for idx = 1:M
%     [~,ind] = min(abs(w/hp.samplingRate-m(idx)));
%     if ind ~= ind_a
%         F(:,count) = f(:,ind);
%         W(count) = w(ind);
%         Weight(count) = weight(ind);
%         count = count + 1;
%     end
%     ind_a = ind;
% end
% 
% % f = [abs(F(:,1)) F abs(F(:,end))];
% % w = [0 W w(end)];
% f = F;
% w = W;
% 
% weight = (1./Weight)*mean(Weight);
% % weight = [max(weight) weight max(weight)];
s = 1i*w;   %jw
% z = exp(s/hp.samplingRate);

f = hp.freqData.';
f(1) =  0;

%=====================================
% Rational function approximation of f(s):
%=====================================
 
%Parameters for Vector Fitting : 
weight= 1./w; weight(1) = weight(2);
% weight = ones(size(w));

opts.s = s;
opts.relax=1;      %Use vector fitting with relaxed non-triviality constraint
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
Niter=50;

rms_order = [];
% for idx = 30
    N=56; %Order of approximation
    
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
    
%     rms = zeros(1,Niter);
%     err = inf*ones(1,50);
%     for iter=1:Niter
%         if iter==Niter, opts.skip_res=0; end
%         disp(['   Iter ' num2str(iter)])
% %         [SER,poles,rmserr,fit]=vectfitZ(f,z,poles,weight,opts);
%         [SER,poles,rmserr,fit]=vectfit3(f,s,poles,weight,opts);
%         rms(iter)=rmserr;
%         
%           zs = eig(SER.A - SER.B*mean(SER.C,1)/mean(SER.D));
%         
%           threshold = 1e-3;
%           subset = 30;
%           
%         
%           if rms(iter) >= max(err)
% %         if err(end-1) == err(end)
%             [zs,poles,k] = ita_zpk_reduce(zs,poles.',1,'dist',threshold);
%             break
%         end
%           err = [err(2:end) rms(iter)];
%     end
%     rms_order = [rms_order rms(end)];
% end
rms = sqrt(mean(mean(abs(f).^2)));
rmserr = zeros(1,Niter);
err = inf*ones(1,50);
for iter=1:Niter
    if iter==Niter, opts.skip_res=0; end
    disp(['   Iter ' num2str(iter)])
    [SER,poles,rmserr(iter),fit]=vectfit3(f,s,poles,weight,opts);
    
    if rmserr(iter) < rms*0.1;
        zs = eig(SER.A - SER.B*mean(SER.C,1)/(mean(SER.D)+10*eps));
        
        threshold = 1e-2;
        subset = 30;
        if rmserr(iter) < 1
            [zs,poles,k] = ita_zpk_reduce(zs,poles.',1,'dist',threshold);
        end
        if rmserr(iter) >= max(err)
            if err(end-1) == err(end)
                break
            end
        end
    end
    err = [err(2:end) rmserr(iter)];
end

opts.skip_pole=1;  %Do NOT skip pole identification
opts.skip_res=0;   %DO skip identification of residues (C,D,E)
opts.s = 1i*2*pi*a.freqVector;
[SER,poles,rmserr,fit]=vectfit3(f,s,poles,weight,opts);
d.freqData = fit(:);

merge(a,d)

[z,p,k] = ss2zp(full(SER.A),SER.B,SER.C,SER.D,1);
[B,A] = ss2tf(full(SER.A),SER.B,SER.C,SER.D,1);
d = a;
d.freqData = freqs(B,A,2*pi*a.freqVector);


break
plot(20*log10(rms));

% ps = poles(abs(angle(poles))/2/pi*hp.samplingRate < 1 ...
%     | abs(angle(poles))/2/pi*hp.samplingRate > 22000);
% zs = zs(abs(angle(zs))/2/pi*hp.samplingRate < 1 ...
%     | abs(angle(zs))/2/pi*hp.samplingRate > 22000);
figure
ita_plot_zplanepz(zs(:),poles(:),1)

w = 2*pi*hp.freqVector.';
s = 1i*w;   %jw
z_1 = exp(-s/hp.samplingRate);

N = prod(1 - z_1(:) * zs(:).',2);
Q = prod(1 - z_1(:) * poles(:).',2);
H = N./Q;
k = median(abs(hp.freqData(:,1))./abs(H));
H = k*H;

% c = zs(1);
% [a,b] = [-z(:) ones(size(z(:)))]\((z(:)-c).*(z(:)-c^2)./f(:) - z(:).^2);
fs = hp.samplingRate;
[sos,g] = zp2sos(zs(3:end),poles(3:end),k,'up');
% sos = [a b];
h = g*ones(size(w.'));
for idx = 1:size(sos,1)
    hn = freqz(sos(idx,1:3),sos(idx,4:6),w.'/fs);
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
semilogx(w/2/pi,abs(H))
hold all
semilogx(w/2/pi,abs(hp.freqData(:,1)))
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

