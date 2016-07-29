function varargout = ita_nonlinear_harmonic_to_power_series(varargin)
% ITA_NONLINEAR_HARMONIC_TO_POWER_SERIES - Convert a harmonic series into a
% power series.
% Does a Conversion from harmonic series to power series based on the
% Chebychev Polynomials. 
% For references see: 
%   Pascal Dietrich - Uncertainties in Acoustical Transfer Functions
% 
%  Syntax:
%   audioObjOut = ita_nonlinear_harmonic_to_power_series(audioObjIn, options)
%   audioObjIn & audioObjOut are itaAudio Objects with nChannel
%   corresponding to maximum degree.
%
%   Options (default):
%           'gain' (1) : gain of the sweep used as excitation signal
%
%  Example:
%   powerSeries = ita_nonlinear_harmonic_to_power_series(harmonicSeries, 'gain', 1)
%
%  See also:
%   ita_nonlinear_power_to_harmonic_series, ita_harmonic_series,
%   ita_power_series
% 
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_harmonic_to_power_series">doc ita_nonlinear_harmonic_to_power_series</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% based on function ita_nonlinear_h2p by Anja Kludszuweit & Pascal Dietrich
% Created:  03-Dec-2014 


%% Initialization and Input Parsing
sArgs        = struct('pos1_harmonic_series','itaAudio', 'gain', 1,'phi',0);
[harmonicSeries, sArgs] = ita_parse_arguments(sArgs,varargin); 

harmonicsVector(harmonicSeries.nChannels) = itaAudio();
for idx= 1:harmonicSeries.nChannels
    harmonicsVector(idx) = harmonicSeries.ch(idx);
end

zero  = ita_generate('flat',0,harmonicSeries.samplingRate, harmonicSeries.fftDegree);
const = ita_generate('flat',1,harmonicSeries.samplingRate, harmonicSeries.fftDegree);

% remove the comments
zero.comment = [];
const.comment = [];

% Chebyshev Matrix CM
CM = ita_chebyshev_polynom(0:harmonicSeries.nChannels);

% GainMatrix GM
GM = diag([0 sArgs.gain.^(0:harmonicSeries.nChannels-1)]) ./ sArgs.gain;

% phase matrix
PM = diag([0 exp(1i*sArgs.phi*(0:harmonicSeries.nChannels-1))]);

% Combined Matrix M
M = (pinv(GM) * CM * pinv(PM)).';

% double * itaAudio performs an elementwise multiplication
audioObjM = M * repmat(const, size(M));

powerSeries = ita_merge([zero harmonicsVector] * audioObjM);
powerSeries = powerSeries.ch(2:powerSeries.nChannels);
for idx = 1:powerSeries.nChannels
    powerSeries.channelNames(idx) = {['Power series:', num2str(idx)]};
    powerSeries.channelUnits(idx) = harmonicSeries.channelUnits(1);
end

powerSeries = ita_metainfo_add_historyline(powerSeries,mfilename,varargin);
varargout{1} = powerSeries; 

end