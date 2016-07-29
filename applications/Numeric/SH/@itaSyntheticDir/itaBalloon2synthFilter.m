function out = itaBalloon2synthFilter(this,balloon,varargin)
% function out = itaBalloon2synthFilter(this,balloon,varargin)
%
% returns a filter that synthesises a directivity, specified by an
% itaBalloon object 'balloon'
% after that, just use "itaSyntheticDir.convolve_filter_and_measurement" to
% get wonderful results
%
% options: 
% 'channels'       you can choose one ore multiple channels (directivity of a
%                  multichannel itaBalloon wil be sumed up).
% 'freqRange',    frequency range of synthesis (will be extended internally
%                  to have space for some filters)
% 'mpb_filter'     result will be band widhth filtered by ita_mpb_filter
% 'optimize_freq_range' choose a not to big range for optimization steps 
%                  (better choose some high frequencies)
% 'encoded'        use spherical encoding of the speaker array
% 'nmax'           maximum order of synthesis
%
% 'rotate'         here you can give a set of euler rotation angles to rotate the input balloon. 
%                  The output will be an array of filters- one for each
%                  position
%                  'rotate', {[orientation 1], [orientation 2], ... }
sArgs = struct('channels',1:balloon.nChannels, 'nmax', this.nmax, 'optimize_freq_range', [],...
    'freqRange', this.freqRange, 'encoded', false, 'rotate',[]);

if ~isa(balloon,'itaBalloon')
    error('Please give me an itaBalloon!');
end

if nargin > 2
    sArgs = ita_parse_arguments(sArgs,varargin);
end

% adapt balloon's fftdegree
if balloon.fftDegree ~= this.speaker.fftDegree
    convertBalloon = true;
    if exist([balloon.balloonFolder '_d' filesep balloon.name '.mat'],'file')
        son = balloon.read([balloon.balloonFolder '_d' filesep balloon.name]);
        if son.fftDegree == this.speaker.fftDegree;
            convertBalloon = false;
            balloon = son;
        end
    end
    
    if convertBalloon
        balloon = balloon.convert_fftDegree(this.speaker.fftDegree, [balloon.balloonFolder '_d']);
    end
end

% indicees of frequency range (do a bit more, to have space for windowing)
idFreqMinMax = this.freq2idxFreq(sArgs.freqRange .* [1/sqrt(2) sqrt(2)]);
inputData = balloon.freq2coefSH(this.freqVector(idFreqMinMax(1):idFreqMinMax(2)), 'nmax', sArgs.nmax, 'normalized');
inputData = squeeze(sum(inputData,2)).';

if isempty(sArgs.rotate), sArgs.rotate = {zeros(1,3)}; end
out = itaAudio(length(sArgs.rotate),1);

for idxR = 1:length(sArgs.rotate)
    
    % eventually rotate the target function
    if sum(sArgs.rotate{idxR})
        actInputData = ita_sph_rotate_realvalued_basefunc(inputData.', sArgs.rotate{idxR}).';
    else
        actInputData = inputData;
    end
    
    % calculate frequency dependent weights for all speakers
    out(idxR) = this.freqData2synthesisRule(actInputData, idFreqMinMax,...
        'optimize_freq_range',sArgs.optimize_freq_range, 'encoded',sArgs.encoded, 'nmax', sArgs.nmax);
    
    % deEqualize input data
    if ~isempty(balloon.sensitivity)
        out(idxR).freqData = out(idxR).freqData * balloon.sensitivity.value;
    end
    
    % timeShift: prepare compensation of difference of latencysamples
    % (will be done in the convolve function)
    arg = struct('timeShift', balloon.latencySamples - this.speaker.latencySamples, 'euler_angle', sArgs.rotate{idxR});
    out(idxR).userData = {arg};
    
    % weights -> filter (via polynomial smoothing)
    out(idxR) = this.synthesisRule2filter(out(idxR), 'method','polyfit','waitbar',false,'extend_only',true); %achtung: normalerweise glätten!
    
end
end