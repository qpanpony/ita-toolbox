% This class just merges the functionality of itaAudio and itaSuperSph
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% You can find the documentation in these classes.

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 1.8.2011

classdef itaAudioSph < itaAudio & itaSuperSph
    methods
        function this = itaAudioSph(varargin) %Constructor
            this = this@itaAudio(varargin{:});
            this = this@itaSuperSph(varargin{:});
        end
        function this = merge(this, that)
            result = merge@itaAudio(this, that);
            result.s = merge(this.s, that.s);
            this = result;
        end
    end
    methods % define this to aviod the overloaded itaSuper functions
        function sObj = saveobj(this)
            sObj = builtin('saveobj',this);
        end
    end
end
