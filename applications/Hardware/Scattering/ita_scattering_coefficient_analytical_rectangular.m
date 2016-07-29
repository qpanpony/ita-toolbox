function varargout = ita_scattering_coefficient_analytical_rectangular(varargin)
%ITA_SCATTERING_COEFFICIENT_ANALYTICAL_RECTANGULAR - analytic scattering coefficient for periodic rectangular profiles
%
% This function computes the scattering coefficient of periodic rectangular
% profiles, assuming that the extent is infinite.
%
% This function is based on Ducourneau's method described by Prof. Embrechts.
%
%  Syntax:
%   resultbjOut =
%   ita_scattering_coefficient_analytical_rectangular(freqVec,phiVec,width,L,hToL,options)
%
%   Options (default):
%           'c' (ita_constants('c')) : speed of sound
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_scattering_coefficient_analytical_rectangular">doc ita_scattering_coefficient_analytical_rectangular</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
%         Malte Buesing
% Created:  12-Oct-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_freqVec','vector', 'pos2_phiVec','vector', 'pos3_width','double', 'pos4_L','double','pos5_hToL','double', 'c', ita_constants('c'));
[freqVec,phiVec,width,L,hToL,sArgs] = ita_parse_arguments(sArgs,varargin); 

phiVec = phiVec.*pi/180;
c = double(sArgs.c);

%% constants
h = hToL*L; % ratio of height to spatial period
lambda = c./freqVec(:); % Wavelength
k = 2*pi./lambda; % Wavenumber

EPS = 1e-3; % stop criterion for infinite sum over u
NMax = 50; % truncation parameter for numbers of outgoing waves
NMax2 = 2*NMax+1;

X_u = zeros(1, NMax);
N = (-NMax:NMax).';
index0 = find(N == 0); % index0 corresponding to R_0
s = zeros(numel(freqVec), numel(phiVec)); % Directional scattering coefficients
previFreq = 0;

nFreq = numel(freqVec);
nPhi = numel(phiVec);
wb = itaWaitbar([nFreq, nPhi]); % itaWaitbar

%% calculation
for iFreq = 1:nFreq
    ita_verbose_info(['f = ' num2str(freqVec(iFreq)) ' Hz'],1);
    for iPhi = 1:nPhi
        str = sprintf('calculating freq %i', iFreq);
        wb.inc(str); %waitbar
        pause(0.05);
        phi_0 = phiVec(iPhi);
        alpha_0 = cos(phi_0);
        alpha_n = alpha_0 + N*lambda(iFreq)/L;
        beta_n = sin(acos(alpha_n));
        
        % some helper variables
        kFreq = k(iFreq);
        kAlpha_n = kFreq.*alpha_n(:).';
        kAlpha_n_width = kAlpha_n.*width;
        jkAlpha_n_over_2width = 1i.*kAlpha_n./(2*width);
        expkAlpha_n_width = exp(1i*kAlpha_n_width);
        
        Y_n_r = zeros(NMax2, NMax2);
        
        for iN = 1:NMax2
            uMax = zeros(1,NMax2);
            uMaxElement = 0;
            for iR = 1:NMax2
                uMax(iR) = 0;
                prevTempU = 0;
                err = 1;
                while err>EPS
                    uMax(iR) = uMax(iR) + NMax2-1;
                    
                    if iR==1
                        U_u_n = zeros(uMax(iR)+1, NMax2);
                    elseif uMax(iR) > uMaxElement
                        U_u_n = zeros(uMax(iR)+1, NMax2);
                    end
                    
                    if (iR==1 || (uMax(iR) > uMaxElement) || (iFreq > previFreq))
                            iU = (0:uMax(iR)).';
                            uVals = repmat(iU,[1 NMax2]);
                            k_x_u = iU.*pi/(2*width);
                            X_u = sqrt(kFreq.^2 - k_x_u.^2);

                            CaseA = logical(abs(bsxfun(@minus,kAlpha_n,k_x_u)) < 1e-3);
                            CaseB = logical(abs(bsxfun(@plus,kAlpha_n,k_x_u)) < 1e-3);
                            CaseC = logical(ones(size(CaseA)) - (CaseA + CaseB));
                            U_u_n(CaseA) = 0.5*exp(1i.*uVals(CaseA)*pi/2);
                            U_u_n(CaseB) = 0.5*exp(-1i.*uVals(CaseB)*pi/2);
                            tmp = bsxfun(@rdivide,jkAlpha_n_over_2width,bsxfun(@minus,k_x_u.^2,kAlpha_n.^2)) .* bsxfun(@minus,expkAlpha_n_width,bsxfun(@rdivide,(-1).^uVals,expkAlpha_n_width));
                            U_u_n(CaseC) = tmp(CaseC);
                    end
                    
                    tempU = sum((sign(iU)+1).*X_u.*tanh(1i.*X_u*h).*conj(U_u_n(iU+1,iN)).*U_u_n(iU+1,iR));
                     
                    err = abs((prevTempU - tempU)./prevTempU);
                    prevTempU = tempU;
                    previFreq = iFreq;
                    
                    if uMaxElement < uMax(iR)
                        uMaxElement = uMax(iR);
                    end 
                    
                end %while
                
                Y_n_r(iN,iR) = tempU*2*width./(kFreq.*L);
                
            end % iR
            
        end % iN
        
        b = sin(phi_0)*(2-(abs(sign(N))+1)) + Y_n_r(:,index0); %b for Ax=b; from Eq. 9
        A = diag(beta_n) - Y_n_r;
        % Solve Ax=b, with x=R_n
        
        R_n = lsqr(A,b, 1e-6, 1000); %lsqr
        %Test (Eq. 10) here
        validIds = abs(alpha_n) <= 1;
        checksum = sum((abs(R_n(validIds)).^2).*beta_n(validIds)./sin(phi_0)); % has to be 1
        absError = abs(checksum - 1);
        ita_verbose_info(['Sum of waves: ' num2str(checksum) ', Abs. err: ' num2str(absError)], 1);
        s(iFreq, iPhi) = 1 - abs(R_n(index0)).^2; % Scattering coefficient
        
    end % iPhi
end %iFreq

wb.close;

s = itaResult(s, freqVec, 'freq');
s.comment = 'Analytical solution of the scattering coefficient of rectangular profiles';
s.channelNames = cellstr([repmat('phi = ',numel(phiVec),1) num2str(round(phiVec(:).*180/pi))]);
s.allowDBPlot = 0;

%% Add history line
s = ita_metainfo_add_historyline(s,mfilename,varargin);

%% Set Output
varargout(1) = {s}; % Directional scattering coefficient
if nargout > 1 && numel(phiVec) > 1
    % also return the random incidence coefficient
    % integrate over frequency and incident angle
    s_direc = s.freq;
    s_randMat = zeros(s.nBins,1);
    % integrate over frequency with Gauss-Chebyshev Quadrature
    for iFreq = 2:s.nBins
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
    s_rand = s;
    s_rand.freq = s_randMat;
    s_rand.channelNames = cellstr('random incidence');
    varargout{2} = s_rand;
end

%end function
end