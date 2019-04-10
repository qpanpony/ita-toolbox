function[dt] = tri_mesh_grid(x_range, y_range, z_range, inc)
%Input: (x_range, y_range, z_range, inc)
%
%Creates a meshgrid with the dimensions of (x_range x y_range x z_range)
%while inc is the used increment
%Afterwards returns a triangulation via DelaunayTri of that grid
%--------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%create grid
[a,b,c] = meshgrid(0:inc:x_range, 0:inc:y_range, 0:inc:z_range);

x = a(:);
y = b(:);
z = c(:);

dt = DelaunayTri(x,y,z);    %create triangulation
%trimesh(dt,x,y,z);
end

