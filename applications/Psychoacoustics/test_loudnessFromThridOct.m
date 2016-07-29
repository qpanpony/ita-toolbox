function varargout = test_loudnessFromThridOct(terzbandPegel, SoundFieldType)
%ITA_LOUDNESS 
%   This function calculates the loudness level of a signal according to the
%   DIN 45631 / ISO 532 B norms, using the Zwicker algorithm.
%    Optionaly the Field type can 
%   be given, either 'free' or 'diffuse'. If the type is not given, free 
%   field is used as standard.
% 
%  
% 
%  
%  Syntax:
%   TotalLoudness                    = ita_loudness(terzbandPegel, SoundFieldType)
%   [TotalLoudness SpecificLoudness] = ita_loudness(terzbandPegel, SoundFieldType)
%
%   Options (default):
%           'SoundFieldType' 1: diffus  || 0:freifeld
%             terzbandPegel: 28 Terzbandpegel von 40 Hz bis 12500 Hz 
%
%  See also:
%   ita_loudness, ita_loudness_timevariant, ita_sone2phon, ita_sharpness
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_loudness">doc ita_loudness</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  16-Apr-2011 


%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 





[N, NS] = DIN45631(terzbandPegel, SoundFieldType);


%% Set Output


if nargout == 2
    varargout(1) = {N};
    varargout(2) = {NS};
else
        varargout(1) = {N};
end


%end function
end