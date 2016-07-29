function audible= ita_IS_isAudibleS(obj,sourcePos, receiverPos)
%%
% ======================================
% =      special case 0-th order       =
% ======================================
numWall = size(obj.Elements,1);
for k1 = 1:numWall
    coord =  obj.Coordinates(obj.Elements(k1,:)+1,:);
    normal = obj.Normals(obj.Elements(k1,1)+1,:);
    hitO= ita_IS_rayHitsOtherTri(coord, sourcePos, receiverPos, normal);
    if hitO ==1, break; end
end
if hitO==0,    audible = 1;
else  audible = 0;
end
