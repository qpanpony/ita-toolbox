function node = xml_create_real_array_node(document, name, A, order)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    node = document.createElement(name);
    attr_shape = document.createAttribute('shape');
    attr_shape.setValue(ita_utils_matrix_to_string(size(A), order, '%d'));
    attr_order = document.createAttribute('order');
    attr_order.setValue(order);
    node.appendChild(document.createTextNode(ita_utils_matrix_to_string(A, order)));
    node.setAttributeNode(attr_shape);
    node.setAttributeNode(attr_order);
end