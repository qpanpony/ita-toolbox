function varargout = ita_invert_freq(varargin)
%ITA_INVERT_SPK_REGULARIZATION - Invert spectrum (Kirkeby method)
%  This function inverts a spectrum in Frequency domain, commonly used for
%  sweep excitation signals, after a method proposed by Angelo Farina.
%  Farina's method is only a one-dimensional look on Kirkeby's method.
%  Given a frequency vector consisting of lower and higher cutoff frequency
%  this functions operates in the given frequency range by inverting the
%  signal. The resulting spectrum is therefore a compensation spectrum.
%  Multiplied with the input spectrum, the obtained impulse response is
%  very compact.
%
%  Syntax:
%   itaAudio = ita_invert_spk_regularization(itaAudio, [low_freq high_freq],options)
% 
%  Options (default): 'beta' (0) - TODO HUHU
%                     'filter' (false) - use additional filtering
%                     'pzmode' (false) - TODO HUHU
%                     'zerophase' (true) - use additional filtering
%
%  Example:
%   audioObj = ita_invert_spk_regularization(audioObj,[40 10000])
%
%   See also: ita_invert_spk_regularization_old, ita_divide_spk, ita_generate.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_invert_spk_regularization">doc ita_invert_spk_regularization</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-May-2009 


varargout{1} = ita_invert_spk_regularization(varargin{:});