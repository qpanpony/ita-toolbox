function varargout = ita_beam_simulate(varargin)
%ITA_BEAM_SIMULATE - simulate beamforming for a given algorithm
%  This function simulates beamforming with a given array and algorithm.
%  The user can specify the position and level of a number of monopole
%  sources and select the beamforming algorithm and the result will be
%  displayed for several frequencies or, if an output variable was
%  specified, the result will be returned.
%  If an option 'SNR' is specified, spatially white noise will be added to
%  all channels, with the argument specifying the signal to noise ratio.
%
%  Syntax: result = ita_beam_simulate(array,options)

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%  Options (default):
%   'source'        (itaMicArray([0.2,0.2,-1],'cart'))      : define a source with coordinates and linear sound power (in source.w)
%   'type'          (ita_beam_evaluatePreferences('Method') : which method to use for the beamforming calculations
%   'soundspeed'    (double(ita_constants('c')))            : speed of sound 
%   'SNR'           (Inf)                                   : create data with specified SNR
%   'sigmaArray'    (0)                                     : add microphone displacements to simulate unknown mic positions
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_simulate">doc ita_beam_simulate</a>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  03-Feb-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_array','itaMicArray','source',itaMicArray([0.2,0.2,-1],'cart'),'type',ita_beam_evaluatePreferences('Method'),'SNR',Inf,'sigmaArray',0,'soundspeed',double(ita_constants('c')),'wavetype',ita_beam_evaluatePreferences('SteeringType'));
[array,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Body
d = abs(mean(array.z)-mean(sArgs.source.z)); % distance between array and sources
width_max = max(4*max(abs([sArgs.source.x(:).',sArgs.source.y(:).'])),0.1*ceil(10*tan(20*pi/180)*2*d)); % maximum scan width for 20 degree opening angle
N = min(625,((ceil(ceil(width_max/0.01)/2)*2)+1)^2); % number of scanpoints
resolution = 1e-3*round(1e3*width_max/(sqrt(N)-1)); % resolution in x,y directions
% create a mesh of scanpoints
Scanmesh = ita_beam_makeArray('grid','Nx',sqrt(N),'Ny',sqrt(N),'dx',resolution,'dy',resolution);
Scanmesh.z = mean(sArgs.source.z);

frac = 1/12;
freqs = ita_ANSI_center_frequencies([200 10000],1/frac); % 1/12th octave band centre frequencies
k     = 2*pi.*freqs./sArgs.soundspeed;
nChannels = array.nPoints;
nFreqs = numel(freqs);

%% pressure from monopole sources
p = itaResult();
p.freqVector = freqs;
freqData = zeros(nFreqs,nChannels);

amplitudes = sArgs.source.w(:);
% if there are several sources make them incoherent by applying random
% phase
if numel(sArgs.source.w) > 1
    amplitudes = amplitudes.*exp(1i*2*pi.*rand(numel(sArgs.source.w),1));
    for i=1:nFreqs % for each frequency
        % create pressure vector as superposition of all sources
        freqData(i,:) = sum(bsxfun(@times,amplitudes,squeeze(ita_beam_steeringVector(k(i),array.cart,sArgs.source.cart,2)).'));
    end
else
    for i=1:nFreqs % for each frequency
        % create pressure vector for the single source
        freqData(i,:) = amplitudes.*squeeze(ita_beam_steeringVector(k(i),array.cart,sArgs.source.cart,2)).';
    end
end

p.freq = freqData;

% spatially white noise for given sArgs.SNR
if sArgs.SNR < 100
    sigma = 10^(-sArgs.SNR/20);
    noise = itaAudio([nChannels,1]);
    for i = 1:nChannels
        noise(i) = ita_generate('noise',1,44100,16);
    end
    noise = merge(noise);
    noise_sm = ita_smooth(noise','LogFreqOctave1',1/3,'Abs');
    ids = noise.freq2index(freqs);
    N = noise.freq(ids,:);
    N_sm = noise_sm.freq(ids,:);
    SN = sqrt(mean(abs(p.freq).^2)./mean(abs(N_sm).^2));
    sigma = sigma.*SN;
    N = bsxfun(@times,sigma,N);
    sArgs.SNR = 10.*log10(mean(mean(abs(p.freq).^2)./mean(abs(N).^2))) %#ok<NOPRT>
    p.freq = p.freq + N;
end

p.channelNames{1} = 'Simulation';
p.channelUnits{1} = 'Pa';
p.channelCoordinates = itaCoordinates(nChannels);
p.channelOrientation = itaCoordinates(nChannels);
p.channelSensors{1} = '';
p.channelUserData = cell(nChannels,1);
p.channelNames = repmat(p.channelNames(1),1,nChannels);
p.channelUnits = repmat(p.channelUnits(1),1,nChannels);
p.channelSensors = repmat(p.channelSensors(1),1,nChannels);
p.userData = {'nodeN',array.ID(:)};

%% array imperfections
array.cart = array.cart + sArgs.sigmaArray.*randn(size(array.cart));

%% do the beamforming
result = ita_beam_beamforming(array,p,Scanmesh,'type',sArgs.type,'wavetype',sArgs.wavetype);

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_beam_simulate','ARGUMENTS');

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting
    figure;
    ita_plottools_aspectratio(1);
    h = 2; v= 3;
    plotFreqs = [250,500,1000,2000,4000,8000];
    source_vecs = sArgs.source.cart.';
    freqData = permute(result.freq,[2 3 1]);
    freqData = freqData./repmat(max(max(abs(freqData))),size(freqData,1),size(freqData,2));
    result.freq = permute(freqData,[3 1 2]);
    result.channelUnits(:) = {''};
    for i=1:numel(plotFreqs)
        subplot(v,h,i);
        ita_plot_2D(result,plotFreqs(i),'plotType','mag','plotRange',[-10,0],'newFigure',false);
        hold on;
        plot(source_vecs(1,:),source_vecs(2,:),'+w','LineWidth',2);
        hold off;
        title(['Frequency: ' num2str(plotFreqs(i)) ' Hz'],'FontSize',16);
        xlabel('X (m)','FontSize',16);
        ylabel('Y (m)','FontSize',16);
        axis square
        set(gca,'FontSize',16,'XTick',-1:0.5:1,'YTick',-1:0.5:1);
        box
    end
else
    % Write Data
    varargout(1) = {result}; 
    if nargout > 1
        varargout(2) = {p};
    end
end

%end function
end