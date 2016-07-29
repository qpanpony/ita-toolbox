function ita_merge_pdfs(varargin)
%ITA_MERGE_PDFS - merges PDFs with ghostscript
%  This function merges PDF files. Ghostscript is required.
%
%  Syntax:
%   ita_merge_pdfs(inputPDFs, outputPDF)
%
%   Options (default):
%           'showOutput' (false)      : open output pdf 
%           'deleteInputPDFs' (false) : delete input pdfs after output was created
%
%  Example 1:
%        ita_merge_pdfs('*', 'out')  % merge all pdf files in current folder
% 
%  Example 2:
%         for iPlot = 1:3
%             fgh = ita_plot_time(ita_generate('noise',iPlot,44100,15));
%             ylim([-1 1]*10);
%             inputPdfCell{iPlot} = sprintf('tmpPdf_%i.pdf', iPlot);
%             ita_savethisplot(fgh, inputPdfCell{iPlot})
%             close(fgh)
%         end
%         ita_merge_pdfs(inputPdfCell, 'mergedPDFs', 'deleteInputPDFs', 'showOutput')
%
% 
%  See also:
%   ita_savethisplot, ghostscript
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_merge_pdfs">doc ita_merge_pdfs</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  20-Jul-2012


% if ~ita_preferences('isGhostscriptInstalled')
%     error('ghostscript not installed (or not activated in ita_preferences)')
% end
if ~nargin 
    guiCall
    return
end

%% Initialization and Input Parsing
sArgs        = struct('pos1_inputinputPdfs','anything', 'pos2_outputPdf', 'char', 'showOutput', false, 'deleteInputPDFs', false);
[inputPdfs, outputPdf, sArgs] = ita_parse_arguments(sArgs,varargin);

% parsing input files
if ischar(inputPdfs)
    if numel(inputPdfs) < 4 || ~strcmpi(inputPdfs(end-3:end), '.pdf')
        ita_verbose_info('adding file extension .pdf',2)
        inputPdfs = [inputPdfs '.pdf'];
    end
    allFiles = dir(inputPdfs);
    if isempty(allFiles)
        error(['no files found: ' inputPdfs])
    end
    inputPath = fileparts(inputPdfs);
    
    % if no path => take current path
    if isempty(inputPath)
        inputPath = pwd;
    end
    inputPdfs = ita_sprintf('%s%s%s', inputPath, filesep, {allFiles.name}');
    
elseif ~iscell(inputPdfs)
    error('ita_merge_pdfs: first input has to be cell(with filenames) or char (input angument for dir command)')
end


% parsing output file
[outputPath, outputFileName] = fileparts(outputPdf);

if isempty(outputPath)
    if exist('inputPath', 'var')
        outputPath = inputPath;
    else
        outputPath = fileparts(inputPdfs{1});
        if isempty(outputPath)
            outputPath = pwd;
        end
    end
end



%%

% built command

inputPdfs(find(cellfun(@isempty, inputPdfs))) = [];   % revome all empty strings in inputPDFcell (ghostscript doesn't like it)

% ghostscript fails to merge more than 66 pdfs => step by step
nPdfsAtOnce = 50;
nInputPdfs = numel(inputPdfs);
tempFileName =  fullfile(outputPath, [outputFileName '_tmp.pdf']) ;

for iPart = 1:ceil(nInputPdfs / nPdfsAtOnce)
    
    allInputPdfsString = ita_sprintf('"%s" ', inputPdfs((iPart-1)*nPdfsAtOnce+1:min(iPart*nPdfsAtOnce,nInputPdfs)));
    if iPart > 1 % add previously merged pdfs
        
       movefile( fullfile(outputPath, [outputFileName '.pdf']), tempFileName, 'f')
        
        allInputPdfsString  = [ {['"' tempFileName '" ']}; allInputPdfsString ];
    end
    
    allInputPdfsString = allInputPdfsString';
    allInputPdfsString = [allInputPdfsString{:}];
    
    gsCommand =[ ' -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="' fullfile(outputPath, outputFileName)  '.pdf" -dBATCH ' allInputPdfsString];
    
    
    % run ghostscript
    [status resultMSG] = ghostscript(gsCommand);
    
    if status
        error(resultMSG)
    end
    
end

if exist(tempFileName, 'file')
    delete(tempFileName)
end

% delete input files
if sArgs.deleteInputPDFs
    for iInput = 1:numel(inputPdfs)
        delete(inputPdfs{iInput});
    end
end

% show output
if sArgs.showOutput
    open(fullfile(outputPath, [outputFileName '.pdf'] ))
else
    ita_verbose_info(sprintf('%s created', fullfile(outputPath, outputFileName)))
end


%end function
end

function guiCall

[fileNames, pathName] = uigetfile('*.pdf','MultiSelect', 'on');
[outputFile, outputPath] = uiputfile('*.pdf', 'Save merged PDF', pathName);
ita_merge_pdfs(ita_sprintf('%s%s%s', pathName, filesep, fileNames), fullfile(outputPath, outputFile), 'showOutput')
end