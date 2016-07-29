function impedanceResults = ita_impcalc_wo_gui(varargin)
% ITA_IMPCALC_WO_GUI - Calculates impedances for layered absorber configurations without opening the GUI ita_impcalc_gui
%
% This function is useful for script processing. However, it is recommended
% that the layered absorber configurations are defined and stored as .mat
% files within the GUI. It is quite difficult to generate the absorber configurations by hand.
% The given function takes the absorber setup file (.mat) and calculates absorption, reflection factor,
% surface admittance and surface impedance for the configuration
%
%  Syntax:
%   impResults = impedanceResults = ita_impcalc_wo_gui(fullFilePath2AbsorberConfigurationStruct, options)
%   impResults = impedanceResults = ita_impcalc_wo_gui(AbsorberConfigurationStruct, options)
%
%   Options:
%           'modus'         'Impedanz'(default) oder 'Matrix'
%           'save'          'Result'(default) oder 'Audio'
%           'fftDegree'     16 (default), only relevant if 'save' is set to 'Audio'
%           'sampleRate'    44100 (default), only relevant if 'save' is set to 'Audio'
%   Output:
%           impResults      4-channel itaResult or 4-channel itaAudio
%                           containing [Impedance, Admittance, Reflection Factor and Absorption]
%
% %  Example:
%             impResults = impedanceResults = ita_impcalc_wo_gui('E:\MyFiles\impedanz_test.mat','modus','Impedanz','save','Result')
%             impResults = impedanceResults = ita_impcalc_wo_gui('E:\MyFiles\impedanz_test.mat','modus','Impedanz','save','Result')
%
%
%  See also:
%   ita_impcalc_gui
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_impcalc_wo_gui">doc ita_impcalc_wo_gui</a>

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created:  03-Jun-2011



%Abfrage ob erster Eingabeparamter ein struct oder ein string ist, laden
%der Daten
firstVar = varargin{1};
varargin = varargin(2:end);
if isa(firstVar,'struct')==1
    saveIt = firstVar;
elseif isa(firstVar,'char')==1
    load(firstVar);
elseif isa(firstVar,'struct')==0 && isa(firstVar,'char')==0
    error('Es wurde weder der Pfad zu einer Datei, noch die Datei selbst angegeben. Bitte an erster Stelle der Eingabe hinzufuegen!');
end

% Define default values
sArgs.modus='Impedanz';
sArgs.save='Result';
sArgs.fftDegree  = 16;
sArgs.sampleRate = 44100 ;

% Parse arguments
[sArgs] = ita_parse_arguments(sArgs,varargin);

% Setzten des matrixModus
if 1==strcmp(sArgs.modus,'Matrix')
    matrixModus = 1;
elseif 1==strcmp(sArgs.modus,'Impedanz');
    matrixModus=0;
else
    error('Die Eingabe der Modusart ist nicht korrekt. Wahlmoeglichkeiten sind "Matrix" und "Impedanz".');
end
% Setzten des Speicherformats
if 1==strcmp(sArgs.save,'Result')
    save_format = 0;
elseif 1==strcmp(sArgs.save,'Audio');
    save_format = 1;
else
    error('Die Eingabe des Speicherformats ist nicht korrekt. Wahlmoeglichkeiten sind "Result" und "Audio".');
end

fftDegree  = sArgs.fftDegree;
sampleRate = sArgs.sampleRate;

% LISTBOX und MaterialDatenListe holen
matListNames = saveIt.rf_name_cell;
matData = saveIt.matData;
nMats = length(matData);

% Pruefen ob wenigstens eine Komponente definiert ist, sonst error
if isempty(matListNames)
    error('Bitte erst die Komponenten definieren!');
end

% Abschluss & Modus speichern
abschlussArt = [saveIt.abschluss_hart, saveIt.abschluss_frei, saveIt.abschluss_vakuum] * [0;1;2];
diffusEinfall = 1- saveIt.sea.senk;
vorAbschluss = matData{end};

% Matrixmodus und gleichzeitig diffuser Schall abfangen
if (matrixModus && diffusEinfall)
    error('Im Matrixmodus bitte einen bestimmten Winkel waehlen!');
end

% PLAUSIBILITAETSCHECKS FUER MATERIALIENREIHENFOLGE UND ABSCHLUSS

% CHECK I
% Restriktionen fuer unterschiedliche Abschluss-Bedingungen
if ~matrixModus   % falls nicht Matrix modus gewaehlt wurde
    if abschlussArt == 0 % schallharter Abschluss
        if isa(vorAbschluss,'lochplatte') %Lochplatte
            error('Es muss mindestens eine Schicht zwischen Lochplatte und schallhartem Abschluss definiert sein.');
        elseif isa(vorAbschluss,'belag') %Belag
            error('Belag am Ende der Anordnung vor schallhartem Abschluss ist irrelevant. (Berechnung wird fortgesetzt)');
        end
    elseif abschlussArt == 2 % Vakuum
        if isa(vorAbschluss,'schicht') % Schicht
            error('Poroese Schicht vor Vakuum nicht moeglich. Abschlussbedingung Vakuum nur fuer luftundurchlaessigen Belag am Ende des geschichteten Absorbers zulaessig.');
        elseif isa(vorAbschluss,'lochplatte') %Lochplatte
            error('Lochplatte vor Vakuum nicht moeglich. Abschlussbedingung Vakuum nur fuer luftundurchlaessigen Belag am Ende des geschichteten Absorbers zulaessig.');
        end
    end
end

% CHECK II
% Es ist nicht moeglich, dass zwei Lochplatten ohne eine (existierende)
% dazwischenliegende Schicht (d.h. Schicht_Dicke > 0) aufeinanderfolgen
if nMats > 1
    %Suche Lochplatten
    isLP = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        end
    end
    
    % nachsehen, ob zwei Lochplatten direkt hintereinander
    for k = 1:nMats-1
        if isLP(k) && isLP(k+1)
            error('Es ist nicht moeglich, dass zwei Lochplatten ohne eine (existierende) dazwischenliegende Schicht aufeinanderfolgen.');
        end
    end
end

% CHECK III
% Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss
% dieser eine definierte Stroemungsresistanz haben
if nMats > 1
    %Suche Lochplatten
    isLP = false(1,nMats);
    isB  = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        elseif isa(matData{k},'belag')
            isB(k) = true;
        end
    end
    
    % nachsehen, ob Lochplatten und Belag direkt hintereinander
    for k = 1:nMats-1
        if (isLP(k) && isB(k+1)) && (matData{k+1}.belagsTyp~=2)
            error('Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss dieser eine definierte Stroemungsresistanz haben');
        elseif (isLP(k+1) && isB(k)) && (matData{k}.belagsTyp~=2)
            error('Ist ein Belag vor oder hinter einer Lochplatte definiert, so muss dieser eine definierte Stroemungsresistanz haben');
        end
    end
end

% CHECK IV
% Ist eine Lochplatte beidseitig von Belaegen umgeben, so muessen beide
% Belaege eine definierte Stroemungsresistanz haben
if nMats > 2
    %Suche Lochplatten
    isLP = false(1,nMats);
    isB  = false(1,nMats);
    for k=1:nMats
        if isa(matData{k},'lochplatte')
            isLP(k) = true;
        elseif isa(matData{k},'belag')
            isB(k) = true;
        end
    end
    
    % nachsehen, ob Lochplatte mit Belag davor UND dahinter
    for k = 2:nMats-1
        if (isB(k-1) && isLP(k) && isB(k+1)) && ( (matData{k-1}.belagsTyp~=2) || (matData{k+1}.belagsTyp~=2) )
            error('Ist eine Lochplatte beidseitig von Belaegen umgeben, so muessen beide Belaege eine definierte Stroemungsresistanz haben.');
        end
    end
end

% EINZELNE MATERIALIEN AUF VOLLSTAENDIGKEIT PRUEFEN:
for k = 1:nMats
    check = [];
    switch class(matData{k})
        case 'belag'
            switch matData{k}.belagsTyp
                case 1 % Massenbelag (luftundurchluessig)
                    check(1) = isnumeric([matData{k}.dicke, matData{k}.dichte, matData{k}.verlustFaktor]);
                    check(2) = all([matData{k}.dicke, matData{k}.dichte]  > 0);
                    check(3) = matData{k}.verlustFaktor >= 0;
                case 2 % Massenbelag (luftdurchluessig)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.stroemungsResistanz ]  > 0);
                case 3 % Platte
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.eModul, ...
                        matData{k}.querKontraktionsZahl, ...
                        matData{k}.verlustFaktor ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.eModul, ...
                        matData{k}.verlustFaktor, ...
                        matData{k}.querKontraktionsZahl ]  > 0);
                    check(3) = matData{k}.querKontraktionsZahl < 1;
                case 4 % MPP (mit Plattenparametern)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.eModul, ...
                        matData{k}.querKontraktionsZahl, ...
                        matData{k}.verlustFaktor, ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.eModul, ...
                        matData{k}.verlustFaktor, ...
                        matData{k}.querKontraktionsZahl
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]  > 0);
                    check(3) = matData{k}.perforationsRatio < 1;
                case 5 % MPP (ohne Plattenparameter)
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.dichte ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.dichte, ...
                        matData{k}.lochDurchmesser, ...
                        matData{k}.perforationsRatio ]  > 0);
                    check(3) = matData{k}.perforationsRatio < 1;
            end
            if ~all(check)
                error(['Fuer den Belag "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter gueltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!']);
            end
        case 'schicht'
            switch matData{k}.schichtModell
                case 1 % Luftschicht
                    check(1) = isnumeric(matData{k}.dicke);
                    check(2) = all([matData{k}.dicke] > 0);
                case 2 % Por. Abs. nach klassischer Theorie
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz, ...
                        matData{k}.raumGewicht, ...
                        matData{k}.porositaet, ...
                        matData{k}.strukturFaktor, ...
                        matData{k}.adiabatenKoeff ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz, ...
                        matData{k}.raumGewicht, ...
                        matData{k}.porositaet, ...
                        matData{k}.strukturFaktor, ...
                        matData{k}.adiabatenKoeff ] > 0);
                    check(3) = (matData{k}.porositaet >= 0.95) && (matData{k}.porositaet <= 1);
                    check(4) = (matData{k}.adiabatenKoeff >= 1) && (matData{k}.adiabatenKoeff <= 1.4);
                case 3 % Por. Abs. nach empirischer Kennwertrelation
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ] > 0);
                case 4 % Por. Abs. nach Komatsu Modell
                    check(1) = isnumeric([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ]);
                    check(2) = all([ matData{k}.dicke, ...
                        matData{k}.stroemungsResistanz ] > 0);
            end
            if ~all(check)
                error(['Fuer die Schicht "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter gueltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!']);
            end
        case 'lochplatte'
            % Bedingungen, die fuer alle Schichten erfuellt sein muessen
            check(1) = isnumeric( [matData{k}.dicke, ...
                matData{k}.lochSchlitzAbmessung, ...
                matData{k}.lochSchlitzAbstand] );
            check(2) = all([ matData{k}.dicke, ...
                matData{k}.lochSchlitzAbmessung, ...
                matData{k}.lochSchlitzAbstand ] > 0);
            if ~all(check)
                error(['Fuer die Lochplatte "' matData{k}.name ...
                    '" sind nicht alle notwendigen Eingangsparameter gueltig definiert. ' ...
                    'Bitte ueberpruefen Sie Ihre Eingaben.!']);
            end
    end
end

% ERZEUGE JEWEILS EINEN DUMMY FUER BELAG, SCHICHT UND LOCHPLATTE

dummy_belag      = belag('dummy belag');
dummy_lochplatte = lochplatte('dummy lochplatte');
dummy_schicht    = schicht('dummy schicht');

% LAGEN FESTLEGEN UND PSEUDO SCHICHTEN, BELAEGE UND LOCHPLATTEN EINFUEGEN
% jede Lage besteht aus einem Belag(B), einer Lochplatte(L) und einer Schicht(S).
%
% Typenliste erstellen
typListe = zeros(nMats,1);
for k=1:nMats
    switch class(matData{k})
        case 'belag'
            typListe(k) = 'B';
        case 'lochplatte'
            typListe(k) = 'L';
        case 'schicht'
            typListe(k) = 'S';
    end
end

% Speicher fuer Lagen struct allozieren
Lagen = cell(nMats,3); % die Anzahl der Lagen ist apriori nicht bekannt, aber maximal gleich nMats

curLage = 1;
k = 1;
% Immer Dreierpakete holen, und Lagen erstellen
while k <= nMats
    if k==nMats % nur noch ein Mat uebrig
        % das letzte verbliebene Material muss in eine eigene Lage
        switch char(typListe(k)) % letztes Mat holen
            case 'B'
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'L'
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'S'
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
        end
    elseif (k+1)==nMats % nur noch zwei Mats uebrig
        switch char(typListe(k:k+1)') % letzten 2 Mats holen
            case {'SB','SL','SS'} % die Schicht wird in eine Lage gepackt, das 2te (und letzte) Mat wird erst in der naechsten Lage eingefuegt
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
            case 'BB' % der Belag wird in eine Lage gepackt, der 2te (und letzte) Belag wird erst in der naechsten Lage eingefuegt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case 'BL' % Belag und Lochplatte werden in die letzte Lage gepackt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'BS' % Belag und Schicht werden in die letzte Lage gepackt
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case 'LB' % Lochplatte und Belag werden in die letzte Lage gepackt
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'LL' % 2 Lochplatten hintereinander nicht moeglich => error
                error('2 Lochplatten direkt hintereinander sind nicht moeglich!');
            case 'LS' % Lochplatte und Schicht werden in die letzte Lage gepackt
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
        end
    elseif (k+1)<nMats % ganzes Dreierpaket holen
        switch char(typListe(k:k+2)') % volles Dreierpaket holen
            case {'SSS','SSB','SSL','SBS','SBB','SBL','SLS','SLB'} % vordere Schicht in Lage, die anderen 2 Mats spaeter behandeln
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k};
                k=k+1;
            case {'SLL','BLL','LLS','LLB','LLL'} % 2 Lochplatten hintereinander nicht moeglich => error
                error('2 Lochplatten direkt hintereinander sind nicht moeglich!');
            case {'BSS','BSB','BSL'} % Belag und Schicht in Lage, drittes Mat spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case {'BBS','BBB','BBL'} % Belag in Lage, die anderen beiden Mats spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = dummy_lochplatte;
                Lagen{curLage,3} = dummy_schicht;
                k=k+1;
            case {'LSS','LSB','LSL'} % Lochplatte und Schicht in Lage, das dritte Mat spaeter
                Lagen{curLage,1} = dummy_belag;
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+1};
                k=k+2;
            case {'LBB','LBL'} % Lochplatte und Belag in Lage, drittes Mat spaeter
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'BLS' % alle drei Mats in Lage
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = matData{k+2};
                k=k+3;
            case 'BLB' % Belag und Lochplatte in Lage, drittes Mat spaeter
                Lagen{curLage,1} = matData{k};
                Lagen{curLage,2} = matData{k+1};
                Lagen{curLage,3} = dummy_schicht;
                k=k+2;
            case 'LBS' % alle drei Mats in Lage
                matData{k}.side = 1; % B ist hinter L
                Lagen{curLage,1} = matData{k+1};
                Lagen{curLage,2} = matData{k};
                Lagen{curLage,3} = matData{k+2};
                k=k+3;
        end
    end
    curLage = curLage+1;
end
anzahlLagen = curLage-1;

% Anzahl Lagen nun bekannt -> umspeichern
Lagen = Lagen(1:anzahlLagen,:);

% Funktion Impedanz.m ausfuehren
erg=Impedanz(saveIt, matrixModus, Lagen, anzahlLagen, abschlussArt);

%Funktion itaSave2 ausfuehren - Speichern der Ergebnisse
impedanceResults=ita_Save_wo_GUI(erg,save_format,sampleRate,fftDegree);
impedanceResults.userData = {erg.k_a,erg.Z_a};

end %function

function impedanceResults=ita_Save_wo_GUI(erg,save_format,sampleRate,fftDegree)
if save_format==0
    freq    = (erg.f).';
    if length(erg.theta) == 1
        if erg.modus == 0          % BESTIMMTER WINKEL UND IMPEDANZMODUS
            chIdx = 1;
            %             if get(handles.cb_impedanz, 'Value')
            data(chIdx) = itaResult(erg.Z, freq, 'freq');
            data(chIdx).channelNames{1} = 'Impedance';
            data(chIdx).channelUnits{1} = 'kg/(s m^2)';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_admittanz, 'Value')
            data(chIdx) = itaResult(erg.Y, freq, 'freq');
            data(chIdx).channelNames{1} = 'Admittance';
            data(chIdx).channelUnits{1} = 's m^2/kg';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_reflexionsfaktor, 'Value')
            data(chIdx) = itaResult(erg.R, freq, 'freq');
            data(chIdx).channelNames{1} = 'Reflection Factor';
            data(chIdx).channelUnits{1} = '';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_absorption, 'Value')
            data(chIdx) = itaResult(erg.alpha, freq, 'freq');
            data(chIdx).channelNames{1} = 'Absorption';
            data(chIdx).channelUnits{1} = '';
            chIdx = chIdx+1;
            %             end
        else                               % BESTIMMTER WINKEL UND MATRIXMODUS
            chIdx = 1;
            %             if get(handles.cb_kettenmatrix, 'Value')
            data(chIdx) = itaResult(erg.a11, freq, 'freq');
            data(chIdx).channelNames{1} = 'A_{11} (Kettenmatrix)';
            data(chIdx).channelUnits{1} = '';
            data(chIdx+1) = itaResult(erg.a12, freq, 'freq');
            data(chIdx+1).channelNames{1} = 'A_{12} (Kettenmatrix)';
            data(chIdx+1).channelUnits{1} = 'kg/(s m^2)';
            data(chIdx+2) = itaResult(erg.a21, freq, 'freq');
            data(chIdx+2).channelNames{1} = 'A_{21} (Kettenmatrix)';
            data(chIdx+2).channelUnits{1} = 'kg/(s m^2)';
            data(chIdx+3) = itaResult(erg.a22, freq, 'freq');
            data(chIdx+3).channelNames{1} = 'A_{22} (Kettenmatrix)';
            data(chIdx+3).channelUnits{1} = '';
            chIdx = chIdx+4;
            %             end
            %             if get(handles.cb_admittanzmatrix, 'Value')
            data(chIdx) = itaResult(erg.y11, freq, 'freq');
            data(chIdx).channelNames{1} = 'Y_{11} (Kettenmatrix)';
            data(chIdx).channelUnits{1} = 's m^2/kg';
            data(chIdx+1) = itaResult(erg.y12, freq, 'freq');
            data(chIdx+1).channelNames{1} = 'Y_{12} (Kettenmatrix)';
            data(chIdx+1).channelUnits{1} = 's m^2/kg';
            data(chIdx+2) = itaResult(erg.y21, freq, 'freq');
            data(chIdx+2).channelNames{1} = 'Y_{21} (Kettenmatrix)';
            data(chIdx+2).channelUnits{1} = 's m^2/kg';
            data(chIdx+3) = itaResult(erg.y22, freq, 'freq');
            data(chIdx+3).channelNames{1} = 'Y_{22} (Kettenmatrix)';
            data(chIdx+3).channelUnits{1} = 's m^2/kg';
            chIdx = chIdx+4;
            %             end
            %             if get(handles.cb_impedanzmatrix, 'Value')
            data(chIdx) = itaResult(erg.yz11, freq, 'freq');
            data(chIdx).channelNames{1} = 'Z_{11} (Kettenmatrix)';
            data(chIdx).channelUnits{1} = 'kg/s m^2';
            data(chIdx+1) = itaResult(erg.z12, freq, 'freq');
            data(chIdx+1).channelNames{1} = 'Z_{12} (Kettenmatrix)';
            data(chIdx+1).channelUnits{1} = 'kg/s m^2';
            data(chIdx+2) = itaResult(erg.z21, freq, 'freq');
            data(chIdx+2).channelNames{1} = 'Z_{21} (Kettenmatrix)';
            data(chIdx+2).channelUnits{1} = 'kg/s m^2';
            data(chIdx+3) = itaResult(erg.z22, freq, 'freq');
            data(chIdx+3).channelNames{1} = 'Z_{22} (Kettenmatrix)';
            data(chIdx+3).channelUnits{1} = 'kg/s m^2';
            chIdx = chIdx+4;
            %             end
        end
    else                                   % DIFFUSER SCHALLEINFALL UND IMPEDANZMODUS
        chIdx = 1;
        %         if get(handles.cb_impedanz, 'Value')
        data(chIdx) = itaResult(erg.Z_diff, freq, 'freq');
        data(chIdx).channelNames{1} = 'Impedance, diffuse incidence';
        data(chIdx).channelUnits{1} = 'kg/(s m^2)';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_admittanz, 'Value')
        data(chIdx) = itaResult(erg.Y_diff, freq, 'freq');
        data(chIdx).channelNames{1} = 'Admittance, diffuse incidence';
        data(chIdx).channelUnits{1} = 's m^2/kg';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_reflexionsfaktor, 'Value')
        data(chIdx) = itaResult(erg.R_diff, freq, 'freq');
        data(chIdx).channelNames{1} = 'Reflection Factor, diffuse incidence';
        data(chIdx).channelUnits{1} = '';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_absorption, 'Value')
        data(chIdx) = itaResult(erg.alpha_diff, freq, 'freq');
        data(chIdx).channelNames{1} = 'Absorption, diffuse incidence';
        data(chIdx).channelUnits{1} = '';
        chIdx = chIdx+1;
        %         end
    end
    impedanceResults = ita_merge(data);
else %save_format==1
    tmp     = ita_generate('flat',0,sampleRate,fftDegree);
    newFreq = tmp.freqVector;
    freq    = (erg.f).';
    %
    if length(erg.theta) == 1
        if erg.modus == 0          % BESTIMMTER WINKEL UND IMPEDANZMODUS
            chIdx = 1;
            %             if get(handles.cb_impedanz, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, erg.Z, newFreq, 'spline');
            channelNames{chIdx} = 'Impedance';
            channelUnits{chIdx} = 'kg/(s m^2)';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_admittanz, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, erg.Y, newFreq, 'spline');
            channelNames{chIdx} = 'Admittance';
            channelUnits{chIdx} = 's m^2/kg';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_reflexionsfaktor, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, erg.R, newFreq, 'spline');
            channelNames{chIdx} = 'Reflection Factor';
            channelUnits{chIdx} = '';
            chIdx = chIdx+1;
            %             end
            %             if get(handles.cb_absorption, 'Value')
            spk(:, chIdx)  = interp_zeroextrap(freq, erg.alpha, newFreq, 'spline');
            channelNames{chIdx} = 'Absorption';
            channelUnits{chIdx} = '';
            chIdx = chIdx+1;
            %             end
        else                               % BESTIMMTER WINKEL UND MATRIXMODUS
            chIdx = 1;
            %             if get(handles.cb_kettenmatrix, 'Value')
            spk(:, chIdx)  =  interp_zeroextrap(freq, erg.a11, newFreq, 'spline');
            spk(:, chIdx+1)  =  interp_zeroextrap(freq, erg.a12, newFreq, 'spline');
            spk(:, chIdx+2)  =  interp_zeroextrap(freq, erg.a21, newFreq, 'spline');
            spk(:, chIdx+3)  =  interp_zeroextrap(freq, erg.a22, newFreq, 'spline');
            channelNames{chIdx}   = 'A_{11}';
            channelNames{chIdx+1} = 'A_{12}';
            channelNames{chIdx+2} = 'A_{21}';
            channelNames{chIdx+3} = 'A_{22}';
            channelUnits{chIdx}   = '';
            channelUnits{chIdx+1} = 'kg/s m^2';
            channelUnits{chIdx+2} = 's m^2/kg';
            channelUnits{chIdx+3} = '';
            chIdx = chIdx+4;
            %             end
            %             if get(handles.cb_admittanzmatrix, 'Value')
            spk(:, chIdx)  =  interp_zeroextrap(freq, erg.y11, newFreq, 'spline');
            spk(:, chIdx+1)  =  interp_zeroextrap(freq, erg.y12, newFreq, 'spline');
            spk(:, chIdx+2)  =  interp_zeroextrap(freq, erg.y21, newFreq, 'spline');
            spk(:, chIdx+3)  =  interp_zeroextrap(freq, erg.y22, newFreq, 'spline');
            channelNames{chIdx}   = 'Y_{11}';
            channelNames{chIdx+1} = 'Y_{12}';
            channelNames{chIdx+2} = 'Y_{21}';
            channelNames{chIdx+3} = 'Y_{22}';
            channelUnits{chIdx}   = 's m^2/kg';
            channelUnits{chIdx+1} = 's m^2/kg';
            channelUnits{chIdx+2} = 's m^2/kg';
            channelUnits{chIdx+3} = 's m^2/kg';
            chIdx = chIdx+4;
            %             end
            %             if get(handles.cb_impedanzmatrix, 'Value')
            spk(:, chIdx)   =  interp_zeroextrap(freq, erg.z11, newFreq, 'spline');
            spk(:, chIdx+1) =  interp_zeroextrap(freq, erg.z12, newFreq, 'spline');
            spk(:, chIdx+2) =  interp_zeroextrap(freq, erg.z21, newFreq, 'spline');
            spk(:, chIdx+3) =  interp_zeroextrap(freq, erg.z22, newFreq, 'spline');
            channelNames{chIdx}   = 'Z_{11}';
            channelNames{chIdx+1} = 'Z_{12}';
            channelNames{chIdx+2} = 'Z_{21}';
            channelNames{chIdx+3} = 'Z_{22}';
            channelUnits{chIdx}   = 'kg/s m^2';
            channelUnits{chIdx+1} = 'kg/s m^2';
            channelUnits{chIdx+2} = 'kg/s m^2';
            channelUnits{chIdx+3} = 'kg/s m^2';
            chIdx = chIdx+4;
            %             end
        end
    else                                   % DIFFUSER SCHALLEINFALL UND IMPEDANZMODUS
        chIdx = 1;
        %         if get(handles.cb_impedanz, 'Value')
        spk(:, chIdx)  = interp_zeroextrap(freq, erg.Z_diff, newFreq, 'spline');
        channelNames{chIdx} = 'Impedance, diffuse incidence';
        channelUnits{chIdx} = 'kg/(s m^2)';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_admittanz, 'Value')
        spk(:, chIdx)  = interp_zeroextrap(freq, erg.Y_diff, newFreq, 'spline');
        channelNames{chIdx} = 'Admittance, diffuse incidence';
        channelUnits{chIdx} = 's m^2/kg';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_reflexionsfaktor, 'Value')
        spk(:, chIdx)  = interp_zeroextrap(freq, erg.R_diff, newFreq, 'spline');
        channelNames{chIdx} = 'Reflection Factor, diffuse incidence';
        channelUnits{chIdx} = '';
        chIdx = chIdx+1;
        %         end
        %         if get(handles.cb_absorption, 'Value')
        spk(:, chIdx)  = interp_zeroextrap(freq, erg.alpha_diff, newFreq, 'spline');
        channelNames{chIdx} = 'Absorption, diffuse incidence';
        channelUnits{chIdx} = '';
        chIdx = chIdx+1;
        %         end
    end
    if ~exist('spk', 'var')
        error('Bitte auswaehlen, was gespeichert werden soll!');
    end
    impedanceResults = itaAudio();
    impedanceResults.freqData = spk;
    impedanceResults.channelNames = channelNames;
    impedanceResults.channelUnits = channelUnits;
    %    impedanceResults.comment = comment;
    impedanceResults.signalType = 'energy';
    impedanceResults.fileName = 'newfile';
    impedanceResults.history = {'ita_impcalc_gui(filename)'};
    %     if strcmpi(type, 'ita')
    %         ita_write(impedanceResults, saveAs, 'overwrite');
    %     elseif strcmpi(type, 'ws')
    %         assignin('base', 'impCalcResults', impedanceResults);
    %     end
end
end %function