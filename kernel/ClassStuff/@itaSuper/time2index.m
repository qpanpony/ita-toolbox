function [bin, dist] = time2index(this,varargin)
%TIME2INDEX - Convert Frequency in Hz to bin number
%  This function converts a time given in seconds to the approximate index
%  of the corresponding sample. 
%  Works also for intervalls, specifing lower and upper time limits
%
%  Syntax:
%   index = time2index(audioObj,time)
%   index = time2index(audioObj,time1,time2)
%
%  Example:
%   index = time2bin(audioObj,200)
%
%   See also: time2value.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_time2bin">doc ita_time2bin</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer  -- Email: rsc@akustik.rwth-aachen.de
% Created:  14-Jan-2010

if nargin == 2
    if any(varargin{1} > max(this.timeVector))
        error('TIME2INDEX: Time is out of range');
    end
        
    time = this.timeVector;
    dist = zeros(numel(varargin{1}),1);
    bin  = zeros(numel(varargin{1}),1);

    for idx = 1:numel(varargin{1})
        [dist(idx), bin(idx)] = min(abs(time-varargin{1}(idx)));
    end
elseif nargin > 2
    bin = this.time2index(varargin{1}):this.time2index(varargin{2});
    dist = NaN;
end

end