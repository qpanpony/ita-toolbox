function ita_clabel(varargin)
%ITA_CLABEL - set colorbar label 
%  This function sets a label to colorbar
%
%  Syntax:
%    ita_clabel()
%
%   Options (default):
%           'figure_handle' (gcf) : specify figure handle
%
%  Example:
%   ita_clabel(audioObjIn)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_clabel">doc ita_clabel</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  01-Jul-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_label', [] , 'figure_handle',gcf);
sArgs = ita_parse_arguments(sArgs,varargin); 


%%


colorbarHandles = findobj(sArgs.figure_handle,  'tag', 'Colorbar');

nColorbars = numel(colorbarHandles);

if ~nColorbars
    ita_verbose_info('no colorbars found',0)
    return
end


if nColorbars == 1
    set(get(colorbarHandles, 'ylabel'), 'string', sArgs.label);             % one colorbar & one label
elseif ischar(sArgs.label)
    set(cell2mat(get(colorbarHandles, 'ylabel')), 'string', sArgs.label)    % more than one bar & one label
else
    if ~iscell(sArgs.label)
        error('to label more than one colobar independently label has to be cell')
    end
    for iBar = 1:nColorbars
        set(get(colorbarHandles(nColorbars - iBar +1), 'ylabel'), 'string', sArgs.label{iBar})
    end
end
    


%end function
end