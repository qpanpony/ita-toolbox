function varargout = ita_laboratory_v2_sound_reduction_index(varargin)
%ITA_V2_SOUND_REDUCTION_INDEX - calculates the sound reduction index
%
%  Syntax:
%   [R,fc,p,pSendMean,pRecMean,D] = ita_v2_sound_reduction_index(audioObjIn,'RT',RT,options)
%   audioObjIn = measured pressure in sending and receiving room
%  'RT'        = reverberation time (itaResult)
%   R          = sound reduction index CH1 = measurement, CH2 = theory
%   fc         = critical frequency
%   D          = pressure ratio
%   pSendmean  = average squared pressure in sending room
%   pSendmean  = average squared pressure in receiving room
%   p		   = pressure squared at all microphones

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%   Options (default):
%           'fraction'     (3)              : frequency band fraction
%           'micPath '     (defaultopt1)    : path of microphone frfs
%           'sendChannels' ([1:4])          : channels of sending room mics
%           'recChannels'  ([5:8])          : channels of receiving room mics
%           'Swall'        (0.75*1)         : area of separating wall
%           'VrecRoom'     (0.75*1*1.13)    : volume of receiving room
%           'limits'       ([315 20000])    : frequency limits
%           'density'      ([])             : plate density
%           'thickness'    ([])             : plate thickness
%           'YoungsModulus'([])             : plate young's modulus
%           'PoissonsRatio'([])             : poisson's ratio
%           'Material'     ([])             : plate material
%  Example:
%   R = ita_v2_sound_reduction_index(DATA,'RT',RT);
%
%   See also:
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_v2_sound_reduction_index">doc ita_v2_sound_reduction_index</a>

% Author: MMT + RBO -- Email: mmt@akustik.rwth-aachen.de
% Created:  18-Sep-2012



%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs.pos1_data      = 'itaAudio';
sArgs.fraction       = 3;
sArgs.sendChannels   = 1:4;
sArgs.recChannels    = 5:8;
sArgs.Swall          = 0.75*1; %wall with three windows 3*200e-3*287e-3
sArgs.VrecRoom       = 0.75*1*1.13;
sArgs.RT             = [];
sArgs.limits         = [];
sArgs.density        = [];
sArgs.thickness_i      = [];
sArgs.YoungsModulus  = [];
sArgs.PoissonsRatio  = 0.3;
sArgs.Material       = [];
sArgs.thickness_ii      = [];%Dicke Platte 2
sArgs.thickness_air      = [];%Luftdicke
sArgs.openingarea = []; %Öffnungsfläche
%sArgs.plateFl = [];
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.limits)
    sArgs.limits = [sArgs.RT.freqVector(1) sArgs.RT.freqVector(end)];
end
ita_verbose_info(['wall surface = ',num2str(sArgs.Swall),'m^2'],1);
ita_verbose_info(['receiving room volume = ',num2str(sArgs.VrecRoom),'m^3'],1);

materialStr = [sArgs.Material ': d_1 = ' num2str(sArgs.thickness_i*1000,2),' mm '];
if sArgs.thickness_ii~=0
    materialStr = [materialStr ', d_2 = ' num2str(sArgs.thickness_air*1000,2),...
        ' mm , d_2 = ', num2str(sArgs.thickness_ii*1000,2), ' mm '];
elseif sArgs.openingarea~=0
    materialStr = [materialStr ', A = ' num2str(sArgs.openingarea,2), ' mï¿½ '];
end

%% body
data.channelNames = cellstr([repmat('MIC',data.nChannels,1),num2str((1:data.nChannels).')]);
%pcompFB = ita_spk2frequencybands(data,'bandsperoctave',sArgs.fraction,'method','added','freqRange',sArgs.limits); %load pressure and make frequency bands
pcompFB = ita_spk2frequencybands(data,'method','added','freqRange',sArgs.limits); %load pressure and make frequency bands

%% sound reduction index
pSendMS = mean(pcompFB.ch(sArgs.sendChannels)); % mean of squared pressure of positions in sending room
pRecMS  = mean(pcompFB.ch(sArgs.recChannels));  % mean of squared pressure of positions in receiving room

D = pSendMS/ pRecMS;
R = D * sqrt(sArgs.Swall); %R = ps^2/pr^2 * S / A;

% absorption area after Sabine
A = 0.161 * sArgs.VrecRoom ./ sArgs.RT.freq;
% compensate with absorption area
if length(A) ~= length(D.data)
    error([thisFuncStr, 'your reverberation time data does not have the right frequencies, leave the limits field blank'])
end
R.freq = bsxfun(@rdivide,R.freq,sqrt(A));

%% Single wall
if strcmpi(sArgs.Material,'MDF') || strcmpi(sArgs.Material,'Brass') || strcmpi(sArgs.Material,'aluminium')
    MassPerSqMetre=sArgs.density.*sArgs.thickness_i;
    BendingStiffnessPerSquareMetre=sArgs.YoungsModulus.*(sArgs.thickness_i.^3)/12./(1-sArgs.PoissonsRatio.^2);
    fc = 343^2*sqrt(MassPerSqMetre./BendingStiffnessPerSquareMetre)/2/pi;
    R0 = 10*log10(1+(2*pi.*R.freqVector*MassPerSqMetre/2/1.21/343).^2);
    R0 = R0(:);
    Rtheory = R;
    %Rtheory.freqData=10.^( (R0-5) /20); % empirical diffuse field correction
    Rtheory.freqData=10.^(R0 /20); 
    R = ita_merge(R,Rtheory);
end
%% Double wall
if strcmpi(sArgs.Material,'MDF double plate')
    MassPerSqMetre = sArgs.density.*sArgs.thickness_i;% m1'
    MassPerSqMetre2 = sArgs.density.*sArgs.thickness_ii;% m2'
    nstrich=sArgs.thickness_air./(343^2*1.21);% Nachgiebigkeit n'
    f0 = sqrt((MassPerSqMetre+MassPerSqMetre2)./nstrich.*MassPerSqMetre.*MassPerSqMetre2)/(2*pi);% resonanzfrequenz
    BendingStiffnessPerSquareMetre=sArgs.YoungsModulus.*(sArgs.thickness_i.^3)/12./(1-sArgs.PoissonsRatio.^2);%Biegesteife; fï¿½r doppelwand brauchen nicht
    fc = 343^2*sqrt(MassPerSqMetre./BendingStiffnessPerSquareMetre)/2/pi;%Koinzidenzfrequenz
    %R0 = 10*log10(1+(2*pi.*R.freqVector*MassPerSqMetre/2/1.21/343).^2);
%     
%     % neue R0 fuer Doppelwand. Quelle: Cremer L. Heckl M. Koerperschall (AV A1) 1967 s.477-480
%     R0_old = 10*log10(1+(2*pi.*R.freqVector.*(MassPerSqMetre+MassPerSqMetre2)/2/1.21/343) .* ...
%         (1-(R.freqVector.^2./f0.^2))).^2;

    % fpa: korrigiertes Massengesetz für Doppelwand - Steigung 18dB/Oktave (60dB/Dekade)
    c0 = ita_constants('c','T',20);
    rho0 = ita_constants('rho_0','T',20);
    R0 = 20*log10( (2*pi*R.freqVector).^3 * sArgs.thickness_air * MassPerSqMetre * MassPerSqMetre2 ./...
        (2*rho0.value^2 * c0.value^3) );

    Rtheory = R;
%     Rtheory.freq=10.^( (R0-10*log10(0.23*R0)) /10); % analytical diffuse field correction
    %Rtheory.freqData=10.^( (R0-5) /20); % empirical diffuse field correction
    Rtheory.freqData=10.^( R0 /20);
    R = ita_merge(R,Rtheory);
end
%% Plate with opening area
if strcmpi(sArgs.Material,'Plate with opening area')
    MassPerSqMetre = sArgs.density.*sArgs.thickness_i;% m1'
    BendingStiffnessPerSquareMetre=sArgs.YoungsModulus.*(sArgs.thickness_i.^3)/12./(1-sArgs.PoissonsRatio.^2);
    fc = 343^2*sqrt(MassPerSqMetre./BendingStiffnessPerSquareMetre)/2/pi;%Koinzidenzfrequenz
    tauRLuft = 1;% Lufttransmissionsgrad
    R12 = 10*log10(1+(2*pi.*R.freqVector*MassPerSqMetre/2/1.21/343).^2);% Platte 1
    tauR12 = 10.^(-R12./10); % Platte 1 Transmissionsgrad
    surfPlate = sArgs.Swall-sArgs.openingarea;% Flaeche der Platte ohne Loecher
    R_R = teilSchalldaemmmass(tauRLuft,tauR12, sArgs.openingarea, surfPlate);
    R0 = round(R_R*10)/10;
    R0 = R0(:);
    Rtheory = R;
    % Rtheory.freq=10.^( (R0-10*log10(0.23*R0)) /10); % analytical diffuse field correction
    %Rtheory.data=10.^( (R0-5) /10); % empirical diffuse field correction
    
    Rtheory.data=10.^( (R0) /20); % empirical diffuse field correction
    
    R = ita_merge(R,Rtheory);
end
       
%% root of all values to simplify plotting ...
% R = sqrt(R);
% D = sqrt(D);
% pSendMS = sqrt(pSendMS);
% pRecMS  = sqrt(pRecMS);

%% update meta info
if ~isempty(sArgs.Material)
    
    D.channelNames{1} =  'squared sound pressure ratio';
    R.channelNames{1} = 'R measured: ';
    R.channelNames{2} = 'R calculated mass law: ';
%     R.channelNames{3} = ''; % mumpitz
    R.channelUnits{1} = '';
    R.channelUnits{2} = '';
%     R.channelUnits{3} = '';
    
    pcompFB.channelNames = cellstr([repmat([materialStr, ': mic'],pcompFB.nChannels,1) num2str((1:pcompFB.nChannels).')]);
    pSendMS.channelNames{1} = 'MEAN of squared sending room pressure: ';
    pRecMS.channelNames{1} =  'MEAN of squared receiving room pressure' ;
    
else
    D.channelNames{1} = 'squared sound pressure ratio';
    R.channelNames{1} = 'R measured';
    R.header.Channel(2).Name = 'R calculated';
    pSendMS.channelNames{1} = 'MEAN of squared sending room pressure';
    pRecMS.channelNames{1} =  'MEAN of squared receiving room pressure';
end

%% save extra information
R.userData{1}.RT = sArgs.RT;

%% Add history line
R       = ita_metainfo_add_historyline(R,mfilename,varargin);
pcompFB = ita_metainfo_add_historyline(pcompFB,mfilename,varargin);
pSendMS = ita_metainfo_add_historyline(pSendMS,mfilename,varargin);
pRecMS  = ita_metainfo_add_historyline(pRecMS,mfilename,varargin);
D       = ita_metainfo_add_historyline(D,mfilename,varargin);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
elseif nargout == 1
    varargout(1) = {R};
else
    varargout(1) = {R};
    varargout(2) = {fc};
    varargout(3) = {pcompFB};
    varargout(4) = {pSendMS};
    varargout(5) = {pRecMS};
    varargout(6) = {D};
end

%end function
end

%% Tau for sound insulation index
function R = teilSchalldaemmmass (tauLuft, tauPlatte, surfLuft, surfPlatte)
        tauGes = (tauLuft*surfLuft+tauPlatte*surfPlatte)/(surfLuft+surfPlatte);
        R = 10*log10(1./tauGes);
end
