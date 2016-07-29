function varargout = ita_subtract(varargin)
%ita_subtract - Subtract b from a (a - b)
%  This function subtracts b from a. There is no difference in which domain
%  the subtraction is done. If there are different domains, the result will
%  be returned in the domain of the first signal.
%
%  Syntax: spk = ita_subtract(a, b)
%
%   See also ita_add, ita_multiply_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_subtract">doc ita_subtract</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Nov-2008



%% Initialization
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the first itaAudio for addition';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Second itaAudio';
    pList{ele}.helptext    = 'This is the second itaAudio for addition';
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
    pList = ita_parametric_GUI(pList,[mfilename ' - Subtract two itaAudio objects']);
    if ~isempty(pList)
        result = ita_subtract(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end

%%
narginchk(2,2);
% Find Audio Data

sArgs   = struct('pos1_a','itaSuper','pos2_b','anything');
[a,b,sArgs] = ita_parse_arguments(sArgs,varargin); 

result = a - b;
%% Find output parameters
varargout(1) = {result};
%end function
end