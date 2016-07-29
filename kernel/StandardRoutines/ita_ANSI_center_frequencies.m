function varargout = ita_ANSI_center_frequencies(varargin)
%ITA_ANSI_CENTER_FREQUENCIES - Get ANSI center frequencies
%  This function takes calculated center frequencies and converts them to
%  the next ANSI center frequencies
%
%  Syntax:
%   freq_vec = ita_ANSI_center_frequencies([f_min f_max],bandsPerOctave)
%   [freq_vec exactFrequencies] = ita_ANSI_center_frequencies([f_min f_max],bandsPerOctave)
%
%  Example:
%   freq_vec = ita_ANSI_center_frequencies([20 20000],3)
%
%   See also: ita_mpb_filter.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_ANSI_center_frequencies">doc ita_ANSI_center_frequencies</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: dietrich  -- Email: pdi@akustik.rwth-aachen.de
% Created:  04-Aug-2009

% Reference:
%   - ANSI S1.6-R2006 Preferred Frequencies, Frequency Levels, and
%      Band Numbers for Acoustical Measurements, 1984.

%% Initialization and Input Parsing
if nargin == 0
    f_limits = ita_preferences('freqRange');
    bands    = ita_preferences('bandsperoctave');
    samplingRate = ita_preferences('samplingRate');
else
    narginchk(2,10);
    if nargin == 1 % only samplingRate or freqVec given
        token  = varargin{1};
        if length(token) == 1 % get global freq limits
            samplingRate = token;
            f_limits = ita_preferences('freqRange');
        else % get global samplingRate
            samplingRate = ita_preferences('samplingRate');
            f_limits = token;
        end
        bands = ita_preferences('bandsperoctacve');
    elseif nargin == 2 % samplingRate/freqRange and bandsperoctave given
        if numel(varargin{1}) == 2
            f_limits = varargin{1};
            samplingRate = ita_preferences('samplingRate');
        else
            f_limits = ita_preferences('freqRange');
            samplingRate = varargin{1};
        end
        bands    = varargin{2};
    else % everything given
        f_limits = varargin{1};
        bands    = varargin{2};
        samplingRate = varargin{3};
    end
end
f_limits = [f_limits(1) min(f_limits(2),samplingRate/2*2^(-1/bands/2))];

%% convert
Nmax = round(bands*(log2(f_limits(2)/1000))+1);
Nmin = round(bands*(log2(1000/f_limits(1)))+1);

% freq_vecEx = 1000 * 10.^([-Nmin:Nmax]*3./(10*bands)); % mgu: nicht mehr basis 10^(3/10)
freq_vecEx = 1000 * 2.^((-Nmin:Nmax)./(bands)); % immer basis 2

freq1   = ita_sd_round(freq_vecEx, 5);
freq2   = ita_sd_round(freq_vecEx, 100);

% idx=find(abs(100*(1-freq1./freq2)) < 1.01);
idx=find(abs(100*(1-freq1./freq2)) < 4); % an pdi: 4% scheint hier gut zu sein. nur die 155 Hz werden nicht auf 160 sondern auf 200 gerundet!

freq_vec      = freq1;
freq_vec(idx) = freq2(idx);

%  versuch mgu
% freq5  = ita_sd_round(freq_vecEx, 5);
% freq10  = ita_sd_round(freq_vecEx, 10);
% freq100   = ita_sd_round(freq_vecEx, 100);
%
% idxTake100 = find(abs(100*(1-freq100./freq_vecEx)) < 2);
% idxTake10 = find(abs(100*(1-freq10./freq_vecEx)) < 0.8); % hier ist Grenze unklar:
%                                                             31.5 soll auf die .5 gerundet werde, 62.5 soll aber auf 63 gerundet werden.
%                                                             Abweichung von exakt in beden fällen aber gleich( 0.8%)
% freq_vec      = freq5;
% freq_vec(idxTake10) = freq10(idxTake10);
% freq_vec(idxTake100) = freq100(idxTake100);


%% remove center frequencies out of the specified range
idxValidFreq = freq_vecEx > f_limits(1)*2^(-0.5/bands) & freq_vec < f_limits(2)*2^(0.5/bands);

% Write Data
varargout(1) = {freq_vec(idxValidFreq)};

if nargout == 2
    varargout{2} = freq_vecEx(idxValidFreq);
end


%end function
end

function A2 = ita_sd_round(A,mult)
N = 3;

% Digit furthest to the left of the decimal point
D1   = ceil(log10(abs(A)));
buf1 = D1( abs(A)-10.^D1 == 0)+1;
D1( abs(A)-10.^D1 == 0) = buf1;

% rounding factor
dec=10.^(N-D1);

% Rounding Computation
buf=dec./mult;
A2=1./buf.*round(buf.*A);
A2(A==0)=0;
end
