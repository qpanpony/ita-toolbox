function value = getValueAtFrequency(varargin)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if nargin < 4
    if isa(varargin{1},'itaMeshBoundaryC')
        this = varargin{1};
    else
        error('getValueAtFrequency:: Wrong input argument');
    end
    if isnumeric(varargin{2})
        freq = varargin{2};
    else
        error('getValueAtFrequency:: Wrong input argument');
    end
    if nargin == 2
        %disp('getValueAtFrequency:: When I have no fluid informations, I choose c=343.7 m/s and rho = 1.2 kg/m³!');
        Z0 = 343.7*1.2;
    elseif nargin==3
        if isa(varargin{3},'itaMeshFluid')
            fluid = varargin{3};
            Z0 = fluid.c*fluid.rho;
        elseif isnumeric(varargin{3})
            Z0 = varargin{3};
        end
    end
else
    error('getValueAtFrequency:: Wrong number of input parameter');
end

omega = 2*pi*freq;
if ~strcmp(this.FreqInputFilename,'none') && length(this.Value)>1
    valueTemp = interp1(this.Freq,this.Value,freq);
else
    valueTemp = this.Value;
end

switch this.Type
    case 'Admittance',value = valueTemp;
    case 'Impedance', value = 1./valueTemp;
    case 'Reflection', value = (1-valueTemp)./(Z0*(1+valueTemp));
    case 'Absorption', value = (1-sqrt(1-valueTemp))./(Z0*(1+sqrt(1+valueTemp)));
    case 'Displacement', value = valueTemp;
    case 'Velocity', value = valueTemp./(1j*omega);
    case 'Acceleration', value = -valueTemp./(1j*omega)^2;
    case 'Point Source', value = valueTemp./(1j*omega);    
    case 'Pressure', value = valueTemp; 
end

