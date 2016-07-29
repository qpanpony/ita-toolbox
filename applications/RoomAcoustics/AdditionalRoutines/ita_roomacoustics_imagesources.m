function isIR = is_part_IR(sPos, rPos, Z, Lx, Ly, Lz, c, rho0, t_max, sR, angleDependant, shiftToSample)
% Spiegelschallquellen Berechnung für Quaderraum

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Raum hat seinen Mittelpunkt bei (x,y,z) = (0,0,0)
%
% Nummerierung der 6 Wände
% Decke = 5
% Boden = 6
%
%    ____3____        y
%   |         |        ^
%  2|    x    |1       |
%   |_________|        |--> x
%        4  
%
%     x = origin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmaxStr = num2str(t_max*1000);
fftDegree = ceil(log2(t_max*sR));

if numel(Z)==1
    % assume same surface impedance on all surfaces
    ZTmp = Z;
    Z = [ZTmp, ZTmp, ZTmp, ZTmp, ZTmp, ZTmp];
elseif numel(Z)==6
    % different surface impedance for all surfaces
    % do nothing
else
    error('numel(Z) needs to be either 1 or 6');
end

% Maximale Ordnung
maxOrderX = floor(c*t_max/Lx);
maxOrderY = floor(c*t_max/Ly);
maxOrderZ = floor(c*t_max/Lz);

% Berechnung der Spiegelschallquellen
% IS = cell( 2*maxOrderX+1 , 2*maxOrderY+1 , 2*maxOrderZ+1 );
numelIS = (2*maxOrderX+1) * (2*maxOrderY+1) * (2*maxOrderZ+1);

IS_order  = zeros(numelIS,3);
IS_list   = zeros(numelIS,3);
IS_d      = zeros(numelIS,1);
IS_t      = zeros(numelIS,1);
IS_theta  = NaN(numelIS,3);

idx_list = 1;

if isnumeric(Z) % That means frequency constant surface impedance on all six walls

    % Calculate Image Sources
    IS_p      = zeros(numelIS,1);
    
    if ~angleDependant
        refl(1) = (Z(1) - rho0*c)/(Z(1) + rho0*c);
        refl(2) = (Z(2) - rho0*c)/(Z(2) + rho0*c);
        refl(3) = (Z(3) - rho0*c)/(Z(3) + rho0*c);
        refl(4) = (Z(4) - rho0*c)/(Z(4) + rho0*c);
        refl(5) = (Z(5) - rho0*c)/(Z(5) + rho0*c);
        refl(6) = (Z(6) - rho0*c)/(Z(6) + rho0*c);
    end
    
    for nx = -maxOrderX:1:maxOrderX
        for ny = -maxOrderY:1:maxOrderY
            for nz = -maxOrderZ:1:maxOrderZ
                              
                order  = [nx,ny,nz];
                coords = [nx*Lx + (-1)^mod(nx,2)*sPos(1) , ny*Ly + (-1)^mod(ny,2)*sPos(2) , nz*Lz + (-1)^mod(nz,2)*sPos(3)];
                d      = norm(rPos - coords);
                t      = d / c;
                
                if t <= t_max
                % if sum(abs(order))<=13
                    
                    if angleDependant
                        % Calculate angles of incidence. Im Quadderraum gibt es
                        % für jede SSQ (egal welcher Ordnung) immer nur 3
                        % Einfallswinkel. Dies sind die Schnittwinkel mit den
                        % elementaren Ebenen x=0; y=0; z=0
                        
                        theta_x = acos(abs(coords(1)-rPos(1))/d);
                        theta_y = acos(abs(coords(2)-rPos(2))/d);
                        theta_z = acos(abs(coords(3)-rPos(3))/d);
                        IS_theta(idx_list,:)  = [theta_x, theta_y, theta_z];
                        
                        refl(1) = (Z(1)*cos(theta_x) - rho0*c)/(Z(1)*cos(theta_x) + rho0*c);
                        refl(2) = (Z(2)*cos(theta_x) - rho0*c)/(Z(2)*cos(theta_x) + rho0*c);
                        refl(3) = (Z(3)*cos(theta_y) - rho0*c)/(Z(3)*cos(theta_y) + rho0*c);
                        refl(4) = (Z(4)*cos(theta_y) - rho0*c)/(Z(4)*cos(theta_y) + rho0*c);
                        refl(5) = (Z(5)*cos(theta_z) - rho0*c)/(Z(5)*cos(theta_z) + rho0*c);
                        refl(6) = (Z(6)*cos(theta_z) - rho0*c)/(Z(6)*cos(theta_z) + rho0*c);
                    end
                    
                    p_magn = 1/d * ...
                        (refl(1)*refl(2))^floor(abs(nx)/2) * ( refl(1)*(1+sign(nx))/2 + refl(2)*(1-sign(nx))/2 )^mod(nx,2) * ...
                        (refl(3)*refl(4))^floor(abs(ny)/2) * ( refl(3)*(1+sign(ny))/2 + refl(4)*(1-sign(ny))/2 )^mod(ny,2) * ...
                        (refl(5)*refl(6))^floor(abs(nz)/2) * ( refl(5)*(1+sign(nz))/2 + refl(6)*(1-sign(nz))/2 )^mod(nz,2);
                    
                    IS_order(idx_list,:)  = order;
                    IS_list(idx_list,:) = coords;
                    IS_t(idx_list)      = t;
                    IS_d(idx_list)      = d;
                    IS_p(idx_list)      = p_magn;
                    idx_list = idx_list+1;
                end
                
            end
        end
    end
    
    IS_order(idx_list:numelIS,:) = [];
    IS_list(idx_list:numelIS,:) = [];
    IS_t(idx_list:numelIS,:) = [];
    IS_d(idx_list:numelIS,:) = [];
    IS_p(idx_list:numelIS,:) = [];
    IS_theta(idx_list:numelIS,:) = [];
    
    [IS_t_sort, sortIdx] = sort(IS_t, 'ascend');
    IS_d_sort            = IS_d(sortIdx);
    IS_p_sort            = IS_p(sortIdx);
    IS_list_sort         = IS_list(sortIdx,:);
    IS_order_sort        = IS_order(sortIdx,:);
    IS_theta_sort        = IS_theta(sortIdx,:);
    
    DEBUG_params.IScoords = IS_list_sort;
    DEBUG_params.theta    = IS_theta_sort;
    DEBUG_params.IS_order_3D = IS_order_sort;
    DEBUG_params.IS_order = sum(abs(IS_order_sort), 2);
    save('DEBUG_params.mat', 'DEBUG_params');
    
    % In ein itaAudio packen
    isIR =  ita_generate('flat',0,sR,fftDegree);
    isIR.signalType = 'energy';
    
    %%% Für Alternative 1
    % tVec = isIR.timeVector;
    
    %%%% Für Alternative 2
    omega = 2*pi*isIR.freqVector;
    TF = isIR.freqData;
    TD = isIR.timeData;
    
    ntotal = num2str(numel(IS_t_sort));
    
    % IR Synthesis
    for n = 1:numel(IS_t_sort)
        
        if ~shiftToSample
            %%% Alternative 1 (Time Domain)
            % isIR.timeData = isIR.timeData + IS_p_sort(n) * sinc((tVec-IS_t_sort(n))*sR);
            
            %%% Alternative 2 (Freq Domain)
            TF = TF + IS_p_sort(n) * exp(-1i*IS_t_sort(n)*omega);
        else
            %%% Alternative 3 (Time Domain -> Shift to next sample Position)
            %%% ACHTUNG: DAS FUNKTIONIERT NUR BEI REELEN
            %%% REFLEKTIONSFAKTOREN !!!!!!!!
            TD(round(IS_t_sort(n)*sR)+1) = TD(round(IS_t_sort(n)*sR)+1) + IS_p_sort(n);
        end
        
        if mod(n,100)==0
            disp([num2str(n), '/', ntotal]);
        end
        
    end
    
    if ~shiftToSample
        isIR.freqData = TF;
    else
        isIR.timeData = TD;
    end
    
    
%     figure(1);
%     stem(IS_t_sort, abs(IS_p_sort), 'MarkerSize', 2);
%     title([ 'IS Time Instants and Amplitudes, maxOrderX=' num2str(maxOrderX) ', maxOrderY=' num2str(maxOrderY) ', maxOrderZ=' num2str(maxOrderZ) ]);
    % saveas(gcf , ['.\Results\Plots\IS_timeInstants_tmax' tmaxStr 'msec.fig'] , 'fig');

elseif isa(Z, 'itaAudio')
    
    % for k=1:6
    %    Z(k) = ita_extract_dat(Z(k),fftDegree,'symmetric');
    % end
    Z1 = Z(1).freqData;
    Z2 = Z(2).freqData;
    Z3 = Z(3).freqData;
    Z4 = Z(4).freqData;
    Z5 = Z(5).freqData;
    Z6 = Z(6).freqData;
    
    if ~angleDependant
        refl1_cur = (Z1 - rho0*c)./(Z1 + rho0*c);
        refl2_cur = (Z2 - rho0*c)./(Z2 + rho0*c);
        refl3_cur = (Z3 - rho0*c)./(Z3 + rho0*c);
        refl4_cur = (Z4 - rho0*c)./(Z4 + rho0*c);
        refl5_cur = (Z5 - rho0*c)./(Z5 + rho0*c);
        refl6_cur = (Z6 - rho0*c)./(Z6 + rho0*c);
    else % precalculate reflection factors for all angles of incidence
        thetas = (0:1:90) * pi/180;
        for k=1:numel(thetas)
           refl_theta1(:,k) = (Z1.*cos(thetas(k)) - rho0*c)./(Z1.*cos(thetas(k)) + rho0*c);
           refl_theta2(:,k) = (Z2.*cos(thetas(k)) - rho0*c)./(Z2.*cos(thetas(k)) + rho0*c);
           refl_theta3(:,k) = (Z3.*cos(thetas(k)) - rho0*c)./(Z3.*cos(thetas(k)) + rho0*c);
           refl_theta4(:,k) = (Z4.*cos(thetas(k)) - rho0*c)./(Z4.*cos(thetas(k)) + rho0*c);
           refl_theta5(:,k) = (Z5.*cos(thetas(k)) - rho0*c)./(Z5.*cos(thetas(k)) + rho0*c);
           refl_theta6(:,k) = (Z6.*cos(thetas(k)) - rho0*c)./(Z6.*cos(thetas(k)) + rho0*c);
        end
        
        for m=1:6
            refl_iA(m) =  ita_generate('flat',0,sR,fftDegree);
            refl_iA(m).signalType = 'energy';
            refl_iA(m).freqData = eval(['refl_theta', int2str(m)]);
            refl_iA_tw(m) = ita_time_window(refl_iA(m), [0.02 0.022], 'time', 'symmetric');
            eval(['refl' int2str(m) '= refl_iA_tw(' int2str(m) ').freqData;']);
        end
    end
    
    IS_p  = zeros(Z(1).nBins,1);
    omega = 2*pi*Z(1).freqVector;

    % Calculate Image Sources and create IR
    count = 1;
    ntotal = num2str(numelIS);
    for nx = -maxOrderX:1:maxOrderX
        for ny = -maxOrderY:1:maxOrderY
            for nz = -maxOrderZ:1:maxOrderZ
                                
                order  = [nx,ny,nz];
                coords = [nx*Lx + (-1)^mod(nx,2)*sPos(1) , ny*Ly + (-1)^mod(ny,2)*sPos(2) , nz*Lz + (-1)^mod(nz,2)*sPos(3)];
                d      = norm(rPos - coords);
                t      = d / c;
                
                if t <= t_max

                    % tic
                    if angleDependant
                        % Calculate angles of incidence. Im Quadderraum gibt es
                        % für jede SSQ (egal welcher Ordnung) immer nur 3
                        % Einfallswinkel. Dies sind die Schnittwinkel mit den
                        % elementaren Ebenen x=0; y=0; z=0
                        
                        theta_x = acos(abs(coords(1)-rPos(1))/d);
                        theta_y = acos(abs(coords(2)-rPos(2))/d);
                        theta_z = acos(abs(coords(3)-rPos(3))/d);
                        
                        [val,x_idx] = min(abs(theta_x-thetas));
                        [val,y_idx] = min(abs(theta_y-thetas));
                        [val,z_idx] = min(abs(theta_z-thetas));
                        
                        %refl1 = (Z1.*cos(theta_x) - rho0*c)./(Z1.*cos(theta_x) + rho0*c);
                        %refl2 = (Z2.*cos(theta_x) - rho0*c)./(Z2.*cos(theta_x) + rho0*c);
                        %refl3 = (Z3.*cos(theta_y) - rho0*c)./(Z3.*cos(theta_y) + rho0*c);
                        %refl4 = (Z4.*cos(theta_y) - rho0*c)./(Z4.*cos(theta_y) + rho0*c);
                        %refl5 = (Z5.*cos(theta_z) - rho0*c)./(Z5.*cos(theta_z) + rho0*c);
                        %refl6 = (Z6.*cos(theta_z) - rho0*c)./(Z6.*cos(theta_z) + rho0*c);
                        
                        refl1_cur = refl1(:,x_idx);
                        refl2_cur = refl2(:,x_idx);
                        refl3_cur = refl3(:,y_idx);
                        refl4_cur = refl4(:,y_idx);
                        refl5_cur = refl5(:,z_idx);
                        refl6_cur = refl6(:,z_idx);
                        
                    end

                    p_freqDomain = 1/d .* ...
                        (refl1_cur.*refl2_cur).^floor(abs(nx)/2) .* ( refl1_cur.*((1+sign(nx))/2) + refl2_cur.*((1-sign(nx))/2) ).^mod(nx,2) .* ...
                        (refl3_cur.*refl4_cur).^floor(abs(ny)/2) .* ( refl3_cur.*((1+sign(ny))/2) + refl4_cur.*((1-sign(ny))/2) ).^mod(ny,2) .* ...
                        (refl5_cur.*refl6_cur).^floor(abs(nz)/2) .* ( refl5_cur.*((1+sign(nz))/2) + refl6_cur.*((1-sign(nz))/2) ).^mod(nz,2);
                    
                    IS_order(idx_list,:)  = order;
                    IS_list(idx_list,:) = coords;
                    IS_t(idx_list)      = t;
                    IS_d(idx_list)      = d;
                    IS_p                = IS_p + p_freqDomain .* exp(-1i*t*omega);
                    
                    % TEST(1:numel(p_freqDomain),idx_list) = p_freqDomain .* exp(-1i*t*omega);
                    
                    idx_list = idx_list+1;
                    % toc
                end
                
                if mod(count,10000)==0
                    disp([num2str(count), '/', ntotal]);
                end
                count = count+1;
                
            end
        end
    end
    
    IS_order(idx_list:numelIS,:) = [];
    IS_list(idx_list:numelIS,:) = [];
    IS_t(idx_list:numelIS,:) = [];
    IS_d(idx_list:numelIS,:) = [];
       
    [IS_t_sort, sortIdx] = sort(IS_t, 'ascend');
    IS_d_sort            = IS_d(sortIdx);
    IS_list_sort         = IS_list(sortIdx,:);
    IS_order_sort        = IS_order(sortIdx,:);
    
    % In ein itaAudio packen
    isIR =  ita_generate('flat',0,sR,fftDegree);
    isIR.signalType = 'energy';
    isIR.freqData = IS_p;

%     figure(1);
%     stem(IS_t_sort, ones(numel(IS_t_sort),1), 'MarkerSize', 2);
%     title([ 'IS Time Instants, maxOrderX=' num2str(maxOrderX) ', maxOrderY=' num2str(maxOrderY) ', maxOrderZ=' num2str(maxOrderZ) ]);
    % saveas(gcf , ['.\Results\Plots\IS_timeInstants_tmax' tmaxStr 'msec.fig'] , 'fig');

    
else
    error('Reflection Factor needs to be given as either a frequency constant value or as an itaAudio');
end

% figure(2);
% title('average time spacing between reflections as a function of time')
% IS_deltaT = IS_t_sort(2:end) - IS_t_sort(1:end-1);
% deltaT_analytic = (Lx*Ly*Lz)./(4.*pi.*c^3.*IS_t_sort(2:end).^2);
% plot(IS_t_sort(2:end), [IS_deltaT(1:10); smooth(IS_deltaT(11:50),5); smooth(IS_deltaT(51:end), 20)], IS_t_sort(2:end), deltaT_analytic);
% saveas(gcf , ['.\Results\Plots\deltaT_tmax' tmaxStr 'msec.fig'] , 'fig');

% figure(3);
% plot3( IS_list_sort(:,1), IS_list_sort(:,2), IS_list_sort(:,3), 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', 2 );
% set(gca, 'XGrid', 'on', ...
%          'YGrid', 'on', ...
%          'ZGrid', 'on', ...
%          'XLim',  [ -maxOrderX*Lx - Lx/2 , maxOrderX*Lx + Lx/2 ], ...
%          'YLim',  [ -maxOrderY*Ly - Ly/2 , maxOrderY*Ly + Ly/2 ], ...
%          'ZLim',  [ -maxOrderZ*Lz - Lz/2 , maxOrderZ*Lz + Lz/2 ], ...
%          'xTick', [-maxOrderX*Lx - Lx/2 : Lx : maxOrderX*Lx + Lx/2 ], ...
%          'yTick', [-maxOrderY*Ly - Ly/2 : Ly : maxOrderY*Ly + Ly/2 ], ...
%          'zTick', [-maxOrderZ*Lz - Lz/2 : Lz : maxOrderZ*Lz + Lz/2 ], ...
%          'xTickLabel', [-maxOrderX*Lx - Lx/2 : Lx : maxOrderX*Lx + Lx/2 ].', ...
%          'yTickLabel', [-maxOrderY*Ly - Ly/2 : Ly : maxOrderY*Ly + Ly/2 ].', ...
%          'zTickLabel', [-maxOrderZ*Lz - Lz/2 : Lz : maxOrderZ*Lz + Lz/2 ].' ...
%          );
% saveas(gcf , ['.\Results\Plots\IS_spatialDistribution_tmax' tmaxStr 'msec.fig'] , 'fig');
     
% isIR = ita_extend_dat(isIR, fftDegree);
isIR.userData.maxNx = maxOrderX;
isIR.userData.maxNy = maxOrderY;
isIR.userData.maxNz = maxOrderZ;

% isIR = ita_mpb_filter(isIR, [20 0], 'order', 8);

