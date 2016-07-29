function ita_plottools_reduce(varargin)
%ITA_PLOTTOOLS_REDUCE - Reduce number of lines in plot
%  This function will reduce the number of lines in a plot (e.g. for an export with ita_savethisplot)
%  The result will be faster as pdf or whatever.
%
%  Syntax:
%   ita_plottools_reduce(Options)
%
%       Options: (default)
%           'fgh'       (gcf)       - Handle of figure or axes that shall be reduced
%           'tolerance' (std(data)) - Tolerance of error (higher tolerance return less points) - empty for auto-mode
%
%  Example:
%   a = ita_demosound(); a.plot_spk; ita_plottools_reduce();
%   a = ita_demosound(); a.plot_spk; ita_plottools_reduce('tolerance',3);
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_reduce">doc ita_plottools_reduce</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  11-May-2010


sArgs = struct('fgh',gca, 'tolerance', [],'factor',0.1);
sArgs = ita_parse_arguments(sArgs,varargin);

lines = findobj(sArgs.fgh,'Type','Line');

for idx = 1:numel(lines)
    
    x = get(lines(idx),'XData');
    y = get(lines(idx),'YData');
    
    x = x(:);
    y = y(:);
    
    orig_size = numel(x);
    
    
    if idx == 1
        xy = [x; y].';
    else
        xy = [xy y.'];
    end
end

if isempty(sArgs.tolerance)
    %sArgs.tolerance = 0.1*nanstd(sqrt(sum(diff(xy).^2,2)));
    sArgs.tolerance = prctile(sqrt(sum(diff(xy).^2,2)),100*(1-sArgs.factor));
    ita_verbose_info(['ita_plottools_reduce: Auto-Tolerance: ' num2str(sArgs.tolerance)],1  )
end

xy = dpsimplify(xy,sArgs.tolerance);

x = xy(:,1).';
y = xy(:,2:end).';

return_size = numel(x);

ita_verbose_info(['ita_plottools_reduce: Reduced from ' int2str(orig_size) ' to ' int2str(return_size) ' points'],1  )

for idx = 1:numel(lines)
    set(lines(idx),'XData',x,'YData',y(idx,:));
end


end
