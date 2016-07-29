function node = xml_create_complex_array_node(document, name, A, order)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    node = document.createElement(name);
    attr_shape = document.createAttribute('shape');
    attr_shape.setValue(ita_utils_matrix_to_string(size(A), order, '%d'));
    attr_order = document.createAttribute('order');
    attr_order.setValue(order);
    subnode_value = document.createElement('value');
    subnode_value.appendChild(document.createTextNode(ita_utils_matrix_to_string(abs(A), order)));
    subnode_angle = document.createElement('angle');
    subnode_angle.appendChild(document.createTextNode(ita_utils_matrix_to_string(angle(A), order)));
    node.setAttributeNode(attr_shape);
    node.setAttributeNode(attr_order);
    node.appendChild(subnode_value);
    node.appendChild(subnode_angle);
end