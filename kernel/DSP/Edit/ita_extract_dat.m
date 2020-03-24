function [ varargout ] = ita_extract_dat( varargin )
%ITA_EXTRACT_DAT - Extract first power of samples in time domain.
%   Extract as many samples as to fit the next lower power of two
%   or number specified by FFT degree.
%
%   Syntax: audioObj = ita_extract_dat( audioObj ) extract half of the samples.
%   Syntax: audioObj = ita_extract_dat( audioObj, FFTdegree )
%   Syntax: audioObj = ita_extract_dat( audioObj, nSamples )
%   Syntax: audioObj = ita_extract_dat( audioObj, nSamples , Options)
%
%
%   FFTdegree is up to a value of 30
%   nSamples is a value greater than 30
%
%   Options (default):
%
%   firstsample (1):        if firstsample is given, the sequence extracted from 
%                           that position in the original data 
%   random (false):         the sequence is extracted with a random first sample
%   forcesamples (false):   use nSamples even if values is smaller that 30
% 
%   Examples:
%   c = ita_extract_dat(c,12);
%   c = ita_extract_dat(c,50);
%   c = ita_extract_dat(c,'firstsample');
%   c = ita_extract_dat(c,'symmetric'); used for acausal impulse responses
%
%   See also ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_write, 
%   ita_fft, ita_ifft, ita_make_header.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_extract_dat">doc ita_extract_dat</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  16-Jun-2008

%% Initialization
narginchk(1,10);

if isa(varargin{1},'itaAudio')
    asData = varargin{1}.';
else
    error('ITA_EXTRACT_DAT:InputParameters','First input argument must be an itaAudio object.');
end

if max(size(asData)) > 1
    for idx = 1:numel(asData)
        % MMT: this seems to be the easiest way to make this work
        if isnumeric(varargin{2})
            optionStr = num2str(varargin{2});
        else
            optionStr = ['''' varargin{2} ''''];
        end
        for iVar = 3:numel(varargin)
            if isnumeric(varargin{iVar})
                optionStr = [optionStr ',' num2str(varargin{iVar})]; %#ok<*AGROW>
            else
                optionStr = [optionStr ',''' varargin{iVar} ''''];
            end
        end
        eval(['result(idx) = ita_extract_dat(asData(idx),' optionStr ');']);
    end
    varargout{1} = result;
    return;
end
    
    

fft_degree = [];
if nargin >= 2
    if isscalar(varargin{2})
        fft_degree = varargin{2};
    else
        error('ITA_EXTRACT_DAT:InputParameters','Second input argument must be a scalar.');
    end
end
    
sArgs = struct('firstsample',1,'random',false,'forcesamples',false,'symmetric',false); 
if nargin > 2
    [sArgs] = ita_parse_arguments(sArgs,varargin(3:end));
end

%% Precalculation - Reduce Number of Samples
%how many samples are required?
if ~isempty(fft_degree)
    if (fft_degree <= 30) & ~sArgs.forcesamples %#ok<AND2> %this is really FFT degree
        new_number_samples = round(2^fft_degree) + mod(round(2^fft_degree),2); % RSC - prevent odd number of samples
    else %fft degree greater than 30? this is for sure the number of samples
        new_number_samples = fft_degree;
    end
    number_samples  = asData.nSamples;
    
    if sArgs.random %Random starting value
        if sArgs.firstsample > 1
            ita_verbose_info('ITA_EXTRACT_DAT:Options random and firstsample set. I hope you know what you are doing. Ignoring firstsample, using random!',0);
        end
        sArgs.firstsample = 1+round(rand(1)*(number_samples-new_number_samples-1));
    end
    
    if (sArgs.firstsample-1) + number_samples < new_number_samples
        ita_verbose_info('ITA_EXTRACT_DAT:I will call ita_extend_dat for you.',2);
        varargout{1} = ita_extend_dat(asData,sArgs.firstsample+new_number_samples-1,'symmetric',sArgs.symmetric); %call the counterpart function
        return;
    end
else
    number_samples     = asData.nSamples-(sArgs.firstsample-1);
    new_number_samples = 2^nextpow2(number_samples./2);
end

%% Reduce data now
if sArgs.symmetric %pdi added
    if new_number_samples < 30
        new_number_samples = 2.^new_number_samples;
    end
    part1  = ita_extract_dat(asData,ceil(new_number_samples./2));
    part2  = ita_time_reverse(ita_extract_dat(ita_time_reverse(asData),floor(new_number_samples./2)));
    asData = ita_append(part1, part2);
else %normal case, non-symmetric
    asData.timeData = asData.timeData(sArgs.firstsample+(0:round(new_number_samples)-1),:);
end

%% Add history line
asData = ita_metainfo_add_historyline(asData,'ita_extract_dat',varargin);

%% Find appropriate Output paramters
varargout{1} = asData;
