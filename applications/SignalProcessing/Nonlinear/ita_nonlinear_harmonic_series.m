function varargout = ita_nonlinear_harmonic_series( varargin )
% ITA_NONLINEAR_HARMONIC_SERIES - creates a distorted signal using a harmonic
% reconstruction: x_out=a*fundamental+b*2ndharm+c*3rdharm+...
%
% Call: audioObject = ita_nonlinear_harmonic_series(audioObject, coeff_vector, 'gain', 1, 'phi', 0)
%
%       coeff_vector: [a b c ...] see above
%       gain        : gain of the input signal
%       phi         : phase offset of the input signal (in case of a sweep,
%                     the phase offset due to the sweep rate needs to be
%                     considered as well)
%
%  See also:
%   ita_mpb_filter, ita_nonlinear_power_series,
%   ita_nonlinear_power_to_harmonic_series,
%   ita_nonlinear_harmonic_to_power_series
%
% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Trigonometric decomposition as in
% Milton Abramowitz and Irene Stegun: Handbook of Mathematical Functions,
% (1964) Dover Publications, New York. ISBN 0-486-61272-4
% and
% I. S. Gradshteyn and I. M. Ryzhik, Table of Integrals, Series, and
% Products, Academic Press, 5th edition (1994). ISBN 0-12-294755-X
%
% Gain and Phase correction from Pascal Dietrich - Uncertainties in
% Acoustical Transfer Functions

% Author: Pascal Dietrich, 2011 - pdi@akustik.rwth-aachen.de

sArgs   = struct('pos1_data','itaAudio','pos2_vec','double','gain',1,'phi',0);
[data, coeff, sArgs] = ita_parse_arguments(sArgs,varargin); 

% conversion from harmonic coefficients to corresponding power coefficients
oIdx        = 0:numel(coeff);         
CM          = ita_chebyshev_polynom(0:numel(coeff));
gainMatrix  = diag(sArgs.gain.^(oIdx-1));
phaseMatrix = diag(exp(1i*sArgs.phi*(oIdx-1)));
coeff       = pinv(gainMatrix(2:end, 2:end)) * CM(2:end,2:end) * pinv(phaseMatrix(2:end, 2:end)) * coeff.';

% generation of the powerseries corresponding to the harmonic series to be created
data        = ita_nonlinear_power_series(data,coeff);

data = ita_metainfo_add_historyline(data,mfilename,varargin);


%% Set Output
varargout(1) = {data};

end

