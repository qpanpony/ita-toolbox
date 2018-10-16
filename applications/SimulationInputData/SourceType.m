classdef VelocityType
    %VelocityMode Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration 
        PointSource, Piston, SurfaceDistribution
    end
    
    methods
        function bool = IsOneDimensional(this)
            bool = ~(VelocityType.SurfaceDistribution == this);
        end
    end
    
end

