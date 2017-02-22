% find zeros
H = hp.freqData(:,1);
f = hp.freqVector;
extrems = [0; -diff(sign(diff(abs(H(:))))/2); 0];
semilogx(abs([H H.*extrems]));

ind = find(extrems < 0,1,'last');
ind_stop = find(extrems(1:ind) > 0,1,'last');
[~,ind_coef] = min(abs(abs(angle(zs))/2/pi*hp.samplingRate - f(ind)));
[~,ind_h] = min(abs(10*log10(abs(H(ind:end)/H(ind)))-3));
[~,ind_l] = min(abs(10*log10(abs(H(ind_stop:ind)/H(ind)))-3));
theta_l = f(ind_stop+ind_l)/hp.samplingRate*2*pi;
theta_c = f(ind)/hp.samplingRate*2*pi;
theta_h = f(ind+ind_h)/hp.samplingRate*2*pi;

g = -40;
v = 10^(g/20);
k = (1 + cos(theta_l)*cos(theta_h))/(cos(theta_l) + cos(theta_h));
t_c = acos(k - sign(k)*sqrt(k^2 - 1));
Q = sqrt((v*sin(t_c)^2*(cos(theta_l)+cos(theta_h)))/(2*cos(t_c)-cos(theta_l)-cos(theta_h)))/2;

% Q = theta_c/(theta_h-theta_l);
% psi = theta_c;


a0 = 1;
a2 = (2*Q - sin(psi))/(2*Q + sin(psi));
a1 = -(1+a2)*cos(psi);
b1 = a1;
b0 = (1+a2)/2 + v*(1-a2)/2;
b2 = (1+a2)/2 - v*(1-a2)/2;

roots([b0 b1 b2])
roots([a0 a1 a2])

Z = zs;
Z(ind_coef+(0:1)) = roots([a0 a1 a2]);
P = poles;

w = 2*pi*hp.freqVector.';
s = 1i*w;   %jw
z_1 = exp(-s/hp.samplingRate);

N = prod(1 - z_1(:) * Z(:).',2);
Q = prod(1 - z_1(:) * P(:).',2);
H = N./Q;
k = median(abs(hp.freqData(:,1))./abs(H));
H = k*H;
figure
semilogx(w/2/pi,abs(H))
hold all
semilogx(w/2/pi,abs(hp.freqData(:,1)))
I = Q./N;
b = zeros(size(N));
b = hp.ch(1) * 0;
a = 1000+b';

epsilon = ita_xfade_spk(a,b,[5 20]);
epsilon = ita_xfade_spk(epsilon,a,[20000 21000]);
epsilon = ita_amplify(epsilon^2, max(max(abs(hp.freqData))) / 100);
epsilon = epsilon.freqData + 1*eps;% was 10*eps + 10i*eps;

II = Q .* conj(N).*(abs(N).^2 .*(1 + epsilon)).^-1;
semilogx(w/2/pi,abs([I II]))
semilogx(w/2/pi,angle([I II]))
b.freqData = II;

h = hp.freqData(:,1);
semilogx(w/2/pi,abs([h.*I h.*II]))

fs = hp.samplingRate;
[sos,g] = zp2sos(Z,P,k,'up');
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