function node = xml_create_string_node(document, name, value)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    node = document.createElement(name);
    node.appendChild(document.createTextNode(value));
end