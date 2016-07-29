function hit = ita_IS_rayHitsOtherTri(coord, posCross, posR, normal)
% ======================================================
% ==         RAY HITS OTHER TRIANGLE TEST             ==
% ======================================================
% coord    : coordinates of the current element
% posCross : coordinates of the image source
% posR     : coordinates of the receiver point
% normal   : normal vector of the plane
% ind      : neglected direction for projection

% hit      : True (1) when there exists a crossing point, false (0) when not

% .......................................................
% plane/line equation :(P_triangle - P_receiver)*n0_triangle/((P_IS-P_receiver)*n0_triangle)
% line equation       : P_IS + lambda * (P_receiver - P_IS)

scalarP = (posR-posCross)*normal';
if  sum(abs(scalarP))>10^-8
    crossPoint = posCross + ((coord(3,:)-posCross)*normal')/scalarP*(posR-posCross);
else
    crossPoint = NaN;
end
if sum(isnan(crossPoint))==0 && sum(isinf(crossPoint))==0
    % check whether point is an element of the corresponding triangle
    v0 = coord(3,:) - coord(1,:);
    v1 = coord(2,:) - coord(1,:);
    v2 = crossPoint - coord(1,:);

    dot00 = v0*v0';dot01 = v0*v1';dot02 = v0*v2';
    dot11 = v1*v1';dot12 = v1*v2';

    invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    if  (u > 0) && (v > 0) && (u + v < 1)
        % nc1 = (posR-posCross)/norm(posR-posCross,2)
        nc2 = (posR-crossPoint)/norm(posR-crossPoint,2);
        nc1c2 = (posCross-crossPoint)/norm(posCross-crossPoint,2);
        if  sum( abs(nc2 - nc1c2) <10^-5)~=3, hit = true;
        else hit = false;
        end
    % elseif (u >= 0) && (v >= 0) && (u + v < 1),disp('Streift!'); hit = false;
    else hit = false;
    end
    
%     if hit == true
%         vecRay = posCross-crossPoint;
%         figure(2); clf; hold on; view([135 135]); grid on;
%         quiver3(crossPoint(1),crossPoint(2),crossPoint(3),normal(1),normal(2),normal(3),'b');
%         quiver3(crossPoint(1),crossPoint(2),crossPoint(3),vecRay(1),vecRay(2),vecRay(3),'r');
%         legend('normal', 'ray');
%         p1 = patch('Faces',1:3,'Vertices',coord,'FaceVertexCData',[0 0 1],'FaceColor',[0.5 0.9 0.9]) ;
%         set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 1 0]);
%         plot3(posR(1),posR(2),posR(3),'-mo','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10);
%         plot3(posCross(1),posCross(2),posCross(3),'-mo','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
%         hold off;
%         disp(' ')
%     end   
else
    hit = false;
end
