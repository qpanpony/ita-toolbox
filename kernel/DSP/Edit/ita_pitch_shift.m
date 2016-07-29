function varargout = ita_pitch_shift(varargin)
%ITA_PITCH_SHIFT - Pitch Shifter
% This function changes pitch of input data according to a factor
%
%  Syntax:
%   audioObj = ita_pitch_shift(audioObj,pitch_factor)
%
%  Example:
%   audioObj = ita_pitch_shift(audioObj)
%
%   See also: ita_nonlinear_power_series
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_pitch_shift">doc ita_pitch_shift</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: dietrich  -- Email: pdi@akustik.rwth-aachen.de
% Created:  21-Jul-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,2);
sArgs        = struct('pos1_data','itaAudioTime','pos2_alpha','int');
[data,alpha,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Pitch Shifting
result = data;
% fs = data.samplingRate;                             % input sampling rate
input = data.dat;
%%% Define global constants

N       = 512;                          % frame length
overlap = .75;                          % overlap fraction
window  = hanning(N)';                  % input window

%%% Calculate working variables

input_length = length(input);           % length of input signal
frame_count  = floor((input_length-2*N)/(N*(1-overlap)));
                                        % number of frames in input
Ra = floor(N*(1-overlap));              % analysis time hop
Rs = floor(alpha*Ra);                   % synthesis time hop
Wk = (0:(N-1))*2*pi/N;                  % center bin frequencies
output = zeros(1, input_length*alpha);  % output signal initialization

%%% Process input frames

Xu_current = fft(window.*input(1:N));   % analyze initial frame
PhiY_current = angle(Xu_current);       % initial frame output phases

for u=1:frame_count
    Xu_prev = Xu_current;               % store last frame's STFT
    PhiY_prev = PhiY_current;           % store last frame's output phases
    Xu_current = fft(window.*input(u*Ra:u*Ra+N-1));
                                        % analyze current frame
    DPhi = angle(Xu_current) - angle(Xu_prev) - Ra*Wk;
                                        % unwrapped phase change
    DPhip = mod(DPhi+pi, 2*pi) - pi;    % principle determination (+/- pi)
    w_hatk = Wk + (1/Ra)*DPhip;         % estimated "real" bin frequency
    PhiY_current = PhiY_prev + Rs*w_hatk;
                                        % Phase propagation formula
    Yu = abs(Xu_current).*exp(1i*PhiY_current);
                                        % output STFT
    output(u*Rs:u*Rs+N-1) = output(u*Rs:u*Rs+N-1) + real(ifft(Yu));
                                        % add current frame to output
end
result.dat = output;
% norm_output = output./max(output);      % normalize the output amplitude
% [t,d]=rat(alpha);                       % determine integer shift ratio
% result.dat = resample(output,d,t);         % resample for pitch shift


%% Find output parameters
varargout(1) = {result};

%end function
end