function load( obj, session_path )
%%LOAD load a ZOOM session (folder similar to ZOOM0001)
% This method only reads metadata like start date and the file structure.
% To get content (recorded audio data) please use extract()

    obj.session_valid = false;
    obj.session_ready = false;
    obj.session_calibrated = false;

    obj.path = session_path;
    [ session_subfolder, obj.identifier, ~ ] = fileparts( obj.path );
    try
        [ session_folder, obj.subfolder, ~ ] = fileparts( session_subfolder );
        [ ~, obj.project_name, ~ ] = fileparts( session_folder );
    catch

    end
    
    if isempty( obj.identifier )
        lst = dir('*.hprj' );
        if numel( lst ) ~= 1
            error 'Could not interpret the given path as a zoom session';
        else
             [ ~, obj.identifier ] = fileparts( lst.name );
        end
    end

    if strcmpi( 'ZOOM', obj.identifier( 1:4 ) )
        id_cells = textscan( obj.identifier( 5:8 ), '%d' );
        obj.index = id_cells{ 1 };
    end

    obj.session_ready = true;

    lst = dir( obj.path );
    for i = 1:numel( lst )

        % Skip folders
        if lst( i ).isdir
            continue
        end
        
        [ ~, base_name, ext ] = fileparts( lst( i ).name );
        
        % Read start date (if coded in file name)
        if numel( base_name ) == 15
            if strcmpi( '.hprj', ext )
                dstr = lst( i ).name( 1:end-5 );
                obj.startdate = datenum( dstr, 'yymmdd-HHMMSS' );
            end
        end

        % Read track files (raw)
        if strcmpi( '.wav', ext )
            
            if strcmpi( obj.identifier, lst( i ).name( 1:numel( obj.identifier ) ) )

                % Channel number
                track_channel = regexp( lst( i ).name, '_Tr(\d+)', 'tokens' );
                if numel( track_channel ) ~= 1
                    error( 'Channel number could not be extracted from track. Reading session metadata aborted.' );
                end
                channel_idx = str2double( track_channel{ 1 } );

                track_id = 0;
                if ~obj.has_channels( channel_idx )
                    track_id = numel( obj.tracks ) + 1;
                    obj.tracks{ track_id } = struct(); % append
                    obj.tracks{ track_id }.channel_idx = channel_idx;
                    obj.tracks{ track_id }.part_ids = [];
                    obj.tracks{ track_id }.path = fullfile( obj.path, lst( i ).name );

                    meta = ita_read( obj.tracks{ track_id }.path, 'metadata' );
                    obj.trackLength = meta.trackLength;
                    obj.tracks{ track_id }.trackLength_parts( 1 ) = meta.trackLength;
                    obj.samplingRate = meta.samplingRate;

                    obj.channels = obj.channels + 1;
                else
                    track_id = obj.get_track_ids( channel_idx );
                    part_path = fullfile( obj.path, lst( i ).name );
                    meta = ita_read( part_path, 'metadata' );
                    obj.trackLength = obj.trackLength + meta.trackLength;
                    obj.tracks{ track_id }.trackLength_parts( end + 1 ) = meta.trackLength;
                    obj.samplingRate = meta.samplingRate;
                end

                obj.tracks{ track_id }.cal_ref_factor = 1.0;
                obj.tracks{ track_id }.channelUnits = 'Pa';

                % Track part running index of splitted files (may be empty or vector)
                track_part_id_raw = regexp( lst( i ).name, '-(\d+).WAV', 'tokens' );
                part_id = 0;
                if numel( track_part_id_raw ) > 0
                    part_id = str2double( track_part_id_raw{ : } );
                end

                obj.tracks{ track_id }.part_ids( end + 1 ) = part_id;

            end
        end
    end

    obj.session_valid = true;
end