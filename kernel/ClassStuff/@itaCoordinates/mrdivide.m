function returnCoords = mrdivide(position,orientation)


if ~isa(orientation,'itaOrientation')
    error('Only multiplication with itaOrientation object is supported')
end

if orientation.nPoints > 1
   if orientation.nPoints ~= position.nPoints
       error('Number of points and orientations does not fit.');
   end
end

if strcmp(orientation.coordSystem,'openGLrh')
  position.cart = ita_matlab2openGL(position.cart);  
end

if orientation.nPoints > 1
    for index = 1:position.nPoints
        tmp(index,:) = (orientation.n(index).quat.inverse.RotationMatrix*position.n(index).cart.').';
    end
else
    tmp = (orientation.quat.inverse.RotationMatrix*position.cart.').';
end

returnCoords = position;
if strcmp(orientation.coordSystem,'openGLrh')
    returnCoords.cart = ita_openGL2Matlab(tmp);
else
    returnCoords.cart = tmp;
end