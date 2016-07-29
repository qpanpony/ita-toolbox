% This class just merges the functionality of itaResult and itaSuperSph
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% You can find the documentation in these classes.

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 1.8.2011

classdef itaResultSph < itaResult & itaSuperSph
    methods
        function this = itaResultSph(varargin) %Constructor
            this = this@itaResult(varargin{:});
            this = this@itaSuperSph(varargin{:});
        end
    end
    methods % define this to aviod the overloaded itaSuper functions
        function sObj = saveobj(this)
            sObj = builtin('saveobj',this);
        end
    end
end
