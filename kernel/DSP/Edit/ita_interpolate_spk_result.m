function [ varargout ] = ita_interpolate_spk_result(varargin)

%ITA_INTERPOLATE_SPK_RESULT - Rezising of frequency data through interpolation in frequency domain
% This Function interpolates an itaResult object in frequency domain
%
%   Syntax: itaResult = ita_interpolate_spk_itaResult(itaResult, newFreqBins, Options)
%
%       Options (default):
%           method ('spline'):   method used for interpolation, see help interp1 for more infos
%           absphase (false) :  interpolate complex data via magnitude/phase or real/imaginary data
%           extraplow ('zeros'): method used for extrapolation to lower frequencies
%           extraphigh ('zeros'): method used for extrapolation to higher frequencies
%           extrap: use this to set both extrapolation methods at once
%
%       Valid for extrapolation methods: ['zeros', 'const', 'interpmethod']
%       - zeros: using zeros for constant extrapolation
%       - const: using value of upper/lower frequency limit for constant extrapolation
%       - interpmethod: using same method as for interpolation
%
%   See also ita_interpolate_spk, ita_mpb_filter, ita_multiply_spk, ita_audioplay.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_interpolate_spk_result">doc ita_interpolate_spk_result</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% For error handling
thisFuncStr  = [upper(mfilename) ':'];

%% Initialization and Input Parsing
sArgs               = struct('pos1_a','itaResult','pos2_newFreqs','numeric','method','spline','absphase',false, 'extraplow', 'zeros', 'extraphigh', 'zeros', 'extrap', '');
[data,newFreqs, sArgs] = ita_parse_arguments(sArgs,varargin);

oldFreqs = data.freqVector;
if isrow(newFreqs); newFreqs = newFreqs'; end

if ~isempty(sArgs.extrap)
    sArgs.extraplow = sArgs.extrap;
    sArgs.extraphigh = sArgs.extrap;
end
switch sArgs.extraplow
    case 'zeros'
        extrapLow = zeros(1, size(data.freqData, 2));
    case 'const'
        extrapLow = data.freqData(1, :);
    case 'interpmethod'
        extrapLow = [];
    otherwise
        error([thisFuncStr 'Invalid value for extraplow option.'])
end
switch sArgs.extraphigh
    case 'zeros'
        extrapHigh = zeros(1, size(data.freqData, 2));
    case 'const'
        extrapHigh = data.freqData(end, :);
    case 'interpmethod'
        extrapHigh = [];
    otherwise
        error([thisFuncStr 'Invalid value for extraphigh option.'])
end

%% Interpolation
if sArgs.absphase %Interpolate abs/phase (gdelay would be even better)
    newFreqData = interp1(oldFreqs,abs(data.freqData),newFreqs,sArgs.method, 'extrap') .* ...
        exp(1i * interp1(oldFreqs,unwrap(angle(data.freqData)),newFreqs,sArgs.method, 'extrap'));
else %Interpolate real/img
    newFreqData = interp1(oldFreqs,data.freqData,newFreqs,sArgs.method, 'extrap');
end

%% Extrapolation
if ~isempty(extrapLow)
    idxOverwriteLow = newFreqs < data.freqVector(1);
    if any(idxOverwriteLow)
        newFreqData(idxOverwriteLow, :) = repmat(extrapLow, sum(idxOverwriteLow), 1);
    end
end
if ~isempty(extrapHigh)
    idxOverwriteHigh = newFreqs > data.freqVector(end);
    if any(idxOverwriteHigh)
        newFreqData(idxOverwriteHigh, :) = repmat(extrapHigh, sum(idxOverwriteHigh), 1);
    end
end

%% Finishing
data.freqVector = newFreqs;
data.freqData = newFreqData;

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find Output
varargout(1) = {data};

end %function