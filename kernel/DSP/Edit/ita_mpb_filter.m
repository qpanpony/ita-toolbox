function varargout = ita_mpb_filter(varargin)
%ITA_MPB_FILTER - Filtering audio data.
%
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
%  Syntax: audioObj  = ita_mpb_filter(audioObj,type,options)
%  Syntax: filterStruct = ita_mpb_filter(SamplingRate,type,options)
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
%  The supported options are listed below:
%
%  Filter order:
%  You can specify the filter order manually by appending 'order',value to
%  the arguement list
%
%  Filter class:
%  You can specify the filter class manually by appending 'class',value to
%  the arguement list, been the classes 0,1 and 2 available.
%  Call: audioObj = ita_mpb_filter(audioObj,[lowerFreq, higherFreq],'zerophase','class',1)
%
%  Zerophase:
%  specify zerophase to build a filter without any phase at all. Oh Lord. We hope
%  you know enough about signal theory!
%
%  Minimum and zero phase filters:
%  ita_mpb_filter(... 'zerophase')
%  ita_mpb_filter(... 'minimumphase')
%
%  See also ita_make_filter.
%
%  Reference page in Help browser <a href="matlab:doc ita_mpb_filter">doc ita_mpb_filter</a>
%
%  Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%  Created:  23-Jun-2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Initialization
if nargin == 0
    varargout{1} = ita_mpb_filter_GUI();
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
    error('ITA_MPB_FILTER:Oh Lord. Only structs allowed.')
end

specs.frequencyfiltering = true; %pdi,klein:major bug fix 18-jun-2009

%% Parse Options
[specs,FilterName] = mpb_parser(specs,varargin);


%% check if filtering is necessary
if isa(varargin{1},'itaAudio')
    if isfield(specs,'freqvec') && sum(specs.freqvec) == 0
        varargout{1} = varargin{1};
        return;
    end
end

%% Get Filter and do filtering if and as specified
Filter = mpb_get_filter(specs,FilterName);

if OutputJustFilter
    % 30.5.2011, mpo, bugfix for zerophase filter
    if specs.zerophase
        Filter.impulseResponse.freqData = abs(Filter.impulseResponse.freqData);
    end
    varargout(1) = {Filter};
    return
else %normal mode, do some filtering
    if specs.frequencyfiltering
        % Do filtering
        Result = mpb_freq_filter(specs,Filter,InputData');
    else
        Result = mpb_time_filter(Filter,InputData);
    end
    % Add history line
    Result = ita_metainfo_add_historyline(Result,'ita_mpb_filter',varargin);
end

varargout{1} = Result;
%EOF ita_mpb_filter

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
            if (numel(inputarg)  >= option_idx+1) && ~isempty(inputarg{option_idx+1}) && isnumeric(inputarg{option_idx+1})
                specs.bandsperoct = inputarg{option_idx+1};
                option_idx = option_idx +1;
            else
                specs.bandsperoct = ita_preferences('bandsPerOctave');
            end
            tmp  = ita_ANSI_center_frequencies(specs.samplingRate, specs.bandsperoct);
            specs.octavefreqrange = tmp([1 end]);
            
        case {'3-oct','third-octaves'}
            specs.filter_mask = 'octave';
            specs.bandsperoct  = 3;
            tmp  = ita_ANSI_center_frequencies(specs.samplingRate, specs.bandsperoct);
            specs.octavefreqrange = tmp([1 end]);
            
        case {'a','a-weight'}
            specs.filter_mask = 'a-weight';
            
        case {'c','c-weight'}
            specs.filter_mask = 'c-weight';
            
        otherwise
            error([ 'ITA_MPB_FILTER: Oh Lord. I do not know the filter option: ' lower(inputarg{option_idx})])
            
    end
    
elseif isnumeric(inputarg{option_idx})
    specs.freqvec = inputarg{option_idx};
    
    if length(specs.freqvec) ~= 2
        error('ITA_MPB_FILTER:Oh Lord. Please check out my syntax.')
    elseif (specs.freqvec(1) > specs.freqvec(2)) && (specs.freqvec(2) ~= 0)
        error('ITA_MPB_FILTER:Oh Lord. Filter frequency setting seems to be incorrect. Check syntax.');
    end
    %pdi bugfix
    if ceil(specs.freqvec(2)) >= floor(specs.samplingRate/2)
        ita_verbose_info('ITA_MPB_FILTER:skipping high frequency',0)
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
    error('ITA_MPB_FILTER:Oh Lord. Please check out my syntax!')
end

%% Parse additional arguments
specs.zerophase = false;
specs.minphase  = false;
sizeinput = length(inputarg);


% sArgs = struct('octavefreqrange',specs.octavefreqrange,'order',)

if sizeinput > option_idx
    i = option_idx+1;
    
    while i <= sizeinput
        token = inputarg{i};
        
        if ischar(token)
            switch(lower(token))
                case {'octavefreqrange'}
                     if sizeinput >= (i+1)
                        specs.octavefreqrange = inputarg{i+1};
                        i = i+1;
                    else
                        error('ITA_MPB_FILTER:Oh Lord. Parameter is missing.')
                    end
                case {'zerophase','zero-phase','zero phase'} %set filter to have no phase at all
                    if ~specs.frequencyfiltering
                        specs.frequencyfiltering = true;
                    end
                    possibleValues = {'true','false','on','off'};
                    if numel(inputarg) > i && (ischar(inputarg{i+1}) && ismember(lower(inputarg{i+1}),possibleValues) || islogical(inputarg{i+1}))
                        specs.zerophase = inputarg{i+1};
                        i = i+1;
                    else
                        specs.zerophase = true;
                    end
                    
                case {'minimumphase','minimum-phase','minimum phase'} %set filter to have no phase at all
                    if ~specs.frequencyfiltering
                        specs.frequencyfiltering = true;
                    end
                    specs.minphase = true;
                    
                case {'order','filterorder'} %set filter order manually
                    if sizeinput >= (i+1)
                        specs.filterorder = inputarg{i+1};
                        i = i+1;
                    else
                        error('ITA_MPB_FILTER:Oh Lord. Parameter is missing.')
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
                        error('ITA_MPB_FILTER:Oh Lord. Parameter is missing.')
                    end
                    
                otherwise
                    error(['ITA_MPB_FILTER:Oh Lord. I don''t know this option. :: ' token ])
            end
        else
            error(['ITA_MPB_FILTER:Oh Lord. I don''t know this option. :: ' token ])
        end
        i = i+1;
    end
end

%Define Name
switch specs.filter_mask
    case {'a-weight','c-weight'}
        FilterName = specs.filter_mask;
        
    case 'octave'
        FilterName = [num2str(specs.bandsperoct) specs.filter_mask '_' specs.filter_class '_order' num2str(specs.filterorder) ...
            '_range' num2str(specs.octavefreqrange(1)) '_' num2str(specs.octavefreqrange(2)) ];
        
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


FilterName = regexprep(FilterName, '([0-9]+)000([^0-9]*)','$1k$2');  % avoid exceeding maximum file name length (63 characters)

eval(['global RWTH_ITA_Filter_' FilterName ';']); %Try to load filter from global variable
Filter = eval(['RWTH_ITA_Filter_' FilterName ';']);

if isempty(Filter)
    % Filter not yet loaded as a global variable. Check if it is avalaible
    % at the saved filters and if not, generate new filter. BMA
    
    FilterNameMat = [FilterName '.mat'];
    pathstr       = fileparts(mfilename('fullpath'));
    filterpath    = [pathstr filesep 'Filters'];
    
    % If the directory does not exist yet, create it.
    if ~isdir(filterpath)
        ita_verbose_info('ITA_MPB_FILTER:Creating a Filter directory for you!',1);
        mkdir(filterpath)
    end
    
    FilterFileName = [filterpath filesep FilterNameMat];
    if exist(FilterFileName,'file')
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
    % when filters are too short for low frequencies
    if isfield(specs,'octavefreqrange') && min(specs.octavefreqrange) < 20
        FFT_DEGREE_FILTER = 18;
    end
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

if flag_new
    save(FilterFileName,'Filter');
end

function Filter = mpb_generate_filter(specs)
%% Generate Filter settings and Filtering

switch specs.filter_mask
    case 'a-weight'
        warning off
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
        warning off 
        f1 = 20.598997;
        f4 = 12194.217;
        C1000 = 0.0619;
        NUMs = [ (2*pi*f4)^2*(10^(C1000/20)) 0 0 ];
        DENs = conv([1 +4*pi*f4 (2*pi*f4)^2],[1 +4*pi*f1 (2*pi*f1)^2]);
        [B,A] = bilinear(NUMs,DENs,specs.samplingRate);
        Hd = dfilt.df1t(B,A);
        Filter.Hd = convert(Hd,'df2sos');
        
    case 'octave'
        fc = 1000;
        b  = specs.bandsperoct;
        sr = specs.samplingRate;
        h  = fdesign.bandpass('N,F3dB1,F3dB2',specs.filterorder,fc*2^(-1/b/2)/sr, fc*2^(1/b/2)/sr);

        % pdi new round according to ANSI
        [freqvecAnsi, freqvecExact] = ita_ANSI_center_frequencies(specs.octavefreqrange([1 end]),b,sr);
        
        for cdx = 1:length(freqvecExact) %go thru all filters
            fc      = freqvecExact(cdx);  % exact center frequency
            h.F3dB1 = fc*2^(-1/b/2)/sr*2; % low bandpass
            h.F3dB2 = fc*2^( 1/b/2)/sr*2; % high bandpass
            
            if h.F3dB2 >= 1 %check for cut off frequencies out of bounds
                ita_verbose_info('ita_mpb_filter::Highest fractional octave band filters substituted by highpass only.',1);
                Hd(cdx) = design(fdesign.highpass('n,F3dB', h.FilterOrder, h.F3dB1), specs.filter_type); %#ok<AGROW>
            else %normal fractional octave band filters
                Hd(cdx) = design(h, specs.filter_type); %#ok<AGROW>
            end
        end
        % store results for next time
        Filter.Hd         = Hd;
        Filter.CenterFreq = freqvecAnsi;
        
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
        error('ITA_MPB_FILTER:Oh Lord. I don''t know this filter mask.')
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
Filter.impulseResponse.dataType = data.dataType;  % to be sure that the following ita_fft & ita_extend work with the right dataType
%correct size of impulse response to the data length and take the FFT
spk_filter = ita_fft(ita_extend_dat(Filter.impulseResponse, data.nSamples));
% result = ita_metainfo_rm_historyline(result,'all');
if specs.zerophase
    spk_filter = ita_zerophase(spk_filter);
end
if specs.minphase
    spk_filter = ita_minimumphase(spk_filter);
end

oldHistory = data.history;

if spk_filter.nChannels == 1
    result = data*spk_filter;
    result.history = oldHistory;
elseif data.nChannels == 1
    result          = data;
    result.freqData = bsxfun(@times, spk_filter.freqData, data.freqData);
    result.channelUnits = repmat(data.channelUnits,result.nChannels,1);
    strMat = [num2str(Filter.CenterFreq(:)) repmat(' Hz', length(Filter.CenterFreq), 1)];
    result.channelNames = mat2cell(strMat, ones(1, size(strMat,1)), size(strMat,2));
else  % TODO: auch schneller
    tempfilter = itaAudio([spk_filter.nChannels 1]);
    for idx = 1:spk_filter.nChannels
        tempfilter(idx) = data*split(spk_filter,idx); 
        for jdx = 1:data.nChannels
            tempfilter(idx).channelNames{jdx} = [num2str(Filter.CenterFreq(idx)) ' Hz'];
        end
    end
    result = merge(tempfilter); % wer will denn mit dem kauderwelsch was anfangen?
end

