function varargout = ita_sharpness(varargin)
%ITA_SHARPNESS - Calculate Sharpness of a signal
%  This function calculates the well-known sharpness of a signal
%
%  Syntax:
%   itaValue_Obj = ita_sharpness(audioObjIn)
%
%  See also:
%   ita_loudness, test_ita_sharpness, ita_roughness_daniel
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sharpness">doc ita_sharpness</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Daniel Cragg -- Email: daniel.cragg@akustik.rwth-aachen.de
% Created:  14-Jun-2010


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
if isa(varargin{1}, 'itaAudio')
    input = varargin{1};
    if ~all(strcmp(input.channelUnits(:), 'Pa'))
        error([thisFuncStr,'The input has to be sound pressure with the unit Pa.']);
    end
    [N NS] = ita_loudness(input);
elseif isa(varargin{1}, 'itaResult')
    NS = varargin{1};
end

k = 0.10852;

gz        = max(1,0.15.*exp(0.42.*(NS.freqVector-15.8))+0.85);
sharpness = k .* sum( bsxfun(@times, gz .* NS.freqVector , NS.freqData),1) ./ sum(NS.freqData,1);
sharpness = itaValue(sharpness);
sharpness.unit = 'acum';

ita_verbose_info([thisFuncStr 'Normalization constant k = ' num2str(k) ],1);

%% Set Output
varargout = {sharpness};

%end function
end