function varargout = ita_pitchshift_reconstruction( varargin )
% ITA_PITCHSHIFT_RECONSTRUCTION - creates a distorted signal using a sum of 
% harmonic created by pitch shifting:x_out=a*fundamental+b*2ndharm+c*3rdharm+...
%
% WARNING: The phase smearing produced by the pitch shift may be too high
%
% Syntax: audioObject = ita_pitchshift_reconstruction(audioObject, coeff_vector)
%
%  See also:
%   ita_pitchshift, ita_nonlinear_harmonic_series   

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- Email: alexandre.bleus@akustik.rwth-aachen.de
% Created:  10-June-2010


%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];

%% Initialisation
%   Number of input arguments
narginchk(2,2);

% Initialise the signal
if isa(varargin{1},'itaAudio')
    inSignal = varargin{1};
else
    error([thisFuncStr 'Oh Lord. I need an audioObject to work.'])
end

% Initialise the coefficients
if isvector(varargin{2})
    coeff = varargin{2};
else
    error([thisFuncStr 'Input vector is missing or erroneous.'])
end
%% Polynome calculation
outSignal=coeff(1).*inSignal;
if length(coeff)>=2
    for idx= 2:length(coeff)
        outSignal = outSignal + coeff(idx).*ita_pitchshift(inSignal,idx);
    end
end

varargout{1} = outSignal;
end