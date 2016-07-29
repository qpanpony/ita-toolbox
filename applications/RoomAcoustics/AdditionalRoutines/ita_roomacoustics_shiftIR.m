function varargout = ita_roomacoustics_shiftIR(varargin)
%ITA_ROOMACOUSTICS_SHIFTIR - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_shiftIR(audioObjIn, options)
%
%   Options (default):
%           'threshold' (defaultopt1) : description
%           'channelHandling' (defaultopt1) : 'independent'
%                                  'reference'
%                                  'identical'   all channels at least below the threshold
%           'prmsThreshold' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_roomacoustics_shiftIR(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_shiftIR">doc ita_roomacoustics_shiftIR</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  12-Oct-2011


%% Initialization and Input Parsing

sArgs        = struct('pos1_data','itaAudioTime', 'threshold', 20, 'channelHandling', 'independent', 'referenceChannel', 1, 'plot', false, 'checkIfIsIR', true, 'prmsThreshold', 30, 'maxThreshold', 6);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

if ~any(strcmpi({'independent', 'reference',  'identical'}, sArgs.channelHandling))
    error('unknown channel handling method (known: ''independent'', ''reference'' or  ''identical'')')
end

%%

timeDataSquare = input.timeData.^2;



if strcmpi(sArgs.channelHandling, 'reference')
    
    if ~isscalar(sArgs.referenceChannel) ||  sArgs.referenceChannel > input.nChannels || sArgs.referenceChannel < 1
        error('invalid  reference channel (%i)', sArgs.referenceChannel)
    end
    channelVec = sArgs.referenceChannel;
    
else
    channelVec = 1: input.nChannels;
end



% plot parameters
if sArgs.plot
    figure
    nChannels = numel(channelVec);
    subplotSize = [ceil(sqrt(nChannels)) round(sqrt(nChannels)) ];
    plot_Limits = [-0.002 0.0005];
    fs = input.samplingRate;
end


%%
startIdx = zeros(numel(channelVec), 1);


envelope        = ita_envelope(input);
envelopeData_dB = 20*log10(abs(envelope.timeData));

[maxValues idxMaxima ] = max(timeDataSquare);           % not all channles needed?
maxValues = 10*log10(maxValues);


for iChannel = channelVec
    if sArgs.checkIfIsIR
        
        % PeakToRMS    =  max(abs(timeData)) ./ sqrt(mean(timeData.^2));
        PeakToRMedS =  maxValues(iChannel) - 10*log10( median(timeDataSquare(:,iChannel)));
        
        if PeakToRMedS < sArgs.prmsThreshold
            ita_verbose_info(sprintf('Channel %i: The SNR too bad or this is not an impulse response => No shift!', iChannel),1)
            startIdx(iChannel) = 1;
            continue
        end
    end
    
    % check if line of sight is not maximum
    upperSearchLimit = find( timeDataSquare(1:idxMaxima(iChannel),iChannel) < 10^((maxValues(iChannel) - sArgs.maxThreshold)/10), 1, 'last');
    idxFirstMax = find( timeDataSquare(1:upperSearchLimit,iChannel) > 10^((maxValues(iChannel) - sArgs.maxThreshold)/10), 1, 'first');
    if ~isempty(idxFirstMax)
        idxMaxima(iChannel) = idxFirstMax;
        maxValues(iChannel) = 10*log10(timeDataSquare(idxFirstMax, iChannel));
        ita_verbose_info('LOS not max')
    end
    
    foundIdx = find( (envelopeData_dB(1:idxMaxima(iChannel),iChannel) - maxValues(iChannel)) < -abs(sArgs.threshold), 1, 'last' );
    
    if isempty(foundIdx)
        foundIdx = 1;
        ita_verbose_info(sprintf('Ch%i: no value below threshold. Using entire IR...',iChannel), 1);
    end
    startIdx(iChannel) = foundIdx;
    
    ita_verbose_info(sprintf('\t Ch %i samples: %i', iChannel, startIdx(iChannel)),2)
    
    
    if sArgs.plot
        if ~strcmpi(sArgs.channelHandling, 'reference')
            subplot(subplotSize(1), subplotSize(2), iChannel)
        end
        
        [del time] = ita_time_shift(input.ch(iChannel), sprintf('%idB',abs(sArgs.threshold)));
        idxSamplesTimeShift =-round(time * fs)+1;
        
        plot(input.timeVector, [10*log10(abs(timeDataSquare(:,iChannel))) envelopeData_dB(:,iChannel) ] - maxValues(iChannel))                  % signal & envelope
        hold all
        scatterSize = 11^2;
        scatter(-time, 10*log10(abs(timeDataSquare(idxSamplesTimeShift,iChannel))) - maxValues(iChannel),scatterSize , 'filled')                             % ita_time_shift result
        scatter((startIdx(iChannel)-1)/fs, envelopeData_dB(startIdx(iChannel),iChannel) - maxValues(iChannel),scatterSize , 'filled') % result
        
        %         scatter(-time + 1/fs, 20*log10(abs(timeData(idxSamplesTimeShift+1,iChannel))) - 20*log10(maximum))
        xlim([min([plot_Limits(1)+(idxMaxima(iChannel)-1)/fs -time (startIdx(iChannel)-1)/fs]) plot_Limits(2)+(idxMaxima(iChannel)-1)/fs] .* [0.9995 1.0]); ylim([-60 0])
        if iChannel == nChannels
            legend({'original' 'envelope' 'ita_time_shift' 'ita_rommacoustics_shiftIR'}, 'location', 'northwest', 'interpreter', 'none')
        end
        title(input.channelNames{iChannel})
        hold off; grid on
    end
    
end


%% shifting

switch lower(sArgs.channelHandling)
    case {'reference', 'identical'}
        startIdx = max(startIdx);
        input.timeData = input.timeData(startIdx:end,:);
        ita_verbose_info(sprintf('shifting all channels: %i samples', startIdx-1),1);
    case 'independent'
        timeData = input.timeData;
        for iCh = 1:input.nChannels
            timeData(:,iCh) = [timeData(startIdx(iCh):end,iCh); zeros(startIdx(iCh)-1,1)];
        end
        input.timeData = timeData;
        %         ita_verbose_info(sprintf('all channels: %i samples', startIdx));
    otherwise
        error('unknown channel handling')
end



%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input};
if nargout == 2
    varargout{2} = startIdx;
end

%end function
end