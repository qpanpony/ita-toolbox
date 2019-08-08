function [ frequency_mags, gain, delay, valid, varargout ] = ita_propagation_path_get_data( pp, f, c, varargin )
% ita_propagation_path_get_data Returns frequency magnitudes, gain and
% delay for DSP processing. 4th return value is a validity flag.
%
% Example: [ frequency_mags, gain, delay, valid ] = ita_propagation_path_get_data( path_struct, f, c )
%

if ~isfield( pp, 'propagation_anchors' )
    error 'Did not find a field ''propagation_anchors'' in this propagation path.'
end

gain = 1;
frequency_mags = ones( 1, numel( f ) );
total_distance = 0;
delay = 0;
valid = true;

pd = pp.propagation_anchors;
N = numel( pd );

record_paths = 0;
if( nargin == 4 ) %if option is set, return path data
    if( strcmp( varargin, 'record_paths' ) == 1 )
        varargout{1} = zeros(N,3);
        if( isa( pd, 'struct' ) )
            varargout{1}(1,:) = pd(1).interaction_point(1:3);
            varargout{1}(N,:) = pd(N).interaction_point(1:3);
        else
            varargout{1}(1,:) = pd{1}.interaction_point(1:3);
            varargout{1}(N,:) = pd{N}.interaction_point(1:3);
        end
        record_paths = 1;
    else
        error(strcat('Unrecognised input argument: ', varargin));
    end
elseif( nargin > 4 )
    error( 'Too many input arguments' );
end

if N < 1
    error('Only one interaction point given') % No path constructable
elseif N == 2
    source = pd( 1 );
    receiver = pd( 2 );
    total_distance = norm( receiver.interaction_point - source.interaction_point );    
end

is_diff = 0; %set to 1 whenever a diffraction is encountered
 
for i = 2:N-1 %start from 2, first entry is always source, -1 as receiver always the last
    
    if isa( pd, 'struct' )
        a_prev = pd( i-1 );
        a_curr = pd( i );
        a_next = pd( i+1 );
    else
        a_prev = pd{ i-1 };
        a_curr = pd{ i };
        a_next = pd{ i+1 };
    end
    
    segment_distance = norm( a_curr.interaction_point - a_prev.interaction_point );
    total_distance = total_distance + segment_distance;

    if( record_paths == 1 ) %if option is set, record the interaction points of the whole path
        varargout{1}(i,:) = a_curr.interaction_point(1:3);
    end
    if( valid == false ) %if the path is invalid, continue so that the delay can be properly worked out
        continue
    end
    
    anchor_type = a_curr.anchor_type;
    switch anchor_type

        case 'outer_edge_diffraction' %case for diffraction

            w = ita_propagation_wedge_from_diffraction_anchor( a_curr );
            w.set_get_geo_eps( 1e-6 );

            source_pos = a_prev.interaction_point(1:3);
            target_pos = a_next.interaction_point(1:3);
            
            rho = ita_propagation_effective_source_distance( pp, i ); %effective distance from aperture point to source
            last_pos_dirn = a_prev.interaction_point(1:3) - a_curr.interaction_point(1:3); %direction to the last source
            eff_source_pos = ( last_pos_dirn .* rho ./ norm(last_pos_dirn) ) +a_curr.interaction_point(1:3);
            r = ita_propagation_effective_target_distance( pp, i ); %effective distance from aperture point to receiver
            next_pos_dirn = a_next.interaction_point(1:3) - a_curr.interaction_point(1:3); %"receiver"
            eff_receiver_pos = ( next_pos_dirn .* r ./ norm(next_pos_dirn) ) + a_curr.interaction_point(1:3);

            if( ~w.point_outside_wedge( eff_source_pos ) || ~w.point_outside_wedge( eff_receiver_pos ))%catch error if source is inside wedge
                warning('Invalid path, source or receiver inside wedge');
                valid = false;
                continue
            end
            %{
            plot3([w.aperture_start_point(1),w.aperture_end_point(1)],[w.aperture_start_point(2),w.aperture_end_point(2)],[w.aperture_start_point(3),w.aperture_end_point(3)])
            plot3([eff_source_pos(1),path_data{i}.interaction_point(1)],[eff_source_pos(2),path_data{i}.interaction_point(2)],[eff_source_pos(3),path_data{i}.interaction_point(3)])
            plot3([eff_receiver_pos(1),path_data{i}.interaction_point(1)],[eff_receiver_pos(2),path_data{i}.interaction_point(2)],[eff_receiver_pos(3),path_data{i}.interaction_point(3)])
            %}
            %{
            smallest_dist = 1000000;
            n0 = 10000; %number of iterations
            its = norm(w.aperture_start_point - w.aperture_end_point) / norm(w.aperture_direction); %number of aperture directions along aperture
            for it = 0:n0
                point_on_ap = w.aperture_start_point + (it*its/n0)*w.aperture_direction;
                source_length = norm( point_on_ap - source_pos );
                receiver_length = norm( eff_receiver_pos - point_on_ap );
                total_dist = source_length + receiver_length;
                if( total_dist < smallest_dist )
                    smallest_dist = total_dist;
                    ap_point = point_on_ap;
                end
            end
            plot3(ap_point(1),ap_point(2),ap_point(3),'.k') %true closest point

            ap_point2 = w.get_aperture_point( source_pos, receiver_pos );
            ap_point3 = w.get_aperture_point( eff_source_pos, eff_receiver_pos );
            ap_point4 = w.get_aperture_point2( source_pos, receiver_pos );
            plot3(ap_point2(1),ap_point2(2),ap_point2(3),'.r') %point which should be predicted from aperture point method
            plot3(ap_point3(1),ap_point3(2),ap_point3(3),'.b') %point which should be predicted from aperture point method
            plot3(ap_point4(1),ap_point4(2),ap_point4(3),'.g') %point which should be predicted from aperture point method
            %}
            aperture_point = w.get_aperture_point2( source_pos, target_pos );
            if ~w.point_on_aperture( aperture_point )
                warning('Invalid path, aperture point calculated not on the aperture');
                valid = false;
                continue
            end
            if norm( eff_receiver_pos - aperture_point ) < w.set_get_geo_eps
                warning('Invalid path where aperture point and receiver point coincide');
                valid = false;
                continue
            end
            
            [~, D, A] = ita_diffraction_utd( w, eff_source_pos, eff_receiver_pos, f, c, aperture_point );    

            if( is_diff == 0 )
                gain = gain * (A / rho);
                is_diff = 1;
            else
                gain = gain * A;
            end
            frequency_mags = frequency_mags .* D;

            
        case 'inner_edge_diffraction'
            
            source_pos = a_prev.interaction_point(1:3);
            target_pos = a_next.interaction_point(1:3);

            w = ita_propagation_wedge_from_diffraction_anchor( a_curr );   
            w.set_get_geo_eps( 1e-6 );

            rho = ita_propagation_effective_source_distance( pp, i ); %effective distance from aperture point to source
            last_pos_dirn = a_prev.interaction_point(1:3) - a_curr.interaction_point(1:3); %direction to the last source
            eff_source_pos = ( last_pos_dirn .* rho ./ norm(last_pos_dirn) ) + a_curr.interaction_point(1:3);
            r = ita_propagation_effective_target_distance( pp, i ); %effective distance from aperture point to receiver
            next_pos_dirn = a_next.interaction_point(1:3) - a_curr.interaction_point(1:3); %"receiver"
            eff_receiver_pos = ( next_pos_dirn .* r ./ norm(next_pos_dirn) ) + a_curr.interaction_point(1:3);

            if( ~w.point_outside_wedge( eff_source_pos ) || ~w.point_outside_wedge( eff_receiver_pos ))%catch error if source is inside wedge
                warning('Invalid path, source or receiver inside wedge');
                valid = false;
                continue
            end

            aperture_point = w.get_aperture_point2( source_pos, target_pos );
            if ~w.point_on_aperture( aperture_point )
                warning('Invalid path, aperture point calculated not on the aperture');
                valid = false;
                continue
            end     

            if norm( eff_receiver_pos - aperture_point ) < w.set_get_geo_eps
                warning('Invalid path where aperture point and receiver point coincide');
                valid = false;
                continue
            end
            
            [~, D, A] = ita_diffraction_utd( w, eff_source_pos, eff_receiver_pos, f, c, aperture_point );    

            if( is_diff == 0 )
                gain = gain * (A / rho);
                is_diff = 1;
            else
                gain = gain * A;
            end
            frequency_mags = frequency_mags .* D;               
        case 'specular_reflection' %case for specular reflection
            %path = 'C:\ITASoftware\Raven\RavenDatabase\MaterialDatabase';
            %data = load(fullfile(path,'brickwall'));
            %frequency_mags = frequency_mags .* FREQ_DATA_FOR_REFLECTION_SURFACE; %INSERT LOOKUP FIR FREQ DATA BASED ON VERTEX NUMBER
        otherwise
            error('Unrecognised anchor type');       
    end
end

%% Determine DSP coefficients / path data

frequency_mags = frequency_mags .* ita_atmospheric_absorption_factor( f, total_distance ); %flter contribution from atmospheric absorption
    
if( is_diff == 0 ) %if there was no diffraction in path, apply 1/r distance law for gain
    gain = 1 / total_distance;
end

segment_distance = norm( a_next.interaction_point - a_curr.interaction_point );
total_distance = total_distance + segment_distance;
delay = total_distance / c;

%drawnow % can be removed?

end