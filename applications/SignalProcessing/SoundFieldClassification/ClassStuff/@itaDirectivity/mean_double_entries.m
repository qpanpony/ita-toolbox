function this = mean_double_entries(this,varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs = struct('critical_angle', 0.1/180*pi);
sArgs = ita_parse_arguments(sArgs,varargin);

idx = 1;
while idx < this.directions.nPoints
    if mod(idx,100) == 0
        disp([num2str(idx/this.directions.nPoints*100, 3) '% processed']);
    end
    
   theta_dist = mod(abs(repmat(this.directions.n(idx).theta,this.directions.nPoints,1) - this.directions.theta),2*pi);
   phi_dist1 = mod(abs(repmat(this.directions.n(idx).phi,this.directions.nPoints,1) - this.directions.phi),2*pi);
   phi_dist2 = mod(abs(2*pi-repmat(this.directions.n(idx).phi,this.directions.nPoints,1) + this.directions.phi),2*pi);
   phi_dist = min([phi_dist1 phi_dist2],[],2);
   
   double_entries = ((theta_dist < sArgs.critical_angle) & (phi_dist < sArgs.critical_angle));
   
   if sum(double_entries) > 1
       this.freq(:,idx,:) = mean(this.freq(:,double_entries,:),2);
       double_entries(find(double_entries,1,'first')) = 0;
       this.freq(:,double_entries,:) = [];
       this.directions = this.directions.n(~double_entries);
   end   
   
   idx = idx+1;
end

end