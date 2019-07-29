function propagation_path_list = ita_propagation_load_paths( json_file_path )
%
% ita_propagation_load_paths Loads a JSON formatted propagation path list
% from a text file
%
% Raises an error if the file does not comply with the propagation path list
% formatting
%

    json_txt = fileread( json_file_path );
    json_struct = jsondecode( json_txt );
    
    if ~isfield( json_struct, 'class' )
        error( 'Could not import propagation path list from file %f, structure is missing field "class"', json_file_path )
    end
    assert( strcmpi( json_struct.class, 'propagation_path_list' ) || strcmpi( json_struct.class, 'PropagationPathList' ) )
    
    if ~isfield( json_struct, 'propagation_paths' )
        error( 'Could not import propagation path list from file %f, structure is missing field "propagation_paths"', json_file_path )
    end
    
    propagation_path_list = json_struct.propagation_paths;
    
end
