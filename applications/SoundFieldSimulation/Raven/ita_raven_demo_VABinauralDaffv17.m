%% RAVEN head rotiation simulation & Auralization with VirtualAcoustics
%
% Author:   Henry Andrew / Lukas Aspöck / Jonas Stienen
% Contact:  las@akustik.rwth-aachen.de
% date:     2019/06/19
%
% Example to simulate head rotation in a classroom and store it in a DAFF
% file (in this example file, only early reflections)
% For auralization, use VA's binaural free field renderer and set the HRIR database 
% to the simulated BRIR database 
% 
% If not available, get VirtualAcoustics on www.virtualacoustics.org
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%--------------------------------User Settings-----------------------------
% Modify path if RAVEN was not installed in the default location
ravenBasePath = 'C:\ITASoftware\Raven\';

raven_project_filename = [ ravenBasePath 'RavenInput\Classroom\Classroom.rpf'];%'Shoebox_room.rpf'; %raven project file of room
source_directivity_filename =  [ ravenBasePath 'RavenDatabase\DirectivityDatabase\Singer_2011_FWE_TLE_norm.daff'];  %path to raven database emtries
receiver_directivity_filename = [ ravenBasePath 'RavenDatabase\HRTF\2017_FABIAN_HATO-0_HRIR_LAS_D170_1x1_128_norm_sampleShift10.v15.daff'];
out_file_prefix = 'Classroom';
source_position = [7.0000    1.7000   -4.0000]; %NOTE, make sure these are inside the room!
receiver_position = [3 1.7 -4]; %NOTE: in openGL coordinated (used by RAVEN) the "up/down" direction is the second element, and the third element is different from matlab coordinates by a factor of -1

% NOTE: A simulation with azimuthResolution=3 and elevationResolution=45
% takes about 20 minutes on a regular computer
azimuthResolution=3; %in degrees. NOTE, small values here may result in large simulation times
elevationResolution=45;
simulate_room = true; %do simulation, or just load results from current workspace?
automatic_rotate_sim = true; %set to true to automatically rotate the room, or false to manually rotate with a slider


%% Create the Daff files to be used in auralisation

%loads data from a raven project. Incudes lots of methods to calculate things/ extract data etc
rpf = itaRavenProject(raven_project_filename);
rpf.setModel([ ravenBasePath 'RavenModels\Classroom\Classroom_empty.ac']);

DAFF17FileName = [out_file_prefix '_' num2str(azimuthResolution) 'x' num2str(elevationResolution) '.v17.ir.daff'];
    
if( simulate_room )
    % ------------------------Load the raven project file----------------------
    
    rpf.setReceiverHRTF(receiver_directivity_filename); %load a HRTF for the receiver
    rpf.setRadiusDetectionSphere(1.2);
    rpf.setTimeSlotLength(15);
    rpf.setNumParticles(10000);
    rpf.setFixReflectionPattern(1);
    rpf.setFixPoissonSequence(1);
    rpf.setSourcePositions(source_position);
    rpf.setSourceDirectivity(source_directivity_filename);
    rpf.setSourceViewVectors([-1 0 0]);
    rpf.setSourceUpVectors([0 1 0]);
    rpf.setFilterLength(100);   % early reflections only
    rpf.setSimulationTypeIS(1);
    rpf.setSimulationTypeRT(0);
    
    
    additional_metadata = daffv17_add_metadata( [], 'Web resource', 'String', 'http://www.opendaff.org' );
    additional_metadata = daffv17_add_metadata( additional_metadata, 'DELAY_SAMPLES', 'Float', '0' );
    
    daffv17_write(  'filename', DAFF17FileName, ...
        'content', 'IR', ...
        'alphares', azimuthResolution, ...
        'betares', elevationResolution, ...
        'alpharange', [ 0 360 ], ...
        'betarange', [ 0 180 ], ...
        'channels', 2, ...
        'metadata', additional_metadata, ...
        'datafunc', @dfRavenBinauralVA, ...
        'orient', [ 0 0 0 ], ...
        'userdata', rpf );    
    
end

%% Connect to VA server
va = itaVA;

va_connect( va ); %function called to automatically open VA and connect to it
% va.connect( 'localhost' ) %connect to a va server which is already running

%% Auralise simulated data
va.reset()

% Control output gain
va.set_output_gain( 0.5 )

% Add the current absolute folder path to VA application
va.add_search_path( pwd );

% Create a signal source and start playback
X = va.create_signal_source_buffer_from_file( [ ravenBasePath '\RavenDatabase\SoundDatabase\Conga_ITA.wav']);
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );

% Create a virtual sound source and set a position
S = va.create_sound_source( 'itaVA_Source' );
va.set_sound_source_position( S, [ 0 0 -1 ] ) % Note: This position is only important for the head rotation. Actual sound source position is encoded in the BRIRs

% Create a listener with a HRTF and position him
L = va.create_sound_receiver( 'itaVA_Listener' );
va.set_sound_receiver_position( L, [ 0 0 0 ] )

H = va.create_directivity( DAFF17FileName );

va.set_sound_receiver_directivity( L, H );

% Connect the signal source to the virtual sound source
va.set_sound_source_signal_source( S, X )

% More information
disp( 'Type ''doc itaVA'' for more information.' )

a = rpf.plotModelRoom;
plot3(a, source_position(1), -source_position(3), source_position(2),'.r','MarkerSize',25);
hold on
plot3(a, [source_position(1),source_position(1)-1], [-source_position(3),-source_position(3)], [source_position(2),source_position(2)],'-r');
plot3(a, receiver_position(1), -receiver_position(3), receiver_position(2), '.b','MarkerSize',25 );
arrow = plot3(a, [receiver_position(1),receiver_position(1)+1], [-receiver_position(3),-receiver_position(3)], [receiver_position(2),receiver_position(2)],'-b');


%---------------------------------plot look directions------------------------------
if( automatic_rotate_sim )
    for iAngle=0:5:360
        %disp(['CurrentAngle: ' num2str(iAngle) ]);
        
        va.set_sound_receiver_orientation_view_up(L,[cosd(iAngle) 0 sind(iAngle)],[0 1 0]);
        
        rcvr_view_vector = receiver_position.*[1 1 -1] + [cosd(iAngle) 0 -sind(iAngle)];
        arrow.XData = [receiver_position(1), rcvr_view_vector(1)];
        arrow.YData = [-receiver_position(3), rcvr_view_vector(3)];
        arrow.ZData = [receiver_position(2), rcvr_view_vector(2)];
        drawnow
        
        pause(0.2);
    end
else
    va_sliderAzimuth(va,L); %control the direction manually with an angle slider
end



%%
function va_connect( va )
VAbinaryPath=fileparts(which('VAServer.exe'));
VAPath = VAbinaryPath(1:end-3);
try
    va.connect( 'localhost' )
catch %open a VA server if not already open
    %automatically open va server
    system([ which('VAServer.exe') ' localhost:12340 ' fullfile( VAPath, 'conf') '\VACore.ini &'])
    for i = 1:20 %try to connect for 20 seconds, then throw an error if sill cannot
        try
            pause(1) %give the server time to set up
            va.connect( 'localhost' )
            break
        catch
            if(i == 10)
                error( 'Unable to Connect to VA Server' )
            end
        end
        
    end
end
end