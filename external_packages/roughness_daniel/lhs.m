function [lethr] = lhs (N5deltaf,deltaf)

% function lhs.m
% ----------------------------------------------------------------------
% calculates the excitation level lethr() at the threshold in quiet              
%
%   INPUT:   deltaf          -  deltaf
%            N5deltaf        -  number of spectral components up to
%                               15500 Hz
%   OUTPUT: lethr(N5deltaf)  -  hearing threshold at the frequencies
%                               ( i*deltaf / i= 1...N5deltaf)
%-----------------------------------------------------------------------
% function for ROUGHNESS
% Daniel Riemann, 29.03.00
%-----------------------------------------------------------------------

%  data for the excitation level at the threshold in quiet
%        Lehs von 50 Hz auf 40.dB gesetzt(Wert aus neuem Buch
%        42 im Program von 1972 (Terhardt 82 berechnet ebenfalls 40))
%        aehnliches fuer den Wert bei 63 Hz 34 statt 36. 

fhs = [25,32,40,50,63,80,125,150,224,250,...
       315,350,400,450,500,570,630,700,...
       800,840,1000];
     
hs = [63,54,47,40,34,28,21,18.5,12.5,11.5,...
      9,8.3,7.3,6.7,6,5.5,5,4.8,4.4,4.3,4];

%     calculation of the hearing threshold

N1kdf = ceil(1000 / deltaf) - 1;

freqs = (1:N5deltaf).*deltaf;
fhscell = num2cell(fhs(1:end));
startIds = cellfun(@(x) find(freqs >= x,1,'first'),fhscell);
js = 2.*ones(1,N5deltaf);

for iStart=1:numel(startIds)-2
    js(startIds(iStart):end) = js(startIds(iStart):end) + 1;
end

lethr = (hs(js)-hs(js-1))./(fhs(js)-fhs(js-1)).*(freqs-fhs(js-1)) + hs(js-1);
lethr(N1kdf+1:end) = 4;

end %function  
     