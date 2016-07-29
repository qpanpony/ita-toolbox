function varargout = ita_kundt_exportResults2excel(varargin)
%ITA_KUNDT_EXPORTRESULTS2EXCEL - Export of 1/3 Octave Values to Excel
%  This function exports all result files of a directory as 1/3 octave mean values  
%  to an Excel-File.
% 
%  Syntax:
%   ita_kundt_exportResults2excel()
%
%  Example:
%     ita_kundt_exportResults2excel()
%
%  See also:
%   ita_kundt_gui, ita_plot_alpha
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kundt_exportResults2excel">doc ita_kundt_exportResults2excel</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: martin.guski@akustik.rwth-aachen.de
% Created:  30-Aug-2010 



% TODO:
% * iput: FreqBereich, doPlots, inputPath, outputFile, 
% * kleiner header in excel datei: datum, uhrzeit, verzeichnis ...
%% Get Function String
% thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 


%% *_result.ita´s suchen

pfad = uigetdir;
allFiles = dir(pfad);
FileNames = cell(1);

for iFile = 1:length(allFiles)
    if ~allFiles(iFile).isdir &&  (length(allFiles(iFile).name) >11)
        if strcmp(allFiles(iFile).name(end-10:end), '_result.ita')
            FileNames = [FileNames {allFiles(iFile).name}];
        end
    end
end
FileNames = {FileNames{2:end} };
clear iFile allFiles


nFiles = length(FileNames);
fprintf('%i result-files found.\n\n',nFiles)



%% calc alpha und mittelwerte

terzmitten =  ita_ANSI_center_frequencies([100 8000], 3);
nTerzen = length(terzmitten);
fuT = terzmitten/2^(1/6);
foT = terzmitten*2^(1/6);
fgrenzen = [fuT(1) sqrt(fuT(2:end).*foT(1:end-1)) foT(end)];

outData = zeros(nFiles, nTerzen);


doCrtlPlots = false;



res = ita_read(FileNames{1});
fGrenzIDX = res.freq2index(fgrenzen);


for iFile = 1:nFiles
    res = ita_read(FileNames{iFile});
    alpha = ita_convert_RT_alpha_R_Z(res,'inQty','Z','outQty','alpha');
    fGrenzIDX = res.freq2index(fgrenzen);
    if doCrtlPlots
        controlPlot = zeros(size(alpha.freqData));
    end
    for iTerz = 1:nTerzen
        outData(iFile,iTerz) = mean(alpha.freqData(fGrenzIDX(iTerz):fGrenzIDX(iTerz+1)));
        if doCrtlPlots
            controlPlot(fGrenzIDX(iTerz):fGrenzIDX(iTerz+1)) = outData(iFile,iTerz);
        end
    end
    if doCrtlPlots
        semilogx(alpha.freqVector, [alpha.freqData controlPlot])
        xlim([100 10000])
        ylim([-.1 1.1])
        pause()
    end
end

%% write excel file

% cl = clock;
% datum = sprintf(' Datum:  %02i.%02i.%04i %02i:%02i Uhr', cl(3), cl(2), cl(1), cl(4), cl(5));


printNames = cell(nFiles,1);
for iFile = 1: nFiles
    printNames{iFile} = FileNames{iFile}(1:end-11);
end


cellToWrite = [ [{'Terzmitten'}; printNames ],[ num2cell(terzmitten); num2cell(outData)]];

fileName = uiputfile('*.xls', 'Save Results', 'TerzAbsorption' );

xlswrite(fileName, cellToWrite);









% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);









%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);
% 
%% Set Output
varargout(1) = {input}; 

%end function
end