function varargout = ita_spectrogram_mgu(varargin)
%ITA_SPECTROGRAM_MGU - Spectrogram with less memory requirements. Levels are still not right!
%  This function calculates a spectogram of the input signal
%
%  Syntax:
%   audioObjOut = ita_spectrogram_mgu(audioObjIn, options)
%
%   Options (default):
%           'blockSize' (13):   fftDegree, ld(nSamples)
%           'overlap' (0.75):   Overlap between time segments
%           'window' ([]):      apply a hanning or rect window
%
%  Example:
%   audioObjOut = ita_spectrogram_mgu(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_spectrogram_mgu">doc ita_spectrogram_mgu</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: martin.guski@akustik.rwth-aachen.de
% Created:  13-Sep-2010 


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio',  'blockSize', 13, 'overlap', 0.75 , 'window', [], 'plotFreqRange', [50 22050]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 

blockSize   = 2^sArgs.blockSize;
fftSize     = blockSize;
if isempty(sArgs.window)
    win             = hanning(fftSize, 'periodic');   % TODO: als input
%     win             = rectwin(fftSize);   % TODO: als input
else
    win = sArgs.window;
end

nChannels = input.nChannels;

nOverlap = round(sArgs.overlap * fftSize);
if nOverlap < 0
    nOverlap = 0;
    ita_verbose_info( 'Overlap set to 0!',0);
elseif nOverlap > blockSize-1
    nOverlap = blockSize-1;
    ita_verbose_info( 'Overlap set to < 1!',0);    
end

% nZeroPaddingFront =  par.fftSize *1;
% nZeroPaddingBack  =  par.fftSize *2;
% outputSize = [par.fftSize/2+1 ceil((par.signalLength+nZeroPaddingFront + nZeroPaddingBack-nOverlap)/(par.fftSize-nOverlap))]; % [Freq Time]

outputSize = [fftSize/2+1 ceil((input.nSamples -nOverlap)/(fftSize-nOverlap))]; % [Freq Time]

specLinear = cell(1, nChannels);
for iChannel = 1:nChannels
    specLinear{iChannel} =  zeros(outputSize) ;
end


nZeroPadding = (fftSize -nOverlap)*(outputSize(2)-1)+fftSize - (input.nSamples);
input_DATA = [ input.timeData; zeros(nZeroPadding, nChannels ) ];


for iTimeStep = 1:outputSize(2)
    winStartIDX         = (fftSize -nOverlap)*(iTimeStep-1)+1;
    for iCh = 1:nChannels  % TODO alle Ch gleichzeitig
        signalPart          = input_DATA( winStartIDX: winStartIDX-1+fftSize, iCh);
        signalPartF         = fft(signalPart .* win , fftSize);
        specLinear{iCh}(:,iTimeStep)  = signalPartF(1:outputSize(1));
    end
end
% sqrt(fftSize)/ sqrt(win.' * win)
%  okay 
result.data             = bsxfun(@times, [1; ones(fftSize/2-1,1)*sqrt(2) ; 1/sqrt(2)]  /(win.' * win)  ,specLinear{1});
result.freqVector       = psdfreqvec('npts',fftSize,'Fs',input.samplingRate,'Range','half');
result.timeVector       = ((1:outputSize(2))-1)* (fftSize-nOverlap)/input.samplingRate + fftSize / 2 / input.samplingRate;


%% Set Output
if nargout == 0
%     fgh = figure;
    [~, idxMin ] = min(abs(result.freqVector - sArgs.plotFreqRange(1)));
    [~, idxMax ] = min(abs(result.freqVector - sArgs.plotFreqRange(2)));
    plotData = 20*log10(abs(result.data(idxMin:idxMax, : )))-20*log10(2e-5);
    pcolor(result.timeVector, result.freqVector(idxMin:idxMax), plotData);
    set(gca, 'YScale', 'log'); % TODO: besser nicht gca
    shading interp;
        title(input.comment)
        ylim([sArgs.plotFreqRange])
    colorbar
    xlabel('time (in s)')
    ylabel('frequency (in Hz)')
    
elseif nargout == 1
    varargout(1) = {result}; 
end

%end function
end
