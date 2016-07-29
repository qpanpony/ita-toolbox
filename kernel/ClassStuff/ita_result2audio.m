function varargout = ita_result2audio(varargin)
%ITA_RESULT2AUDIO - converts itaResult to itaAudio by interpolation and resampling
%  This function converts an itaResult into an itaAudio by interpolation
%  and resampling
%
%  Syntax:
%   audioObjOut = ita_result2audio(resultObjIn,samplingRate,fftDegree,options)
%   Options (default):
%    'no_filter' (false) :       
%
%  Example:
%   audioObjOut = ita_result2audio(resultObjIn,44100)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_result2audio">doc ita_result2audio</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  19-Jan-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% if a target samplingrate and fftdegree is specified
if nargin < 3
    if nargin < 2
        varargin = [varargin, {44100}];
    end
    varargin = [varargin, {10}];
end

sArgs        = struct('pos1_input','itaResult','pos2_targetSamplingRate','numeric','pos3_fftDegree','numeric','no_filter',false);
[input,targetSamplingRate,fftDegree,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 'input' is an audioObj and is given back
% first do the interpolation to a minFFTDegree
minFFTDegree = nextpow2(input.nSamples);
if isTime(input)
    oldAbscissa  = input.timeVector;
    samplingRate = 1./mean(diff(oldAbscissa));
    minFFTDegree = max(minFFTDegree,log2(ceil(max(oldAbscissa)*samplingRate/2)*2));
    newAbscissa  = (0:2^minFFTDegree-1)./samplingRate;
else
    oldAbscissa  = input.freqVector;
    samplingRate = ceil(2*max(oldAbscissa)); % round to 1Hz precision
    minFFTDegree = max(minFFTDegree,log2(ceil(samplingRate/2/mean(diff(oldAbscissa)))));
    newAbscissa  = linspace(0,samplingRate/2,(2^minFFTDegree)+1);
end
oldData = input.data;
interpData = zeros(numel(newAbscissa),size(oldData,2));
for i=1:input.nChannels
    if all(isreal(oldData(:,i)))
        interpData(:,i) = interp1(oldAbscissa,real(oldData(:,i)),newAbscissa,'spline','extrap');
    else % let's try abs and unwrapped phase (or groupdelay)
        interpData(:,i) = interp1(oldAbscissa,abs(oldData(:,i)),newAbscissa,'spline','extrap').*...
            exp(1i.*interp1(oldAbscissa,unwrap(angle(oldData(:,i))),newAbscissa,'spline','extrap'));
%         interpData(:,i) = interp1(oldAbscissa,real(oldData(:,i)),newAbscissa,'spline','extrap')+...
%             1i.*interp1(oldAbscissa,imag(oldData(:,i)),newAbscissa,'spline','extrap');
    end
end

% save some values for postprocessing
processingLimits = [min(oldAbscissa) max(oldAbscissa)];
% avoid the zero
if isFreq(input)
    processingLimits(1) = find(oldAbscissa~=0,1,'first');
end

% if an fftdegree was specified that is higher than the
% minFFTDegree, do another interpolation
if fftDegree > minFFTDegree
    ita_verbose_info([thisFuncStr 'fftDegree was specified, doing second interpolation'],1);
    oldAbscissa = newAbscissa;
    if isTime(input)
        newNSamples = max(2^fftDegree,ceil(max(oldAbscissa)*samplingRate/2)*2);
        newAbscissa = (0:newNSamples-1)./samplingRate;
    else
        newAbscissa = linspace(0,samplingRate/2,2^(fftDegree-1)+1);
    end
    oldData = interpData;
    interpData = zeros(numel(newAbscissa),size(oldData,2));
    for i=1:size(oldData,2)
        if all(isreal(oldData(:,i)))
            interpData(:,i) = interp1(oldAbscissa,real(oldData(:,i)),newAbscissa,'spline','extrap');
        else % let's try abs and unwrapped phase (or groupdelay)
            interpData(:,i) = interp1(oldAbscissa,abs(oldData(:,i)),newAbscissa,'spline',1e-6).*...
                exp(1i.*interp1(oldAbscissa,unwrap(angle(oldData(:,i))),newAbscissa,'spline',1e-6));
        end
    end
end

if ~isreal(interpData(1,:))
    interpData(1,:) = real(interpData(1,:));
end
if ~isreal(interpData(end,:))
    interpData(end,:) = real(interpData(end,:));
end
sObj = saveobj(input);
sObj = rmfield(sObj,[{'classname','classrevision'},itaResult.propertiesSaved]);
input = itaAudio(sObj);
input.signalType = 'energy';
input.samplingRate = samplingRate;
input.data = interpData;

% some postprocessing to cancel out effects of extrapolation
if isTime(input)
    input = ita_time_window(input,[1.1*processingLimits(1) 0.95*processingLimits(1) 0.8*processingLimits(2) 0.95*processingLimits(2)],'time');
elseif ~sArgs.no_filter
    input = ita_filter_bandpass(input,'lower',processingLimits(1),'upper',processingLimits(2),'order',20,'zerophase');
end

if targetSamplingRate ~= samplingRate
    input = ita_resample(input,targetSamplingRate);
    input = ita_interpolate_spk(input,fftDegree);
end

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end