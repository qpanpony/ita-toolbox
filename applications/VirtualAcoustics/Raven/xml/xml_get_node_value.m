function s = xml_get_node_value(root, path, sep)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    if nargin > 1
        if nargin < 3
            sep = '/';
        end
        root = xml_get_node(root, path, sep);
    end
    
    s = char(root.item(0).getNodeValue);

end