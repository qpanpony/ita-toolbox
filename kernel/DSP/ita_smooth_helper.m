function c = ita_smooth_helper(varargin)
%SMOOTH  Smooth data.
%   res = ita_smooth_helper(data,width) smooths data using width

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


is_x = 0; % x is not given
y = varargin{1};
y = y(:);
x = (1:length(y))';

lwidth = varargin{2+is_x};

t = length(y);
if lwidth < 1, lwidth = ceil(lwidth*t); end % percent convention
if isempty(lwidth), lwidth = 5; end % smooth(Y,[],method)

idx = 1:t;

sortx = any(diff(isnan(x))<0);   % if NaNs not all at end
if sortx || any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end

c = NaN(size(y));
ok = ~isnan(x);
c(ok) = moving(x(ok),y(ok),lwidth);
c(idx) = c;

%--------------------------------------------------------------------
function c = moving(x,y, lwidth)
% moving average

ynan  = isnan(y);
lwidth  = floor(lwidth);
n     = length(y);
lwidth  = min(lwidth,n);
width = lwidth-1+mod(lwidth,2); % force it to be odd
xreps = any(diff(x)==0);
if width==1 && ~xreps && ~any(ynan), c = y; return; end
if ~xreps && ~any(ynan)
    % simplest method for most common case
    c = filter(ones(width,1)/width,1,y);
    cbegin = cumsum(y(1:width-2));
    cbegin = cbegin(1:2:end)./(1:2:(width-2))';
    cend = cumsum(y(n:-1:n-width+3));
    cend = cend(end:-2:1)./(width-2:-2:1)';
    c = [cbegin;c(width:end);cend];
elseif ~xreps
    % with no x repeats, can take ratio of two smoothed sequences
    yy = y;
    yy(ynan) = 0;
    nn = double(~ynan);
    ynum = moving(x,yy,lwidth);
    yden = moving(x,nn,lwidth);
    c = ynum ./ yden;
else
    disp('sorry...')
end


