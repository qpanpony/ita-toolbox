function objHandle = ita_guisupport_getParentFigure(objHandle)
% get handle of parent figure

while ~isempty(objHandle) && ~strcmpi( get(objHandle,'Type'), 'figure' )
  objHandle = get(objHandle,'Parent');
end