classdef DAFF < handle
    
    % DAFF is a direction audio file format for virtual acoustics
    % A daff file instance can be used to load a file in DAFF format and 
    % receiver metadata, proerties and directional audio content.
    %
    % The most important functions are
    %
    %   load                        Open a DAFF file
    %   close                       Closes a DAFF file
    %   nearest_neighbour_record    Receive content for a certain direction in spherical coordinates
    %   metadata                    Get DAFF metadata as struct
    %   properties                  Get DAFF properties as struct
    %
    
   properties (Access = protected)
       
      daffhandle % The internal DAFF file handle
      view = 'object' % The DAFF viewpoint (user/object or developer/data)
      
   end
   
   methods
       
        function obj = DAFF( filepath )
            % Creates a DAFF instance and loads content from file
            %   filepath    Path to DAFF file
            if( nargin > 0 )
                obj.open( filepath )
            end
        end
        
        function delete( obj )
            if obj.daffhandle
                close( obj );
            end
        end
        
        function open( obj, filepath )
			% Opens a DAFF file
             obj.daffhandle = DAFFv17( 'open', filepath );
        end
        
        function close( obj )
			% Closes the DAFF file
			DAFFv17( 'close', obj.daffhandle )
            obj.daffhandle = [];
        end
        
        function set_data_view( obj )
			% Switches to data view (alpha, beta)
             obj.view = 'data';
        end
        function set_object_view( obj )
			% Switches to object / user view (elevation, azimuth) [default]
             obj.view = 'object';
        end        
        function metadata = metadata(obj)
            % Returns the metadata of an opened DAFF file
            metadata = DAFFv17( 'getMetadata', obj.daffhandle );
        end
        function metadata = record_metadata( obj, index )
            % Returns the record metadata of an opened DAFF file
            metadata = DAFFv17( 'getRecordMetadata', obj.daffhandle, index );
        end
        function props = properties( obj )
            % Returns the properties of an opened DAFF file
            props = DAFFv17( 'getProperties', obj.daffhandle );
        end
        function coords = record_coords( obj, index )
            % Returns the coordinates of a grid point
            coords = DAFFv17( 'getRecordCoords', obj.daffhandle, obj.view, index );
        end
        function idx = nearest_neighbour_index( obj, azi_deg, ele_deg )
            % Returns the data at the nearest neighbour grid point to the given direction
            % Uses spherical coordinates azimuth and elevation in degree.
            %
            %   azi_deg     Azimuthal angle in degree
            %   ele_deg     Elevation angle in degree
            %
            idx = DAFFv17( 'getNearestNeighbourIndex', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function data = nearest_neighbour_record( obj, azi_deg, ele_deg )
            % Returns the data at the nearest neighbour grid point to the given direction
            % Uses spherical coordinates azimuth and elevation in degree.
            %
            %   azi_deg     Azimuthal angle in degree
            %   ele_deg     Elevation angle in degree
            %
            data = DAFFv17( 'getNearestNeighbourRecord', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function rec = record_by_index( obj, idx )
            % Returns the data at a grid of the given index
            rec = DAFFv17( 'getRecordByIndex', obj.daffhandle, idx );
        end
        function data = cell_records( obj, azi_deg, ele_deg )
            % Returns the data of all four records of the surrounding cell to the given direction
            % Uses spherical coordinates azimuth and elevation in degree.
            %
            %   azi_deg     Azimuthal angle in degree
            %   ele_deg     Elevation angle in degree
            %
            data = DAFFv17('getCellRecords', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function idx = cell( obj, azi_deg, ele_deg )
            % Returns the data at the nearest neighbour grid point to the given direction
            % Uses spherical coordinates azimuth and elevation in degree.
            %
            %   azi_deg     Azimuthal angle in degree
            %   ele_deg     Elevation angle in degree
            %
            idx = DAFFv17( 'getCell', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        
   end
   
    methods (Static)
        
        function mex_help()
            % Prints the help output of OpenDAFF extension (mex)
            DAFFv17( 'help' )
        end
        
        function v = mex_version()
            % Returns the OpenDAFF extension (mex) version
            v = DAFFv17( 'getVersion' );
        end
        
    end
   
end
