function varargout = ita_IS_hitsWall(obj,sourcePos, receiverPos)
%% see rbo_isAudibleS

numWall = size(obj.Elements,1);
hitO = zeros(numWall,1);
for k1 = 1:numWall  
    elemOrder = obj.Elements(k1,:)+1;
    
    coord =  obj.Coordinates(elemOrder ,:);
    normal = obj.Normals(elemOrder,:);
    hitO(k1)= ita_IS_rayHitsOtherTri(coord, sourcePos, receiverPos, normal);
%    if hitO ==1, break; end
    
%     elemOrder = elemOrder(length(elemOrder):-1:1);
%     coord =  obj.Coordinates(elemOrder,:);
%    normal = cross(coord(1,:)-coord(2,:),coord(2,:)-coord(3,:) )/abs(cross(coord(1,:)-coord(2,:),coord(2,:)-coord(3,:) ));
%    hitO = rayHitsOtherTri(coord, sourcePos, receiverPos, -normal);
end

if sum(hitO) > 0, varargout{1} = 1;
else varargout{1} = 0;
end

if nargout == 2
    varargout{2} = obj.Elements(hitO == 1,:);
end
