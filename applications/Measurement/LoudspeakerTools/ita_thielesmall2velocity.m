function varargout = ita_thielesmall2velocity(varargin)
%ITA_THIELESMALL2VELOCITY - calculates velocity out of Thiele Small
%Parameters (gui)
%  This function calculates the velocity out of the Thiele Small Parameters
%  by assuming normalized input voltage
%
%  Syntax:
%   audioObjOut = ita_thielesmall2velocity('pos1_input','struct','freq',itaValue(1000,'Hz'),'V_0',[],'Zs',[])
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_thielesmall2velocity">doc ita_thielesmall2velocity</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  01-Mar-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing

if nargin == 0
    % the GUI
    pList = [];
    
    ele = numel(pList)+1;
    pList{ele}.description = 'DC Resistance Re [Ohm]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Voice Coil Inductivity Le [mH]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Mechanical Resistance Rms (w) [kg/s]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Moving Mass Mms (m) [g]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Suspension Compliance Cms (n) [mm/N]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Force Factor M [T m]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Effective Piston Area Sd [cm^2]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Equivalent Volume Vas [l]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 0;
    
    if nargout == 0
        ele = numel(pList)+1;
        pList{ele}.datatype    = 'line';
        
        ele = numel(pList)+1;
        pList{ele}.description = 'Name of Output Object';
        pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
        pList{ele}.datatype    = 'itaAudioResult';
        pList{ele}.default     = ['result_' mfilename];
    end
    
    pList = ita_parametric_GUI(pList,[mfilename ' - Calculate membrane velocity from T-S parameters']);
    
    if ~isempty(pList)
        parameters = {'R_e','L_e','w','m','n','M','S_d','Vas'};
        units = {'Ohm','H','kg/s','kg','m/N','T m','m^2','m^3'};
        factors = {1,0.001,1,0.001,0.001,1,1e-4,0.001};
        for i = 1:numel(parameters)
            varargin{1}.(parameters{i}) = itaValue(pList{i}*factors{i},units{i});
        end
    else
        disp([thisFuncStr 'operation cancelled by user']);
        return;
    end
end

sArgs         = struct('pos1_input','struct','freq',itaValue(1000,'Hz'),'V_0',[],'Zs',[]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% some preprocessing
if ~isa(sArgs.freq,'itaValue')
    sArgs.freq = itaValue(sArgs.freq,'Hz');
end

omega = 2*pi.*sArgs.freq;
[c,Z_0] = ita_constants({'c','z_0'});
a = double(sqrt(input.S_d/pi));
k = double(omega./c);

if ~isempty(sArgs.V_0)
    if ~isa(sArgs.V_0,'itaValue')
        sArgs.V_0 = itaValue(sArgs.V_0,'m^3');
    end
    n_v  = sArgs.V_0/(Z_0*c*input.S_d^2); % spring due to enclosure
    input.n = (input.n * n_v)/(input.n + n_v);
end

%% Radiation impedance - if none is given, use piston radiation impedance
if isempty(sArgs.Zs)
    sArgs.Zs = Z_0*(1-(2.*besselj(1,2.*k.*a)./(2.*k.*a))+2.*1i.*ita_struve1(2.*k.*a)./(2.*k.*a));
elseif ~isa(sArgs.Zs,'itaValue')
    sArgs.Zs = itaValue(sArgs.Zs,'kg/m^2 s');
end

%% electrical network components
U = itaValue(1,'V');
if ~isfield(input,'L_e')
    ita_disp('no L_e given!')
    Ze = input.R_e;
else
    Ze = input.R_e + 1i.*omega.*input.L_e;
end

%% mechanical impedance
Zm = input.w + 1i.*omega.*input.m + 1./(1i.*omega.*input.n);

%% simple calculation
v = U/(input.M + (sArgs.Zs*input.S_d + Zm)*Ze/input.M);
f = double(sArgs.freq);
result = itaResult(v.value(:),f(:),'freq');
result.channelUnits = {v.unit};
% also store the thiele small parameters
result.userData = input;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Set Output
varargout(1) = {result};

%end function
end