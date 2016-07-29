function varargout = ita_pitchshift(varargin)
% ITA_PITCHSHIFT - produces a shifting in the pitch of a
%   sound or generates the harmonics of a sound with a proper choice of the
%   parameter alpha (compression: alpha<1 or expansion: alpha>1)
%
% Syntax: audioObject = ita_pitchshift(audioObjectIn, alpha, overlap, frame_size) 
% 
%  Example:
%   audioObjOut = ita_pitchshift(audioObjIn, 2, 0.75, 2048)
%       produce the second harmonic of the input signal with an overlap of
%       75% and a frame size of 2048 samples
%
%  See also:
%   resample, hanning, fft, ifft, angle, ita_pitchshift_reconstruction

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- alexandre.bleus@akustik.rwth-aachen.de
% Created: 23-April-2010


%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');

%% Initialisation
%   Number of input arguments
narginchk(2,4);

if nargin<3
    if verboseMode, disp('ITA_PITCHSHIFT:Default frame size and overlap will be used'); end;
    Nfft=2048;  % size of the frame
    over=0.75;  % overlap between 0 and 1;
else
    over=varargin{3};
    Nfft=varargin{4};

end
alpha=varargin{2}; % compression: alpha<1 or expansion: alpha>1
input=varargin{1}.timeData;
N=length(input);

%% Initial process
La        = floor((1-over) * Nfft);   % number of samples to "advance" for each analysis frame : analysis hop size.
nb_frames = floor((N-Nfft) / La);     % number of frames to compute
Ls        = floor(alpha * La);        % number of samples to "advance" for each synthesis frame : synthesis hop size.
output    = zeros(floor(N*alpha),1);  % result vector
h         = hanning(Nfft);            % Hanning Window

%% Loop initialisation
x     = h.*input(1:Nfft);
xfft  = fft(x,Nfft);
Phis1 = angle(xfft);
Phia1 = Phis1;

%% Loop
for loop=2:nb_frames-1
    % Analysis
    % Window the frame
    x= h.*input((loop-1) * La + 1:(loop-1)*La + Nfft);  
    xfft    =fft(x, Nfft);
	Xi    = abs(xfft);      % Amplitude
    Phia2 = angle(xfft);    % Phase
    % Time scaling 
    omega = mod( (Phia2-Phia1)-2*pi*([0:Nfft-1].')/Nfft * La + pi, 2*pi) - pi;
    omega = 2 * pi * ([0:Nfft-1].') / Nfft + omega / La;
    Phis2 = Phis1 + Ls*omega;
    % Keep the phases consistent
    Phis1 = Phis2;
    Phia1 = Phia2;
    %  Synthesis    
    tfs = Xi.*exp(1i*Phis2);
    Xr  = real(ifft(tfs)).*h;
    % overlapp and add the synthetised frames 
    output((loop-1)*Ls+1 : (loop-1)*Ls+Nfft)= output((loop-1)*Ls+1:(loop-1)*Ls+Nfft) + Xr;
end

%% Resampling
[t,d]=rat(alpha);                       % shift ratio
shifted = resample(output,d,t);         % resample for pitch shift
out=varargin{1};
out.timeData=shifted;

%% Set Output
varargout(1)={out};
end
