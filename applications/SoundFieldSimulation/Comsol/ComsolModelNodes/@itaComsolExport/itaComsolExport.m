classdef itaComsolExport < itaComsolNode
    %itaComsolExport Interface to the result.export nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolExport(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'export',...
                'com.comsol.clientapi.impl.ExportFeatureClient', comsolModel.modelNode.result)
        end
    end
    
    %% Execute export
    methods
        function Run(obj, filename)
            %Executes the active export node and optionally sets the file
            %destination first
            assert(~isempty(obj.activeNode), 'No active export node specified.')
            if nargin == 1
                itaComsolExport.runExportNode(obj.activeNode)
            else
                assert(ischar(filename) && isrow(filename), 'Input must be a char row vector')
                itaComsolExport.runExportNode(obj.activeNode, filename)
            end
        end
        function RunSpecific(obj, nodeID, filename)
            %Executes an Export node given its label/name, its tag or its
            %index. Optionally, a filename can be specified.
            %   If given a char row vector, first the names and then the
            %   tags are checked. Throws an error if node does not exist.
            assert(isscalar(nodeID) && isnumeric(nodeID) && mod(nodeID,1)==0 ||...
                ischar(nodeID) && isrow(nodeID),...
                'Input must be either a char row vector or a single integer')
            if nargin == 3
                assert(ischar(filename) && isrow(filename),...
                    'Second (optional) input must be a char row vector')
            else
                filename = [];
            end
            
            if ischar(nodeID)
                exportNodeToRun = obj.ChildByName(nodeID);
                if isempty(exportNodeToRun)
                    exportNodeToRun = obj.Child(nodeID);
                end
            else
                exportNodeToRun = obj.ChildByIndex(nodeID);
            end
            assert(~isempty(exportNodeToRun), 'Export node not found')
            
            obj.runExportNode(exportNodeToRun, filename);
        end
    end
    methods(Access = private, Static = true)
        function runExportNode(exportNode, filename)
            if nargin == 2 && ~isempty(filename)
                exportNode.set('filename', filename);
            end
            exportNode.run();
        end
    end
end