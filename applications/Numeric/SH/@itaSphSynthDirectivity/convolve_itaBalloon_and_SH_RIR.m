function out_m = convolve_itaBalloon_and_SH_RIR(this, balloon, varargin)
%
% Convolves a target-directivity (an itaBalloon-object) and the impulse
% responses of abstract directivities with the form of spherical harmonic
% basefunctions.
% see also: makeSHfilter and SHfilter2SHrir
%
% input: 
% - balloon : target - directivity - function
%
% options: 
% 'channels'       you can choose one ore multiple channels (directivity of a
%                  multichannel itaBalloon will be sumed up).
% 'mpb_filter'     result will be band widhth filtered by ita_mpb_filter
% 'rotate'         here you can give a set of euler rotation angles to rotate the input balloon. 
%                  The output will be an array of filters- one for each
%                  position
%                  'rotate', {[orientation 1], [orientation 2], ... }
sArgs = struct('channels',1:balloon.nChannels,'rotate',zeros(1,3));
if nargin > 2
    sArgs = ita_parse_arguments(sArgs, varargin);
end

if ~isdir([this.folder filesep 'SH_RIR']) || ~numel(dir([this.folder filesep 'SH_RIR' filesep '*.ita']))
    error('First proceed itaSphSyntDirectivity.SHfilter2SHrir');
end

if ~iscell(sArgs.rotate), sArgs.rotate = {sArgs.rotate}; end
for idxR = 1:length(sArgs.rotate)
    if size(sArgs.rotate{idxR},2)~=3, error('size(rotatate,2) != 3 (euler angle)'); end
end

% target's directivity
ao = balloon.idxCoefSH2itaAudio(1:this.mFilterData.dimension(3),'channels',sArgs.channels,'sum_channels', true);
ao.dataType = this.precision;

if balloon.fftDegree ~= this.array.fftDegree
    error('I can not handle different fftDegrees. Please use itaBalloon.convert_fftDegree as work arround.');
end

% synthesised abstract room impulse responses
nMic = numel(dir([this.folder filesep 'SH_RIR' filesep 'SH_RIR_Mic*.ita']));

out = itaAudio(length(sArgs.rotate),nMic);
for idxM = 1:nMic
    RIR  = ita_read([this.folder filesep 'SH_RIR' filesep 'SH_RIR_Mic' int2str(idxM) '.ita']);
    for idxR = 1:length(sArgs.rotate)
        out(idxR, idxM) = itaAudio('dataType', this.precision, 'signalType', 'energy','samplingRate', this.array.samplingRate);
        ao2 = ao;
        if strcmpi(this.SHType, 'complex')
            ao2.freqData = ita_sph_rotate_complex_valued_spherical_harmonics(ao.freqData.',sArgs.rotate{idxR}).';
        elseif strcmpi(this.SHType, 'real')
            ao2.freqData = ita_sph_rotate_real_valued_spherical_harmonics(ao.freqData.',sArgs.rotate{idxR}).';
        else
            error('unknown SHType');
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
        out(idxR, idxM) = sum(ita_multiply_spk(ao2,RIR));
        
        %adapt latency samples
        if balloon.latencySamples ~= this.array.latencySamples
            out(idxR, idxM) = ita_time_shift(out(idxR, idxM), balloon.latencySamples - this.array.latencySamples, 'samples');
        end
        
        out(idxR, idxM).channelNames{1} = '';
        out(idxR, idxM).comment = ['synthesized RIR of ' balloon.name ' (mic: ' int2str(idxM) ')'];
    end
end

out_m = itaAudio(length(sArgs.rotate),1);
for idxR = 1:length(sArgs.rotate)
    out_m(idxR) = merge(out(idxR,:));
    out_m(idxR).history = {' '};
end