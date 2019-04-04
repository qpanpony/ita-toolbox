function s = xml_get_attribute_value(root, path, sep)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


    if nargin < 3
        sep = '/';
    end
    
    if ischar(path)
        path = split(path, sep);
    end
    
    if numel(path) > 1
        root = xml_get_node(root, path(1:end-1), sep);
    end
    
    if ~iscell(root)
        s = char(root.getAttribute(path(end)));
    else
        for index = 1:numel(root)
            s{index} = char(root{index}.getAttribute(path(end)));
        end
    end

end