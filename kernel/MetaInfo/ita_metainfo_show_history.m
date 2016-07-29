function ita_metainfo_show_history(varargin)
%ITA_HEADER_SHOW_HISTORY - Show Variable History
%  This function plots the history of the variable on the screen. This
%  history is used to see which function was used on the data. Parameters
%  will be shown as well if applicable.
%
%  Syntax: ita_header_show_history(audioObj)
%  Syntax: ita_header_show_history(header)
%  Syntax: ita_header_show_history(HistoryCells)
%
%   See also ita_header_add_historyline, ita_header_rm_historyline 
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_header_show_history">doc ita_header_show_history</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 26-Sep-2008 



%% Initialization
% Number of Input Arguments
narginchk(1,2);
sub_call = false; %used to determine subcalls
% Find Audio Data
if isa(varargin{1},'itaSuper')
    %domainType = ita_get_domain(varargin{1});
    history = varargin{1}.history;
    pre_string = '';
elseif iscell(varargin{1}) %input is already history list
    history  = varargin{1};
    sub_call = true;
    pre_string = ['  ' varargin{2}];
else
    error('ita_metainfo_show_history:Oh Lord. Only structs and cellstr allowed.')
end

fixed_pre = '      ';%'___';

%% Plot history
% if ~sub_call
%     varargin{1}.displayLineMiddle('dispVerboseHistory');
% else
%     fprintf([pre_string '    >'])
% end

for idx = 1:length(history) %step through entries
    token = history{idx};
    if isstruct(token)
       if isfield(token,'ChannelSettings')
           token = 'ita_measurement_settings';  
       else
           token = 'struct';
       end        
    end
    if iscell(token) %|| iscell(token) %sub cell will be plotted recursively
        %         disp([pre_string '   ---------- SUB CELL INFO START ----------------------------'])
        %         disp([pre_string '   ---------- SUB CELL INFO START ----------------------------'])
%         fprintf([pre_string '    >'])
        ita_metainfo_show_history(token,pre_string);
        %         disp([pre_string '   ---------- SUB CELL INFO END
        %         ------------------------------'])
    else
        if (idx == 1) && sub_call
                    disp([fixed_pre pre_string(1:end-2) '+ ' token]) %token
        else
                    disp([fixed_pre pre_string '' token]) %token
        end

    end
end
% % display a line and give the appropriate preference for showing it
% if ~sub_call, varargin{1}.displayLineMiddle('dispVerboseHistory'), end

%end function
end