function varargout = ita_loudness(varargin)
%ITA_LOUDNESS - calculates loudness level of a signal according to DIN
%45631 / ISO 532 B norms (Zwicker algorithm)
%   This function calculates the loudness level of a signal according to the
%   DIN 45631 / ISO 532 B norms, using the Zwicker algorithm.
%   The input is an ITA audio object.  Optionaly the Field type can 
%   be given, either 'free' or 'diffuse'. If the type is not given, free 
%   field is used as standard.
% 
%
%  Syntax:
%   TotalLoudness                    = ita_loudness(audioObjIn, options)
%   [TotalLoudness SpecificLoudness] = ita_loudness(audioObjIn, options)
%
%   Options (default):
%           'SoundFieldType' ('free') : Type of sound field: 'free' or 'diffuse'
%           'mode'   ('fft')          : calculate 1/3 octave levels with 'fft' or with 'filter' (ita_mpb_filter)
% 
%  Example:
%   [N NS] = ita_loudness(audioObjIn, 'SoundFieldType' , 'free')
%
%  See also:
%   ita_loudness_timevariant, ita_sone2phon, ita_sharpness
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_loudness">doc ita_loudness</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  27-May-2010 


% TODO mgu:
%   + In N  schreiben ob GF oder GD

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'SoundFieldType', 'free', 'mode', 'fft');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 

% Type of sound field ( free = 0 / diffuse  = 1 )
switch sArgs.SoundFieldType 
    case {'diffuse', 'd'}
        SoundFieldType = 1;
        einheit = 'sone';
    case {'free', 'f'}
        SoundFieldType = 0;
        einheit = 'sone';
    otherwise
        error([thisFuncStr,'Unknown sound field type. Please choose between free or diffuse fields.']);      
end

% UNIT CHECK 
if ~all(strcmp(input.channelUnits(:), 'Pa'))
    error([thisFuncStr,'The input has to be itaAudio with unit Pa.']);
end


thirdOctBands = ita_spk2frequencybands(input','freqRange', [25 12500], 'bandsPerOctave', 3,  'mode', sArgs.mode, 'class' , 0 , 'order', 6 );
freqVec = ita_ANSI_center_frequencies([25 12500], 3);

% calculate loudness with mex function  
N           = zeros(1,thirdOctBands.nChannels);
NS          = zeros(240,thirdOctBands.nChannels);
refLevel    = -20*log10(2e-5);

% be sure to have doubles in the output
thirdOctBands.dataTypeOutput = 'double'; 
for iChannel = 1:thirdOctBands.nChannels
     if thirdOctBands.ch(iChannel).nBins ~= 28
         [~, idxPosition, idxAvailable] = intersect(freqVec, thirdOctBands.freqVector);
         freqDBData = zeros(28,1);
         tmp = thirdOctBands.ch(iChannel).freqData_dB;
         freqDBData(idxPosition) = tmp(idxAvailable);
     else
         freqDBData = thirdOctBands.ch(iChannel).freqData_dB;
     end
         [N(iChannel), NS(:,iChannel)] = DIN45631(freqDBData, SoundFieldType); 
end

% write itaResult
SpecificLoudness                    = itaResult(input); % copy audio struct information from input struct
SpecificLoudness.channelUnits(:)    = {[einheit '/Bark']}; 
SpecificLoudness.freqVector         = (0.1:0.1:24)';
SpecificLoudness.freqData           = NS;
SpecificLoudness.allowDBPlot        = false;
SpecificLoudness.plotAxesProperties = {'xlim', [0.1 24], 'xscale', 'lin'};


TotalLoudness = itaValue(N,'sone');


%% Add history line
SpecificLoudness    = ita_metainfo_add_historyline(SpecificLoudness,mfilename,varargin);
%% Set Output
if nargout == 1
    varargout(1) = {TotalLoudness};
elseif nargout == 2
    varargout(1) = {TotalLoudness};
    varargout(2) = {SpecificLoudness};
elseif nargout == 0
    plot(SpecificLoudness.freqVector, SpecificLoudness.freqData)
    xlim([0 24.1]); xlabel('frequency [Bark]'); ylabel('Specific Loudness [sone/ Bark]'); title(sprintf('Total Loudness: %2.2f sone', TotalLoudness.value))
end


%end function
end