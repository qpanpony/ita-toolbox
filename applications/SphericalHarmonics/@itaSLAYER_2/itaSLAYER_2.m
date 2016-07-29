
% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



<<<<<<< .mine
classdef itaSLAYER_2 < handle

    
    % About 'distorted sphere support': To simulate distorted spheres (ie.
    % the membrane center points are placed at different radii), all blocks
    % markes 'Remove for distorted sphere support' have to be removed,
    % correspondingly, all blocks marked 'Use for distorted sphere support'
    % have to be used. The support for distorted spheres has been dropped a
    % while ago, so it might not work with newer parts fo the code.
    
    properties
        % Base
        % nmax  : Maximum spherical harmonic order
        % sph   : Spherical coordinates of transducer positions
        nmax        = []
        sph         = [];
        
        % Physical array apertures
        % Will be computed by 'generate_aperturesSH'
        aperturesSH = []
        
        % Physical array MULTIPOLE directivites in SH domain.
        % MULTIPOLE: Stripped of their hankel radiation term! See Klein,
        % Optimization of a Method for the Synthesis of Transfer Functions 
        % of Variable Sound Source Directivities for Acoustical 
        % Measurements, RWTH Aachen University, Diploma Thesis, 2012.
        % In case the array will be simuated entirely this property will be
        % computed by 'generate_Mphys' based on 'aperturesSH'.
        % This property is also the interface for injecting measured
        % directivites of a real array.
        Mphys       = []
        
        % Orientation
        % Sets the orientations of the array during the measurements.
        % aziVec: Horizontal rotation ('phi') around the centerpoint of the array. Default: 0
        % eleVec: Vertical rotation ('theta') around the centerpoint of the array. Default: 0
        aziVec      = 0
        eleVec      = 0
        
        % Positioning
        % Sets the positions of the array during the measurements.
        % transVec: Off-centering of the whole array on the turn table. Default: 0
        % rotVec  : Rotation of the whole (possibly off-centered) array
        %           around the rotational center of the turn table. Default: 0
        transVec    = 0
        rotVec      = 0
        
        % Full virtual array MULTIPOLE directivities in SH domain.
        % MULTIPOLE: Stripped of their hankel radiation term! See Klein,
        % Optimization of a Method for the Synthesis of Transfer Functions 
        % of Variable Sound Source Directivities for Acoustical 
        % Measurements, RWTH Aachen University, Diploma Thesis, 2012.
        % Accumulation of the single transducer directivites ('Mphys') in
        % all orientations and in all orientations at all measurement positions.
        Mall        = []
        
        % Other physical properties
        % r_mem         : List of the membrane radii
        % k             : Wavenumber
        % displacement  : List of max. membrane displacements. Needed for
        %                 the computation of realistic transducer velocities.
        r_mem       = []
        displacement  = [];
        c = double(ita_constants('c'));
    end
    
    properties(Dependent)
        % Velocities in SH domain. Calculated on-the-fly.
        % Derived from apertures speed of sound 'c' and 'k'. See M. POLLOW 
        % and G. K. BEHLER, ÿVariable directivity for platonic sound 
        % sources based on spherical harmonics optimizationÿ Acta Acustica
        % United with Acustica, vol. 95, pp. 1082ÿ1092, 2009.
        velocitiesSH
        
        % Physical source powers. 
        % See M. POLLOW and G. K. BEHLER, ÿVariable directivity for 
        % platonic sound sources based on spherical harmonics optimizationÿ
        % Acta Acustica United with Acustica, vol. 95, pp. 1082ÿ1092, 2009.
        % coeffPower: Power in each spherical harmonic coefficient.
        % orderpower: Power within each spherical harmonic order.
        coeffPower
        orderPower
        
        % Tools
        % nCoeff: Number of spherical harmonic coefficients currently used.
        % nPoints: Number of spatial sampling points (ie. transducers).
        % nFrequencies: Number of fequency bins.
        % frequencies: List of all frequencies in [Hz].
        % r     : List of radii at membrane center points.
        % theta : List of spherical 'theta' coordinates of all membranes.
        % phi   : List of spherical 'phi' coordinates of all membranes.
        % degreeIndex: List of orders each coefficient is affiliated with.
        % frequencies: 
        nCoeff
        nPoints
        nFrequencies
        frequencies
        r
        theta
        phi
        degreeIndex
        k
    end
    
    methods
        function this = itaSLAYER_2(varargin)
            % 1 argument    : Triggers the copy constructor.
            % 4 arguments   : Default case for an entirely simulated array.
            
            % Initial constructor
            if nargin >= 4
                % Read membrane positions.
                var_membrane_positions = varargin{1};
                
                % Begin - Remove for distorted sphere support %
                if gt(unique(var_membrane_positions(:,1)),1)
                    error('itaSLAYER: No can do! That ain`t a sphere!');
                end
                % End - Remove for distorted sphere support %
                
                % Read membrane radii.
                var_membrane_radii = varargin{2};
                % Read membrane displacements.
                var_membrane_displacement = varargin{3};
                % Read maximum order.
                var_nmax = varargin{4};
                
                % Set read values.
                this.sph = var_membrane_positions;
                this.r_mem = var_membrane_radii;
                this.displacement = var_membrane_displacement;
                this.nmax = var_nmax;
                
                % Generate apertures in SH domain.
                this.generate_aperturesSH;
                % Generate directivities of all transducers. SH domain.
                % Multipole reprenstation.
                %this.generate_Mphys;
                
                s.c = double(ita_constants('c'));
                if numel(varargin) > 4
                    varargin = varargin(5:end);
                else
                    varargin = {};
                end
                    
                sOut = ita_parse_arguments(s,varargin);
                this.c = sOut.c;
            % Copy constructor    
            elseif nargin == 1
                % Get saved field names, and try to set the values.
                fieldName = fieldnames(varargin{1});
                for ind = 1:numel(fieldName);
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            end
        end
        
        % Base
        % Set order limit. The apertures as base have to be reset
        % accordingly. The directivities derived from the apertures will be
        % reset automatically.
        function set.nmax(this,value)
            this.nmax = value;
            this.reset_aperturesSH;
        end
        
        % Set spherical coordinates fo the sampling points (ie. transducer
        % positions. The apertues as base have to be reset accordingly. The
        % directivites dervied from the apertures will be reset
        % automatically.
        function set.sph(this,value)
            this.sph = value;
            this.reset_aperturesSH;
        end
        
        % Physical array multipole directivites
        % Set all physical directivites. SH domain.
        % Multipole respresentation. The simulation result based on the
        % physical directivites has to be reset accordingly.
        function set.Mphys(this,value)
            this.Mphys = value;
            this.reset_Mall;
        end
        
        % Orientation
        % Set horizontal orientation / ('phi') rotation of the Array about 
        % its own center point. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.aziVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.aziVec = value;
            this.reset_Mall;
        end
        
        % Set vertical orientation / ('theta') rotation of the Array about
        % its own center point. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.eleVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.eleVec = value;
            this.reset_Mall;
        end
        
        % Positioning
        % Set the translations to off-center the array from the center
        % point of the turn table. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.transVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.transVec = value;
            this.reset_Mall;
        end
        
        % Set rotational positions for the turn table during the
        % measurements. The simulation result incorporating the different
        % orientations during the measurmeent has to be reset accordingly.
        function set.rotVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.rotVec = value;
            this.reset_Mall;
        end
        
        % Other physical properties
        % Set maximum membrane displacement for velocity computation. The
        % physical directivites of the single transducers have to be reset
        % accordingly.
        function set.displacement(this,value)
            if iscolumn(value)
                value = value';
            end
            this.displacement = value;
            this.reset_Mphys;
        end
        
        function set.r_mem(this,value)
            if iscolumn(value)
                value = value';
            end
            this.r_mem = value;
            this.reset_Mphys;
        end
            
        
        % Set all the wavenumbers that should be regarded during the
        % simulations. The physical directivites of the single
        % transducers have to be reset accordingly.
        function value = get.k(this)
            value = 2 * pi / this.c .* ita_ANSI_center_frequencies;
        end
        function set.k(this,value)
            if iscolumn(value)
                value = value';
            end
            this.k = value;
            this.reset_Mphys;
        end
        
        % Velocities
        function value = get.velocitiesSH(this)
%             if this.nPoints == 0
%                 value = [];
%                 return
%             end
            disp_vec = this.displacement;
            if size(disp_vec,2)==1
                disp_vec = repmat(disp_vec,1,this.nPoints);
            end
%             c = double(ita_constants('c'));
            vel_list = ones(1,this.nPoints,this.nFrequencies);
            
            for idf = 1:this.nFrequencies
                vel_list(1,:,idf) = 1i * this.k(idf) * this.c .* disp_vec;
            end
            vel_list = repmat(vel_list,[this.nCoeff 1 1]);
            apSH = repmat(this.aperturesSH, [1 1 this.nFrequencies]);
            value = bsxfun(@times, apSH, vel_list);
        end
        
        % Physical source powers
        function value = get.coeffPower(this)
            % Get set of unique north pole caps
            caps_mat = this.generate_capsSH;
            % Initialize resulting matrix
            value = zeros(this.nCoeff,size(caps_mat,3));
            % Get energy in every coefficient for every unique north pole cap
            for idc = 1:size(caps_mat,3)
                value(:,idc) = abs(diag(caps_mat(:,:,idc))).^2;
            end
        end
        
        function value = get.orderPower(this)
            coeffPower_mat = this.coeffPower;
            orderSumMat = this.generate_orderSumMat;
            value = zeros(this.nmax+1, size(coeffPower_mat,2));
            % Get power in single SH orders
            for idc = 1:size(coeffPower_mat,2)
                value(:,idc) = orderSumMat * coeffPower_mat(:,idc);
            end
        end
        
        % Tools
        function value = get.nCoeff(this)
            value = (this.nmax+1)^2;
        end
        
        function value = get.nPoints(this)
            value = size(this.sph,1);
        end
        
        function value = get.nFrequencies(this)
            value = size(this.k,2);
        end
        
        function value = get.r(this)
            value = this.sph(:,1);
        end
        
        function value = get.theta(this)
            value = this.sph(:,2);
        end
        
        function value = get.phi(this)
            value = this.sph(:,3);
        end
        
        function value = get.degreeIndex(this)
            value = ita_sph_linear2degreeorder(1:this.nCoeff);
        end
        
        function value = get.frequencies(this)
            if ~isnan(this.k)
                %c = double(ita_constants('c'));
                value = this.k * this.c / (2 * pi);
            else
                value = [];
            end
        end
        
        function set.frequencies(this,value)
            if iscolumn(value)
                value = value';
            end
            %c = double(ita_constants('c'));
            this.k = 2 * pi * value / this.c;
            this.reset_Mphys;
        end
        
        % Property Generators
        
        function generate_aperturesSH(this)
            
            % Generate northpole caps
            caps_mat = this.generate_capsSH;
            
            % Generate Sampling matrices
            S = this.generate_S;
            
            value = zeros(this.nCoeff,this.nPoints*size(S,3));
            
            for idr = 1:size(S,3)
                value(:,this.nPoints*(idr-1)+1:this.nPoints*idr) = caps_mat(:,:,idr)*S(:,:,idr);
            end
            
            % Eliminate 0-columns
            this.aperturesSH = value(:,any(value));
            
        end
        
        function generate_Mphys(this)
            % Multiply velocitiesSH of all physical membranes with their
            % multipole factors.
            
            MP = generate_MP(this);
            velSH = this.velocitiesSH;
            
            value = zeros(this.nCoeff,this.nPoints,this.nFrequencies);
            for idx=1:this.nFrequencies
                value(:,:,idx) = MP(:,:,idx) * velSH(:,:,idx);
            end
            this.Mphys = value;
        end
        
        function generate_Mall(this)
            
            % To reduce the computational effort, get a list of unique
            % angles, together with a mapping vector, which maps every
            % element of the redundant vector to its representative in the
            % new reduced vector.
            [unique_angles , ~, unique_angles_map] = unique([this.eleVec, this.aziVec, this.rotVec]);
            unique_map_ele = unique_angles_map(1:size(this.eleVec,2));
            unique_map_azi   = unique_angles_map(size(this.eleVec,2)+1:size(this.eleVec,2)+size(this.aziVec,2));
            unique_map_rot   = unique_angles_map(size(this.eleVec,2)+size(this.aziVec,2)+1:end);
            
            % Make sure the more complicated rotation matrices will be
            % needed, before generating them.
            temp_eleVec = this.eleVec;
            temp_eleVec(temp_eleVec == 0) = [];
            
            temp_transVec = this.transVec;
            temp_transVec(temp_transVec == 0) = [];
            
            temp_unique_angles = unique_angles;
            temp_unique_angles(temp_unique_angles == 0) = [];
            
            if size([temp_unique_angles temp_transVec],2)==0
                value = this.Mphys;
            else
                %Initialize the different stages of M matrices
                %M_azi       = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2));
                M_ele       = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2));
                %M_trans_rot = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2));
                %M_trans     = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2)*size(this.transVec,2));
                M_freq      = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2)*size(this.transVec,2),this.nFrequencies);
                
                % Generate set of unique D matrices.
                D_mat = zeros(this.nCoeff,this.nCoeff,size(unique_angles,2));
                for ida = 1:size(unique_angles,2);
                    D_mat(:,:,ida) = ita_sph_zrotT(unique_angles(ida),this.nmax);
                end
                
                if gt(size(temp_eleVec,2),0) || gt(size(temp_transVec,2),0)
                    % Get D matrix for pos pi/2 rotation around y. This is the only
                    % y rotation ever needed, since all others will be replaced by
                    % the combination of said +pi/2 around z, +pi/2 around y,
                    % +pi around z, the desired angle yet another +pi/2 around y
                    % and +pi/2 around z.
                    D_beta_pos  = ita_sph_wignerD(this.nmax, 0  ,pi/2, 0);
                    % swapped back sign convention (mpo)
                else
                    D_beta_pos = 1;
                end
                
                if gt(size(temp_eleVec,2),0)
                    D_z_pi_half = ita_sph_zrotT(pi/2,this.nmax);
                    D_z_pi      = ita_sph_zrotT( pi ,this.nmax);
                    
                    D_pre  = D_z_pi * D_beta_pos * D_z_pi_half;
                    D_past = D_z_pi_half * D_beta_pos;
                else
                    D_beta_pos = 1;
                    D_pre = 1;
                    D_past = 1;
                end
                
                if gt(size(temp_eleVec,2),0) || gt(size(temp_transVec,2),0)
                    D_beta_neg = D_past * ita_sph_zrotT(-pi/2,this.nmax) * D_pre;
                else
                    D_beta_neg = 1;
                end
                
                % Now, what costs a lot of time is the computation of redundant
                % theta rotations. If there are still redundancies left in
                % unique_map_theta, eliminate them, and pre calculate the
                % really unique theta rotations.
                
                [really_unique_ele, ~, really_unique_map_ele] = unique(unique_map_ele);
                
                D_mat_ele = zeros(this.nCoeff,this.nCoeff,size(really_unique_ele,2));
                for idt = 1:size(really_unique_ele,2)
                    D_mat_ele(:,:,idt) = D_past * D_mat(:,:,really_unique_ele(idt)) * D_pre;
                end
                
                % Generate Mall
                for idk = 1:this.nFrequencies
                    % Get M for all elevation and azimiuth orientations in the
                    % center position for this k.
                    for ide = 1:size(this.eleVec,2)
                        % Go through all elevations
                        % Incline original array
                        ele_block_begin = ((ide-1)*this.nPoints*size(this.aziVec,2))+1;
                        %ele_block_end   = ide*this.nPoints*size(this.aziVec,2);
                        M_init = D_mat_ele(:,:,really_unique_map_ele(ide)) * this.Mphys(:,:,idk);
                        for ida = 1:size(this.aziVec,2)
                            % Go through all azimuth orientations
                            azi_block_begin = ((ida-1)*this.nPoints)+1;
                            azi_block_end   = ida*this.nPoints;
                            %M_azi(:,((ida-1)*this.nPoints)+1:ida*this.nPoints) = D_mat(:,:,unique_map_azi(ida)) * M_init;
                            M_ele(:,ele_block_begin+azi_block_begin-1:ele_block_begin+azi_block_end-1) = D_mat(:,:,unique_map_azi(ida)) * M_init;
                        end
                        % Save rotation of current elevation
                        %M_ele(:,((ide-1)*this.nPoints*size(this.aziVec,2))+1:ide*this.nPoints*size(this.aziVec,2)) = M_azi;
                    end
                    % M_ele contains all orientations at the center position.
                    % Based on that, shift the virtual center array to the
                    % translated positions and the rotate it around the old
                    % center according to rotVec.
                    for idt = 1:size(this.transVec,2)
                        % M_trans_init is the virtual center array M_ele,
                        % translated to the new position. Just compute matrices
                        % if translation other than 0.
                        trans_block_begin = (idt-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))+1;
                        %trans_block_end   = idt*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2));
                        if~(this.transVec(idt)==0)
                            M_trans_init = D_beta_pos * ita_sph_ztransT(this.transVec(idt),this.nmax,this.k(idk)) * D_beta_neg * M_ele;
                        else
                            M_trans_init = M_ele;
                        end
                        for idr = 1:size(this.rotVec,2)
                            rot_block_begin = (idr-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))+1;
                            rot_block_end   = idr*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2));
                            %M_trans_rot(:,(idr-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))+1:idr*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))) = D_mat(:,:,unique_map_rot(idr)) * M_trans_init;
                            M_freq(:,trans_block_begin+rot_block_begin-1:trans_block_begin+rot_block_end-1,idk)= D_mat(:,:,unique_map_rot(idr)) * M_trans_init;
                        end
                        %M_trans(:,(idt-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))+1:idt*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))) = M_trans_rot;
                    end
                    %M_freq(:,:,idk) = M_trans;
                end
                value = M_freq;
            end
            this.Mall = value;
        end
        
        % Matrix generators
        
        function value = generate_S(this)
            % To reduce the computational effort, get a list of unique
            % r_mem / r combinations, together with a mapping vector, which
            % maps every element of the redundant vectors to their
            % representative in the new reduced vector.
            r_combinations = asin(this.r_mem./this.r');
            unique_r = unique(r_combinations);
            
            % Worst case allocation for S. 0-colums will be removed later.
            S = zeros(this.nCoeff,this.nPoints,size(unique_r,2));
            
            % Generate sampling matrix for every unique
            % r_mem/r_combination
            for idr = 1:size(unique_r,2)
                r_indices = r_combinations==unique_r(idr);
                s = itaCoordinates(this.sph(r_indices,:),'sph');
                S(:,1:s.nPoints,idr) = ita_sph_base(s,this.nmax)';
            end
            value = S;
        end
        
        function value = generate_capsSH(this)
            % To reduce the computational effort, get a list of unique
            % r_mem / r combinations, together with a mapping vector, which
            % maps every element of the redundant vectors to their
            % representative in the new reduced vector.
            r_combinations = asin(this.r_mem./this.r');
            unique_r = unique(r_combinations);
            
            % Generate set of unique northpole cap matrices.
            value = zeros(this.nCoeff, this.nCoeff, size(unique_r,2));
            spread_matrix = ita_sph_eye(this.nmax,'nm-nm');
            spread_factor = sqrt(4*pi./(2*this.degreeIndex.'+1));
            
            for idr = 1:size(unique_r,2)
                value(:,:,idr) = diag(spread_factor .* (spread_matrix * ita_sph_northpolecapSH(this.nmax, unique_r(idr))));
            end
        end
        
        function value = generate_MP(this)
            % Generate Multipole conversion factor
            % Based on Williams , 'Fourier Acoustics', eq. 6.103
            % Z = P(r_0) / V(r_0) = 1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)')
            % Modified to save computation time, (P(r_0) / hankel(k*r_0)) is considered to be the multipole representation:
            % MP = (P(r_0) / hankel(k*r_0)) / V(r_0) = 1i * rho_0 * c / (hankel(k*r_0)')
            % Written as transformation matrix diag(1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)'))
            
            % Begin - Use for distorted sphere support %
            
            % In this case, Z not a transformation matrix, to maintain the
            % possibilty to use different array radii for every driver.
            % den = zeros(this.nCoeff,this.nPoints,this.nFrequencies);
            % pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            % for idx = 1:this.nFrequencies
            %     den(:,:,idx) = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r');
            % end
            % value = pre / den;
            
            % End - Use for distorted sphere support %
            
            % Begin - Remove for distorted sphere support %
            
            pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            value = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            for idx=1:this.nFrequencies
                den = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r(1));
                value(:,:,idx) = diag(pre./den);
            end
            
            % End - Remove for distorted sphere support %
            
        end
        
        function value = generate_Z0(this)
            % Get the real, physically correct radiation impedance,
            % contrary to the similar multipole factor.
            % Based on Williams , 'Fourier Acoustics', eq. 6.103
            % Z = P(r_0) / V(r_0) = 1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)')
            % Written as transformation matrix diag(1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)'))
            
            % Begin - Use for distorted sphere support %
            
            % num = zeros(this.nCoeff,size(this.r,1),this.nFrequencies);
            % den = zeros(this.nCoeff,size(this.r,1),this.nFrequencies);
            % pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            % for idx = 1:this.nFrequencies
            %     num(:,:,idx) = ita_sph_besselh(this.degreeIndex',2,this.k(idx)*this.r');
            %     den(:,:,idx) = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r');
            % end
            % value = pre * bsxfun(@rdivide,num,den);
            
            % End - Use for distorted sphere support %
            
            % Begin - Remove for distorted sphere support %
            
            pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            value = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            for idx=1:this.nFrequencies
                num = ita_sph_besselh(this.degreeIndex',2,this.k(idx)*this.r(1));
                den = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r(1));
                value(:,:,idx) = diag(pre*num./den);
            end
            
            % End - Remove for distorted sphere support %
            
        end
        
                function aux = generate_H(this,r)
            % Generate hankel term for the radiation of the multipole
            % source.
            % Based on Williams , 'Fourier Acoustics', eq. 6.97
            % P(r) / P(r_0) = hankel(k*r) / hankel(k*r_0)
            % Modified to match the chosen Multipole representation:
            % H = P(r) / (P(r_0) / hankel(k_r_0)) = hankel(k*r)
            % Written as transformation matrix diag(hankel_n(k*r))
            
%             a = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            %             for idx=1:this.nFrequencies
            %                 value(:,:,idx) = diag(ita_sph_besselh(this.degreeIndex',2, this.k(idx)*r));
            %             end
            
            %pdi speed up
            if isinf(r)
                % NOT VERYFIED!
                aux = bsxfun(@times, 1i ./ this.k, (1i.^this.degreeIndex).');
            else
                aux = ita_sph_besselh(this.degreeIndex',2, this.k*r);
            end
        end
        
        function value = generate_orderSumMat(this)
            % Assemble diagonal block matrix for summation in orders
            row = ita_sph_linear2degreeorder(1:this.nCoeff)+1;
            col = 1:this.nCoeff;
            value = accumarray([row(:) col(:)],ones(this.nCoeff,1));
        end
        
        % Radiation        
        function value = radiate(this,r)
            % Multiply Hankel matrix and Mutipole matrix.
            % This is done for every regarded frequency.
            % There is an alternative method, sorting the
            % matrices into cells for every frequency with num2cell() and
            % then multiplying the corrspoing cell contents with cellfun().
            % cat() then sorts the contents back into one 3D matrix:
            % value = cellfun(@mtimes,num2cell(this.generate_H(r),[1 2]),num2cell(M,[1 2]),'UniformOutput',false);
            % value = cat(3,value{:});
            % However, this method makes extensive use of the computers
            % memory and is slower, especially if paging is needed to cope
            % with the demands.
            
            M = this.Mall;
            value = zeros(this.nCoeff,size(M,2),this.nFrequencies);
            H = this.generate_H(r);
            for idf = 1:this.nFrequencies
%                 value(:,idf) = H(:,idf).*M(:,:,idf);
                value(:,:,idf) = bsxfun(@times,H(:,idf),M(:,:,idf));
            end
        end
        
        
        % Reset
        function reset_aperturesSH(this)
            this.aperturesSH = [];
            this.reset_Mphys;
        end
        
        function reset_Mphys(this)
            this.Mphys = [];
        end
        
        function reset_Mall(this)
            this.Mall = [];
        end
        
        % Saving
        function sObj = saveobj(this)
            propertylist = {'nmax','sph','r_mem','aperturesSH','displacement','k','aziVec','eleVec','transVec','rotVec','Mphys','Mall'};
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        %Loading
        function this = loadobj(sObj)
            if isfield(sObj,'classrevision'), sObj = rmfield(sObj,{'classrevision'}); end;
            if isfield(sObj,'classname'), sObj = rmfield(sObj,{'classname'}); end;
            try
                this = itaSLAYER(sObj);
            catch errmsg
                disp(errmsg);
            end
        end
        
    end
end=======
classdef itaSLAYER_2 < handle


    
    % About 'distorted sphere support': To simulate distorted spheres (ie.
    % the membrane center points are placed at different radii), all blocks
    % markes 'Remove for distorted sphere support' have to be removed,
    % correspondingly, all blocks marked 'Use for distorted sphere support'
    % have to be used. The support for distorted spheres has been dropped a
    % while ago, so it might not work with newer parts fo the code.
    
    properties
        % Base
        % nmax  : Maximum spherical harmonic order
        % sph   : Spherical coordinates of transducer positions
        nmax        = []
        sph         = [];
        
        % Physical array apertures
        % Will be computed by 'generate_aperturesSH'
        aperturesSH = []
        
        % Physical array MULTIPOLE directivites in SH domain.
        % MULTIPOLE: Stripped of their hankel radiation term! See Klein,
        % Optimization of a Method for the Synthesis of Transfer Functions 
        % of Variable Sound Source Directivities for Acoustical 
        % Measurements, RWTH Aachen University, Diploma Thesis, 2012.
        % In case the array will be simuated entirely this property will be
        % computed by 'generate_Mphys' based on 'aperturesSH'.
        % This property is also the interface for injecting measured
        % directivites of a real array.
        Mphys       = []
        
        % Orientation
        % Sets the orientations of the array during the measurements.
        % aziVec: Horizontal rotation ('phi') around the centerpoint of the array. Default: 0
        % eleVec: Vertical rotation ('theta') around the centerpoint of the array. Default: 0
        aziVec      = 0
        eleVec      = 0
        
        % Positioning
        % Sets the positions of the array during the measurements.
        % transVec: Off-centering of the whole array on the turn table. Default: 0
        % rotVec  : Rotation of the whole (possibly off-centered) array
        %           around the rotational center of the turn table. Default: 0
        transVec    = 0
        rotVec      = 0
        
        % Full virtual array MULTIPOLE directivities in SH domain.
        % MULTIPOLE: Stripped of their hankel radiation term! See Klein,
        % Optimization of a Method for the Synthesis of Transfer Functions 
        % of Variable Sound Source Directivities for Acoustical 
        % Measurements, RWTH Aachen University, Diploma Thesis, 2012.
        % Accumulation of the single transducer directivites ('Mphys') in
        % all orientations and in all orientations at all measurement positions.
        Mall        = []
        
        % Other physical properties
        % r_mem         : List of the membrane radii
        % k             : Wavenumber
        % displacement  : List of max. membrane displacements. Needed for
        %                 the computation of realistic transducer velocities.
        r_mem       = []
        displacement  = [];
        c = double(ita_constants('c'));
    end
    
    properties(Dependent)
        % Velocities in SH domain. Calculated on-the-fly.
        % Derived from apertures speed of sound 'c' and 'k'. See M. POLLOW 
        % and G. K. BEHLER, ÿVariable directivity for platonic sound 
        % sources based on spherical harmonics optimizationÿ Acta Acustica
        % United with Acustica, vol. 95, pp. 1082ÿ1092, 2009.
        velocitiesSH
        
        % Physical source powers. 
        % See M. POLLOW and G. K. BEHLER, ÿVariable directivity for 
        % platonic sound sources based on spherical harmonics optimizationÿ
        % Acta Acustica United with Acustica, vol. 95, pp. 1082ÿ1092, 2009.
        % coeffPower: Power in each spherical harmonic coefficient.
        % orderpower: Power within each spherical harmonic order.
        coeffPower
        orderPower
        
        % Tools
        % nCoeff: Number of spherical harmonic coefficients currently used.
        % nPoints: Number of spatial sampling points (ie. transducers).
        % nFrequencies: Number of fequency bins.
        % frequencies: List of all frequencies in [Hz].
        % r     : List of radii at membrane center points.
        % theta : List of spherical 'theta' coordinates of all membranes.
        % phi   : List of spherical 'phi' coordinates of all membranes.
        % degreeIndex: List of orders each coefficient is affiliated with.
        % frequencies: 
        nCoeff
        nPoints
        nFrequencies
        frequencies
        r
        theta
        phi
        degreeIndex
        k
    end
    
    methods
        function this = itaSLAYER_2(varargin)
            % 1 argument    : Triggers the copy constructor.
            % 4 arguments   : Default case for an entirely simulated array.
            
            % Initial constructor
            if nargin >= 4
                % Read membrane positions.
                var_membrane_positions = varargin{1};
                
                % Begin - Remove for distorted sphere support %
                if gt(unique(var_membrane_positions(:,1)),1)
                    error('itaSLAYER: No can do! That ain`t a sphere!');
                end
                % End - Remove for distorted sphere support %
                
                % Read membrane radii.
                var_membrane_radii = varargin{2};
                % Read membrane displacements.
                var_membrane_displacement = varargin{3};
                % Read maximum order.
                var_nmax = varargin{4};
                
                % Set read values.
                this.sph = var_membrane_positions;
                this.r_mem = var_membrane_radii;
                this.displacement = var_membrane_displacement;
                this.nmax = var_nmax;
                
                % Generate apertures in SH domain.
                this.generate_aperturesSH;
                % Generate directivities of all transducers. SH domain.
                % Multipole reprenstation.
                %this.generate_Mphys;
                
                s.c = double(ita_constants('c'));
                if numel(varargin) > 4
                    varargin = varargin(5:end);
                else
                    varargin = {};
                end
                    
                sOut = ita_parse_arguments(s,varargin);
                this.c = sOut.c;
            % Copy constructor    
            elseif nargin == 1
                % Get saved field names, and try to set the values.
                fieldName = fieldnames(varargin{1});
                for ind = 1:numel(fieldName);
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            end
        end
        
        % Base
        % Set order limit. The apertures as base have to be reset
        % accordingly. The directivities derived from the apertures will be
        % reset automatically.
        function set.nmax(this,value)
            this.nmax = value;
            this.reset_aperturesSH;
        end
        
        % Set spherical coordinates fo the sampling points (ie. transducer
        % positions. The apertues as base have to be reset accordingly. The
        % directivites dervied from the apertures will be reset
        % automatically.
        function set.sph(this,value)
            this.sph = value;
            this.reset_aperturesSH;
        end
        
        % Physical array multipole directivites
        % Set all physical directivites. SH domain.
        % Multipole respresentation. The simulation result based on the
        % physical directivites has to be reset accordingly.
        function set.Mphys(this,value)
            this.Mphys = value;
            this.reset_Mall;
        end
        
        % Orientation
        % Set horizontal orientation / ('phi') rotation of the Array about 
        % its own center point. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.aziVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.aziVec = value;
            this.reset_Mall;
        end
        
        % Set vertical orientation / ('theta') rotation of the Array about
        % its own center point. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.eleVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.eleVec = value;
            this.reset_Mall;
        end
        
        % Positioning
        % Set the translations to off-center the array from the center
        % point of the turn table. The simulation result incorporating the
        % different orientations during the measurmeent has to be reset
        % accordingly.
        function set.transVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.transVec = value;
            this.reset_Mall;
        end
        
        % Set rotational positions for the turn table during the
        % measurements. The simulation result incorporating the different
        % orientations during the measurmeent has to be reset accordingly.
        function set.rotVec(this,value)
            if(gt(size(value,1),size(value,2)))
                value = value';
            end
            this.rotVec = value;
            this.reset_Mall;
        end
        
        % Other physical properties
        % Set maximum membrane displacement for velocity computation. The
        % physical directivites of the single transducers have to be reset
        % accordingly.
        function set.displacement(this,value)
            if iscolumn(value)
                value = value';
            end
            this.displacement = value;
            this.reset_Mphys;
        end
        
        function set.r_mem(this,value)
            if iscolumn(value)
                value = value';
            end
            this.r_mem = value;
            this.reset_Mphys;
        end
            
        
        % Set all the wavenumbers that should be regarded during the
        % simulations. The physical directivites of the single
        % transducers have to be reset accordingly.
        function value = get.k(this)
            value = 2 * pi / this.c .* ita_ANSI_center_frequencies;
        end
        function set.k(this,value)
            if iscolumn(value)
                value = value';
            end
            this.k = value;
            this.reset_Mphys;
        end
        
        % Velocities
        function value = get.velocitiesSH(this)
%             if this.nPoints == 0
%                 value = [];
%                 return
%             end
            disp_vec = this.displacement;
            if size(disp_vec,2)==1
                disp_vec = repmat(disp_vec,1,this.nPoints);
            end
%             c = double(ita_constants('c'));
            vel_list = ones(1,this.nPoints,this.nFrequencies);
            
            for idf = 1:this.nFrequencies
                vel_list(1,:,idf) = 1i * this.k(idf) * this.c .* disp_vec;
            end
            vel_list = repmat(vel_list,[this.nCoeff 1 1]);
            apSH = repmat(this.aperturesSH, [1 1 this.nFrequencies]);
            value = bsxfun(@times, apSH, vel_list);
        end
        
        % Physical source powers
        function value = get.coeffPower(this)
            % Get set of unique north pole caps
            caps_mat = this.generate_capsSH;
            % Initialize resulting matrix
            value = zeros(this.nCoeff,size(caps_mat,3));
            % Get energy in every coefficient for every unique north pole cap
            for idc = 1:size(caps_mat,3)
                value(:,idc) = abs(diag(caps_mat(:,:,idc))).^2;
            end
        end
        
        function value = get.orderPower(this)
            coeffPower_mat = this.coeffPower;
            orderSumMat = this.generate_orderSumMat;
            value = zeros(this.nmax+1, size(coeffPower_mat,2));
            % Get power in single SH orders
            for idc = 1:size(coeffPower_mat,2)
                value(:,idc) = orderSumMat * coeffPower_mat(:,idc);
            end
        end
        
        % Tools
        function value = get.nCoeff(this)
            value = (this.nmax+1)^2;
        end
        
        function value = get.nPoints(this)
            value = size(this.sph,1);
        end
        
        function value = get.nFrequencies(this)
            value = size(this.k,2);
        end
        
        function value = get.r(this)
            value = this.sph(:,1);
        end
        
        function value = get.theta(this)
            value = this.sph(:,2);
        end
        
        function value = get.phi(this)
            value = this.sph(:,3);
        end
        
        function value = get.degreeIndex(this)
            value = ita_sph_linear2degreeorder(1:this.nCoeff);
        end
        
        function value = get.frequencies(this)
            if ~isnan(this.k)
                %c = double(ita_constants('c'));
                value = this.k * this.c / (2 * pi);
            else
                value = [];
            end
        end
        
        function set.frequencies(this,value)
            if iscolumn(value)
                value = value';
            end
            %c = double(ita_constants('c'));
            this.k = 2 * pi * value / this.c;
            this.reset_Mphys;
        end
        
        % Property Generators
        
        function generate_aperturesSH(this)
            
            % Generate northpole caps
            caps_mat = this.generate_capsSH;
            
            % Generate Sampling matrices
            S = this.generate_S;
            
            value = zeros(this.nCoeff,this.nPoints*size(S,3));
            
            for idr = 1:size(S,3)
                value(:,this.nPoints*(idr-1)+1:this.nPoints*idr) = caps_mat(:,:,idr)*S(:,:,idr);
            end
            
            % Eliminate 0-columns
            this.aperturesSH = value(:,any(value));
            
        end
        
        function generate_Mphys(this)
            % Multiply velocitiesSH of all physical membranes with their
            % multipole factors.
            
            MP = generate_MP(this);
            velSH = this.velocitiesSH;
            
            value = zeros(this.nCoeff,this.nPoints,this.nFrequencies);
            for idx=1:this.nFrequencies
                value(:,:,idx) = MP(:,:,idx) * velSH(:,:,idx);
            end
            this.Mphys = value;
        end
        
        function generate_Mall(this)
            
            % To reduce the computational effort, get a list of unique
            % angles, together with a mapping vector, which maps every
            % element of the redundant vector to its representative in the
            % new reduced vector.
            [unique_angles , ~, unique_angles_map] = unique([this.eleVec, this.aziVec, this.rotVec]);
            unique_map_ele = unique_angles_map(1:size(this.eleVec,2));
            unique_map_azi   = unique_angles_map(size(this.eleVec,2)+1:size(this.eleVec,2)+size(this.aziVec,2));
            unique_map_rot   = unique_angles_map(size(this.eleVec,2)+size(this.aziVec,2)+1:end);
            
            % Make sure the more complicated rotation matrices will be
            % needed, before generating them.
            temp_eleVec = this.eleVec;
            temp_eleVec(temp_eleVec == 0) = [];
            
            temp_transVec = this.transVec;
            temp_transVec(temp_transVec == 0) = [];
            
            temp_unique_angles = unique_angles;
            temp_unique_angles(temp_unique_angles == 0) = [];
            
            if size([temp_unique_angles temp_transVec],2)==0
                value = this.Mphys;
            else
                %Initialize the different stages of M matrices
                %M_azi       = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2));
                M_ele       = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2));
                %M_trans_rot = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2));
                %M_trans     = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2)*size(this.transVec,2));
                M_freq      = zeros(this.nCoeff,this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2)*size(this.transVec,2),this.nFrequencies);
                
                % Generate set of unique D matrices.
                D_mat = zeros(this.nCoeff,this.nCoeff,size(unique_angles,2));
                for ida = 1:size(unique_angles,2);
                    D_mat(:,:,ida) = ita_sph_zrotT(unique_angles(ida),this.nmax);
                end
                
                if gt(size(temp_eleVec,2),0) || gt(size(temp_transVec,2),0)
                    % Get D matrix for pos pi/2 rotation around y. This is the only
                    % y rotation ever needed, since all others will be replaced by
                    % the combination of said +pi/2 around z, +pi/2 around y,
                    % +pi around z, the desired angle yet another +pi/2 around y
                    % and +pi/2 around z.
                    D_beta_pos  = ita_sph_wignerD(this.nmax, 0  ,pi/2, 0);
                    % swapped back sign convention (mpo)
                else
                    D_beta_pos = 1;
                end
                
                if gt(size(temp_eleVec,2),0)
                    D_z_pi_half = ita_sph_zrotT(pi/2,this.nmax);
                    D_z_pi      = ita_sph_zrotT( pi ,this.nmax);
                    
                    D_pre  = D_z_pi * D_beta_pos * D_z_pi_half;
                    D_past = D_z_pi_half * D_beta_pos;
                else
                    D_beta_pos = 1;
                    D_pre = 1;
                    D_past = 1;
                end
                
                if gt(size(temp_eleVec,2),0) || gt(size(temp_transVec,2),0)
                    D_beta_neg = D_past * ita_sph_zrotT(-pi/2,this.nmax) * D_pre;
                else
                    D_beta_neg = 1;
                end
                
                % Now, what costs a lot of time is the computation of redundant
                % theta rotations. If there are still redundancies left in
                % unique_map_theta, eliminate them, and pre calculate the
                % really unique theta rotations.
                
                [really_unique_ele, ~, really_unique_map_ele] = unique(unique_map_ele);
                
                D_mat_ele = zeros(this.nCoeff,this.nCoeff,size(really_unique_ele,2));
                for idt = 1:size(really_unique_ele,2)
                    D_mat_ele(:,:,idt) = D_past * D_mat(:,:,really_unique_ele(idt)) * D_pre;
                end
                
                % Generate Mall
                for idk = 1:this.nFrequencies
                    % Get M for all elevation and azimiuth orientations in the
                    % center position for this k.
                    for ide = 1:size(this.eleVec,2)
                        % Go through all elevations
                        % Incline original array
                        ele_block_begin = ((ide-1)*this.nPoints*size(this.aziVec,2))+1;
                        %ele_block_end   = ide*this.nPoints*size(this.aziVec,2);
                        M_init = D_mat_ele(:,:,really_unique_map_ele(ide)) * this.Mphys(:,:,idk);
                        for ida = 1:size(this.aziVec,2)
                            % Go through all azimuth orientations
                            azi_block_begin = ((ida-1)*this.nPoints)+1;
                            azi_block_end   = ida*this.nPoints;
                            %M_azi(:,((ida-1)*this.nPoints)+1:ida*this.nPoints) = D_mat(:,:,unique_map_azi(ida)) * M_init;
                            M_ele(:,ele_block_begin+azi_block_begin-1:ele_block_begin+azi_block_end-1) = D_mat(:,:,unique_map_azi(ida)) * M_init;
                        end
                        % Save rotation of current elevation
                        %M_ele(:,((ide-1)*this.nPoints*size(this.aziVec,2))+1:ide*this.nPoints*size(this.aziVec,2)) = M_azi;
                    end
                    % M_ele contains all orientations at the center position.
                    % Based on that, shift the virtual center array to the
                    % translated positions and the rotate it around the old
                    % center according to rotVec.
                    for idt = 1:size(this.transVec,2)
                        % M_trans_init is the virtual center array M_ele,
                        % translated to the new position. Just compute matrices
                        % if translation other than 0.
                        trans_block_begin = (idt-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))+1;
                        %trans_block_end   = idt*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2));
                        if~(this.transVec(idt)==0)
                            M_trans_init = D_beta_pos * ita_sph_ztransT(this.transVec(idt),this.nmax,this.k(idk)) * D_beta_neg * M_ele;
                        else
                            M_trans_init = M_ele;
                        end
                        for idr = 1:size(this.rotVec,2)
                            rot_block_begin = (idr-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))+1;
                            rot_block_end   = idr*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2));
                            %M_trans_rot(:,(idr-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))+1:idr*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2))) = D_mat(:,:,unique_map_rot(idr)) * M_trans_init;
                            M_freq(:,trans_block_begin+rot_block_begin-1:trans_block_begin+rot_block_end-1,idk)= D_mat(:,:,unique_map_rot(idr)) * M_trans_init;
                        end
                        %M_trans(:,(idt-1)*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))+1:idt*(this.nPoints*size(this.aziVec,2)*size(this.eleVec,2)*size(this.rotVec,2))) = M_trans_rot;
                    end
                    %M_freq(:,:,idk) = M_trans;
                end
                value = M_freq;
            end
            this.Mall = value;
        end
        
        % Matrix generators
        
        function value = generate_S(this)
            % To reduce the computational effort, get a list of unique
            % r_mem / r combinations, together with a mapping vector, which
            % maps every element of the redundant vectors to their
            % representative in the new reduced vector.
            r_combinations = asin(this.r_mem./this.r');
            unique_r = unique(r_combinations);
            
            % Worst case allocation for S. 0-colums will be removed later.
            S = zeros(this.nCoeff,this.nPoints,size(unique_r,2));
            
            % Generate sampling matrix for every unique
            % r_mem/r_combination
            for idr = 1:size(unique_r,2)
                r_indices = r_combinations==unique_r(idr);
                s = itaCoordinates(this.sph(r_indices,:),'sph');
                S(:,1:s.nPoints,idr) = ita_sph_base(s,this.nmax)';
            end
            value = S;
        end
        
        function value = generate_capsSH(this)
            % To reduce the computational effort, get a list of unique
            % r_mem / r combinations, together with a mapping vector, which
            % maps every element of the redundant vectors to their
            % representative in the new reduced vector.
            r_combinations = asin(this.r_mem./this.r');
            unique_r = unique(r_combinations);
            
            % Generate set of unique northpole cap matrices.
            value = zeros(this.nCoeff, this.nCoeff, size(unique_r,2));
            spread_matrix = ita_sph_eye(this.nmax,'nm-nm');
            spread_factor = sqrt(4*pi./(2*this.degreeIndex.'+1));
            
            for idr = 1:size(unique_r,2)
                value(:,:,idr) = diag(spread_factor .* (spread_matrix * ita_sph_northpolecapSH(this.nmax, unique_r(idr))));
            end
        end
        
        function value = generate_MP(this)
            % Generate Multipole conversion factor
            % Based on Williams , 'Fourier Acoustics', eq. 6.103
            % Z = P(r_0) / V(r_0) = 1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)')
            % Modified to save computation time, (P(r_0) / hankel(k*r_0)) is considered to be the multipole representation:
            % MP = (P(r_0) / hankel(k*r_0)) / V(r_0) = 1i * rho_0 * c / (hankel(k*r_0)')
            % Written as transformation matrix diag(1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)'))
            
            % Begin - Use for distorted sphere support %
            
            % In this case, Z not a transformation matrix, to maintain the
            % possibilty to use different array radii for every driver.
            % den = zeros(this.nCoeff,this.nPoints,this.nFrequencies);
            % pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            % for idx = 1:this.nFrequencies
            %     den(:,:,idx) = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r');
            % end
            % value = pre / den;
            
            % End - Use for distorted sphere support %
            
            % Begin - Remove for distorted sphere support %
            
            pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            value = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            for idx=1:this.nFrequencies
                den = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r(1));
                value(:,:,idx) = diag(pre./den);
            end
            
            % End - Remove for distorted sphere support %
            
        end
        
        function value = generate_Z0(this)
            % Get the real, physically correct radiation impedance,
            % contrary to the similar multipole factor.
            % Based on Williams , 'Fourier Acoustics', eq. 6.103
            % Z = P(r_0) / V(r_0) = 1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)')
            % Written as transformation matrix diag(1i * rho_0 * c * hankel(k*r_0)/(hankel(k*r_0)'))
            
            % Begin - Use for distorted sphere support %
            
            % num = zeros(this.nCoeff,size(this.r,1),this.nFrequencies);
            % den = zeros(this.nCoeff,size(this.r,1),this.nFrequencies);
            % pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            % for idx = 1:this.nFrequencies
            %     num(:,:,idx) = ita_sph_besselh(this.degreeIndex',2,this.k(idx)*this.r');
            %     den(:,:,idx) = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r');
            % end
            % value = pre * bsxfun(@rdivide,num,den);
            
            % End - Use for distorted sphere support %
            
            % Begin - Remove for distorted sphere support %
            
            pre = (-1i) * double(ita_constants('rho_0')) * double(ita_constants('c'));
            value = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            for idx=1:this.nFrequencies
                num = ita_sph_besselh(this.degreeIndex',2,this.k(idx)*this.r(1));
                den = ita_sph_besseldiff(@ita_sph_besselh,this.degreeIndex',2,this.k(idx)*this.r(1));
                value(:,:,idx) = diag(pre*num./den);
            end
            
            % End - Remove for distorted sphere support %
            
        end
        
        function value = generate_H(this,r)
            % Generate hankel term for the radiation of the multipole
            % source.
            % Based on Williams , 'Fourier Acoustics', eq. 6.97
            % P(r) / P(r_0) = hankel(k*r) / hankel(k*r_0)
            % Modified to match the chosen Multipole representation:
            % H = P(r) / (P(r_0) / hankel(k_r_0)) = hankel(k*r)
            % Written as transformation matrix diag(hankel_n(k*r))
            
            value = zeros(this.nCoeff,this.nCoeff,this.nFrequencies);
            %             for idx=1:this.nFrequencies
            %                 value(:,:,idx) = diag(ita_sph_besselh(this.degreeIndex',2, this.k(idx)*r));
            %             end
            
            %pdi speed up
            if isinf(r)
                % NOT VERYFIED!
                aux = bsxfun(@times, 1i ./ this.k, (1i.^this.degreeIndex).');
            else
                aux = ita_sph_besselh(this.degreeIndex',2, this.k*r);
            end
            
            for idx=1:this.nCoeff
                value(idx,idx,:) = aux(idx,:);
            end
        end
        
        function value = generate_orderSumMat(this)
            % Assemble diagonal block matrix for summation in orders
            row = ita_sph_linear2degreeorder(1:this.nCoeff)+1;
            col = 1:this.nCoeff;
            value = accumarray([row(:) col(:)],ones(this.nCoeff,1));
        end
        
        % Radiation
        function value = radiate(this,r)
            % Multiply Hankel matrix and Mutipole matrix.
            % This is done for every regarded frequency.
            % There is an alternative method, sorting the
            % matrices into cells for every frequency with num2cell() and
            % then multiplying the corrspoing cell contents with cellfun().
            % cat() then sorts the contents back into one 3D matrix:
            % value = cellfun(@mtimes,num2cell(this.generate_H(r),[1 2]),num2cell(M,[1 2]),'UniformOutput',false);
            % value = cat(3,value{:});
            % However, this method makes extensive use of the computers
            % memory and is slower, especially if paging is needed to cope
            % with the demands.
            
            M = this.Mall;
            value = zeros(this.nCoeff,size(M,2),this.nFrequencies);
            H = this.generate_H(r);
            for idf = 1:this.nFrequencies
                value(:,:,idf) = H(:,:,idf)*M(:,:,idf);
            end
        end
        
        % Reset
        function reset_aperturesSH(this)
            this.aperturesSH = [];
            this.reset_Mphys;
        end
        
        function reset_Mphys(this)
            this.Mphys = [];
        end
        
        function reset_Mall(this)
            this.Mall = [];
        end
        
        % Saving
        function sObj = saveobj(this)
            propertylist = {'nmax','sph','r_mem','aperturesSH','displacement','k','aziVec','eleVec','transVec','rotVec','Mphys','Mall'};
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        %Loading
        function this = loadobj(sObj)
            if isfield(sObj,'classrevision'), sObj = rmfield(sObj,{'classrevision'}); end;
            if isfield(sObj,'classname'), sObj = rmfield(sObj,{'classname'}); end;
            try
                this = itaSLAYER(sObj);
            catch errmsg
                disp(errmsg);
            end
        end
        
    end
end>>>>>>> .r11541
