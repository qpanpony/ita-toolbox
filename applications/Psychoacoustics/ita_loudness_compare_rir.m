function varargout = ita_loudness_compare_rir(varargin)
%ITA_LOUDNESS_COMPARE_RIR - compares two RIRs' timevariant loudness
%  This function compares two Room Impulse Responses' timevariant loudness
%
%  Syntax:
%   audioObjOut = ita_loudness_compare_rir(audioObjIn1,audioObjIn2,options)
%
%   Options (default):
%           'blocksize' (defaultopt1)   : description
%           'overlap' (defaultopt1)     : description
%
%  Example:
%   audioObjOut = ita_loudness_compare_rir(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_loudness_compare_rir">doc ita_loudness_compare_rir</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  09-Dec-2010 


% TODO:
% input direkt spezifische Lautheit


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'pos2_data','itaAudio', 'blocksize', 0.1, 'overlap', 0);
[ia1, ia2,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 

[LoudnessVsTime1 LoudnessVsTimeVsFreq1]        = ita_loudness_timevariant(ia1, 'blocksize', sArgs.blocksize, 'overlap', sArgs.overlap);
[LoudnessVsTime2 LoudnessVsTimeVsFreq2]        = ita_loudness_timevariant(ia2, 'blocksize', sArgs.blocksize, 'overlap', sArgs.overlap);



% da es noch kein 2D itaResult gibt ...
% anaBlockSize    = round(sArgs.blocksize/1000 * ia1.samplingRate);
% nOverlap        = round(sArgs.overlap * anaBlockSize);
% analysisDeltaT  = (anaBlockSize-nOverlap) / ia1.samplingRate ;
% timeVec = (0:size(LoudnessVsTimeVsFreq1,2)-1 )* analysisDeltaT;





ratio.data  = abs(LoudnessVsTimeVsFreq2.data ./ LoudnessVsTimeVsFreq1.data);

% idx2Invert= ratio >=1;  % alle werte zwischen 0 und 1
idx2Invert= ratio.data <=1;    % alle werte > 1
ratio.data(idx2Invert) = 1./ratio.data(idx2Invert);

idxNan = isnan(ratio.data);
ratio.data(idxNan) = 1; % TODO: sinnvoll? besser 0??


ratio.timeVector = LoudnessVsTimeVsFreq1.timeVector;
ratio.freqVector = LoudnessVsTimeVsFreq1.freqVector;










% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);







%% Add history line
% input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
if nargout == 0
    figure
    
    % nicht zu viel plotten, da sonst java nicht hinterher kommt
    timePlotLimits = [0 0.2]; % in sekunden
       
    barkVec = .1:.1:24;
    timePlotIdx = round(timePlotLimits/analysisDeltaT)+1;
    
    
    contourf(ratio.timeVector(timePlotIdx(1):timePlotIdx(2)) ,ratio.freqVector,  ratio.data(:,timePlotIdx(1):timePlotIdx(2)));
    
    
    shading flat;  xlabel('time [s]'); ylabel('[Bark]')
    colorbar
    caxis([1 50])
    title(strrep([ia1.comment ' vs. ' ia2.comment ], '_', ' '))
    
else
    
    
    varargout(1) = {ratio};
end
%end function
end