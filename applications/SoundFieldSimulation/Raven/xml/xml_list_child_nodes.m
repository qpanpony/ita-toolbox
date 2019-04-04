function list = xml_list_child_nodes(node)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

list = {};

index = 0;
while ~isempty(node.item(index))
    list = [list {xml_get_node_name(node.item(index))}];
    index = index + 1;
end

end