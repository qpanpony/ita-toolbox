%% Short tutorial about data structure and methods in itaSyntheticDir
%Kurze Zusammenstellung der Datenstruktur und der Funktionen von
%itaSyntheticDir, sowie der Ergebnisse der Messungen im Seminarraum
%
%
% Ordnerstruktur : 
% - sem_1tilt und sem_2tilt (itaSyntheticDir Objekte)
%   - this.mat : Zeiger auf itaSyntheticDir-Objekt
%   - synthSuperSpeaker : sphärische Koeffizienten des synthetisierten
%     Lautsprecherarrays, in Frequenzblöcke zusammengefasst, über 
%     this.freq2coefSH_synthSpeaker abrufbar
%   - sphRIR  : Impulsantworten der sphärischen Harmonischen
%     z.B. : md_M1_sphRIR.ita: itaAudio mit allen Impulsantworten, gemessen
%     an Mic 1
%   - sphFilter : Filter zur Erzeugung der sphRIR (nicht geglättet)
%     dienen nur zur Evaluation
%   - filterData : (eigentlich nur) temporäre Zwischenspeicherung des invertierten
%     synthSuperSpeakers, Frequenzblöcke
%   
% - Messdaten:   
%   -  Nur ein Kippwinkel (für sem_1tilt) : Ordner 'DODE_I\data_csII'
%      - 'md_M1_6.ita' : "multi channel dode, Mic 1, turntableposition 6"
%        enthält die RIRs aller 12 Treiber, channelCoordinates =
%        Rotationswinkel (ACHTUNG : im Uhrzeigersinn : phi = 2l*pi - channelChoordinates.phi)
%      - 'sd_6.ita' : "single channel dode, turntableposition 6"
%        enthält RIR des Referenzdodekaeders an allen 5 Mikrofonen
%
%   -  zwei Kippwinkel (für sem_2tilt) (Daten wie oben)
%      Ordner 'DODE_IIa\data_csII' und 'DODE_IIb\data_csII'
%
%   -  Vergleichsmessung mit der Zielquelle: Ordner: 'CUBE_I\data_cs', 'CUBE_II\data_cs'
%      - sd_1.ita : Referenzdodekaeder (siehe oben)
%      - cu_2.ita : RIR des Würfellautsprechers an turntableposition 2,
%        alle 5 Mics
%
%  - Fotos : Mikrofone : 1+2 = inkes & rechtes Ohr des Kunstkopfes, 
%           3,4,5 : Ke4-Kapseln, von der rednerposition zum Fenster hin
%           durchnumeriert (3, ca. 2 m vom Dode weg, 4 mitten im Raum, 5 weit hinten)
%  
%

%% Beispiel für die Funktionen der itaSyntheticDir an Hand von 'sem_2tilt'

%% initialize: 
  % basic settings
    this = itaSyntheticDir;
    this.folder = 'sem_2tilt'; % object's homedirectory
    this.measurementDataFolder = {'...\DODE_IIa\data_csII', '...\DODE_IIb\data_csII'};
    this.euler_tilt = {[tilt_angles_I], [tilt_angles_II]};
    this.speaker = dode;       % theitaBalloon of your measurement speaker array
    this.speaker_channels = 1:12; % the (measurement)-channels that refer to your used speakers
    this.measurementCoordinates_are_itaItalian = true; %if the channelCoordinates in your measurement data are ste by itaItalian
    
  % set maximum order of spherical harmonic stuff
    this.nmax = 25; % all the calculations are beeing done with this maximum order
    this.speaker_nmax = 30; % if you want to, you can synthesize the synthSpeaker up to an higher order (evaluation purposes only)
    this.encode_nmax = 15;  % if encoded 
    
  % set regarization
    this.regularization = 1e-5; % tikhonov regularization parameter 
    this.target_tolerance = -0.0100; %[dB] if single speakers are excluded, the inner product theoretical achieved directivity result must not get worse than ths tolerance
    
%% synthezise an awesome array
 this.getPositions('nPos', 100); % selects the 100 'best' rotated measurements to build a synthSuperSpeaker
 this.makeSynthSpeaker;          % virtual synthesis of a speaker array
 
 %% synthesis of RIRs method I
 
 filter = this.itaBalloon2synthFilter(target_balloon);  % see documentation!!!!
 % give it directivity via an itaBalloon and it will return nice filters to
 % weight your measurements
    %uses the following functions:
    targets_coeficients = ita_sph_rotate_realvalued_basefunc(targets_coeficients, [your rotation angles]);
    weights = this.freqData2synthesisRule;
    filter = this.synthesisRule2filter(weights,'method','polynomial');
    
 RIR = this.convolve_filter_and_measurement(filter, filemask);
    % filemask : z.B. 'md_M4_'
    
%% synthesis of RIRs method II
%to proceed only once
this.makeSphRIR;  % see documentation!!!!
this.convolve_itaBalloon_and_sphRIR(target_balloon); % see documentation!!!!


%% evaluation tools
% compare an original an a synthesized RIR:
test_maku_compare; % see documentation!!!!

% compare an original an a synthesized directivity:
test_maku_plot_synthresult; % see documentation!!!!
    

  