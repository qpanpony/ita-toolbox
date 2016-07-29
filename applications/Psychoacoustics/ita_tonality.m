function varargout = ita_tonality(varargin)
%ITA_TONALITY - TONALITY ref. DIN 45681 (2002)
%  This function gives:
% TONALITY ref. DIN 45681 (2002)
% tonh_max  = Maximum Tonal Audibility [dB]. Der  Maximale Wert aller DL
% ist nach DIN 45681(2002) maßgeblich für die Tonhaltigkeit
% tonh_maxf = Frequency [Hz] of this maximum
% info     = Information Matrix like in DIN paper
%  Syntax:
%   audioObjOut = ita_tonality(audioObjIn)
%
%  Example:
%   audioObjOut = ita_tonality(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tonality">doc ita_tonality</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Daniel Cragg -- Email: daniel.cragg@akustik.rwth-aachen.de
% Created:  22-Jun-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 
sig=input;
sig_t=sig.time;
% Frequenzgrenzen der Auswertung. ACHTUNG: Das sind die 
% FFT-Punkte, Frequenz durch Deltaf dividiert! 50 = (100 Hz/2 Hz)
anfang = 50; % 100 Hz
ende = 4096; % 8192 Hz

Nf = 22050;  % Anzahl Samplepunkte
sampfrq = 44100;
freq = 2:2:22050;

k_max = round(Nf*0.5);
clear L_pt L_pn f_max
merker(1:22050) = 0;

% Signal muss Spalte sein: Zeilenvektor wird transponiert
if size(sig_t,1) == 1
    sig_t = sig_t.';
end

% ---------------- self-averaging -----------------

num_av = floor((length(sig_t)-2050)/10000 - 1); % überlappend nach 10.000

for i = [1:num_av]
    a = i*10000;
    sig_t1 = sig_t((a-9999):a+12050);
    Sig_tmp = abs(fft(sig_t1.*hanning(Nf))).';
    Sig_f(i,:) = (Sig_tmp(1:round(Nf/2)).*sqrt(2)/(2e-5*Nf)).^ 2;
end
pegel = 10 * log10 (mean(Sig_f));

figure(1)
plot(freq(1:2000),pegel(1:2000))
axis([0 2500 -20 80])
text(20,70,['Averages: ' num2str(num_av)])

% ---------------- Anfang und Ende des Untersuchungsbereiches bestimmen

    i = 1;
    start = 1;
    delta_L(anfang:ende) = 0;
    freq_anfang = freq(anfang);
    freq_ende = freq(ende);
    
%   ---------------- Linienbreite bestimmen

    linienbreite = freq(2) - freq(1);

%   ---------------- Falls Spektrum nicht A-bewertet, A-Bewertung vornehmen

% hier: KEINE A-Bewertung

    for i = start:ende
        pegel(i) = pegel(i) + 165.5 + 20*log10(freq(i)^4 / (freq(i)^2 + 20.6^2) / (freq(i)^2 + 12200^2) / sqrt(freq(i)^2 + 107.7^2) / sqrt(freq(i)^2 + 737.9^2));
    end

%   ---------------- Frequenzgruppenbreite sowie Unter- und Obergrenzen bestimmen
    j1alt = 2;
    j2alt = 2;
%   ----------------  schleife = 1
    for i = anfang:ende
        delta_f_c(i) = 25 + 75 * (1 + 1.4 * (freq(i) / 1000)^2)^0.69;    %   delta_f_c
        f1(i) = freq(i) - 0.5 * delta_f_c(i);                            %   f1
        f2(i) = freq(i) + 0.5 * delta_f_c(i);                            %   f2
        
        % index fgi1 der Frequenzgruppenuntergrenze bestimmen
        j = j1alt;
        while freq(j) < f1(i) & j < ende
            j = j + 1;
        end
        fgi1(i) = j;
        j1alt = j;
        
        % index fgi2 der Frequenzgruppenobergrenze bestimmen
        j = j2alt;
        while freq(j) < f2(i) & j <= ende
            j = j + 1;
        end
        fgi2(i) = j - 1;
        j2alt = j;
    end
    
%   ---------------- Töne suchen

%   ----------------  schleife = 2
    for i = anfang:ende  % alle Linien des Spektrums in aufsteig. Reihenfolge untersuchen
                         %   mittleren Schmalbandpegel LS bestimmen
        merker(i) = 1;
        linien = 1000;
        vorwert = 0;
        LS(i) = 1000;

        % Beginn der iterationsschleife
        while linien > 9 & vorwert ~= LS(i)      % Abbruch, wenn LS sich nicht mehr ändert
                                                 % oder weniger als 10 Linien zur Bestimmung
                                                 % von LS übriggeblieben sind
% --------------NEU: vektorisiert
            merker_tmp = zeros(length(fgi1(i):fgi2(i)),1);
            merker_tmp(pegel(fgi1(i):fgi2(i)) > LS(i) + 6) = 2; % die mehr als 6 dB über LS liegen
            merker(fgi1(i):fgi2(i))=merker_tmp;
% --------------ENDE NEU

            vorwert = LS(i);

%            LS(i) = 0;
%            linien = 0;

% --------------NEU: vektorisiert
            k_vector = find(merker(fgi1(i):fgi2(i))==0) + fgi1(i) - 1;
            LS(i) = sum(10.^(pegel(k_vector)/10));            
            linien = length(k_vector); 
% --------------ENDE NEU
            
            if linien > 0
                LS(i) = 10 * log10(LS(i) / linien) - 1.76;   % LS berechnen
            end
        end
        % Ende der Iterationsschleife
        
        if linien < 10                          % Falls Iteration wegen Unterschreitung der
            LS(i) = vorwert;                    % Mindestzahl an Linien beendet wurde,
        end                                     % letzten LS mit Anzahl > 10 wählen

%        for j = fgi1(i):fgi2(i)                 % verwendete Hilfsmerker rücksetzen
%            merker(j) = 0;
%        end
        merker(fgi1(i):fgi2(i)) = 0;
    end
      
    % ---------------- alle Linien des Spektrums in aufsteig. Reihenfolge untersuchen

%   ----------------  schleife = 3
    for i = anfang:ende
        if pegel(i) >= LS(i) + 6                % potenziellen Ton als ununterbrochenen
            D_S = pegel(i)-LS(i);
            maximum = i;                        % Bereich mit Pegel > LS + 6 dB suchen
            maxpegel = pegel(i);
            kmax = i + 1;
            while pegel(kmax) >= LS(kmax) + 6
                if pegel(kmax) > maxpegel
                    maxpegel = pegel(kmax);     % und Frequenz der Spektrallinie mit
                    maximum = kmax;             % maximalem Pegel als Frequenz des
                end                             % potenziellen Tonesermitteln
                kmax = kmax + 1;
            end
% !!! mkl NEU: ohne diese Zeilen geht's nicht! (Anfang) ------------------
            kmax = i - 1;
            while pegel(kmax) >= LS(kmax) + 6
                if pegel(kmax) > maxpegel
                    maxpegel = pegel(kmax);     % 
                    maximum = kmax;             % 
                end                             % 
                kmax = kmax - 1;
            end
            if maximum>=anfang
                i = maximum;        % sonst unter 100 Hz!
            end
% !!! mkl NEU: ohne diese Zeilen geht's nicht! (Ende) ------------------
            
            % ---------------- Tonpegel des potenziellen Tones bestimmen
            LT(i) = 10^(pegel(i) / 10);
            merker(i) = 0;
            TonLinien(i) = 1;

            % ---------------- zu kleinen Frequenzen hin Nebenlinien des Tones suchen
            j = i - 1;
            while pegel(j) >= LS(i) + 6 & pegel(j) >= pegel(i) - 10
                LT(i) = LT(i) + 10^(pegel(j) / 10);
                merker(i) = 3;
                TonLinien(i) = TonLinien(i) + 1;
                j = j - 1;
            end
            if j < i - 1           % Flankensteilheit der unteren Flanke berechnen
                untereFlanke(i) = (pegel(i) - pegel(j)) * freq(i) / sqrt(2) / (freq(i) - freq(j));
            else
                untereFlanke(i) = 100;
            end

            % ---------------- zu hohen Frequenzen hin Nebenlinien des Tones suchen
            j = i + 1;
            while pegel(j) >= LS(i) + 6 & pegel(j) >= pegel(i) - 10
                LT(i) = LT(i) + 10^(pegel(j) / 10);
                merker(i) = 3;
                TonLinien(i) = TonLinien(i) + 1;
                j = j + 1;
            end
            if j > i + 1           % Flankensteilheit der oberen Flanke berechnen
                obereFlanke(i) = (pegel(i) - pegel(j)) * freq(i) / sqrt(2) / (freq(j) - freq(i));
            else
                obereFlanke(i) = 100;
            end
            
            LT(i) = 10 * log10(LT(i));
            if merker(i) == 3                  % wenn Nebenlinien addiert wurden,
                LT(i) = LT(i) - 1.76;            % Korrektur für Hanning-Fenster vornehmen
            end
            
            % ---------------- Prüfung ob Ton, dann Tonzuschlag berechnen
            LG(i) = LS(i) + 10 * log10(delta_f_c(i) / linienbreite);
            av(i) = -2 - log10(1 + (freq(i) / 502)^2.5);
            delta_L(i) = LT(i) - LG(i) - av(i);
            
            % ---------------- Kriterium Ausgeprägtheit:
            %           kein Ton, wenn er breiter als 18 * (1 + 0.001 *fT) der Frequenzgruppe
            %           oder Flankensteilheit kleiner 24/Oktave ist
%            if (TonLinien(i) * linienbreite > 18 * (1 + 0.001 * freq(i)) | untereFlanke(i) < 24 | obereFlanke(i) < 24) & antwortS ~= 'vbYes'
            if (TonLinien(i) * linienbreite > 18 * (1 + 0.001 * freq(i)) | untereFlanke(i) < 24 | obereFlanke(i) < 24)
                delta_L(i) = 0;
            end
            
            for j = fgi1(i):fgi2(i)    % verwendete Hilfsmerker rücksetzen
              merker(j) = 0;
            end
            
            i = kmax - 1;              % im oben untersuchten Bereich nicht weiter suchen
                % ??????? WIE GEHT DAS ??????            
        end
    end
        
%   ---------------- Töne in einer Frequenzgruppe addieren
%   ----------------  schleife = 4
    for i = ende:-1:anfang
        if delta_L(i) > 0                   % wenn Ton gefunden
            LT_FG(i) = 10^(LT(i)/10);
            for j = (i - 1):-1:fgi1(i)      % zu tiefen Frequenzen hin prüfen,
                if delta_L(j) > 0           % ob in der Frequenzgruppe ein weiterer Ton liegt
                    LT_FG(i) = LT_FG(i) + 10^(LT(j) / 10);
                    merker(i) = 4;
            end
            end
                
            for j = (i + 1):fgi2(i)         % zu hohen Frequenzen hin prüfen,
                if delta_L(j) > 0           % ob in der Frequenzgruppe ein weiterer Ton liegt
                    LT_FG(i) = LT_FG(i) + 10^(LT(j) / 10);
                    merker(i) = 4;
                end
            end
            
            if merker(i) == 4              % wenn mindestens 2 Töne in der Frequenzgruppe
                LT_FG(i) = 10 * log10(LT_FG(i));
                delta_L_FG(i) = LT_FG(i) - LG(i) - av(i);
            else
                LT_FG(i) = 0;
            end
        end
    end
    
%   ---------------- Töne anzeigen und maximalen Zuschlag bestimmen
    maxzuschlag = 0;
    j = 1;
    DL(i)=delta_L(i);
    DLF(i) = DL(i);
    for i = anfang:ende
        if delta_L(i) > 0
        
            DL(i)=delta_L(i);
            DLF(i) = DL(i);
            if merker(i) == 4
                DLF(i) = delta_L_FG(i);
            end
            info(j,1) = freq(i);
            info(j,2) = delta_f_c(i);
            info(j,3) = LS(i);
            info(j,4) = LT(i);
            info(j,5) = LG(i);
            info(j,6) = av(i);
            info(j,7) = DL(i);
            info(j,8) = merker(i);
            info(j,9) = LT_FG(i);
            info(j,10) = DLF(i);
            j = j + 1;
        end
    end
    tonh_max = max(DL,DLF);
    tonh_maxfreq = find(tonh_max==max(tonh_max));
    tonh_maxf = freq(tonh_maxfreq);
    tonh_max = max(tonh_max);
    
    

% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {tonh_max}; 
varargout (2)= {tonh_maxf};
varargout (3) = {info};
%end function
end