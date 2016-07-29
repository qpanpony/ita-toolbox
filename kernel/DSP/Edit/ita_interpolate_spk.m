function [ varargout ] = ita_interpolate_spk( varargin )
%ITA_INTERPOLATE_SPK - Rezising of audioData through interpolation in frequency domain
% This Function interpolates the signal in frequency domain
%
%   Syntax: itaAudio = ita_interpolate_spk(itaAudio, NewFFTDegree, Options)
%
%       Options (default):
%           method ('spline'):   method used for interpolation, see help interp1 for more infos
%           absphase (false) : 
%
%   See also ita_mpb_filter, ita_multiply_spk, ita_audioplay.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_resample">doc ita_resample</a>
%
%   Autor: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%% Initialization and Input Parsing
sArgs                     = struct('pos1_a','itaAudioFrequency','pos2_fftdegree','integer','method','spline','absphase',false);
[Data,fftDegree, sArgs]   = ita_parse_arguments(sArgs,varargin);

if ~strcmpi(Data.signalType,'energy')
    ita_verbose_info(' Oh Lord, no energy signal, this is not good, I hope you know what you are doing',0 );
end


[nSamples, nBins] = ita_get_nSamples(fftDegree);


OldFreqs = Data.freqVector;
NewFreqs = linspace(0,max(OldFreqs),nBins);

if sArgs.absphase %Interpolate abs/phase (gdelay would be even better
    Data.freqData = interp1(OldFreqs.',abs(Data.freqData),NewFreqs.',sArgs.method) .* ...
        exp(1i * interp1(OldFreqs.',unwrap(angle(Data.freqData)),NewFreqs.',sArgs.method));
else %Interpolate real/img
    Data.freqData = interp1(OldFreqs.',Data.freqData,NewFreqs.',sArgs.method);
end

%% Add history line
Data = ita_metainfo_add_historyline(Data,mfilename,varargin);

%% Find Output
varargout(1) = {Data};

end %function