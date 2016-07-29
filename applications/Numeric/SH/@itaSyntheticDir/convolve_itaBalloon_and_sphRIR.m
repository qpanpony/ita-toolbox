function out = convolve_itaBalloon_and_sphRIR(this, balloon, filemask, varargin)

% options: 
% 'channels'       you can choose one ore multiple channels (directivity of a
%                  multichannel itaBalloon will be sumed up).
% 'mpb_filter'     result will be band widhth filtered by ita_mpb_filter
% 'rotate'         here you can give a set of euler rotation angles to rotate the input balloon. 
%                  The output will be an array of filters- one for each
%                  position
%                  'rotate', {[orientation 1], [orientation 2], ... }
sArgs = struct('channels',1:balloon.nChannels, 'mpb_filter',[], 'rotate',zeros(1,3));
if nargin > 3
    sArgs = ita_parse_arguments(sArgs, varargin);
end
if ~iscell(sArgs.rotate), sArgs.rotate = {sArgs.rotate}; end
for idxR = 1:length(sArgs.rotate)
    if size(sArgs.rotate{idxR},2)~=3, error('size(rotatate,2) != 3 (euler angle)'); end
end
 
    
RIR = ita_read([this.folder filesep 'sphRIR' filesep filemask 'sphRIR.ita']);
ao = balloon.idxCoefSH2itaAudio(1:RIR.nChannels,'channels',sArgs.channels,'sum_channels', true);
ao.dataType = 'single';

% kill silent sph
maxValue = max(max(abs(ao.freqData)));
ao.freqData(:, max(abs(ao.freqData),[],1) < maxValue*1e-3) = 0;

if balloon.samplingRate ~= this.speaker.samplingRate
    error('help me, I can not handle different samplingRates. maybe you could code that');
end

out = itaAudio(length(sArgs.rotate),1);
for idxR = 1:size(sArgs.rotate,1)
    out(idxR).signalType = 'energy';
    out(idxR).dataType = 'single';
    ao2 = ao;
    if sum(sum(abs(sArgs.rotate{idxR})))
        ao2.freqData = ita_sph_rotate_realvalued_basefunc(ao.freqData.',sArgs.rotate{idxR}).';
    end
    % adapt data
    if ao2.nSamples < RIR.nSamples
        ao2 = ita_time_window(ao2, round(ao2.nSamples/2+[-0.005*ao2.samplingRate 0]),'samples','symmetric');
        ao2 = ita_extend_dat(ao2, RIR.nSamples,'symmetric');
    else
        ao2 = ita_extract_dat(ao2, RIR.nSamples,'symmetric');
        ao2 = ita_time_window(ao2, round(ao2.nSamples/2+[-0.005*ao2.samplingRate 0]),'samples','symmetric');
    end
    
    %convolve and add
   	out(idxR) = sum(ita_multiply_spk(ao2,RIR));
    %adapt latency samples
    if balloon.latencySamples ~= this.speaker.latencySamples
        out(idxR) = ita_time_shift(out(idxR), balloon.latencySamples - this.speaker.latencySamples, 'samples');
    end
    
   
    out(idxR).channelNames{1} = '';
    out(idxR).comment = ['synthesized RIR of ' balloon.name ' (mic: ' filemask ')'];
    out(idxR).history = {' '};
    
    
end