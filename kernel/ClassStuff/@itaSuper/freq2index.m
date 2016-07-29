function [bin, dist] = freq2index(this,varargin)
%Convert Frequency in Hz to bin number
%  This function converts a frequency given in Hz to the approximate index
%  of the corresponding frequency bin.
%  Works also for intervalls, specifing lower and upper frequency limits
%
%  Syntax:
%   index = freq2index(audioObj,frequency)
%   index = freq2index(audioObj,frequency1,frequency2)
%
%  Example:
%   index = freq2bin(audioObj,200)
%
%   See also: freq2value.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_freq2bin">doc ita_freq2bin</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer  -- Email: rsc@akustik.rwth-aachen.de
% Created:  14-Jan-2010

if nargin == 2
    if any(varargin{1} > max(this.freqVector)) % Check for frequency limits
        error('FREQ2INDEX: Frequency is out of range');
    end
    freq = this.freqVector;
    dist = zeros(numel(varargin{1}),1);
    bin  = zeros(numel(varargin{1}),1);

    for idx = 1:numel(varargin{1})
        [dist(idx), bin(idx)] = min(abs(freq-varargin{1}(idx)));
    end
elseif nargin > 2
    bin = this.freq2index(varargin{1}):this.freq2index(varargin{2});
    dist = NaN;
end

end