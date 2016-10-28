classdef itaVA < handle
    %ITAVA Remote network interface to VA (Virtual Acoustics), the real-time 
    %auralization software made by ITA.
    %
    %   This class realizes a remote connection to a VA real-time
    %   auralization server and implements the full VA core interface
    %   in Matlab. You can connect to to the server
    %   and control all of its features to perform real-time
    %   auralization, including live tracking if available.
    %   In order to get understand to the concepts behind VA
    %   please refer to the VA documentation or have a look at the example scripts.
    %
    %   See also: itaVA_example_simple, itaVA_example_tracked_listener,
    %   itaVA_example_generic_path_renderer, itaVA_example_random_numbers
    %
    %   Quick usage:
    %
    %   - Create an interface and connect to the server running on the
    %     same computer (localhost)
    %
    %     va = itaVA;
    %     va.connect;
    %
    %     If no error occurs, you can then use the interface to work with
    %     the VA server.
    %
    %     Now, you can call other methods. For instance create a sound
    %     source:
    %
    %     sourceID = va.createSoundSource( 'My Matlab virtual sound source' )
    %
    %     When everything is done, do not forget to close the connection.
    %     You can call disconnect on the instance or simply clear it:
    %
    %     clear va
    %
    %
    
    properties(Hidden = true, Access = private)
        handle = int32(0); % Connection handle
                
        % Connection defaults
        DEFAULT_SERVER_PORT = 12340;
    end
    
    methods(Static)
        
        function [ ok ] = check_for_mex_file()
            % Checks if VAMatlab executable can be found.
            if ~exist( 'VAMatlab', 'file' )
                disp( 'Matlab binding for VA not complete (missing VAMatlab executable).' )
                
                % file dialog
                itaVA_setup()
                
                % Re-check
                ok = exist( 'VAMatlab', 'file' ) > 0;
            else
                ok = true;
            end
        end
        
        function [version] = getVersion()
            % Return the version of the VA Matlab interface
            %
            % Parameters:
            %
            % 	None
            %
            % Return values:
            %
            % 	version  [string]  Version string
            
            if ~itaVA.check_for_mex_file()
                error( 'Matlab binding for VA requires VAMatlab executable.' );
            end

            version = VAMatlab('getVersion');
        end
        
         function [] = setVerboseMode(mode)
            % Sets the verbose level of the VA Matlab interface
            %
            % Parameters:
            %
            % 	mode  [string]   Verbose mode ('quiet'|'normal')
            %
            % Return values:
            %
            % 	None
            %
            % Remarks:
            %
            % - If you do not want any messages from the extension
            %   set the verbose mode to 'quiet'
            %
            
            if ~itaVA.check_for_mex_file()
                error( 'Matlab binding for VA requires VAMatlab executable.' );
            end

            VAMatlab('setVerboseMode', mode);
        end
    end

    methods
        function this = itaVA(addressstring)
            % Initialization constructor. Initiiates a new connection.
            %
            % Parameters:
            %
            % 	addressstring  [string]   Hostname or IP address and port of the
            %                             server string (name:port), optional
            %
            % Return values:
            %
            % 	None
            %
            % Remarks:
            %
            % - You can leave the argument 'address' undefined, in order
            %   to create an clear, unconnected instance and connect to
            %   a server later using the method 'connect'
            % - Example: core = itaVA;
            %            core = itaVA('localhost:12340');
            %
            
            if ~itaVA.check_for_mex_file()
                error( 'Matlab binding for VA requires VAMatlab executable.' );
            end
        
            if (nargin > 0)
                this.connect(addressstring)
            end
        end
        
        function delete(this)
            % Destructor. Automatically disconnects an existing connection.
            this.disconnect
        end 
       
        function [connected] = isConnected(this)
            % Returns if a connection to a server is established
           connected = VAMatlab('isConnected', this.handle);
        end
        
        function connect(this, addressstring)
            % Connects to a server
            %
            % Parameters:
            %
            % 	addressstring  [string]   Hostname or IP address and port of the
            %                             server string (name:port), optional
            %
            % Return values:
            %
            % 	None
            %
            % Remarks:
            %
            % - An error occurs if the instance is already connected
            % - Example: core.connect('localhost:12340')
            %
            if this.handle~=0
				error('Already connected. Close the existing connection first.'); 
			end 
            
			if nargin == 2
				if isempty(addressstring) 
					error('Server address must not be empty.');
				end
			else
				addressstring = 'localhost';
			end
            
            this.handle = VAMatlab('connect', addressstring);
        end
        
        function disconnect(this)
            % Disconnects from a server
            VAMatlab('disconnect', this.handle)
            this.handle = int32(0);
        end
           
        function [state] = getServerState(this)
            % Returns the state of the connected server
            %
            % Use this function to check whether the server is
            % running fine and does not have any problems.
            %
            % Parameters:
            %
            % 	None
            %
            % Return values:
            %
            % 	state [integer-1x1] Server stat
            %
            % States:
            % 
            % - 0 = Connected, but server not configured. Failure.
            % - 1 = Connected and ready for usage.
            % - 2 = Connected, but server has failure.
            %
            if this.handle==0, error('Not connected.'); end; 
            state = VAMatlab('getServerState', this.handle);
        end
        
        function connectTracker( this, remote_ip, local_ip )
            % Connects to a local NatNet tracking server
            % 
            % The server will update a virtual listener for real-time 
            % sound synthesis and the real world listener position for
            % those sound reproductions that need this information, like  
            % Crosstalk-Cancellation.
            %
            % See also setTrackedListener.
            %
            % Parameters (optional):
            %
            % 	remote_ip [char]	Remote ip address
            % 	local_ip [char]		Local ip address
            %

			if( nargin == 1 )
				remote_ip = '127.0.0.1';
				local_ip = '127.0.0.1';
			end

            VAMatlab( 'ConnectTracker', this.handle, remote_ip, local_ip );
        end
        
        function [connected] = isTrackerConnected( this )
            % Returns true, if tracker is connected
            connected = VAMatlab( 'IsTrackerConnected', this.handle );
        end
        
        function setTrackedListener( this, listener_id )
            % Connects a VA listener with the tracked rigid body
            %
            % Parameters:
            %
            % 	listener_id  [integer-1x1]   VA listener id
            %
            VAMatlab( 'SetTrackedListener', this.handle, listener_id );
        end
        
        function setTrackedSource( this, source_id )
            % Connects a VA source with the tracked rigid body
            %
            % Parameters:
            %
            % 	source_id  [integer-1x1]   VA listener id
            %
            VAMatlab( 'SetTrackedSource', this.handle, source_id );
        end
        
        function disconnectTracker( this )
            % Disconnects from the NatNet tracking server
            VAMatlab( 'DisconnectTracker', this.handle )
        end
        
        function setRigidBodyIndex( this, index )
            % Sets the index of the rigid body to be tracked (default is 1)
            VAMatlab( 'SetRigidBodyIndex', this.handle, index )
        end
        
        function setRigidBodyTranslation( this, translation )
            % Sets the pivot point translation for the tracked rigid body
			%
			% Parameters:
			%
			%	translation [double-3x1]	Translation in local coordinate system of rigid body [m]
			%
            VAMatlab( 'SetRigidBodyTranslation', this.handle, translation )
        end
        
        function setRigidBodyRotation( this, rotation )
            % Sets the rotation of orientation for the tracked rigid body
			%
			% Given rotation has to be a Matlab quaternion type (order: w(real), i, j, k)
			%
			% Parameters:
			%
			%	rotation [quaternion]	Rotation of rigid body
			%
            VAMatlab( 'SetRigidBodyRotation', this.handle, rotation )
        end
        
        %% --= Functions =--
        
        	function [valid] = addSearchPath(this, path)
		% adds a search path at core side
		%
		% Parameters:
		%
		% 	path [string] Relative or absolute path
		%
		% Return values:
		%
		% 	valid [logical scalar] True, if path at core side valid
		%

		if this.handle==0, error('Not connected.'); end;

		[valid] = VAMatlab('addSearchPath', this.handle, path);
	end

	function [playbackID] = addSoundPlayback(this, signalSourceID,soundID,flags,timecode)
		% Adds a sound playback for a sequencer signal source
		%
		% Parameters:
		%
		% 	signalSourceID [string] Sequencer signal source ID
		% 	soundID [integer-1x1] Sound ID
		% 	flags [integer-1x1] Playback flags
		% 	timecode [double-1x1] Playback time (expressed in core clock time, 0 => instant playback)
		%
		% Return values:
		%
		% 	playbackID [integer-1x1] Playback ID
		%

		if this.handle==0, error('Not connected.'); end;

		[playbackID] = VAMatlab('addSoundPlayback', this.handle, signalSourceID,soundID,flags,timecode);
	end

	function [ret] = callModule(this, module,mstruct)
		% Calls an internal module of the VA server
		%
		% Parameters:
		%
		% 	module [string] Module name
		% 	mstruct [struct] Matlab structure with key-value content
		%
		% Return values:
		%
		% 	ret [struct-1x1] Struct containing the return values
		%

		if this.handle==0, error('Not connected.'); end;

		[ret] = VAMatlab('callModule', this.handle, module,mstruct);
	end

	function [signalSourceID] = createAudiofileSignalSource(this, filename,name)
		% Creates a signal source which plays an audiofile
		%
		% Parameters:
		%
		% 	filename [string] Filename
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('createAudiofileSignalSource', this.handle, filename,name);
	end

	function [signalSourceID] = createEngineSignalSource(this, name)
		% Creates an engine signal source
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('createEngineSignalSource', this.handle, name);
	end

	function [id] = createListener(this, name,auralizationMode,hrirID)
		% Creates a listener
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		% 	auralizationMode [string] Auralization mode (optional, default: 'default')
		% 	hrirID [integer-1x1] HRIR dataset ID (optional, default: -1)
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		if ~exist('auralizationMode','var'), auralizationMode = 'default'; end
		if ~exist('hrirID','var'), hrirID = -1; end
		[id] = VAMatlab('createListener', this.handle, name,auralizationMode,hrirID);
	end

	function [signalSourceID] = createNetworkStreamSignalSource(this, address,port,name)
		% Creates a signal source which receives audio samples via network
		%
		% Parameters:
		%
		% 	address [string] Hostname or IP address of the audio streaming server
		% 	port [integer-1x1] Server port
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('createNetworkStreamSignalSource', this.handle, address,port,name);
	end

	function [signalSourceID] = createSequencerSignalSource(this, name)
		% Creates a sequencer signal source
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('createSequencerSignalSource', this.handle, name);
	end

	function [id] = createSoundSource(this, name,auralizationMode,volume)
		% Creates a sound source
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		% 	auralizationMode [string] Auralization mode (optional, default: 'default')
		% 	volume [double-1x1] Volume [factor] (optional, default: 1)
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		if ~exist('auralizationMode','var'), auralizationMode = 'default'; end
		if ~exist('volume','var'), volume = 1; end
		[id] = VAMatlab('createSoundSource', this.handle, name,auralizationMode,volume);
	end

	function [id] = createSoundSourceExplicitRenderer(this, name,renderer)
		% Creates a sound source explicitly for a certain renderer
		%
		% Parameters:
		%
		% 	name [string] Name
		% 	renderer [string] Renderer identifier
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound source ID
		%

		if this.handle==0, error('Not connected.'); end;

		[id] = VAMatlab('createSoundSourceExplicitRenderer', this.handle, name,renderer);
	end

	function [] = deleteListener(this, listenerID)
		% Deletes a listener from the scene
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('deleteListener', this.handle, listenerID);
	end

	function [result] = deleteSignalSource(this, signalSourceID)
		% Deletes a signal source
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		%
		% Return values:
		%
		% 	result [logical-1x1] Signal source deleted?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('deleteSignalSource', this.handle, signalSourceID);
	end

	function [] = deleteSoundSource(this, soundSourceID)
		% Deletes an existing sound source in the scene
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('deleteSoundSource', this.handle, soundSourceID);
	end

	function [modules] = enumerateModules(this)
		% Enumerates internal modules of the VA server
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	modules [cell-array of struct-1x1] Module informations (names, descriptions, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[modules] = VAMatlab('enumerateModules', this.handle);
	end

	function [result] = freeDirectivity(this, directivityID)
		% Frees a directivity and releases its memory
		%
		% Parameters:
		%
		% 	directivityID [integer-1x1] Directivity ID
		%
		% Return values:
		%
		% 	result [logical-1x1] Directivity freed?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('freeDirectivity', this.handle, directivityID);
	end

	function [result] = freeHRIRDataset(this, hrirID)
		% Frees a loaded HRIR dataset
		%
		% Parameters:
		%
		% 	hrirID [integer-1x1] HRIR dataset ID
		%
		% Return values:
		%
		% 	result [logical-1x1] HRIR dataset freed?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('freeHRIRDataset', this.handle, hrirID);
	end

	function [result] = freeSound(this, soundID)
		% Frees a loaded sound
		%
		% Parameters:
		%
		% 	soundID [integer-1x1] Sound ID
		%
		% Return values:
		%
		% 	result [logical-1x1] Sound freed?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('freeSound', this.handle, soundID);
	end

	function [listenerID] = getActiveListener(this)
		% Returns the active listener
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	listenerID [integer-1x1] Listener ID
		%

		if this.handle==0, error('Not connected.'); end;

		[listenerID] = VAMatlab('getActiveListener', this.handle);
	end

	function [isLooping] = getAudiofileSignalSourceIsLooping(this, signalSourceID)
		% Returns the playback state of an audiofile signal source. Available modes: PLAYING, STOPPED, PAUSED
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		%
		% Return values:
		%
		% 	isLooping [logical-1x1] Looping enabled/disabled
		%

		if this.handle==0, error('Not connected.'); end;

		[isLooping] = VAMatlab('getAudiofileSignalSourceIsLooping', this.handle, signalSourceID);
	end

	function [playState] = getAudiofileSignalSourcePlaybackState(this, signalSourceID)
		% Returns the playback state of an audiofile signal source. Available modes: PLAYING, STOPPED, PAUSED
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		%
		% Return values:
		%
		% 	playState [string] Playback state
		%

		if this.handle==0, error('Not connected.'); end;

		[playState] = VAMatlab('getAudiofileSignalSourcePlaybackState', this.handle, signalSourceID);
	end

	function [clk] = getCoreClock(this)
		% Returns the current core time
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	clk [double-1x1] Core clock time (unit: seconds)
		%

		if this.handle==0, error('Not connected.'); end;

		[clk] = VAMatlab('getCoreClock', this.handle);
	end

	function [info] = getDirectivityInfo(this, directivityID)
		% Returns information on a loaded directivity
		%
		% Parameters:
		%
		% 	directivityID [integer-1x1] Directivity ID
		%
		% Return values:
		%
		% 	info [struct-1x1] Information struct (name, filename, resolution, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getDirectivityInfo', this.handle, directivityID);
	end

	function [info] = getDirectivityInfos(this)
		% Returns information on all loaded directivities
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	info [cell-array of struct-1x1] Information structs (name, filename, resolution, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getDirectivityInfos', this.handle);
	end

	function [auralizationMode] = getGlobalAuralizationMode(this)
		% Returns the global auralization mode
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	auralizationMode [string] Auralization mode
		%

		if this.handle==0, error('Not connected.'); end;

		[auralizationMode] = VAMatlab('getGlobalAuralizationMode', this.handle);
	end

	function [info] = getHRIRDatasetInfo(this, hrirID)
		% Returns information on a loaded HRIR dataset
		%
		% Parameters:
		%
		% 	hrirID [integer-1x1] HRIR dataset ID
		%
		% Return values:
		%
		% 	info [struct-1x1] Information structs (name, filename, resolution, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getHRIRDatasetInfo', this.handle, hrirID);
	end

	function [info] = getHRIRDatasetInfos(this)
		% Returns information on all loaded HRIR datasets
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	info [cell-array of struct-1x1] Information structs (name, filename, resolution, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getHRIRDatasetInfos', this.handle);
	end

	function [gain] = getInputGain(this)
		% Returns the gain the audio device input channels
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	gain [double-1x1] Input gain (amplification factor >=0)
		%

		if this.handle==0, error('Not connected.'); end;

		[gain] = VAMatlab('getInputGain', this.handle);
	end

	function [auralizationMode] = getListenerAuralizationMode(this, listenerID)
		% Returns the auralization mode of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	auralizationMode [string] Auralization mode
		%

		if this.handle==0, error('Not connected.'); end;

		[auralizationMode] = VAMatlab('getListenerAuralizationMode', this.handle, listenerID);
	end

	function [hrirID] = getListenerHRIRDataset(this, listenerID)
		% Returns for a listener the assigned HRIR dataset
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	hrirID [integer-1x1] HRIR dataset ID
		%

		if this.handle==0, error('Not connected.'); end;

		[hrirID] = VAMatlab('getListenerHRIRDataset', this.handle, listenerID);
	end

	function [ids] = getListenerIDs(this)
		% Returns the IDs of all listeners in the scene
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	ids [integer-1xN] Vector containing the IDs
		%

		if this.handle==0, error('Not connected.'); end;

		[ids] = VAMatlab('getListenerIDs', this.handle);
	end

	function [name] = getListenerName(this, listenerID)
		% Returns name of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	name [string] Displayed name
		%

		if this.handle==0, error('Not connected.'); end;

		[name] = VAMatlab('getListenerName', this.handle, listenerID);
	end

	function [view,up] = getListenerOrientationVU(this, listenerID)
		% Returns the orientation of a listener (as view- and up-vector)
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%

		if this.handle==0, error('Not connected.'); end;

		[view,up] = VAMatlab('getListenerOrientationVU', this.handle, listenerID);
	end

	function [ypr] = getListenerOrientationYPR(this, listenerID)
		% Returns the orientation of a listener (in yaw-pitch-roll angles)
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%

		if this.handle==0, error('Not connected.'); end;

		[ypr] = VAMatlab('getListenerOrientationYPR', this.handle, listenerID);
	end

	function [params] = getListenerParameters(this, ID,args)
		% Returns the current listener parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Listener identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('getListenerParameters', this.handle, ID,args);
	end

	function [pos] = getListenerPosition(this, listenerID)
		% Returns the position of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos] = VAMatlab('getListenerPosition', this.handle, listenerID);
	end

	function [pos,view,up,velocity] = getListenerPositionOrientationVelocityVU(this, listenerID)
		% Returns the position, orientation (as view- and up vector) and velocity of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		% 	velocity [double-3] velocity vector
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up,velocity] = VAMatlab('getListenerPositionOrientationVelocityVU', this.handle, listenerID);
	end

	function [pos,ypr,velocity] = getListenerPositionOrientationVelocityYPR(this, listenerID)
		% Returns the position, orientation (in yaw-pitch-roll angles) and velocity of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		% 	velocity [double-3] velocity vector
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,ypr,velocity] = VAMatlab('getListenerPositionOrientationVelocityYPR', this.handle, listenerID);
	end

	function [pos,view,up] = getListenerPositionOrientationVU(this, listenerID)
		% Returns the position and orientation (as view- and up-vector) of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up] = VAMatlab('getListenerPositionOrientationVU', this.handle, listenerID);
	end

	function [pos,ypr] = getListenerPositionOrientationYPR(this, listenerID)
		% Returns the position and orientation (in yaw-pitch-roll angles) of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,ypr] = VAMatlab('getListenerPositionOrientationYPR', this.handle, listenerID);
	end

	function [pos,view,up] = getListenerRealWorldHeadPositionOrientationVU(this, listenerID)
		% Returns the real-world position and orientation (as view- and up vector) of the listener's head
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up] = VAMatlab('getListenerRealWorldHeadPositionOrientationVU', this.handle, listenerID);
	end

	function [gain] = getOutputGain(this)
		% Returns the global output gain
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	gain [double-1x1] Output gain (amplification factor >=0)
		%

		if this.handle==0, error('Not connected.'); end;

		[gain] = VAMatlab('getOutputGain', this.handle);
	end

	function [ids] = getPortalIDs(this)
		% Return the IDs of all portal in the scene
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	ids [integer-1xN] Vector containing the IDs
		%

		if this.handle==0, error('Not connected.'); end;

		[ids] = VAMatlab('getPortalIDs', this.handle);
	end

	function [name] = getPortalName(this, portalID)
		% Returns the name of a portal
		%
		% Parameters:
		%
		% 	portalID [integer-1x1] Portal ID
		%
		% Return values:
		%
		% 	name [string] Displayed name
		%

		if this.handle==0, error('Not connected.'); end;

		[name] = VAMatlab('getPortalName', this.handle, portalID);
	end

	function [name] = getPortalState(this, portalID)
		% Returns the state of a portal
		%
		% Parameters:
		%
		% 	portalID [integer-1x1] Portal ID
		%
		% Return values:
		%
		% 	name [double-1x1] Portal state (range [0,1] where 0 => fully closed, 1 => fully opened)
		%

		if this.handle==0, error('Not connected.'); end;

		[name] = VAMatlab('getPortalState', this.handle, portalID);
	end

	function [dGain] = getRenderingModuleGain(this, sModuleID)
		% Get rendering module output gain
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		%
		% Return values:
		%
		% 	dGain [double-1x1] Gain (scalar)
		%

		if this.handle==0, error('Not connected.'); end;

		[dGain] = VAMatlab('getRenderingModuleGain', this.handle, sModuleID);
	end

	function [dGain] = getReproductionModuleGain(this, sModuleID)
		% Returns the reproduction module output gain
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		%
		% Return values:
		%
		% 	dGain [double-1x1] Gain (scalar)
		%

		if this.handle==0, error('Not connected.'); end;

		[dGain] = VAMatlab('getReproductionModuleGain', this.handle, sModuleID);
	end

	function [info] = getSceneInfo(this)
		% Returns information on the loaded scene
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	info [struct-1x1] Information struct (name, filename, num polygons, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getSceneInfo', this.handle);
	end

	function [addr] = getServerAddress(this)
		% Returns for an opened connection the server it is connected to
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	addr [string] Server address
		%

		if this.handle==0, error('Not connected.'); end;

		[addr] = VAMatlab('getServerAddress', this.handle);
	end

	function [info] = getSignalSourceInfo(this, signalSourceID)
		% Returns information on signal source
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		%
		% Return values:
		%
		% 	info [struct-1x1] Information structs (id, name, type, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getSignalSourceInfo', this.handle, signalSourceID);
	end

	function [info] = getSignalSourceInfos(this)
		% Returns information on all existing signal sources
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	info [cell-array of struct-1x1] Information structs (id, name, type, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getSignalSourceInfos', this.handle);
	end

	function [info] = getSoundInfo(this, soundID)
		% Returns information on a loaded sound
		%
		% Parameters:
		%
		% 	soundID [integer-1x1] Sound ID
		%
		% Return values:
		%
		% 	info [struct-1x1] Information struct (name, filename, length, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getSoundInfo', this.handle, soundID);
	end

	function [info] = getSoundInfos(this)
		% Returns information on all loaded sounds
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	info [cell-array of struct-1x1] Information structs (name, filename, length, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		[info] = VAMatlab('getSoundInfos', this.handle);
	end

	function [auralizationMode] = getSoundSourceAuralizationMode(this, soundSourceID)
		% Returns the auralization mode of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	auralizationMode [string] Auralization mode
		%

		if this.handle==0, error('Not connected.'); end;

		[auralizationMode] = VAMatlab('getSoundSourceAuralizationMode', this.handle, soundSourceID);
	end

	function [directivityID] = getSoundSourceDirectivity(this, soundSourceID)
		% Returns the directivity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	directivityID [integer-1x1] Directivity ID
		%

		if this.handle==0, error('Not connected.'); end;

		[directivityID] = VAMatlab('getSoundSourceDirectivity', this.handle, soundSourceID);
	end

	function [ids] = getSoundSourceIDs(this)
		% Returns the IDs of all sound sources in the scene
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	ids [integer-1xN] Vector containing the IDs
		%

		if this.handle==0, error('Not connected.'); end;

		[ids] = VAMatlab('getSoundSourceIDs', this.handle);
	end

	function [name] = getSoundSourceName(this, soundSourceID)
		% Returns name of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	name [string] Displayed name
		%

		if this.handle==0, error('Not connected.'); end;

		[name] = VAMatlab('getSoundSourceName', this.handle, soundSourceID);
	end

	function [view,up] = getSoundSourceOrientationVU(this, soundSourceID)
		% Returns the orientation of a sound source as view- and up-vector
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	view [double-3] View vector (length: 1)
		% 	up [double-3] Up vector (length: 1)
		%

		if this.handle==0, error('Not connected.'); end;

		[view,up] = VAMatlab('getSoundSourceOrientationVU', this.handle, soundSourceID);
	end

	function [ypr] = getSoundSourceOrientationYPR(this, soundSourceID)
		% Returns the orientation of a sound source (in yaw-pitch-roll angles)
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%

		if this.handle==0, error('Not connected.'); end;

		[ypr] = VAMatlab('getSoundSourceOrientationYPR', this.handle, soundSourceID);
	end

	function [params] = getSoundSourceParameters(this, ID,args)
		% Returns the current sound source parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Sound source identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('getSoundSourceParameters', this.handle, ID,args);
	end

	function [pos] = getSoundSourcePosition(this, soundSourceID)
		% Returns the position of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos] = VAMatlab('getSoundSourcePosition', this.handle, soundSourceID);
	end

	function [pos,view,up,vel] = getSoundSourcePositionOrientationVelocityVU(this, soundSourceID)
		% Returns the position, orientation (as view- and up-vector) and velocity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector (length: 1)
		% 	up [double-3] Up vector (length: 1)
		% 	vel [double-3] Velocity vector (vx, vy, vz) (unit: meters/second)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up,vel] = VAMatlab('getSoundSourcePositionOrientationVelocityVU', this.handle, soundSourceID);
	end

	function [pos,ypr,vel] = getSoundSourcePositionOrientationVelocityYPR(this, soundSourceID)
		% Returns the position, orientation (in yaw-pitch-roll angles) and velocity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		% 	vel [double-3] Velocity vector [vx,vy,vz] (unit: meters/second)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,ypr,vel] = VAMatlab('getSoundSourcePositionOrientationVelocityYPR', this.handle, soundSourceID);
	end

	function [pos,view,up] = getSoundSourcePositionOrientationVU(this, soundSourceID)
		% Returns the position and orientation (as view- and up-vector) of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector (length: 1)
		% 	up [double-3] Up vector (length: 1)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up] = VAMatlab('getSoundSourcePositionOrientationVU', this.handle, soundSourceID);
	end

	function [pos,ypr] = getSoundSourcePositionOrientationYPR(this, soundSourceID)
		% Returns the position and orientation (in yaw-pitch-roll angles) of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,ypr] = VAMatlab('getSoundSourcePositionOrientationYPR', this.handle, soundSourceID);
	end

	function [signalSourceID] = getSoundSourceSignalSource(this, soundSourceID)
		% Returns for a sound source, the attached signal source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		[signalSourceID] = VAMatlab('getSoundSourceSignalSource', this.handle, soundSourceID);
	end

	function [volume] = getSoundSourceVolume(this, soundSourceID)
		% Returns the volume of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	volume [double-1x1] Volume
		%

		if this.handle==0, error('Not connected.'); end;

		[volume] = VAMatlab('getSoundSourceVolume', this.handle, soundSourceID);
	end

	function [result] = isInputMuted(this)
		% Returns if the audio device inputs are muted
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	result [logical-1x1] Inputs muted?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('isInputMuted', this.handle);
	end

	function [result] = isOutputMuted(this)
		% Returns if the global output is muted
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	result [logical-1x1] Output muted?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('isOutputMuted', this.handle);
	end

	function [bMuted] = isRenderingModuleMuted(this, sModuleID)
		% Is reproduction module muted?
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		%
		% Return values:
		%
		% 	bMuted [logical-1x1] true if muted, false if unmuted
		%

		if this.handle==0, error('Not connected.'); end;

		[bMuted] = VAMatlab('isRenderingModuleMuted', this.handle, sModuleID);
	end

	function [bMuted] = isReproductionModuleMuted(this, sModuleID)
		% Is reproduction module muted?
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		%
		% Return values:
		%
		% 	bMuted [logical-1x1] true if muted, false if unmuted
		%

		if this.handle==0, error('Not connected.'); end;

		[bMuted] = VAMatlab('isReproductionModuleMuted', this.handle, sModuleID);
	end

	function [result] = isSceneLoaded(this)
		% Returns if a scene is loaded
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	result [logical-1x1] Is a scene loaded?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('isSceneLoaded', this.handle);
	end

	function [result] = isSceneLocked(this)
		% Is scene locked?
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	result [logical-1x1] true, if within locked (synchronized) scene modification
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('isSceneLocked', this.handle);
	end

	function [result] = isSoundSourceMuted(this, soundSourceID)
		% Returns if a sound source is muted
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	result [logical-1x1] Muted?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('isSoundSourceMuted', this.handle, soundSourceID);
	end

	function [directivityID] = loadDirectivity(this, filename,name)
		% Loads a directivity from a file
		%
		% Parameters:
		%
		% 	filename [string] Filename
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	directivityID [integer-1x1] Directivity ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[directivityID] = VAMatlab('loadDirectivity', this.handle, filename,name);
	end

	function [id] = loadHRIRDataset(this, filename,name)
		% Loads a HRIR dataset from a file
		%
		% Parameters:
		%
		% 	filename [string] Filename
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	id [integer-1x1] HRIR dataset ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[id] = VAMatlab('loadHRIRDataset', this.handle, filename,name);
	end

	function [] = loadScene(this, filename)
		% Loads a scene from a file (e.g. RAVEN project file)
		%
		% Parameters:
		%
		% 	filename [string] Filename
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('loadScene', this.handle, filename);
	end

	function [id] = loadSound(this, filename,name)
		% Loads a sound from an audiofile
		%
		% Parameters:
		%
		% 	filename [string] Filename
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[id] = VAMatlab('loadSound', this.handle, filename,name);
	end

	function [] = lockScene(this)
		% Locks the scene (modifications of scene can be applied synchronously)
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('lockScene', this.handle);
	end

	function [id] = playSound(this, soundID,volume)
		% Plays a sound
		%
		% Parameters:
		%
		% 	soundID [integer-1x1] Sound ID
		% 	volume [double-1x1] Volume [factor] (optional, default: 1)
		%
		% Return values:
		%
		% 	id [integer-1x1] Playback ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('volume','var'), volume = 1; end
		[id] = VAMatlab('playSound', this.handle, soundID,volume);
	end

	function [result] = removeSoundPlayback(this, playbackID)
		% Removes an existing sound playback from a sequencer signal source
		%
		% Parameters:
		%
		% 	playbackID [integer-1x1] Playback ID
		%
		% Return values:
		%
		% 	result [logical-1x1] Playback removed?
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('removeSoundPlayback', this.handle, playbackID);
	end

	function [] = removeSoundSourceSignalSource(this, ID)
		% Removes the signal source of a sound source
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Sound source identifier
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('removeSoundSourceSignalSource', this.handle, ID);
	end

	function [] = reset(this)
		% Resets the VA server
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('reset', this.handle);
	end

	function [] = setActiveListener(this, listenerID)
		% Sets the active listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setActiveListener', this.handle, listenerID);
	end

	function [] = setAudiofileSignalSourceIsLooping(this, signalSourceID,isLooping)
		% Change the playback state of an audiofile signal source. Available actions: PLAY STOP PAUSE
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		% 	isLooping [logical] Set looping enabled/disabled
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setAudiofileSignalSourceIsLooping', this.handle, signalSourceID,isLooping);
	end

	function [] = setAudiofileSignalSourcePlaybackAction(this, signalSourceID,playAction)
		% Change the playback state of an audiofile signal source. Available actions: PLAY STOP PAUSE
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		% 	playAction [string] Playback action
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setAudiofileSignalSourcePlaybackAction', this.handle, signalSourceID,playAction);
	end

	function [] = setAudiofileSignalSourcePlayPosition(this, signalSourceID,playPosition)
		% Sets the playback position of an audiofile signal source.
		%
		% Parameters:
		%
		% 	signalSourceID [string] Signal source ID
		% 	playPosition [scalar] Playback position [s]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setAudiofileSignalSourcePlayPosition', this.handle, signalSourceID,playPosition);
	end

	function [] = setCoreClock(this, clk)
		% Sets the core clock time
		%
		% Parameters:
		%
		% 	clk [double-1x1] New core clock time (unit: seconds)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setCoreClock', this.handle, clk);
	end

	function [] = setGlobalAuralizationMode(this, auralizationMode)
		% Sets global auralization mode
		%
		% Parameters:
		%
		% 	auralizationMode [string] Auralization mode
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setGlobalAuralizationMode', this.handle, auralizationMode);
	end

	function [] = setInputGain(this, gain)
		% Sets the gain the audio device input channels
		%
		% Parameters:
		%
		% 	gain [double-1x1] Input gain (amplification factor >=0)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setInputGain', this.handle, gain);
	end

	function [] = setInputMuted(this, muted)
		% Sets the audio device inputs muted or unmuted
		%
		% Parameters:
		%
		% 	muted [logical-1x1] Muted?
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setInputMuted', this.handle, muted);
	end

	function [] = setListenerAuralizationMode(this, listenerID,auralizationMode)
		% Sets the auralization mode of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	auralizationMode [string] Auralization mode
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerAuralizationMode', this.handle, listenerID,auralizationMode);
	end

	function [] = setListenerHRIRDataset(this, listenerID,hrirID)
		% Set the HRIR dataset of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	hrirID [integer-1x1] HRIR dataset ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerHRIRDataset', this.handle, listenerID,hrirID);
	end

	function [] = setListenerName(this, listenerID,name)
		% Sets the name of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	name [string] Displayed name
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerName', this.handle, listenerID,name);
	end

	function [] = setListenerOrientationVU(this, listenerID,view,up)
		% Sets the orientation of a listener (as view- and up-vector)
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerOrientationVU', this.handle, listenerID,view,up);
	end

	function [] = setListenerOrientationYPR(this, listenerID,ypr)
		% Sets the orientation of a listener (in yaw-pitch-roll angles)
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerOrientationYPR', this.handle, listenerID,ypr);
	end

	function [] = setListenerParameters(this, ID,params)
		% Sets listener parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Listener identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerParameters', this.handle, ID,params);
	end

	function [] = setListenerPosition(this, listenerID,pos)
		% Sets the position of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerPosition', this.handle, listenerID,pos);
	end

	function [] = setListenerPositionOrientationVelocityVU(this, listenerID,pos,view,up,velocity)
		% Sets the position, orientation (as view- and up vector) and velocity of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] view vector
		% 	up [double-3] up vector
		% 	velocity [double-3] velocity vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerPositionOrientationVelocityVU', this.handle, listenerID,pos,view,up,velocity);
	end

	function [] = setListenerPositionOrientationVelocityYPR(this, listenerID,pos,ypr,velocity)
		% Sets the position, orientation (in yaw-pitch-roll angles) and velocity of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		% 	velocity [double-3] velocity vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerPositionOrientationVelocityYPR', this.handle, listenerID,pos,ypr,velocity);
	end

	function [] = setListenerPositionOrientationVU(this, listenerID,pos,view,up)
		% Sets the position and orientation (as view- and up vector) of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerPositionOrientationVU', this.handle, listenerID,pos,view,up);
	end

	function [] = setListenerPositionOrientationYPR(this, listenerID,pos,ypr)
		% Sets the position and orientation (in yaw-pitch-roll angles) of a listener
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerPositionOrientationYPR', this.handle, listenerID,pos,ypr);
	end

	function [] = setListenerRealWorldHeadPositionOrientationVU(this, listenerID,pos,view,up)
		% Updates the real-world position and orientation (as view- and up vector) of the listener's head
		%
		% Parameters:
		%
		% 	listenerID [integer-1x1] Listener ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setListenerRealWorldHeadPositionOrientationVU', this.handle, listenerID,pos,view,up);
	end

	function [] = setOutputGain(this, gain)
		% Sets global output gain
		%
		% Parameters:
		%
		% 	gain [double-1x1] Output gain (amplification factor >=0)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setOutputGain', this.handle, gain);
	end

	function [] = setOutputMuted(this, muted)
		% Sets the global output muted or unmuted
		%
		% Parameters:
		%
		% 	muted [logical-1x1] Output muted?
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setOutputMuted', this.handle, muted);
	end

	function [] = setPortalName(this, portalID,name)
		% Sets the name of a portal
		%
		% Parameters:
		%
		% 	portalID [integer-1x1] Portal ID
		% 	name [string] Displayed name
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setPortalName', this.handle, portalID,name);
	end

	function [] = setPortalState(this, portalID,state)
		% Sets the state of a portal
		%
		% Parameters:
		%
		% 	portalID [integer-1x1] Portal ID
		% 	state [double-1x1] Portal state (range [0,1] where 0 => fully closed, 1 => fully opened)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setPortalState', this.handle, portalID,state);
	end

	function [] = setRenderingModuleGain(this, sModuleID,dGain)
		% Sets the output gain of a reproduction module
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	dGain [double-1x1] gain (factor)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setRenderingModuleGain', this.handle, sModuleID,dGain);
	end

	function [] = setRenderingModuleMuted(this, sModuleID,bMuted)
		% Mutes a reproduction module
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	bMuted [logical-1x1] Mute (true) or unmute (false)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setRenderingModuleMuted', this.handle, sModuleID,bMuted);
	end

	function [] = setReproductionModuleGain(this, sModuleID,dGain)
		% Sets the output gain of a reproduction module
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	dGain [double-1x1] gain (factor)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setReproductionModuleGain', this.handle, sModuleID,dGain);
	end

	function [] = setReproductionModuleMuted(this, sModuleID,bMuted)
		% Mutes a reproduction module
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	bMuted [logical-1x1] Mute (true) or unmute (false)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setReproductionModuleMuted', this.handle, sModuleID,bMuted);
	end

	function [] = setSoundSourceAuralizationMode(this, soundSourceID,auralizationMode)
		% Returns the auralization mode of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	auralizationMode [string] Auralization mode
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceAuralizationMode', this.handle, soundSourceID,auralizationMode);
	end

	function [] = setSoundSourceDirectivity(this, soundSourceID,directivityID)
		% Sets the directivity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	directivityID [integer-1x1] Directivity ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceDirectivity', this.handle, soundSourceID,directivityID);
	end

	function [] = setSoundSourceMuted(this, soundSourceID,muted)
		% Sets a sound source muted or unmuted
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	muted [logical-1x1] Muted?
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceMuted', this.handle, soundSourceID,muted);
	end

	function [] = setSoundSourceName(this, soundSourceID,name)
		% Name
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	name [string] Displayed name
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceName', this.handle, soundSourceID,name);
	end

	function [] = setSoundSourceOrientationVU(this, soundSourceID,view,up)
		% Sets the orientation of a sound source (as view- and up-vector)
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceOrientationVU', this.handle, soundSourceID,view,up);
	end

	function [] = setSoundSourceOrientationYPR(this, soundSourceID,ypr)
		% Sets the orientation of a sound source (in yaw-pitch-roll angles)
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceOrientationYPR', this.handle, soundSourceID,ypr);
	end

	function [] = setSoundSourceParameters(this, ID,params)
		% Sets sound source parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Sound source identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceParameters', this.handle, ID,params);
	end

	function [] = setSoundSourcePosition(this, id,pos)
		% Sets the position of a sound source
		%
		% Parameters:
		%
		% 	id [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourcePosition', this.handle, id,pos);
	end

	function [] = setSoundSourcePositionOrientationVelocityVU(this, soundSourceID,pos,view,up,velocity)
		% Sets the position, orientation (as view- and up vector) and velocity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		% 	velocity [double-3] Velocity vector (unit: meters/second)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourcePositionOrientationVelocityVU', this.handle, soundSourceID,pos,view,up,velocity);
	end

	function [] = setSoundSourcePositionOrientationVelocityYPR(this, soundSourceID,pos,ypr,velocity)
		% Sets the position, orientation (in yaw, pitch, roll angles) and velocity of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		% 	velocity [double-3] Velocity vector (unit: meters/second)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourcePositionOrientationVelocityYPR', this.handle, soundSourceID,pos,ypr,velocity);
	end

	function [] = setSoundSourcePositionOrientationVU(this, soundSourceID,pos,view,up)
		% Sets the position and orientation (as view- and up vector) of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourcePositionOrientationVU', this.handle, soundSourceID,pos,view,up);
	end

	function [] = setSoundSourcePositionOrientationYPR(this, soundSourceID,pos,ypr)
		% Sets the position and orientation (in yaw, pitch, roll angles) of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	ypr [double-3] Rotation angles [yaw, pitch, roll] (unit: degrees, not radians!)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourcePositionOrientationYPR', this.handle, soundSourceID,pos,ypr);
	end

	function [] = setSoundSourceSignalSource(this, soundSourceID,signalSourceID)
		% Sets the signal source of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	signalSourceID [string] Signal Source ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceSignalSource', this.handle, soundSourceID,signalSourceID);
	end

	function [] = setSoundSourceVolume(this, soundSourceID,volume)
		% Sets the volume of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	volume [double-1x1] Volume
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setSoundSourceVolume', this.handle, soundSourceID,volume);
	end

	function [] = setTimer(this, period)
		% Sets up the high-precision timer
		%
		% Parameters:
		%
		% 	period [double-1x1] Timer period (unit: seconds)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('setTimer', this.handle, period);
	end

	function [newStateID] = unlockScene(this)
		% Unlocks scene and applied synchronously modifications made
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	newStateID [integer-1x1] 
		%

		if this.handle==0, error('Not connected.'); end;

		[newStateID] = VAMatlab('unlockScene', this.handle);
	end

	function [] = waitForTimer(this)
		% Wait for a signal of the high-precision timer
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('waitForTimer', this.handle);
	end


        
        function display(this)
            % TODO: Define nice behaviour
%             if this.handle
%                 fprintf('Connection established to server ''%s''\n', this.getServerAddress())
%             else
%                 fprintf('Not connected\n');
%             end
        end
        
    end

end
