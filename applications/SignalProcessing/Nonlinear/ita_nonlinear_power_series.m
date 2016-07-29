function varargout = ita_nonlinear_power_series( varargin )
% ITA_NONLINEAR_POWER_SERIES - create a distorted signal using a polynomial series
% decomposition: x_out=a*x_in+b*x_in.^2+c*x_in.^3+...
%
% NOTE: we use convolution in frequency domain in this function
%
%  Syntax: audioObject = ita_nonlinear_power_series(audioObject, coeff_vector)
%  
%  Example:
%   audioObjOut = ita_nonlinear_power_series(audioObjIn, [1 0.1 0 0.03])
%               = 1*audioObjIn+0.1*audioObjIn.^2+0.03*audioObjIn.^4
%
%  See also:
%   ita_fconv2, ita_nonlinear_harmonic_series, ita_nonlinear_h2p, ita_nonlinear_p2h

% This function was previously called ita_taylor_series

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];

%% Initialisation
if nargin == 0
    %% GUI
    ele = 1;
    pList{ele}.description = 'Input Data';
    pList{ele}.helptext    = 'This is the itaAudio as input data';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
      
    ele = ele + 1;
    pList{ele}.description = 'Polynomial Vector';
    pList{ele}.helptext    = 'This is the vector with the frequency independent coefficients for the power series.';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = [1 0.1 0.1 0.1];
    
    ele = ele + 1;
    pList{ele}.datatype    = 'line';
    
    ele = ele + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Polynomial Series']);
    if ~isempty(pList)
        result = ita_nonlinear_power_series(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;    
end

%% Initialize the signal
if isa(varargin{1},'itaAudio')
    inSignal = varargin{1};
else
    error([thisFuncStr 'Oh Lord. I need an audioObject to work.'])
end

% Initialise the coefficients
if isnumeric(varargin{2}) || isa(varargin{2},'itaAudio')
    coeff = varargin{2};
else
    error([thisFuncStr 'Input vector is missing or erroneous.'])
end

%% Polynom calculation
% pdi: dec 2012: handle units correctly
physicalUnit    = inSignal.channelUnits;
inSignal.channelUnits = '';
outSignal       = coeff(1) * inSignal;                  %anj: .* -> * for itaAudio
convprod        = inSignal;
power_sig       = convprod;

if length(coeff) >= 2
    for idx= 2:length(coeff)
        convprod        = ita_fconv(inSignal, idx);
        power_sig(idx)  = convprod;
        outSignal       = outSignal + coeff(idx)*convprod;
    end
end

% outSignal.channelNames{1} = ['Power Series Distortion'];  %anj: Taylor->Power
outSignal.channelUnits = physicalUnit;
varargout{1} = outSignal;

if nargout == 2
    varargout{2} = power_sig;
end

end