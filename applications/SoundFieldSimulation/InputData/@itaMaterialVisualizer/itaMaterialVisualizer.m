classdef itaMaterialVisualizer < handle
    %itaMaterialVisualizer Used for plotting data of itaMaterials
    %   Holds a vector of itaMaterials whose data can be visualized.
    %   This class can plot the impedance, absorption or scattering of all
    %   given materials in a single plot. Plotting is based on ita_plot_freq()
    %   function and uses same syntax for input arguments.
    %   
    %   See also itaMaterial, ita_plot_freq
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaMaterialVisualizer">doc itaMaterialVisualizer</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mMaterials;
    end
    properties(Dependent = true)
        materials
    end
    
    %% Constructor
    methods
        function obj = itaMaterialVisualizer(materials)
            %Initializes this class with a vector of itaMaterials
            if ~isa(materials, 'itaMaterial') || ~isvector(materials)
                error('Input must be a vector of materials')
            end
            obj.mMaterials = materials;
        end
    end
    
    %% Set/Get
    methods
        function set.materials(this, materials)
            if ~isa(materials, 'itaMaterial') || ~isvector(materials)
                error('Input must be a vector of type itaMaterial')
            end
            this.mMaterials = materials;
        end
        function out = get.materials(this)
            out = this.mMaterials;
        end
    end
    
    %% Plot methods
    methods
        function varargout = plotAbsorption(this, varargin)
            %Plots the absorption coefficient for all given materials
            %   For specification of plot input arguments: See ita_plot_freq()
            [fgh, ax] = this.plotParameter('absorption', 'HasAbsorption', varargin{:});
            ylabel(ax, 'Absorption coefficient \alpha');
            ylim(ax, [0 1.1])
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
        function varargout = plotScattering(this, varargin)
            %Plots the scattering coefficient for all given materials
            %   For specification of plot input arguments: See ita_plot_freq()
            [fgh, ax] = this.plotParameter('scattering', 'HasScattering', varargin{:});
            ylabel(ax, 'Scattering coefficient\it s');
            ylim(ax, [0 1.1])
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
        function varargout = plotImpedance(this, varargin)
            %Plots the impedance for all given materials
            %   For specification of plot input arguments: See ita_plot_freq()
            [fgh, ax] = this.plotParameter('impedance', 'HasNonInfImpedance', varargin{:});
            ylabel(ax, 'Impedance\it Z');
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
    end
    
    methods(Access = private)
        function [fgh, ax] = plotParameter(this, parameter, checkFunction, varargin)
            materialsWithParameter = this.mMaterials(this.mMaterials.(checkFunction));
            if numel(materialsWithParameter) == 0
                error('Cannot plot material parameter, since it is not specified or cannot be visualized for any of the given materials')
            end
            
            parameterData = itaResult();
            for idxMat = 1:numel(materialsWithParameter)
                materialsWithParameter(idxMat).(parameter).channelNames = {materialsWithParameter(idxMat).name};
                parameterData = ita_merge(parameterData, materialsWithParameter(idxMat).(parameter));
            end
            
            [fgh, ax] = ita_plot_freq( parameterData, 'nodB', 'on', varargin{:} );
        end
    end
end

