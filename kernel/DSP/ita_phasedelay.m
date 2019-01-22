function varargout = ita_phasedelay(varargin)
%ITA_PHASEDELAY - Calculate Phase Delay
%  This function calculates the phase delay of a spectrum
%
%  Syntax: phase_vec = ita_phasedelay(audioObj)
%  Syntax: phase_vec = ita_phasedelay(spk_vec)
%
%%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_phasedelay">doc ita_phasedelay</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Stefan Liebich -- Email: liebich@iks.rwth-aachen.de
% Created:  19-Jun-2018 



%% Verbose Mode
verboseMode  = ita_preferences('verboseMode');  

%% Initialization
% Number of Input Arguments
narginchk(1,1);
% Find Audio Data
if isa(varargin{1},'itaSuper')
    if isTime(varargin{1})
        asData = fft(varargin{1});
    elseif isFreq(varargin{1})
        asData = varargin{1};
    else
        error('ita_phasedelay:Oh Lord. I cannot find the data in the struct.')
    end
elseif isnumeric(varargin{1})
    if verboseMode, disp('ITA_GROUPDELAY:Oh Lord. Please use audioObjs !!!'); end;
    asData = itaAudio();
    asData.samplingRate = 44100; % standard samplingrate
    asData.domain = 'freq';
    asData.freq = varargin{1};
end


%% 'result' is an audioObj and is given back 
phase = angle(asData.freqData);
freq_vec = asData.freqVector;

%BMA: Bugfix => unwrap did not work wenn first number was a NaN.
if any( isnan(phase) | isinf(phase))
    error('ita_phasedelay:undefined_point','Your signal has a point with NaN or Inf phase. How could this be?')
end

phase_vec = unwrap(phase,[],1);

if isa(asData,'itaAudio')
    phase_vec = - phase_vec ./ ((freq_vec * 2*pi) * ones(1,size(phase_vec,2)));
else
    phase_vec = - bsxfun(@rdivide,phase_vec,(freq_vec * 2*pi) * ones(1,size(phase_vec,2)));
end


%% Find output parameters
if nargout == 1 %User has not specified a variable
    varargout{1} = phase_vec;
elseif nargout == 2
    % Write Data
    varargout{1} = phase_vec; 
    varargout{2} = asData;
end

%end function
end