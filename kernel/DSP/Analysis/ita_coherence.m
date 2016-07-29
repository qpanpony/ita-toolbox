function varargout = ita_coherence(varargin)
%ita_coherence - Calculates spatial coherence for two signals
%  This function calculates the coherence between two signals
%  If no audio signal is given, the theoretic coherence is calculated
%
%  Syntax: analysis_results = ita_coherence(dat, Options)
%           Options:
%               'blocksize' (1024):      The Blocksize in which the time signal will be segmented
%               'combinations' ([]):     Analysis only of the channel-combinations given (e.g. [[1 3]; [1 4]])
%               'export_fftsize' ([]):   % TODO HUHU
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar, ita_parse_arguments.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_coherence">doc ita_coherence</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created: 26-Nov-2008

%% Initialization
% Number of Input Arguments
%narginchk(1,9);
% Find Audio Data
TwoInMode = false;
sArgs = struct('pos1_data1','itaAudioTime','blocksize',1024,'combinations',[],'use_power_of_2',false,'fftsize',[],'nsegments',[],'complex',false);

if nargin > 1 && isa(varargin{2},'itaAudio')
    TwoInMode = true;
    sArgs.pos2_data2 = 'itaAudioTime';
end


if TwoInMode
    [data1,data2,sArgs] = ita_parse_arguments(sArgs, varargin);
    
    for i1 = 1:data1.nChannels
        for i2 = 1:data2.nChannels
            sArgs.combinations(end+1,:) = [i1 data1.nChannels+i2];
        end
    end
    data1 = merge(data1, data2);
else
    [data1,sArgs] = ita_parse_arguments(sArgs, varargin);
end

sArgs.blocksize = round(sArgs.blocksize);
sArgs.blocksize = sArgs.blocksize + mod(sArgs.blocksize,2); % Make even

if sArgs.use_power_of_2
    sArgs.blocksize = nextpow2(sArgs.blocksize);
end


%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
if 3 * sArgs.blocksize > data1.nSamples % We should have at least 5 segments, with overlap thats 3*blocksize > signal_length
    ita_verbose_info('ITA_COHRENCE: Careful, blocksize is too big for your signal, coherence wont tell you anything this way!',1)
end

if data1.nChannels < 2
    error('ITA_COHERENCE: At least 2 channels needed');
end

if ischar(sArgs.combinations) || iscellstr(sArgs.combinations)
    sArgs.combinations = ita_channelnames_to_numbers(sArgs.combinations,'substring');
end

result = ita_fft(data1);
%for idx = 1:data1.nChannels
%    result.channelNames{idx} = [];
%    result.channelUnits{idx} = [];
%end
result.data = [];

if isempty(sArgs.combinations)
    for i1 = 1:data1.nChannels
        for i2 = (i1+1):data1.nChannels
            sArgs.combinations(end+1,:) = [i1 i2];
        end
    end
end

for i_ges = 1:size(sArgs.combinations,1)
    i1 = sArgs.combinations(i_ges,1);
    i2 = sArgs.combinations(i_ges,2);
    if any([i1 i2] > data1.nChannels)
        error(['ITA_ANALYSE_COHERENCE: Not enough channels for that channel combination: ' int2str(i1) ' ' int2str(i2)]);
    end
    
    % C_xy = |<S_xy>|^2 / (S_xx * S_yy)
    ch1 = ita_split(data1,i1);
    ch2 = ita_split(data1,i2);
    
    S_xy = ita_psd(ch1,ch2, 'blocksize',sArgs.blocksize,'fftsize',sArgs.fftsize);
    S_xx = ita_psd(ch1,     'blocksize',sArgs.blocksize,'fftsize',sArgs.fftsize);
    S_yy = ita_psd(ch2,     'blocksize',sArgs.blocksize,'fftsize',sArgs.fftsize);
    
    if sArgs.complex
        Cxy = (S_xy.freq) ./ sqrt(S_xx.freq .* S_yy.freq);
    else
        Cxy = abs(S_xy.freq).^2 ./ (S_xx.freq .* S_yy.freq);
    end
    
    channelNames{i_ges} = ['Coherence between ' data1.channelNames{i1} ' and ' data1.channelNames{i2}];
    channelUnits{i_ges} = '';
    
    resultspk(i_ges,:) = Cxy;
end

% Some limits, usually not necessary, but needed e.g. for empty signals
resultspk(isnan(resultspk)) = 0;
resultspk(isinf(resultspk)) = 1;


result.freqData = resultspk.';
result.channelNames = channelNames;
result.channelUnits = channelUnits;
result.signalType = 'energy';

%result.PlotOptions
%result.PlotOptions.xlim = [50 10000];
%result.PlotOptions.ylim = [0 1];
%result.PlotOptions.xscale = 'lin';
%result.PlotOptions.yscale = 'lin';


%%result = ita_metainfo_check(result);

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_coherence',varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end
