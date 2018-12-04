function snippet = extract( obj, extract_seconds, channels, calibrated )
    % Default channel_num is 1, time can be relative
    % seconds of record or absolute date
    if numel( extract_seconds ) ~= 2
        error( 'Time for extraction has to be a 1-by-2 vector with start and end value' )
    end

    if ( sum( extract_seconds < 0 ) || sum( extract_seconds > obj.trackLength ) )
        error( 'Requested time [ %1.1fs %1.1fs ] is not (or only partly) contained in this session with track length of %1.1fs', extract_seconds( 1 ), extract_seconds( 2 ), obj.trackLength )
    end

    if nargin < 4
        calibrated = true;
    end
    if nargin < 3
        channels = 1;
    end

    if ~obj.has_channels( channels )
        error( 'Could not find tracks for requested channels %i', channels )
    end

    snippet = itaAudio();

    for c = 1:numel( channels )

        track_ids = obj.get_track_ids( channels( c ) );
        ets = extract_seconds; % sliding

        bFirstPart = false;
        bSecondPart = false;
        for i=1:numel( obj.tracks{ track_ids }.part_ids )

            if obj.tracks{ track_ids }.part_ids( i ) > 0
                track_part_str = sprintf( '%04d', obj.tracks{ track_ids }.part_ids( i ) );
                track_base_name = [ obj.identifier '_Tr' num2str( channels ) '-' track_part_str ];
            else
                 track_base_name = [ obj.identifier '_Tr' num2str( channels ) ];
            end

            track_full_path = fullfile( obj.path, [ track_base_name '.wav' ] );

            track_part_meta = ita_read_wav( track_full_path, 'metadata' );
            part_track_length = obj.tracks{ track_ids }.trackLength_parts( i );

            if ets > track_part_meta.trackLength
                ets = ets - part_track_length;
                continue; 
            end

            if ets <= track_part_meta.trackLength
                if ets >= 0
                    % requested snippet is completely in this part.
                    snippet = ita_read( track_full_path, ets, 'time' );
                    snippet.channelUnits = obj.tracks{ track_ids }.channelUnits;
                    if obj.tracks{ track_ids }.cal_ref_factor ~= 1 && calibrated
                        snippet = ita_amplify( snippet, 1 / obj.tracks{ track_ids }.cal_ref_factor );
                    end
                    return;
                end
            end

            % Snippet overlaps track parts                    
            if ets( 1 ) < track_part_meta.trackLength && ets( 2 ) > track_part_meta.trackLength
                % beginning if snippet is in this part.
                snippet_first = ita_read( track_full_path, [ ets( 1 ) track_part_meta.trackLength ], 'time' );
                bFirstPart = true;
                if obj.tracks{ track_ids }.cal_ref_factor ~= 1 && calibrated
                    snippet_first = ita_amplify( snippet_first, 1 / obj.tracks{ track_ids }.cal_ref_factor );
                end
                ets = ets - part_track_length;
            elseif ets( 1 ) < 0 && ets( 2 ) > 0
                % end of snippet is in this part.
                snippet_second = ita_read( track_full_path, [ 0 ets( 2 ) ], 'time' );
                bSecondPart = true;
                if obj.tracks{ track_ids }.cal_ref_factor ~= 1 && calibrated
                    snippet_second = ita_amplify( snippet_second, 1 / obj.tracks{ track_ids }.cal_ref_factor );
                end
            end

        end            

        if bFirstPart && bSecondPart
            snippet = ita_append( snippet_first, snippet_second ); % Concat time data, already calibrated
            snippet.channelUnits = 'Pa';
            return
        end
    end

    error( 'Requested time snippet is not found in this session, unkown error' )
end
