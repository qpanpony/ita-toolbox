function [NM] = ita_level2criticalBandLoudness(LT)
%	Function used by ita_loudness_timevariant()
%   
%
%	Syntax:
%	[NM]=DIN45631(LT)
%
%	This is a loudness function which:
%		Calculates loudness based on DIN 45631 / ISO 532 B (Zwicker)
%		Accepts 1/3 octave band levels (SPL Linear Weighting)
%		* This data must be calibrated using a separate calibration function
%
%	Input Variables
%	LT(28)			Field of 28 elements which represent the 1/3 OB levels in dB with
%						fc = 25 Hz to 12.5 kHz
%	MS				String variable to distinguish the type of sound field ( free / diffuse )
%
%	Output Variables
%	N				Loudness in sone G
%	NS				Specific Loudness
%	err				Error Code

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%	Working Variables
%	RAP(8)			Ranges of 1/3 OB levels for correction at low frequencies according
%						to equal loudness contours
%	DLL(11,8)		Reduction of 1/3 OB levels at low frequencies according to equal
%						loudness contours within the 8 ranges defined by RAP
%	LTQ(20)			Critical Band Rate level at absolute threshold without taking into
%						account the transmission characterisics of the ear
%	AO(20)			Correction of levels according to the transmission characteristics
%						of the ear
%
%	Working Variables (Uncertain of Definitions)
%	TI					Intensity of LT
%	LCB                 Lower Critical Band
%	LE					Level Excitation
%	NM					Critical Band Level
%	N2					Main Loudness
%	Z1					Critical Band Rate for Lower Limit
%	N1					Loudness of previous band
%	Z					Critical band rate
%	J,IG				Counters used with USL



%%	Begin initializing the working variables

RAP=[45 55 65 71 80 90 100 120];

DLL=[-32 -24 -16 -10 -5 0 -7 -3 0 -2 0
    -29 -22 -15 -10 -4 0 -7 -2 0 -2 0
    -27 -19 -14 -9  -4 0 -6 -2 0 -2 0
    -25 -17 -12 -9  -3 0 -5 -2 0 -2 0
    -23 -16 -11 -7  -3 0 -4 -1 0 -1 0
    -20 -14 -10 -6  -3 0 -4 -1 0 -1 0
    -18 -12 -9  -6  -2 0 -3 -1 0 -1 0
    -15 -10 -8  -4  -2 0 -3 -1 0 -1 0]';	%%	BASIC code does this a oddly, hence the transpose

LTQ=[30 18 12 8 7 6 5 4 3 3 3 3 3 3 3 3 3 3 3 3].';

AO=[0 0 0 0 0 0 0 0 0 0 -0.5 -1.6 -3.2 -5.4 -5.6 -4.0 -1.5 2.0 5.0 12.0];


DCB=[-0.25 -0.6 -0.8 -0.8 -0.5 0.0 0.5 1.1 1.5 1.7 1.8 1.8 1.7 1.6 1.4 1.2 0.8 0.5 0.0 -0.5].';

%%	Begin Loudness Calculation

%%	Correction of 1/3 OB levels according to equal loudness contours (XP) and
%%	calculation of the intensities for 1/3 OB's up to 315 Hz

if length(LT) == 28 % kombinieren der teifeln Freq wie in DIN
    TI = zeros(11,1);
    for I=1:11
        J = find((LT(I)) <= RAP - DLL(I,:),1,'first');
        if isempty(J)
            J = 8;
        end
        TI(I)=10^(0.1*(LT(I)+DLL(I,J)));
    end
    
    %%	Determination of Levels LCB(1), LCB(2), and LCB(3) within the first three
    %%	critical bands
    
    GI = [ max(TI(1)+TI(2)+TI(3)+TI(4)+TI(5)+TI(6),0) max(TI(7)+TI(8)+TI(9),0) max(TI(10)+TI(11),eps) ];
    
    
    LE = [ 10*log10(GI) LT(12:28).'] - AO;
elseif length(LT) == 20  % Tiefe Freq bereits addiert
    LE = LT;
else
    error('Wrong size of input.')
end
% idxNMeqZero = [LE<=LTQ true]; % append true to get NM(21) = 0
idxNMeqZero = LE<=LTQ ; 
LE = LE -DCB;
NM = max( 0.0635*10.^(0.025*LTQ) .* ((0.75+0.25*10.^(0.1*(LE-LTQ))).^0.25-1), 0);
NM(idxNMeqZero) = 0;


%%	Correction of specific loudness in the lowest critical band taking
%%	into account the dependence of absolute threshold within this critical band
NM(1)=NM(1)* min( 0.4+0.32*NM(1)^0.2, 1);

end
