function varargout = ita_read_txtfrequencyresponse (varargin)
% reads preprocessed SoundSolve *.txt files and converts it into itaAudio
% format
%
% Call:  audioStruct=ita_read_txtfrequencyresponse(textFile,'samplingRate',
%           samplingRate, 'fftDegree', fftDegree, 'normalization', 'on'/'off')
%
% textFile can be either filepath and filename or 'getui' to get the Matlab
% open file gui
%
% samplingRate is optional and should be followed by a real even value.
% Default value is twice the highest frequency of the SoundSolve file.
%
% fftDegree is also optional and must be an integer that is greater zero, 
% fftDegree is specifying the number of samples as 2^(fftDegree) 
% (and thus also indirectly the number of frequency bins in the freq domain)
% If fftDegree is not specified, than the frequency step width of the FEM 
% simulation is preserved, but in this case it is essential ...
%
% Normalization is also optional and either 'on' or 'off', default value is 'off'.
% It normalizes the sound pressure of the simulation to the sound pressure that 
% is obtained for a point source with Q=1m³/s at 1m distance from the source. 
% This option should only be turned on if such a source is used in the simulation.
%
% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created:  21-Dec-2009

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



narginchk(1,7);

[textFile,samplingRate,nSamples, normalization]=parseinput(varargin);

[pathstr, name, ext, versn] = fileparts(textFile);

fid = fopen(textFile, 'r');
M = fscanf(fid, '%e %e %e', [3,inf]);
M = M.';
fclose(fid);
frequencies = M(:,1);
data = M(:,2)+1i*M(:,3);

if strcmpi(normalization,'on')
    %air density
    rho0=1.205;
    %source volume velocity in fem simulation
    Q=1;
    %scaling
    data=data./(1i*frequencies*rho0*Q/2);
end

if strcmpi(samplingRate,'default')
    samplingRate=2*frequencies(end);
end

if strcmpi(nSamples,'default')

    binDist = frequencies(2)-frequencies(1);
    for k=1:(length(frequencies)-1)
        newBinDist = frequencies(k+1)-frequencies(k);
        if ~isequal(binDist, newBinDist)
            error('ITA_READ_TXTFREQUENCYRESPONSE: if nSamples is not specified, the bin distance must be constant!')
        end
        binDist = newBinDist;
    end
    freqMin = frequencies(1);
    if mod(freqMin, binDist)~=0
        error('ITA_READ_TXTFREQUENCYRESPONSE: if nSamples is not specified, the bin distance must be chosen such that the freq.-vector can be extended down to 0 Hz!')
    end
    nyqFreq = samplingRate/2;
    nBins = nyqFreq/binDist + 1;
    nSamples = (nBins-1)*2;
end

newFreq = make_frequencyvector(samplingRate, nSamples);

[interpData] = interp_zeroextrap(frequencies, data, newFreq, 'linear');

%itaAudio creation
audioStruct=itaAudio();
audioStruct.freqData=interpData.';
audioStruct.samplingRate=samplingRate;
audioStruct.signalType='energy';
audioStruct.comment='FEM simulation';
audioStruct.channelNames = {name};
audioStruct.fileName=textFile;

% DEBUG:
% plot(frequencies,20*log10(abs(data)), ita_make_frequencyvector(audioStruct), 20*log10(audioStruct.data));

varargout{1}=audioStruct;

function [textFile,samplingRate,nSamples,normalization]=parseinput(varargin)

%default values
samplingRate='default';
nSamples='default';
normalization='off';

varargin=varargin{:};
textFile=varargin{1};

if strcmpi(textFile,'getui')
    [inputFile,pathName] = uigetfile({'*.txt', 'text files (*.txt)';'*.*' , ...
        'all files (*.*)'}, ... 
        'Please select FEM simulation text file to convert into ita audioStruct', ...
        'MultiSelect' , 'off');
    textFile=fullfile(pathName, inputFile);
    if pathName==0
        error('please select file')
    end
end

attributes={'samplingrate' , 'fftdegree', 'normalization'};
normalizationattr={'on','off'};

stringoptions = lower(varargin(cellfun('isclass',varargin,'char')));
attributeindexesinoptionlist = ismember(stringoptions,attributes);
newinputform = any(attributeindexesinoptionlist);
if newinputform
    i=2;
    while i<length(varargin)
        if  (~ismember(lower(varargin{i}),attributes))
            error('ITA_READ_TXTFREQUENCYRESPONSE:AttributeList', ...
                'invalid attribute %s in parameter list', varargin{i})
        end
        if strcmpi(varargin{i},'samplingRate')
            if isnumeric(varargin{i+1}) && ~mod(varargin{i+1},2)
                samplingRate = varargin{i+1};
            else
                error('ITA_READ_TXTFREQUENCYRESPONSE: no valid sampling rate')
            end
        elseif strcmpi(varargin{i},'fftdegree')
            if (isnumeric(varargin{i+1})) && (mod(varargin{i+1},1)==0) && (varargin{i+1}>0)
                nSamples = 2^(varargin{i+1});
            else
                error('ITA_READ_TXTFREQUENCYRESPONSE: no valid number of Samples')
            end            
        elseif strcmpi(varargin{i},'normalization')
            if ismember(lower(varargin{i+1}),normalizationattr)
                normalization = lower(varargin{i+1});
            else
                error ('ITA_READ_TXTFREQUENCYRESPONSE: no valid normalization method. Please choose on or off.')
            end
        end
        i=i+2;
    end
end

% interpolate simulation data and set data to zero outside of simulation range
function [interpData] = interp_zeroextrap(freq, data, newFreq, modus)

if (size(data,1)==1) || (size(data,2)==1)
    % Make sure all vectors are row vectors
    freqHelp(1,:)    = freq;
    dataHelp(1,:)    = data;
    newFreqHelp(1,:) = newFreq;
    freq             = freqHelp;
    data             = dataHelp;
    newFreq          = newFreqHelp;
    
    lenF             = length(freq);
    lenNF            = length(newFreq);
    idxS             = 1;
    idxE             = lenNF;
    interpData       = zeros(1, lenNF);
    
    % Append zeros where data is not available
    while newFreq(idxS) < min(freq)
        idxS = idxS+1;
    end
    while newFreq(idxE) > max(freq)
        idxE = idxE-1;
    end
    interpData(idxS:idxE) = interp1(freq, data, newFreq(idxS:idxE), modus);
else
    error('FUNCTION:INTERP_ZEROEXTRAP: Invalid first input argument.');
end

function freq_vector = make_frequencyvector(samplingRate, nSamples)

bin_dist = samplingRate / nSamples; % get distance between bins

if rem(nSamples,2) == 1 % nSamples is odd
    nFreqs = (nSamples-1)/2 + 1;
else % nSamples is even
    nFreqs = (nSamples-2)/2 + 2;    
end

freq_vector  = (0:nFreqs-1) .* bin_dist; % % frequency vector including zero frequency in Hz



