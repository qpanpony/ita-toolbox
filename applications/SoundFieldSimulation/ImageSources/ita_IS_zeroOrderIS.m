function audi = ita_IS_zeroOrderIS(sourcePos, receiverPos, obj)

for i1 = 1:size(obj.Elements,1)
    normal = obj.Normals(obj.Elements(i1,1)+1,:);
    coord = obj.Coordinates(obj.Elements(i1,:)+1,:);
    audi = ita_IS_rayHitsOtherTri(coord, sourcePos, receiverPos, normal);
    if audi == 1, break; end
end
