function varargout = ita_ISO_limits_scattering(varargin)
%ITA_ISO_LIMITS_SCATTERING - returns ISO17497-1 limits
%  This function accepts the room volume and an optional frequency vector
%  and returns objects with the limits given in ISO17497-1.
%
%  Syntax:
%   resultObjOut = ita_ISO_limits_scattering(roomVolume, options)
%
%   Options (default):
%           'freqVector' ([]) : frequency vector
%
%  Example:
%   audioObjOut = ita_ISO_limits_scattering(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_ISO_limits_scattering">doc ita_ISO_limits_scattering</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  03-Oct-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_Volume','numeric', 'freqVector', []);
[V,sArgs] = ita_parse_arguments(sArgs,varargin); 

freqVectorISO = ita_ANSI_center_frequencies([100 5000],3,44100);
if isempty(sArgs.freqVector)
    freqVector = freqVectorISO(:);
else
    freqVector = sArgs.freqVector(:);
end

idx_fISO_1 = find(freqVector >= 100,1,'first');
idx_fISO_2 = find(freqVector <= 5000,1,'last');

dummy = itaResult(ones(numel(freqVector),1),freqVector,'freq');
dummy.allowDBPlot = false;
dummy.channelUnits = {''};

%% Maximum Absorption Coefficient alpha_s
alpha_max = dummy;
alpha_max.freq(:) = 0.5;
alpha_max.comment = 'Absorption Coefficient';
alpha_max.channelNames = {'Maximum Absorption Coefficient of the Sample (ISO17497)'};

%% Maximum Scattering Coefficient for the Base Plate
s_baseplate = dummy;
s_baseplate_ISO_values = itaResult([repmat(0.05,1,8) 0.10 0.10 0.10 0.15 0.15 0.15 0.20 0.20 0.20 0.25].',freqVectorISO,'freq');

if any(freqVector < 100) || any(freqVector > 5000)
    nBelow = numel(find(freqVector < 100));
    nAbove = numel(find(freqVector > 5000));
    s_baseplate.freq = [repmat(0.05,nBelow,1); s_baseplate_ISO_values.freq2value(freqVector(idx_fISO_1:idx_fISO_2)); repmat(0.25,nAbove,1)];
else
    s_baseplate = itaResult(s_baseplate_ISO_values,freqVector);
end
s_baseplate.channelNames = {'Maximum Scattering Coefficient of the Base Plate (ISO 17497)'};
s_baseplate.comment = 'Scattering Coefficient of the Base Plate';

%%
A_empty = dummy*itaValue(0.3*V^(2/3),'m^2');
A_empty.channelNames = {'Maximum Absorption Area of the Empty Room (ISO 17497)'};

%% Add history line
alpha_max = ita_metainfo_add_historyline(alpha_max,mfilename,varargin);
A_empty = ita_metainfo_add_historyline(A_empty,mfilename,varargin);
s_baseplate = ita_metainfo_add_historyline(s_baseplate,mfilename,varargin);

%% Set Output
varargout(1) = {[alpha_max,A_empty,s_baseplate]}; 

%end function
end