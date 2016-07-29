function [ varargout ] = ita_multiply_dat( varargin )
%ITA_MULTIPLY_DAT - Multiplication in time domain
%   This function multiplies two time signals in time domain. Channel names
%   and units will be handled as well.
%
%   Syntax: audioObj = ita_multiply_dat( itaAudioA , itaAudioB )
%
%   See also ita_divide_spk, ita_multiply_spk, ita_sqrt, ita_power.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_multiply_dat">doc ita_multiply_dat</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de

% TODO: finding a better solution for multiplication with a factor, as the
% history gets messed up

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>


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
    pList = ita_parametric_GUI(pList,[mfilename ' - Multiply two itaAudio objects in Time Domain']);
    if ~isempty(pList)
        result = ita_multiply_dat(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end

narginchk(2,2);

sArgs   = struct('pos1_num','itaSuper','pos2_den','anything');
sArgs   = ita_parse_arguments(sArgs,varargin);
num     = sArgs.num;
den     = sArgs.den;

%% check nominator and denumerator
if isa(den,'itaValue') || isnumeric(den)
    varargout{1} = ita_amplify(num,1/den); %re-route to ita_amplify
    return;
elseif isFreq(den)
    den = den.';
end

if isFreq(num)
    num = num.';
end

result = num.*den;

%% Find what domain is requested - Always the result domain goes out
varargout(1) = {result};