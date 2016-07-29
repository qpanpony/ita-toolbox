function out = ita_sph_window(B,limits)
%ITA_SPH_WINDOW - Window Sph. Harmonic Coefficients
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_sph_window(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_sph_window(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_window">doc ita_sph_window</a>

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  10-May-2011 


if nargin == 1
    return
elseif nargin == 2
    if length(limits) ~= 2
        error('Please give a vector with lower and upper limit for the window.')
    end
    
    if isa(B,'itaSuper')
        [n,m] = ita_sph_linear2degreeorder(1:B.nChannels);
        flag = 1;
    elseif isscalar(B)
        d = ita_sph_degreeorder2linear(B);
        [n,m] = ita_sph_linear2degreeorder(1:d);
        flag = 0;
    else
        error('First argument must be either an itaSuper or a scalar.');
    end
else
    error('Too many input arguments');
end



A = itaAudio(ones((n(end)+1)*100,1), 100, 'time');
if any(limits > A.trackLength.value)
    limits(limits > A.trackLength.value) = A.trackLength.value;
end
win = ita_time_window(A,limits,'time');
win = interp1(win.timeVector,win.timeData,0:n(end));
win = win(n+1);

if flag
    B.freqData = bsxfun(@times,B.freqData,win);
    out = B;
else
    out = win;
end

%end function
end