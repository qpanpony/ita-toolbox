function [frequency_mags, gain, delay] = ita_propagation_path_get_data( path_struct, f, c )
    path_data = path_struct.propagation_anchors;
    gain = 1;
    frequency_mags = ones(1,length(f));
    total_distance = 0;
    is_diff = 0; %set to 1 whenever a diffraction is encountered
    %{
    figure
    for i = 1:numel(path_data)-1
        plot3([path_data{i}.interaction_point(1),path_data{i+1}.interaction_point(1)],[path_data{i}.interaction_point(2),path_data{i+1}.interaction_point(2)],[path_data{i}.interaction_point(3),path_data{i+1}.interaction_point(3)])
        hold on
    end
    %}
    for i = 2:numel(path_data)-1 %start from 2, first entry is always source, -1 as receiver always the last
        anchor_type = path_data{i}.anchor_type;
        segment_distance = norm(path_data{ i }.interaction_point(1:3) - path_data{ i-1 }.interaction_point(1:3));
        total_distance = total_distance + segment_distance;
        
        switch anchor_type
            
            case 'outer_edge_diffraction' %case for diffraction
                main_face_normal(1,:) = path_data{i}.main_wedge_face_normal(1:3);
                opposite_face_normal(1,:) = path_data{i}.opposite_wedge_face_normal(1:3);
                aperture_start(1,:) = path_data{i}.vertex_start(1:3); %aperture point    
                vertex_length(1,:) = norm( path_data{i}.vertex_start(1:3) - path_data{i}.vertex_end(1:3) );
                %wedge_type = path_struct{i}.anchor_type; %FOR NOW ALWAYS USE THE DEFAULT WEDGE TYPE
                
                w = itaFiniteWedge( main_face_normal, opposite_face_normal, aperture_start, vertex_length, 'outer_edge' );
                w.set_get_geo_eps( 1e-6 );
                
                source_pos(1,:) = path_data{i-1}.interaction_point(1:3);
                receiver_pos(1,:) = path_data{i+1}.interaction_point(1:3);
                rho = ita_propagation_effective_source_distance( path_struct, i ); %effective distance from aperture point to source
                last_pos_dirn(1,:) = path_data{i-1}.interaction_point(1:3) - path_data{i}.interaction_point(1:3); %direction to the last source
                eff_source_pos(1,:) = ( last_pos_dirn .* rho ./ norm(last_pos_dirn) ) + path_data{i}.interaction_point(1:3)';
                r = ita_propagation_effective_target_distance( path_struct, i ); %effective distance from aperture point to receiver
                next_pos_dirn(1,:) = path_data{i+1}.interaction_point(1:3) - path_data{i}.interaction_point(1:3); %"receiver"
                eff_receiver_pos(1,:) = ( next_pos_dirn .* r ./ norm(next_pos_dirn) ) + path_data{i}.interaction_point(1:3)';
                
                if( w.point_outside_wedge( eff_source_pos ) == 0 ) %catch error if source is inside wedge
                    delay = -1;
                    return
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
                aperture_point = w.get_aperture_point2( source_pos, receiver_pos );
                if( w.point_on_aperture( aperture_point ) == 0 )
                    warning('Skipping path, aperture point calculated not on the aperture');
                    continue
                end
                
                [~, D, A] = ita_diffraction_utd( w, eff_source_pos, eff_receiver_pos, f, c, aperture_point );    
                                
                if( is_diff == 0 )
                    gain = gain * (A / rho);
                    is_diff = 1;
                else
                    gain = gain * A;
                end
                frequency_mags = frequency_mags .* abs(D);
                
            case 'inner_edge_diffraction'
                source_pos(1,:) = path_data{i-1}.interaction_point(1:3);
                receiver_pos(1,:) = path_data{i+1}.interaction_point(1:3);
                
                opposite_face_normal(1,:) = path_data{i}.main_wedge_face_normal(1:3);
                main_face_normal(1,:) = path_data{i}.opposite_wedge_face_normal(1:3);
                aperture_start(1,:) = path_data{i}.vertex_start(1:3); %aperture point    
                vertex_length(1,:) = norm( path_data{i}.vertex_start(1:3) - path_data{i}.vertex_end(1:3) );
                %wedge_type = path_struct{i}.anchor_type; %FOR NOW ALWAYS USE THE DEFAULT WEDGE TYPE
                
                w = itaFiniteWedge( main_face_normal, opposite_face_normal, aperture_start, vertex_length, 'inner_edge' );     
                w.set_get_geo_eps( 1e-6 );
                
                rho = ita_propagation_effective_source_distance( path_struct, i ); %effective distance from aperture point to source
                last_pos_dirn(1,:) = path_data{i-1}.interaction_point(1:3) - path_data{i}.interaction_point(1:3); %direction to the last source
                eff_source_pos(1,:) = ( last_pos_dirn .* rho ./ norm(last_pos_dirn) ) + path_data{i}.interaction_point(1:3)';
                r = ita_propagation_effective_target_distance( path_struct, i ); %effective distance from aperture point to receiver
                next_pos_dirn(1,:) = path_data{i+1}.interaction_point(1:3) - path_data{i}.interaction_point(1:3); %"receiver"
                eff_receiver_pos(1,:) = ( next_pos_dirn .* r ./ norm(next_pos_dirn) ) + path_data{i}.interaction_point(1:3)';

                if( w.point_outside_wedge( eff_source_pos ) == 0 ) %catch error if source is inside wedge
                    delay = -1;
                    return
                end
                
                aperture_point = w.get_aperture_point2( source_pos, receiver_pos );
                if( w.point_on_aperture( aperture_point ) == 0 )
                    warning('Skipping path, aperture point calculated not on the aperture');
                    continue
                end     
                
                [~, D, A] = ita_diffraction_utd( w, eff_source_pos, eff_receiver_pos, f, c, aperture_point );    
                                
                if( is_diff == 0 )
                    gain = gain * (A / rho);
                    is_diff = 1;
                else
                    gain = gain * A;
                end
                frequency_mags = frequency_mags .* abs(D);               
            case 'specular_reflection' %case for specular reflection
                %path = 'C:\ITASoftware\Raven\RavenDatabase\MaterialDatabase';
                %data = load(fullfile(path,'brickwall'));
                %frequency_mags = frequency_mags .* FREQ_DATA_FOR_REFLECTION_SURFACE; %INSERT LOOKUP FIR FREQ DATA BASED ON VERTEX NUMBER
            otherwise
                error('Unrecognised anchor type');       
        end
    end
    frequency_mags = frequency_mags .* ita_atmospheric_absorption_factor( f, total_distance ); %flter contribution from atmospheric absorption
    drawnow
    if( is_diff == 0 ) %if there was no diffraction in path, apply 1/r distance law for gain
        gain = 1/total_distance;
    end
    delay = total_distance / c;
end