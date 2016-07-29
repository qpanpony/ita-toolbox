function [hpos, hview, hup, ppos, pview, pup, pbtn, apos, aview, aup] = ITATracking_CorrectMeasurement( ref_pos, ref_orient, qx, qy, qz )
%ITATracking_CorrectMeasurement - Makes a measurement of the tracker and corrects
%the values acoording to the test measurements done in the VR lab.
%The parameters it needs can all be found in the reference.mat workspace
%and must then must be provided to this function. These contain the reference
%measurements with which the correction of position and orientation is calculated.

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% The tracking environment must be initialized first with:
% ITATracking('Init');
% And after use finished with:
% ITATracking('Finalize');
% qx, qy, qz as well as the reference data ref_pos and ref_orient must be
% provided. 

[hpos, hview, hup, ppos, pview, pup, pbtn, apos, aview, aup] = ITATracking('GetStatePVU');

%returns the corrected position, up- and view-vectors of the three sensors 
%head, pointer and aux.

[corr, delta, orient] = correctCubic( hpos, ref_pos, ref_orient, qx, qy, qz );
hpos = hpos-delta;
hview = orient*hview;
hup = orient*hup;

[corr, delta, orient] = correctCubic( ppos, ref_pos, ref_orient, qx, qy, qz );
ppos = ppos-delta;
pview = orient*pview;
pup = orient*pup;

[corr, delta, orient] = correctCubic( apos, ref_pos, ref_orient, qx, qy, qz );
apos = apos-delta;
aview = orient*aview;
aup = orient*aup;
end
