function node = xml_get_node(root, path, sep)

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


    if ~isscalar(root)
        % Error: Ambiguous path
        % Maybe allow multiple roots later
        exception = MException('fdda:xml:ambiguousPathError', ...
            sprintf('Ambiguous path. (Maybe support multiple root and non-leaf nodes later.)') ...
            );
        throw(exception);
    end

    if nargin < 3
        sep = '/';
    end
    
    if ischar(path)
        path = split(path, sep);
    end
    
    if ~iscell(path)
        exception = MException('fdda:xml:inputTypeError', ...
            sprintf('Path has to be a string or a cell array of strings.') ...
            );
        throw(exception);
    end
    
    if numel(path) > 1
        node = xml_get_node(xml_get_node(root, path(1), sep), path(2:end), sep);
    else
        index = find(strcmp(path{1}, xml_list_child_nodes(root))) - 1;
        if isempty(index)
            exception = MException('fdda:xml:invalidPathError', ...
                sprintf('Node "%s" does not exist.', path{1}) ...
                );
            throw(exception);
        else
            if isscalar(index)
                node = root.item(index);
            else
                for idx = 1:numel(index)
                    node{idx} = root.item(index(idx));
                end
            end
        end
    end
    
end