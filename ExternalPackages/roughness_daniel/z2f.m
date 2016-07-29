function [fz] = z2f (Ndeltaz)

%---------------------------------------------------------------------
% calculates the frequency fz(z) of the crtical band rate z for
% z = (i-1)*deltaz ,i=1,...,Ndeltaz and deltaz = .1 Bark
%
%   INPUT:  Ndeltaz (=241) -    number of subdivisions of the Barkscale
%
%   OUTPUT: fz(i)          -    frequency for the critical band rate i*deltaz
%                                   deltaz=0.1
%---------------------------------------------------------------------
% function for ROUGHNESS
% Daniel Riemann, 29.03.00
%---------------------------------------------------------------------

%  data for the transformation frequency f -> critical band rate z
fd = [ 20,100,400,450,510,560,630,710,770,900,920,1080,...
    1120,1270,1400,1480,1720,1800,2000,2240,2320,2500,...
    2700,2800,3150,3550,3700,4400,4500,5300,5600,6400,...
    7100,7700,9000,9500,10500,11200,12000,13500,14000,15500];

zd = [0,1,4,4.4,5,5.4,6,6.6,7,7.9,8,9,9.2,10,10.6,11,...
    12,12.3,13,13.8,14,14.5,15,15.2,16,16.7,17,18,...
    18.1,19,19.3,20,20.6,21,21.8,22,22.5,22.7,23,23.5,23.6,24];

NBark  = 24;
deltaz = NBark / (Ndeltaz-1);

zs = (0:Ndeltaz-1).*deltaz;
zdcell = num2cell(zd(2:end-1));
startIds = cellfun(@(x) find(zs > x,1,'first'),zdcell);

js = 2.*ones(1,Ndeltaz);

for iStart=1:numel(startIds)
    js(startIds(iStart):end) = js(startIds(iStart):end) + 1;
end

fz = (fd(js)-fd(js-1)).*(zs-zd(js-1))./(zd(js)-zd(js-1))+fd(js-1);

end %function