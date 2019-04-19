classdef itaInfiniteWedge
    
    properties (Access = protected)
        n1 % 3-dim normal vector of main face (internal)
        n2 % 3-dim normal vector of opposite face (internal)
        ad % 3-dim aperture direction vector (internal)
        l % Internal location variable
        wt % type of wedge (internal)
        bc_hard % Internal boundary condition (hard = true)
    end
    
    properties (Dependent)
        main_face_normal % 3-dim normal vector of main face (normalized)
        opposite_face_normal % 3-dim normal vector of opposite face (normalized)
        aperture_direction % 3-dim normal vector of aperture direction (normalized)
        location % Location of wedge (somewhere along aperture)
        opening_angle % Angle from main to opposite face in propagation medium / air (radiants)
        wedge_angle % Angle from main to opposite face in solid medium of wedge (radiants)
        wedge_type % 'wedge' for opening angles > pi or 'corner' for opening angles < pi
        boundary_condition % boundary condition of the wedge faces (hard or soft)
    end
    
    methods
        function obj = itaInfiniteWedge( main_face_normal, opposite_face_normal, location, wedge_type )
            % Create a wedge by a main face normal and an opposite face
            % normal
            %   main_face_normal:       Main face normal (3-dim)
            %   opposite_face_normal:   Opposite face normal (3-dim)
            %   location:               Point on aperture which defines
            %                           location of the wedge in 3_dim sapce
            %   wedge_type:             use 'wedge' for opening angles > pi (default) and
            %                           'corner' for opening angles < pi
            % Note: 3-dim direction vectors will be normalized automatically
            % 
            if nargin < 4
                wedge_type = 'wedge';
            end
            if ~isequal( wedge_type, 'wedge' ) && ~isequal( wedge_type, 'corner' )
                error( 'Invalid wedge type. Use either wedge or corner' )
            end
            if numel( main_face_normal ) ~= 3
                error 'Main face normal has to be a 3-dim vector'
            end
            if numel( opposite_face_normal ) ~= 3
                error 'Opposite face normal has to be a 3-dim vector'
            end
            if numel(location) ~= 3
                error( 'Location must be of dimension 3')
            end
            
            obj.n1 = main_face_normal;
            obj.n2 = opposite_face_normal;
            obj.l = location;
            obj.wt = wedge_type;
            obj.bc_hard = true;
            
            if ~obj.validate_normals
                warning 'Normalized face normals'
                obj.n1 = main_face_normal ./ norm( main_face_normal );
                obj.n2 = opposite_face_normal ./ norm( opposite_face_normal );
            end
            
            n_scaled = cross( obj.main_face_normal, obj.opposite_face_normal );
            if ~norm( n_scaled )
                warning 'Normals are linear dependent and aperture direction could not be determined. Please set aperture direction manually.'
            else
                obj.ad = n_scaled ./ norm( n_scaled );
            end
        end
        
        function n = get.main_face_normal( obj )
            n = obj.n1;
        end
                
        function n = get.opposite_face_normal( obj )
            n = obj.n2;
        end
        
        function n = get.aperture_direction( obj )
            % Returns normalized direction of aperture. Vectors main face normal, opposite face normal and aperture direction 
            % form a clockwise system.
            if isempty( obj.ad )
                error 'Invalid wedge, aperture direction not set and face normals are linear dependent'
            end
            n = obj.ad;
        end
        
        function obj = set.aperture_direction( obj, aperture_direction )
            % Sets aperture direction manually (in case of linear
            % dependent normals)
            if norm( cross( obj.n1, obj.n2 ) )
                error 'Aperture of linear independent normals is fixed can not be modified'
            end
            if ~norm( aperture_direction )
                error 'Aperture vector must be a valid direction'
            end
            if norm( aperture_direction ) ~= 1
                warning ' Normalizing aperture direction'
                aperture_direction = aperture_direction / norm( aperture_direction );
            end
            if ~( dot( aperture_direction, obj.n1 ) == 0 && dot( aperture_direction, obj.n2 ) == 0 )
                error 'Invalid aperture direction, vector must be perpendicular to face normals'
            end
            obj.ad = aperture_direction;
        end
        
        function beta = get.wedge_angle( obj )
            % Returns angle from main to opposite face through solid medium
            % of the wedge (radiant)
            if isequal( obj.wt, 'wedge' )
                s = 1;
            elseif isequal( obj.wt, 'corner' )
                s = -1;
            end
            beta = pi - s * acos(dot(obj.main_face_normal, obj.opposite_face_normal));
        end
        
        function beta_deg = wedge_angle_deg( obj )
            % Get the wedge angle angle in degree
            beta_deg = rad2deg( obj.wedge_angle );
        end  
        
        function theta = get.opening_angle( obj )
            % Returns angle from main face to opposite face through propagation medium /
            % air (radiant)
            theta = 2 * pi - obj.wedge_angle;
        end
                
        function theta_deg = opening_angle_deg( obj )
            % Get the wedge opening angle in degree
            theta_deg = rad2deg( obj.opening_angle );
        end
        
        function l = get.location( obj )
            l = obj.l;
        end
        
        function b = validate_normals( obj )
            % Returns true, if the normals of the faces are both normalized
            b = false;
            if ( norm( obj.main_face_normal ) - 1 ) < eps && ( norm( obj.opposite_face_normal ) -1 ) < eps
               b = true;
            end
        end
        
        function wt = get.wedge_type( obj )
            wt = obj.wt;
        end
        
        function bc = get.boundary_condition( obj )
            if obj.bc_hard
                bc = 'hard';
            else
                bc = 'soft';
            end
        end
        
        function obj = set.boundary_condition( obj, bc )
            if ischar(bc)
                if strcmpi('hard', bc)
                    obj.bc_hard = true;
                elseif strcmpi('soft', bc)
                    obj.bc_hard = false;
                else
                    error('boundary condition must be "hard" or "soft"!');
                end
            else
                error('boundary condtion must be of type character!');
            end
        end
        
        function obj = set.bc_hard( obj, b )
            obj.bc_hard = b;
        end
        
        function bc = is_boundary_condition_hard( obj )
            bc = obj.bc_hard;
        end
        
        function bc = is_boundary_condition_soft( obj )
            bc = ~obj.bc_hard;
        end    
    end
    
    
    methods (Static)
        function current_eps = set_get_geo_eps( new_eps )
            % Controls and returns the geometrical calculation precision value for
            % deciding e.g. if a point is inside or outside a wedge
            % (defaults to Matlab eps, but should be set for instance to
            % millimeter (1e-3) or micrometer (1e-6).
            persistent geo_eps;
            if nargin > 0
                geo_eps = new_eps;
            end
            if isempty( geo_eps )
                geo_eps = eps; % Default eps from Matlab double precision
            end
            current_eps = geo_eps;
        end
    end
end