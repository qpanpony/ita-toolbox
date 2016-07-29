% This class just merges the functionality of itaAudio and itaSuperSpatial
%

% <ITA-Toolbox>
% This file is part of the application SpatialAudio for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% You can find the documentation in these classes.

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 1.8.2011

classdef itaAudioSpatial < itaAudio & itaSuperSpatial   
    methods
        function this = itaAudioSpatial(varargin) %Constructor
            this = this@itaAudio(varargin{:});
            this = this@itaSuperSpatial(varargin{:});
        end
    end
    methods % define this to aviod the overloaded itaSuper functions
        function sObj = saveobj(this)
            sObj = builtin('saveobj',this);
        end
    end
end