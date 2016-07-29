function [data, dist] = freq2value(this,varargin)
%Returns data from a given frequency in Hz
%  This function converts a frequency given in Hz to the data of the approximate index
%  Works also for intervalls, specifing lower and upper freq limits
%
%  Syntax:
%   value = freq2data(audioObj,freq)
%   audioObj = freq2bin(audioObj,freq1,freq2)
%
%  Example:
%   audioObj = freq2bin(audioObj,200)
%
%   See also: ita_bin2freq.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_freq2bin">doc ita_freq2bin</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer  -- Email: rsc@akustik.rwth-aachen.de
% Created:  14-Jan-2010

if numel(this.dimensions) > 1
    data = squeeze(eval(['this.freq(this.freq2index(varargin{:}),:' repmat(',:',1,numel(this.dimensions)-1) ');']));
else
    data = this.freq(this.freq2index(varargin{:}),:);
end
if nargout > 1
    [ind,dist] = this.freq2index(varargin{:});
end
end