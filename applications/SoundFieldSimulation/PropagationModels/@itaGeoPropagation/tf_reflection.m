function [ linear_freq_data ] = tf_reflection( obj, anchor, incident_direction_vec, emitting_direction_vec )
%TF_REFLECTION Returns the specular reflection transfer function for an reflection point anchor with
% an incident and emitting direction

linear_freq_data = ones( obj.num_bins, 1 );

if ~isfield( anchor, 'material_id' )
    return
end

if ~isfield( obj.material_db, anchor.material_id )
    warning( 'Material id "%s" not found in database, skipping reflection tf calculation', anchor.material_id )
    return
end

material_data = obj.material_db.( anchor.material_id );

if isa( material_data, 'struct' )
    
else
    warning( 'Unrecognized material format "%s" of material with id "%s"', class( material_data ), anchor.material_id )
end

end

