function ita_export_newBassyst_fast(varargin)

sArgs.freqData = itaAudio;
sArgs.impData = itaAudio;
sArgs.fileName = 'export.xml';
sArgs.name = 'export';
sArgs = ita_parse_arguments(sArgs,varargin);

sArgs.fileName = getOutFileWithExtension(sArgs.name,sArgs.fileName);

exportBSFile(sArgs.freqData,sArgs.impData,sArgs.name,sArgs.fileName)

end


function exportBSFile(transFunc, inputImp, bsName, outFile)

    docNode = getDocNode(transFunc, inputImp, bsName);
    xmlwrite(outFile,docNode);

end

function outFile = getOutFileWithExtension(outFile, bsName)

    if( isempty(outFile) )
        outFile = [bsName getBSFileExtension()];
        return;
    end

    idxFileExt = strfind(outFile, getBSFileExtension());
    if (~isempty(idxFileExt))
        %File Extension is at the end of the filename?
        boolAddExt = ~( ( idxFileExt + length(getBSFileExtension()) - 1 ) == length(outFile) );
    else
        boolAddExt = 1;
    end

    if(boolAddExt)
        outFile = [outFile getBSFileExtension()];
    end
end