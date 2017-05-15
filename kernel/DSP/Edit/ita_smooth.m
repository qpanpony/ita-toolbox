function varargout = ita_smooth(audioObject, varargin)
%ITA_SMOOTH - Smoothes the given data
%  This function smoothes time data and frequency data. In the time domain only linear smoothing
%  is possible using the matlab function 'smooth'. In frequency domain either linear or logarithmic
%  smoothing is possible. It is also possible to smooth the absolute values
%  or the complex values.
%  The bandwidth for linear smoothing has to be defined by the user in samples or seconds in
%  time domain or in bins or Hertz in frequency domain. In the case of logarithmic smoothing
%  in the frequency domain, the bandwidth has to be defined in fractions of octaves, e.g. 1/3 for
%  third octave smoothing.
%
%  Syntax:  audioObj = ita_smooth(audioObject,options)
%           audioObj = ita_smooth(audioObject)
%  Options (default timeData / default freqData)):
%   'smoothTypes' ('LinTimeSec' / 'LinFreqBins'):       'LinTimeSec', 'LinTimeSamp', 'LinFreqHertz', 'LinFreqBins', 
%                                                       'LogFreqOctave1', 'LogFreqOctave2' or 'Gammatone'
%                                                       There exist two different smoothTypes of logarithmic smoothing in the
%                                                       frequency domain. 'LogFreqOctave1' interpolates the frequency data to a
%                                                       logarithmic frequency axis  and then uses 'smooth' as a moving average
%                                                       for the logarithmic frequencies. 'LogFreqOctave2' calculates the
%                                                       frequency dependant windows for the linear frequency axis and then
%                                                       calculates averages for the moving frequency dependant window. Be aware,
%                                                       that the second method is much slower than the first one!!!
%                                                       The Gammatone smoothing is based on a window the size of a Gammatone
%                                                       filter. The second parameter in this case is the filter order.
%
%   'windowWidth' (0.1 / 1/3):                          This parameter is interpreted based on the chosen smoothType, e.g.
%                                                       for 'LinTimeSec' bandwidth is interpreted as Seconds, the input argument
%                                                       is given as a simple numeric value.
%
%   'dataTypes' ('Real' / 'Abs'):                       'Real', 'Complex', 'Abs', 'GDelay', 'Abs+GDelay' or 'Abs+Phase';
%                                                       In Time Domain interpolation we always use 'Real' no
%                                                       matter, what the input parameter 'dataType' is set
%                                                       to.  For frequency domain interpolation, it is
%                                                       possible to choose between smoothing real and
%                                                       imaginary parts, just the absolute value, just the
%                                                       group delay (respectively phase) or both together.
% 
%
%  If ita_smooth is called without the optional parameters the following
%  defaults are used:
%  time data: {'LinTimeSec', 0.1, 'Real'}
%  freq data: {'LogFreqOctave1', 1/3, 'Abs'}
%
%  Example: ita_smooth(frequencyStruct,'LogFreqOctave1',1/3,'Abs') - third octave band smoothing on absolute values in frequency domain
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_smooth">doc ita_smooth</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% TODO: clean-up, old syntax (example) doesnt work anymore

% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created:  24-Feb-2009


thisFuncStr  = [upper(mfilename) ':'];

% Check if 
if exist('smooth.m','file')
    smooth_helper = @smooth;
    smooth_opt = [];
    ita_verbose_info('Using MATLAB smooth',1);
else
    smooth_helper = @ita_smooth_helper;
    smooth_opt = cell(1);
    ita_verbose_info('Using lowlevel Toolbox Smooth',1);
end

%% READ INPUT ARGUMENTS
narginchk(1,6);

if nargin >= 4 && strcmp(func2str(smooth_helper),'smooth')
    smooth_opt = varargin(4:end);
    varargin(4:end) = [];
else
    ita_verbose_info([thisFuncStr 'No Curve Fitting Toolbox. Additional arguments cannot be processed.'],1)
    varargin(4:end) = [];
end

result = itaAudio([numel(audioObject),1]);
for ind = 1:numel(audioObject)
    audioObj = audioObject(ind);
    
    % First input argument must be a struct with data in time or frequency domain.
    % -------------------------------------------------------------------------
    if ~isa(audioObj,'itaAudio') %pdi: if someone wants to use itaSuper instead of itaAudio, please contact me first!
        error('ITA_SMOOTH:Oh Lord. Only ITAs allowed as first input argument!')
    end
    domain = audioObj.domain;
    
    % Check if optional parameters are set. If not specify defaults
    if length(varargin) == 3
        smoothType = varargin{1};
        windowWidth = varargin{2};
        dataType = varargin{3};
    elseif isempty(varargin)
        if isequal(domain, 'freq')
            ita_verbose_info([thisFuncStr 'Assuming Frequency domain smoothing with third octave band.'],1)
            smoothType = 'LogFreqOctave1';
            windowWidth = 1/3;
            dataType = 'Abs';
        elseif isequal(domain, 'time')
            ita_verbose_info([thisFuncStr 'Assuming Time domain smoothing with 0.1 seconds'],1)
            smoothType = 'LinTimeSec';
            windowWidth = 0.1;
            dataType = 'Real';
        end
    else
        error('ITA_SMOOTH:Oh Lord. You either have to specify all 3 optional parameters or none.');
    end
    
    % Second input argument 'smoothType' must be a valid string
    % -------------------------------------------------------------------------
    validTypes         = {'LinTimeSec', 'LinTimeSamp', 'LinFreqHertz', 'LinFreqBins', 'LogFreqOctave1', 'LogFreqOctave2','Gammatone'};
    if ischar(smoothType)
        if ismember(smoothType, validTypes)
            if ( isequal(smoothType, 'LinTimeSec') || isequal(smoothType, 'LinTimeSamp') ) && isequal(domain, 'freq')
                audioObj = ita_ifft(audioObj);
                domain = 'time';
            end
            if ( isequal(smoothType, 'LinFreqHertz') || ...
                    isequal(smoothType, 'LinFreqBins') || ...
                    isequal(smoothType, 'LogFreqOctave1') || ...
                    isequal(smoothType, 'LogFreqOctave2') || ...
                    isequal(smoothType, 'Gammatone') ) && ...
                    isequal(domain, 'time')
                audioObj = audioObj';
                domain = 'freqData';
            end
        else
            error(['ITA_SMOOTH:Oh Lord. Invalid String for second input argument smoothType.',...
                'Please choose one of the following types: ', validTypes{:} '.'])
        end
    else
        error('ITA_SMOOTH:Oh Lord. Second input argument must be a string.')
    end
    
    % Third input argument 'windowWidth' must be numeric. Depending on 'smoothType'
    % the value of 'windowWidth' must be checked!
    % -------------------------------------------------------------------------
    if isnumeric(windowWidth) && isequal(size(windowWidth),[1,1])
        switch smoothType
            case 'LinTimeSec'
                timeVector  = audioObj.timeVector';
                timeBinDist = timeVector(2)-timeVector(1);
                maxTime     = timeVector(length(timeVector));
                if (windowWidth >= timeBinDist)  && (windowWidth <= maxTime)
                    span = round(windowWidth/timeBinDist);
                    span = span + 1 - mod(span,2); % Just make sure its uneven instead of an error
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
            case 'LinTimeSamp'
                if (windowWidth >= 1) && (windowWidth <= audioObj.nSamples)
                    span = windowWidth;
                    span = span +1 - mod(span,2); % Just make sure its uneven instead of an error
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
            case 'LinFreqHertz'
                bins = audioObj.freqVector.';
                binDist = diff(bins(1:2));
                if (windowWidth >= binDist) && (windowWidth <= bins(length(bins)))
                    span = round(windowWidth/binDist);
                    span = span +1 - mod(span,2); % Just make sure its uneven instead of an error
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
            case 'LinFreqBins'
                if (windowWidth >= 1) && (windowWidth <= audioObj.nBins)
                    span = windowWidth;
                    span = span +1 - mod(span,2); % Just make sure its uneven instead of an error
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
            case 'LogFreqOctave1'
                if windowWidth >= 1/120  && windowWidth <= 1 % minimum Bandwidth = 10cent; maximum bandwidth = 1octave
                    % ok, do nothing for the moment
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
            case 'LogFreqOctave2'
                if windowWidth >= 1/120  && windowWidth <= 1 % minimum Bandwidth = 10cent; maximum bandwidth = 1octave
                    % ok, do nothing for the moment
                else
                    error('ITA_SMOOTH:Oh Lord. Invalid Input for windowWidth.')
                end
        end
    else
        error('ITA_ROHRBERT:Oh Lord. Third input argument must be numeric.')
    end
    
    % Fourth input argument 'dataType' must be a string. Either 'Real','Abs' or 'Complex'
    % -------------------------------------------------------------------------
    validDataTypes = {'Real', 'Complex', 'Abs', 'GDelay', 'Abs+GDelay', 'Abs+Phase'};
    if ischar(dataType)
        if ismember(lower(dataType), lower(validDataTypes))
            if isequal(smoothType, 'LinTimeSec') || isequal(smoothType, 'LinTimeSamp')
                % For time domain interpolation we always interpolate real numbers
                dataType = 'Real';
            end
        else
            error('ITA_SMOOTH:Oh Lord. Invalid String for fourth input argument dataType.')
        end
    else
        error('ITA_SMOOTH:Oh Lord. Fourth input argument must be a string.')
    end
    
    %% Do Smoothing
    switch smoothType
        case {'LinTimeSec','LinTimeSamp'}
            out = zeros(audioObj.nSamples,audioObj.nChannels);
            % Time domain smoothing of real valued data
            data = real(audioObj.timeData);
            for k=1:audioObj.nChannels
                out(:,k) = ita_smooth_helper(data(:,k), span);
            end
        case {'LinFreqHertz','LinFreqBins'}
            % Linear Frequency Domain Smoothing
            out = zeros(audioObj.nBins,audioObj.nChannels);
            absOut = zeros(audioObj.nBins,audioObj.nChannels);
            switch lower(dataType)
                case 'abs'
                    data = abs(audioObj.freqData);
                    for k=1:audioObj.nChannels
                        absOut(:,k) = ita_smooth_helper(data(:,k), span);
                    end
                    out = absOut .* exp(1i*angle(audioObj.freqData));
                case 'complex'
                    data = audioObj.freqData;
                    for k=1:audioObj.nChannels
                        out(:,k) = ita_smooth_helper(data(:,k), span);
                    end
                case 'real'
                    data = real(audioObj.freqData);
                    ita_verbose_info('ITA_SMOOTH:Only smoothing real part in frequency domain. Imaginary part is dismissed. I hope you know what you are doing!',1);
                    for k=1:audioObj.nChannels
                        out(:,k) = ita_smooth_helper(data(:,k), span);
                    end
            end
        case {'LogFreqOctave1'}
            % logarithmic frequency domain smoothing (Version 1)
            freq = audioObj.freqVector;
            nBins        = audioObj.nBins;
            channels     = audioObj.nChannels;
            SamplingRate = audioObj.samplingRate;
            
            % We subdivide the frequency domain into 20 Octaves, where the upper
            % boundary of the highest octave is the Nyquist Frequency
            f_max            = (SamplingRate/2);
            f_min            = f_max * 2^(-20);
            
            % We build a new frequency vector in 1 cent steps (1 octave = 1200 cent)
            cent = 0:1:24000;
            fCent = f_min .* 2.^(cent/1200);
            
            span = round(windowWidth * 1200);
            out = zeros(nBins,channels);
            switch lower(dataType) % fpa: ignore constant component when smoothing, otherwise: possible offset in time data
                case 'real'
                    ita_verbose_info('ITA_SMOOTH:Only smoothing real part in frequency domain. Imaginary part is dismissed. I hope you know what you are doing!',1);
                    for k=1:channels
                        SignalCent       = interp1(freq, real(audioObj.freqData(:,k)), fCent);
                        signalCentSmooth = feval(smooth_helper,SignalCent, span,smooth_opt{:});
                        out(:,k)         = [audioObj.freqData(1,k);interp1(fCent(2:end), signalCentSmooth(2:end), freq(2:end), 'spline')];
                    end
                    
                case 'complex'
                    for k=1:channels
                        SignalCent       = interp1(freq, audioObj.freqData(:,k), fCent);
                        signalCentSmooth = feval(smooth_helper,SignalCent, span,smooth_opt{:});
                        out(:,k)         = [audioObj.freqData(1,k);interp1(fCent(2:end), signalCentSmooth(2:end), freq(2:end), 'spline')];
                    end
                    
                case 'abs'
                    spkData = audioObj.freqData;
                    for k=1:channels
                        SignalCent       = interp1(freq, abs(spkData(:,k)), fCent);
                        signalCentSmooth = feval(smooth_helper,SignalCent, span,smooth_opt{:});
                        absOut           = interp1(fCent(2:end), signalCentSmooth(2:end), freq(2:end),'spline'); 
                        out(:,k)         = [spkData(1,k);absOut(:)] .* exp(1i*angle(spkData(:,k)));
                    end
                    
                case 'gdelay'
                    gdelay = ita_groupdelay(audioObj);
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                    for k=1:channels
                        SignalCent       = interp1(freq, gdelay(:,k), fCent);
                        signalCentSmooth = feval(smooth_helper,SignalCent, span,smooth_opt{:});
                        delayOut         = interp1(fCent(2:end), signalCentSmooth(2:end), freq(2:end), 'spline');
                        out(:,k)         = [audioObj.freqData(1,k); abs(audioObj.freqData(2:end,k))] .* exp(1i*-cumsum([gdelay(1,k);delayOut])*(bin_dist * 2*pi));
                    end
                    
                case 'abs+gdelay'
                    gdelay = ita_groupdelay(audioObj);
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                    for k=1:channels
                        SignalCentAbs    = interp1(freq, abs(audioObj.freqData(:,k)), fCent);
                        SignalCentDelay  = interp1(freq, gdelay(:,k),fCent);%unwrap(angle(audioObj.freqData(:,k)),[],2), fCent);
                        signalCentSmoothAbs = feval(smooth_helper,SignalCentAbs,span,smooth_opt{:});
                        signalCentSmoothDelay = feval(smooth_helper,SignalCentDelay,span,smooth_opt{:});
                        absOut           = interp1(fCent(2:end), signalCentSmoothAbs(2:end), freq(2:end), 'spline');
                        delayOut         = interp1(fCent(2:end), signalCentSmoothDelay(2:end), freq(2:end), 'spline');
                        out(:,k)         = [audioObj.freqData(1,k);absOut(:)] .* exp(1i*-cumsum([gdelay(1,k);delayOut])*(bin_dist * 2*pi));
                    end
                    
                case 'abs+phase'
                    for k=1:channels
                        SignalCentAbs    = interp1(freq,   abs(audioObj.freqData(:,k)), fCent);
                        SignalCentPhase  = interp1(freq, unwrap(angle(audioObj.freqData(:,k))), fCent); 
                        signalCentSmoothAbs   = feval(smooth_helper, SignalCentAbs  , span, smooth_opt{:});
                        signalCentSmoothPhase = feval(smooth_helper, SignalCentPhase, span, smooth_opt{:});
                        absOut           = interp1(fCent(2:end), signalCentSmoothAbs(2:end), freq(2:end), 'spline');
                        PhaseOut         = interp1(fCent(2:end), signalCentSmoothPhase(2:end), freq(2:end), 'spline');
                        out(:,k)         = [audioObj.freqData(1,k);absOut(:)] .* exp(1i.*[angle(audioObj.freqData(1,k));PhaseOut]);
                    end
                    
                otherwise
                    error('ITA_SMOOTH:Oh Lord. Unknown data type.')
            end
        case 'LogFreqOctave2'
            % logarithmic frequency domain smoothing (Version 2)
            
            % calculate boundaries of frequency dependant windows
            freq = audioObj.freqVector;
            dist = diff(freq(1:2));
            f_minus_delta_f = freq/(2^(windowWidth/2));
            f_plus_delta_f  = freq*(2^(windowWidth/2));
            lowerBoundaryBins   = floor(f_minus_delta_f/dist);
            upperBoundaryBins   = ceil(f_plus_delta_f/dist);
            % Deal with tails
            k = 1;
            while lowerBoundaryBins(k) < 1
                lowerBoundaryBins(k) = 1;
                k =k+1;
            end
            k = 1;
            while upperBoundaryBins(k) < 1
                upperBoundaryBins(k) = 1;
                k =k+1;
            end
            k = length(freq);
            while lowerBoundaryBins(k) > length(freq)
                lowerBoundaryBins(k) = length(freq);
                k =k-1;
            end
            k = length(freq);
            while upperBoundaryBins(k) > length(freq)
                upperBoundaryBins(k) = length(freq);
                k =k-1;
            end
            
            nBins        = audioObj.nBins;
            channels     = audioObj.nChannels;
            
            absOut = zeros(nBins,channels);
            phaseOut = zeros(nBins,channels);
            delayOut = zeros(nBins,channels);
            
            switch lower(dataType)
                case 'real'
                    ita_verbose_info('ITA_SMOOTH:Only smoothing real part in frequency domain. Imaginary part is dismissed. I hope you know what you are doing!',1);
                    signalReal = audioObj.freqData;
                    for k=1:nBins
                        absOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum( real(signalReal(lowerBoundaryBins(k):upperBoundaryBins(k),:)), 1 );
                    end
                    out = absOut;
                    
                case 'complex'
                    signal = audioObj.freqData;
                    for k=1:nBins
                        absOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum( signal(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1 );
                    end
                    out = absOut;
                    
                case 'abs'
                    signalAbs = abs(audioObj.freqData);
                    for k=1:nBins
                        absOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalAbs(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                    end;
                    out = absOut .* exp(1i*angle(audioObj.freqData));
                    
                case 'gdelay'
                    signalDelay = ita_groupdelay(audioObj);
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                    for k=1:nBins
                        delayOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalDelay(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                    end;
                    delayOut(1,:) = signalDelay(1,:);
                    out = abs(audioObj.freqData) .* exp(1i*-cumsum(delayOut,1)*(bin_dist * 2*pi));
                    
                case 'abs+gdelay'
                    signalAbs = abs(audioObj.freqData);
                    signalDelay = ita_groupdelay(audioObj);
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                    for k=1:nBins
                        absOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalAbs(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                        
                        delayOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalDelay(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                    end
                    delayOut(1,:) = signalDelay(1,:);
                    out = absOut .* exp(1i*-cumsum(delayOut,1)*(bin_dist * 2*pi));
                
                case 'abs+phase'
                    signalAbs = abs(audioObj.freqData);
                    signalPhase = unwrap(angle(audioObj.freqData));
                    for k=1:nBins
                        absOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalAbs(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                        
                        phaseOut(k,:) = 1./(upperBoundaryBins(k)-lowerBoundaryBins(k)+1) .* ...
                            sum(signalPhase(lowerBoundaryBins(k):upperBoundaryBins(k),:), 1);
                    end
                    out = absOut .* exp(1i*phaseOut);

                otherwise
                    error('ITA_SMOOTH:Oh Lord. Unknown data type.')
            end
            
            
        case 'Gammatone'
            % Smoothing based on a Gammatone filter, after
            % J. Breebaart, "The perceptual (ir)relevance of HRTF magnitude
            % and phase spectra", AES 2001
            
            switch dataType
                case 'Real'
                    data = real(audioObj.freqData);                                        
                    ita_verbose_info('ITA_SMOOTH:Only smoothing real part in frequency domain. Imaginary part is dismissed. I hope you know what you are doing!',1);
                                        
                case 'Complex'
                    data = audioObj.freqData;
                                                            
                case 'Abs'
                    data = abs(audioObj.freqData).^2;
                                       
                case 'GDelay'
                    data = ita_groupdelay(audioObj);
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                    
                case 'Abs+GDelay'
                    data_abs = abs(audioObj.freqData).^2;
                    data_gd = ita_groupdelay(audioObj);
                    data = [data_abs data_gd];
                    bin_dist = audioObj.samplingRate/audioObj.nSamples;
                                        
                otherwise
                    error('ITA_SMOOTH:Oh Lord. Unknown data type.')
            end
            
            % Initialize variables
            out = data;
            
            f = audioObj.freqVector;                
            for idx=1:audioObj.nBins
                fc = f(idx);
                b = 24.7*(0.00437*fc + 1)/(2 * sqrt(2^(windowWidth)-1));
                h = (1./(1 + 1i*(f - fc)/b)).^(1/windowWidth);
                
                out(idx,:) = sum(bsxfun(@times,data,abs(h).^2),1)./sum(abs(h).^2,1);
            end
            
            switch dataType
                case 'Real'                    
                    
                case 'Complex'
                    
                case 'Abs'                    
                    out = out.^0.5 .* exp(1i*angle(audioObj.freqData));
                    
                case 'GDelay'
                    out(1,:) = data(1,:);
                    out = abs(audioObj.freqData) .* exp(1i*-cumsum(out,1)*(bin_dist * 2*pi));
                    
                case 'Abs+GDelay'
                    out_abs = out(:,1:end/2);
                    out_gd = out(:,end/2+1:end);
                    out_gd(1,:) = data_gd(1,:);
                    
                    out = out_abs.^0.5 .* exp(1i*-cumsum(out_gd,1)*(bin_dist * 2*pi));
                    
                otherwise
                    error('ITA_SMOOTH:Oh Lord. Unknown data type.')
            end
            
        otherwise
            error('ITA_SMOOTH:I don''t know this smooth method. Check help for a list of valid methods.')
    end
    
    % use input as output to copy all important meta data, then set new
    % data
    result(ind) = audioObj;
    result(ind).(domain)   = out;
    
    
    %% Add history line
    result(ind) = ita_metainfo_add_historyline(result(ind),mfilename,{audioObj, smoothType, windowWidth});
end

%% Find output parameters
varargout(1) = {result};
end %end function