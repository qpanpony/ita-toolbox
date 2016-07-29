function varargout = ita_struct2arguments(varargin)
%ITA_STRUCT2ARGUMENTS - Convert argument structure back to cellArray
%
%  Syntax: cellArray = ita_struct2arguments(sArgs)
%
%
% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  23-Feb-2009 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
varargin{1} = struct(varargin{1}); %pdi: bugfix for new itaMeausrementSetup class
sArgs        = struct('pos1_data','struct');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 


f = fieldnames(data);
c = struct2cell(data);

Result = [f c].';
Result = reshape(Result,numel(Result),1);


%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {Result}; 
end

%end function
end