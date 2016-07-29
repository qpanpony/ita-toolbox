function[coord, elem] = create_meshgridData(x_range, y_range, z_range, step, filename)
%Input: (x_range, y_range, z_range, step)
%
%Creates a meshgrid with the dimensions of (x_range * y_range * z_range)
%while step is the used increment
%After triangulate the grid via DelaunayTri, it saves data in an mat-file
%--------------------------------------------------------------------------

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%create grid
[a,b,c] = meshgrid(0:step:x_range, 0:step:y_range, 0:step:z_range);
x = a(:);   y = b(:);   z = c(:);
%create triangulation
dt = DelaunayTri(x,y,z);

%create itaMeshNodes
coord = itaMeshNodes(length(dt.X(:,1)));
coord.ID = 1:length(dt.X(:,1));
coord.comment = 'Mesh Coordinates';
coord.x =  dt.X(:,1);
coord.y = dt.X(:,2);
coord.z = dt.X(:,3);
coord.cart = dt.X;

%create itaMeshElements
elem = itaMeshElements(length(dt.X(:,1)));
elem.ID = 1:length(dt.X(:,1));
elem.nodes = dt.Triangulation;
elem.shape = 'tetra';
elem.type = 'volume';
%elem.nElements = length(dt.X(:,1));
elem.order = 'parabolic';
elem.comment = 'Mesh Elements';

if isa(filename, 'char')
    save([filename, '.mat'],'coord');
    save([filename, '.mat'],'elem', '-append');
else
    save('meshGridData.mat','coord'); %default
    save('meshGridData.mat','elem', '-append');
end

