function varargout = ita_roomacoustics_uncertainty(varargin)
%ITA_ROOMACOUSTICS_UNCERTAINTY - Uncertainties in RT (ISO 3382)
%  This function calculates the uncertainty calculated by the formula given
%  in EN ISO 3382-1:2009 for T20 and T30. Please keep the GUM in mind !!!
%
%  Syntax:
%   audioObj = ita_roomacoustics_uncertainty(reverberationTime)
%
%  Example:
%   audioObj = ita_roomacoustics_uncertainty(audioObj)
%
%   See also: ita_roomacoustics.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_roomacoustics_uncertainty">doc ita_roomacoustics_uncertainty</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  14-Aug-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% % % narginchk(1,1);
% % % sArgs        = struct('pos1_data','itaAudio');
% % % [data,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
% % % 
% % % %% +++Body - Your Code here+++ 'result' is an audioObj and is given back 
% % % T = data.data;

if nargin == 1
    T = varargin{1};
else
    T = 1;
end

f_center_oct  = ita_ANSI_center_frequencies([125 8000],1);
f_center_3oct = ita_ANSI_center_frequencies([125 8000],3);
T_oct         = f_center_oct .* 0 + T;
T_3oct        = f_center_3oct .* 0 + T;

%bandwidth in Hertz
B_oct = 0.71 * f_center_oct;
B_3oct = 0.23 * f_center_3oct;


%n number of measurements per position pair
n = 1;

%N number of measurements used for averaging over the room (different position pairs)
N = 1;

sigmaT20_oct = 0.88 .* T_oct .* sqrt((1+1.9 /n)./(N * B_oct  .* T_oct));
sigmaT30_oct = 0.55 .* T_oct .* sqrt((1+1.52/n)./(N * B_oct  .* T_oct));
sigmaT20_3oct = 0.88 .* T_3oct .* sqrt((1+1.9 /n)./(N * B_3oct .* T_3oct));
sigmaT30_3oct = 0.55 .* T_3oct .* sqrt((1+1.52/n)./(N * B_3oct .* T_3oct));

disp(' ')
cprintf('blue',['Result for ' num2str(n) ' measurement(s) per IR and ' num2str(N) ' IR(s) per room.\n' ])
disp(' ')
cprintf('-green','For Octaves:\n')
disp('  Freq    T [s]  sigma [s]')
for idx = 1:length(T_oct) 
    disp(['  ' sprintf('%4.0f',f_center_oct(idx)) '    ' sprintf('%0.2f',T_oct(idx)) '      ' sprintf('%0.2f',sigmaT20_oct(idx))]);
end
disp(' ')
cprintf('-green','For Third-Octaves:\n')
disp('  Freq    T [s]  sigma [s]')
for idx = 1:length(T_3oct) 
    disp(['  ' sprintf('%4.0f',f_center_3oct(idx)) '    ' sprintf('%0.2f',T_3oct(idx)) '      ' sprintf('%0.2f',sigmaT20_3oct(idx))]);
end



% % % result = 1;
% % % 
% % % 
% % % 
% % % %% Add history line
% % % result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);
% % % 
% % % %% Check header
% % % %result = ita_metainfo_check(result);
% % % 
% % % %% Find output parameters
% % % if nargout == 0 %User has not specified a variable
% % %     % Do plotting?
% % %     
% % % else
% % %     % Write Data
% % %     varargout(1) = {result}; 
% % % end

%end function
end