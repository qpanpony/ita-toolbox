function [a0] = a0damp (N6deltaf,deltaf)
% ------------------------------------------------------------------
% calculates the dampimg a0 in dB between the free field
% and the inner ear
%
%    INPUT:      N6deltaf     -    number of frequency
%                                  conponents up to 16 kHz
%                deltaf       -    frequency spacing between
%                                  the spectral components
%
%    OUTPUT:      a0          -    damping from the free field
%                                  to the inner ear in dB
% -----------------------------------------------------------------



% data for the damping a0
fao = [1000,1170,1250,1370,1600,1850,...
    2000,2150,2500,2900,3150,3400,...
    4000,4800,5000,5800,6300,7000,...
    8000,8500,10000,10500,12500,13500];

aod = [0,0,0,-0.2,-0.5,-1.2,-1.6,-2.1,-3.2,...
    -4.6,-5.4,-5.5,-5.6,-4.3,-4.0,-2.5,...
    -1.5,-0.1,2.0,2.8,5.0,6.4,12.0,20.0];

n1 = 24;

% slope for frequencies above 13,5 kHz
faon1 = fao(n1);
aodn1 = aod(n1);
an = (aodn1-aod(n1-1)) / (faon1-fao(n1-1));

freqs = (1:N6deltaf).*deltaf;
faocell = num2cell(fao(2:end));
startIds = cellfun(@(x) find(freqs < x,1,'last'),faocell) + 1;
js = 2.*ones(1,N6deltaf);

for iStart=1:numel(startIds)-1
    js(startIds(iStart):end) = js(startIds(iStart):end) + 1;
end

a0 = (aod(js)-aod(js-1))./(fao(js)-fao(js-1)) .* (freqs-fao(js-1)) + aod(js-1);
a0(freqs >= faon1) = an.*(freqs(freqs >= faon1)-faon1)+aodn1;

end % function