classdef itaVA < VA
    %ITAVA Deprecated! Please instantiate the super class VA directly.
    %
    %

    methods        
        function this = itaVA
            warning( 'The class itaVA has been renamed to VA. This deprecated class may be removed in the future.' )
            this = this@VA;            
        end
    end
end
