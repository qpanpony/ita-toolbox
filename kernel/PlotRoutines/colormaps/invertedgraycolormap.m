function [ J ] = invertedgraycolormap(m)
%INVERTEDGRAYCOLORMAP Inverts the gray colormap to save printer color in
%spectrogram plots

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

grayMap = ita_plottools_colormap('gray');


J = flipud(grayMap);

end

