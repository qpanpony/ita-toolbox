function [ pps_new, pps_del, pps_common ] = ita_propagation_paths_diff( pps_1, pps_2 )
%
% ita_propagation_paths_diff Returns difference information on two
% propagation path lists
%%
% Example: [ pps_new, pps_del, pps_alt ] = ita_propagation_paths_diff( pps_1, pps_2 )
%
% Note: no common propagation paths are found if the identifier is empty!
% Path lists with non-unique identifiers may lead to unintended results.
%
%

if ~isfield( pps_1, 'class' ) || ~isfield( pps_2, 'class' )
    error( 'Could not diff propagation path lists, struct is missing field "class"' )
end

if ~isfield( pps_1, 'propagation_anchors' ) || ~isfield( pps_2, 'propagation_anchors' )
    error( 'Could not diff propagation path lists, struct is missing field "propagation_anchors"' )
end

% terribly slow search algorithm comes here:

missing_in_1 = ones( numel( pps_2 ), 1 );
missing_in_2 = ones( numel( pps_1 ), 1 );
found_in_both = zeros( numel( pps_1 ), 1 );

for n1 = 1:numel( pps_1 )
    
    for n2 = 1:numel( pps_2 )
        
        if strcmpi( pps_1( n1 ).identifier, pps_2( n2 ).identifier ) && ~isempty( pps_1( n1 ).identifier )
            found_in_both( n1 ) = 1;
            missing_in_1( n2 ) = 0;
            missing_in_2( n1 ) = 0;
        end
        
    end
end

pps_new = pps_2( missing_in_1 == 1 );
pps_del = pps_1( missing_in_2 == 1 );
pps_common = pps_1( found_in_both == 1 );

end
