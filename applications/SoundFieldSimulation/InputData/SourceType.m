classdef SourceType
    %SourceType Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration 
        PointSource, Piston, SurfaceDistribution
    end
    
    methods
        function bool = IsOneDimensional(this)
            bool = ~(SourceType.SurfaceDistribution == this);
        end
    end
    
end

