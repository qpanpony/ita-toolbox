%% Little tutorial for the itaBalloon and the itaBalloonSH classes
%
% itaBalloon   : class to administrate measured directivity funtions.
% itaBalloonSH : administrate and manipulate directivities in the
%                   spherical domain
%
% The all (maybe) big matrices are swaped to your disc and saved in some
% mat-files. You don't have to care about this structure, just use the functions below.
%
% have also a look on the documentation of the varius functions
% and do:  >>>  edit itaBalloon.tutorial  <<<

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>






%% create a new itaBalloon-object ----------------

this = itaBalloon;  % new object;
this.balloonFolder = 'c:\balloonfolder';  % object's directory

% optional 
this.name = 'newBalloon'; 
this.precision = 'double';

save(this);    % saves objekt in file [this.balloonfolder '\' this.name '.m']

% setup

this.makeSetup.dataFolderNorth = 'c:\dataNorth'; 
    % directory with the itaAudios or itaResults of your measurement
this.makeSetup.dataFolderSouth = 'c:\dataSouth'; % if you have one...
this.makeSetup.MBytePerSegment = 150;             % set the maximum size of a data block
this.makeSetup.phi0 = 0;  % the southern hemissphere will be rotated arround a axis thrue this angle

this.normalizeData = true;
this.eleminateLatencySamples = true;
% the mesurementdata are beeing normalized by this.sensitivity and time-shifted 
% by this.latencySamples in this.makeBalloon

% after all settings are done, proceed this
this.makeBalloon;  % reads all the measurement data calculates the new balloon, initializes a lot of stuff and equalizes it

                   
% if you have already some frequency dependent data in a matrix, you can
% also use:
this.freqDataMatrix2itaBalloon;

%% correct measurement position:
% see doc itaBalloon.correctMeasurementPosition;


%% spherical harmonics ------------------------------

son = this.makeSH(nmax); % proceeds a DSHT to COMPLEX VALUED spherical harmonics [complex (default) | real]
% son is an itaBalloonSH - object
this.makeSH('type','real');          % proceeds a DSHT to REAL VALUED spherical harmonics
    % see doc itaBalloon.makeSH

% if you want to get the basefunctions (amplitudes of the valued basefunctions at this.positions)
SH = this.Y;

% the basefunctions are swaped to disk as well as the spherical
% coefficients
this.existSH; % a DSHT has already been done



%% administration
this.freq2idxFreq;
this.freq2value;
this.freqVector;



%% plot:
freq = 2000;
this.plot(freq, 'type','complex','channels',1,'unit','db');
% - type: absolute, absoluteSphere, phase, phaseSphere, complex
% - unit: pa, db



%% interpolate directivity to another sampling
son = this.interpolateBalloon(newSampling, newBalloonFolder); %creates a new itaBalloon object with another sampling
% for itaBalloonSH only



%% other methods
% Most of the functions have the options:
% 'channels', [1:this.nChannels] : if you have an multichannel  speaker you can specify the
%           channel you want to have
% 'nmax',[this.nmax]     : maximum order of output data 
%          (if the function has something to do with spherical harmonics)
% 'normalized': returns normalized data (without this.sensitivity)

a = this.idxCoefSH2itaAudio(idxCoefSH, 'channels',1:this.nChannels)
a = this.idxPoint2itaAudio(idxPoint);
a = this.idxPoint2itaResult(idxPoint);
a = this.response; % total pressure energy
a = sphericalKlirr; % for itaBalloonSH only
a = this.angle2itaAudio([theta phi]);
a = this.angle2itaResult([theta phi]);
this.isItaAudio; % true if your measurement date were also itaAudios, so export to itaAudio is possible
