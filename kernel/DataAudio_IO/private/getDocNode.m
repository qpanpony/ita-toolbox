function docNode = getDocNode(transFunc, inputImp, bsName)

xml = getXMLStrings();

docNode = com.mathworks.xml.XMLUtils.createDocument(xml.DocType);
domImpl = docNode.getImplementation();
doctype = domImpl.createDocumentType(xml.DocType, [], '');
docNode.appendChild(doctype);
docRootNode = docNode.getDocumentElement;

% docRootNode.setAttribute('attr_name','attr_value');

versionNode = docNode.createElement(xml.Version);
versionNode.appendChild...
    (docNode.createTextNode(xml.ActualVersion));
docRootNode.appendChild(versionNode);

optionsNode = getOptionsNode(docNode, bsName);
docRootNode.appendChild(optionsNode);

mainNode = docNode.createElement(xml.SaveTypeQuadripole);
docRootNode.appendChild(mainNode);


quadMSNode = getQuadripoleMSNode(docNode, transFunc, inputImp, bsName);
mainNode.appendChild(quadMSNode);



function quadMSNode = getQuadripoleMSNode(docNode, transFunc, inputImp, bsName)

xml = getXMLStrings();

quadMSNode = docNode.createElement(xml.QuadripoleMeasured);

[freqVecNode, transferFunctionNode, inputImpedanceNode] = lsData2DomNodes(docNode, transFunc, inputImp);


quadMSNode.appendChild(freqVecNode);
quadMSNode.appendChild(transferFunctionNode);
quadMSNode.appendChild(inputImpedanceNode);


function optionsNode = getOptionsNode(docNode, bsName)

xml = getXMLStrings();

optionsNode = docNode.createElement(xml.Options);
nameNode = docNode.createElement(xml.Name);
nameNode.appendChild(docNode.createTextNode(bsName));
optionsNode.appendChild(nameNode);


function [freqVecNode, transferFunctionNode, inputImpedanceNode] = lsData2DomNodes(docNode, transFunc, inputImp)

fVec = transFunc.freqVector;
fVec2 = inputImp.freqVector;

if ~areIdenticalFreqVecs(fVec, fVec2)
    if(length(fVec) < length(fVec2))
        transFunc = ita_interpolate_spk(transFunc,inputImp.fftDegree);
    else 
        inputImp = ita_interpolate_spk(inputImp,transFunc.fftDegree);
    end
end

fVec = transFunc.freqVector;
fVec2 = inputImp.freqVector;
if ~areIdenticalFreqVecs(fVec, fVec2)
    error('Data files have no identical frequency vectors!')
end


transFunc = transFunc.freqData;
inputImp = inputImp.freqData;

freqVecNode = getFreqVecNode(docNode, fVec);
transferFunctionNode = getTransferFunctionNode(docNode, transFunc);
inputImpedanceNode = getInputImpedanceNode(docNode, inputImp);

function str = realArray2str(array)
str = mat2str(array);
str = strrep(str, '[', '');
str = strrep(str, ']', '');
str = strrep(str, ' ', ',');
str = strrep(str, ';', ',');

function [strReal, strImag] = cmplxArray2str(cmplxArray)

strReal = realArray2str(real(cmplxArray));
strImag = realArray2str(imag(cmplxArray));

function bool = areIdenticalFreqVecs(fVec1, fVec2)
bool = isequal(fVec1, fVec2);

function freqVecNode = getFreqVecNode(docNode, freqVec)
xml = getXMLStrings();

freqVecNode = docNode.createElement(xml.FrequencyList);
strFreqVec = realArray2str(freqVec);
freqVecNode.appendChild(docNode.createTextNode(strFreqVec));


function transferFunctionNode = getTransferFunctionNode(docNode, transFunc)
xml = getXMLStrings();
transferFunctionNode = docNode.createElement(xml.TransferFunction);

[realNode, imagNode] = getRealAndImagNode(docNode, transFunc);
transferFunctionNode.appendChild(realNode);
transferFunctionNode.appendChild(imagNode);

function inputImpNode = getInputImpedanceNode(docNode, inputImp)
xml = getXMLStrings();
inputImpNode = docNode.createElement(xml.InputImpedance);

[realNode, imagNode] = getRealAndImagNode(docNode, inputImp);
inputImpNode.appendChild(realNode);
inputImpNode.appendChild(imagNode);

function [realNode, imagNode] = getRealAndImagNode(docNode, cmplxArray)
xml = getXMLStrings();

realNode = docNode.createElement(xml.Real);
imagNode = docNode.createElement(xml.Imag);

[strReal, strImag] = cmplxArray2str(cmplxArray);

realNode.appendChild(docNode.createTextNode(strReal));
imagNode.appendChild(docNode.createTextNode(strImag));