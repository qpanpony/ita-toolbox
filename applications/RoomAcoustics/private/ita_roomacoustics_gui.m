function varargout = ita_roomacoustics_gui(varargin)
%ITA_ROOMACOUSTICS_GUI - GUI for ita_roomacoustics()
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   ita_roomacoustics()
%
%  Example:
%   ita_roomacoustics()
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_gui">doc ita_roomacoustics_gui</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  16-May-2011


%% Create GUI
pList = {};

ele = 1;

if ~nargin  && ~nargout
    
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the input itaAudio';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = ele + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 'roomacousticResults';
    
elseif ~nargin  && nargout
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the input itaAudio';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = ele+1;
    pList{ele}.description = 'Result will be given as output variable'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Result will be given as output variable';
    pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI
    
else
    
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the input itaAudio';
    pList{ele}.datatype    = 'itaAudioFix';
    pList{ele}.default     = varargin{1};
    
    ele = ele+1;
    pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
    pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI
    
end

if nargin >0 || nargout > 0 % ita_toolbox_gui call OR output var
else % set in bae stuff
    
end



ele = ele + 1;  pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Parameter'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select the parameter to calculate. For multiple parameter calculation use console';
pList{ele}.datatype    = 'char_popup';
pList{ele}.list        = ita_string_listing(ita_roomacoustics_parameters('getAvailableParameters'), 'seperator', '|');
pList{ele}.default     = 'T20'; %default value, could also be empty, otherwise it has to be of the datatype specified above



ele = ele + 1;  pList{ele}.datatype    = 'line';

possiblePar     = { 'useSinglePrecision' };


ele = ele + 1;
pList{ele}.description = 'Frequency Range';
pList{ele}.helptext    = 'Define evaluated frequency range';
pList{ele}.datatype    = 'int';
pList{ele}.default     = ita_preferences('freqRange');


ele = ele + 1;
pList{ele}.description = 'Bands per octave';
pList{ele}.helptext    = 'Define evaluation bandwidth';
pList{ele}.datatype    = 'int_popup';
pList{ele}.list        = [1 3];
pList{ele}.default     = ita_preferences('bandsPerOctave');





edcMethodString = ita_string_listing({'noCut' 'justCut' 'cutWithCorrection' 'subtractNoise' 'subtractNoiseAndCutWithCorrection' 'unknownNoise' 'noCutWithCorrection' }, 'seperator', '|');

ele = ele+1;
pList{ele}.description = 'Noise compensation'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select the noise compensation method.';
pList{ele}.datatype    = 'char_popup';
pList{ele}.list        = edcMethodString;
pList{ele}.default     = 'subtractNoiseAndCutWithCorrection'; %default value, could also be empty, otherwise it has to be of the datatype specified above



% possiblePar     = {'noisedetect' 'useSinglePrecision' };
possiblePar     = { 'freqRange', 'bandsPerOctave', 'edcMethod', 'useSinglePrecision' 'cutTailingZeros', 'plotLundebyResults', 'broadbandAnalysis'};
ele = ele + 1;
pList{ele}.description = 'Single precision';
pList{ele}.helptext    = 'Use single precision to avoid memory errors' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;



ele = ele + 1;
pList{ele}.description = 'Cut tailing Zeros';
pList{ele}.helptext    = 'detect tailing zeros and crop RIR' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = true;

ele = ele + 1;
pList{ele}.description = 'Plot Lundeby results';
pList{ele}.helptext    = 'plot lundeby results (reverberation time, intersection time and noise level)' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;

ele = ele + 1;
pList{ele}.description = 'Broadband analysis';
pList{ele}.helptext    = 'deactivate the fractional octave band filtering' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;


ele = ele + 1; pList{ele}.datatype    = 'line';


% OLD WAY, more than one output parameter. this is too complicated for ita_TB_gui, setinbase etc...
% raPar           = ita_preferences('roomacousticParameters');
%
% categoryNameCell = fieldnames(raPar);
% for iCat = 1:numel(categoryNameCell)
%     ele = length(pList) + 1;
%     pList{ele}.datatype    = 'text';
%     pList{ele}.description    = strrep(categoryNameCell{iCat}, '_', ' ');
%
%     fieldNameCell = fieldnames(raPar.(categoryNameCell{iCat}));
%     for iField = 1:numel(fieldNameCell)
%         ele = length(pList) + 1;
%         possiblePar = [possiblePar fieldNameCell{iField}];
%         fieldStr = strrep(fieldNameCell{iField}, '_', ' ');
%         pList{ele}.description = fieldStr;
%         pList{ele}.helptext    = fieldStr;
%         if isa(raPar.(categoryNameCell{iCat}).(fieldNameCell{iField}), 'logical')
%             pList{ele}.datatype    = 'bool';
%             %         elseif isa(raPar.(categoryNameCell{iCat}).(fieldNameCell{iField}), 'numeric')
%             %             pList{ele}.datatype    = 'int';
%         else
%             error(sprintf('unknown type in struct (field: %s). i don''t know how to generate gui', fieldNameCell{iField}))
%         end
%         pList{ele}.default     = raPar.(categoryNameCell{iCat}).(fieldNameCell{iField});
%     end
%
%     ele = length(pList) + 1;
%     pList{ele}.datatype    = 'line';
%
% end

varargout = {};
guiOutput = ita_parametric_GUI(pList, 'Roomacoustics');

%%
if ~isempty(guiOutput)
    tmpPar  = [possiblePar(:)'; guiOutput(end-6:end)];
    raResults  = ita_roomacoustics(guiOutput{[1 end-7]}, tmpPar{:}); % end-7 weil anzhal gui elemet abhängiv von inpt und output variablen ist
    if nargout >= 1
        varargout =  {raResults.(guiOutput{end-7})};
    else
        ita_setinbase(guiOutput{2}, raResults.(guiOutput{end-7}) );
    end
end


%end function
end