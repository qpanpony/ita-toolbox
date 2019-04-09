%% Short tutorial for VA, a Matlab interface for Virtual Acoustics (VA)
% The tutorial covers basic operations for setting up a simple virtual scene
% (1 receiver, 1 static / 1 moving virtual sound source), and explains how to
% set up a synchronized playback of multiple virtual sound sources.
%
% It is recommended to run the tutorial in sections to understand the basic
% concepts and controls!
%
% WARNING: Check the playback level of your sound card to avoid hearing damage!
%
% NOTE: The user needs a running version of VAServer.exe / Redstart.exe (+ dependencies)
% which can be downloaded here: http://www.virtualacoustics.org/ (section Download)
% For a more detailed introduction, the reader is referred to http://www.virtualacoustics.org/start.html
%
% Explore VA by typing "doc VA" in Matlab's command window.
%
% Author:   Florian Pausch, fpa@akustik.rwth-aachen.de
% Version:  2018-03-27 (compatible with VA.v2018a_preview.win32-x64.vc12 (and probably higher))
% Revision: Ernesto Accolti 2018-02-20 (update for VA.2018a_preview)

%% Step 1: Initializations
% Select VA environment
VAsel = 1;  % 0: start VAServer.exe (without graphical user interface (GUI) for visualization of virtual environment), 
            % 1: start Redstart.exe (with GUI)
            
% Set VA root directory containing bin, conf, data folders, etc.
if ~exist('deployDir','var')
    deployDir = uigetdir(pwd, 'Set VA root directory...');
end

% Do you use Natural Point's Optitrack motion tracking system?
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
        system(fullfile(deployDir,'\bin\Redstart.exe -a &')); % -a for autostart (runs last activated session), -s to run in safe mode (overrides autostart flag)
        pause(1) % start-up may take some time on old PC's, pause() to avoid error
    end
end
 

%% Step 2: Create VA object and connect to VAServer
a = VA;

% Connect to VAServer (must be running and listening to default port on localhost)
if ~a.get_connected % only connect if no connection to server is established
    a.connect('localhost')
end

% Reset VA and clear the scene
a.reset()

% Optionally add important data directories (if not specified in the VA setup GUI which pops up the first time you use VA)
a.add_search_path( fullfile( deployDir, 'data' ) );
a.add_search_path( fullfile( deployDir, 'conf' ) );
%a.add_search_path( 'C:/Users/Rocky/Experiment/InputWAVFiles' )
%a.add_search_path( 'C:/Users/Rocky/Experiment/HRTFs' )

%% Step 3: Set global output gain
% set global gain of VA output
a.set_output_gain(0.3); % value between 0 (-inf dB) and 1 (0 dB) 

% % query available reproduction modules (cf. VACore.ini)
% modules = a.get_modules;

% Example 1: get help about parameters
% va.call_module( 'module_id', struct('help',true) )
% 
% Example 2: receiver dumping for binaural free field renderer
% command_struct = struct();
% command_struct.command = 'STARTDUMPLISTENERS';
% command_struct.gain = .1;
% command_struct.FilenameFormat = 'ListenerFuerMeckingjay$(ListenerID).wav';
% a.call_module( 'BinauralFreeField:MyBinauralRenderer', command_struct )
% command_struct.command = 'STOPDUMPLISTENERS';
% a.call_module( 'BinauralFreeField:MyBinauralRenderer', command_struct )


%% Step 4: Create a receiver and assign an HRIR set
% load HRTF set stored in VADataDir\HRIR

HRIRSet = a.create_directivity_from_file( 'ITA_Artificial_Head_5x5_44kHz_128.v17.ir.daff' ); % $(DefaultHRIR) macro would work, too

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

a.set_sound_source_position(S1,[2 LHeightTracked 0])
S1ori = ita_rpy2quat(0,0,pi/2); % calculate quaternion orientation based on roll/pitch/yaw input [rad]
S1ori_quat = S1ori.e;  % access quaternion coefficients 
a.set_sound_source_orientation(S1,S1ori_quat)
% The virtual sound source is now positioned on the right side of the receiver, 
% at a height of LHeightTracked metres, at a distance of 2 metres relative to 
% the midpoint of the interaural axis and facing to +x direction

% Create an audiofile signal source for the sound source (based on a mono wave file)
X1 = a.create_signal_source_buffer_from_file( 'WelcomeToVA.wav' ); % Macro $(DemoSound) would also work here

% ...and link the signal source to the sound source
a.set_sound_source_signal_source(S1,X1)

% optionally set volume of sound source
a.set_sound_source_sound_power(S1,3e-2); % value between 0 (-inf dB) and 1 (0 dB) 

% set playback state of audiofile signal source 
a.set_signal_source_buffer_looping( X1, true );          % looping yes/no?
a.set_signal_source_buffer_playback_action( X1, 'PLAY' ) % e.g., plays the audiofile signal source

% listen to the virtual scene for 3 seconds
pause(3)

a.set_signal_source_buffer_playback_action( X1, 'STOP' ) % stop playback


%%  Step 6: Create a moving virtual sound source (with directivity):
%   S2: moving virtual sound source (on a pre-defined trajectory)

S2 = a.create_sound_source('Source 2'); % name of the sound source as string

% Create an audiofile signal source for the sound source (based on a mono wave file)
X2 = a.create_signal_source_buffer_from_file( 'WelcomeToVA.wav' );

% ...and link the signal source to the sound source
a.set_sound_source_signal_source(S2,X2);

% load a directivity file in *.daff file format (e.g. directivity of a trumpet)
S2dir = a.create_directivity( 'Singer.v17.ms.daff' );
% set directivity of S2
a.set_sound_source_directivity(S2,S2dir);

% increase sound source power due to energy loss (directivity)
a.set_sound_source_sound_power(S2,0.1)

% define a simple trajectory: the virtual sound source S2 shall move on a
% circle on the horizontal plane with constant radius from pi/2 to -pi/2 (counter-clockwise rotation)
% Note: Please refer to itaOrientation to get more information about the used
%       openGL coordinate system!

circleR     = 2;        % radius of trajectory [m]
nlegs       = 200;      % number of equidistant trajectory legs
Tvel        = 10;       % time to pass nlegs points
phi_start   = pi/2;     % start azimuth angle in [rad]
phi_end     = -pi/2;    % end azimuth angle in [rad]
theta       = pi/2;     % zenith angle in [rad]

% define the position trajectory
phi = linspace(phi_start,phi_end,nlegs);
S2pos_traj = ([circleR*sin(phi)', repmat(LHeight,nlegs,1), -circleR*cos(phi)']);

% ... and the orientation trajectory
S2ori_traj = ita_rpy2quat(zeros(nlegs,1),zeros(nlegs,1),linspace(pi/2,-pi/2,nlegs)'); % alternatively use ita_vu2quat
a.set_signal_source_buffer_looping( X2, true ); % looping yes/no?

% set period of high-precision timer [s] (for precise position updates in the following update loop)
a.set_timer(Tvel/nlegs); 
for idx = 1:nlegs
    if idx==1 % start playback during first loop cycle
       a.set_signal_source_buffer_playback_action(X2, 'PLAY')
    end
    
    % wait for a signal of the high-precision timer
    a.wait_for_timer();
    
    % update source position and orientation of S2 (virtual sound source always points at receiver)
    a.set_sound_source_position(S2, [S2pos_traj(idx,1), S2pos_traj(idx,2), S2pos_traj(idx,3)]);
    a.set_sound_source_orientation(S2, S2ori_traj(idx).e); % access quaternion coefficients by .e

    if idx==nlegs % optionally: stop playback during last loop cycle
       a.set_signal_source_buffer_playback_action(X2, 'STOP') 
    end
end


%% Step 7: Use synchronized scene actions
%  Set set_signal_source_buffer_playback_action for the two existing sources
%  simultaneously (Note: no spatial separation if same signal source from buffer is used 
%  for both sound sources) 

% shift buffer playback position of signal source
a.set_signal_source_buffer_playback_position(X2,0.5)

% everything between .lock_update and .unlock_update will be triggered in
% one cycle to allow for synchronized scene events
a.lock_update;
a.set_signal_source_buffer_playback_action(X1, 'PLAY')
a.set_signal_source_buffer_playback_action(X2, 'PLAY')
a.unlock_update;

% listen to the scene
java.util.concurrent.locks.LockSupport.parkNanos(6.5*10^9); 

a.lock_update;
a.set_signal_source_buffer_playback_action(X1, 'STOP')
a.set_signal_source_buffer_playback_action(X2, 'STOP')
a.unlock_update;


%% Step 8: Clean up (optionally), reset, and disconnect from VAServer

% delete sound sources
a.delete_sound_source(S1);
a.delete_sound_source(S2);

% reset VA and clear the scene
a.reset()

if useTracker
    % disconnect from tracker
    a.disconnect_tracker
end

% disconnect VA object from server
a.disconnect()


