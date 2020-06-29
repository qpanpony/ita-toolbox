classdef itaGeoPropagation < handle
    %ITAGEOPROPAGATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pps;
        fs = 44100;
        c = 341.0;
        diffraction_model = 'utd';
        sim_prop = struct();
    end
    
   properties (Access = protected)
        n = 2^15 + 1;
        directivity_db = struct();
   end
    
    properties (Dependent)
        freq_vec;
        num_bins;
    end
    
    methods
        
        function obj = itaGeoPropagation( fs, num_bins )            
           if nargin >= 1
                obj.fs = fs;            
           end           
           if nargin >= 2
                obj.n = num_bins;            
           end
           
           obj.sim_prop.diffraction = true;
           obj.sim_prop.reflection = true;
           obj.sim_prop.directivity = true;
           
        end
        
        function fs = get.fs( obj )
            fs = obj.fs;
        end
        
        function num_bins = get.num_bins( obj )
            num_bins = obj.n;
        end
        
        function f = get.freq_vec( obj )
            % Returns frequency base vector
            
            % taken from itaAudio (ITA-Toolbox)
            if rem( obj.n, 2 ) == 0
                f = linspace( 0, obj.fs / 2, obj.n )';
            else
                f = linspace( 0, obj.fs / 2 * ( 1 - 1 / ( 2 * obj.n - 1 ) ), obj.n )'; 
            end
            
        end
        
    end
end

