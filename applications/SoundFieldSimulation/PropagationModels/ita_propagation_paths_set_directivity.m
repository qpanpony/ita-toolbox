function [ pps_with_directivity ] = ita_propagation_paths_set_directivity( pps, anchor_type, directivity_id )
%
% ita_propagation_paths_set_directivity Assigns all given anchor types a
% directivity id
%%
% Example: pps_with_directivity = ita_propagation_paths_set_directivity( pps, 'emitter', 'Genelec8020' )
%

if nargin < 3
    error( 'Too few arguments, need propagation path list and directivity id' )
end

if isempty( pps )
    warning 'Empty propagation path list given'
    return;
end

if ~isfield( pps, 'class' )
    error( 'Given path list does not contain a class field' )
end

if ~isfield( pps, 'propagation_anchors' )
    error( 'Could not modify propagation path list, struct is missing field "propagation_anchors"' )
end

pps_with_directivity = pps;

for n = 1:numel( pps )
    pp = pps( n );

    for a = 1:numel( pp.propagation_anchors )
        
        if( isa( pp.propagation_anchors, 'struct' ) )
            anchor = pp.propagation_anchors( a );
        else
            anchor = pp.propagation_anchors{ a };
        end
        
        if strcmpi( anchor.anchor_type, anchor_type )
             anchor.directivity_id = directivity_id;
        end
        
        if( isa( pp.propagation_anchors, 'struct' ) )
            pp.propagation_anchors( a ) = anchor;
        else
            pp.propagation_anchors{ a } = anchor;
        end
    end
    
    pps_with_directivity( n ) = pp;

end

end
