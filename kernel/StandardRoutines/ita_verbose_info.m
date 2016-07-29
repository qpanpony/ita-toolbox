function  ita_verbose_info(varargin)
%ITA_VERBOSE_INFO - Warning/ Informing Function of ITA-Toolbox
%  This function displays warning or informing messages dependent of the
%  verboseLevel configured in ita_preferences (ita_preferences('verboseMode',
%  verboseLevel)). Level 0 should only be important warnings, level 1 should be
%  all other warnings, while level 2 should be informations not very
%  important.
%
%
%  Syntax:
%   ita_verbose_info('Message', verboseLevel)
%
%   Options (default):
%           'Message'               : Message as a string
%           verboseLevel (default=2): number between 0-2
%
%  Example:
%   ita_verbose_info('This is an information');
%   ita_verbose_info('This is a warning', 1);
%   ita_verbose_info('This is an important warning', 0);
%
%   Please call inside other function with:
%   ita_verbose_info([thisFuncStr ' Warning'], 1);
%
%   Please do not forget: Errors should be placed with error('Error message');
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_verbose_info">doc ita_verbose_info</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  16-Nov-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  % Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

% Initialization and Input Parsing
narginchk(1,2);

% recognize input parameters
if ~(ischar(varargin{1}))
    error([thisFuncStr ' See your Syntax!']);
elseif nargin == 2
    if (varargin{2} ~= 0 && varargin{2} ~= 1 && varargin{2} ~=2 && varargin{2} ~=-1)
        error([thisFuncStr ' See your Syntax!']);
    end
end

%% read input
mes = varargin{1};

stackStruct = dbstack;
if numel(stackStruct) > 1
    caller = stackStruct(2).file(1:end-2);
else
    caller = '';
end


if isempty(strfind(lower(mes), lower(caller)))  % mes contains no functionname
    mes = [ upper(caller) ': ' mes];
end
    
%%
if nargin == 1
    signif = 2;
else
    signif = varargin{2};
end

if signif == -1
    niceColor = [.5 .2 .8];
    cdisp(niceColor,'*******************************************************************')
    cdisp(niceColor,mes)
    cdisp(niceColor,'*******************************************************************')
    
elseif signif <= verboseMode
    % check if we are in desktop mode or in console
    if usejava('jvm') && exist('cdisp','file')
        colormap=cell(3,1);
        % red ; blue ; green
        colormap{1} =[1 .1 .1]; colormap{2}='Blue'; colormap{3}=[.1 .6 .1];
        cdisp(colormap{signif+1}, mes);
    else
        disp(mes);
    end
end

end

