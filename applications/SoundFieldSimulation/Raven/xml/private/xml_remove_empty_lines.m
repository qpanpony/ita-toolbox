function node = xml_remove_empty_lines(node)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

index = 0;
while true
    subnode = node.item(index);
    
    if isempty(subnode)
        break;
    end
    
    if strcmp(subnode.class, 'org.apache.xerces.dom.DeferredTextImpl')
        if strcmp(sscanf(subnode.getNodeValue.toCharArray, '%s'), '')
            node.removeChild(subnode);
        else
            index = index + 1;
        end
    else
        xml_remove_empty_lines(subnode);
        index = index + 1;
    end
end

end