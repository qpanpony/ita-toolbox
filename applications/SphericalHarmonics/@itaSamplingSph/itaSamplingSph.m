classdef itaSamplingSph < itaCoordinates
    %  extention of the itaCoordinates for spherical harmonics
    %  new properties: Y : amplitudes of spherical harmonic base functions
    %
    % see also : itaCoordinates, itaSamplingSphReal,
    % itaCoordinates.spherical_voronoi (a method to calculate the weights of
    % sampling points)
    %
    % Autor: Martin Pollow <mpo@akustik.rwth-aachen.de>
    
    % <ITA-Toolbox>
    % This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties
        Y % sampled spherical harmonics
        dims
    end
    properties(Dependent)
        nmax
        nSH
    end
    
    methods
        function this = itaSamplingSph(varargin) %Constructor
            this = this@itaCoordinates(varargin{:});
            
            %copy / cast
            if nargin
                if isa(varargin{1}, 'itaSamplingSph')
                    this.nmax = varargin{1}.nmax;
                end
            end
        end
        
        function value = get.nmax(this)
            if numel(this.Y) > 0
                value = sqrt(size(this.Y,2))-1;
            else
                value = NaN;
            end
        end
        function this = set.nmax(this, varargin)
            nmax = varargin{:};
            if numel(nmax) > 1 || ~isnumeric(nmax)
                error([mfilename('class') '.set.nmax  invalid nmax']);
            end
            if isnan(nmax)
                this.Y = [];
            else
                this = set_base(this, nmax);
            end
        end
        function value = get.nSH(this)
            if numel(this.Y) > 0
                value = size(this.Y,2);
            else
                value = NaN;
            end
        end
        function this = set.nSH(this, varargin)
            nSH = varargin{:};
            if numel(nSH) > 1 || ~isnumeric(nSH)
                error([mfilename('class') '.set.nSH  invalid number of coefficients']);
            end
            if isnan(nSH)
                this.Y = [];
            else
                this = set_base(this, (nSH+1)^2);
            end
        end
        
        function this = n(this,index)
            this = n@itaCoordinates(this,index);
            if size(this.Y,1) > 0
                if size(this.Y,1) < max(index)
                    this.Y = []; %pdi Bugfix for itaSamplingSPH
                else
                    % the Y matrix is set
                    this.Y = this.Y(index,:);
                end
            end
            if numel(this.weights) > 0
                if numel(this.weights) < max(index)
                    this.weights = []; %pdi: bugfix
                else
                    % the weights are set
                    this.weights = this.weights(index);
                end
            end
        end
        % this does not work as it is no handle class
        %         function this = update(this)
        %             % recalculates the Y matrix
        %             this = this.set_base(this.nmax);
        %         end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaCoordinates(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaSamplingSph.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    methods(Access = protected)
        function this = set_base(this, nmax)
            this.Y = ita_sph_base(this,nmax);
            ita_verbose_info(['Complex valued spherical harmonics up to order ' num2str(nmax) ' calculated.']);
        end
        function this = set_weights(this, varargin)
            if abs(sum(varargin{:}) - 4*pi) < 1e-10
                this.weights = varargin{1};
            else
                error('weights have wrong sum')
            end
        end
    end
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            if isfield(sObj,'classrevision'), sObj = rmfield(sObj,{'classrevision'}); end;
            if isfield(sObj,'classname'), sObj = rmfield(sObj,{'classname'}); end;
            this = itaSamplingSph(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 8687 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            % always save as cart
            result = {'Y'};
        end
    end
    
end