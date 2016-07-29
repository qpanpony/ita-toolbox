function varargout = ita_colorbarLabel(varargin)
%ITA_COLORBARLABEL - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_colorbarLabel(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_colorbarLabel(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_colorbarLabel">doc ita_colorbarLabel</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  16-Jun-2014 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','', 'figure_handle', gcf);
[labelText, sArgs] = ita_parse_arguments(sArgs,varargin); 

colorbarHandles = get(findobj(get(sArgs.figure_handle, 'children'), 'tag', 'Colorbar'), 'YLabel');
nColorbars = numel(colorbarHandles);
if ischar(labelText)
    labelText = repmat({labelText}, nColorbars,1);
elseif iscell(labelText) 
    if numel(labelText) == 1
        labelText = repmat(labelText, nColorbars,1);
    elseif numel(labelText) ~= nColorbars
        error('Found %i colorbars. Text input has to be of size %i or 1!', nColorbars, nColorbars)
    end
    
end

for iColorbar = 1:nColorbars
    set(colorbarHandles{iColorbar}, 'string', labelText{iColorbar})
end
%end function
end