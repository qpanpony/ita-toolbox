function [ out ] = ita_matlab2openGL( in )
%ITA_MATLAB2OPENGL converts either a itaCoordinates or a nx3 cartesian coordinates matrix from
%itaCoordinate system to the OpenGL system. Always returns a nx3 matrix.
%   Detailed explanation goes here
MATRIX_MATLAB2OPENGL= [0 0 -1; -1 0 0; 0 1 0];

if isa(in,'itaCoordinates')
    in=in.cart;
end
if ~(size(in,2)==3)
    error('Input has to be itaCoordinates or nx3 matrix')
end

out=in*(MATRIX_MATLAB2OPENGL);


end

