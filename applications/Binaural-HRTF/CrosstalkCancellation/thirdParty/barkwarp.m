function lambda = barkwarp(fs)
%BARKWARP - Computation of warping coefficient
%
% lambda = barkwarp(fs)
%
% computes an optimal warping coefficient vs sample rate in Hertz
% to approximate the psychoacoustic Bark scale
% approximation by J.O. Smith and J.S. Abel (1995)
%
% If output argument is not specified, e.g.,
% >> barkwarp(44100)
% the function plots the warping function and shows the optimal 
% coefficient value on the title line of the figure. 
% The turning point frequency, i.e., 
% the frequency below which the frequency resolution of the 
% system is higher than in a non-warped system, is also shown in
% the figure as a vertical line.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

% (Smith&Abel, 1995)
% lambda = 1.0211*sqrt((2/pi)*atan(0.000076*fs))-0.19877; 

% (Smith&Abel, 1999) Is there an error in formula (26)?
lambda = 1.0674*sqrt((2/pi)*atan(0.06583*fs/1000))-0.1916; 

if nargout==0,
  F=freqz([-lambda 1],[1 -lambda]);
  a=-angle(F);
  tp=fs/(2*pi)*atan(sqrt(lambda^(-2)-1));
  plot(linspace(0,fs/2000,512),a/pi);axis([0 fs/2000 0 1]);grid
  xlabel('Frequency [kHz]'); ylabel('Normalized warped frequency');
  title(['Warping function for \lambda = ' num2str(lambda)]);
  h=line([tp/1000 tp/1000],[0 1]);set(h,'LineStyle','--');
  set(h,'Color',[1 0 1]);
  text(tp/1000,0.25,'\leftarrow  Turning point frequency');
end

