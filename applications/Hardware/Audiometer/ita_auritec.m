function ita_auritec(varargin)
%ITA_AURITEC - read data from Auritec via serial port
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   ita_auritec( options)
%
%   Options (default):
%           'port' ('COM5') : serial port name
%
%  Example:
%    ita_auritec
%
%  See also:
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_auritec">doc ita_auritec</a>

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  19-Feb-2013


%% Initialization and Input Parsing

sArgs        = struct('port','COM5');
sArgs = ita_parse_arguments(sArgs,varargin);


%% open serial port
s = serial( sArgs.port, 'baud', 9600);
fopen(s);
% fwrite(s,1);  % reset auritec
%% wait for data

mboxHandle = msgbox('warte auf daten: D(A)tenbank => (S)peichern');
while  ~s.BytesAvailable && ishandle(mboxHandle)
    pause(0.5)
end
if ishandle(mboxHandle)
    close(mboxHandle)
else
    %close serial port
    fclose(s);
    delete(s);
    return
end


mboxHandle = msgbox('empfange daten');
rec = cell(0);
iBlock = 1;
while  s.BytesAvailable
    
    rec{iBlock} = fread(s, s.BytesAvailable);
    
    % ACK
    fwrite(s, 6)
    %     rec{iBlock}'
    pause(0.5)
    
    iBlock = iBlock + 1;
    
end


%close serial port
fclose(s);
delete(s);

if ishandle(mboxHandle)
    close(mboxHandle)
end

%% get user data

userData = cell(size(rec));

for iBlock = 2:numel(rec)
    if isequal(rec{iBlock}, [22 22 5])
        fprintf('start block\n')
    elseif rec{iBlock} == 4
        fprintf('ende der übertragung\n')
    else
        nUserBytes = rec{iBlock}(2) +1;
        
        userData{iBlock} = rec{iBlock}(3:nUserBytes+2)';
        checkSum = rec{iBlock}(nUserBytes+4)*256  + rec{iBlock}(nUserBytes+5);
        if sum(userData{iBlock}) ~= checkSum
            fprintf('checksum falsch!!!!\n')
        end
    end
end

userData = [userData{:}];

%%
char(userData(1))

res.datum = char(userData(2:9));
res.nachname = char(userData(10:24));
res.vorname =  char(userData(25:39));

res.gebDatum =  char(userData(40:47));
res.untersucher =  char(userData(48:57));
res.untersuchungsNr =  char(userData(58:69));
res.diagnose =  userData(70:79);
res.durchgefUntersuchungen = userData(80:82);

res.rechtesOhr = userData(83:83+12-1)-10;
res.rechtesOhrKnochen = userData(95:95+12-1)-10;
res.linkesOhr = userData(203:203+12-1)-10;
res.linkesOhrKnochen = userData(215:215+12-1)-10;
res.unsicherAngabe = userData(323:323+12-1);

%% edit data

res.nachname = umlauteErsetzen(res.nachname);
res.vorname = umlauteErsetzen(res.vorname);
res.untersucher = umlauteErsetzen(res.untersucher);
res.untersuchungsNr = umlauteErsetzen(res.untersuchungsNr);


% remove spaces
res.nachname(res.nachname == 0) = [];
res.vorname(res.vorname == 0) = [];
res.untersucher(res.untersucher == 0) = [];
res.untersuchungsNr(res.untersuchungsNr == 0) = [];


% set invalid data to nan
res.rechtesOhr(res.rechtesOhr == 245) = nan;
res.linkesOhr(res.linkesOhr == 245) = nan;
res.rechtesOhrKnochen(res.rechtesOhrKnochen == 245) = nan;
res.linkesOhrKnochen(res.linkesOhrKnochen == 245) = nan;

% correction
res.rechtesOhr = res.rechtesOhr - [-0.6 -1.2 -1.8 -1.2 -1.2 -0.8 -0.4 -0.2 0.5 4.6 -1 0];
res.linkesOhr = res.linkesOhr - [-3.5 -3.8 -3.7 -4.0 -5.0 -4.5 -4.5 -3.2 -1.3 2.2 -2 0];


freqVec = [125 250 500 750 1000 1500 2000 3000 4000 6000 8000 10000];

%% plot figure

fgh = plotFig(res, freqVec);


%% get filename form user

fileName             = [res.nachname '_' res.vorname '_' res.datum];

fileName = strrep(fileName, '.', '');

pathName             = '\\VERDI\Share\Datenbank-Hoerversuche\ProbandenDaten\Audiometrie\noch zu bearbeiten';



[fileName, pathName] = uiputfile('*.txt', 'Save', fullfile(pathName, fileName ));
fileName = fileName(1:end-4);

if fileName == 0
    return
end

%% save as text file
fid = fopen(fullfile(pathName,[ fileName '.txt' ]), 'w+');
fopen(fid);

fprintf(fid, 'Vorname: \t\t %s\r\n', res.vorname);
fprintf(fid, 'Nachname: \t\t %s\r\n', res.nachname);
fprintf(fid, 'Datum: \t\t\t %s\r\n', res.datum);
fprintf(fid, 'Geburtsdatum: \t\t %s\r\n', res.gebDatum);
fprintf(fid, 'Untersucher: \t\t %s\r\n', res.untersucher);
fprintf(fid, 'Untersuchungsnummer: \t %s\r\n', res.untersuchungsNr);

fprintf(fid, '\r\n\r\n');

fprintf(fid, ' Freq (Hz) \t Links \t \t Rechts \r\n');
fprintf(fid, ' %i \t  \t %6.1f  \t  %6.1f \r\n', [freqVec; res.linkesOhr; res.rechtesOhr]);

fclose(fid);

%% save as struct

save(fullfile(pathName,[ fileName '.mat']), 'res')

%% save figure

answer = questdlg('Bild speichern?', 'Bild speichern', 'Ja', 'Nein', 'Ja');

if strcmp(answer, 'Ja')
    [fileName, pathName] = uiputfile('*.png', 'Save', fullfile(pathName, fileName));
    if ~ishandle(fgh)
        fgh = plotFig(res, freqVec);
    end
    if fileName
        ita_savethisplot(fgh, fullfile(pathName, fileName))
    end
end


%end function
end


function fgh = plotFig(res, freqVec)

fgh = figure;
freqCell = {'125' '250' '500' '750' '1k' '1.5k' '2k' '3k' '4k' '6k' '8k' '10k'};
plot(freqVec, res.linkesOhr, 'x-', 'linewidth', 2.5, 'color', [0 0 1], 'markersize', 10)
hold all
plot(freqVec, res.rechtesOhr, 'o-', 'linewidth', 2.5, 'color', [1 0 0],  'markersize', 7);
plot(freqVec, res.linkesOhrKnochen,  '<--', 'linewidth', 2.5, 'color', [0.5 0.5 1],  'markersize', 7);
plot(freqVec, res.rechtesOhrKnochen, '>--', 'linewidth', 2.5, 'color', [1 0.5 0.5],  'markersize', 7);


plot(freqVec([1 end]), 15*[1  1], '--', 'linewidth', 1.5, 'color', [1 0.84 0]);
plot(freqVec([1 end]), 20*[1  1], '--', 'linewidth', 1.5, 'color', [1 0 0]);
hold off
xlim([125 10000]); ylim([-25 60])
set(gca,'yDir','reverse', 'xscale', 'log', 'xTick', freqVec, 'xTickLabel', freqCell);
legend({'linkes Ohr - Luftleitung', 'rechtes Ohr - Luftleitung' 'linkes Ohr - Knochenleitung', 'rechtes Ohr - Knochenleitung'}, 'location', 'south')
grid on

title(sprintf('%s %s %s', res.vorname, res.nachname, res.datum))
xlabel('Frequenz (in Hz)')
ylabel('Hörpegel nach ISO (in dB)')

end


function fileName = umlauteErsetzen(fileName)
sonderzeichenCell = {'{' 'ae' '|' 'oe' '}' 'ue' '[' 'Ae' '\' 'Oe' ']' 'Ue' '~' 'ss'};
for iSonderzeichen = 1:2:numel(sonderzeichenCell)
    fileName = strrep(fileName, sonderzeichenCell{iSonderzeichen}, sonderzeichenCell{iSonderzeichen+1});
end
end