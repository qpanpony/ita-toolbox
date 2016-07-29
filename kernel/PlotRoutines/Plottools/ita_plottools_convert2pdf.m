function ita_plottools_convert2pdf(filedir, filename)
% ITA_PLOTTOOLS_CONVERT2PDF - Converts the eps to a pdf using eps2pdf.exe

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Where ist eps2pdf
epspath = which('eps2pdf.exe');

% global PlotSettings % global variable is loaded very fast
% if isempty(PlotSettings) % getpref slows down a lot if called to many times
%     PlotSettings = getpref('RWTH_ITA_ToolboxPrefs','PlotSettings');
% end
blackbackground = ita_preferences('blackbackground');
menubar = ita_preferences('menubar');
colorTableName = ita_preferences('colorTableName');
linewidth = ita_preferences('linewidth');
aspectratio = ita_preferences('aspectratio');

if isempty(verbose) % getpref slows down a lot if called to many times
    verbose = ita_preferences('verboseMode');
end
if ~isempty(epspath)
    if exist([filename '.pdf'], 'file')
        if verbose, disp(['  Deleting old file... ' filename]), end;
        delete([filename '.pdf'])
    end
    system( ['"' epspath '" /f="' fullfile(filedir, filename) '.eps" &']);
else
    % TODO % use matlab pdf feature
    print('-dpdf',[filename '.pdf']);
end