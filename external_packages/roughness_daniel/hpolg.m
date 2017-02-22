function [hx] = hpolg(ih,deltaf,nhk)

% ----------------------------------------------------------------
% calculates the bandpassfilter for the envelope of the 
% excitation pattern
%---------------------------------------------------------------------
% function for ROUGHNESS
% Daniel Riemann, 29.03.00
%---------------------------------------------------------------------

% number of frequency components up to 640 Hz
n = 32;

% Data for the Bandpass filters
hd = [0.0 , 0.25, 0.45, 0.55, 0.63, 0.85,...
      0.9 , 0.96, 1.0 , 0.99, 0.95, 0.91,...
      0.87, 0.81, 0.76, 0.7,  0.65, 0.58,...
      0.51, 0.47, 0.41, 0.37, 0.33, 0.29,...
      0.27, 0.22, 0.18, 0.15, 0.1 , 0.08,...
      0.03, 0.0 ];

% h1f.neu aus rconi.ftn
h1f = [  0,   5,  10,  12,  14,  19,...
        21,  25,  30,  32,  41,  49,...
        56,  66,  77,  90,  102, 119,...
        138, 149, 168, 181, 194, 209,...
        217, 237, 255, 269, 295, 307,...
        338, 360];

h9f = [  0,  15,  25,  30,  34,  50,...
         55,  63,  70,  84, 110, 128,...
         146, 169, 181, 192, 201, 218,...
         240, 250, 282, 302, 325, 350,...
         364, 401, 429, 450, 500, 530,...
         600, 640 ];

h10f = [ 0,  10,  18,  24,  29,  45,...
         50,  57,  70,  84, 110, 128,...
         140, 158, 170, 188, 194, 206,...
         232, 250, 282, 302, 325, 350,...
         364, 401, 429, 450, 500, 530,...
         600, 640 ];

h21f = [ 0,  10,  18,  23,  28,  45,...
         49,  56,  70,  79,  87,  94,...
         101, 113, 124, 138, 154, 189,...
         232, 250, 282, 302, 325, 350,...
         364, 401, 429, 450, 500, 530,...
         600, 640];

hx = zeros(1,nhk);

if ih <= 2
   hfd(1:n) = h1f(1:n);
elseif ih <= 7
   hfd(1:n) = (ih-2) .* (h9f(1:n)-h1f(1:n)) / 6 + h1f(1:n);
elseif ih <= 10
   hfd(1:n) = h9f(1:n);
elseif ih <= 20
   hfd(1:n) = (ih-10) .* (h21f(1:n)-h9f(1:n)) / 10 + h9f(1:n);
else
   hfd(1:n) = h21f(1:n);
end;

for i = 1:nhk
   first(i) = findfirst(i*deltaf,hfd);
end;
ax(1:nhk) = (hd(first(1:nhk))-hd(first(1:nhk)-1)) .* ((1:nhk)-hfd(first(1:nhk))) ./ (hfd(first(1:nhk))-hfd(first(1:nhk)-1)) ; 
hx(1:nhk) = ax(1:nhk) + hd(first(1:nhk));

% end of function hpolg
% ----------------------------------------------------------------------------

% subfunction findfirst
function first = findfirst (number,hfd)
% this function gives the number of the first element
% whos value is greater than number

temp = find(number < hfd);
if isempty(temp)
   first = 32;
else
   first = temp(1);
end;
    