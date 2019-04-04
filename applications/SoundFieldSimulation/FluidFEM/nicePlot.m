function nicePlot(coord,elements,Data)
% Funktion bekommt ein object, dass elemente, koordinaten und gruppen
% enthält

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if  length(elements{2}.nodes(1,:))<10
    surfElem = elements{2}.nodes;
else
    surfElem = elements{1}.nodes;
end
if nnz(Data.p_real)==0 && nnz(Data.p_imag)==0 
    press = zeros(size(Data.p_real));
else
    press =20*log10(sqrt(Data.p_real.^2+Data.p_imag.^2)/(2*10^-5));  
end

try
    a=get(testgui); %#ok<NASGU>
catch %#ok<CTCH>
    figure(2);cla;
end

%figure(2);
%% eigene plotroutine
grid on;hold all;xlabel('x');ylabel('y');zlabel('z');
if length(surfElem(1,:)) == 8
for i1=1:length(surfElem(:,1))
    coord_temp =coord.cart(surfElem(i1,:)',:);
    press_temp =press(surfElem(i1,:)',:);p=press_temp;
    x=coord_temp(:,1);y=coord_temp(:,2);z=coord_temp(:,3);
    plot3([x;x(1)],[y;y(1)],[z;z(1)],'Color',[0.2 0.2 0.2]);
    if length(x)==8 %hex
        ip=1; 
        tx = sum(x(2:2:end))/4; ty = sum(y(2:2:end))/4;
        tz = sum(z(2:2:end))/4;
        [p_diff pos] = min(abs([p(1)-p(5);p(2)-p(6); p(3)-p(7); p(4)-p(8)]));
        switch pos(1)
            case 1, tp = mean([p(1),p(5)]);
            case 2, tp = mean([p(2),p(6)]);
            case 3, tp = mean([p(3),p(7)]);
            case 4, tp = mean([p(4),p(8)]);
        end
        
        X=[x(1) x(8) x(7); x(2) tx x(6); x(3) x(4) x(5)];
        Y=[y(1) y(8) y(7); y(2) ty y(6); y(3) y(4) y(5)];
        Z=[z(1) z(8) z(7); z(2) tz z(6); z(3) z(4) z(5)];
        P=[p(1) p(8) p(7); p(2) tp p(6); p(3) p(4) p(5)];
                  
        XI=interp2(X,ip);YI=interp2(Y,ip);ZI=interp2(Z,ip);PI=interp2(P,ip);
        surface(XI,YI,ZI,PI); shading interp;
   else % tetra
        %warning('Baustelle: Löcher')
        ip=1; % 33 points
        X=[x(1) x(6) x(5); x(2) x(4) x(4); x(3) x(4) x(4)];
        Y=[y(1) y(6) y(5); y(2) y(4) y(4); y(3) y(4) y(4)];
        Z=[z(1) z(6) z(5); z(2) z(4) z(4); z(3) z(4) z(4)];
        P=[p(1) p(6) p(5); p(2) p(4) p(4); p(3) p(4) p(4)];
        XI=interp2(X,ip);YI=interp2(Y,ip);ZI=interp2(Z,ip);PI=interp2(P,ip);
        surface(XI,YI,ZI,PI); shading interp;
    end
end
elseif length(surfElem(1,:)) == 6
    patch('Faces',surfElem,'Vertices',coord.cart,'FaceVertexCData',press,'FaceColor','interp') ;
end

colorbar;hold off;