function J = artemis(m)
%ARTEMIS    Colormap Artemis style (reverse engineered)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

% initialize
r = zeros(m,1);
g = r;
b = r;

indexStart = floor((0:4).*m/5) + 1;
indexEnd = ceil((1:5).*m/5);

interval = cell(5,1);
n = zeros(5,1);
for ind = 1:5
    interval{ind} = indexStart(ind):indexEnd(ind);
    n(ind) = numel(interval{ind});
end

r(interval{1}) = zeros(n(1),1);
g(interval{1}) = zeros(n(1),1);
b(interval{1}) = linspace(0,1,n(1));

r(interval{2}) = linspace(0,1,n(2));
g(interval{2}) = zeros(n(2),1);
b(interval{2}) = ones(n(2),1);

r(interval{3}) = ones(n(3),1);
g(interval{3}) = zeros(n(3),1);
b(interval{3}) = linspace(1,0,n(3));

r(interval{4}) = ones(n(4),1);
g(interval{4}) = linspace(0,1,n(4));
b(interval{4}) = zeros(n(4),1);

r(interval{5}) = ones(n(5),1);
g(interval{5}) = ones(n(5),1);
b(interval{5}) = linspace(0,1,n(5));

J = [r g b];