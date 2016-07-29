function displayPsamp(params, state, dirs);
% displayPsamp.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
% Display the interpolated function p(k,th,ph) after sampling.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
% Output Parameters;
%   none.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display interpolated p(k,th,phi) after sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K = params.fft.K;
kr = params.center.kr_freqs_x_1;
f = params.fft.f;
Nc = params.source.N;
Na = params.array.N;
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto')
fontsize=50;
for k_ind = params.display.p_samp.k
    p = state.interp.interp_p(:,k_ind);
    p = p/norm(p);
    surf(params.display.grid, p);
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'string','rad','fontsize',fontsize,'fontweight','bold');
    remove_colorbar = false;
    set(gca, 'fontsize', fontsize, 'Fontweight', 'bold');
    handel=title(sprintf('p at %d Hz not aligned', round(f(k_ind))));
    pos = get(handel,'position');
    set(handel,'position',[pos(1) pos(2) pos(3)*0.70]);
    set(gca,'xtick',[],'ytick',[],'ztick',[],'xticklabel',{[]},'yticklabel',{[]},'zticklabel',{[]});
    xlabel('');
    ylabel('');
    zlabel('');

    filename_addition = sprintf('f%d', k_ind);


%     saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.fig_dir,...
%                  dirs.slash, dirs.interp_after_sampling_filename,...
%                  '_', filename_addition],...
%                  'fig');

    saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.jpg_dir,...
                 dirs.slash, dirs.interp_after_sampling_filename,...
                 '_', filename_addition],...
                 'jpg');

%     saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
%                  dirs.slash, dirs.interp_after_sampling_filename,...
%                  '_', filename_addition, '_color'],...
%                  'epsc');
%     colormap gray
%     saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
%                  dirs.slash, dirs.interp_after_sampling_filename,...
%                  '_', filename_addition],...
%                  'eps');
%     colormap default
end
