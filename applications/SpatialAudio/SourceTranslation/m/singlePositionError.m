function state = singlePositionError(params, state)
% singlePositionError.m
% Author: Noam Shabtai
% ITA-RWTH, 12.11.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% state = singlePosisionError(params, state)
% Calculate error for a single assumed source center.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   state.errors.J - 5 error types (4 high order and 1 directivity) x freqs x scan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fetch parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc_ind = state.slide.loc_ind;
loc = params.slide.locs(loc_ind,:);
cnm = state.slide.cnm(:,:,loc_ind);
N = params.array.N;
Nfirst = params.errors.high_order.Nfirst;
weights = params.errors.high_order.n;
pnm = state.slide.pnm(:, :, loc_ind);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% High order errors of cnm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J_high_order = ita_sph_error_high_order(cnm, N, Nfirst, weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% High order errors of pnm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J_high_order_pnm = ita_sph_error_high_order(pnm, N, Nfirst, weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directivity preservation errors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_circ_nm_x_to_z = ita_sph_wignerD(N, 0, -pi/2, 0) * pnm; %yz plane
p_circ_nm_y_to_z = ita_sph_wignerD(N, -pi/2, -pi/2, 0) * pnm; %xz plane

J_direct = ita_sph_error_directivity(pnm);
J_direct_yz_plane = ita_sph_error_directivity(p_circ_nm_x_to_z);
J_direct_xz_plane = ita_sph_error_directivity(p_circ_nm_y_to_z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directivity preservation errors with cnm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c_circ_nm_x_to_z = ita_sph_wignerD(N, 0, -pi/2, 0) * cnm; %yz plane
c_circ_nm_y_to_z = ita_sph_wignerD(N, -pi/2, -pi/2, 0) * cnm; %xz plane

J_direct_cnm = ita_sph_error_directivity(cnm);
J_direct_yz_plane_cnm = ita_sph_error_directivity(c_circ_nm_x_to_z);
J_direct_xz_plane_cnm = ita_sph_error_directivity(c_circ_nm_y_to_z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store different errors in state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
state.errors.J(:,:,loc_ind) = [...
                                J_high_order;...
                                J_direct; J_direct_yz_plane; J_direct_xz_plane;...
                                J_high_order_pnm;...
                                J_direct_cnm; J_direct_yz_plane_cnm; J_direct_xz_plane_cnm
                              ];
