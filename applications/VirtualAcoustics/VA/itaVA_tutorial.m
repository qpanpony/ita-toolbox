%% Short tutorial for itaVA (Virtual Acoustics (VA) Matlab client)
% covers basic operations for setting up a simple example of a virtual scene
% (binaural synthesis for 1 receiver, 1 static / 1 moving virtual sound source)
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
% Version: 2018-03-12 (compatible with VA.v2018a_preview.win32-x64.vc12 (and probably higher))
% Revision: Ernesto Accolti 2018-02-20 (update for VA.2018a_preview)

%% Step 0: Initializations
% Select VA environment
VAsel = 0;  % 0: start VAServer.exe (without GUI for visualization of virtual environment), 
            % 1: start Redstart.exe (with graphical user interface)
            
% Set VA root directory containing bin, conf, data folders etc.
if ~exist('deployDir','var')
    deployDir = uigetdir(pwd);
end

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
    [~,searchresult]=system('tasklist /FI "imagename eq Redstart.exe" /fo table /nh');
    if ~strcmp(strtrim(searchresult(1:13)),'Redstart.exe')
        system(fullfile(deployDir,'\bin\Redstart.exe &'));
        pause(1) % start-up may take some time on old PC's, pause() to avoid error
    end
end
 
%% Step 1: 
% VAsel = 0: VAServer.exe was started based on the configuration in VAini.exe and currently is running
% VAsel = 1: Create a session under the menu item Redstart and press the start button in Redstart VA GUI

if ~exist('firstStart','var')
    firstStart = true;
end

if VAsel == 1 && firstStart == true
    fprintf('(1) Create a session under the menu item Redstart.\n(2) Press the start button in Redstart VA GUI.\n(3) Press any button in Matlab to continue.\n')
    firstStart = false;
    pause 
end

%% Step 2: Create itaVA object and connect to VAServer
a = itaVA;

% Connect to VAServer (must be running and listening to default port on localhost)
if ~a.get_connected % only connect if no connection to server is established
    a.connect('localhost')
end

% Reset VA and clear the scene
a.reset()

% Optionally add important data directories (if not specified in the VA setup GUI which pops up the first time you use VA)
a.add_search_path( fullfile( deployDir, 'data' ) );
a.add_search_path( fullfile( deployDir, 'conf' ) );

%% Step 3: Set global output gain (optionally set reproduction module)
% set global gain of VA output
a.set_output_gain(0.3); % value between 0 (-inf dB) and 1 (0 dB) 

% % query available reproduction modules (cf. VACore.ini)
% modules = a.get_modules;
% 
% Example 1: set reproduction module for binaural synthesis, e.g. 'hprep' for a
% binaural synthesis played back over headphones and set HPEQ file
% command_struct = struct();
% command_struct.hpirinv = '$(VADataDir)/HPEQ/HD600_all_eq_128_stereo.wav';
% command_struct.gain = 0.1;
% a.call_module( 'Headphones:MyHD600', command_struct )

% Example 2: receiver dumping for binaural freefield renderer
% command_struct = struct();
% command_struct.command = 'STARTDUMPLISTENERS';
% command_struct.gain = .1;
% command_struct.FilenameFormat = 'ListenerFuerMeckingjay$(ListenerID).wav';
% a.call_module( 'BinauralFreefield:MyBinauralFreefield', command_struct )
% command_struct.command = 'STOPDUMPLISTENERS';
% a.call_module( 'BinauralFreefield:MyBinauralFreefield', command_struct )


%% Step 4: Create a receiver and assign a HRIR set
% load HRTF set stored in VADataDir\HRIR

HRIRSet = a.create_directivity( 'ITA_Artificial_Head_5x5_44kHz_128.v17.ir.daff' ); % $(DefaultHRIR) macro would work, too

% create a receiver and assign the HRTF set
L       = a.create_sound_receiver('Listener'); % input parameters: (displayed) name (in VAGUI) / auralization mode / ID of HRIR data set
a.set_sound_receiver_directivity( L, HRIRSet );

LHeight = 1.2; % height of receiver's interaural axis [m]

% set position/orientation of receiver L in virtual world in VA world coordinates / openGL coordinates [m]:
%       center of coordinate system: (x,y,z)=(0,0,0), right-handed coordinate system
%       receiver is looking into -z direction (default) 
%       (positive) offset to the right  -> +x
%       (positive) offset in height     -> +y
%
% use a.setListenerPositionOrientationYPR() to specify 
% the receiver's orientation in the virtual world in yaw-pitch-roll coordinates, or
% a.setListenerPositionOrientationVelocityVU() to specify 
% the receiver's orientation in the virtual world by view-up vectors

a.set_sound_receiver_position(L, [0 LHeight 0])

ori_initial = ita_rpy2quat(0,0,0); % calculate quaternion orientation based on roll/pitch/yaw input
ori_initial_quat = ori_initial.e;  % access quaternion coefficients 
a.set_sound_receiver_orientation(L, ori_initial_quat)  % the midpoint of the receiver's interaural axis is now at a height of LHeight metres, 
%                                                        no additional lateral offset,
%                                                        the receiver is facing into -z direction

% Infos for orientation commands:
% A positive rotation is always applied clockwise wrt. the respective axis [deg]
% Roll:  rotation wrt. -z axis, tilting 
% Pitch: rotation wrt. x axis, nodding
% Yaw:   rotation wrt. y axis, turning

% For further information, please refer to the documentation of the class itaOrientation

% NOTE: When using CTC reproduction module, additionally set the real-world
%       position and orientation of the receiver (wrt. loudspeaker positions) 
%       by using the method set_sound_receiver_real_world_position_orientation_view_up()

% activate the receiver to listen to sound sources in playback status 'play' 
a.set_active_sound_receiver(L)

if useTracker
    a.set_tracked_sound_receiver(L)
    a.connect_tracker()
end

% query the receiver position
LPosTracked = a.get_sound_receiver_position(L);
LHeightTracked = LPosTracked(2);


%%  Step 5: Create a static virtual sound source:
%   S1: static sound source at a defined position
S1 = a.create_sound_source('Source 1');      % name of the sound source as string

a.set_sound_source_position(S1,[-2 LHeightTracked 0])
S1ori = ita_rpy2quat(0,0,-90); % calculate quaternion orientation based on roll/pitch/yaw input
S1ori_quat = S1ori.e;  % access quaternion coefficients 
a.set_sound_source_orientation(S1,S1ori_quat)
% The virtual sound source is now positioned on the left side of the receiver, 
% at a height of LHeightTracked metres, at a distance of 2 metres relative to 
% the midpoint of the interaural axis and facing to +x direction

% Create an audiofile signal source for the sound source (based on a mono wave file)
X1      = a.create_signal_source_buffer_from_file( 'WelcomeToVA.wav' ); % Macro $(DemoSound) would also work here

% ...and link the signal source to the sound source
a.set_sound_source_signal_source(S1,X1)

% optionally set volume of sound source
a.set_sound_source_sound_power(S1,0.05); % value between 0 (-inf dB) and 1 (0 dB) 

% set playback state of audiofile signal source 
a.set_signal_source_buffer_looping( X1, true );          % looping yes/no?
a.set_signal_source_buffer_playback_action( X1, 'play' ) % e.g., plays the audiofile signal source

% listen to the virtual scene for 3 seconds
pause(3)

a.set_signal_source_buffer_playback_action( X1, 'stop' ) % stop playback


%%  Step 6: Create a moving virtual sound source (with directivity):
%   S2: moving virtual sound source (on a pre-defined trajectory)

S2  = a.create_sound_source('Source 2');    % name of the sound source as string

% Create an audiofile signal source for the sound source (based on a mono wave file)
X2  = a.create_signal_source_buffer_from_file( 'WelcomeToVA.wav' );

% ...and link the signal source to the sound source
a.set_sound_source_signal_source(S2,X2);

% load a directivity file in *.daff file format (e.g. directivity of a trumpet)
S2dir = a.create_directivity( 'Singer.v17.ms.daff' );
% set directivity of S2
a.set_sound_source_directivity(S2,S2dir);

% increase sound source power due to energy loss (directivity)
a.set_sound_source_sound_power(S2,0.15)

% define a simple trajectory: the virtual sound source S2 shall move on a
% circle on the horizontal plane with constant radius from pi/2 to -pi/2 (counter-clockwise rotation)
% Note: for the definition of phi/theta, the local coordinate system of the
%       receiver is used (view/up direction: -z/y axis), i.e. phi=0 is in look
%       direction of the receiver and increases counterclockwise, and the
%       zenith angle starts at north pole (0) and ends at south pole (pi)

circleR     = 2;        % radius of trajectory [m]
nlegs       = 200;      % number of equidistant trajectory legs
Tvel        = 10;       % time to pass nlegs points
phi_start   = pi/2;     % start azimuth angle in [rad]
phi_end     = -pi/2;    % end azimuth angle in [rad]
theta       = pi/2;     % zenith angle in [rad]

phi = linspace(phi_start,phi_end,nlegs);

traj_cart(:,1) = circleR*sin(phi); 
traj_cart(:,2) = circleR*cos(phi);
traj_cart(:,3) = LHeight + circleR*cos(theta);

% set initial position of S2 (use first position of trajectory)
a.set_sound_source_position(S2, [traj_cart(1,1) traj_cart(1,2) traj_cart(1,3)]);

% ... and the initial orientation
S2ori = ita_rpy2quat(0,0,0); % alternatively use ita_vu2quat
a.set_sound_source_orientation(S2,S2ori.e); % access quaternion coefficients by .e
a.set_signal_source_buffer_looping( X2, true );         % looping yes/no?

% set period of high-precision timer [s] (for precise position updates in the following update loop)
a.set_timer(Tvel/nlegs); 
for idx = 1:nlegs
    if idx==1 % start playback during first loop cycle
       a.set_signal_source_buffer_playback_action(X2, 'play')
    end
    
    % wait for a signal of the high-precision timer
    a.wait_for_timer();
    
    % update source position and view/up direction of S2 (virtual sound source always points at receiver)
    a.set_sound_source_position(S2, [traj_cart(idx,1), traj_cart(idx,2), traj_cart(idx,3)]);
   
    if idx==nlegs % optionally: stop playback during last loop cycle
       a.set_signal_source_buffer_playback_action(X2, 'STOP') 
    end
end


%% Step 7: Use synchronized scene actions
%  Set set_signal_source_buffer_playback_action for the two existing sources
%  simultaneously (Note: no spatial separation if same signal source from buffer is used 
%  for both sound sources) 

% set initial position of S2 (use first position of trajectory)
a.set_sound_source_position(S2, [traj_cart(1,1) traj_cart(1,2) traj_cart(1,3)]);
% ... and the initial orientation
a.set_sound_source_orientation(S2,S2ori.e); % access quaternion coefficients by .e

% shift buffer playback position of signal source
a.set_signal_source_buffer_playback_position(X1,0.5)

% everything between .lock_update and .unlock_update will be triggered in
% one cycle to allow for synchronized scene events
a.lock_update;
a.set_signal_source_buffer_playback_action(X1, 'PLAY')
a.set_signal_source_buffer_playback_action(X2, 'PLAY')
a.unlock_update;

% wait until longer signal source is played back completely
java.util.concurrent.locks.LockSupport.parkNanos(6.5*10^9); 

a.lock_update;
a.set_signal_source_buffer_playback_action(X1, 'STOP')
a.set_signal_source_buffer_playback_action(X2, 'STOP')
a.unlock_update;


%% Step 8: Clean up (optionally), reset, and disconnect from VAServer

% delete sound sources
a.delete_sound_source(S1);
a.delete_sound_source(S2);

% delete receiver
a.delete_sound_receiver(L);

% reset VA and clear the scene
a.reset()

if useTracker
    % disconnect from tracker
    a.disconnect_tracker
end

% disconnect itaVA object from server
a.disconnect()


