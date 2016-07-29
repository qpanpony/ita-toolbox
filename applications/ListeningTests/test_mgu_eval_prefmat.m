function test_mgu_eval_prefmat(varargin)
% Die Funktion analysiert Konsistenz und Konkordanz von vollständigen Paarvergleichsurteilen

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% eine 1 in der prefMat "wenn ein die Zeile kennzeichnendes Objekt einem die Spalte kennzeichnendens Objekt vorgezogen wurde"
% also: prefMat(item1, item2) = 1   ==> item1 besser als iterm2


sArgs         = struct('pos1_prefMat', [] ,'TestpersonNameCell', [], 'AnalyseName', 'Analyse', 'openExcelFile', true, 'excludeAlphaLimit', []);
[prefMat,sArgs] = ita_parse_arguments(sArgs,varargin);



TestPersonNames = sArgs.TestpersonNameCell;
AnalyseName  = sArgs.AnalyseName;

%% beispiel aus buch

% prefMat = [0 1 1 1 1 1; 0 0 0 1 0 1; 0 1 0 0 0 0;0 0 1 0 1 1 ; 0 1 1 0 0 1; 0 0 1 0 0 0];
% % Konkordanz
% prefMat = [ 0 1 1 1 1; 0 0 0 0 1; 0 1 0 1 1 ; 0 1 0 0 1; 0 0 0 0 0 ];
% prefMat(:,:,2) = [0 1 1 1 1; 0 0 0 0 1; 0 1 0 0 1; 0 1 1 0 1; 0 0 0 0 0];
% prefMat(:,:,3) = [0 1 0 1 1 ; 0 0 0 0 0; 1 1 0 1 1; 0 1 0 0 1; 0 1 0 0 0 ];
% prefMat(:,:,4) = [0 1 1 1 0 ;0 0 0 0 0 ; 0 1 0 0 1; 0 1 1 0 1 ; 1 1 0 0 0];
%
% AnalyseName = 'Buch beispieltest'
% clear TestPersonNames
%% test input data


[nItems nItems2 nPersons] = size(prefMat);



if ~isequal(nItems, nItems2)
    error('wrong prefMat dimensions')
end

for iPerson = 1:nPersons
    
    currentPrefMat = squeeze(prefMat(:,:,iPerson)) + diag(nan(nItems,1));  % set diagonal of matrix to nan
    
    
    if nItems * (nItems -1) ~= nansum(nansum(currentPrefMat + currentPrefMat.'))
        error('error')
    end
    
    
end


if ~exist('TestPersonNames', 'var') || isempty(TestPersonNames)
    TestPersonNames = cell(nPersons,1);
    for iPerson = 1:nPersons
        TestPersonNames{iPerson} = sprintf('VP %i', iPerson);
    end
end


clear nItems2

%%  Konsitenz
% K     :   Konsistenzkoeffizient  (1=konsistent, 0 = inkonsistent)
% d_max :   Maximale Anzahl inkonsistenter Triaden
% d     :   Anzahl auftretender Triaden

if rem(nItems,2) % ungerade Anzahl von Items
    d_max = nItems * (nItems^2-1) / 24;
else             % gerade
    d_max = nItems * (nItems^2-4) / 24;
end


d = zeros(nPersons,1);

for iPerson = 1:nPersons
    
    currentPrefMat = squeeze(prefMat(:,:,iPerson)) + diag(nan(nItems,1));  % set diagonal of matrix to nan
    S = nansum(currentPrefMat,2);
    d(iPerson) = nItems* (nItems -1) *(2*nItems-1) / 12 - 0.5 *sum(S.^2);
    
end



K = 1 - d./d_max;
Erwatungswert_d = 0.25 * nchoosek(nItems, 3);

% große stichproben
Fg_konsistenz = nItems * (nItems-1)* (nItems-2) / (nItems -4)^2;
chiQuadrat_konsistenz = 8 / (nItems -4) * (0.25 * nchoosek(nItems,3) - d + 0.5) + Fg_konsistenz;


%% eport 2 excel

nSpalten = 4;

header = {'Analyse:', AnalyseName; 'Datum der Analyse:', datestr(now); 'Anzahl Personen:' , nPersons; 'Anzahl Items:', nItems; [] []; 'Max. zirk. Triaden:' d_max; 'Erwartungswert zirk. Triaden:' Erwatungswert_d};
header{end+2, nSpalten} = [];

spaltenNamen = {[] 'Anzahl zirkulärer Triaden'  'Konsistenzkoeffizient' 'Chi Quadrat'};
exportData =  mat2cell([d K chiQuadrat_konsistenz], ones(nPersons,1), ones(1, nSpalten-1)) ;

chiProzentBeispiel = [0.9 0.99 0.995 0.999 0.9999];
bspCell = cell(numel(chiProzentBeispiel),nSpalten);
for iBsp = 1:numel(chiProzentBeispiel)
    bspCell{iBsp} = sprintf('Chi^2 (%2.2f, %1.4f%%) = %2.2f', Fg_konsistenz, chiProzentBeispiel(iBsp), chi2inv(chiProzentBeispiel(iBsp),Fg_konsistenz ) );
end



konsistenzResult = [header ; spaltenNamen; [TestPersonNames, exportData]; repmat({''}, 3,nSpalten); bspCell];



%% Urteilskonkordanz
% fij           : Häufigkeiten
% J             : Übereinstimmende Urteilspaare
% Erwartung_J   : Erwartungswert für J bei zufälligen Antwortrn
% A             : Akkordanzmaß
% A_min         : minimaler Akkordanzkoeffizient

if isempty(sArgs.excludeAlphaLimit)
    idxPersonsForKonkordanz = logical(ones(nPersons,1));
    excludeInfoStr = '';
else
    chiLimit = chi2inv(1-sArgs.excludeAlphaLimit ,Fg_konsistenz );
    idxPersonsForKonkordanz = chiQuadrat_konsistenz >= chiLimit;
    nPersons = sum(idxPersonsForKonkordanz);
    excludeInfoStr = sprintf('%i (von %i) Personen von Konkordanzanalyse ausgeschlossen (alpha  = %1.3f %%, chiQuadrat = %2.2f)',numel(idxPersonsForKonkordanz) - sum(idxPersonsForKonkordanz) , numel(idxPersonsForKonkordanz), sArgs.excludeAlphaLimit*100,  chiLimit);
    ita_verbose_info(excludeInfoStr,0)
end

fij = sum(prefMat(:,:,idxPersonsForKonkordanz), 3);
J_mat = zeros(size(fij));

for idx = 1:numel(fij)
    if fij(idx) < 2 % entnehme ich 
        J_mat(idx) = 0;
    else
        J_mat(idx) = nchoosek(fij(idx), 2);
    end
end

J = sum(J_mat(:));
Erwartung_J = 0.5 * nchoosek(nItems,2) * nchoosek(nPersons,2);

A = 8*J / (nItems* (nItems-1) * nPersons * (nPersons -1)) - 1;
A_min = -1 / (nPersons -1 + rem(nPersons,2) );

Fg_konkordanz           = nchoosek(nItems, 2) * nPersons * (nPersons -1) ./ (nPersons -2)^2;
if Fg_konkordanz <= 30
    J_strich = J-1;
    kontiKorrekturStr = ['Kontinuitätskorrektur vorgenonmen (J'' = J-1 = ' num2str(J_strich) ')'];
else
    J_strich = J;
    kontiKorrekturStr = 'Kontinuitätskorrektur nicht vorgenonmen ';
end
chiQuadrat_konkordanz   = 4 / (nPersons-2) * ( J_strich - 0.5 * nchoosek(nItems,2) * nchoosek(nPersons,2) * (nPersons-3) / (nPersons-2) );


chiProzentBeispiel = [0.95 0.99 0.995 0.999 0.9999];
bspCell = cell(numel(chiProzentBeispiel),2);
for iBsp = 1:numel(chiProzentBeispiel)
    bspCell{iBsp} = sprintf('Chi^2 (%2.2f, %1.4f%%) = %2.2f', Fg_konkordanz, chiProzentBeispiel(iBsp), chi2inv(chiProzentBeispiel(iBsp),Fg_konkordanz ) );
end


konkordanzResult = [{'Analyse:', 'Urteilskonkordanz'; 'Probe:' AnalyseName; 'Datum der Analyse:', datestr(now); 'Anzahl Personen:' , sum(idxPersonsForKonkordanz); 'Anzahl Items:', nItems; excludeInfoStr, []; [] [];...
                    'Übereinstimmende Urteilspaare J:' J; 'Erwartungswert für J bei zufälligen Antworten:', Erwartung_J; 'Akkordanzmaß A:' A; 'Minimaler Akkordanzkoeffizient:' A_min; [] []; ...
                    'Fg' Fg_konkordanz; 'Chi Quadrat', chiQuadrat_konkordanz; kontiKorrekturStr, []; [] []; }; bspCell];

%% export
warning off MATLAB:xlswrite:AddSheet
xlswrite(['Auswertung_' AnalyseName '.xls'], konsistenzResult, 'Konsitenz')
xlswrite(['Auswertung_' AnalyseName '.xls'], konkordanzResult, 'Konkordanz')
if sArgs.openExcelFile
    winopen(['Auswertung_' AnalyseName '.xls'])
end
