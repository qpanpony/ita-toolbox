classdef itaFiniteWedge < itaInfiniteWedge
    
    properties (Access = protected)
        al % aperture length
        sp % start point of aperture
        ep % end point of aperture
    end
    
    properties (Dependent)
        length
        aperture_start_point
        aperture_end_point
    end
    
    methods
        function obj = itaFiniteWedge( main_face_normal, opposite_face_normal, location, length, edge_type )
            % Creates an finite wedge with a location in 3-dim space
            % Starting point of wedge aperture is the wedge location, end
            % point is defined by length and direction of aperture
            % Length must be a scalar value greater zero
            if nargin < 5
                edge_type = 'outer_edge';
            end
            obj@itaInfiniteWedge( main_face_normal, opposite_face_normal, location, edge_type );
            if numel( length ) > 1 || length <= 0
                error 'Length must be a scalar value greater zero'
            end
            obj.al = length;
            obj.sp = obj.l;
            
            n_scaled = cross( obj.main_face_normal, obj.opposite_face_normal );
            if ~norm( n_scaled )
                warning 'Aperture end point could not be determined since aperture direction is not defined. Please set aperture direction manually.'
            else
                obj.ep = obj.sp + length * obj.aperture_direction;
            end
        end

        function obj = set.aperture_end_point( obj, length_of_aperture )
            % Sets aperture direction manually (in case of linear
            % dependent normals)
            if norm( cross( obj.n1, obj.n2 ) )
                error 'Aperture is already fixed and cannot be modified'
            end
            if length_of_aperture <= 0
                error 'Aperture length must be a valid scalar > 0'
            end
            obj.ep = length_of_aperture;
        end
        
        function l = get.length( obj )
            l = obj.al;
        end
        
        function sp = get.aperture_start_point( obj )
            % 3-dim starting point of finite aperture
            sp = obj.sp;
        end
        
        function ep = get.aperture_end_point( obj )
            % 3-dim end point of finite aperture
            ep = obj.ep;
        end
    end
end
