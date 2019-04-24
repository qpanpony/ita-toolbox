classdef SourceType
    %SourceType Used to specify the representing geometry of an itaSource
    %and expected acoustic data for wave-based simulations
    
    enumeration 
        PointSource, Piston, SurfaceDistribution
    end
    
    methods
        function bool = IsOneDimensional(this)
            bool = ~(SourceType.SurfaceDistribution == this);
        end
    end
    
end

