classdef itaThieleSmall < itaHandle
    % Thiele-Small Parameter class to store and calculate the full set of
    % TS Parameters.
    
    
    % <ITA-Toolbox>
    % This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    
    % Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
    % Created:  31-May-2014
    
    properties(Access = public, Hidden = false)
        c       = ita_constants('c');
        rho0    = ita_constants('rho_0');
        S_d     = itaValue([],'m^2');
        m       = itaValue([],'kg');
        n       = itaValue([],'s^2/kg');
        w       = itaValue([],'kg/s');
        M       = itaValue([],'T m');
        R_e     = itaValue([],'Ohm');
        L_e     = itaValue([],'H');
        R_2     = itaValue([],'Ohm');
        L_2     = itaValue([],'H');
        lambda  = itaValue([],'');
        k       = itaValue([],'');
        f_min   = itaValue([],'Hz');
        V_0     = itaValue([],'m^3');
        Q_g     = itaValue([],'');
        n_g     = itaValue([],'s^2/kg');
        alpha   = itaValue(3.93e-3,'1/K'); % thermal model, linear
        beta    = itaValue(0.6e-6,'1/K'); % thermal model, quadratic
        temperature = itaValue([],'K'); % temperature difference to ambient
        compliance_factor = itaValue(0.018,'1/K'); % temperature dependency of compliance
    end
    
    properties(Hidden = false, Dependent = true)
        w_g
        f_s
        C_mes
        L_ces
        L_ces_encl
        R_es
        R_es_encl
        V_equi
        Q_m
        Q_e
        Q_tot
    end
    
    properties(Hidden = true, Dependent = true)
        % Hidden properties used only for plotting purposes
        audioObjImp
        audioObjHx
    end
    
    methods
        
        function this = itaThieleSmall(varargin)
            if nargin == 0
                % do nothing
            elseif isstruct(varargin{1}) % if TS Parameters are handled as a struct
                % remove dependent fields
                removeFields = {'w_g','f_s','C_mes','L_ces','L_ces_encl','R_es','R_es_encl','V_equi','Q_m','Q_e','Q_tot'};
                TSnames = fieldnames(varargin{1});
                varargin{1} = rmfield(varargin{1},intersect(TSnames,removeFields));
                TSvalues = num2cell(structfun(@double, varargin{1}, 'UniformOutput', 1));
                TSnames = fieldnames(varargin{1});
                for idx = 1:numel(TSvalues)
                    try
                        this.(TSnames{idx}).value = TSvalues{idx};
                    catch
                        ita_verbose_info(['Field "' TSnames{idx} '" has been skipped'],0);
                    end
                end
                
            elseif isa(varargin{1}, 'itaThieleSmall')
                % copy constructor
                TS = convert2struct(varargin{1});
                this = itaThieleSmall(TS);
                
            elseif nargin >= 2 && isnatural(nargin/2)
                % constructor using field names as string and corresponding
                % vaules
                for idx = 1:2:nargin
                    try
                        this.(varargin{idx}).value = varargin{idx+1};
                    catch
                        ita_verbose_info(['Field "', varargin{idx}, '" has been skipped.'],0);
                    end
                end
                
            else
                ita_verbose_info('Wrong input parameters given.',0)
                
            end
        end
        
        function TSstruct = convert2struct(this, varargin)
            % save all TS parameters that are not empty into a struct
            TSnames = fieldnames(this);
            for idx = 1:numel(TSnames)
                if ~isempty(double(this.(TSnames{idx})))
                    TSstruct.(TSnames{idx}) = this.(TSnames{idx});
                end
            end
            
            if nargin > 1
                if strcmp(varargin{1},'double') || strcmp(varargin{1},'d')
                    TSstruct = structfun(@double, TSstruct, 'UniformOutput', 0);
                else
                    ita_verbose_info('Not a valid option.')
                end
            end
            
            
        end
        
        
        function init_creep_models(this, model, initialized)
            %  clear other creep models in case multiple values are set
            if ~initialized
                switch model
                    case 'tpc'
                        this.lambda.value = [];
                    case 'nc'
                        this.lambda.value = [];
                        this.k.value = [];
                        this.f_min.value = [];
                    case 'log'
                        this.k.value = [];
                        this.f_min.value = [];
                end
            else
                return
            end
        end
        
        
        %% get/set functions
        function set.m(this,valIn)
            this.m.value = double(valIn);
        end
        
        function res = get.m(this)
            res = this.m;
        end
        
        function set.n(this,valIn)
            this.n.value = double(valIn);
        end
        
        function res = get.n(this)
            if isempty(this.temperature.value) || isempty(this.compliance_factor.value)
                res = this.n;
            else
                res = this.n*(1+this.compliance_factor.value*this.temperature.value);
            end
        end
        
        function set.w(this,valIn)
            this.w.value = double(valIn);
        end
        
        function res = get.w(this)
            res = this.w;
        end
        
        function set.M(this,valIn)
            this.M.value = double(valIn);
        end
        
        function res = get.M(this)
            res = this.M;
        end
        
        function set.R_e(this,valIn)
            this.R_e.value = double(valIn);
        end
        
        function res = get.R_e(this)
            if isempty(this.temperature.value) || isempty(this.alpha.value)
                res = this.R_e;
            else
                res = this.R_e*(1+this.alpha.value*this.temperature.value);
                if ~isempty(this.beta.value)
                    res = res + this.R_e*this.beta.value*this.temperature.value.^2;
                end
            end
        end
        
        function set.L_e(this,valIn)
            this.L_e.value = double(valIn);
        end
        
        function res = get.L_e(this)
            res = this.L_e;
        end
        
        function set.R_2(this,valIn)
            this.R_2.value = double(valIn);
        end
        
        function res = get.R_2(this)
            res = this.R_2;
        end
        
        function set.L_2(this,valIn)
            this.L_2.value = double(valIn);
        end
        
        function res = get.L_2(this)
            res = this.L_2;
        end
        
        function set.Q_g(this,valIn)
            this.Q_g.value = double(valIn);
        end
        
        function res = get.Q_g(this)
            res = this.Q_g;
        end
        
        function set.S_d(this,valIn)
            this.S_d.value = double(valIn);
        end
        
        function res = get.S_d(this)
            res = this.S_d;
        end
        
        function set.V_0(this,valIn)
            this.V_0.value = double(valIn);
        end
        
        function res = get.V_0(this)
            res = this.V_0;
        end
        
        function set.c(this,valIn)
            this.c.value = double(valIn);
        end
        
        function res = get.c(this)
            res = this.c;
        end
        
        function set.rho0(this,valIn)
            this.rho0.value = double(valIn);
        end
        
        function res = get.rho0(this)
            res = this.rho0;
        end
        
        function res = get.n_g(this)
            if ~isempty(this.n_g.value)
                res = this.n_g;
            elseif ~(isempty(this.Q_g) || isempty(this.V_0) || isempty(this.S_d))
                res = itaValue(this.V_0.value/(this.rho0.value*this.c.value^2*this.S_d.value^2),'s^2/kg');
            else
                res = itaValue([],'s^2/kg');
            end
        end
        
        function set.n_g(this,valIn)
            this.n_g.value = double(valIn);
        end
        
        function res = get.alpha(this)
            res = this.alpha;
        end
        
        function set.alpha(this,valIn)
            this.alpha.value = double(valIn);
        end
        
        function res = get.beta(this)
            res = this.beta;
        end
        
        function set.beta(this,valIn)
            this.beta.value = double(valIn);
        end
        
        function res = get.compliance_factor(this)
            res = this.compliance_factor;
        end
        
        function set.compliance_factor(this,valIn)
            this.compliance_factor.value = double(valIn);
        end
        
        function res = get.temperature(this)
            res = this.temperature;
        end
        
        function set.temperature(this,valIn)
            this.temperature.value = double(valIn);
        end
        
        %%  Creep Models
        %   when a parameter corresponding to a new or different creep
        %   model is set older creep parameters will be erased
        function set.lambda(this,valIn)
            if isempty(this.k.value) && isempty(this.f_min.value)
                initialized = true;
            else
                initialized = false;
            end
            this.init_creep_models('log', initialized);
            this.lambda.value = double(valIn);
        end
        
        function res = get.lambda(this)
            res = this.lambda;
        end
        
        function set.k(this,valIn)
            if isempty(this.lambda.value)
                initialized = true;
            else
                initialized = false;
            end
            this.init_creep_models('tpc', initialized);
            this.k.value = double(valIn);
        end
        
        function res = get.k(this)
            res = this.k;
        end
        
        
        function set.f_min(this,valIn)
            if isempty(this.lambda.value)
                initialized = true;
            else
                initialized = false;
            end
            this.init_creep_models('tpc', initialized);
            this.f_min.value = double(valIn);
        end
        
        function res = get.f_min(this)
            res = this.f_min;
        end
        
        %% dependent properties
        function res = get.w_g(this)
            if isempty(this.Q_g) || isempty(this.n_g)
                res = itaValue([],'kg/s');
            else
                res = itaValue(1/(2*pi*this.f_s.value*this.n_g.value*this.Q_g.value),'kg/s');
            end
        end
        
        function res = get.f_s(this)
            if isempty(this.n_g)
                res = itaValue(1/2/pi/sqrt(this.m.value*this.n.value), 'Hz');
            else
                res = itaValue(1/2/pi/sqrt(this.m.value*(1/(1/this.n.value + 1/this.n_g.value))), 'Hz');
            end
        end
        
        function res = get.L_ces(this)
            if isempty(this.n)
                res = itaValue([],'H');
            else
                res = itaValue(this.n.value*this.M.value^2,'H');
            end
        end
        
        function res = get.L_ces_encl(this)
            if isempty(this.n_g)
                res = itaValue([], 'H');
            else
                res = itaValue(this.n_g.value*this.M.value^2,'H');
            end
        end
        
        function res = get.C_mes(this)
            res = itaValue(this.m.value/this.M.value^2,'F');
        end
        
        function res = get.R_es(this)
            if ~isempty(this.w)
                res = itaValue(this.M.value^2/this.w.value,'Ohm');
            else
                res = itaValue([], 'Ohm');
            end
        end
        
        function res = get.R_es_encl(this)
            if ~isempty(this.w_g)
                res = itaValue(this.M.value^2/this.w_g.value,'Ohm');
            else
                res = itaValue([], 'Ohm');
            end
        end
        
        function res = get.V_equi(this)
            if ~isempty(this.S_d)
                res = itaValue(this.n.value*this.rho0.value*this.c.value^2*this.S_d.value^2,'m^3');
            else
                res = itaValue([],'m^3');
            end
        end
        
        function res = get.Q_m(this)
            if isempty(this.n_g)
                res = itaValue(this.f_s.value*2*pi*this.m.value/this.w.value,'');
            else
                res = itaValue(this.f_s.value*2*pi*this.m.value/(this.w.value + this.w_g.value),'');
            end
        end
        
        function res = get.Q_e(this)
            if isempty(this.n_g)
                res = itaValue(this.Q_m.value*this.R_e.value*this.w.value/this.M.value.^2,'');
            else
                res = itaValue(this.Q_m.value*this.R_e.value*(this.w.value + this.w_g.value)/this.M.value.^2,'');
            end
        end
        
        function res = get.Q_tot(this)
            res = itaValue(1/(1/this.Q_m.value + 1/this.Q_e.value),'');
        end
        
        function res = get.audioObjImp(this)
            res = ita_linear_loudspeaker(convert2struct(this));
        end
        
        function res = get.audioObjHx(this)
            [~,res] = ita_linear_loudspeaker(convert2struct(this));
        end
        
        %% plot functions
        function audioObj = plot_impedance(this, varargin)
            %   returns the calculated impedance as an itaAudio Object
            %   see ita_linear_loudspeaker
            [audioObj,~] = ita_linear_loudspeaker(convert2struct(this), varargin{1:end});
            audioObj.plot_freq;
        end
        
        function audioObj = plot_displacement(this,varargin)
            %   returns the calculated membrane displacement as an itaAudio Object
            %   see ita_linear_loudspeaker
            [~,audioObj] = ita_linear_loudspeaker(convert2struct(this), varargin{1:end});
            audioObj.plot_freq;
        end
        
        
        function audioObj = plot_spl(this,varargin)
            %   returns the calculated sound pressure level as an itaAudio Object
            %   see ita_linear_loudspeaker
            [~,~,audioObj] = ita_linear_loudspeaker(convert2struct(this), varargin{1:end});
            audioObj.plot_freq;
        end
        
        function audioObj = plot_pac(this,varargin)
            %   returns the calculated sound pressure level as an itaAudio Object
            %   see ita_linear_loudspeaker
            [~,~,~,audioObj] = ita_linear_loudspeaker(convert2struct(this), varargin{1:end});
            audioObj.plot_freq;
        end
        
        function show(this)
            % plots TS parameters
            ita_show_struct(this.convert2struct)
        end
        
        
    end
    
    methods(Hidden = true)
        % creates console plot with links, etc
        function display(this)
            
            fprintf('==|itaThieleSmall|======================================================================== \n')
            if ~isempty(this.lambda.value)
                dispArray = ['      creep model: ....... LOG'];
            elseif ~isempty(this.k.value) && ~isempty(this.f_min.value)
                dispArray = ['      creep model: ....... TPC'];
            else
                dispArray = ['      creep model: ....... no creep model applied'];
            end
            disp(dispArray)
            
            command = {[inputname(1), '.audioObjImp.pf'], [inputname(1), '.audioObjImp.pfp']};
            commandText = {'plot_freq', 'plot_freq_phase'};
            fprintf(['      impedance: ......... ' '<a href = "matlab: ' command{1} '">' commandText{1} '</a>' '  ' '<a href = "matlab: ' command{2} '">' commandText{2} '</a>'])
            fprintf('\n')
            command = {[inputname(1), '.audioObjHx.pf'], [inputname(1), '.audioObjHx.pfp']};
            fprintf(['      displacement: ...... ' '<a href = "matlab: ' command{1} '">' commandText{1} '</a>' '  ' '<a href = "matlab: ' command{2} '">' commandText{2} '</a>'])
            fprintf('\n')
            command = {[inputname(1), '.show']};
            commandText = {'show TS parameters'};
            fprintf(['      parameter table: ... ' '<a href = "matlab: ' command{1} '">' commandText{1} '</a>'])
            fprintf('\n------------------------------------------------------------------------------------------ \n')
            %             fprintf('\n')
        end
        
    end
    
end