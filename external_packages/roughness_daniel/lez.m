function [leiz,komp] = lez (speca0,nsp,N5deltaf,deltaf,zf,zlolim,zhilim,flolim,fhilim,lethr)

% function fastlez.m
% ---------------------------------------------------------------------------------
% calculates the excitation pattern as a function of the 
% critical band rate for the critical band 'icritbnd'.
% The 'icritical' band is characterized by its critical 
% band rate boundaries zlolim,zhilim and by its frequency 
% boundaries flolim,fhilim
%
%   INPUT:   speca0(nsp)     -       spectrum (in dB) already
%                                       filtered with a0 
%            deltaf          -       frequency spacing of adjacent 
%                                       spectral components 
%            lethr           -       level of the hearing threshold
%            zf              -       critical band rate as a function 
%                                       of frequency       
%            N5deltaf        -       number of spectral components 
%                                       up to 15.500 Hz 
%            zlolim          -       lower  limit of the critical band in Bark
%            zhilim          -       higher limit of the critical band in Bark
%            flolim          -       lower limit of the critical band in Hz
%            fhilim          -       higher limit of the critical band in Hz
%
%   OUTPUT:  leiz(nsp)       -       excitation pattern as a function  
%                                       of the spectrum at the place of the 
%                                       critical band 'icritbnd'
%            komp            -       number of excitation components 
%                                       above the threshold
% ----------------------------------------------------------------------------------
% function for ROUGHNESS
% Daniel Riemann, 22.10.00 (performance optimized, based on lez.m 29.03.00)
% ----------------------------------------------------------------------------------

% highfrequency slope: -> subfunction hifslope
freqz = zf(1:N5deltaf);      % berechnet die entsprechenden Bark-Werte
freqz(N5deltaf+1:nsp) = zf(N5deltaf);
freq = deltaf.*(1:nsp);       % legt die Frequenzwerte fest
leiz = zeros(1,nsp);

% only speca0-values >4 are relevant
relevant = find(speca0 > 4);           % Berechnet wird nur, wenn speca0 > 4

%3-Faelle: 1. zhilim <= Barkwert
%         2. zlolim >= Barkwert
%         3. sonst

relevant1 = relevant(zhilim <= freqz(relevant));
relevant2 = relevant(zlolim >= freqz(relevant));
relevant3 = relevant(zhilim >= freqz(relevant) & zlolim <= freqz(relevant));

% lowfrequency slope: 27 dB / Bark
lofslope = 27;
hifslope = hislope(freq(relevant1),speca0(relevant1));

lei(relevant1) = speca0(relevant1) - hifslope .* (freqz(relevant1) - zhilim);
ihs(relevant1) = round(fhilim / deltaf);

lei(relevant2) = speca0(relevant2) - lofslope .* (zlolim - freqz(relevant2));
ihs(relevant2) = round(flolim / deltaf);

lei(relevant3) = speca0(relevant3);
%ihs(relevant3) = freq(relevant3);
ihs(relevant3) = relevant3;

%ihs
% ihs noch etwas "verschoben" !!!
% Klemenz 12.02.01: other length! +Filling up "lethr" with dummies
ihs(ihs == 0) = 1;
% komp = find(lei(1:length(relevant)) > lethr(ihs(1:length(relevant))))
komp = find(lei > lethr(ihs));

% Klemenz 12.02.01: "freq(" was wrong, therefore deleted
leiz(komp) = 10.^((lei(komp)-lethr(ihs(komp))) ./ 20);
komp = length(komp);

% end of fastlez.m
%-------------------------------------------------------------------------------



function hifslope = hislope (fv,lv)
% subfunction hifslope
% -----------------------------------------------
% calculates the highfrequency slope
% of the excitation pattern as a 
% function of the frequency fv of the
% spectral components and its level lv
%
% INPUT   fv        : frequency of the 
%                     component in Hz
%         lv        : level of the component
%
% OUTPUT  hifslope  : upper slope of the 
%                     component fv in dB / Bark
%                     (Terhardt...Pitch 79)
%
% -------------------------------------------------

fkhz = fv ./ 1000;
a = 1 ./ fkhz;

hifslope = 24 + 0.23 .* a - 0.2 .* lv;

% End of subfunction hifslope
% -------------------------------------------------

