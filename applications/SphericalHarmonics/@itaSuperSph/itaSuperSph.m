% Super class for using SH routines with itaAudio/itaResult
% 
% This class extends the functionality of itaAudio and itaResult objects
% to use them with the SphericalHarmonics application of the ITA-Toolbox.
% Besides the well-known time/freq-domains there are now also three spatial
% domains. These domains are:
%
%      this.spatialDomain = 'S2'        % spatial domain, data on 2-sphere
%      this.spatialDomain = 'SH'        % spherical harmonic domain
%      this.spatialDomain = 'MP'        % multipole domain
%
%   Please note that the multipole domain is NOT describing physical
%   multipoles, but gives a measure for source strength in a modified
%   spherical harmonic domain. The sound radiation of can be describes in
%   the entire 3D space with this measure. For details, read the nice
%   papers from Gumerov/Duraiswami and/or ask Martin.
%
%   There are six possible conversions with their routines:
%           S2 ==> SH       .sht 
%           SH ==> S2       .isht 
%           S2 ==> MP       .mpt
%           MP ==> S2       .impt
%           SH ==> MP       .apply_iHankel
%           MP ==> SH       .applyHankel
%
%   Note that the last two transformations only work on a constant radius.
%   That means on non-constant radii, directly transform from S2 to MP. If
%   you have constant radius, the two-step method (.sht + .apply_iHankel)
%   could be faster, however. Have fun and please report bugs.

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 1.8.2011

classdef itaSuperSph < itaSuperSpatial
    properties
        spatialDomain = 'S2'
        sht_handle
        soundSpeed = 340;
    end
    methods
        function this = itaSuperSph(varargin) %Constructor
            this = this@itaSuperSpatial(varargin{:});
        end
        function this = sht(this)            
            % error check
            if ~strcmp(this.spatialDomain,'S2')
                disp(['.spatialDomain = ''S2''    expected, but it is ''' this.spatialDomain '''']);
            elseif isempty(this.s.Y)
                disp('I need some base functions, try setting .spatialSampling.nmax to some small integer value')
            else
                % error check done, we can do the transform
                if isempty(this.sht_handle)
                    ita_verbose_info(' Setting the type of spherical harmonic transform to (unweighted) matrix inversion by pseudo-inverse.',1)
                    this.sht_handle = @inv_least_squares;
                    ita_verbose_info([' .... now (and in future) using the function itaSuperSph.' char(this.sht_handle) ' for this object.'],1);
                    ita_verbose_info(' Be aware that there could be better ways to do the SHT, depending on the used spatialSampling.',1)
                    ita_verbose_info(' To use your own matrix inversion, set the function handle .sht_handle = @inv_mySHT',1)
                    ita_verbose_info('    (check also the readymade functions in @itaSuperSph/inv_*)',1)
                end
                this = this.sht_handle(this);
                
                this.spatialDomain = 'SH';
                ita_verbose_info(['new spatial domain: ' this.spatialDomain],2);
            end
        end
        function this = isht(this)
            %         function this = isht(this, trafoMat)
            % error check
            if ~strcmp(this.spatialDomain,'SH')
                disp(['.spatialDomain = ''SH''    expected, but it is ''' this.spatialDomain '''']);
            elseif isempty(this.spatialSampling.Y)
                disp('I need some base functions, try setting .spatialSampling.nmax to some small integer value')
            else
                % do inverse spherical harmonic transform
                % this is exact, no need for multiple functions
                
                this.data = this.data * this.spatialSampling.Y.';
                this.spatialDomain = 'S2';
                ita_verbose_info(['new spatial domain: ' this.spatialDomain],2);
            end
        end
        function this = applyHankel(this)
            % error check
            if ~strcmp(this.spatialDomain,'MP')
                disp(['.spatialDomain = ''MP''    expected, but it is ''' this.spatialDomain '''']);
            elseif isempty(this.spatialSampling.Y)
                disp('I need some base functions, try setting .spatialSampling.nmax to some small integer value')
            else
                r = this.spatialSampling.r;
                if all(r(1) == r)
                    % only one radius
                    r = r(1);
                else
                    % use individual radii
                    ita_verbose_info('Having different radii is not possible here',0)
                    return;
                end
                hankelMat = calcHankel(this, r);
                this.data = this.data .* hankelMat;
                
                this.spatialDomain = 'SH';
            end
        end
        function this = apply_iHankel(this)
            % error check
            if ~strcmp(this.spatialDomain,'SH')
                disp(['.spatialDomain = ''SH''    expected, but it is ''' this.spatialDomain '''']);
            elseif isempty(this.spatialSampling.Y)
                disp('I need some base functions, try setting .spatialSampling.nmax to some small integer value')
            else
                r = this.spatialSampling.r;
                if all(r(1) == r)
                    % only one radius
                    r = r(1);
                else
                    % use individual radii
                    ita_verbose_info('Having different radii is not possible here',0)
                    return;
                end
                hankelMat = calcHankel(this, r);
                this.freqData = this.freqData ./ hankelMat;
                
                this.spatialDomain = 'MP';
            end
        end
        function this = mpt(this)

            % check for single radius only
            rUnique = unique(this.s.r);
            if numel(rUnique) == 1
                % then we can decompose it to be faster
                this = this.sht;
                this = this.apply_iHankel;
            else                
                % store Y and the full data in a save place
                thisDummy = this;
                freqData = zeros(this.nBins, size(this.s.Y,2));
                
                % do transform
                freqVector = this.freqVector;
                for ind = 1:this.nBins
                    
                    % calc hankel term for each radius
%                     hankelMat = calcHankel_singleFreq(this, freqVector(ind));
%                     H = this.s.Y .* hankelMat.';
                    % cheap hack: fake that H is the Y matrix
                    thisDummy.spatialSampling.Y = this.s.Y .* calcHankel_singleFreq(this, freqVector(ind)).';
                    thisDummy.freqData = this.freqData(ind,:);
                    thisDummy = sht(thisDummy);
                    thisDummy.spatialDomain = 'S2';
                    freqData(ind,:) = thisDummy.freqData;
                    ita_verbose_info(['f = ' num2str(freqVector(ind),'%05.0d')],1);
                end
                this.freqData = freqData;
            end

            this.spatialDomain = 'MP';
            ita_verbose_info(['new spatial domain: ' this.spatialDomain],2);
        end
        function this = impt(this)
            % check for single radius only
            rUnique = unique(this.s.r);
            % if there is more than one radius left, check for tiny
            % differences
            if numel(rUnique) > 1
                relDiff = (max(rUnique) - min(rUnique)) ./ max(rUnique);
                if relDiff < 1e-10 %#ok<BDSCI>
                    ita_verbose_info(['Tiny differences of ' num2str(100*relDiff) '% detected, simplifying this to a single radius.'],1);
                    rUnique = mean(rUnique);
                    this.s.r = rUnique;
                end
            end

            if numel(rUnique) == 1
                % then we can decompose it to be faster
                this = this.applyHankel;
                this = this.isht;
            else
                                
                % store Y and the full data in a save place
                thisDummy = this;
                freqData = zeros(this.nBins, size(this.s.Y,1));
                % do transform
                freqVector = this.freqVector;
                for ind = 1:this.nBins
                    
                    % calc hankel term for each radius
%                     hankelMat = calcHankel_singleFreq(this, freqVector(ind));
                    % compose the H matrix
%                     H = this.s.Y .* hankelMat.';
                    % cheap hack: fake that H is the Y matrix
                    thisDummy.spatialSampling.Y = this.s.Y .* calcHankel_singleFreq(this, freqVector(ind)).';
                    thisDummy.freqData = this.freqData(ind,:);
                    thisDummy.spatialDomain = 'SH';
                    thisDummy = isht(thisDummy);
                    freqData(ind,:) = thisDummy.freqData;
                    thisDummy.spatialDomain = 'S2';
                    ita_verbose_info(['f = ' num2str(freqVector(ind),'%05.0d')],1);
                end
                this.freqData = freqData;
            end
            this.spatialDomain = 'S2';
            ita_verbose_info(['new spatial domain: ' this.spatialDomain],2);
        end
        function value = calcHankel(this, r)
            % calculates the spherical Hankel function
            % result is a [nBins x nSH x nRadius] matrix
            %
            % if called with 2 input arguments, only use one radius
            
            if nargin < 2
                error('temporarily disabled')
                r = this.s.r;
            end
            
            % check for patterns of same radius to speed up the calculation
            [r, m, n] = unique(r); %#ok<ASGLU>
            
            c0 = this.soundSpeed;
            % TODO: add itaConstants support here
            
            % make sure we have freq data
            this = this';
            
            k = 2*pi* this.freqVector ./ c0;
            
            kr = kron(k, r.'); % freq x radii
            
            nSH = size(this.spatialSampling.Y,2);
            % 0 1 1 1 2 2 2 2 2 3 ...
            degreeIndex = ita_sph_linear2degreeorder(1:nSH);
            
            % avoid a MATLAB crash by disabling the division by zero
            kr(kr==0) = nan;
            
            value = zeros(this.nBins, nSH, numel(r));
            
            for ind = 1:numel(r)
                value(:,:,ind) = ita_sph_besselh(degreeIndex, 2, kr(:,ind));
            end
            
            % now reexpand the result (for all r's)
            value = value(:,:,n);
        end
        
        function value = calcHankel_singleFreq(this, f)
            % calculates the spherical Hankel function
            % result is a [nSH x nRadius] matrix
            
            if nargin < 2
                error('give the frequency')
            end
            
            r = this.s.r;            
            % check for patterns of same radius to speed up the calculation
            [r, m, n] = unique(r); %#ok<ASGLU>
            
            c0 = this.soundSpeed;
            % TODO: add itaConstants support here
            
            % make sure we have freq data
            this = this';
            
            k = 2*pi* f ./ c0;
            
            kr = kron(k, r.'); % freq x radii
            
            nSH = size(this.spatialSampling.Y,2);
            % 0 1 1 1 2 2 2 2 2 3 ...
            degreeIndex = ita_sph_linear2degreeorder(1:nSH);
            
            % avoid a MATLAB crash by disabling the division by zero
            kr(kr==0) = nan;
            
            value = ita_sph_besselh(degreeIndex.', 2, kr);
            
            % now reexpand the result (for all r's)
            value = value(:,n);
        end
        
        function varargout = surf(this, varargin)
            hFig = surf@itaSuperSpatial(this, varargin{:});
            if nargout
                varargout = {hFig};
            else
                varargout = {};
            end
        end
        function this = setColorSchemeSH(this,orders)
            % sets the color for line plots to bundle SH orders
            
            % if order is a single value ==> nmax
            % if order is [n1 n2] ==> range of orders
            % if no order is given ==> all orders
            
            if nargin < 2
                orders = [0 sqrt(this.nChannels)-1];
            end
            if numel(orders) == 1
                orders = [0 orders];
            end
            linOrders = ita_sph_degreeorder2linear(orders);
            orderVec = ita_sph_linear2degreeorder(linOrders(1):linOrders(2)) + 1;
            colortableSH = ita_plottools_colortable(orderVec);
            this.plotLineProperties = {};
            for ind = 1:size(colortableSH,1)
                this.plotLineProperties = [this.plotLineProperties; {'Color',colortableSH(ind,:)}];
            end
        end
    end
end
