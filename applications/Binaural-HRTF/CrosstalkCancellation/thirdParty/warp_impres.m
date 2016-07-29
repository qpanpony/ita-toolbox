function res = warp_impres(sig,lambda,n)
%WARP_IMPRES - Computation of a warped impulse response
%
% y = warp_impres(x,lambda,n)
%
% warp a signal or impulse response (sig) (by allpass1 with lambda)
% n = number of samples in the result always stable.
% This function uses the dewarping technique, which is more
% suitable for warping of an impulse response than longchain
% function.
%
% This function is a part of WarpTB - a Matlab toolbox for
% warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% See 'help WarpTB' for related functions and examples

% Authors: Matti Karjalainen, Aki Härmä
% Helsinki University of Technology, Laboratory of Acoustics and
% Audio Signal Processing

len=length(sig);
if nargin<3 n=len; end
if nargin<4 Flag=0;end

temp = [1 zeros(1,n)];
bw = [lambda 1]';
aw = [1 lambda]';
res = sig(1)*temp;
for i=2:len
%	i
	temp = filter(bw,aw,temp);
	res = res+sig(i)*temp;
end
res(end) = [];