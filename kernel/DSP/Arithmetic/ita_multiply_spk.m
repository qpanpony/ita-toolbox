function [ varargout ] = ita_multiply_spk( varargin )
%ITA_MULTIPLY_SPK - Multiplication in spectral domain
%   This function multiplies two spectra in frequency domain. Channel names
%   and units will be handled as well.
%
%   Syntax: itaAudio = ita_multiply_spk( itaAudioNumerator , itaAudioDenominator )
%
%   See also ita_divide_spk, ita_multiply_dat.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_multiply_spk">doc ita_multiply_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de


%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode'); %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the first itaAudio';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Second itaAudio';
    pList{ele}.helptext    = 'This is the second itaAudio';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 3;
    pList{ele}.datatype    = 'line';
    
    ele = 4;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Multiply two itaAudio objects in Frequency Domain']);
    if ~isempty(pList)
        result = ita_multiply_spk(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end
narginchk(2,2);
sArgs   = struct('pos1_num','itaSuper','pos2_den','anything');
[num, den, sArgs] = ita_parse_arguments(sArgs,varargin);

result = num*den;

%% Find what domain is requested - Always the result domain goes out
varargout(1) = {result};