function varargout = vertcat(varargin)

%Concatenates node IDs of given itaMeshGroup objects of same type vertically

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


result = varargin{1};
tmpID = varargin{1}.ID(:);
tmpType = varargin{1}.type;
varargin(1) = [];
while numel(varargin) > 0 && strcmpi(varargin{1}.type,tmpType)
    if numel(unique([tmpID(:); varargin{1}.ID(:)])) < numel(tmpID(:))+numel(varargin{1}.ID(:))
       ita_verbose_info('itaMeshGroup.vertcat:nodes have been renumbered due to ID conflicts',0);
       tmpID = [tmpID(:); varargin{1}.ID(:)+max(tmpID)];
    else
       tmpID = [tmpID(:); varargin{1}.ID(:)]; 
    end
    varargin(1) = [];
end
if numel(varargin) > 0
    ita_verbose_info('itaMeshGroup.vertcat:not all groups have been concatenated, possibly types do not match',0);
end
result.ID = tmpID;
varargout = {result};
end