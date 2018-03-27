classdef DAFF < handle
   properties
      daffhandle
      view = 'object'
   end
   methods
        function obj = DAFF( filepath )
            if( nargin > 0 )
                open( filepath )
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
        function idx = get_nearest_neighbour_index( obj, azi_deg, ele_deg )
            idx = DAFFv17( obj.daffhandle, 'getNearestNeighbourIndex', obj.view, azi_deg, ele_deg );
        end
   end
end
