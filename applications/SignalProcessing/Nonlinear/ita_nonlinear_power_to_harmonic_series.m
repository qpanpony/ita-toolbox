function varargout = ita_nonlinear_power_to_harmonic_series(varargin)
% ITA_NONLINEAR_POWER_TO_HARMONIC_SERIES - Convert a power series into a
% harmonic series.
% Does a Conversion from power series to harmonic series based on the
% Chebychev Polynomials. 
% For references see: 
%   Pascal Dietrich - Uncertainties in Acoustical Transfer Functions
% 
%  Syntax:
%   audioObjOut = ita_nonlinear_power_to_harmonic_series(audioObjIn, options)
%   audioObjIn & audioObjOut are itaAudio Objects with nChannel
%   corresponding to maximum degree.
% 
%   Options (default):
%           'gain' (1) : gain of the sweep used as excitation signal
%
%  Example:
%   powerSeries = ita_nonlinear_power_to_harmonic_series(harmonicSeries, 'gain', 1)
%
%  See also:
%   ita_nonlinear_harmonic_to_power_series,
%   ita_nonlinear_shift_frequency_vector, ita_harmonic_series,
%   ita_power_series
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_power_to_harmonic_series">doc ita_nonlinear_power_to_harmonic_series</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% based on function ita_nonlinear_h2p by Anja Kludszuweit & Pascal Dietrich
% Created:  09-Dec-2014 


%% Initialization and Input Parsing
sArgs        = struct('pos1_powerSeries','itaAudio', 'gain', 1,'phi',0);
[powerSeries, sArgs] = ita_parse_arguments(sArgs,varargin); 

zero  = ita_generate('flat',0,powerSeries.samplingRate, powerSeries.fftDegree);
const = ita_generate('flat',1,powerSeries.samplingRate, powerSeries.fftDegree);               

% remove the comments
zero.comment = [];
const.comment = [];

powerSeriesVector(powerSeries.nChannels) = itaAudio();
for idx= 1:powerSeries.nChannels
    powerSeriesVector(idx) = powerSeries.ch(idx);
end

% Chebyshev Matrix CM
CM = ita_chebyshev_polynom(0:powerSeries.nChannels);

% GainMatrix GM
GM = diag(sArgs.gain.^(-1:powerSeries.nChannels-1)) ./ sArgs.gain;

% Phase matrix
PM = diag(exp(1i*sArgs.phi*(-1:powerSeries.nChannels-1)));

% Combined Matrix M
M = (PM * pinv(CM) * GM).';

% double * itaAudio performs an elementwise multiplication
audioObjM = M * repmat(const, size(M));

powerSeriesMatrix = repmat(powerSeriesVector, powerSeries.nChannels, 1);
for idx = 2:powerSeries.nChannels
    powerSeriesMatrix(idx, 1:end) = ita_nonlinear_shift_frequency_vector(powerSeriesMatrix(idx, 1:end),...
                                    'degree', idx, 'left', 'array');
end
harmonicSeriesMatrix = [repmat(zero, powerSeries.nChannels, 1), powerSeriesMatrix] * audioObjM;

harmonicSeries = ita_merge(get_diag(harmonicSeriesMatrix(1:end,2:end)));

harmonicSeries = ita_nonlinear_shift_frequency_vector(harmonicSeries, 'right');
harmonicSeries = ita_metainfo_add_historyline(harmonicSeries,mfilename,varargin);

for idx = 1:harmonicSeries.nChannels
    harmonicSeries.channelNames(idx) = {['Harmonic series: ', num2str(idx)]};
    harmonicSeries.channelUnits(idx) = powerSeries.channelUnits(1);
end
varargout{1} = harmonicSeries;

%end function
end