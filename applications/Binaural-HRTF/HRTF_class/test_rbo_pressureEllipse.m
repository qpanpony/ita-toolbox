function  HRTF_ellipsoid = test_rbo_pressureEllipse(an)
% Berechnet den Umweg auf der Ellipse durch mathematische Formel,
% Integral ersetzt durch Summe

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


radiusRounded = round(an.headRadius*1000)/1000;

[~, I] = unique(radiusRounded);
rU = radiusRounded(sort(I));
            
%rU= unique(round(an.headRadius*1000)/1000,'stable');

maxWbRun = 25;
if numel(rU)>maxWbRun,wb = itaWaitbar(numel(rU), 'Radius', {'Pressure' });
end

timeData = zeros(numel(an.timeVector),an.channelCoordinates.nPoints);
for iR = 1:numel(rU)      
        idxRadiusCurrent = find(radiusRounded == rU(iR));
        currentCoord = an.channelCoordinates.n(idxRadiusCurrent);
        currentCoord.r = rU(iR);
        earSite = an.EarSide(idxRadiusCurrent);
        
        pSphere = test_rbo_pressureSphere('sph',currentCoord,'fftDeg',an.fftDegree); 
        
        idxRun = 2*[1:currentCoord.nPoints];
        idxRun(earSite=='L') = idxRun(earSite=='L')-1;
        
        pSphereSort = pSphere.timeData(:,idxRun);

        timeData(:,idxRadiusCurrent) = pSphereSort;
        if numel(rU)>maxWbRun,       wb.inc; end
end
HRTF_ellipsoid = itaAnthroHRTF(an); 
HRTF_ellipsoid.timeData = timeData;
HRTF_ellipsoid = ita_time_shift(HRTF_ellipsoid, an.trackLength/2);

if numel(rU)>maxWbRun,wb.close; end
end