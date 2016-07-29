function [z] = ftoz (N5deltaf,deltaf)   

%---------------------------------------------------------------------
% calculates the crtical band rate zf at the frequencies i*deltaf 
%
%   INPUT:  N5deltaf      -    number of spectral components up to
%                              15.500 Hz
%   OUTPUT: zf(i)         -    function of the critical band rate 
%
%---------------------------------------------------------------------
% function for ROUGHNESS
% Daniel Riemann, 29.03.00
%---------------------------------------------------------------------
%
freq = deltaf:deltaf:deltaf * N5deltaf;
z = ( ( (0.02681 .* freq) ) ./ (1.96 + ( freq ./ 1000 ) ) ) - 0.53;