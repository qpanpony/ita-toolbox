function [ returnCoords ] = mtimes(position,b)
%TIMES Summary of this function goes here
%   Detailed explanation goes here

if ~isa(b,'itaOrientation')
    error('Only multiplication with itaOrientation object is supported')
end

if b.nPoints > 1
   if b.nPoints ~= position.nPoints
       error('Number of points and orientations does not fit.');
   end
end

if strcmp(b.coordSystem,'openGLrh')
  position.cart = ita_matlab2openGL(position.cart);  
end

if b.nPoints > 1
    for index = 1:position.nPoints
        tmp(index,:) = (b.n(index).quat.RotationMatrix*position.n(index).cart.').';
    end
else
    tmp = (b.quat.RotationMatrix*position.cart.').';
end

returnCoords = position;
if strcmp(b.coordSystem,'openGLrh')
    returnCoords.cart = ita_openGL2Matlab(tmp);
else
    returnCoords.cart = tmp;
end

end

