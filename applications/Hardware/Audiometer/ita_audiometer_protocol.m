function varargout = ita_audiometer_protocol(inputFile)
%ITA_KUNDT_PROTOCOL - calculates loudness level of a signal according to DIN

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%%

delTexFile                  =  true;


%% select file

% if nargin == 0

[fileName, pathName, ~]  = uigetfile('*.mat', 'Select Audiometer Result');


% generate picture name
if strcmpi(fileName(end-3:end), '.mat')
    baseFileName = fileName(1:end-4);
else
    baseFileName =  fileName;
end

pictureName = [ baseFileName '.png'];


if ~exist(fullfile(pathName, pictureName), 'file')
    errordlg(['Picture file is missing (' fullfile(pathName, pictureName) ')'])
end

% load result data
load(fullfile(pathName, fileName))

%%

protocolHeaderPNG = 'KopfzeileGKB.png';

% enter your MIKTEX path here |  |  |  |  |  |
%                            \ /\ /\ /\ /\ /\ /
%                             .  .  .  .  .  .
% texpath = '"C:\Program Files\MiKTeX 2.8\miktex\bin\pdf.latex.exe"';
% texpath = '"D:\Program Files\MiKTeX 2.9\miktex\bin\pdflatex.exe"';
%texpath = '"D:\Programme\MiKTeX 2.9\miktex\bin\pdflatex.exe"';
texpath = '"C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe"';
%                             .  .  .  .  .  .
%                            / \/ \/ \/ \/ \/ \
%                             |  |  |  |  |  |

cd(pathName)
pause(0.1)


% fill in the template
keyValueCell   = { '<\itaBriefkopfBild>' protocolHeaderPNG;
    '<\datumDerMessung>' saveStruct.personalInfo.date;
    '<\proband>'  saveStruct.personalInfo.name
    '<\dateinameGrafik>'  pictureName
    '<\kommentar>'  saveStruct.personalInfo.comment
    '<\geburtsDatum>'  saveStruct.personalInfo.birthday};


texFileName = [baseFileName '.tex'];
ita_fillInTemplate(fullfile(ita_toolbox_path, 'applications', 'Audiometer', 'AudiometerTemplate.tex' ), keyValueCell, texFileName);
fclose('all');



% kopieren schein einfacher als latex pfade mit leerzeichen erklären...
[stat res] = system(['copy "' fullfile(ita_toolbox_path, 'applications', 'Kundt','Protocol',  protocolHeaderPNG ) '" ']);


% create pdf
if ita_preferences('verboseMode') == 2
    system([texpath ' ' texFileName]) % mit ausgabe
else
    [status result] = system([texpath ' ' texFileName]); % ohne ausgabe zur console
    if status
        error(result)
    end
end


%  try
%      open([probeFileName '.pdf']);


% löscht überflüssige Dateien
delete(protocolHeaderPNG);
delete([baseFileName '.log'] );
delete([baseFileName '.aux'] );
if exist([baseFileName '.bbl'], 'file')~=0
    delete([baseFileName '.bbl']);
end
if exist([baseFileName '.blg'],'file')~=0
    delete([baseFileName '.blg'] );
end

% TODO: Order in itaToolbox wo Template und header dring liegt
%  catch %#ok<CTCH>
%      warning('Please, insert your path of miktex in linie 33. In addition there could be difficulties with your tex file. Please try to compile it separately.') %#ok<WNTAG>
%  end

if delTexFile
    delete(texFileName);
end
% if delPictureFile
%     delete([baseName '.png']);
% end
