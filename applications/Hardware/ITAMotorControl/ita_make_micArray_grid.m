function varargout = ita_make_micArray_grid(varargin)
% ITA_MAKE_MICARRAY_GRID - create micarray grid
%
%

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  16-Feb-2010



sArgs=struct('pos1_width','numeric', 'pos2_height','numeric', ...
    'pos3_number_w','numeric', 'pos4_number_h','numeric', 'zAxis',0);

[width, height, number_w, number_h, sArgs]=ita_parse_arguments(sArgs,varargin);

grid=zeros((number_w*number_h),3);
k=1;
%grid(1,:)=[0,0,sArgs.zAxis];
for i=1:number_w
    for j=1:number_h
          grid(k,:)= [(i-1),(j-1), sArgs.zAxis];
          k =k+1;
    end
end
mic=itaMicArray(grid,'cart');

%gewichten
mic.x=mic.x/(number_w-1)*width;
mic.x=mic.x-(width/2);
mic.y=mic.y/(number_h-1)*height;
mic.y=mic.y-(height/2);

varargout = {mic};
