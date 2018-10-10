classdef itaComsolModel < handle
    %itaComsolModel Interface to adjust work with comsol model
    %   This class takes an existing comsol model and provides interfaces
    %   to adjust certain parameters such as boundary conditions
    %   (impedances) and sources. Also provides the function to run a
    %   simulation and gather results in ita-formats.
    %   
    %   Note, that it is crucial to define the basis of the comsol model in
    %   Comsol itself. This includes:
    %   -Geometry
    %   -Materials
    %   -Physics
    %       -especially, impedances at boundaries
    %   -Mesh
    %   -Study
    %
    %   This class is able to create/adjust:
    %   -Global Definitions
    %       -Interpolations
    %   -Geometry
    %       -for sources (points / boundary surfaces)
    %
    %   This class is able to adjust:
    %   -Materials
    %       -...(to be added in future)
    %   -Physics
    %       -frequency dependent values for boundary impedances
    %       -frequency dependent source parameters (velocity / pressure)
    %   -Mesh
    %       -... ()
    %   -Study
    %       -frequency vector
    
    properties(Access = private)
        mModel;         %Comsol model (com.comsol.clientapi.impl.ModelClient)
        
        mCurrentGeometry;
        mCurrentPhysics;
        mCurrentMesh;
        mCurrentStudy;
    end
    
    properties(Dependent = true)
        currentGeometry;%Currently used geometry node. Geometry based operations are processed on this node if not specified differently.
        currentPhysics; %Currently used physics node. Physics based operations are processed on this node if not specified differently.
        currentMesh;    %Currently used mesh node. Mesh based operations are processed on this node if not specified differently.
        currentStudy;   %Currently used study node. Study based operations are processed on this node if not specified differently.
    end
    
    methods
        function out = get.currentGeometry(obj)
            out = obj.mCurrentGeometry;
        end
        function out = get.currentPhysics(obj)
            out = obj.mCurrentPhysics;
        end
        function out = get.currentMesh(obj)
            out = obj.mCurrentMesh;
        end
        function out = get.currentStudy(obj)
            out = obj.mCurrentStudy;
        end
        function set.currentGeometry(obj, input)
            assert(isa(input, 'com.comsol.clientapi.impl.GeomSequenceClient'), 'Input must be a Comsol geometry node')
            obj.mCurrentGeometry = input;
        end
        function set.currentPhysics(obj, input)
            assert(isa(input, 'com.comsol.clientapi.impl.PhysicsClient'), 'Input must be a Comsol physics node')
            obj.mCurrentPhysics = input;
        end
        function set.currentMesh(obj, input)
            assert(isa(input, 'com.comsol.clientapi.impl.MeshSequenceClient'), 'Input must be a Comsol mesh node')
            obj.mCurrentMesh = input;
        end
        function set.currentStudy(obj, input)
            assert(isa(input, 'com.comsol.clientapi.impl.StudyClient'), 'Input must be a Comsol study node')
            obj.mCurrentStudy = input;
        end
    end
    
    
    %% Constructor
    methods
        function obj = itaComsolModel(comsolModel)
            if ~isa(comsolModel, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must be a comsol model (com.comsol.clientapi.impl.ModelClient)')
            end
            obj.mModel = comsolModel;
            
            obj.mCurrentGeometry = obj.FirstGeometry();
            obj.mCurrentPhysics = obj.FirstPressureAcoustics();
            obj.mCurrentMesh = obj.FirstMesh();
            obj.mCurrentStudy = obj.FirstStudy();
            
            assert(isempty(obj.mCurrentGeometry), 'No Comsol geometry node found')
            assert(isempty(obj.mCurrentPhysics), 'No Comsol physics node found')
            assert(isempty(obj.mCurrentMesh), 'No Comsol mesh node found')
            assert(isempty(obj.mCurrentStudy), 'No Comsol study node found')
        end
    end
    
    %% Global Definitions
    methods
        function interpolationNode = CreateInterpolation(obj, functionName, propertyStruct)
            %Creates an Interpolation with the given function name (if not
            %already existing) and returns it. Optionally, the function
            %properties can be set using a property struct.
            %   The function name must be a valid Matlab variable name (no
            %   whitespace, not starting with a number and so on...).
            %   The property struct has the property names as field names
            %   and the respective property values as the field values
            assert(ischar(functionName) && isrow(functionName), 'First input must be a char row vector')
            assert(isvarname(functionName), 'First input must be a valid variable name')
            if nargin > 2; assert(isstruct(propertyStruct), 'Second input must be a struct with function properties'); end
            
            if ~obj.hasChildNode(obj.mModel.func, functionName)
                obj.mModel.func.create(functionName, 'Interpolation');
            end
            
            obj.mModel.func(functionName).label(functionName);
            interpolationNode = obj.mModel.func(functionName);
            
            if nargin == 2; return; end
            obj.setNodeProperties( interpolationNode, propertyStruct );
        end
    end
    methods(Access = private)
        function [realInterpolationNode, imagInterpolationNode] = createComplexInterpolation(obj, interpolationBaseName, freqVector, complexDataVector, functionUnits)
            %Creates or adjusts two Comsol Interpolation nodes, one for the
            %real and one for the imaginary data and returns the two
            %interpolation nodes.
            %   The interpolation tags are interpolationBaseName_real and
            %   interpolationBaseName_imag. The argument units are set to
            %   Hz whereas the function units are specified by the user.
            %   Default methods are "piecewise cubic" interpolation and
            %   "linear" extrapolation.
            interpolationNameReal = [interpolationBaseName '_real'];
            interpolationNameImag = [interpolationBaseName '_imag'];
            
            realInterpolationNode = obj.CreateInterpolation(interpolationNameReal);
            imagInterpolationNode = obj.CreateInterpolation(interpolationNameImag);
            
            propertyStruct.source = 'table';
            propertyStruct.argunit = 'Hz';
            propertyStruct.fununit = functionUnits;
            propertyStruct.extrap = 'linear';
            propertyStruct.interp = 'piecewisecubic';
            
            obj.setNodeProperties(realInterpolationNode, propertyStruct);
            obj.setNodeProperties(imagInterpolationNode, propertyStruct);
            
            obj.setInterpolationTableData(realInterpolationNode, freqVector, real(complexDataVector));
            obj.setInterpolationTableData(imagInterpolationNode, freqVector, imag(complexDataVector));
        end
    end
    methods(Access = private, Static = true)
        function setInterpolationTableData(interpolationNode, argumentVector, functionVector)
            assert(isreal(argumentVector) && isreal(functionVector), 'Data vectors for Comsol interpolation must be real valued')
            if isrow(argumentVector); argumentVector = argumentVector.'; end
            if isrow(functionVector); functionVector = functionVector.'; end
            
            %Note: Comsol expects a Nx2 cell string array for the table data
            comsolTableData = [ cellstr( num2str(argumentVector) ) cellstr( num2str(functionVector) )];
            interpolationNode.set('table', comsolTableData);
        end
    end
    
    %% Geometry
    methods
        function geom = Geometry(obj)
            %Returns all geometry nodes as cell array
            geom = obj.getRootElementChildren('geom');
        end
        function geom = FirstGeometry(obj)
            %Returns the first geometry node if atleast one geometry exists
            geom = obj.getFirstRootElementChild('geom');
        end
    end
    methods(Static = true)
        function [pointNode, selectionTag] = createPointWithSelection(geomNode, pointTag, coords)
            pointNode = itaComsolModel.createPoint(geomNode, pointTag, coords);            
            pointNode.set('selresult', true);
            pointNode.set('selresultshow', 'pnt');
            
            selectionTag = [char(geomNode.tag) '_' pointTag '_pnt'];
        end
        function pointNode = createPoint(geomNode, pointTag, coords)
            assert(isa(geomNode, 'com.comsol.clientapi.impl.GeomSequenceClient'), 'First input must be a Comsol geometry node')
            assert( (isnumeric(coords) && isvector(coords) && numel(coords)==3) ||...
                (isa(coords, 'itaCoordinates') && coords.nPoints==1), 'Third input must be a cartesian vector or a single itaCoordinates');
            
            if ~itaComsolModel.hasFeatureNode(geomNode, pointTag)
                geomNode.create(pointTag, 'Point');
                geomNode.feature(pointTag).label(pointTag);
            end
            
            if isa(coords, 'itaCoordinates'); coords = coords.cart; end
            if isrow(coords); coords = coords.'; end
            
            pointNode = geomNode.feature(pointTag);
            pointNode.set('p', coords);
            geomNode.run();
        end
        
        function pointNode = getPointNodeByTag(geomNode, pointTag)
            [~, pointNode] = itaComsolModel.hasFeatureNode(geomNode, pointTag);
        end
    end
    
    %% Selections == Groups
    methods
        function select = Selection(obj)
            %Returns all selection nodes as cell array
            select = obj.getRootElementChildren('selection');
        end
        function boundaryGroups = BoundaryGroups(obj)
            %Returns all boundary groups (2D selections) as cell array
            boundaryGroups = obj.selectionsOfDimension(2);
        end
        function volumeGroups = VolumeGroups(obj)
            %Returns all volume groups (3D selections) as cell array
            volumeGroups = obj.selectionsOfDimension(3);
        end
        
        function boundaryGroupNames = BoundaryGroupNames(obj)
            %Returns the names of all boundary groups (2D selections) as cell array
            boundaryGroupNames = obj.selectionNames(obj.BoundaryGroups());
        end
        function boundaryGroupNames = VolumeGroupNames(obj)
            %Returns the names of all volume groups (3D selections) as cell array
            boundaryGroupNames = obj.selectionNames(obj.VolumeGroups());
        end
    end
    
    methods(Access = private)
        function selections = selectionsOfDimension(obj, dimension)
            selections = obj.Selection();
            if isempty(selections); return; end
            
            removeSelections = false(size(selections));
            for idxSelection = 1:numel(selections)
                if ~isequal(selections{idxSelection}.dimension, dimension)
                    removeSelections(idxSelection) = true;
                end
            end
            selections(removeSelections) = [];
        end
        function selNames = selectionNames(~, selections)
            selNames = cell(size(selections));
            for idxSelection = 1:numel(selections)
                selNames{idxSelection} = char( selections{idxSelection}.name );
            end
        end
    end
    
    %% Materials
    methods
        function materials = Material(obj)
            %Returns all material nodes as cell array
            materials = obj.getRootElementChildren('material');
        end
    end
    
    %% Physics
    methods
        function physics = Physics(obj)
            %Returns all physics nodes as cell array
            physics = obj.getRootElementChildren('physics');
        end
        function physics = FirstPhysics(obj)
            %Returns the first physics node
            physics = obj.getFirstRootElementChild('physics');
        end
        function pressureAcoustics = PressureAcoustics(obj)
            %Returns all physics nodes of type Pressure Acoustics
            physics = obj.getRootElementChildren('physics');
            idxPressureAcoustics = false(size(physics));
            for idxPhysics = 1:numel(physics)
                idxPressureAcoustics(idxPhysics) =...
                    contains(char( physics{idxPhysics}.getType ), 'PressureAcoustics');
            end
            pressureAcoustics = physics(idxPressureAcoustics);
        end
        function pressureAcoustics = FirstPressureAcoustics(obj)
            %Returns the first physics node of type Pressure Acoustics
            pressureAcoustics = obj.PressureAcoustics();
            if isempty(pressureAcoustics)
                pressureAcoustics = [];
            else
                pressureAcoustics = pressureAcoustics{1};
            end
        end
    end
    methods(Static=true)
        function bool = IsBoundaryMethod(physics)
            assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'Input must be a Comsol physics node')
            bool = strcmp(physics.getType, 'PressureAcousticsBoundaryElements') ||...
                strcmp(physics.getType, 'BoundaryModeAcoustics');
        end
    end
    %------Impedance-------------------------------------------------------
    methods
        function impedanceNodes = ImpedanceNodes(obj, physics)
            %Returns the impedance nodes for the given physics node. If the
            %physics node is left empty or not passed the default one will
            %be used
            if nargin == 1
                physics = obj.mCurrentPhysics;
                assert(~isempty(physics), 'No default physics node specified')
            else
                assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'Input must be a Comsol Physics node')
            end
            impedanceNodes = obj.getChildNodesByType(physics, 'Impedance');
        end
        
        function SetBoundaryGroupImpedance(obj, boundaryGroupName, data, physics)
            %Sets the data of the impedance node for the given boundary group
            %(=label of a 2D selection in Comsol). The data can either be
            %passed using an itaMaterial or an itaResult/itaAudio.
            %   Optionally, a physics node can be passed, if you do not
            %   want to work on currentPhysics
            if nargin == 3
                physics = obj.mCurrentPhysics;
                assert(~isempty(physics), 'No default physics node specified');
            end
            
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'First input must be a char row vector')
            if isa(data, 'itaMaterial'); data = data.impedance; end
            assert(isa(data, 'itaSuper') && numel(data) == 1 && data.nChannels == 1,...
                'Second input must either be an itaMaterial with a valid impedance or a single itaSuper')
            assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'First input must be a Comsol Physics node')
            
            freqVector = data.freqVector;
            freqData = data.freqData;
            
            impedanceNodeOfBoundary = obj.impedanceNodeByBoundaryGroupName(physics, boundaryGroupName);
            if isempty(impedanceNodeOfBoundary); error('A Comsol impedance node for the given boundary group does not exist'); end
            
            interpolationBaseName = [strrep(boundaryGroupName, ' ', '_') '_impedance'];
            obj.setImpedanceViaInterpolation(impedanceNodeOfBoundary, interpolationBaseName, freqVector, freqData);
        end
    end
    methods(Access = private)
        function impedanceNodeOfBoundary = impedanceNodeByBoundaryGroupName(obj, physics, boundaryGroupName)
            %Returns the impedance node of the given physics node that is
            %connected to given boundary group (= Comsol selection). Returns
            %an empty object if no impedance is connected to the given selection.
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Second input must be a char row vector')
            impedanceNodeOfBoundary = [];
            
            idxBoundary = strcmp(obj.BoundaryGroupNames(), boundaryGroupName);
            if sum(idxBoundary) ~= 1; return; end
            boundaryGroup = obj.BoundaryGroups{idxBoundary};
            
            impedanceNodes = obj.ImpedanceNodes(physics);
            for idxImpedance = 1:numel(impedanceNodes)
                selectionTag = impedanceNodes{idxImpedance}.selection.named;
                if strcmp(selectionTag, boundaryGroup.tag)
                    impedanceNodeOfBoundary = impedanceNodes{idxImpedance};
                    return
                end
            end
        end
        function setImpedanceViaInterpolation(obj, impedanceNode, interpolationBaseName, freqVector, complexDataVector)
            %assert( isnumeric(argumentVector)&& isvector(argumentVector) &&...
            %    isnumeric(functionVector) && isvector(functionVector), 'Data vectors must be numeric')
            %assert( numel(argumentVector) == numel(functionVector), 'Both data vectors must be of same length')
            
            [realInterpolationNode, imagInterpolationNode] = obj.createImpedanceInterpolation(...
                interpolationBaseName, freqVector, complexDataVector);
            
            realFuncName = char(realInterpolationNode.tag);
            imagFuncName = char(imagInterpolationNode.tag);
            impedanceExpression = [realFuncName '(freq) + i*' imagFuncName '(freq)'];
            impedanceNode.set('ImpedanceModel', 'UserDefined');
            impedanceNode.set('Zi', impedanceExpression);
        end
        function [realInterpolationNode, imagInterpolationNode] = createImpedanceInterpolation(obj, interpolationBaseName, freqVector, complexDataVector)
            %Creates or adjusts two Comsol Interpolation nodes, one for the
            %real and one for the imaginary impedance data and returns the
            %two interpolation nodes.
            [realInterpolationNode, imagInterpolationNode] = obj.createComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'Pa / m * s');
        end
    end
    %------Sources---------------------------------------------------------
    methods
        function CreatePointSource(obj, source, physics)
            %Creates a point source in physics given an itaSource
            %   Optionally, a physics node can be passed, if you do not
            %   want to work on currentPhysics
            %   In Comsol internally, a point is created for the physics
            %   geometry and then linked to the point source that is
            %   created for the physics
            if nargin == 2
                physics = obj.mCurrentPhysics;
                assert(~isempty(physics), 'No default physics node specified');
            else
                assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'Second input must be a Comsol Physics node')
            end
            assert( ~obj.IsBoundaryMethod(physics), 'Point sources are not allowed for physics with boundary methods')
            assert(isa(source, 'itaSource') && isscalar(source), 'Input must be a single itaSource object')
            
            geometryNode = obj.mModel.geom(physics.geom);
            pointTag = [source.name '_pointSourcePosition'];
            sourceTag = [source.name '_pointSource'];
            
            [~, selectionTag] = obj.createPointWithSelection(geometryNode, pointTag, source.position);
            
            if ~itaComsolModel.hasFeatureNode(physics, sourceTag)
                physics.create(sourceTag, 'FrequencyMonopolePointSource', 0);
            end
            sourceNode = physics.feature(sourceTag);
            sourceNode.selection.named(selectionTag);
            %sourceNode.set('Type', 'UserDefined');
            %sourceNode.set('S', 1);
            %sourceNode.set('Type', 'Power');
            %sourceNode.set('P_rms', 3);
            sourceNode.set('Type', 'Flow');
            sourceNode.set('Qs', 1);
        end
    end
    methods(Access = private, Static = true)
    end
    
    %% Mesh
    methods
        function meshes = Mesh(obj)
            %Returns all mesh nodes as cell array
            meshes = obj.getRootElementChildren('mesh');
        end
        function mesh = FirstMesh(obj)
            %Returns the first mesh node
            mesh = obj.getFirstRootElementChild('mesh');
        end
    end
    
    %% Study
    methods
        function studies = Study(obj)
            %Returns all study nodes as cell array
            studies = obj.getRootElementChildren('study');
        end
        function study = FirstStudy(obj)
            %Returns the first study node
            study = obj.getFirstRootElementChild('study');
        end
        
        function SetAllFrequencyVectors(obj, freqVector)
            %Sets the frequency vector for all frequency domain studies.
            assert(isnumeric(freqVector) && isrow(freqVector), 'Input must be a numeric row vector')
            
            studies = obj.Study();
            idxFreqStudies = false(size(studies));
            for idxStudy = 1:numel(studies)
                idxFreqStudies(idxStudy) = obj.isFreqStudy(studies{idxStudy});
            end
            
            freqStudies = studies(idxFreqStudies);
            if isempty(freqStudies); warning([class(obj) ': No frequency domain study found']); end
            for idxFreqStudy = 1:numel(freqStudies)
                obj.SetFrequencyVector(freqStudies{idxFreqStudy}, freqVector)
            end
        end
    end
    methods(Static = true)
        function SetFrequencyVector(study, freqVector)
            %Sets the frequency vector for the given study. Throws an error
            %if this is not a frequency domain study.
            assert(isa(study, 'com.comsol.clientapi.impl.StudyClient'), 'First input must be a Comsol Study node')
            assert(isnumeric(freqVector) && isrow(freqVector), 'Second input must be a numeric row vector')
            
            [freqNodeDefined, freqNode] = itaComsolModel.hasFeatureNode( study, 'freq' );
            if ~freqNodeDefined; error('Given Comsol study is no frequency study'); end
            
            freqNode.set('plist', num2str(freqVector))
        end
    end
    methods(Static = true, Access = private)
        function bool = isFreqStudy(study)
            [bool, ~] = itaComsolModel.hasFeatureNode( study, 'freq' );
        end
    end

    %% -----------Helper Function Section------------------------------- %%
    %% Root node functions
    methods(Access = private)
        function nodes = getRootElementChildren(obj, rootName)
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            nodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                nodes{idxNode} = obj.mModel.(rootName)(tags(idxNode));
            end
        end
        function node = getFirstRootElementChild(obj, rootName)
            node = [];
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            if isempty(tags); return; end
            node = obj.mModel.(rootName)(tags(1));
        end
    end
    
    %% Functions applying directly to model nodes
    methods(Access = private, Static = true)
        function childNodes = getChildNodes(comsolNode)
            tags = itaComsolModel.getChildNodeTags(comsolNode);
            childNodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                if ismethod(comsolNode, 'feature')
                    childNodes{idxNode} = comsolNode.feature(tags(idxTag));
                else
                    childNodes{idxNode} = comsolNode(tags(idxTag));
                end
            end
        end
        function childNodes = getChildNodesByType(comsolNode, type)
            tags = itaComsolModel.getChildNodeTags(comsolNode);
            childNodes = {};
            for idxTag = 1:numel(tags)
                if ismethod(comsolNode, 'feature')
                    node = comsolNode.feature(tags(idxTag));
                else
                    node = comsolNode(tags(idxTag));
                end
                if strcmp(node.getType, type)
                    childNodes{end+1} = node;
                end
            end
        end
        
        function out = getChildNodeTags(comsolNode)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            if ismethod( comsolNode, 'tags' )
                out = comsolNode.tags();
            elseif ismethod( comsolNode, 'objectNames' )
                out = comsolNode.objectNames();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolModel.getChildNodeTags( comsolNode.feature() );
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return children'])
            end
        end
        
        function out = getNodeType(comsolNode)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            if strcmp(comsolNode.scope(), 'root')
                warning('Root objects do not have a type. Returning name instead.')
                out = comsolNode.name();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolModel.getNodeType( comsolNode.feature() );
            elseif ismethod( comsolNode, 'getType' )
                out = comsolNode.getType();
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return a type'])
            end
        end
        
        function [bool, featureNode] = hasFeatureNode(comsolNode, featureTag)
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            featureNode = [];
            bool = false;            
            if ~ismethod(comsolNode, 'feature'); return; end
            if ~ismethod(comsolNode.feature, 'tags'); return; end
            
            tags = cell(comsolNode.feature.tags);
            idxTag = strcmp(tags, featureTag);
            if sum(idxTag) ~=1; return; end
            
            featureNode = comsolNode.feature( tags(idxTag) );
            bool = true;
        end
        
        function [bool] = hasChildNode(comsolNode, childTag)
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            bool = false;
            if ~ismethod(comsolNode, 'tags'); return; end
            
            tags = cell(comsolNode.tags);
            idxTag = strcmp(tags, childTag);
            if sum(idxTag) ~=1; return; end
            
            bool = true;
        end
        
        function setNodeProperties(comsolNode, propertyStruct)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            propertyNames = fieldnames(propertyStruct);
            for idxProperty = 1:numel(propertyNames)
                currentProperty = propertyNames{idxProperty};
                comsolNode.set(currentProperty, propertyStruct.(currentProperty));
            end
        end
    end
    
    %% Check input
    methods(Access = private, Static = true)
        function checkInputForComsolNode(input)
            if ~contains(class(input), 'com.comsol') || ~contains(class(input), '.impl.')
                error('Input must be a Comsol Node');
            end
            if isa(input, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must not be an Comsol model but one of its child nodes')
            end
        end
    end
end

