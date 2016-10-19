function [ out ] = ita_openGL2Matlab( in )
%ITA_OPENGL2MATLAB converts either a itaCoordinates or a nx3 cartesian coordinates matrix from
%OpenGL coordinate system to the itaCoordinate system. Always returns a nx3
%matrix.
%   Detailed explanation goes here
MATRIX_MATLAB2OPENGL= [0 0 -1; -1 0 0; 0 1 0];

if isa(in,'itaCoordinates')
    in=in.cart;
end
if ~(size(in,2)==3)
    error('Input has to be itaCoordinates or nx3 matrix')
end

out=in*inv(MATRIX_MATLAB2OPENGL);


end

