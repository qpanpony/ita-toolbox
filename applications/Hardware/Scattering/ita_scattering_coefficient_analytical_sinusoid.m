function varargout = ita_scattering_coefficient_analytical_sinusoid(varargin)
%ITA_SCATTERING_COEFFICIENT_ANALYTICAL_SINUSOID - analytic scattering for sine shapes
%  This function computes the scattering coefficient of a sine-shaped
%  suface (with infinite extent) for a given set of frequencies and
%  incident angles.
%
%  The function implements the method by Holford and Urusovskii with the
%  implementation notes given by Embrechts.
%
%  Syntax:
%   itaResult = ita_scattering_coefficient_analytical_sinusoid(doubleVec,doubleVec, options)
%
%   Options (default):
%           'theta_0' (0)                       : out-of-plane incident angle (-90 to 90 deg)
%           'c' (double(ita_constants('c')))    : speed of sound
%
%  Example:
%   s = ita_scattering_coefficient_analytical_sinusoid(100:10:4000,40)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_scattering_coefficient_analytical_sinusoid">doc ita_scattering_coefficient_analytical_sinusoid</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  22-Jul-2011 


%% Initialization and Input Parsing
sArgs        = struct('pos1_freqVec','vector', 'pos2_phiVec', 'vector','theta_0',0,'c',double(ita_constants('c')));
[freqVec,phiVec,sArgs] = ita_parse_arguments(sArgs,varargin); 

phiVec = phiVec(phiVec >= -90);
phiVec = phiVec(phiVec <= 90);
phiVec = phiVec.*pi/180; % make it radian

%% constants
L               = 0.354/2; % structural wavelength
h               = 0.051/2; % structural height (half of peak-to-peak)
K               = 2*pi/L; % structural wavenumber
lambda          = sArgs.c./freqVec(:); % wavelength
k               = 2*pi./lambda; % wavenumber
ky              = k.*sin(sArgs.theta_0); % account for out-of-plane incidence
eta0            = 0; % normalized admittance

Nmax            = ceil(L*max(freqVec)/sArgs.c*2); % maximum reflection order
sCoeff          = zeros(numel(freqVec),numel(phiVec));

ita_verbose_info(['L = ' num2str(L) ', h/L = ' num2str(h/L)],1);

%% loop through frequencies and phi values
tStart = tic;
parfor iFreq = 1:numel(freqVec)
    sPhi = zeros(numel(phiVec),1);
    for iPhi = 1:numel(phiVec)
        ita_verbose_info(['f = ' num2str(freqVec(iFreq)) 'Hz, L/lambda = ' num2str(L/lambda(iFreq)) ', incident angle phi = ' num2str(round(phiVec(iPhi)*180/pi))],1);
        alpha_0     = cos(phiVec(iPhi));
        gamma_0     = sin(phiVec(iPhi));
        
        % get valid n/m values and corresponding angles
        [alpha_n,n]  = alpha(-Nmax:1:Nmax,alpha_0,k(iFreq),ky(iFreq),K);
        if isempty(n) || (numel(n) == 1 && n == 0)
%             ita_verbose_info('Only specular reflection, scattering is 0',1);
            continue;
        end
        gamma_n     = sin(acos(alpha_n));

        % build U matrix and Phi_hat vector and solve for Phi
        Nmax2       = max(abs(n));
        N           = 2*Nmax2+1;
        n_vec       = -Nmax2:1:Nmax2;
        Phi_hat     = phi_hat(n_vec,k(iFreq)*h*gamma_0);
        U           = zeros(N);
        
        tuStart = tic;
        for iM = 1:numel(n)
            for iN = 1:numel(n)
                if rem(n_vec(iM)-n_vec(iN),2)
                    A = getA(k(iFreq),ky(iFreq),h,K,alpha_0,n(iM),n(iN));
                    U(n(iM)+Nmax2+1,n(iN)+Nmax2+1) = getV(k(iFreq),ky(iFreq),h,K,alpha_0,A,n(iM),n(iN)) + getW(k(iFreq),ky(iFreq),h,K,alpha_0,A,n(iM),n(iN));
                end
            end
        end
        tU = toc(tuStart);
        A = (eye(N) - U);
        b = 2.*Phi_hat;
        % solve the system Ax = b for the phi values
        
%         Phi = A\b; % brute force least squares
        Phi = lsqr(A,b); % recursive least squares
%         [U,S,V] = svd(A);
%         epsilon = max(1e-3,min(abs(S(:))));
%         Phi = (A'*A + epsilon.*eye(N))\(A'*b); % tikhonov regularization
%         D = diag(diag(S)./(diag(S).^2 + epsilon));
%         Phi = V*D*U'*b; % tikhonov using SVD
        
        % get the R vector and only keep the values that correspond to radiating waves
        R = zeros(N);
        for iM = 1:numel(n)
            for iN = 1:numel(n)
                R(n(iM)+Nmax2+1,n(iN)+Nmax2+1) = 1./(2.*gamma_n(iM)).*Phi(iN)*phi_hat(n_vec(iM)-n_vec(iN),k(iFreq)*h*gamma_n(iM)).*(gamma_n(iM) + (n_vec(iM)-n_vec(iN))*K*alpha_n(iM)/(k(iFreq)*gamma_n(iM)) + eta0);
            end
        end
        
        R = sum(R,2);
        R = R(n+Nmax2+1);
        
        % test should be equal to 1
        normTest = sum(abs(R).^2.*gamma_n(:))./gamma_0;
        ita_verbose_info(['U matrix built in ' num2str(round(1000*tU)/1000) 's, test variable is ' num2str(normTest)],1);
        
        % scattering is computed from the "0" mode, i.e. the specular mode
        R0 = R(n == 0);
        sPhi(iPhi) = 1 - min(1,abs(R0)^2);
    end
    sCoeff(iFreq,:) = sPhi;
%     save tempResults_holford.mat s;
end
tEnd = toc(tStart);
ita_verbose_info(['Function took ' num2str(round(1000*tEnd)/1000) 's to complete'],1);

sCoeff = itaResult(sCoeff,freqVec,'freq');
sCoeff.comment = 'Analytical solution of the scattering coefficient for sinusoidal profiles';
sCoeff.channelNames = cellstr([repmat('phi = ',numel(phiVec),1) num2str(round(phiVec(:).*180/pi))]);
sCoeff.allowDBPlot = 0;

%% Add history line
sCoeff = ita_metainfo_add_historyline(sCoeff,mfilename,varargin);

%% Set Output
varargout(1) = {sCoeff};
if nargout > 1 && numel(phiVec) > 1
    % also return the random incidence coefficient
    % integrate over frequency and incident angle
    s_direc = sCoeff.freq;
    s_randMat = zeros(sCoeff.nBins,1);
    % integrate over frequency with Gauss-Chebyshev Quadrature
    for iFreq = 2:sCoeff.nBins
        % formulas are simplified w.r.t. weights etc.
        n = 2*ceil(iFreq/2);
        xi = cos((2.*(1:n)-1)./(2*n).*pi);
        xi = sort(xi(xi > 0));
        fIdx = round(xi(:).*freqVec(iFreq));
        xi = xi(fIdx > min(freqVec));
        fIdx = fIdx(fIdx > min(freqVec));
        if ~isempty(fIdx)
            sxi = interp1(freqVec(1:iFreq),s_direc(1:iFreq,:),fIdx);
        else
            sxi = zeros(numel(n/2),numel(phiVec));
        end
        sxi(isnan(sxi)) = 0;
        sxi(fIdx == 0,:) = 0;
        fxi = bsxfun(@times,xi(:).^2,sxi);
        tmp = 2.*mean(fxi);
        % integration over angle
        s_randMat(iFreq) = trapz(phiVec,sin(phiVec).*tmp,2);
    end
    s_rand = sCoeff;
    s_rand.freq = s_randMat;
    varargout{2} = s_rand;
end

%end function
end

%% subfunctions
function [a,n] = alpha(n,alpha0,k,ky,K)

a = (ky./k).^2 + alpha0 + n.*K./k;
valid_a = logical(abs(a) <= 1);
n = n(valid_a);
a = a(valid_a);
% ita_verbose_info(['Valid n-values are: ' mat2str(n)],1);
end

function phi = phi_hat(m,khgamma0)

phi = zeros(numel(m),1);
for iM = 1:numel(m)
    phi(iM) = (-1i)^m(iM) * besselj(m(iM),khgamma0);
end
end

function A = getA(k,ky,h,K,alpha0,m,n)
if n == m+1 || n == m-1
    alpham = alpha(m,alpha0,k,ky,K);
    alphan = alpha(n,alpha0,k,ky,K);
    if abs(alpham) == 1 || abs(alphan) == 1
        A = 1./k.*max(40,200.*(k.*h)^2);
    else
        A = 1./k.*max([40,200.*(k.*h)^2,50./min([1+alpham,1-alpham,1+alphan,1-alphan])]);
    end
else
    A = 1./k.*max(40,200.*(k.*h)^2);
end
end

function V = getV(k,ky,h,K,alpha0,A,m,n)

alpham = alpha(m,alpha0,k,ky,K);

int2func2 = @(x,tau) K./pi.*exp(-1i.*(m-n).*K.*x).*int2func(x,tau,h,k,K).*exp(-1i.*k*alpham.*tau);
V = myDblIntegration(int2func2,0,pi/K,-A,A);
end

function W = getW(k,ky,h,K,alpha0,A,m,n)

if n == m+1 || n == m-1
    alpham = alpha(m,alpha0,k,ky,K);
    if abs(alpham) ==  1
        W = 0;
    else
        W = 1i*h*K/(1-alpham.^2)./sqrt(2*pi.*k.*A).*exp(1i.*(k.*A-0.75*pi)).*(alpham.*cos(k.*A*alpham)-1i*sin(k*A*alpham));
        if n == m+1
            W = -W;
        end
    end
else
    W = 0;
end
end

function res = int2func(s,t,h,k,K)
% careful for small t, rho is then almost equal to t
% and the hankel function explodes for small values
if abs(t) < 0.001
%     if abs(t + 1./(h^2*K^3*sin(K.*s).*cos(K.*s)) + tan(K.*s)./K) < 0.01
%         res = 0;
%     else
        res = -(h*K^2)/(2*pi).*(cos(K.*s) - K*t/3.*sin(K.*s))./(1 + (h*K.*sin(K.*s)).^2 + t.*(h^2).*(K^3).*sin(K.*s).*cos(K.*s));
%     end
else
%     sine shape
    xi  = @(x) h*cos(K*x);
    dxi = @(x) -h*K*sin(K*x);
    rho = sqrt(t.^2 + (xi(s+t)-xi(s)).^2);
    B   = xi(s+t)-xi(s)-t.*dxi(s);
    res =  1i.*k./(2.*rho).*besselh(1,1,k.*rho).*B;
end
end

function I = myDblIntegration(func,xmin,xmax,ymin,ymax)

I = quadgk(@(y) innerIntegral(y,func,xmin,xmax),ymin,ymax);

end

%% subfunctions

function U = innerIntegral(y,fctn,xmin,xmax)

U = zeros(1,numel(y));
for iY = 1:numel(y)
    U(iY) = quadgk(@(x) fctn(x,y(iY)),xmin,xmax);
end
    
end