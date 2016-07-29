%% Short demo for itaSphSynthDirectivity class
%
%  
%  Das hier dient vorläufig auch als Demo für diese Klasse. Ist im Prinzip
%  bisschen wir itaBalloon: Einen Haufen settings geeignet setzen, play
%  drücken, warten, warten und dann ein paar Auswertungsroutinen genießen
%
%
%
%% settings
this = itaSphSynthDirectivity;
this.folder = [homeFolder '\evaluation\superDode'];
this.name = 'superDode';
this.array = ita_read_itaBalloon([balloonHomeFolder '\Dode_Mid2_c\DODE_MID']);

% basic settings
this.freqRange      = [100 16000];
this.arrayNmax      = 30;       % maximale Ordnung, bis zu der das synthetisch erweiterete Array berechnet wird
this.arrayChannels  = 1:12; % die Channels des itaBalloons, die in der Messung angewendet wurden
this.nmax           = 30;            % maximale Ordnung, bis zu der alles andere Berechnet wird
this.precision      = 'single';

% important stuff: 
this.measurementDataFolder = ...  % Pade der Messdaten
    {[homeFolder filesep measurementFolder{1} '\data_p'], ...
     [homeFolder filesep measurementFolder{2} '\data_p'], ...
     [homeFolder filesep measurementFolder{3} '\data_p']};
this.tiltAngle = ...              % zugeordnete Euler - Kippwinkel
    {[0 180 0; 38.5+80 16.2 0]* pi/180, ... 
     [0 180 0; 38.5+0 16.2 0] * pi/180, ...
     [0 180 0; 38.5+40 16.2 0]* pi/180};
 
this.filemask = 'dode';           % filemask
this.rotationAngle_counterClockWise = false; % angles by itaItalian : dreht im Urzeigersinn !!
this.getPositions('nPos',20);                % liest this.rotationAngle aus Messdaten, setzt rooting channel2
save(this);


%% --- Der Abschnitt dauert bisschen (trotz intensiven Gebrauchs des profilers...)!!
% engster Flaschenhals : fft in 'SHfilter2SHrir'
%
% Für diese Funktionen gibt es jeweils aufschlussreiche Dokumentation
%
disp('makin awesome enlarged array');
this.makeSynthArray;        % die SH-Koeffizienten des synthetischen Arrays werden berechnet (Die große D-Matrix)
disp('makin awesome synthesis filter');
this.makeSHfilter;          % Invertierung der D-Matrix, regularisiert. + Umsortieren der Vorzugsrichtung: 
                            %    Bislang waren die Daten nach Frequenzen
                            %    unterteilt, jetzt nach Einzellautsprechern
disp('makin awesome synthesized room impulse responses');                            
this.SHfilter2SHrir;        % Die Filter werden mit da Messung gefaltet

% Quelle synthetisieren
target = ita_read_itaBalloon([balloonHomeFolder '\CUBEd\CUBE']);
ao = this.convolve_itaBalloon_and_SH_RIR(target);

%% --- Auswertung -----------------

% coeffizienten des erweiterten Arrays:
coef = this.freq2coefSH_synthArray(2000);  % -> see doc

% 'mein' graph
RMS  = this.evaluate_synthesisError;   % -> see doc

% filter anschauen (index von zu synthetisierender sphericsal harmonic 2
% filter)
ao   = this.idxSH2filter(1);        



%% Vergleich mit Messung;

target = ita_read_itaBalloon([balloonHomeFolder '\CUBEd\CUBE']);
orgFiles = [homeFolder filesep measurementFolder{7} '\data_p\cube'];
org = itaAudio(numel(dir([orgFiles '*'])),1);
rot = {};
for idx = 1:length(org)
    org(idx)= ita_read([orgFiles int2str(idx) '.ita']);
    rot = [rot, {[0 0 2*pi - org(idx).channelCoordinates.phi(1)]}];  %#ok<AGROW> %CUBE's rotation angles (euler format)
end

synth = this.convolve_itaBalloon_and_SH_RIR(target, 'rotate',rot);  % synth: an array of itaAudios: length(synth) == length(rot)