function coordIS  = ita_IS_coordImageSource(redNorm,sourcePos) 

% ======================================================
% ==            IMAGE SOURCE                          ==
% ======================================================
% redNorm   : reducedd normal form of the plane
% sourcePos : coordinates of the image source

% .......................................................
% % reduced normal form of a plane
a=redNorm(1); b=redNorm(2); c=redNorm(3); d=redNorm(4);

% projection of source point on the wall (footpoint)
pFoot(1) = (b^2+ c^2).*sourcePos(1)-a*(d+b*sourcePos(2)+c*sourcePos(3));
pFoot(2) = (a^2+ c^2).*sourcePos(2)-b*(d+a*sourcePos(1)+c*sourcePos(3));
pFoot(3) = (a^2+ b^2).*sourcePos(3)-c*(d+a*sourcePos(1)+b*sourcePos(2));

% mirror point
coordIS = 2*pFoot-sourcePos;