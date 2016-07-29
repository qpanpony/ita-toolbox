function this = equally_angled_sphere(this,varargin)
% Create an equally angled sphere (like HRTF)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


sArgs = struct('phi_range',[0 2*pi],'theta_range',[0 pi],'phi_step',15/180*pi,'theta_step',15/180*pi,'radius',1);
sArgs = ita_parse_arguments(sArgs,varargin);

% Remove double entry for end of turn
if sArgs.phi_range(2) - 2*pi == sArgs.phi_range(1)
    sArgs.phi_range(2) = sArgs.phi_range(2) - sArgs.phi_step;
end

phi = sArgs.phi_range(1):sArgs.phi_step:sArgs.phi_range(2);
theta = sArgs.theta_range(1):sArgs.theta_step:sArgs.theta_range(2);

grid = nan(0,3);

for idtheta = numel(theta):-1:1
    if mod(idtheta-numel(theta),2) == 0
        start_index = 1;
        stop_index = numel(phi);
    else
        start_index = numel(phi);
        stop_index = 1;
    end
    
    %numel(phi)
    for idphi = start_index:sign(stop_index-start_index):stop_index
        idtotal = (idtheta-1)*numel(phi)+idphi;
        grid(end+1,:) = [sArgs.radius theta(idtheta) phi(idphi)];
    end
end

%this.sph = flipud(grid);
this.sph = grid;