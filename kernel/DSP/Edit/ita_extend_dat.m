function [ varargout ] = ita_extend_dat( varargin )
%ITA_EXTEND_DAT - Extend first power of samples in time domain.
%                 Counterpart to ita_extract_dat.
%
%   Syntax: ita_extend_dat( dat ) %- the signal is extended twice.
%   Syntax: ita_extend_dat( dat, FFTdegree, Options)
%   Syntax: ita_extend_dat( dat, nSamples, Options)
%   Syntax: [dat1, dat2] = ita_extend_dat( dat1, dat2 )
%
%   FFTdegree is up to a value of (including) 35
%   nSamples is a value greater than 35
%
%       Options (default):
%           'forcesamples' (false):      Interpret second arguments as samples, even if lower than 35
%           'symmetric' (false):         Used for acausal impulse responses
%
%   If called with two AudioSignals, it will extend the shorter one to the size of the longer one
%
%   See also ita_extract_dat, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_extend_dat">doc ita_extend_dat</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  16 Jun 2008


%% Initialization
make_same_length = false;

if nargin == 1
    sArgs   = struct('pos1_a','itaAudioTime','symmetric',false,'nozero',false); %only itaAudio given, symmetric flag necessary
    [asData, sArgs] = ita_parse_arguments(sArgs,varargin); 
    new_number_samples = 2^(nextpow2(asData.nSamples)+1);
else
    if isa(varargin{2},'itaAudio') %If we have two Audios we will make them the same length
        sArgs   = struct('pos1_a','itaAudioTime','pos2_b','itaAudioTime','symmetric',false,'nozero',false); %pdi: forcesamples???
        [asData, asData2, sArgs] = ita_parse_arguments(sArgs,varargin);
        make_same_length = true;
    else %this is the normal case...
        sArgs   = struct('pos1_a','itaAudioTime','pos2_num','integer','forcesamples',false,'symmetric',false,'nozero',false);
        [asData, new_number_samples, sArgs] = ita_parse_arguments(sArgs,varargin);
    end
end

%% Extend Number of Samples
%how many samples are needed?
if make_same_length
    length  = max([asData.nSamples asData2.nSamples]); %Find maximum length
    asData  = ita_extend_dat(asData, length,'symmetric',sArgs.symmetric); %Extend both to maximum length
    asData2 = ita_extend_dat(asData2,length,'symmetric',sArgs.symmetric);
    asData  = ita_metainfo_rm_historyline(asData); %Remove History Entry for this operation
    asData2 = ita_metainfo_rm_historyline(asData2);
else
    if sArgs.symmetric %pdi added
        if new_number_samples <= 35
            new_number_samples = round(2.^new_number_samples/2)*2;
        end
        old_number_samples = asData.nSamples;
        part1 = ita_extend_dat(ita_extract_dat(asData,old_number_samples/2),new_number_samples./2);
        part2 = ita_time_reverse(ita_extend_dat(ita_extract_dat(ita_time_reverse(asData),old_number_samples/2),new_number_samples./2));
        asData = ita_append(part1, part2);
    else
        if new_number_samples <= 35 && ~sArgs.forcesamples %this is really the FFT degree
            new_number_samples = round(2.^new_number_samples/2)*2;
        end
        if asData.nSamples > new_number_samples
            ita_verbose_info('ITA_EXTEND_DAT:I will call ita_extract_dat for you.',2);
            varargout{1} = ita_extract_dat(asData,new_number_samples,'symmetric',sArgs.symmetric); %call the counterpart function %bugfix,pdi instead of fftdegree
            return;
        end
        
        %extend data
        number_zeros           = new_number_samples - asData.nSamples;
        newSize = size(asData.time);
        newSize(1) = new_number_samples;
        if sArgs.nozero
            asData.time             = [asData.time; bsxfun(@times,ones(newSize,asData.dataTypeOutput),asData.time(end,:))];
        else %normal case
            tmp = zeros(newSize,asData.dataTypeOutput);
            tmp(1:asData.nSamples,:)             = asData.time;
            asData.time = tmp;
        end
        
    end
end


%% Add history line
asData = ita_metainfo_add_historyline(asData,'ita_extend_dat',varargin);

if exist('asData2','var')
    asData2 = ita_metainfo_add_historyline(asData2,'ita_extend_dat',varargin);
end

%% Find appropriate Output paramters
varargout{1} = asData;
if nargout == 2 && make_same_length
    varargout{2} = asData2;
end
end
