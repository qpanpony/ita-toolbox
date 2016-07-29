function ita_removeWhiteBordersFromPicture(varargin)
%   removeWhiteBorders(fileName, overwriteOldFile)
%   removeWhiteBorders('myPic.png', true)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



fileName = varargin{1};
if nargin == 1
    fileNamePostfix = '_cut';
elseif nargin == 2
    if varargin{2}
      fileNamePostfix = '';  
    else
        fileNamePostfix = '_cut';
    end
end


    
% fileName = 'saveplot.png_Fig2.png';


img = imread(fileName);
imgInv = sum(255- img, 3); % invertieren damit [0 0 0 ] = weiﬂ

sumX = sum(imgInv,1);
sumY = sum(imgInv,2);


xStart = find(cumsum(sumX)== 0,1 ,'last');
xStop  = length(sumX) - find(cumsum(sumX(end:-1:1))== 0,1 ,'last')+1;

yStart = find(cumsum(sumY)== 0,1 ,'last');
yStop  = length(sumY) - find(cumsum(sumY(end:-1:1))== 0,1 ,'last')+1;

% imshow(img)
% figure;
% imshow(img(yStart:yStop,xStart:xStop, :))

[pathstr, name, ext] = fileparts(fileName) ;


imwrite( img(yStart:yStop,xStart:xStop, :), fullfile(pathstr,[name fileNamePostfix ext]))
%%
