% This class defines an analytic object for spherical loudspeaker objects.
% 
% The constructor
%                       LS = itaSphericalLoudspeaker(SAMPLING)
%
% - creates a loudspeaker object with the membrane center points on the
%   points defined in SAMPLING (which can be some itaCoordinates descendent)
%   default SAMPLING is ita_sph_sampling_dodecahedron.m
% - set the maximum order of SH coefficients used for calculation
%       (the higher the more accurate, but usually slow values are fast and precise)
% - set the membrane radius of the membranes
% - now you can access the following
%       - aperture functions of the membrane velocity in SH domain
%       - sound pressure in any point in space
%
%   Examples:
%               membranes = ita_sph_sampling_dodecahedron;
%               dode = itaSphericalLoudspeaker(membranes);
%               dode.nmax = 15;     % maximum SH order
%               dode.r_mem = 0.05;  % 5cm membrane radius
%
%               dode.apertureSH(:,1)    % SH coefs of 1st membrane 
%
%               % calculate the sound pressure for omni-unit excitation (in SH domain)
%               velocities = ones(12,1)
%               velSH = dode.apertureSH * velocities;
%               k = 1; r = 5;           % look at wavenr = 1 and 5m radius
%               pressureSH = dode.pressureFactor(k,r).' .* velSH;
%
%
%    Author: Martin Pollow <mpo@akustik.rwth-aachen.de>

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


classdef itaSphericalLoudspeaker < itaSamplingSph

    properties(Hidden, Access=protected)
        m_r_mem
        mCapSH
        mApertureSH        
    end
    properties
        soundSpeed = 340;
    end
    properties(Dependent)
        r_mem % membrane radius [m]
        capSH % SH coefficient of the northern cap
        apertureSH % aperture functions of the membranes in SH coefs
    end
    properties(Constant)
        m_rho0 = double(ita_constants('rho_0'));
%         m_c0   = double(ita_constants('c'));
%         m_default_nmax = 15;
    end
    methods
        function this = itaSphericalLoudspeaker(varargin) 
            %Constructor
            if isempty(varargin)
                % default is SuperDode
                varargin = {ita_sph_sampling_dodecahedron};
            end
            this = this@itaSamplingSph(varargin{:});                    
        end
        
        % get
        function value = get.r_mem(this)
            value = this.m_r_mem;
        end
        function value = get.capSH(this)
            value = this.mCapSH;
        end
        function value = get.apertureSH(this)
            value = this.mApertureSH;
        end
        
        % set
        function this = set.r_mem(this, varargin)
            this.m_r_mem = varargin{:};
%             if isempty(this.Y)
%                 this.update; end
%                 ita_verbose_info('Please set the maximum order nmax first.',0)
%             else
                this.capSH = makeNorthpoleCap(this);
                this.apertureSH = makeAperture(this);
%             end            
        end
        function this = set.capSH(this, varargin)
            this.mCapSH = varargin{:};
        end
        function this = set.apertureSH(this, varargin)
            this.mApertureSH = varargin{:};
        end

        function value = pressureFactor(this, k, r)
            narginchk(2,3);
            if ~isnumeric(this.nmax) || ~isscalar(this.nmax)
                error([mfilename('class') ' no valid nmax given']);
            end
            
            if nargin < 3
                r = Inf;
                disp('Calculating far-field directivity.')
            end
            
            % load the constants
            rho0 = this.m_rho0;
            c0   = this.soundSpeed;
            
            ka = k .* this.r(1); % using only the first radius saved
            kr = k .* r;
            
            % 0 1 1 1 2 2 2 2 2 3 ...
            degreeIndex = ita_sph_linear2degreeorder(1:this.nSH);
            
            % now try to put the degreeIndex in the right dimensions
            if size(k,2) ~= 1
                degreeIndex = degreeIndex.';
            end
            
            % avoid a MATLAB crash by disabling the division by zero
            kr(kr==0) = eps;
            ka(ka==0) = eps;
            
            if isinf(kr(end)) % use the last frequency (first one can be nan)
                % use the formula for directivity
                % cf. FA (6.114)
                value = ...
                    bsxfun(@rdivide,  bsxfun(@times, rho0 * c0 ./ k, 1i.^degreeIndex), ...
                    ita_sph_besseldiff(@ita_sph_besselh, degreeIndex, 2, ka));
                
            else
                % work with pressure formula
                % cf. FA (6.105)
                value = ...
                    (-1i) .* rho0 * c0 .* ita_sph_besselh(degreeIndex, 2, kr) ...
                    ./ ita_sph_besseldiff(@ita_sph_besselh, degreeIndex, 2, ka);
            end                        
        end
        
        function pressSH = velocity2pressure(this,vel_mem,r)
            % this function expects a itaAudio object in vel_mem with as
            % many channels as we do have transducers. If the number of
            % channels is smaller, they are assumed to be not powered
            % Output is a itaAudio object in the SH domain
            %   r is the evaluation radius
                            
            if isnan(this.nSH)
                error('Please set the maximum order first: e.g.: dode.nmax = 20');
            end
            if numel(this.apertureSH) < this.nPoints
                error('Please define the membranes first: e.g.: dode.r_mem = 0.05;');
            end
            
            % check for correct number of channels and add zeros if necessary
            nMembranes = this.nPoints;
            if vel_mem.nChannels > nMembranes
                disp('ignoring the higher channels')
                vel_mem.data = vel_mem.data(:,1:this.nPoints);
            elseif vel_mem.nChannels < nMembranes
                disp('using no excitation for the higher channels')
                vel_mem.data = cat(2,vel_mem.data,zeros(size(vel_mem.data,1),nMembranes-vel_mem.nChannels));
            end
            
            % calculate the pressureFactor
            k = 2*pi * vel_mem.freqVector / this.soundSpeed;

            if nargin < 3
                % far-field
                pressFac = this.pressureFactor(k);
            else
                % defined radius
                pressFac = this.pressureFactor(k, r);
            end
            
            pressSH = itaAudio;
            pressSH.samplingRate = vel_mem.samplingRate;            
            % initialize
            nBins = vel_mem.nBins;
            pressSH.freq = zeros(nBins, this.nSH);
            
            velSH = vel_mem.freq * this.apertureSH.';
            pressSH.freq = velSH .* pressFac;
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSamplingSph(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaSphericalLoudspeaker.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Hidden)
        function value = makeNorthpoleCap(this)
            if max(this.r) > 1.001 * min(this.r)
                error('this is not a sphere');
            end
            r = this.r(1);
            apertureAngle = asin(this.r_mem ./ r);
            value = ita_sph_northpolecapSH(this.nmax, apertureAngle);
        end
        
        function value = makeAperture(this)
            nMem = size(this.cart,1);
            nSH = size(this.capSH,1);
            value = zeros(nSH,nMem);
            for ind = 1:nMem
                % NOT ANYMORE: all angles are negated due to the sign conventions
                D = ita_sph_wignerD(this.nmax,0,this.theta(ind),this.phi(ind));
                value(:,ind) = D * this.capSH;
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            if isfield(sObj,'classrevision'), sObj = rmfield(sObj,{'classrevision'}); end;
            if isfield(sObj,'classname'), sObj = rmfield(sObj,{'classname'}); end;
            this = itaSphericalLoudspeaker(sObj); % Just call constructor, he will take care
        end
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 3235 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        function result = propertiesSaved
            % always save as cart
            result = {'apertureSH', 'capSH', 'r_mem'};
        end

    end
end