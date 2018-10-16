classdef (Abstract) itaSpatialSimulationInputItem < itaSimulationInputItem
    %itaSpatialSimulationInputItem Summary of this class goes here
    %   Detailed explanation goes here
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    properties(Access = protected, Hidden = true)
        mPosition = itaCoordinates([0 0 0]);                        %itaCoordinates
        mOrientation = itaOrientation.FromViewUp([1 0 0], [0 1 0]); %itaOrientation
    end
    properties(Dependent = true)
        position;       %Position of the item in 3D space - itaCoordinates
        orientation;    %Orientation of the item in 3D space - itaOrientation
    end
    
    %% Set / Get
    methods
        function this = set.position(this, coord)
            if isnumeric(coord) && isempty(coord)
                this.mPosition = [];
                return;
            end
            
            if ~isa(coord, 'itaCoordinates') || ~isscalar(coord)
                error('Input must be a scalar of type itaCoordinates');
            end
            if coord.nPoints > 1
                error('Input must be a single set or coordinates or empty.')
            end
            this.mPosition = coord;
        end
        function this = set.orientation(this, orientation)
            if isnumeric(orientation) && isempty(orientation)
                this.mOrientation = [];
                return;
            end
            
            if ~isa(orientation, 'itaOrientation') || ~isscalar(orientation)
                error('Input must be a scalar of type itaOrientation');
            end
            if orientation.nPoints > 1
                error('Input must be a single orientation or empty.')
            end
            this.mOrientation = orientation;
        end
        
        function out = get.position(this)
            out = this.mPosition;
        end
        function out = get.orientation(this)
            out = this.mOrientation;
        end
    end
    
    %% Booleans
    methods
        function bool = HasPosition(this)
            bool = ~isempty(this.mPosition) && this.mPosition.nPoints == 1;
        end
        function bool = HasOrientation(this)
            bool = ~isempty(this.mOrientation) && this.mOrientation.nPoints == 1;
        end
        function bool = HasSpatialInformation(this)
            bool = this.HasPosition & this.HasOrientation;
        end
    end
end

