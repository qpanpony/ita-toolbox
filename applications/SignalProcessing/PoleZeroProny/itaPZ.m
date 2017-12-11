classdef itaPZ
    %ITAAUDIOAnalytic - super class for analytic audio data files
    %
    %
    % These objects can be used for all data with is directly convertable
    % between frequency domain and time domain. Equally spaced samples or
    % bins.
    %
    % itaAudio Properties:
    %   samplingRate
    %
    %   Reference page in Help browser
    %        <a href="matlab:doc itaAudio">doc itaAudio</a>
    
    % <ITA-Toolbox>
    % This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de - 2011
    
    properties
        f       = []; %frequencies of poles
        sigma   = []; %damping of poles
        C       = []; %coefficient of poles
        comment = ''; %comment on the content of the object
        D       = 0 ; % constant term
        E       = 0 ; % extra + s * E term
        exp_s   = 0 ; % multiply result by s^(exp_s)
        delay   = 0 ; %delay of the entire object
        unit    = itaValue; % unit of the coefficients as itaValue
    end
    
    properties (Hidden = true)
        clustersize = 1; % used to calculate frequency response, increasing this value requires more memory but is faster
    end
    
    properties(Dependent = true, Hidden = true)
        rfmodel; %get/set radio frequency toolbox object on the fly
        A;       %combination of frequency*2pi and delta
    end
    
    properties(Dependent = true, Hidden = false)
        p;       %poles: combination of frequency*2pi and sigma
        T;       %reveration time of the modes
    end
    
    methods
        
        function this = itaPZ(varargin)
            % Constructor: input could be rfmodel.rational object
            if nargin == 1
                this.rfmodel = varargin{1};
            end
        end
        
        function res = get.rfmodel(this)
            res         = rfmodel.rational;
            res.C       = this.C;
            res.Delay   = this.delay;
            res.D       = this.D;
            res.A       = this.A;
        end
        
        function this = set.rfmodel(this,rfmodel)
            this.f      = imag(rfmodel.A)/(2*pi);
            this.sigma  = real(rfmodel.A);
            this.C      = rfmodel.C;
            this.D      = rfmodel.D;
            this.delay  = rfmodel.Delay;
        end
        
        function this = set.A(this,value)
            this.f      = imag(value)/(2*pi);
            this.sigma  = real(value);
        end
        
        function res = get.p(this)
            res = this.A;
        end
        function this = set.p(this,value)
            this.A = value;
        end
        
        function res = get.A(this)
            res = this.sigma + 1i*this.f * (2*pi);
        end
        
        function this = times(this,value)
            % multiplication with factor or unit
            this = mtimes(this,value);
        end
        function this = mtimes(this,value)
            % multiplication with factor or unit
            
            value = itaValue(value);
            
            if double(value) == 0
                this.C = [];
                this.sigma = [];
                this.D = 0;
                this.f = [];
            else
                this.unit = this.unit * itaValue(value)/double(value);
                this.C = this.C * double(value);
            end
        end
        
        function this = make_symmetric(this)
            % copy all poles at positive frequencies to complex conj. neg. poles
            
            % delete all neg. freq poles
            this = this.ch(find(this.f >= 0));
            
            % generate compl. conj. poles of pos. poles, do not copy zero freq poles
            this = merge(conj(this.ch(find(this.f >0))),this); %#ok<*FNDSB>
            
        end
        
        function this = make_positive(this)
            % neglect all negative poles
            
            % delete all neg. freq poles
            this = this.ch(find(this.f >= 0));
        end
        
        
        function this = conj(this)
            % compl. conj. of coefficients and inverse of frequency
            this.A = conj(this.A);
            this.C = conj(this.C);
        end
        function this = merge(this,new_this)
            % merge two sets together into one set of modal parameters
            this.A = [this.A(:); new_this.A(:)];
            this.C = [this.C(:); new_this.C(:)];
        end
        function res = freqresp(h,value)
            % get complex frequency response
            %     values: frequency vector with values in Hertz
            poles   = h.A;
            c       = h.C;
            d       = h.D;
            e       = h.E;
            ddelay  = h.delay;
            
            s       = 1i*2*pi*value;
            resp    = zeros(length(value),1);
            max_idx = numel(c);
            for idx = 1:h.clustersize:max_idx
                idxx = idx:min(idx+h.clustersize-1,max_idx);
                %                 token = sum(c(idxx)./(s-poles(idxx)));
                token = sum(bsxfun(@rdivide, c(idxx),(bsxfun(@minus,s,poles(idxx)))),2);
                resp = resp + token;
            end
            res = (resp+d+e*s) .* exp(1i*-2*pi*value*ddelay) .* s.^(h.exp_s);
        end
        
        % %         function resp = timeresp(h,t)
        % %             % get complex frequency response
        % %             %     t: time vector with values in seconds
        % %             h = h.ch(find(h.f >=0));
        % %
        % %             poles   = h.A;
        % %             c       = h.C;
        % %
        % %             c(find(h.f ==0)) = c(find(h.f ==0)) * 2;
        % %             %             d       = h.D;
        % %             %             e       = 0;
        % %             %             ddelay  = h.delay;
        % %
        % %             resp    = zeros(length(t),1);
        % %             for idx = 1:numel(c)
        % %                 token = real(exp(poles(idx).*t)*c(idx));
        % %                 resp  = resp + token;
        % %             end
        % %             %             res = (resp+d+e*s) .* exp(1i*-2*pi*value*ddelay);
        % %         end
        
        function resp = timeresp(h,t)
            % get complex frequency response
            %     t: time vector with values in seconds
            h = h.ch(find(h.f >=0));
            
            poles   = h.A;
            sigma0  = real(poles);
            omega0  = imag(poles);
            c       = h.C;
            
            % correct poles at frequency zero
            idxx = find(h.f == 0);
            c(idxx) = c(idxx) / 2;
            
            alpha   = real(c);
            beta    = imag(c);
            
            %             c(find(h.f ==0)) = c(find(h.f ==0)) * 2;
            %             d       = h.D;
            %             e       = 0;
            %             ddelay  = h.delay;
            
            resp    = zeros(length(t),1);
            for idx = 1:numel(c)
                
                
                token = exp(sigma0(idx)*t).*(2*alpha(idx)*cos(omega0(idx)*t) + (-2*beta(idx))*sin(omega0(idx)*t));
                resp  = resp + token;
            end
            %             res = (resp+d+e*s) .* exp(1i*-2*pi*value*ddelay);
        end
        
        
        function resp = freqresp2(h,freq)
            % get complex frequency response
            %     freq: freq vector with values in Hertz
            h = h.ch(find(h.f >=0));
            
            poles   = h.A;
            sigma0  = real(poles);
            omega0  = imag(poles);
            c       = h.C;
            alpha   = real(c);
            beta    = imag(c);
            
            s       = 1i*2*pi*freq;
            
            %             c(find(h.f ==0)) = c(find(h.f ==0)) * 2;
            %             d       = h.D;
            %             e       = 0;
            %             ddelay  = h.delay;
            
            resp    = zeros(length(freq),1);
            for idx = 1:numel(c)
                token = 2 * ((-beta(idx)*omega0(idx)- alpha(idx)*sigma0(idx)) + s*alpha(idx) )./ ( (s-sigma0(idx)).^2 + omega0(idx)^2 );
                resp  = resp + token;
            end
            %             res = (resp+d+e*s) .* exp(1i*-2*pi*value*ddelay);
        end
        
        function plot_spk(this,varargin)
            % plot spectrum (freq)
            res = itaAudioAnalyticRational(this);
            res.plot_spk(varargin{:});
        end
        function res = res_mixed_poles(this)
            %pdi implementation using conjugate complex pole pairs
            res = ita_rational2itaAudio(this.f, this.sigma, this.C);
        end
        function res = res_single_poles(this)
            %pdi implementation using single poles
            res = ita_rational2itaAudio_new(this.f, this.sigma, this.C);
        end
        
        function x = transpose(this)
            % transform to itaAudioAnalyticRational
            x = itaAudioAnalyticRational(this);
        end
        
        function T = get.T(this)
            %reverberation time from damping constants
            T  = -3.*log(10)./this.sigma;
        end
        function this = set.T(this,value)
            this.sigma = -3 .*log(10)/ value;
        end
        
        
        function this = sort(this,varargin)
            %sort the data according to ' 'f', 'sigma', 'C'
            sArgs        = struct('pos1_mode','string','crop',length(this.f));
            [sArgs] = ita_parse_arguments(sArgs,varargin);
            
            switch(lower(sArgs.mode))
                case {'f','freq'}
                    [x, idx] = sort(abs(this.f));
                case ('fpositive')
                    [x, idx] = sort(this.f);
                case {'sigma'}
                    [x, idx] = sort(abs(this.sigma));
                case {'c'}
                    [x, idx] = sort(abs(this.C));
                case {'ccx'} %find the correct sorting according to amplitude in freq domain
                    [x, idx] = sort(abs(this.C)./abs(this.sigma));
                otherwise
                    disp('no idea...')
            end
            %crop
            idx = idx(1:sArgs.crop);
            %sort
            this = this.ch(idx);
        end
        
        function this = ch(this,idx)
            % get specific modes only
            this.f       = this.f(idx);
            this.sigma   = this.sigma(idx);
            this.C       = this.C(idx);
        end
    end
end