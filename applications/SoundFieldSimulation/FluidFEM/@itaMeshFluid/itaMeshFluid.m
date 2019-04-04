classdef  itaMeshFluid < itaMeshProperties

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Access = private)
        mC=343.7;
        mRho=1.2;
    end
    
    properties(Dependent)     
        c
        rho 
    end
    
    methods 
        function this = itaMeshFluid(varargin)
             if nargin == 1
                if isa(varargin{1},'itaMeshFluid')
                    this = varargin{1};  
                end
             elseif nargin < 5
                if nargin ==2
                    if isnumeric(varargin{1}) &&isnumeric(varargin{2})
                        this.mRho = varargin{2}; this.mC = varargin{1};
                    end
                elseif nargin == 4
                    if isnumeric(varargin{1})&& ischar(varargin{2})&&(varargin{3}) &&isnumeric(varargin{4})
                        this.ID = varargin{1}; this.Name = varargin{2};
                        this.mRho = varargin{4}; this.mC = varargin{3};
                    end
                end
             else
                 error('itaMeshFluid:: Wrong number of input parameter');
             end
        end
        
        function display(this)
            disp([this.Name '  (ID: ' num2str(this.ID) ')']);
            disp( '==================================================')
            disp(['c           : ' num2str(this.mC)]);
            disp(['rho         : ' num2str(this.mRho)]);
        end
        
        function this = set.c(this, value), this.mC = value; end      
        function this = set.rho(this, value), this.mRho = value; end
        function value = get.c(this), value = this.mC; end
        function value = get.rho(this), value = this.mRho; end
    end
end
