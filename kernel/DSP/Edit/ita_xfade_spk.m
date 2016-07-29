function varargout = ita_xfade_spk(varargin)
%ITA_XFADE_SPK - Crossfade two spectra in a given frequency range
%  This function crossfades the spectra of two itaAudio objects in a given
%  freqency range with a raised cosine filter and returns the result as a
%  new itaAudio object.
%
%  Syntax: itaAudio = ita_xfade_spk(itaAudio,itaAudio,xfade_vec)
%
%  Examples:
%   xfaded_audio     =   ita_xfade_spk(a_audio,b_audio,[500 1000])
%
%   See also ita_mpb_filter.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_xfade_spk">doc ita_xfade_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  03-Mar-2009 


%% Initialization and Input Parsing
narginchk(3,3);
sArgs        = struct('pos1_a','itaAudioFrequency', 'pos2_b','itaAudioFrequency','pos3_xfade_vec','integer');
[a,b,xfade_vec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% check for single frequency input
if length(xfade_vec) == 1
   xfade_vec = [xfade_vec, xfade_vec]; 
end

%% Prep 
f0  =   xfade_vec(1,1);
if f0 >= a.samplingRate/2
    if ita_verbose_info('Crossfade Frequency too high, just returning input A.', 1)
        varargout(1) = {a};
        return;
    end
end
f1  =   min(xfade_vec(1,2),a.samplingRate/2); %pdi: maximum is Nyquist

fsa     =   a.samplingRate;
fsb     =   b.samplingRate;

if fsa~=fsb
    %% TODO: Resample
    error('Not the same samplerate');
else
    fs  =   fsa; %Samplingrate
end

bin_dist=   fs ./ (2 * (a.nBins - 1));

bin0    =   round(f0/bin_dist)+1;
bin1    =   round(f1/bin_dist)+1;
bins    =   bin1-bin0;
if bins %normal case
    win      =   window(@hann,2*bins+1);
    leftwin  =   win(1:ceil(end/2)).';
    rightwin =   win(ceil(end/2):end).';
else %only one frequency not a range
    leftwin  = 0.5;
    rightwin = 0.5;
end
rightwin = repmat(rightwin.',1,a.nChannels);
leftwin  = repmat(leftwin.' ,1,a.nChannels);

a.freqData(bin0:bin1,:)   =   a.freqData(bin0:bin1,:).*rightwin;
a.freqData(bin1+1:end,:)  =   0;
b.freqData(1:bin0-1,:)    =   0;
b.freqData(bin0:bin1,:)   =   b.freqData(bin0:bin1,:).*leftwin;

result  =   a + b;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};

%end function
end