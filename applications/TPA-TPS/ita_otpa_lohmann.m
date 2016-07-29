% /-----------------------------------------------------------------------\
% OTPA
% System identification and transfer function estimation in
% Operational Path Analysis (OPA) via matrix inversion of operational data
% matrix and regularization techniques including Tikhonov, Singular Value
% Rejection (SVR) and Moore-Penrose pseudo inverse.
%
% SYNTAX
% main script
%
% DESCRIPTION
% input data: vectors or matrices of operational data
% output data: calculated total and partial sound pressures
%
% REFERENCES
% [1] Choi,H.; Thite,A. & Thompson,D.J. (2007), Comparison of methods for
% parameter selection in Tikhonov regularization with application to
% inverse force determination, J. Sound and Vibration; 304, pP.894-917
% [2] Choi,H.; Thite,A. & Thompson,D.J. (2006), A threshold for the use
% of Tikhonov regularization in inverse force determination, Applied
% Acoustics 67, pp. 700-719
% [3] Thite, A. & Thompson, D. (2003), The quantification of structure-borne
% transmission paths by inverse methods. Part 1: Improved singular value
% rejection methods, J. Sound and Vibration, 264, pp.411-431
% [4] Thite, A. & Thompson, D. (2003), 'The quantification of structure-borne
% transmission paths by inverse methods. Part 2: Use of regularization
% techniques', J. Sound and Vibration, 264, pp.433-451
%
%
% Timo Lohmann (CR/ARU1)                                    (c) 23 Apr 2008
% \-----------------------------------------------------------------------/

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


clear all; close all;

Lresindex = [10 50 100 500];

% laden mehrerer Sets von Betriebszuständen
for meas_index = 1:4
    clear A ak Hk p pk H_moore p_moore H_svr p_svr H_tikho p_tikho i j k n m d dmin U S V c
    
    time = clock;
    disp([' ']);
    disp(['Simulation started: ',num2str(time(4)),':',num2str(time(5))]);
    
    % sizes
    m = 111;
    n = 33;
    
    for i = 1:m
        measOP(i,1)  = load(strcat('X:\Matlab\OPA_full\Betriebsmatrix\','Meas',num2str(i),'.MAT'));
        measSPL(i,1) = load(strcat('X:\Matlab\OPA_full\Schalldruckvektor\','Meas',num2str(i),'.MAT'));
    end
    for i = 1:m % OPs
        for j = 1:n % Paths
            A(i,j,:) = measOP(i,1).shdf.Data(j,:);
        end
    end
    for i = 1:m % OPs
        p(i,:) = measSPL(i,1).shdf.Data(1,:);
    end
    
    N = 1250; % Block length
    
    
    %% Ordinary cross validation
    % lambda range and spacing
    space  = 'exp'; % linear or exp lambda spacing
    expMin = -6;    % minimum exponent for lambda
    expMax = 1;     % maximum exponent for lambda
    Lres   = Lresindex(meas_index); % No. lambda values (resolution) (=Lres+1)
    if (strcmp(space,'exp'))
        % comments Prof. Thompson (ISVR):
        % - log spacing seems to be better than lin spacing
        % - start with wide ranges and many values of lambda
        % - too big ranges tend to overestimate solution (and vice versa)
        exp = expMin:((expMax-expMin)/Lres):expMax; % exponential lambda range
        L = zeros(length(exp),1);
        for z = 1:length(exp)
            L(z) = 10^(exp(z));
        end
    elseif (strcmp(space,'lin'))
        L = (10^expMin):((10^expMax-10^expMin)/Lres):(10^expMax);
    else
        disp('No valid lambda spacing');
    end
    
    %% initialization
    Lopt    = zeros(N,1);
    c       = zeros (N,1); % condition number with respect to eigenvalues
    c_svr   = 1000; % SVR threshold for setting singular values = 0
    %c_cross = 10^(0.13*n - 0.055*m + 1.28); % cross-over cond. number, see [2]
    Ak      = A;
    pk      = p;
    d       = zeros(length(L),1); % cross validation distance
    H_moore = zeros(n,N);
    H_tikho = zeros(n,N);
    H_thres = zeros(n,N);
    S       = zeros(m,n); % contains singular values
    V       = zeros(m,n); % unitary: V'*V = I
    U       = zeros(m,m); % unitary: U'*U = I
    
    %% matrix inversion
    tic;                                % start timer
    wait = waitbar(0,'Processing ...'); % initialize waitbar
    for i = 1 : N                       % index frequency
        for j = 1 : length(L)           % index lambda
            % begin ordinary cross validation
            for k = 1 : m               % index operational mode
                Ak      = A(:,:,i); % copy operational data matrix
                Ak(k,:) = [];       % delete k-th row: A -> Ak
                pk      = p(:,i);   % copy SPL-matrix
                pk(k,:) = [];       % delete k-th column (=path): p -> pk
                [U,S,V] = svd(Ak);  % decomposition reduced operational matrix
                %Hk      = V*(transpose(S)*S+eye(n)*L(j))^-1 * transpose(S)*U'*pk;
                Hk      = V * (S'*S + eye(n)*L(j))^-1 * S'*U'*pk;
                d(j)    = d(j) + abs( p(k,N) - A(k,:,i)*Hk )^2; % sum of distances
            end
            d(j) = 1/m *d(j);      % distance for each lambda
            % end(ordinary cross validation)
        end
        % find and set optimal lambda
        dmin = find(d==min(d));  % minimum distance -> optimal lambda
        if (isnan(dmin))         % just in case of numerical problems
            Lopt(i) = Lopt(i-1); % take optimal lambda from iteration before
        else
            Lopt(i) = L(dmin(1)); % find minimum disctance and set optimal lambda
        end
        % singular value decompositions
        [U,S,V] = svd(A(:,:,i)); % decomposition complete operational matrix
        c(i)    = cond(S); % condition number at frequency i
        
        % Tikhonov solution
        H_tikho(:,i) = V*(S'*S+eye(n)*Lopt(i))^-1 * S'*U'*p(:,i);
        %H_tikho(:,i) = V*(transpose(S)*S+eye(n)*Lopt(i))^-1 * transpose(S)*U'*p(:,i);
        
        % Moore-Penrose solution
        H_moore(:,i)    = V*pinv(S)*U'*p(:,i);
        
        %     % Combined solution - threshold for Tikhonov regularization
        %     if (c(i) > c_cross)
        %         H_thres(:,i) = H_tikho(:,i); % apply Tikhonov solution
        %     else
        %         H_thres(:,i) = H_moore(:,i); % apply Moore-Penrose pseudo inverse
        %     end
        
        % Singular Value Rejection solution
        for c_index = 1 : n
            if (c_svr < cond(S(1:c_index,1:c_index)))
                break % get index for wich c_svr < actual condition number
            end
        end
        H_svr(:,i) = V*pinv(S,S(c_index,c_index))*U'*p(:,i);
        
        % calculation time estimate (just for user info)
        if (i==3)               % calculate time estimate after 3 iterations
            testimate = toc;    % stop estimated calc timer
            testimate = testimate*N/3; % total estimated calc time
            disp(['Time estimate:   ',num2str(testimate),' seconds']);
            disp(' ');
        end
        waitbar(i/N); % update waitbar
    end
    close(wait); % close waitbar
    tcalc = toc;
    
    %% optional: some status calculations
    % [Lhist,Lvec] = hist(Lopt,L); % calculate histogramm of optimal lambdas
    % Lnum         = length(nonzeros(Lhist)); % different opt. lambdas
    
    %% Transfer Path Synthesis
    % predicted overall sound pressure
    for i = 1 : N
        p_moore(:,i) = A(:,:,i) * H_moore(:,i);
        p_tikho(:,i) = A(:,:,i) * H_tikho(:,i);
        %     p_thres(:,i) = A(:,:,i) * H_thres(:,i);
        p_svr(:,i)   = A(:,:,i) * H_svr(:,i);
    end
    figure; hold on; grid;
    plot([4:4:N*4],20*log10(abs(p(1,1:N))./2e-5),'k');
    plot([4:4:N*4],20*log10(abs(p_moore(1,:))./2e-5),'cyan');
    plot([4:4:N*4],20*log10(abs(p_tikho(1,:))./2e-5),'g');
    % plot([4:4:N*4],20*log10(abs(p_thres(1,:))./2e-5),'r');
    plot([4:4:N*4],20*log10(abs(p_svr(1,:))./2e-5),'b');
    legend('Measured','Moore-Penrose','Tikhonov','SVR');
    hold off;
    
    % partial sound pressures for every path in OP sequences 21 and 36
    for i = 1 : 33
        p_part_moore_21(i,:)  =  squeeze(A(21,i,1:N)) .* transpose(H_moore(i,:));
        p_part_moore_36(i,:)  =  squeeze(A(36,i,1:N)) .* transpose(H_moore(i,:));
        p_part_tikho_21(i,:)  =  squeeze(A(21,i,1:N)) .* transpose(H_tikho(i,:));
        p_part_tikho_36(i,:)  =  squeeze(A(36,i,1:N)) .* transpose(H_tikho(i,:));
        p_part_svr_21(i,:)    =  squeeze(A(21,i,1:N)) .* transpose(H_svr(i,:));
        p_part_svr_36(i,:)    =  squeeze(A(36,i,1:N)) .* transpose(H_svr(i,:));
    end
    
    %% command window status
    disp('------------------------------------------------------------------');
    disp('X                          S T A T U S                           X');
    disp('------------------------------------------------------------------');
    disp(' ');
    disp(['Condition (min):  ',num2str(min(c))]);
    disp(['Condition (max):  ',num2str(max(c))]);
    disp(['Lambda (min):     ',num2str(min(Lopt))]);
    disp(['Lambda (max):     ',num2str(max(Lopt))]);
    %disp(['Lambda spread:    ',num2str(Lnum),' (from ',num2str(Lres+1),')']);
    disp(['Elapsed time:     ',num2str(tcalc),' seconds']);
    disp(' ');
    
    simpath = 'X:\Matlab\OPA_full\01_Results\';
    simfile = strcat(simpath,'Sim_',num2str(meas_index),'.mat');
    save(simfile);
end
% EOF