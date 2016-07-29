function varargout = ita_roomacoustics_reverberation_time_huszty(varargin)
%ITA_ROOMACOUSTICS_REVERBERATION_TIME_HUSZTY - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_reverberation_time_huszty(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_roomacoustics_reverberation_time_huszty(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_reverberation_time_huszty">doc ita_roomacoustics_reverberation_time_huszty</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  04-Jul-2011




%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'p', [0.5 1], 'nIterations', 10000, 'plot', false, 'deltaT',30e-3,'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsperoctave'), 'shift', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

ita_verbose_info('Function still unter construction. Caution!',0);
if sArgs.shift
    input = ita_time_shift(input, '30dB');
end

%% constants
p               = sArgs.p;
nPsteps         = numel(p);
k               = 3*log(10);
L               = input.trackLength;
freqVec         = ita_ANSI_center_frequencies(sArgs.freqRange, sArgs.bandsPerOctave, input.samplingRate);
deltaT          = sArgs.deltaT;
deltaSamples    = round(deltaT * input.samplingRate);
nParts          = ceil(input.nSamples/ deltaSamples);
timeVec         = input.timeVector;
medianRs        = zeros(input.nChannels,nPsteps);

%% reverb calculation
% wb_h = waitbar(0, 'Huszty is running like hell');
% wbh = itaWaitbar([nPsteps, nParts]);
for iPValue = 1:nPsteps
    data    = abs(input.timeData).^p(iPValue);
    Rparts  = zeros(input.nChannels,nParts);
    for iPart = 1: nParts
        upperIdx    = min(iPart * deltaSamples, input.nSamples);
        currL       = min(iPart * deltaT, L);
        hNorm       = data(1:upperIdx,:);
        
        R0 = (k*p(iPValue) * sum(bsxfun(@times, timeVec(1:upperIdx) , hNorm)) ./ sum(hNorm)).'; % start values
        R_tmp = R0;
        for iIteration = 1:sArgs.nIterations
            R_tmp = R0 + currL*k*p(iPValue) ./ (exp(currL*k*p(iPValue) ./ R_tmp) - 1);
        end
        Rparts(:,iPart) = R_tmp;
%         waitbar(((iPart-1) + (iPValue-1)*nParts) / (nParts*nPsteps),wb_h)
%         wbh.inc;
    end
    
    firstDiff       = gradient(Rparts);
    zeroCrossings   = gradient(sign(firstDiff)) ~= 0;
    minima          = zeroCrossings & gradient(firstDiff) > 0;
    
    for iCh = 1:input.nChannels
        medianRs(iCh, iPValue) = median( Rparts(iCh, minima(iCh,:)) );
    end
    % sometimes there is no minimum, just take the first value then
    medianRs(sum(minima,2) == 0,iPValue) = Rparts(sum(minima,2) == 0,1);
end
% close(wb_h)
% wbh.close;

result                  = itaResult(input);
result.allowDBPlot      = false;
result.freqVector       = freqVec(:);
result.freq             = median(medianRs,2);
result.channelUnits(:)  = {'s'};
result.comment          = [input.comment ' -> T (Huszty)'];


medianResult = result;
medianResult.freq = medianRs;

% plot
if sArgs.plot
    figure;
    scatter(repmat(freqVec(:),nPsteps,1), medianRs(:), 'r')
    hold all
    scatter(freqVec, median(medianRs,2), 'b', 'filled')
    ylim([0 5])
    grid on
    set(gca, 'xScale', 'log', 'xtick', freqVec, 'xlim', [min(freqVec) max(freqVec)])
    hold off
    legend({['p-values of ' mat2str(p(:).')], 'median'});
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Set Output
varargout(1) = {result};
if nargout == 2
    varargout(2) = {medianRs};
end
%end function
end