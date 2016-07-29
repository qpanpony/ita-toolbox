function varargout = ita_dither(varargin)
%ITA_DITHER - Dithering of excitation signal
%  This function applys dither noise to minimize non-linearities due to
%  quantization. This is helpful if the output level of the signal is very
%  low and therfore quantization effects become problematic.
%
%  Syntax:
%   audioObjOut = ita_dither(audioObjIn, options)
%
%   Options (default):
%           'nBits'(24)    : number of bits of the sound card used
%           'type' ('tri') : 'rect', 'tri', 'gauss' different PDFs of dither noise
%           'quite'(false) : enable to prevent dither noise if no signal is present
%
%  Example:
%   audioObjOut = ita_dither(audioObjIn)
%
%  See also:
%   itaMSTF
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_dither">doc ita_dither</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  11-Jun-2012 


%% Initialization and Input Parsing
sArgs         = struct('pos1_data','itaAudio', 'nBits', 24,'type','tri','quiet',false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 
timeData = input.timeData;


%% generate dither noise
idxx  = [input.nSamples input.nChannels]; %init
delta = 2 / 2.^sArgs.nBits;%between two quantization steps, symmetric amplitude +/-1, LSB
switch lower(sArgs.type)
    case 'rect' %uniform PDF
        dithernoise = rand(idxx);
    case {'tri','aes17','tpdf'} %triangular PDF according to standard AES17
        dithernoise = rand(idxx) + rand(idxx); %convolution of two uniform PDFs (TPDF dither, according to Lipshitz/Vanderkooy JAES 2004)
    case 'tri2' %triangular PDF
        dithernoise = rand(idxx) + rand(idxx); %convolution of two uniform PDFs
        dithernoise = dithernoise * 2;
        %         dithernoise = dithernoise/2; %doulbe values due to convolution%         !pdi:
    case 'gauss' %normal PDF
        dithernoise = randn(idxx)/2 ; % according to Lipshitz/Vanderkooy JAES 2004
    case 'none'
        dithernoise = 0;
    otherwise
        error('type unknown')
end
dithernoise = dithernoise * delta;

%% quitening the dither noise if no signal is present
if sArgs.quiet
    quiet = abs(timeData < delta/2);
    dithernoise = dithernoise.* quiet;
end

%% add dither 
input.timeData = timeData + dithernoise;


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end