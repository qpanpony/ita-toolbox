function varargout = ita_groupdelay(varargin)
%ITA_GROUPDELAY - Calculate Group Delay
%  This function calculates the group delay of a spectrum
%
%  Syntax: phase_vec = ita_groupdelay(audioObj)
%  Syntax: phase_vec = ita_groupdelay(spk_vec)
%
%   See also ita_plot_spkgdelay.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_groupdelay">doc ita_groupdelay</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  30-Sep-2008 


% TODO % get rid off the jump in group delay!!!

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
        error('ita_groupdelay:Oh Lord. I cannot find the data in the struct.')
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

%BMA: Bugfix => unwrap did not work wenn first number was a NaN.
if any( isnan(phase) | isinf(phase))
    error('ita_groupdelay:undefined_point','Your signal has a point with NaN or Inf phase. How could this be?')
end

phase_vec = unwrap(phase,[],1);

if isa(asData,'itaAudio')
    bin_dist = asData.samplingRate/asData.nSamples;
    phase_vec = -[phase_vec(1,:); diff(phase_vec,1,1)]/(bin_dist * 2*pi);
else
    bin_dist = gradient(asData.freqVector(:));
    phase_vec = -bsxfun(@rdivide,gradient(phase_vec.').',(bin_dist * 2*pi));
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