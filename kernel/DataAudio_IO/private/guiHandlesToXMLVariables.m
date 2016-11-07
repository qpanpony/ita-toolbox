function [transFunc, inputImp, bsName, outFile] = guiHandlesToXMLVariables(guiHandles)

bsName = guiHandles.bsName;
outFile = guiHandles.outFile;

tfFile = guiHandles.tfFile;
impFile = guiHandles.impFile;

try
    transFunc = ita_read(tfFile);
    inputImp = ita_read(impFile);
catch ME  
    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction') &&...
            strcmp(ME.message, 'Undefined function or variable "result".')
        
        newME = MException('ITA_READ:UnkownFiletype', 'The given file is no ITA file');
        throw(newME)
    end
    rethrow(ME)
end
