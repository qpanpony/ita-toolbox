function s = ita_sph_sampling_visualize(s, twistCable)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

if nargin < 2
    twistCable = true;
end

ita_sph_plot_SH(0, {s.weights, s}, 'type','sphere','FaceAlpha',0.5)

% input('press a key for evaluation a route (this can take a while)');

% theta = pi/2 - sph.theta;
% phi = sph.phi;

% P = eye(length(phi));
% for iCurrent = 1:(length(s.weights)-1)    
%     disp(['evaluating point nr. ' num2str(iCurrent)])
%     clear dist az;
%     for iNext = 1:(length(s.weights)-iCurrent)
%         % freely find a route
%         [dist(iNext), az(iNext)] = distance(pi/2-s.coord(iCurrent,1),s.coord(iCurrent,2),...
%             pi/2-s.coord(iCurrent+iNext,1),s.coord(iCurrent+iNext,2),'Radians');
%         if ~twistCable % dont twist the cable, no jump between -pi and pi
%             dist(iNext) = sqrt((s.coord(iCurrent,1) - s.coord(iCurrent+iNext,1)).^2 ...
%                 + ( rem(s.coord(iCurrent,2) - s.coord(iCurrent+iNext,2),2*pi) ).^2);
%         end
%     end
%     % weight to get a higher use of azimuthal movement (turntable) instead of arm    
%     [void,iMin] = min(dist .* (1.5 - abs(sin(az))) );
%     s = permute_sph(s, iCurrent+1, iCurrent+iMin);
% end
% 
% [x,y,z] = sph2cart(s.coord(:,2), pi/2-s.coord(:,1), 1);
% hold all;
% plot3(x,y,z,'LineWidth',3);
% hold off;
% end
% 
% function s = permute_sph(s,a,b)
% s.coord([a b],:) = s.coord([b a],:);
% s.weights([a b],:) = s.weights([b a],:);
% s.Y([a b],:) = s.Y([b a],:);
% end