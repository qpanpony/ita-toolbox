function [] = daffv15_convert_from_daffv17( daffv17_input_file_path, daffv15_output_file_path )
%
%  OpenDAFF
%
    h = DAFFv17( 'open', daffv17_input_file_path );

    props = DAFFv17( 'getProperties', h );

    metadata_v15 = daffv15_metadata_addKey( [], 'Converter', 'String', 'Converted from DAFF version 1.7' );
    metadata_v15 = daffv15_metadata_addKey( metadata_v15, 'Date of conversion', 'String', date );
    metadata_v15 = daffv15_metadata_addKey( metadata_v15, 'delay_samples', 'Float', 0 ); % No inherent latency

    metadata_v17 = DAFFv17( 'getMetadata', h );

    metadata_field_names = fieldnames( metadata_v17 );
    for i = 1:size( metadata_field_names, 1 )
       key = metadata_field_names{i};
       val = metadata_v17.( key );
       if isnumeric( val )
           val = num2str( val );
       end
       metadata_v15 = daffv15_metadata_addKey( metadata_v15, key, 'String', val );
    end

    %% DAFF version 15

    % Prepare data set
    dataset = daffv15_create_dataset( 'alphares', props.alphaResolution, ...
                              'alpharange', props.alphaRange, ...
                              'betares', props.betaResolution, ...
                              'betarange', props.betaRange, ...
                              'channels',  props.numChannels );

    dataset.metadata = metadata_v15;

    
    % Copy data 
    for i = 1:dataset.numrecords
       dataset.records{ i }.data = DAFFv17( 'getRecordByIndex', h, i );
    end 
    
    switch( props.contentType )
        case 'ir'
    dataset.samplerate = props.samplerate;
    daffv15_write( 'filename', daffv15_output_file_path, ...
                'content', props.contentType, ...
                'dataset', dataset, ...
                'orient', props.orientation, ...
                'quantization', props.quantization, ...
                'verbose' );
        otherwise
            error( 'Conversion for this content type is not implemented' );
    end

    DAFFv17( 'close', h ); 
end