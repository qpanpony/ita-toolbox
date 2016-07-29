function ellipsoid = test_rbo_Ellipse2Sphere(an)
% Berechnet den Umweg auf der Ellipse durch mathematische Formel,
% Integral ersetzt durch Summe

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


a1 = an.headDepth;   % Ellipsenradius vorne (center - Nase, x-Achse)
a2 = an.headDepth;   % Ellipsenradius hinten (center - Hinterkopf, x-Achse)
aIn1 =  a1;aIn2 =  a2;
b  = an.headWidth;    % Kopfradius, halber Abstand zw den Ohren (y-Achse)
c  = an.headHight;    % center - Scheitel (z-Achse)
phi = rad2deg(an.phi_Unique);
theta = rad2deg(an.theta_Unique);


phiMod = mod(phi,360);
quad1 = phiMod >= 0 & phiMod < 90 ;    % 1. Quadrant
quad4 = phiMod >= 270 & phiMod < 360; % 4. Quadrant
quad3 = phiMod >= 180 & phiMod < 270; % 3. Quadrant
quad2 = phiMod >= 90 & phiMod < 180;  % 2. Quadrant

rSphere_R = zeros(numel(phi),numel(theta));
rSphere_L = zeros(numel(phi),numel(theta));

for iTheta = 1:numel(theta)
    %% Ellipses
    currentTheta = theta(iTheta);
    if currentTheta ~= 90
        
        % bei anderen Winkeln a1 aus "aNew_Ellipse":
        a1 = test_marcia_get_aNew_Ellipse('az',phi,'el',currentTheta,'a',aIn1,'b',b,'c',c);
        a2 = test_marcia_get_aNew_Ellipse('az',phi,'el',currentTheta,'a',aIn2,'b',b,'c',c);
        
    end
    
    alpha1 = 90;    % Startwinkel für die Berechnung der Bogenlänge der Ellipse
    beta1 = 270;
    
    alpha2Vec = zeros(numel(phi),1);
    beta2Vec = zeros(numel(phi),1);
    alphaStep = 0.001;
    
    for iPhi = 1:numel(phi)
        
        currentPhi = mod(phi(iPhi),360);
        
        if quad1(iPhi)       % 1.Quadrant
            alpha2Vec(iPhi) = currentPhi;
            beta2Vec(iPhi) = 180 - currentPhi;
        elseif quad4(iPhi)
            alpha2Vec(iPhi) = 540 - currentPhi;
            beta2Vec(iPhi) = currentPhi;
        elseif quad3(iPhi)
            alpha2Vec(iPhi) = currentPhi;
            beta2Vec(iPhi) = currentPhi;
        elseif quad2(iPhi)
            alpha2Vec(iPhi) = currentPhi;
            beta2Vec(iPhi) = currentPhi;
        end
    end
    
    %% calculate detour on ellipse
    distVec_R = zeros(size(alpha2Vec)); % detour for each ear depending on azimutal angle
    distVec_L = zeros(size(alpha2Vec));
    for iPhi = 1:numel(phi)
        alpha2 = alpha2Vec(iPhi);
        beta2 = beta2Vec(iPhi);
              
        
        if currentTheta == 0
            t_L = 0:alphaStep:alpha1;
            t_R = beta1:alphaStep:360;
        else
            t_L = min(alpha1,alpha2):alphaStep:max(alpha1,alpha2);
            t_R = min(beta1,beta2):alphaStep:max(beta1,beta2);
        end
        
        if numel(a1) == 1
            currentA1 = a1;
            currentA2 = a2;
        else
            currentA1 = a1(iPhi);
            currentA2 = a2(iPhi);
        end
  
        E1 = ((currentA1^2-b^2) / currentA1^2);
        E2 = ((currentA2^2-b^2) / currentA2^2);
        
        % formula to calculate detour: "großes handbuch der mathematik", p. 494, integral approximated by sum about infinitesimal alphaStep
        if quad1(iPhi)
            distVec_R(iPhi) = currentA1 * sum(sqrt(1 - E1  * cosd(t_R).^2)) * alphaStep / 180 * pi;
            distVec_L(iPhi) = currentA1 * sum(sqrt(1 - E1  * cosd(t_L).^2)) * alphaStep / 180 * pi;
        elseif quad4(iPhi)
            distVec_R(iPhi) = currentA1 * sum(sqrt(1 - E1  * cosd(t_R).^2)) * alphaStep / 180 * pi;
            distVec_L(iPhi) = currentA1 * sum(sqrt(1 - E1  * cosd(t_L).^2)) * alphaStep / 180 * pi;
        elseif quad3(iPhi)
            distVec_R(iPhi) = currentA2 * sum(sqrt(1 - E2  * cosd(t_R).^2)) * alphaStep / 180 * pi;
            distVec_L(iPhi) = currentA2 * sum(sqrt(1 - E2  * cosd(t_L).^2)) * alphaStep / 180 * pi;
        elseif quad2(iPhi)
            distVec_R(iPhi) = currentA2 * sum(sqrt(1 - E2  * cosd(t_R).^2)) * alphaStep / 180 * pi;
            distVec_L(iPhi) = currentA2 * sum(sqrt(1 - E2  * cosd(t_L).^2)) * alphaStep / 180 * pi;
        end
        
    end
    
    alpha = zeros(numel(phi),1);
    
    for iPhi = 1:numel(phi)
        
        currentPhi = mod(phi(iPhi),360);
        
        if quad1(iPhi)
            alpha(iPhi) = 90 - currentPhi;
        elseif quad4(iPhi)
            alpha(iPhi) = 450 - currentPhi;
        elseif quad3(iPhi)
            alpha(iPhi) = currentPhi - 90;
        elseif quad2(iPhi)
            alpha(iPhi) = currentPhi - 90;
        end
    end
    
    beta = 180 - alpha;
    
    rSphere_R(:,iTheta) = distVec_R*360./(2*pi*beta);
    rSphere_L(:,iTheta) = distVec_L*360./(2*pi*alpha);
end

rSphere_R(rSphere_R==Inf) = rSphere_R(find(rSphere_R==Inf)-1);
rSphere_L(rSphere_L==Inf) = rSphere_L(find(rSphere_L==Inf)-1);


%% coordinates
[thetaC,phiC] = meshgrid(an.theta_Unique,an.phi_Unique);
coord =itaCoordinates([an.dirCoord.r thetaC(:) phiC(:)],'sph');

idxCoord = coord.findnearest(an.dirCoord);

ellipsoid  = zeros(numel(rSphere_R)*2,1);
ellipsoid(1:2:end) = rSphere_L(idxCoord);
ellipsoid(2:2:end) = rSphere_R(idxCoord);

end
