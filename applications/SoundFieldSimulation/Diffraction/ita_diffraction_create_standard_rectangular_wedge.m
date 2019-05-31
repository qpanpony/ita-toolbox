function infWdg = ita_diffraction_create_standard_rectangular_wedge()
%CREATE_RECTANGULAR_WEDGE Creates an instance of the class itaInfiniteWedge
%   wedge of 90 degree angle pointing in y direction

wdgNormal_1 = [1, 1, 0];
wdgNormal_2 = [-1, 1, 0];
wdgLoc = [0, 0, 0];
infWdg = itaInfiniteWedge(wdgNormal_1 / norm( wdgNormal_1 ), wdgNormal_2 / norm( wdgNormal_2 ), wdgLoc);
end

