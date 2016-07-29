function varargout = ita_loudness_adjustment(varargin)
%ITA_LOUDNESS_ADJUSTMENT - Adjusts loudness of two audios
%  Function adjusts the input level of audioObjIn2 so that both audio objects have the same loudness.
%
%  Syntax:
%   audioObjOut = ita_loudness_adjustment(audioObjIn1, audioObjIn2, 'threshold', 10)
%   ampINdB     = ita_loudness_adjustment(audioObjIn1, audioObjIn2, 'threshold', 10, 'justReturnAmplification')
%
%   Options (default):
%           'threshold' (10)                    : maximal allowed error in percent
%           'justReturnAmplification' (false)   : false: output is amplified audioObjIn2 || true: output is amplification in dB to adjust audioObjIn2
%           'timeVariant'   (false)             : use time variant loudness
%           'whileLimit' (25)                   : maximal number of
%           iterations
%           
%  Example:
%   adjustedS2 = ita_loudness_adjustment(S1, S2, 'threshold', 5 )
%
%  See also:
%   ita_loudness, ita_amplify, ita_loudness_timevariant
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_loudness_adjustment">doc ita_loudness_adjustment</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  19-Jan-2011


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio','pos2_data','itaAudio', 'threshold', 5, 'justReturnAmplification', 'false', 'timeVariant', 'false', 'whileLimit', 25);
[input1, input2,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 

errorThreshold = sArgs.threshold / 100;

timeVariant = sArgs.timeVariant;

if (timeVariant == 0)
    N1 = ita_loudness(input1);
    N2 = ita_loudness(input2);
else
    [~,~,N1] = ita_loudness_timevariant(input1);
    [~,~,N2] = ita_loudness_timevariant(input2);    
end

currentAmp = 0;

% start with stepsize of 10 dB
if N1.value > N2.value
    ampStep = 10;
else
    ampStep = -10;
end

lastStatus = N1.value > N2.value;

% break if too many iterations are needed
whileCounter = 0;
whileLimit = sArgs.whileLimit;

while (abs(N1.value-N2.value) / N1.value > errorThreshold)
    
    if lastStatus ~= ( N1.value > N2.value)    % if status change => decrease and invert stepsize
        ampStep = ampStep / -10;
        lastStatus = N1.value > N2.value;
    end
    
    currentAmp = currentAmp + ampStep;
    
    if (timeVariant == 0)
        N2 = ita_loudness(ita_amplify(input2, currentAmp, 'dB'));
    else
        [~,~,N2] = ita_loudness_timevariant(ita_amplify(input2, currentAmp, 'dB'));
    end
    
    ita_verbose_info( sprintf('CurrentAmp: %2.2f -- Error: %2.2f\n', currentAmp, abs(N1.value-N2.value) / N1.value),2);
    
    whileCounter = whileCounter +1;
    if (whileCounter >= whileLimit)
        error([thisFuncStr,'Difference threshold can not be met. Try increasing it']);
    end
end

% sample use of the ita warning/ informing function
ita_verbose_info([thisFuncStr sprintf('Amplification factor for signal 2: %2.2f dB', currentAmp)],1);


%% Set Output
if sArgs.justReturnAmplification                                % return amplification
    varargout(1) = {itaValue(currentAmp, 'dB')};
else                                                            % return audio
    varargout(1) = {ita_amplify(input2, currentAmp, 'dB')};
end

%end function
end