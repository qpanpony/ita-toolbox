function varargout = ita_filter_pdi(varargin)
%ITA_FILTER_PDI - Filtering audio data.
%  This function is like the JFilter in MF, only that it is optimized for
%  popular brazilian music (musica popular brasileira - mpb). It uses the
%  Signal Processing Toolbox to generate filtersettings and applies the
%  filters in time or frequency domain, depending on input signal and on
%  the settings.
%
%  By now it supports standard octave and third octave band filtering and a
%  low-high-pass filter combination specified by the 3dB edge frequencies.
%
%  If instead of an audio structure, the sampling rate is given in as the
%  first input, the function returns a structure with the filter object and
%  its impulse response.
%
%  Syntax: audioObj  = ita_filter_pdi(audioObj,type,options)
%  Syntax: filterStruct = ita_filter_pdi(SamplingRate,type,options)
%
%  The supported types of filter are listed below:
%
%  Band Filters:
%  'a-weight'      - A weight Filtering
%  'c-weight'      - C weight Filtering
%  'oct',b         - 1/b Octave Filtering
%  'octaves',b     - 1/b Octave Filtering
%  '3-oct'         - Third Octave Filtering
%  'third-octaves' - Third Octave Filtering
%  'octaves*'      - High band Octave Filtering - Model Room Measurements
%
%  Low-High Filters:
%  [lowerFreq, higherFreq]) - passband filter between these frequencies
%  [0, higherFreq])         - low pass filter
%  [lowerFreq, 0])          - high pass filter
%
%  Options (default):
%
%  filterorder (10):
%  You can specify the filter order manually by appending 'order',value to
%  the arguement list
%
%  filter_class ('Class 0'):
%  You can specify the filter class manually by appending 'class',value to
%  the arguement list, been the classes 0,1 and 2 available.
%  Call: audioObj = ita_filter_pdi(audioObj,[lowerFreq, higherFreq],'zerophase','class',1)
%
%  zerophase (false):
%  specify zerophase to build a filter without any phase at all. Oh Lord. We hope
%  you know enough about signal theory!
%
%  Minimum and zero phase filters:
%  ita_filter_pdi(... 'zerophase')
%  ita_filter_pdi(... 'minimumphase')
%
%  See also ita_make_filter.
%
%  Reference page in Help browser <a href="matlab:doc ita_filter_pdi">doc ita_filter_pdi</a>
%
%  Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%  Created:  23-Jun-2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Initialization
if nargin == 0
    varargout{1} = ita_filter_pdi_GUI();
    return;
end
narginchk(2,20);

%find data
if isnumeric(varargin{1})
    OutputJustFilter = true;
    specs.samplingRate = varargin{1};
    %     specs.frequencyfiltering = true;
elseif isa(varargin{1},'itaAudio')
    OutputJustFilter = false;
    InputData = varargin{1};
    if InputData.isTime
        specs.original_domain = 'time';
        %         specs.frequencyfiltering = false;
    elseif InputData.isFreq
        specs.original_domain = 'freq';
        %         specs.frequencyfiltering = true;
    end
    specs.samplingRate = InputData.samplingRate;
else
    error('ita_filter_pdi:Oh Lord. Only structs allowed.')
end

specs.frequencyfiltering = true; %pdi,klein:major bug fix 18-jun-2009

%% Parse Options
[specs,FilterName] = mpb_parser(specs,varargin);

%% Get Filter and do filtering if and as specified
Filter = mpb_get_filter(specs,FilterName);

if OutputJustFilter
    %     Result = Filter;
    %     specs.frequencyfiltering = false;
    varargout(1) = {Filter};
    return
else %normal mode, do some filtering
    if specs.frequencyfiltering
        % Do filtering
        Result = mpb_freq_filter(specs,Filter,InputData');
    else
        if specs.switchfrequencies %renzo-mode
            specs.oldSamplingRate = InputData.samplingRate;
            InputData.samplingRate = specs.samplingRate / round(specs.samplingRate./48000);
            
            Result = mpb_time_filter(Filter,InputData);
            Result.samplingRate = specs.oldSamplingRate;
        else
            Result = mpb_time_filter(Filter,InputData);
        end
    end
    
    % Add history line
    Result = ita_metainfo_add_historyline(Result,'ita_filter_pdi',varargin);
end

varargout{1} = Result;
%EOF ita_filter_pdi

function [specs,FilterName] = mpb_parser(specs,inputarg)
%% standard settings
specs.filterorder  = 10;
specs.filter_mask  = [];
specs.filter_type  = 'butter';
specs.filter_class = 'Class 0';
specs.switchfrequencies = false;
option_idx = 2; %options follow at this index

%% parsing filter information
if ischar(inputarg{option_idx}) %char input
    switch lower(inputarg{option_idx})
        case {'oct','octave','octaves'} %band filters
            specs.filter_mask = 'octave';
            if ~isempty(inputarg{option_idx+1}) && isnumeric(inputarg{option_idx+1})
                specs.bandsperoct = inputarg{option_idx+1};
                option_idx = option_idx +1;
            else
                specs.bandsperoct = 1;
            end
        case {'oct*','octave*','octaves*'} %band filters
            specs.filter_mask = 'octave';
            if ~isempty(inputarg{option_idx+1}) && isnumeric(inputarg{option_idx+1})
                specs.bandsperoct = inputarg{option_idx+1};
                option_idx = option_idx +1;
            else
                specs.bandsperoct = 1;
            end
            specs.switchfrequencies = true;
        case {'3-oct','third-octaves'}
            specs.filter_mask = 'octave';
            specs.bandsperoct  = 3;
            
        case {'a','a-weight'}
            specs.filter_mask = 'a-weight';
            
        case {'c','c-weight'}
            specs.filter_mask = 'c-weight';
            
        otherwise
            error('ita_filter_pdi: Oh Lord. I do not know this filter option.')
            
    end
    
elseif isnumeric(inputarg{option_idx})
    specs.freqvec = inputarg{option_idx};
    
    if length(specs.freqvec) ~= 2
        error('ita_filter_pdi:Oh Lord. Please check out my syntax.')
    elseif (specs.freqvec(1) > specs.freqvec(2)) && (specs.freqvec(2) ~= 0)
        error('ita_filter_pdi:Oh Lord. Filter frequency setting seems to be incorrect. Check syntax.');
    end
    %pdi bugfix
    if ceil(specs.freqvec(2)) >= floor(specs.samplingRate/2)
        ita_verbose_info('ita_filter_pdi:skipping high frequency',0)
        specs.freqvec(2) = 0;
    end
    if specs.freqvec(1) == 0 % lowpass requested
        specs.freqvec(2) = min(specs.freqvec(2),floor(specs.samplingRate/2));
        specs.filter_mask = 'low_pass';
    elseif (specs.freqvec(2) == 0) || (specs.freqvec(2) >= specs.samplingRate) % highpass requested
        specs.filter_mask = 'high_pass';
    else
        specs.freqvec(2) = min(specs.freqvec(2),floor(specs.samplingRate/2));
        specs.filter_mask = 'band_pass';
    end
    
else
    error('ita_filter_pdi:Oh Lord. Please check out my syntax!')
end

%% Parse additional arguments
specs.zerophase = false;
specs.minphase  = false;
sizeinput = length(inputarg);

if sizeinput > option_idx
    i = option_idx+1;
    
    while i <= sizeinput
        token = inputarg{i};
        
        if ischar(token)
            switch(lower(token))
                case {'zerophase','zero-phase','zero phase'} %set filter to have no phase at all
                    if ~specs.frequencyfiltering
                        specs.frequencyfiltering = true;
                    end
                    specs.zerophase = true;
                    
                case {'minimumphase','minimum-phase','minimum phase'} %set filter to have no phase at all % TODO HUHU Documentation
                    if ~specs.frequencyfiltering
                        specs.frequencyfiltering = true;
                    end
                    specs.minphase = true;
                    
                case {'order'} %set filter order manually
                    if sizeinput >= (i+1)
                        specs.filterorder = inputarg{i+1};
                        i = i+1;
                    else
                        error('ita_filter_pdi:Oh Lord. Parameter is missing.')
                    end
                    
                case {'class'}
                    if sizeinput >= (i+1)
                        if isnumeric(inputarg{i+1})
                            specs.filter_class = ['class ' num2str(inputarg{i+1})];
                        else
                            specs.filter_class = inputarg{i+1};
                        end
                        i = i+1;
                    else
                        error('ita_filter_pdi:Oh Lord. Parameter is missing.')
                    end
                    
                otherwise
                    error('ita_filter_pdi:Oh Lord. I don''t know this option.')
            end
        else
            error('ita_filter_pdi:Oh Lord. I don''t know this option.')
        end
        i = i+1;
    end
end

%Define Name
switch specs.filter_mask
    case {'a-weight','c-weight'}
        FilterName = specs.filter_mask;
        
    case 'octave'
        FilterName = [num2str(specs.bandsperoct) specs.filter_mask '_' specs.filter_class '_order' num2str(specs.filterorder)];
        
    case 'band_pass'
        FilterName = [specs.filter_mask '_' num2str(specs.freqvec(1)) '_' num2str(specs.freqvec(2)) '_order' num2str(specs.filterorder)];
        
    case 'high_pass'
        FilterName = [specs.filter_mask '_' num2str(specs.freqvec(1)) '_order' num2str(specs.filterorder)];
        
    case 'low_pass'
        FilterName = [specs.filter_mask '_' num2str(specs.freqvec(2)) '_order' num2str(specs.filterorder)];
        
end
FilterName = [FilterName(~isspace(FilterName))  '_Fs' num2str(specs.samplingRate)];

function Filter = mpb_get_filter(specs,FilterName)
%% Check if filter already exists and if not, generate it.
flag_new = false;
FilterName(FilterName  == '-') = 'm';
FilterName(FilterName  == '.') = 'p';
eval(['global RWTH_ITA_Filter_' FilterName ';']); %Try to load filter from global variable
Filter = eval(['RWTH_ITA_Filter_' FilterName ';']);

if isempty(Filter)
    % Filter not yet loaded as a global variable. Check if it is avalaible
    % at the saved filters and if not, generate new filter. BMA
    
    FilterNameMat = [FilterName '.mat'];
    pathstr = fileparts(mfilename('fullpath'));
    filterpath = [pathstr filesep 'Filters'];
    
    % If the directory does not exist yet, create it.
    if ~isdir(filterpath)
        ita_verbose_info('ita_filter_pdi:Creating a Filter directory for you!',1);
        mkdir(filterpath)
    end
    
    FilterFileName = [filterpath filesep FilterNameMat];
    if exist(FilterFileName,'file') && ~specs.switchfrequencies
        load(FilterFileName);
    else
        Filter = mpb_generate_filter(specs);
        flag_new = true;
    end
    
    % Load global variable
    eval(['RWTH_ITA_Filter_' FilterName ' = Filter;']);
    
else
    FilterNameMat = [FilterName '.mat'];
    %     my_path = pwd;
    pathstr = fileparts(mfilename('fullpath'));
    filterpath = [pathstr filesep 'Filters'];
    FilterFileName = [filterpath filesep FilterNameMat];
end

if specs.frequencyfiltering && ~isfield(Filter,'impulseResponse')
    % Make impulse. Use fft_degree 15 and resize afterwards for performance
    % reasons.
    FFT_DEGREE_FILTER = 15;
    impulse = ita_generate('impulse',1,specs.samplingRate,FFT_DEGREE_FILTER);
    impulse = ita_metainfo_rm_channelsettings(impulse);
    
    % Filter is now a structure that contains the filter object .Hd and
    % the filter impulse response .dat with its normal . If the
    % filter is an octave filter bank, the center frequencies of each
    % filter are saved at .CenterFreq.
    ImpulseResponse = mpb_time_filter(Filter,impulse);
    Filter.impulseResponse = ImpulseResponse;
    eval(['RWTH_ITA_Filter_' FilterName ' = Filter;']);
    clear ImpulseResponse impulse
    flag_new = true;
end

if flag_new && ~specs.switchfrequencies
    save(FilterFileName,'Filter');
end



function Filter = mpb_generate_filter(specs)
%% Generate Filter settings and Filtering

switch specs.filter_mask
    case 'a-weight'
        warning off %#ok<WNOFF>
        f1 = 20.598997;
        f2 = 107.65265;
        f3 = 737.86223;
        f4 = 12194.217;
        A1000 = 1.9997;
        NUMs = [ (2*pi*f4)^2*(10^(A1000/20)) 0 0 0 0 ];
        DENs = conv([1 +4*pi*f4 (2*pi*f4)^2],[1 +4*pi*f1 (2*pi*f1)^2]);
        DENs = conv(conv(DENs,[1 2*pi*f3]),[1 2*pi*f2]);
        [B,A] = bilinear(NUMs,DENs,specs.samplingRate);
        Hd = dfilt.df1t(B,A);
        Filter.Hd = convert(Hd,'df2sos');
        
    case 'c-weight'                            % C weightning
        warning off %#ok<WNOFF>
        f1 = 20.598997;
        f4 = 12194.217;
        C1000 = 0.0619;
        NUMs = [ (2*pi*f4)^2*(10^(C1000/20)) 0 0 ];
        DENs = conv([1 +4*pi*f4 (2*pi*f4)^2],[1 +4*pi*f1 (2*pi*f1)^2]);
        [B,A] = bilinear(NUMs,DENs,specs.samplingRate);
        Hd = dfilt.df1t(B,A);
        Filter.Hd = convert(Hd,'df2sos');
        
    case 'octave'
        if specs.switchfrequencies %renzo-mode         %pdi added for renzen
            ita_verbose_info('ita_filter_pdi:switching center frequencies for model room measurements.',0)
            specs.oldSamplingRate = specs.samplingRate;
            specs.samplingRate = specs.samplingRate / round(specs.samplingRate./48000);
        end
        h       = fdesign.octave(specs.bandsperoct,specs.filter_class, 'N,F0',specs.filterorder,1000,specs.samplingRate);
        
        % pdi new round according to ANSI
        freqvec = ita_ANSI_center_frequencies([min(freq) max(freq)],specs.bandsperoct);
        if length(freqvec) ~= length(freq)
            error('ANSI frequencies are strange')
        end
        % end rounding
        
        N       = length(freqvec);
        idx = 1;
        for cdx = 1:N
            h.F0 = freq(cdx);
            
            try
                Hd(cdx) = design(h, specs.filter_type); %#ok<AGROW>
                freqvec(idx) = freqvec(cdx);
                if cdx == N
                    if max(impz(Hd(N))) > 10;
                        h.F0 = h.F0/2^(1/2/h.BandsPerOctave);
                        Hd(cdx) = design(fdesign.highpass('n,fc', h.FilterOrder/2, h.F0/h.Fs*2), specs.filter_type); %#ok<AGROW>
                    end
                end
                idx = idx + 1;
            catch %#ok<CTCH>
                
            end
        end
        %last filter is a high pass, and not a band pass filter.
        
        Filter.Hd = Hd;
        if specs.switchfrequencies
            freqvec = freqvec .* specs.oldSamplingRate ./ specs.samplingRate;
            %             specs.samplingRate = specs.oldSamplingRate;
        end
        Filter.CenterFreq = freqvec;
        
    case 'band_pass'
        h  = fdesign.bandpass('n,f3dB1,f3dB2',specs.filterorder,specs.freqvec(1),specs.freqvec(2),specs.samplingRate);
        Filter.Hd = design(h,specs.filter_type);
        
    case 'high_pass'    %% High Pass
        h  = fdesign.highpass('n,f3dB',specs.filterorder,specs.freqvec(1),specs.samplingRate);
        Filter.Hd = design(h,specs.filter_type);
        
    case 'low_pass'     %% Low Pass
        h  = fdesign.lowpass('n,f3db',specs.filterorder,specs.freqvec(2),specs.samplingRate);
        Filter.Hd = design(h,specs.filter_type);
        
    otherwise
        error('ita_filter_pdi:Oh Lord. I don''t know this filter mask.')
end

function result = mpb_time_filter(Filter,data)
%% Filter in Time Domain
result = data;
if length(Filter.Hd) == 1
    result.timeData = filter(Filter.Hd,data.dat,2).';
else
    NCHANNELS = result.nChannels;
    
    %     ChannelNames = result.channelNames;
    ChannelUnits = result.channelUnits;
    
    finalTimeData = [];
    finalChannelUnits = {};
    for idx = 1:length(Filter.Hd)
        %         filtString = repmat([num2str(round(Filter.CenterFreq(idx))) 'Hz - '],NCHANNELS,1);
        finalTimeData = [finalTimeData filter(Filter.Hd(idx),data.timeData',2).']; %#ok<AGROW>
        
        %% TODO mmt
        %         finalChannelNames{end+1:end+NCHANNELS} = [filtString(idch,:)  ChannelNames{idch}];
        finalChannelUnits(end+1:end+NCHANNELS) = ChannelUnits; 
        
    end
    result.timeData = finalTimeData;
    result.channelUnits = finalChannelUnits;
end

function result = mpb_freq_filter(specs,Filter,data)
%% Filter in Frequecy Domain
impResp = (Filter.impulseResponse);
% result = impResp;
%correct size of impulse response to the data length and take the FFT
spk_filter = ita_fft(ita_extend_dat(impResp,data.nSamples));
% result = ita_metainfo_rm_historyline(result,'all');
if specs.zerophase
    spk_filter = ita_zerophase(spk_filter);
end
if specs.minphase
    spk_filter = ita_minimumphase(spk_filter);
end

oldHistory = data.history;

if spk_filter.nChannels == 1
    result = ita_multiply_spk(data,spk_filter);
    result.history = oldHistory;
else
    tempfilter = itaAudio([spk_filter.nChannels 1]);
    for idx = 1:spk_filter.nChannels
        tempfilter(idx) = data*split(spk_filter,idx); 
        for jdx = 1:data.nChannels
            tempfilter(idx).channelNames{jdx} = [num2str(Filter.CenterFreq(idx)) ' Hz'];
        end
        %         result.freqvec = Filter.CenterFreq;
    end
    result = merge(tempfilter);
    %    result.freqvec = Filter.CenterFreq; % RSC: Wont do anything anyway
end

