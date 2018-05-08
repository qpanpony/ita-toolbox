classdef DAFF < handle
   properties (Access = protected)
      daffhandle
      view = 'object'
   end
   methods
        function obj = DAFF( filepath )
            %% Create DAFF class and load from file
            % filepath Path to DAFF file
            if( nargin > 0 )
                obj.open( filepath )
            end
        end
        function open( obj, filepath )
             obj.daffhandle = DAFFv17( 'open', filepath );
        end
        function set_data_view( obj )
             obj.view = 'data';
        end
        function set_object_view( obj )
             obj.view = 'object';
        end
        
        function metadata = get_metadata(obj)
            %% Returns the metadata of an opened DAFF file
            metadata = DAFFv17('getMetadata', obj.daffhandle);
        end
        function metadata = get_record_metadata( obj, index )
            %% Returns the record metadata of an opened DAFF file
            metadata = DAFFv17('getRecordMetadata', obj.daffhandle, index);
        end
        function props = get_properties( obj )
            %% Returns the properties of an opened DAFF file
            props = DAFFv17( 'getProperties', obj.daffhandle );
        end
        function coords = get_record_coords( obj, index )
            %% Returns the coordinates of a grid point
            coords = DAFFv17( 'getRecordCoords', obj.daffhandle, obj.view, index );
        end
        function idx = get_nearest_neighbour_index( obj, azi_deg, ele_deg )
            %% Returns the data at the nearest neighbour grid point to the given direction
            idx = DAFFv17( 'getNearestNeighbourIndex', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function data = get_nearest_neighbour_record( obj, azi_deg, ele_deg )
            %% Returns the data at the nearest neighbour grid point to the given direction
            data = DAFFv17( 'getNearestNeighbourRecord', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function rec = get_record_by_index( obj, idx )
            %% Returns the data at a grid of the given index
            rec = DAFFv17( 'getRecordByIndex', obj.daffhandle, idx );
        end
        function data = get_cell_records( obj, azi_deg, ele_deg )
            %% Returns the data of all four records of the surrounding cell to the given direction
            data = DAFFv17('getCellRecords', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
        function idx = get_cell( obj, azi_deg, ele_deg )
            %% Returns the data at the nearest neighbour grid point to the given direction
            idx = DAFFv17( 'getCell', obj.daffhandle, obj.view, azi_deg, ele_deg );
        end
   end
    methods (Static)
        function help()
            %% Prints the help output of OpenDAFF
            DAFFv17('help')
        end
        function v = get_version()
            %% Returns the OpenDAFF version
            v = DAFFv17('getVersion');
        end
   end
end
