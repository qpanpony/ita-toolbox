function [z,p,k] = ita_zpk_warp(z,p,k,lambda)
%ITA_ZPK_WARP - perform warping operation on zeros, poles and gain
%  This function ..
%
%  Syntax:
%   audioObjOut = ita_zpk_warp(audioObjIn, options)
%
%
%  Example:
%   audioObjOut = ita_zpk_warp(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zpk_warp">doc ita_zpk_warp</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  02-Sep-2010 
% Modified by 
%  Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  08-Mar-2019


dc_p = (prod(abs(1 - p)));
dc_z = (prod(abs(1 - z)));

% based on dewarping
% ita_audio_warp implements the dewarping formula, thus here the same is
% used
z = (1 - lambda * z)./(z - lambda);
p = (1 - lambda * p)./(p - lambda);

% SL: why is this necessary?
z = 1./conj(z);
p = 1./conj(p);
k = -k;

% based on warping
% z = (1 + lambda * z)./(z + lambda);
% p = (1 + lambda * p)./(p + lambda);

dc_p_w = real(prod(abs(1 - p)));
dc_z_w = real(prod(abs(1 - z)));

% correct gain
k = k * ((dc_p_w / dc_z_w) / (dc_p / dc_z)) ;

%end function
end