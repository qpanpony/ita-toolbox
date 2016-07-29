function display(this)
%show the Obj

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if ita_preferences('nakedClasses')
    builtin('disp',this)
else
    % right now, only one instance
    if numel(this) == 0
        disp('****** nothing to do, empty object ******')
    elseif numel(this) > 1
        disp(['size(' inputname(1) ') = [' num2str(size(this))  ']; (for full display, pick a single instance)']);
    else
        %% start plotting
        this.displayLineStart
        disp(this)
        this.displayChannelString(@ita_metainfo_show_channelnames);
        this.displayOptions('dispVerboseErrors', @ita_errorlog_show);

    end
end
end
