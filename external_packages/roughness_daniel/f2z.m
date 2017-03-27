function zf = f2z(N5deltaf,deltaf)

%---------------------------------------------------------------------
% calculates the crtical band rate zf at the frequencies i*deltaf 
%
%   INPUT:  N5deltaf      -    number of spectral components up to
%                              15.500 Hz
%   OUTPUT: zf(i)         -    function of the critical band rate 
%
%---------------------------------------------------------------------
% function for ROUGHNESS
% mkl, 15.02.01
% Based on Zwickerbook page 164 (6.1)
%---------------------------------------------------------------------

freq = deltaf.*(1:N5deltaf);  % legt die Frequenzwerte fest
zf = 13.*atan(0.00076.*freq) + 3.5*atan((freq./7500).^2);
