function displayError(params, state, dirs);
% displayError.m
% Author: Noam Shabtai
% ITA-RWTH, 12.11.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% displayError(params, state, dirs);
% Display the error with every guess of the acoustic center.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   dirs - directories and file names.
%
%
% Output Parameters;
%   none.

K = params.fft.K;
kr = params.center.kr_freqs_x_1;
Nc = params.source.N;
Na = params.array.N;
f = params.fft.f;
locs = params.slide.locs;
error_displays = size(params.display.errors.indices,1);
rows = params.display.errors.rows_err_res;
cols = ceil(error_displays/rows);
figure('units','normalized','outerposition',[0 0 1 1]);
for k_ind = params.display.errors.k
    for display_z = params.errors.display_z
        clf;
        max_error = max(max(state.errors.normJ(:,k_ind,:)));
        min_error = min(min(state.errors.normJ(:,k_ind,:)));
        for err_ind = 1:size(params.display.errors.indices,1)
            type = params.display.errors.indices(err_ind,1);
            type_ind = type + 1;
            err_dim = params.display.errors.indices(err_ind,2:4);
            chx = get_cord_char(err_dim(1));
            chy = get_cord_char(err_dim(2));
            chz = get_cord_char(err_dim(3));
            ind_z = find(abs(locs(:,err_dim(3))-display_z)<1e-10);
            locx = locs(ind_z, err_dim(1));
            locy = locs(ind_z, err_dim(2));
            xs = length(unique(locx));
            ys = length(locy)/xs;
            cordx_cm = locx*100;
            cordy_cm = locy*100;
            err = state.errors.normJ(ind_z, k_ind, type_ind);

            if ~params.display.errors.separate
                subplot(rows,cols,err_ind);
                filename_addition = sprintf('f%d_z_%d_cm',...
                                     k_ind,...
                                     round(display_z*100));
            else
                filename_addition = sprintf('j%d_%s_%s_f%d_z_%d_cm',...
                                     type, chx, chy, k_ind,...
                                     round(display_z*100));
            end

            if err_dim(1)<err_dim(2)
                err = reshape(err,ys,xs);
            else
                err = reshape(err,xs,ys)';
            end
            imagesc(cordx_cm, cordy_cm, err);
            set(gca,'YDir','normal')
            axis square
            if ~mod(err_ind,cols)
                caxis([min_error,max_error]);
                colorbar('location','east');
            end

            if params.display.errors.separate
                set(gca,'fontsize',50);
            else
                set(gca, 'fontsize', 15, 'fontweight', 'bold');
            end

            xlabel(sprintf('%c [cm]', chx));
            ylabel(sprintf('%c [cm]', chy));

            if type < 4 
                error_str = sprintf('J_c at %d Hz', round(f(k_ind)));
            else
                error_str = sprintf('J_p at %d Hz', round(f(k_ind)));
            end
            title(error_str);

            if params.display.errors.separate
                saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                         dirs.slash, dirs.errors_filename,...
                         '_', filename_addition, '_color'],...
                         'epsc');
                colormap gray;
                saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                         dirs.slash, dirs.errors_filename,...
                         '_', filename_addition],...
                         'eps');
                colormap default
            end
        end

        if ~params.display.errors.separate
            % Save error figures
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.jpg_dir,...
                     dirs.slash, dirs.errors_filename,...
                     '_', filename_addition],...
                     'jpg');
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                     dirs.slash, dirs.errors_filename,...
                     '_', filename_addition, '_color'],...
                     'epsc');
            colormap gray;
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                     dirs.slash, dirs.errors_filename,...
                     '_', filename_addition],...
                     'eps');
            colormap default;
        end
    end
end

function ch = get_cord_char(num)
switch num
case 1
    ch = 'x';
case 2
    ch = 'y';
case 3
    ch = 'z';
end
