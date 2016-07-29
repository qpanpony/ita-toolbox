function [ h ] = ita_make_MF_header(varargin)
%ITA_MAKE_MF_HEADER - Generates a complete MF header - currently obsolete
%without routine writing MF files
%   Produces a header for AudioFiles as required for writing data to Monkey
%   Forest. Signal can be in frequency or time domain.
%
%   Syntax: header = ita_make_MF_header(audioObj)
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_make_MF_header">doc ita_make_MF_header</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Aug-2008

% changing for OOP data files, mpo, 16-Jun-2011

%% Initialization
narginchk(1,2);

if ~isa(varargin{1},'itaAudio')
    error('ITA_MAKE_MF_HEADER: Wrong Input.')
else
    ao = varargin{1};
end

if numel(ao) > 1
    error('ITA_MAKE_MF_HEADER: Multiple instances of itaAudio are not allowed.');
end

if ao.isFreq
    xAxUnit  = 'Hz';
    RcursOld = ao.nSamples;
    domainStr = 'M';
else
    xAxUnit  = 's';
    RcursOld = ao.nBins;    
    domainStr = 'T';
end

if strcmpi(ao.channelUnits{1},'Pa')
    yAxUnit = 'Pa';
    Volt0dB = 20e-6;
else
    yAxUnit = 'V';
    Volt0dB = 1;
end

%% Produce Header
h = struct;
h.Domain          = domainStr;
h.Samples         = size(ao.data,1); % can be nSamples or nBins
h.SamplingRate    = ao.samplingRate;
h.nChannels       = ao.nChannels;

h.ADofs           = 0; %still unsure -- huhu
h.KanalNr         = 0;
h.alleBearb       = 1;
h.Preemph         = 0;
h.LiCursAct       = 0;
h.CursCross       = 0;
h.CursLock        = 0;
h.DrawMode        = 1;
h.ODrawMode       = 0;
h.Wei             = 0;
h.nur0            = 0;
h.NormMax0dB      = 0;
h.Yzoom           = 0;
h.Xlog            = 1;
h.Ylog            = 5;
h.VerNr           = 97;
h.Reserviert      = double(zeros(52,1));

h.Hun             = 0; % TODO: set the correct date values here
h.Year            = 0;
h.Month           = 0;
h.Day             = 0;
h.Hour            = 0;
h.Min             = 0;
h.Sec             = 0;

% h.Hun             = ao.DateVector(7);
% h.Year            = ao.DateVector(1);
% h.Month           = ao.DateVector(2);
% h.Day             = ao.DateVector(3);
% h.Hour            = ao.DateVector(4);
% h.Min             = ao.DateVector(5);
% h.Sec             = ao.DateVector(6);
h.Start           = 0;
h.xAxUnit         = xAxUnit;
h.yAxUnit         = yAxUnit;
h.Rand            = double([2; RcursOld]);
h.Cursor          = double([1; RcursOld]);
h.MainDelay       = 0;
h.Volt0dB         = Volt0dB;
h.LcursOld        = 1;
h.RcursOld        = RcursOld;
h.ADDAident       = '24 Bit Quantisierung'; %pdi
h.VoltageRange    = 1; %has been compensated in the read in function

h.Comment = ao.comment;

switch(ao.signalType)
    case {'power'}
        h.FFTnorm = 0;
    case {'energy'}
        h.FFTnorm = 1;
    case {'passband'}
        h.FFTnorm = 2;
    otherwise
        error('ITA_MAKE_MF_HEADER:Oh Lord. FFTnorm is from hell!')
end


% h.SampleSize  = round(24 / 8); % TODO % Samplesize still unsure -- huhu
% else
%     h.SampleSize  = 2* round(24 / 8  );
% end




