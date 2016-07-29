function varargout = ita_make_filter(varargin)
%ITA_MAKE_FILTER - Make filter in frequency domain
%
%  This function generates an audioObj containing a filter generated 
%  with ita_mpb_filter. The output is in time domain!
%
%  FFTdegree is up to a value of 30!
%  nSamples is a value greater than 30!
%
%  Syntax: audioObj = ita_make_filter([f0,f1],SamplingRate,nSamples)
%  Syntax: audioObj = ita_make_filter([f0,f1],SamplingRate,FFTdegree)
%  Syntax: audioObj = ita_make_filter([f0,f1],header)
%
%  ita_make_filter([f0,f1],header) makes a filter in frequency domain
%  according to the values of the SamplingRate, FFTdegree & nSamples 
%  existent in the header.
%
%  Examples:    c = ita_make_filter([100 1000],44100,20);
%               c = ita_make_filter([100 1000],44100,31);
%               c = ita_make_filter([100 1000],c.header); 
%
%  See also ita_mpb_filter, ita_minimumphase, ita_zerophase, ita_multiply_spk.
%
%  Reference page in Help browser <a href="matlab:doc ita_make_filter">doc ita_make_filter</a>
%
%  Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%  Created: 19-Sep-2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%  TODO % delete splitting of header and data



%% Initialization
FFT_DEGREE_FILTER = 14; %used to get an impulse for time domain filtering

narginchk(2,20);
filt_vec   = varargin{1};
if (nargin >= 3) && ~ischar(varargin{3}) %samples and rate are given
    sr       = varargin{2};
    nSamples = varargin{3};
    var_start = 4;
elseif isa(varargin{2},'itaAudio')
    as = varargin{2};
    sr       = as.samplingRate;
    nSamples = as.nSamples;
    if nSamples < 30 %FFT degree is given!
        nSamples = 2.^(nSamples);
    end
    var_start = 3;
else
    error('ita_make_filter:See Syntax.')
end

%% generate filter
%make impulse
imp = ita_generate('impulse',1,sr,FFT_DEGREE_FILTER); % use fft_degree and resize afterwards, performance reason
imp.signalType = 'energy';
for idx = 1:length(imp.channelUnits)
   imp.channelUnits{idx} = '';
end
if nargin >= var_start
    filt = ita_mpb_filter(imp,filt_vec,varargin{var_start:end});
else
    filt = ita_mpb_filter(imp,filt_vec);
end
filt = ita_extend_dat(filt,nSamples);

%% Update header settings
filt = ita_metainfo_rm_channelsettings(filt);
filt.comment = 'Filter';

%% Add history line
filt = ita_metainfo_rm_historyline (filt,'all');
filt = ita_metainfo_add_historyline(filt,mfilename,varargin);

%% Find output parameters
varargout(1) = {filt};

%end function
end