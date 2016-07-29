%% Short tutorial for itaVA (Virtual Acoustics (VA) Matlab client)
% covers basic operations for setting up a simple example of a virtual scene
% (binaural synthesis for 1 listener, 1 static / 1 moving virtual sound source)
% as well as synchronized playback of multiple virtual sound sources
%
% NOTE: The user needs a running version of VAServer.exe / VAGUI.exe (+ dependencies)
% ( please contact {jst, fpa}@akustik.rwth-aachen.de ).
% Set up the (absolute) path of the VA deploy dir (see below).
% Configuration settings are based on VACore.ini / VAGUI.ini files (located in conf directory).
% Additionally, it is necessary to select the correct audio driver backend 
% (e.g. Portaudio, ASIO4All)
%
% Explore itaVA by typing "doc itaVA" in Matlab command window
%
% Author:  Florian Pausch, fpa@akustik.rwth-aachen.de
% Version: 2015-06-24 (compatible with VA.2016-03-23 (and probably higher))


%% Step 1: Initializations
% Select VA environment
VAsel = 1;  % 0: start VAServer.exe (without GUI for visualization of virtual environment), 
            % 1: start VAGUI.exe (with visualization of virtual environment)
            % HINT: Press Ctrl+A in VAGUI window to show and arrange all VAGUI windows conveniently
            
% Select location of *.wav/*.daff/*.ini files (use absolute paths instead of relative paths)
deployDir = 'D:\VA_deploy\VA.2016-03-23'; % root directory of VA deploy (with folders bin, conf, data)

% Do you use Natural Point's Optitrack tracking system?
useTracker = false;

if VAsel==0
    % start VAServer.exe (in Server mode) if not running already
    [~,searchresult]=system('tasklist /FI "imagename eq VAServer.exe" /fo table /nh');
    if ~strcmp(strtrim(searchresult(1:13)),'VAServer.exe')
        % input parameters: deployDir\VAServer.exe localhost:12340 deployDir\VACore.ini &
        system([fullfile(deployDir,'\bin\VAServer.exe localhost:12340 '),fullfile(deployDir,'\conf\VACore.ini &')]);
        pause(1) % start-up may take some time on old PC's, pause() to avoid errors
    end
else
    % start VAGUI.exe if not running already
    [~,searchresult]=system('tasklist /FI "imagename eq VAGUI.exe" /fo table /nh');
    if ~strcmp(strtrim(searchresult(1:10)),'VAGUI.exe')
        % input parameters: deployDir\VAGUI.exe deployDir\VACore.ini deployDir\VAGUI.ini &
        system([fullfile(deployDir,'\bin\VAGUI.exe '),fullfile(deployDir,'\conf\VACore.ini '),fullfile(deployDir,'\conf\VAGUI.ini &')]);
        pause(1) % start-up may take some time on old PC's, pause() to avoid error
    end
end


%% Step 2: Create itaVA object and connect to VAServer
a = itaVA;

% Connect to VAServer (must be running and listening to default port on localhost)
if ~a.isConnected % only connect if no connection to server is established
    a.connect('localhost')
end

% Reset VA and clear the scene
a.reset()


%% Step 3: Set global output gain (optionally set reproduction module)
% set global gain of VA output
a.setOutputGain(0.3); % value between 0 (-inf dB) and 1 (0 dB) 

% % query available reproduction modules (cf. VACore.ini)
% modules = a.enumerateModules;
% 
% Example 1: set reproduction module for binaural synthesis, e.g. 'hprep' for a
% binaural synthesis played back over headphones and set HPEQ file
% command_struct = struct();
% command_struct.hpirinv = '$(VADataDir)/HPEQ/HD600_all_eq_128_stereo.wav';
% command_struct.gain = 0.1;
% a.callModule( 'Headphones:MyHD600', command_struct )

% Example 2: listener dumping for binaural freefield renderer
% command_struct = struct();
% command_struct.command = 'STARTDUMPLISTENERS';
% command_struct.gain = .1;
% command_struct.FilenameFormat = 'ListenerFuerMeckingjay$(ListenerID).wav';
% a.callModule( 'BinauralFreefield:MyBinauralFreefield', command_struct )
% command_struct.command = 'STOPDUMPLISTENERS';
% a.callModule( 'BinauralFreefield:MyBinauralFreefield', command_struct )


%% Step 4: Create a listener and assign a HRIR set
% load HRTF set stored in VADataDir\HRIR

HRIRSet = a.loadHRIRDataset(fullfile(deployDir,'data\HRIR\ITA-Kunstkopf_HRIR_AP11_Pressure_Equalized_3x3_256.daff')); 

% HRIRSet = a.loadHRIRDataset('$(VADataDir)\HRIR\ITA-Kunstkopf_HRIR_AP11_Pressure_Equalized_3x3_256.daff'); 

% create a listener and assign the HRTF set
L       = a.createListener('Listener', 'default', HRIRSet); % input parameters: (displayed) name (in VAGUI) / auralization mode / ID of HRIR data set
LHeight = 1.2; % height of listener's interaural axis [m]

% set position/orientation of listener L in virtual world in VA world coordinates / openGL coordinates [m]:
%       center of coordinate system: (x,y,z)=(0,0,0), right-handed coordinate system
%       listener is looking into -z direction (default) 
%       (positive) offset to the right  -> +x
%       (positive) offset in height     -> +y
%
% use a.setListenerPositionOrientationYPR() to specify 
% the listener's orientation in the virtual world in yaw-pitch-roll coordinates, or
% a.setListenerPositionOrientationVelocityVU() to specify 
% the listener's orientation in the virtual world by view-up vectors

a.setListenerPositionOrientationYPR(L, [0 LHeight 0], [0 0 0]) % the midpoint of the listener's interaural axis is now at a height of LHeight metres, no additional lateral offset
%                                                                the listener is facing into -z direction

% Infos for orientation commands:
% A positive rotation is always applied clockwise wrt. the respective axis [deg]
% Yaw:   rotation wrt. y axis, turning
% Pitch: rotation wrt. x axis, nodding
% Roll:  rotation wrt. -z axis, tilting 

% NOTE: When using CTC reproduction module, additionally set the real-world
%       position and orientation of the listener (wrt. loudspeaker positions) 
%       by using the command setListenerRealWorldHeadPositionOrientationVU()

% activate the listener, i.e. listen to the existing virtual sound sources
a.setActiveListener(L)

if useTracker
    a.setTrackedListener(L)
    a.connectTracker()
end

LPosTracked = a.getListenerPosition(L);
LHeightTracked = LPosTracked(2);


%%  Step 5: Create a static virtual sound source:
%   S1: static sound source at defined position
S1 = a.createSoundSource('Source 1');        % name of the sound source as string
S1ori = itaOrientation(1);                   % use itaOrientation class
S1ori.rpy_deg = [0,0,-90];                   % set roll_deg/pitch_deg/yaw_deg [deg]

a.setSoundSourcePositionOrientationYPR(S1, [-2 LHeightTracked 0], [S1ori.yaw_deg S1ori.pitch_deg S1ori.roll_deg])
                                             % the virtual sound source is now positioned 
                                             % on the left side of the listener, 
                                             % at a height of LHeightTracked metres, 
                                             % at a distance of 2 metres relative to the midpoint of the interaural axis
                                             % and facing in +x direction
                                         
% Create an audiofile signal source for the sound source (based on a mono wave file)
X1      = a.createAudiofileSignalSource(fullfile(deployDir,'\data\Audiofiles\lang_short.wav'));
XX1     = a.loadSound(fullfile(deployDir,'\data\Audiofiles\lang_short.wav')); % load wave file to get additional information (nsamples, duration, ...)
XX1Info = a.getSoundInfo(XX1); % get info about signal source, i.e. wave file

% ...and link the signal source to the sound source
a.setSoundSourceSignalSource(S1,X1)

% optionally set volume of sound source
a.setSoundSourceVolume(S1,0.5); % value between 0 (-inf dB) and 1 (0 dB) 

% set playback state of audiofile signal source 
a.setAudiofileSignalSourceIsLooping(X1,true)         % looping yes/no?
a.setAudiofileSignalSourcePlaybackAction(X1, 'PLAY') % e.g. plays the audiofile signal source
% listen to the virtual scene for the length of the audiofile signal source
java.util.concurrent.locks.LockSupport.parkNanos(XX1Info.duration*10^9); 
a.setAudiofileSignalSourcePlaybackAction(X1, 'STOP') % stop playback


%%  Step 6: Create a moving virtual sound source (with directivity):
%   S2: moving virtual sound source (on a pre-defined trajectory)

S2  = a.createSoundSource('Source 2');    % name of the sound source as string

% Create an audiofile signal source for the sound source (based on a mono wave file)
X2  = a.createAudiofileSignalSource(fullfile(deployDir,'\data\Audiofiles\lang_short.wav'));
XX2 = a.loadSound(fullfile(deployDir,'\data\Audiofiles\lang_short.wav')); % load wave file to get additional information (nsamples, duration)
XX2Info = a.getSoundInfo(XX2); % get info about signal source, i.e. wave file

% ...and link the signal source to the sound source
a.setSoundSourceSignalSource(S2,X2)

% load a directivity file in *.daff file format (e.g. directivity of a trumpet)
DirS2 = a.loadDirectivity(fullfile(deployDir,'\data\Directivity\Saenger.daff'));
% set directivity of S2
a.setSoundSourceDirectivity(S2,DirS2);

% define a simple trajectory: the virtual sound source S2 shall move on a
% circle on the horizontal plane with constant radius from phi=(3*pi/2):(pi/2) (counter-clockwise rotation)
% Note: for the definition of phi/theta, the local coordinate system of the
%       listener is used (view/up direction: -z/y axis), i.e. phi=0 is in look
%       direction of the listener and increases counterclockwise

circleR     = 2;        % radius of trajectory [m]
nlegs       = 200;      % number of equidistant trajectory legs
phi_start   = pi/4;     % start azimuth angle in [rad]
phi_end     = 5*pi/4;   % end azimuth angle in [rad]
theta_start = pi/2;     % start zenith angle in [rad]
theta_end   = pi/2;     % end zenith angle in [rad]

traj        = itaCoordinates(nlegs); % use itaCoordinates object
% trajectory with nlegs equidistant legs in spherical coordinates [<radius> <zenith angle> <azimuth angle>]
traj.sph    = [repmat(circleR,nlegs,1), linspace(theta_start, theta_end, nlegs)', linspace(phi_start, phi_end, nlegs)'];

% apply rotation matrices on trajectory to translate Matlab coordinates to VA world coordinates
rotmtx_x = [1,           0,             0; ...
            0,           cos(-pi/2),   -sin(-pi/2); ...
            0,           sin(-pi/2),    cos(-pi/2)];

rotmtx_z = [cos(-pi/2),   0,            sin(-pi/2); ...
            0,            1,            0; ...
           -sin(-pi/2),   0,            cos(-pi/2)];

traj.cart = (rotmtx_x * traj.cart')';
traj.cart = (rotmtx_z * traj.cart')';
traj.cart = [-traj.cart(:,1), traj.cart(:,2)+LHeight, -traj.cart(:,3)];

% set initial position of S2 (use first position of trajectory) and default orientation
a.setSoundSourcePositionOrientationYPR(S2, [traj.cart(1,1) traj.cart(1,2) traj.cart(1,3)], [0,0,0]);
a.setAudiofileSignalSourceIsLooping(X1,true) % looping yes/no?

% set period of high-precision timer [s] (for precise position updates in the following update loop)
a.setTimer(XX2Info.duration/nlegs); 
for idx = 1:nlegs
    if idx==1 % start playback during first loop cycle
       a.setAudiofileSignalSourcePlaybackAction(X2, 'PLAY')
    end
    
    % update source position and view/up direction of S2 (virtual sound source always points at listener)
    a.setSoundSourcePositionOrientationVU(S2, [traj.cart(idx,1), traj.cart(idx,2), traj.cart(idx,3)],...
        [-traj.cart(idx,1) 0 -traj.cart(idx,3)],[0 1 0]);
    
    % wait for a signal of the high-precision timer
    a.waitForTimer();
    
    if idx==nlegs % optionally: stop playback during last loop cycle
       a.setAudiofileSignalSourcePlaybackAction(X2, 'STOP') 
    end
end


%% Step 7: Use synchronized scene actions
%  Set setAudiofileSignalSourcePlaybackAction for the two existing sources
%  simultaneously (Note: no spatial separation if same AudiofileSignalSource is used 
%  for both SoundSources) 

% everything between .lockScene() and .unlockScene() will be triggered in
% one cycle to allow for synchronized scene events
a.lockScene();
a.setAudiofileSignalSourcePlaybackAction(X1, 'PLAY')
a.setAudiofileSignalSourcePlaybackAction(X2, 'PLAY')
a.unlockScene();

% wait until longer AudiofileSignalSource is played back completely
java.util.concurrent.locks.LockSupport.parkNanos(max(XX1Info.duration,XX2Info.duration)*10^9); 

a.lockScene();
a.setAudiofileSignalSourcePlaybackAction(X1, 'STOP')
a.setAudiofileSignalSourcePlaybackAction(X2, 'STOP')
a.unlockScene();

% % test timer accuracy
% nnlegs = 1000;
% a.setTimer(1/nnlegs); %synced 1kHz update rate for scene modification
% timestamps = zeros(nnlegs,1);
% for idx=1:nnlegs
%     a.waitForTimer(); % wait residual time
%     a.lockScene();
%     timestamps(idx) = a.getCoreClock(); % Modification entry time
%     
%     % do something synchronous in your scene
%     
%     a.unlockScene();
% end
% 
% hist(timestamps(2:end)-timestamps(1:end-1),nnlegs-1)
% grid on
% title('Timer accuracy')
% xlabel('Difference of time stamps in loop [s]')
% ylabel('Number of occurences')


%% Step 8: Clean up (optionally) + disconnect from VAServer
java.util.concurrent.locks.LockSupport.parkNanos(3*10^9); % wait 3s before scene is cleared

% % delete sound sources
% a.deleteSoundSource(S1);
% a.deleteSoundSource(S2);
% 
% % delete listener
% a.deleteListener(L);

% reset VA and clear the scene
a.reset()

if useTracker
    % disconnect from tracker
    a.disconnectTracker()
end

% disconnect itaVA object from server
a.disconnect()


