function [data, dist] = time2value(this,varargin)
%TIME2VALUE - Returns data from a given time in seconds
%  This function converts a time given in seconds to the data of the approximate index
%  Works also for intervalls, specifing lower and upper time limits
%
%  Syntax:
%   value = time2data(audioObj,time)
%   audioObj = time2bin(audioObj,time1,time2)
%
%  Example:
%   audioObj = time2bin(audioObj,200)
%
%   See also: ita_bin2time.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_time2bin">doc ita_time2bin</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer  -- Email: rsc@akustik.rwth-aachen.de
% Created:  14-Jan-2010

if numel(this.dimensions) > 1
    data = squeeze(eval(['this.time(this.time2index(varargin{:}),:' repmat(',:',1,numel(this.dimensions)-1) ');']));
else
    data = this.time(this.time2index(varargin{:}),:);
end
if nargout > 1
    [ind,dist] = this.time2index(varargin{:});
end
end