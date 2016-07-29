function displayPslide(params, state);
% displayPslide.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% displayPslide(params, state);
% Display the interpolated function p(k,th,ph) after sampling.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   none.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display interpolated p(k,th,phi) after sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ita_preferences('FontSize', 25);
K = params.fft.K;
kr = params.center.kr_freqs_x_1;
f_khz = (params.fft.f)/1000;
N = min(params.source.N, params.array.N);
Ynm = params.display.Ynm(:,1:(N+1)^2); % display_grid x (N+1)^2

locs = params.slide.locs;
display_locs = params.slide.display_locs;
display_points = size(display_locs,1);

for k_ind = 1:K
    figure('units','normalized','outerposition',[0 0 1 1]);
    for display_ind = 1 : display_points
        current_disp = display_locs(display_ind,:);
        current_disp_matrix = repmat(current_disp, size(locs,1), 1);
        [val,loc_ind] = min(sum(abs(locs-current_disp_matrix).^2,2));
        loc = locs(loc_ind,:);
        loc_cm = round(100*loc);
        pnm = state.slide.pnm(:, k_ind, loc_ind); % (N+1)^2 x 1
        p = Ynm * pnm;                            % display_grid x 1

        subplot(display_points, 2, (display_ind-1)*2+1);
        colorbar('off');
        surf(params.display.grid, p);
        set(gca, 'fontsize', 12, 'fontweight', 'bold');
        title(sprintf('p_{slide}(k,th,ph) at %3.1f KHz \n at [%d,%d,%d] cm',...
                 f_khz(k_ind), loc_cm(1), loc_cm(2), loc_cm(3)))

        p_circ_nm = ita_sph_wignerD(N, 0, pi/2, 0) * pnm;
        p_circ = Ynm * p_circ_nm;       % display_grid x 1

        subplot(display_points, 2, display_ind*2);
        colorbar('off');
        surf(params.display.grid, p_circ);
        set(gca, 'fontsize', 12, 'fontweight', 'bold');
        title(sprintf('p_{circ}(k,th,ph) at %3.1f KHz \n at [%d,%d,%d] cm',...
                 f_khz(k_ind), loc_cm(1), loc_cm(2), loc_cm(3)))
    end
end
