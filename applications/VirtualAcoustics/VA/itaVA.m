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
    %   See also: itaVA_example_simple, itaVA_example_tracked_sound_receiver,
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
    %     sourceID = va.create_sound_source( 'My Matlab virtual sound source' )
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
        
        function [version] = get_version()
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

            version = VAMatlab('get_version');
        end
        
         function [] = set_verbose_mode(mode)
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

            VAMatlab('set_verbose_mode', mode);
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
       
        function [connected] = get_connected(this)
            % Returns if a connection to a server is established
           connected = VAMatlab('get_connected', this.handle);
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
           
        function [state] = get_server_state(this)
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
            state = VAMatlab('get_server_state', this.handle);
        end
        
        function connect_tracker( this, remote_ip, local_ip )
            % Connects to a local NatNet tracking server
            % 
            % The server will update a virtual sound receiver for real-time 
            % sound synthesis and the real world sound receiver position for
            % those sound reproductions that need this information, like  
            % Crosstalk-Cancellation.
            %
            % See also set_tracked_sound_receiver.
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

            VAMatlab( 'connect_tracker', this.handle, remote_ip, local_ip );
        end
        
        function [connected] = get_tracker_connected( this )
            % Returns true, if tracker is connected
            connected = VAMatlab( 'get_tracker_connected', this.handle );
        end
        
        function disconnect_tracker( this )
            % Disconnects from the NatNet tracking server
            VAMatlab( 'disconnect_tracker', this.handle )
        end
        
		% -- Tracked sound receiver -- %
		
        function set_tracked_sound_receiver( this, sound_receiver_id )
            % Connects a VA sound receiver with the tracked sound receiver rigid body
            %
            % Parameters:
            %
            % 	sound_receiver_id  [integer-1x1]   VA sound receiver id
            %
            VAMatlab( 'set_tracked_sound_receiver', this.handle, sound_receiver_id );
        end
        
        function set_tracked_sound_receiver_head_rigid_body_index( this, index )
            % Sets the index of the rigid body to be tracked for sound receiver (default is 1)
            VAMatlab( 'set_tracked_sound_receiver_head_rigid_body_index', this.handle, index )
        end
        
        function set_tracked_sound_receiver_torso_rigid_body_index( this, index )
            % Sets the index of the rigid body to be tracked for sound receiver's absolute torso orientation (default is 1)
            VAMatlab( 'set_tracked_sound_receiver_torso_rigid_body_index', this.handle, index )
        end
        
        function set_tracked_sound_receiver_head_rigid_body_translation( this, translation )
            % Sets the pivot point translation for the tracked sound receiver rigid body
			%
			% Parameters:
			%
			%	translation [double-3x1]	Translation in local coordinate system of rigid body [m]
			%
            VAMatlab( 'set_tracked_sound_receiver_head_rigid_body_translation', this.handle, translation )
        end
        
        function set_tracked_sound_receiver_head_rigid_body_rotation( this, rotation )
            % Sets the rotation of orientation for the tracked sound receiver rigid body
			%
			% Given rotation has to be a Matlab quaternion type (order: w(real), i, j, k)
			%
			% Parameters:
			%
			%	rotation [quaternion]	Rotation of rigid body
			%
            VAMatlab( 'set_tracked_sound_receiver_head_rigid_body_rotation', this.handle, rotation )
        end
		
		% -- Tracked real-world sound receiver -- %
		
        function set_tracked_real_world_sound_receiver( this, sound_receiver_id )
            % Connects a VA real-world sound receiver with the tracked real-world rigid body
            %
            % Parameters:
            %
            % 	sound_receiver_id  [integer-1x1]   VA real-world sound receiver id
            %
            VAMatlab( 'set_tracked_real_world_sound_receiver', this.handle, sound_receiver_id );
        end
		
        function set_tracked_real_world_sound_receiver_head_rigid_body_index( this, index )
            % Sets the index of the rigid body to be tracked for real-world sound receiver (default is 1)
            VAMatlab( 'set_tracked_real_world_sound_receiver_rigid_body_index', this.handle, index )
        end
		
        function set_tracked_real_world_sound_receiver_torso_rigid_body_index( this, index )
            % Sets the index of the rigid body to be tracked for real-world sound receiver' torso (default is 1)
            VAMatlab( 'set_tracked_real_world_sound_receiver_torso_rigid_body_index', this.handle, index )
        end
        
        function set_tracked_real_world_sound_receiver_head_rigid_body_translation( this, translation )
            % Sets the pivot point translation for the tracked real-world sound receiver rigid body
			%
			% Parameters:
			%
			%	translation [double-3x1]	Translation in local coordinate system of rigid body [m]
			%
            VAMatlab( 'set_tracked_real_world_sound_receiver_head_rigid_body_translation', this.handle, translation )
        end
        
        function set_tracked_real_world_sound_receiver_head_rigid_body_rotation( this, rotation )
            % Sets the rotation of orientation for the tracked real-world sound receiver rigid body
			%
			% Given rotation has to be a Matlab quaternion type (order: w(real), i, j, k)
			%
			% Parameters:
			%
			%	rotation [quaternion]	Rotation of rigid body
			%
            VAMatlab( 'set_tracked_real_world_sound_receiver_head_rigid_body_rotation', this.handle, rotation )
        end
		        
		% -- Tracked source -- %
		
        function set_tracked_sound_source( this, source_id )
            % Connects a VA source with the tracked source rigid body
            %
            % Parameters:
            %
            % 	source_id  [integer-1x1]   VA source id
            %
            VAMatlab( 'set_tracked_sound_source', this.handle, source_id );
        end
		
        function set_tracked_source_rigid_body_index( this, index )
            % Sets the index of the rigid body to be tracked for source (default is 1)
            VAMatlab( 'set_tracked_source_rigid_body_index', this.handle, index )
        end
        
        function set_tracked_source_rigid_body_translation( this, translation )
            % Sets the pivot point translation for the tracked source rigid body
			%
			% Parameters:
			%
			%	translation [double-3x1]	Translation in local coordinate system of rigid body [m]
			%
            VAMatlab( 'set_tracked_source_rigid_body_translation', this.handle, translation )
        end
        
        function set_tracked_source_rigid_body_rotation( this, rotation )
            % Sets the rotation of orientation for the tracked source rigid body
			%
			% Given rotation has to be a Matlab quaternion type (order: w(real), i, j, k)
			%
			% Parameters:
			%
			%	rotation [quaternion]	Rotation of rigid body
			%
            VAMatlab( 'set_tracked_source_rigid_body_rotation', this.handle, rotation )
        end
		
        
        %% --= Functions =--
        
        	function [valid] = add_search_path(this, path)
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

		[valid] = VAMatlab('add_search_path', this.handle, path);
	end

	function [ret] = call_module(this, module,mstruct)
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

		[ret] = VAMatlab('call_module', this.handle, module,mstruct);
	end

	function [material_id] = create_acoustic_material_from_file(this, file_path,material_name)
		% Create acoustic material
		%
		% Parameters:
		%
		% 	file_path [string] Material file path
		% 	material_name [string] Material name (optional, default: '')
		%
		% Return values:
		%
		% 	material_id [double-1x1] Material identifier
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('material_name','var'), material_name = ''; end
		[material_id] = VAMatlab('create_acoustic_material_from_file', this.handle, file_path,material_name);
	end

	function [directivityID] = create_directivity(this, filename,name)
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
		[directivityID] = VAMatlab('create_directivity', this.handle, filename,name);
	end

	function [geo_mesh_id] = create_geometry_mesh_from_file(this, file_path,geo_mesh_name)
		% Create geometry mesh from file
		%
		% Parameters:
		%
		% 	file_path [string] Geometry mesh file path
		% 	geo_mesh_name [string] Geometry mesh name (optional, default: '')
		%
		% Return values:
		%
		% 	geo_mesh_id [double-1x1] Geometry mesh identifier
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('geo_mesh_name','var'), geo_mesh_name = ''; end
		[geo_mesh_id] = VAMatlab('create_geometry_mesh_from_file', this.handle, file_path,geo_mesh_name);
	end

	function [signalSourceID] = create_signal_source_buffer_from_file(this, filename,name)
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
		[signalSourceID] = VAMatlab('create_signal_source_buffer_from_file', this.handle, filename,name);
	end

	function [signalSourceID] = create_signal_source_buffer_from_parameters(this, params,name)
		% Creates an buffer signal source
		%
		% Parameters:
		%
		% 	params [struct] Parameters
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('create_signal_source_buffer_from_parameters', this.handle, params,name);
	end

	function [signalSourceID] = create_signal_source_engine(this, params,name)
		% Creates an engine signal source
		%
		% Parameters:
		%
		% 	params [struct] Parameters
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	signalSourceID [string] Signal source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[signalSourceID] = VAMatlab('create_signal_source_engine', this.handle, params,name);
	end

	function [signalSourceID] = create_signal_source_network_stream(this, address,port,name)
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
		[signalSourceID] = VAMatlab('create_signal_source_network_stream', this.handle, address,port,name);
	end

	function [signalSourceID] = create_signal_source_sequencer(this, name)
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
		[signalSourceID] = VAMatlab('create_signal_source_sequencer', this.handle, name);
	end

	function [signalSourceID] = create_signal_source_text_to_speech(this, name)
		% Creates a text to speech signal
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
		[signalSourceID] = VAMatlab('create_signal_source_text_to_speech', this.handle, name);
	end

	function [id] = create_sound_receiver(this, name)
		% Creates a sound receiver
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound receiver ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[id] = VAMatlab('create_sound_receiver', this.handle, name);
	end

	function [id] = create_sound_source(this, name)
		% Creates a sound source
		%
		% Parameters:
		%
		% 	name [string] Displayed name (optional, default: '')
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound source ID
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('name','var'), name = ''; end
		[id] = VAMatlab('create_sound_source', this.handle, name);
	end

	function [id] = create_sound_source_explicit_renderer(this, renderer,name)
		% Creates a sound source explicitly for a certain renderer
		%
		% Parameters:
		%
		% 	renderer [string] Renderer identifier
		% 	name [string] Name
		%
		% Return values:
		%
		% 	id [integer-1x1] Sound source ID
		%

		if this.handle==0, error('Not connected.'); end;

		[id] = VAMatlab('create_sound_source_explicit_renderer', this.handle, renderer,name);
	end

	function [success_flag] = delete_acoustic_material(this, material_id)
		% Delete acoustic material
		%
		% Parameters:
		%
		% 	material_id [double-1x1] Material identifier
		%
		% Return values:
		%
		% 	success_flag [logical-1x1] Removal success
		%

		if this.handle==0, error('Not connected.'); end;

		[success_flag] = VAMatlab('delete_acoustic_material', this.handle, material_id);
	end

	function [result] = delete_directivity(this, directivityID)
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

		[result] = VAMatlab('delete_directivity', this.handle, directivityID);
	end

	function [success_flag] = delete_geometry_mesh(this, geo_mesh_id)
		% Delete geometry mesh
		%
		% Parameters:
		%
		% 	geo_mesh_id [double-1x1] Geometry mesh identifier
		%
		% Return values:
		%
		% 	success_flag [logical-1x1] Removal success
		%

		if this.handle==0, error('Not connected.'); end;

		[success_flag] = VAMatlab('delete_geometry_mesh', this.handle, geo_mesh_id);
	end

	function [result] = delete_signal_source(this, signalSourceID)
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

		[result] = VAMatlab('delete_signal_source', this.handle, signalSourceID);
	end

	function [] = delete_sound_receiver(this, soundreceiverID)
		% Deletes a sound receiver from the scene
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('delete_sound_receiver', this.handle, soundreceiverID);
	end

	function [] = delete_sound_source(this, soundSourceID)
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

		VAMatlab('delete_sound_source', this.handle, soundSourceID);
	end

	function [params] = get_acoustic_magerial_parameters(this, material_id,args)
		% Acoustic material parameter getter
		%
		% Parameters:
		%
		% 	material_id [integer-1x1] Acoustic material identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_acoustic_magerial_parameters', this.handle, material_id,args);
	end

	function [soundreceiverID] = get_active_sound_receiver(this)
		% Returns the active sound receiver
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%

		if this.handle==0, error('Not connected.'); end;

		[soundreceiverID] = VAMatlab('get_active_sound_receiver', this.handle);
	end

	function [clk] = get_core_clock(this)
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

		[clk] = VAMatlab('get_core_clock', this.handle);
	end

	function [info] = get_directivity_info(this, directivityID)
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

		[info] = VAMatlab('get_directivity_info', this.handle, directivityID);
	end

	function [info] = get_directivity_infos(this)
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

		[info] = VAMatlab('get_directivity_infos', this.handle);
	end

	function [result] = get_geometry_mesh_enabled(this, geo_mesh_id)
		% Geometry mesh enabled getter
		%
		% Parameters:
		%
		% 	geo_mesh_id [integer-1x1] Geometry mesh identifier
		%
		% Return values:
		%
		% 	result [logical-1x1] Enabled flag
		%

		if this.handle==0, error('Not connected.'); end;

		[result] = VAMatlab('get_geometry_mesh_enabled', this.handle, geo_mesh_id);
	end

	function [params] = get_geometry_mesh_parameters(this, geo_mesh_id,args)
		% Geometry mesh parameter getter
		%
		% Parameters:
		%
		% 	geo_mesh_id [integer-1x1] Geometry mesh identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_geometry_mesh_parameters', this.handle, geo_mesh_id,args);
	end

	function [auralizationMode] = get_global_auralization_mode(this)
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

		[auralizationMode] = VAMatlab('get_global_auralization_mode', this.handle);
	end

	function [shift_speed] = get_homogeneous_medium_relative_humidity(this)
		% Get homogeneous medium relative humidity
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	shift_speed [double-1x1] Relative humidity [Percent]
		%

		if this.handle==0, error('Not connected.'); end;

		[shift_speed] = VAMatlab('get_homogeneous_medium_relative_humidity', this.handle);
	end

	function [params] = get_homogeneous_medium_shift_parameters(this, args)
		% Returns homogeneous medium parameters
		%
		% Parameters:
		%
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_homogeneous_medium_shift_parameters', this.handle, args);
	end

	function [shift_speed] = get_homogeneous_medium_shift_speed(this)
		% Get homogeneous medium shift speed
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	shift_speed [double-3x1] Shift speed vector [m/s]
		%

		if this.handle==0, error('Not connected.'); end;

		[shift_speed] = VAMatlab('get_homogeneous_medium_shift_speed', this.handle);
	end

	function [sound_speed] = get_homogeneous_medium_sound_speed(this)
		% Get homogeneous medium sound speed
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	sound_speed [double-1x1] Sound speed [m/s]
		%

		if this.handle==0, error('Not connected.'); end;

		[sound_speed] = VAMatlab('get_homogeneous_medium_sound_speed', this.handle);
	end

	function [static_pressure] = get_homogeneous_medium_static_pressure(this)
		% Get homogeneous medium static pressure
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	static_pressure [double-1x1] Static pressure [Pa]
		%

		if this.handle==0, error('Not connected.'); end;

		[static_pressure] = VAMatlab('get_homogeneous_medium_static_pressure', this.handle);
	end

	function [temperature] = get_homogeneous_medium_temperature(this)
		% Get homogeneous medium temperature
		%
		% Parameters:
		%
		% 	None
		%
		% Return values:
		%
		% 	temperature [double-1x1] Temperature [degree Celsius]
		%

		if this.handle==0, error('Not connected.'); end;

		[temperature] = VAMatlab('get_homogeneous_medium_temperature', this.handle);
	end

	function [gain] = get_input_gain(this)
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

		[gain] = VAMatlab('get_input_gain', this.handle);
	end

	function [result] = get_input_muted(this)
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

		[result] = VAMatlab('get_input_muted', this.handle);
	end

	function [modules] = get_modules(this)
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

		[modules] = VAMatlab('get_modules', this.handle);
	end

	function [gain] = get_output_gain(this)
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

		[gain] = VAMatlab('get_output_gain', this.handle);
	end

	function [result] = get_output_muted(this)
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

		[result] = VAMatlab('get_output_muted', this.handle);
	end

	function [renderers] = get_rendering_modules(this, bFilterEnabled)
		% Get list of rendering modules
		%
		% Parameters:
		%
		% 	bFilterEnabled [boolean-1x1] Filter activated (true) (optional, default: 1)
		%
		% Return values:
		%
		% 	renderers [cell-array of struct-1x1] Renderer infos (names, descriptions, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('bFilterEnabled','var'), bFilterEnabled = 1; end
		[renderers] = VAMatlab('get_rendering_modules', this.handle, bFilterEnabled);
	end

	function [auralization_mode] = get_rendering_module_auralization_mode(this, sModuleID)
		% Returns the current rendering module parameters
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		%
		% Return values:
		%
		% 	auralization_mode [string] Auralization mode as string
		%

		if this.handle==0, error('Not connected.'); end;

		[auralization_mode] = VAMatlab('get_rendering_module_auralization_mode', this.handle, sModuleID);
	end

	function [dGain] = get_rendering_module_gain(this, sModuleID)
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

		[dGain] = VAMatlab('get_rendering_module_gain', this.handle, sModuleID);
	end

	function [bMuted] = get_rendering_module_muted(this, sModuleID)
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

		[bMuted] = VAMatlab('get_rendering_module_muted', this.handle, sModuleID);
	end

	function [params] = get_rendering_module_parameters(this, sModuleID,args)
		% Returns the current rendering module parameters
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_rendering_module_parameters', this.handle, sModuleID,args);
	end

	function [reproductionmodules] = get_reproduction_modules(this, bFilterEnabled)
		% Get list of rendering modules
		%
		% Parameters:
		%
		% 	bFilterEnabled [boolean-1x1] Filter activated (true) (optional, default: 1)
		%
		% Return values:
		%
		% 	reproductionmodules [cell-array of struct-1x1] Reproduction module infos (names, descriptions, etc.)
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('bFilterEnabled','var'), bFilterEnabled = 1; end
		[reproductionmodules] = VAMatlab('get_reproduction_modules', this.handle, bFilterEnabled);
	end

	function [dGain] = get_reproduction_module_gain(this, sModuleID)
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

		[dGain] = VAMatlab('get_reproduction_module_gain', this.handle, sModuleID);
	end

	function [bMuted] = get_reproduction_module_muted(this, sModuleID)
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

		[bMuted] = VAMatlab('get_reproduction_module_muted', this.handle, sModuleID);
	end

	function [params] = get_reproduction_module_parameters(this, sModuleID,args)
		% Returns the current reproduction module parameters
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_reproduction_module_parameters', this.handle, sModuleID,args);
	end

	function [addr] = get_server_address(this)
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

		[addr] = VAMatlab('get_server_address', this.handle);
	end

	function [isLooping] = get_signal_source_buffer_looping(this, signalSourceID)
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

		[isLooping] = VAMatlab('get_signal_source_buffer_looping', this.handle, signalSourceID);
	end

	function [playState] = get_signal_source_buffer_playback_state(this, signalSourceID)
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

		[playState] = VAMatlab('get_signal_source_buffer_playback_state', this.handle, signalSourceID);
	end

	function [info] = get_signal_source_info(this, signalSourceID)
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

		[info] = VAMatlab('get_signal_source_info', this.handle, signalSourceID);
	end

	function [info] = get_signal_source_infos(this)
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

		[info] = VAMatlab('get_signal_source_infos', this.handle);
	end

	function [params] = get_signal_source_parameters(this, ID,args)
		% Returns the current signal source parameters
		%
		% Parameters:
		%
		% 	ID [string] Signal source identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_signal_source_parameters', this.handle, ID,args);
	end

	function [ids] = get_sound_portal_ids(this)
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

		[ids] = VAMatlab('get_sound_portal_ids', this.handle);
	end

	function [name] = get_sound_portal_name(this, portalID)
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

		[name] = VAMatlab('get_sound_portal_name', this.handle, portalID);
	end

	function [auralizationMode] = get_sound_receiver_auralization_mode(this, soundreceiverID)
		% Returns the auralization mode of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	auralizationMode [string] Auralization mode
		%

		if this.handle==0, error('Not connected.'); end;

		[auralizationMode] = VAMatlab('get_sound_receiver_auralization_mode', this.handle, soundreceiverID);
	end

	function [directivityID] = get_sound_receiver_directivity(this, soundreceiverID)
		% Returns for a sound receiver the assigned directivity
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	directivityID [integer-1x1] Directivity ID
		%

		if this.handle==0, error('Not connected.'); end;

		[directivityID] = VAMatlab('get_sound_receiver_directivity', this.handle, soundreceiverID);
	end

	function [orient] = get_sound_receiver_head_above_torso_orientation(this, soundreceiverID)
		% Returns the head-above-torso (relative) orientation of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	orient [double-4] Rotation angles [w,x,y,z]
		%

		if this.handle==0, error('Not connected.'); end;

		[orient] = VAMatlab('get_sound_receiver_head_above_torso_orientation', this.handle, soundreceiverID);
	end

	function [ids] = get_sound_receiver_ids(this)
		% Returns the IDs of all sound receivers in the scene
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

		[ids] = VAMatlab('get_sound_receiver_ids', this.handle);
	end

	function [name] = get_sound_receiver_name(this, soundreceiverID)
		% Returns name of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	name [string] Displayed name
		%

		if this.handle==0, error('Not connected.'); end;

		[name] = VAMatlab('get_sound_receiver_name', this.handle, soundreceiverID);
	end

	function [orient] = get_sound_receiver_orientation(this, soundreceiverID)
		% Returns the orientation of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	orient [double-4] Rotation angles [w,x,y,z]
		%

		if this.handle==0, error('Not connected.'); end;

		[orient] = VAMatlab('get_sound_receiver_orientation', this.handle, soundreceiverID);
	end

	function [view,up] = get_sound_receiver_orientation_view_up(this, soundreceiverID)
		% Returns the orientation of a sound receiver (as view- and up-vector)
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%

		if this.handle==0, error('Not connected.'); end;

		[view,up] = VAMatlab('get_sound_receiver_orientation_view_up', this.handle, soundreceiverID);
	end

	function [params] = get_sound_receiver_parameters(this, ID,args)
		% Returns the current sound receiver parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Sound receiver identifier
		% 	args [mstruct] Requested parameters
		%
		% Return values:
		%
		% 	params [mstruct] Parameters
		%

		if this.handle==0, error('Not connected.'); end;

		[params] = VAMatlab('get_sound_receiver_parameters', this.handle, ID,args);
	end

	function [pos,ypr] = get_sound_receiver_pose(this, soundreceiverID)
		% Returns the position and orientation of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	ypr [double-4] Rotation quaternion [w,x,y,z]
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,ypr] = VAMatlab('get_sound_receiver_pose', this.handle, soundreceiverID);
	end

	function [pos] = get_sound_receiver_position(this, soundreceiverID)
		% Returns the position of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos] = VAMatlab('get_sound_receiver_position', this.handle, soundreceiverID);
	end

	function [view] = get_sound_receiver_real_world_head_above_torso_orientation(this, soundreceiverID)
		% Returns the real-world orientation (as quaterion) of the sound receiver's head over the torso
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	view [double-4] Rotation quaternion [w,x,y,z]
		%

		if this.handle==0, error('Not connected.'); end;

		[view] = VAMatlab('get_sound_receiver_real_world_head_above_torso_orientation', this.handle, soundreceiverID);
	end

	function [pos,view,up] = get_sound_receiver_real_world_head_position_orientation_view_up(this, soundreceiverID)
		% Returns the real-world position and orientation (as view- and up vector) of the sound receiver's head
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,view,up] = VAMatlab('get_sound_receiver_real_world_head_position_orientation_view_up', this.handle, soundreceiverID);
	end

	function [auralizationMode] = get_sound_source_auralization_mode(this, soundSourceID)
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

		[auralizationMode] = VAMatlab('get_sound_source_auralization_mode', this.handle, soundSourceID);
	end

	function [directivityID] = get_sound_source_directivity(this, soundSourceID)
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

		[directivityID] = VAMatlab('get_sound_source_directivity', this.handle, soundSourceID);
	end

	function [ids] = get_sound_source_ids(this)
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

		[ids] = VAMatlab('get_sound_source_ids', this.handle);
	end

	function [result] = get_sound_source_muted(this, soundSourceID)
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

		[result] = VAMatlab('get_sound_source_muted', this.handle, soundSourceID);
	end

	function [name] = get_sound_source_name(this, soundSourceID)
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

		[name] = VAMatlab('get_sound_source_name', this.handle, soundSourceID);
	end

	function [orient] = get_sound_source_orientation(this, soundSourceID)
		% Returns the orientation of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	orient [double-4] Rotation as quaternion (w,x,y,z)
		%

		if this.handle==0, error('Not connected.'); end;

		[orient] = VAMatlab('get_sound_source_orientation', this.handle, soundSourceID);
	end

	function [view,up] = get_sound_source_orientation_view_up(this, soundSourceID)
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

		[view,up] = VAMatlab('get_sound_source_orientation_view_up', this.handle, soundSourceID);
	end

	function [params] = get_sound_source_parameters(this, ID,args)
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

		[params] = VAMatlab('get_sound_source_parameters', this.handle, ID,args);
	end

	function [pos,orient] = get_sound_source_pose(this, soundSourceID)
		% Returns the position and orientation of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		% 	orient [double-4] Rotation quaternion (w,x,y,z)
		%

		if this.handle==0, error('Not connected.'); end;

		[pos,orient] = VAMatlab('get_sound_source_pose', this.handle, soundSourceID);
	end

	function [pos] = get_sound_source_position(this, soundSourceID)
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

		[pos] = VAMatlab('get_sound_source_position', this.handle, soundSourceID);
	end

	function [signalSourceID] = get_sound_source_signal_source(this, soundSourceID)
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

		[signalSourceID] = VAMatlab('get_sound_source_signal_source', this.handle, soundSourceID);
	end

	function [volume] = get_sound_source_sound_power(this, soundSourceID)
		% Returns the volume of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		%
		% Return values:
		%
		% 	volume [double-1x1] Sound source power
		%

		if this.handle==0, error('Not connected.'); end;

		[volume] = VAMatlab('get_sound_source_sound_power', this.handle, soundSourceID);
	end

	function [result] = get_update_locked(this)
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

		[result] = VAMatlab('get_update_locked', this.handle);
	end

	function [] = lock_update(this)
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

		VAMatlab('lock_update', this.handle);
	end

	function [] = remove_sound_source_signal_source(this, ID)
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

		VAMatlab('remove_sound_source_signal_source', this.handle, ID);
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

	function [] = set_acoustic_magerial_parameters(this, material_id,params)
		% Acoustic material parameter setter
		%
		% Parameters:
		%
		% 	material_id [integer-1x1] Acoustic material identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_acoustic_magerial_parameters', this.handle, material_id,params);
	end

	function [] = set_active_sound_receiver(this, soundreceiverID)
		% Sets the active sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_active_sound_receiver', this.handle, soundreceiverID);
	end

	function [] = set_core_clock(this, clk)
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

		VAMatlab('set_core_clock', this.handle, clk);
	end

	function [] = set_geometry_mesh_enabled(this, geo_mesh_id,enabled)
		% Geometry mesh enabled setter
		%
		% Parameters:
		%
		% 	geo_mesh_id [integer-1x1] Geometry mesh identifier
		% 	enabled [logical-1x1] Enabled flag (optional, default: 1)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		if ~exist('enabled','var'), enabled = 1; end
		VAMatlab('set_geometry_mesh_enabled', this.handle, geo_mesh_id,enabled);
	end

	function [] = set_geometry_mesh_parameters(this, geo_mesh_id,params)
		% Geometry mesh parameter setter
		%
		% Parameters:
		%
		% 	geo_mesh_id [integer-1x1] Geometry mesh identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_geometry_mesh_parameters', this.handle, geo_mesh_id,params);
	end

	function [] = set_global_auralization_mode(this, auralizationMode)
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

		VAMatlab('set_global_auralization_mode', this.handle, auralizationMode);
	end

	function [] = set_homogeneous_medium_relative_humidity(this, shift_speed)
		% Set homogeneous medium relative humidity
		%
		% Parameters:
		%
		% 	shift_speed [double-1x1] Relative humidity [Percent]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_relative_humidity', this.handle, shift_speed);
	end

	function [] = set_homogeneous_medium_shift_parameters(this, params)
		% Sets homogeneous medium parameters
		%
		% Parameters:
		%
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_shift_parameters', this.handle, params);
	end

	function [] = set_homogeneous_medium_shift_speed(this, shift_speed)
		% Set homogeneous medium shift speed
		%
		% Parameters:
		%
		% 	shift_speed [double-3x1] Shift speed vector [m/s]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_shift_speed', this.handle, shift_speed);
	end

	function [] = set_homogeneous_medium_sound_speed(this, sound_speed)
		% Set homogeneous medium sound speed
		%
		% Parameters:
		%
		% 	sound_speed [double-1x1] Sound speed [m/s]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_sound_speed', this.handle, sound_speed);
	end

	function [] = set_homogeneous_medium_static_pressure(this, static_pressure)
		% Set homogeneous medium static pressure
		%
		% Parameters:
		%
		% 	static_pressure [double-1x1] Static pressure [Pa]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_static_pressure', this.handle, static_pressure);
	end

	function [] = set_homogeneous_medium_temperature(this, temperature)
		% Set homogeneous medium temperature
		%
		% Parameters:
		%
		% 	temperature [double-1x1] Temperature [degree Celsius]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_homogeneous_medium_temperature', this.handle, temperature);
	end

	function [] = set_input_gain(this, gain)
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

		VAMatlab('set_input_gain', this.handle, gain);
	end

	function [] = set_input_muted(this, muted)
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

		VAMatlab('set_input_muted', this.handle, muted);
	end

	function [] = set_output_gain(this, gain)
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

		VAMatlab('set_output_gain', this.handle, gain);
	end

	function [] = set_output_muted(this, muted)
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

		VAMatlab('set_output_muted', this.handle, muted);
	end

	function [] = set_rendering_module_auralization_mode(this, sModuleID,am_str)
		% Sets the output gain of a reproduction module
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	am_str [string] auralization mode string
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_rendering_module_auralization_mode', this.handle, sModuleID,am_str);
	end

	function [] = set_rendering_module_gain(this, sModuleID,dGain)
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

		VAMatlab('set_rendering_module_gain', this.handle, sModuleID,dGain);
	end

	function [] = set_rendering_module_muted(this, sModuleID,bMuted)
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

		VAMatlab('set_rendering_module_muted', this.handle, sModuleID,bMuted);
	end

	function [] = set_rendering_module_parameters(this, sModuleID,params)
		% Sets rendering module parameters
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_rendering_module_parameters', this.handle, sModuleID,params);
	end

	function [] = set_reproduction_module_gain(this, sModuleID,dGain)
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

		VAMatlab('set_reproduction_module_gain', this.handle, sModuleID,dGain);
	end

	function [] = set_reproduction_module_muted(this, sModuleID,bMuted)
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

		VAMatlab('set_reproduction_module_muted', this.handle, sModuleID,bMuted);
	end

	function [] = set_reproduction_module_parameters(this, sModuleID,params)
		% Sets reproduction module parameters
		%
		% Parameters:
		%
		% 	sModuleID [string] Module identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_reproduction_module_parameters', this.handle, sModuleID,params);
	end

	function [] = set_signal_source_buffer_looping(this, signalSourceID,isLooping)
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

		VAMatlab('set_signal_source_buffer_looping', this.handle, signalSourceID,isLooping);
	end

	function [] = set_signal_source_buffer_playback_action(this, signalSourceID,playAction)
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

		VAMatlab('set_signal_source_buffer_playback_action', this.handle, signalSourceID,playAction);
	end

	function [] = set_signal_source_buffer_playback_position(this, signalSourceID,playPosition)
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

		VAMatlab('set_signal_source_buffer_playback_position', this.handle, signalSourceID,playPosition);
	end

	function [] = set_signal_source_parameters(this, ID,params)
		% Sets signal source parameters
		%
		% Parameters:
		%
		% 	ID [string] Signal source identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_signal_source_parameters', this.handle, ID,params);
	end

	function [] = set_sound_portal_name(this, portalID,name)
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

		VAMatlab('set_sound_portal_name', this.handle, portalID,name);
	end

	function [] = set_sound_receiver_auralization_mode(this, soundreceiverID,auralizationMode)
		% Sets the auralization mode of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	auralizationMode [string] Auralization mode
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_auralization_mode', this.handle, soundreceiverID,auralizationMode);
	end

	function [] = set_sound_receiver_directivity(this, soundreceiverID,directivityID)
		% Set the directivity of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	directivityID [integer-1x1] HRIR dataset ID
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_directivity', this.handle, soundreceiverID,directivityID);
	end

	function [] = set_sound_receiver_head_above_torso_orientation(this, soundreceiverID,orient)
		% Sets the head-above-torso (relative) orientation of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	orient [double-4] Rotation quaternion [w,x,y,z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_head_above_torso_orientation', this.handle, soundreceiverID,orient);
	end

	function [] = set_sound_receiver_name(this, soundreceiverID,name)
		% Sets the name of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	name [string] Displayed name
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_name', this.handle, soundreceiverID,name);
	end

	function [] = set_sound_receiver_orientation(this, soundreceiverID,orient)
		% Sets the orientation of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	orient [double-4] Rotation quaternion [w,x,y,z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_orientation', this.handle, soundreceiverID,orient);
	end

	function [] = set_sound_receiver_orientation_view_up(this, soundreceiverID,view,up)
		% Sets the orientation of a sound receiver (as view- and up-vector)
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_orientation_view_up', this.handle, soundreceiverID,view,up);
	end

	function [] = set_sound_receiver_parameters(this, ID,params)
		% Sets sound receiver parameters
		%
		% Parameters:
		%
		% 	ID [integer-1x1] Sound receiver identifier
		% 	params [mstruct] Parameters
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_parameters', this.handle, ID,params);
	end

	function [] = set_sound_receiver_pose(this, soundreceiverID,pos,ypr)
		% Sets the position and orientation (in yaw-pitch-roll angles) of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	ypr [double-4] Rotation angles [w,x,y,z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_pose', this.handle, soundreceiverID,pos,ypr);
	end

	function [] = set_sound_receiver_position(this, soundreceiverID,pos)
		% Sets the position of a sound receiver
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	pos [double-3] Position vector [x,y,z] (unit: meters)
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_position', this.handle, soundreceiverID,pos);
	end

	function [] = set_sound_receiver_real_world_head_above_torso_orientation(this, soundreceiverID,pos)
		% Updates the real-world position and orientation (as view- and up vector) of the sound receiver's head
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	pos [double-4] Rotation quaternion [w, x, y, z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_real_world_head_above_torso_orientation', this.handle, soundreceiverID,pos);
	end

	function [] = set_sound_receiver_real_world_position_orientation_view_up(this, soundreceiverID,pos,view,up)
		% Updates the real-world position and orientation (as view- and up vector) of the sound receiver's head
		%
		% Parameters:
		%
		% 	soundreceiverID [integer-1x1] Sound receiver ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	view [double-3] View vector
		% 	up [double-3] Up vector
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_receiver_real_world_position_orientation_view_up', this.handle, soundreceiverID,pos,view,up);
	end

	function [] = set_sound_source_auralization_mode(this, soundSourceID,auralizationMode)
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

		VAMatlab('set_sound_source_auralization_mode', this.handle, soundSourceID,auralizationMode);
	end

	function [] = set_sound_source_directivity(this, soundSourceID,directivityID)
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

		VAMatlab('set_sound_source_directivity', this.handle, soundSourceID,directivityID);
	end

	function [] = set_sound_source_muted(this, soundSourceID,muted)
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

		VAMatlab('set_sound_source_muted', this.handle, soundSourceID,muted);
	end

	function [] = set_sound_source_name(this, soundSourceID,name)
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

		VAMatlab('set_sound_source_name', this.handle, soundSourceID,name);
	end

	function [] = set_sound_source_orientation(this, soundSourceID,orient)
		% Sets the orientation of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	orient [double-4] Rotation quaterion [w,x,y,z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_source_orientation', this.handle, soundSourceID,orient);
	end

	function [] = set_sound_source_orientation_view_up(this, soundSourceID,view,up)
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

		VAMatlab('set_sound_source_orientation_view_up', this.handle, soundSourceID,view,up);
	end

	function [] = set_sound_source_parameters(this, ID,params)
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

		VAMatlab('set_sound_source_parameters', this.handle, ID,params);
	end

	function [] = set_sound_source_pose(this, soundSourceID,pos,orient)
		% Sets the position and orientation (in yaw, pitch, roll angles) of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	pos [double-3] Position vector [x, y, z] (unit: meters)
		% 	orient [double-3] Rotation angles [q,x,y,z]
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_source_pose', this.handle, soundSourceID,pos,orient);
	end

	function [] = set_sound_source_position(this, id,pos)
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

		VAMatlab('set_sound_source_position', this.handle, id,pos);
	end

	function [] = set_sound_source_signal_source(this, soundSourceID,signalSourceID)
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

		VAMatlab('set_sound_source_signal_source', this.handle, soundSourceID,signalSourceID);
	end

	function [] = set_sound_source_sound_power(this, soundSourceID,soundpower)
		% Sets the volume of a sound source
		%
		% Parameters:
		%
		% 	soundSourceID [integer-1x1] Sound source ID
		% 	soundpower [double-1x1] Sound power
		%
		% Return values:
		%
		% 	None
		%

		if this.handle==0, error('Not connected.'); end;

		VAMatlab('set_sound_source_sound_power', this.handle, soundSourceID,soundpower);
	end

	function [] = set_timer(this, period)
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

		VAMatlab('set_timer', this.handle, period);
	end

	function [newStateID] = unlock_update(this)
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

		[newStateID] = VAMatlab('unlock_update', this.handle);
	end

	function [] = wait_for_timer(this)
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

		VAMatlab('wait_for_timer', this.handle);
	end


        
        function display(this)
            % TODO: Define nice behaviour
%             if this.handle
%                 fprintf('Connection established to server ''%s''\n', this.get_server_address())
%             else
%                 fprintf('Not connected\n');
%             end
        end
        
    end

end
