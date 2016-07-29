function varargout = ita_cutImpulseTrain(varargin)
%ITA_CUTIMPULSETRAIN - automatic cut of impulses from one audio
%  This function cuts out the impulses(specific length, threshold) of an audio signal
%  and gives back an itaAudio with those impulses, each in a different
%  channel.
%
%  Syntax:
%   audioObjOut = ita_cutImpulseTrain(audioObjIn, options)
%
%   Options (default):
%           'threshold' (0.7):                  normalized threshold:   1: maximum level in dB, 0: rms level
%           'length' (1):                       length of the impulse in seconds
%           'startBeforeThreshold' (0.004):     start of cut before the threshold detection in seconds
%
%  Example:
%   audioObjOut = ita_cutImpulseTrain(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_cutImpulseTrain">doc ita_cutImpulseTrain</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  24-Feb-2011


% TODO: take maximum value as reference and not first value above threshold


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'threshold', 0.7, 'length', 1, 'startBeforeThreshold' , 0.004, 'plotCuts', false, 'syncChannels', true, 'refChannel', 1);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%%

percentageOfDynRange    =   sArgs.threshold;
minTimeBetweenPeaks     =   sArgs.length;
startBeforeMax          =   sArgs.startBeforeThreshold;


nSamlesLength           = round(input.samplingRate * minTimeBetweenPeaks);
nSamplesBefore          = round(input.samplingRate * startBeforeMax);

nChannels = input.nChannels;

peaksGetrennt = itaAudio(nChannels,1);
input = ita_ifft(input);

if sArgs.syncChannels 
    channels2analyse = sArgs.refChannel;
else
    channels2analyse = 1:nChannels;
end



for iCh = channels2analyse
    
    timeData = input.timeData(:,iCh);
    
    % calc threshold
    maxLevel    = 20*log10(max(abs(timeData)));
    rmsLevel    = 10*log10(timeData.' * timeData / size(timeData,1));
    
    threshold = maxLevel* percentageOfDynRange + rmsLevel*(1-percentageOfDynRange);
    
    % find indices above threhold
    idxStart = find(20*log10(abs(timeData)) > threshold);
    
    % delete indices that belongs to the same impulse
    idxStart( idxStart > input.nSamples - nSamlesLength + nSamplesBefore) = [];
    idx2del             = [false;  diff(idxStart) < nSamlesLength ];
    idxStart(idx2del)   = [];

    idxStart(idxStart-nSamplesBefore < 0 ) = [];

    nImpulsesFound = numel(idxStart);
    
    idx2take = repmat(idxStart-nSamplesBefore,1, nSamlesLength) + repmat(0:nSamlesLength-1,size(idxStart,1),1);
    
    
    justPeaks = input*0;
    justPeaks.timeData(idx2take(:)) = timeData(idx2take(:));
    
    
    if sArgs.plotCuts % one time signal with detected peaks
        ita_plot_dat_dB(merge(input, justPeaks))
    end

    peaksGetrennt(iCh)           = ita_metainfo_add_historyline(input.ch(iCh),mfilename,varargin);
    peaksGetrennt(iCh).timeData  = timeData(idx2take.');
    
    
    % channel names & units 
    tmpStr = [repmat([input.ch(iCh).channelNames{1} ' - Impulse No. '], nImpulsesFound,1) num2str((1:nImpulsesFound)') ];
    peaksGetrennt(iCh).channelNames     = mat2cell(tmpStr, ones(nImpulsesFound,1), size(tmpStr,2))';
    peaksGetrennt(iCh).channelUnits(:)  = input.ch(iCh).channelUnits;
    
end

if sArgs.syncChannels
    for iCh = 1:nChannels 
        if iCh ~= sArgs.refChannel
            tmpDat = input.timeData(:,iCh);
            peaksGetrennt(iCh).timeData  =  tmpDat(idx2take.');
            tmpStr = [repmat([input.ch(iCh).channelNames{1} ' - Impulse No. '], nImpulsesFound,1) num2str((1:nImpulsesFound)') ];
            peaksGetrennt(iCh).channelNames     = mat2cell(tmpStr, ones(nImpulsesFound,1), size(tmpStr,2))';
        end 
    end
end


% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);


%% Add history line
% input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output

varargout(1) = {peaksGetrennt};

if nargout == 2
    varargout(2) = {   justPeaks };
end

if nargout == 3
    varargout(2) = {   justPeaks };
    varargout(3) ={[ idxStart-nSamplesBefore idxStart-nSamplesBefore+nSamlesLength]};
end

%end function
end