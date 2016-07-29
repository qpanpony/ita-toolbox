function a_newEllipse = test_marcia_get_aNew_Ellipse(varargin)

% doesnt work for el = 90;

sArgs           = struct('az',0:360,'el',85,'a',0.1,'b',0.075,'c',0.15);
sArgs           = ita_parse_arguments(sArgs,varargin);

% example:
% a_new = test_marcia_get_aNew_Ellipse('az',0:360,'el',85,'a',0.1,'b',0.075,'c',0.15);

az = sArgs.az;
el = sArgs.el;
a  = sArgs.a;
b  = sArgs.b;
c  = sArgs.c;

if el == 90
    error('invalid input argument (el = 90°)')
end

% Weg, der auf Ellipsoid zurückgelegt wird.

%% Parameter and Coordinates
% a Schnittpunkt mit der x-Achse (Nase)
% b          "           y-Achse (Ohren)
% c          "           z-Achse (Scheitel)

r = 1;

a_newEllipse = zeros(numel(az),1);
k1 = zeros(numel(az),1);
k2 = zeros(numel(az),1);

z = zeros(numel(az),1);
x = zeros(numel(az),1);

for iAz = 1:numel(az)
    
    currentAz = az(iAz);
    
    %% plane
    %points
    p1 = [0  b 0];   % 1. Bezugspunkt für die Ebene: linkes Ohr
    p2 = [0 -b 0];   % 2. Bezugspunkt: rechtes Ohr
    p3 = [r*sind(el)*cosd(currentAz) r*sind(el)*sind(currentAz) r*cosd(el)]; % 3. Bezugspunkt: Schallquelle
    
      
    %% numerischer Ansatz
%     
%     scale = 30;
%     pointsa = -a*scale:a/30:scale*a;  % Punkte in x- und 
%     pointsb = -b*scale:b/30:scale*b;  % y-Richtung Bereichabgrenzung für die Ebene
%         
%     [alpha, beta] = meshgrid(pointsb,pointsa);
%     plane = zeros(numel(pointsb)*numel(pointsa),3);
%     
%     plane(:,1) = p1(1) + alpha(:).*(p2(1)-p1(1)) +  beta(:).*(p3(1)-p1(1));
%     plane(:,2) = p1(2) + alpha(:).*(p2(2)-p1(2)) +  beta(:).*(p3(2)-p1(2));
%     plane(:,3) = p1(3) + alpha(:).*(p2(3)-p1(3)) +  beta(:).*(p3(3)-p1(3));
%     
%     ellipsoid = (plane(:,1)/a).^2 + (plane(:,2)/b).^2 + (plane(:,3)/c).^2;
%     idsEllipsoid = find(ellipsoid<=1);
%     
% %     inEllipsoid = ellipsoid(idsEllipsoid,:);
%     xEllipsoid = plane(idsEllipsoid,1);
% %     yEllipsoid = plane(idsEllipsoid,2);
%     zEllipsoid = plane(idsEllipsoid,3);
%     
%     xEllipsoidT =  sqrt(xEllipsoid.^2+zEllipsoid.^2);
%     a_newEllipse(iAz) = max(xEllipsoidT);

    %% analytischer Ansatz
    
    % Vektoren für die Parameterdarstellung der Ebene
    v0 = p1;        % Stützvektor
    v1 = p2 - p1;   % Richtungsvektor
    v2 = p3 - p1;   %         "

    k1(iAz) = (v1(1) - v1(2)/v2(2)*v2(1)) / ( v1(3) - v1(2)/v2(2)*v2(3) );
    
   
    k2(iAz) = (v0(2)/v2(2)*v2(3) - v0(3)) * k1(iAz) + v0(1) - v0(2)/v2(2)*v2(1);
    try
    z(iAz) = (k1(iAz)*k2(iAz) + a/c * sqrt(c^2 * k1(iAz)^2 + a^2 - k2(iAz)^2 )) / ( k1(iAz)^2 + (a/c)^2 );
    catch
        
        disp('hr');
    end
    x(iAz) = sqrt((1-(z(iAz)/c)^2)*a^2);
    
    a_newEllipse(iAz) = sqrt(x(iAz)^2 + z(iAz)^2);
    
      
end

end
