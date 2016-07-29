% Super class for using spatial routines with itaAudio/itaResult
%

% <ITA-Toolbox>
% This file is part of the application SpatialAudio for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% This class allows to store an additional itaCoordinates object (or an
% derivated class from that). You can now plot nice balloons using the
% overloaded surf() routine.
%
%   Example (a itaAudio or itaResult called "ita" is given):
%
%           as = itaAudioSpatial(ita);          % make spatial class object 
%            s = itaCoordinates(as.nChannels)   % set the coordinates for it
%            s.cart = randn(as.nChannels,3)     % just random values
%           as.s = s;                           % apply it to the object
%           surf(as,as.freq2value(2000))        % plot 2kHz data set%
%
%      See also itaCoordinates.surf for details of the syntax.
%
% TODO: The surf plot now is specific to spherical data. If you need to
% implement another 

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 1.8.2011

classdef itaSuperSpatial
    properties
        spatialSampling
    end
    properties(Dependent,Hidden)
        % this is just a short form for spatialSampling
        s
    end
    methods
        function this = itaSuperSpatial(varargin) %Constructor
            for ind = 1:nargin
                if isa(varargin{ind},'itaCoordinates')
                    this.spatialSampling = varargin{ind};
                end
            end
        end
        function value = get.s(this)
            value = this.spatialSampling;
        end
        function this = set.s(this,value)
            this.spatialSampling = value;
        end
        function varargout = surf(this, varargin)
            % hand the job over to itaCoordinates.surf
            hFig = surf(this.spatialSampling, varargin{:});
            if nargout
                varargout = {hFig};
            else
                varargout = {};
            end
        end
    end
end
