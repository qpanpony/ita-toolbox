function ellipsoidCoord = test_rbo_Ellipse2mSphere(an)
% Berechnet den Umweg auf der Ellipse durch mathematische Formel,
% Integral ersetzt durch Summe

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


a1 = an.headDepth;   % Ellipsenradius vorne (center - Nase, x-Achse)
a2 = an.headDepth;   % Ellipsenradius hinten (center - Hinterkopf, x-Achse)
aIn1 =  a1;
b  = an.headWidth;    % Kopfradius, halber Abstand zw den Ohren (y-Achse)
c  = an.headHeight;    % center - Scheitel (z-Achse)
phiIn = round(rad2deg(an.phi_Unique));
if isempty(find(phiIn<45,1,'first'))  || isempty(find(phiIn>135 & phiIn<225,1,'first')) || ...
        isempty(find(phiIn>315,1,'first')) 
   phi = unique([0:5:355 ,phiIn']);
else
    phi = phiIn';
end
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
        if currentTheta > 90
            a1 = test_marcia_get_aNew_Ellipse('az',phi,'el',currentTheta,'a',aIn1,'b',b,'c',b);
        else
            a1 = test_marcia_get_aNew_Ellipse('az',phi,'el',currentTheta,'a',aIn1,'b',b,'c',c);
        end
        a2 =a1;
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
        if quad1(iPhi) && quad4(iPhi)
            rSphere_R(iPhi,iTheta) = mean(b./sqrt(1-E1.*cosd(t_R).^2));
            rSphere_L(iPhi,iTheta) = mean(b./sqrt(1-E1.*cosd(t_L).^2));
        else
            rSphere_R(iPhi,iTheta) = mean(b./sqrt(1-E2.*cosd(t_R).^2));
            rSphere_L(iPhi,iTheta) = mean(b./sqrt(1-E2.*cosd(t_L).^2));
        end
        
    end
    
end

%% coordinates &  Interpolation between 75...105°
[thetaC,phiC] = meshgrid(an.theta_Unique,deg2rad(phi));
coord =itaCoordinates([ones(numel(phiC),1) thetaC(:) phiC(:)],'sph');

%idxCoord = 1:numel(phi)*numel(theta);%coord.findnearest(an.dirCoord);

try
    ellipsoidL = rSphere_L;
    ellipsoidR = rSphere_R;

    deltaPhi = 25;
    method = 'spline';
    phiC90 =  phi(phi<90-deltaPhi | phi>90+deltaPhi);
    phiC270 = phi(phi<270-deltaPhi | phi>270+deltaPhi);
    
    numPhi = numel(phi);

    for iTheta = 1:numPhi:numel(rSphere_R)
        ellipRc = ellipsoidR(iTheta:iTheta+numPhi-1);
        ellipLc = ellipsoidL(iTheta:iTheta+numPhi-1);
        
        ellipsoidRi(iTheta:iTheta+numPhi-1) = interp1(phiC90,...
            ellipRc(phi<90-deltaPhi | phi>90+deltaPhi),phi,method);
        ellipsoidLi(iTheta:iTheta+numPhi-1) = interp1(phiC270,...
            ellipLc(phi<270-deltaPhi  | phi>270+deltaPhi ),phi,method);
    end
    
   idxPhi = zeros(numel(theta),numel(phiIn));
   for iPhi = 1:numel(phiIn)
        idxPhi(:,iPhi)= find(round(coord.phi_deg) == round(phiIn(iPhi)));
   end
   idxPhi = idxPhi(:);
   
   ellipsoidCoord  = zeros(numel(phiIn)*numel(theta)*2,1);
   
   ellipsoidCoord(1:2:end) = ellipsoidLi(idxPhi);
   ellipsoidCoord(2:2:end) = ellipsoidRi(idxPhi);

 catch
    ellipsoidCoord  = zeros(numel(rSphere_R)*2,1);
    ellipsoidCoord(1:2:end) = rSphere_L(idxCoord);
    ellipsoidCoord(2:2:end) = rSphere_R(idxCoord);
end


if an.channelCoordinates.nPoints ~= numel(ellipsoidCoord)
    % Problem when HRTF has only 2 Channels at poles and not nPhi channels
    % in the  'same' location - 17.04.18 - hbr
    idx = coord.findnearest(an.dirCoord);
    chIdx = [2*idx-1, 2*idx].';
    ellipsoidCoord = ellipsoidCoord(chIdx(:));
end

% coord.surf(coord.r, ellipsoidRi)
% an.dirCoord.surf(an.dirCoord.r,ellipsoidCoord(1:2:end))     
end