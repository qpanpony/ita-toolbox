classdef itaSamplingSphReal < itaSamplingSph
    
    % <ITA-Toolbox>
    % This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % equal to itaSamplingSph, but works with real valued
    % spherical harmonics
    methods
        function this = itaSamplingSphReal(varargin) %Constructor
            this = this@itaSamplingSph(varargin{:});
        end        
    end
    methods(Access = protected)
        function this = set_base(this, nmax)
                this.Y = ita_sph_base(this, nmax, 'real');
                ita_verbose_info(['Real valued spherical harmonics up to order ' num2str(nmax) ' calculated.']);
        end
    end
end