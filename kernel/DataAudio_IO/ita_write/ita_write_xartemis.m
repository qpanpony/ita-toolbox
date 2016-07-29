function  result = ita_write_artemis(varargin)
%ITA_WRITE_ARTEMIS - +++ Short Description here +++
%   This functions writes itaAudios to a *.mat file for ArtemiS
%
%  Syntax:
%   ita_write_artemis(audioObjIn)
%   ita_write_artemis(audioObjIn, , options)
%
%   Options (default):
%           'fileName' ('itaAudio2ArtemisExport') : string with Filename
%
%  Example:
%   a = ita_generate('pinknoise', 125,44100,19);
%   ita_write_artemis(a, 'fileName', 'ITApinkNoise')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_write_artemis">doc ita_write_artemis</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  25-Jun-2010 


%% Initialization and Input Parsing
if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.mat';
    result{1}.comment = 'HEAD acoustics Artemis (*.mat)';
    return;
end

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio','pos2_fileName', 'string','overwrite',false);
[input,filename,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 

dateNow = datestr(now, 'dd.mm.yyyy HH:MM:SS.FFF');

shdf.szTitle            = inputname(1);
shdf.szDateOfRecording  = dateNow;
shdf.szMoniker          = 'Recording';
shdf.szComment          = ['ITA Toolbox: itaAudio to ArtemiS export (' dateNow ') ' input.comment];
shdf.nNbrOfAbsc         = 1;                % only audio export
shdf.nNbrOfChn          = input.nChannels;
% shdf.UserDefinedInfos   = 



shdf.Absc.szAbbrev      = 't';
shdf.Absc.szName        = 'time';
shdf.Absc.szQuantity    = 'time';
shdf.Absc.szUnit        = 's';
shdf.Absc.nNbrOfSamples = input.nSamples;
shdf.Absc.eKind         = 1; % equidistant values
shdf.Absc.szKind        = 'EquidistantValues';
shdf.Absc.dStart        = input.timeVector(1);
shdf.Absc.dStep         = diff(input.timeVector(1:2));
shdf.Absc.dStop         = input.timeVector(end);


% set ranage to min 20 dB above maximum
% 20*log(dRangeMax) - 9dB(headroom)   = shown Range in dB
maxAmp          = max(abs(input.timeData(:)));
maxRange        = 20*log10(maxAmp * 10 / 2 /sqrt(2)/2e-5); % standard Artemis Headroom -6dB (2), rms -3dB (srqt(2)), my Headroom app. 20dB
shownRange      = 10*round(maxRange/10);
dRangeArtemis   = 10^(shownRange /20) * 2e-5 *2 *sqrt(2);



for iCh = 1:input.nChannels
    shdf.Chn(iCh).szCodecMoniker        = 'Audio.Decoded';
    shdf.Chn(iCh).szQuantity            = 'pressure';
    shdf.Chn(iCh).szUnit                = 'Pa';
    shdf.Chn(iCh).dRangeMin             = -dRangeArtemis;
    shdf.Chn(iCh).dRangeMax             = dRangeArtemis;
    shdf.Chn(iCh).dSamplingrate         = input.samplingRate;
    shdf.Chn(iCh).dOversamplingFactor   = 1;
    shdf.Chn(iCh).nID                   = iCh-1;
    shdf.Chn(iCh).nGroupMembership      = iCh-1;
    shdf.Chn(iCh).szAbbrev              = [num2str(iCh)];
    shdf.Chn(iCh).szName                = ['Channel' num2str(iCh)];
    shdf.Chn(iCh).szTitle               = ['Channel ' num2str(iCh)];
end






shdf.Absc1Data          = input.timeVector.';
shdf.Data               = input.timeData.';




save([filename], 'shdf', '-v6')

%%
result = 1;

%end function
end