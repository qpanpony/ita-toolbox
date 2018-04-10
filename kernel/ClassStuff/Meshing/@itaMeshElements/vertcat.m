function varargout = vertcat(varargin)

%Concatenates elements vertically

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


result = varargin{1};
tmpID = varargin{1}.ID(:);
tmpNodes = varargin{1}.mNodes;
varargin(1) = [];
while numel(varargin) > 0
    if numel(unique([tmpID(:); varargin{1}.ID(:)])) < numel(tmpID(:))+numel(varargin{1}.ID(:))
       ita_verbose_info('itaMeshElements.vertcat:elements have been renumbered due to ID conflicts',0);
       tmpID = [tmpID(:); varargin{1}.ID(:)+max(tmpID)];
    else
       tmpID = [tmpID(:); varargin{1}.ID(:)]; 
    end
    tmpNodes = [tmpNodes; varargin{1}.mNodes];
    varargin(1) = [];
end
result.mNodes = tmpNodes;
result.ID = tmpID;
varargout = {result};
end