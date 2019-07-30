%% General

% Load and generate ids
pps = ita_propagation_load_paths( 'ppa_example_paths.json' );
fprintf( 'Found %i paths\n', numel( pps ) );
[ pps_with_ids, pps_hash_table ] = ita_propagation_paths_add_identifiers( pps, true ); % verbose mode

% Compare
pps_2 = ita_propagation_load_paths( 'ppa_example_paths_2.json' );
[ pps_2, pps_hash_table_2 ] = ita_propagation_paths_add_identifiers( pps_2 );

[ pps_new, pps_del, pps_alt ] = ita_propagation_paths_diff( pps_with_ids, pps_2 );
