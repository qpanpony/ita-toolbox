function varargout = ita_xcorr_dat(varargin)
%ITA_XCORR_DAT - Calculates the cross-correlation in time-domain
%  This function calculates xcorr between two audioObjs
%  The second object (or the one with only 1 channel, if one of the objects is multichannel)
%  is considered the reference.
%
%  Syntax: out = ita_xcorr_dat(audioObj1,audioObj2,options)
%  Options (default):
%   'normalize' ('none'):       normalizes the correlation
%                               'biased'   - scales the raw cross-correlation by 1/M.
%                               'unbiased' - scales the raw correlation by 1/(M-abs(lags)).
%                               'coeff'    - normalizes the sequence so that the auto-correlations
%                                            at zero lag are identically 1.0.
%                               'none'     - no scaling (this is the default).
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar, ita_parse_arguments.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_xcorr_dat">doc ita_xcorr_dat</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Sebastian Fingerhuth -- Email: sfi@akustik.rwth-aachen.de
% Created:  09-Dec-2008


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     % %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_inputA','itaAudio', 'pos2_inputB', 'itaAudio','normalize','none');
if nargin == 1
    varargin{2} = varargin{1}; %autocorrelation
end
[inputA,inputB,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Cross Correlation
orig_nSamples = max(inputA.nSamples,inputB.nSamples);

if max(inputA.nChannels,inputB.nChannels) > 1
    % if there are multiple channels, always make inputB 1 channel
    % (so the one-channel object is considered the "reference")
    if inputA.nChannels == 1 && inputB.nChannels > 1
        ita_verbose_info('Swapping input objects according to nChannels',0);
        tmp = inputA;
        inputA = inputB;
        inputB = tmp;
        clear tmp;
    elseif inputB.nChannels == 1 && inputA.nChannels > 1
        % do nothing
    else
        error([thisFuncStr 'either one input object should have 1 channel only!']);
    end
end

resultData = zeros(2*orig_nSamples-1,inputA.nChannels);
channelNames = inputA.channelNames;
for iCh = 1:inputA.nChannels
    resultData(:,iCh) = xcorr(double(inputA.time(:,iCh)),double(inputB.time),sArgs.normalize);
    channelNames(iCh) = {['xcorr(' inputA.channelNames{iCh} ',' inputB.channelNames{1} ')']};
end

result = inputA;
result.time = resultData(orig_nSamples:end,:);
result.channelNames = channelNames;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Set Output
varargout(1) = {result}; 

%end function
end