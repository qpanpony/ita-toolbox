function displayErrorOneDim(params, state, dirs);
% displayErrorOneDim.m
% Author: Noam Shabtai
% ITA-RWTH, 1.9.2014
%
% displayErrorOneDim(params, state, dirs);
% Display the error on 1D line.
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
f = params.fft.f;
locs = params.slide.locs;
error_displays = size(params.display.errors.indices,1);
rows = params.display.errors.rows_err_res;
cols = ceil(error_displays/rows);
display_z = params.errors.display_z(1);
display_y = params.errors.display_y;
figure('units','normalized','outerposition',[0 0 1 1]);
for k_ind = params.display.errors.k
    for err_ind = 1:size(params.display.errors.indices,1)
        type = params.display.errors.indices(err_ind,1);
        type_ind = type + 1;

        err_dim = params.display.errors.indices(err_ind,2:4);

        relevant_ind(:,err_ind) = find(abs(locs(:,err_dim(2))-display_y) +...
                            abs(locs(:,err_dim(3))-display_z) < 1e-10);

        err_matrix(:,err_ind) = state.errors.normJ(relevant_ind(:,err_ind),...
                                                   k_ind, type_ind);
    end

    min_error_total = min(min(err_matrix));
    max_error_total = max(max(err_matrix));

    clf;
    for err_ind = 1:size(params.display.errors.indices,1)
        type = params.display.errors.indices(err_ind,1);
        err = err_matrix(:,err_ind);
        err_dim = params.display.errors.indices(err_ind,2);
        chx = get_cord_char(err_dim);
        locx = locs(relevant_ind(:,err_ind), err_dim);
        cordx_cm = locx*100;
        
        if ~params.display.errors.separate
            subplot(rows,cols,err_ind);
            filename_addition = sprintf('f%d_z_%d_cm_y_%d_cm_1d',...
                                         k_ind,...
                                         round(display_z*100),...
                                         round(display_y*100));
        else
            filename_addition = sprintf('j%d_%s_f%d_z_%d_cm_y_%d_cm_1d',...
                                         type, chx, k_ind,...
                                         round(display_z*100),...
                                         round(display_y*100));
        end

        plot(cordx_cm, err, 'linewidth', 5);
        xlim([min(cordx_cm),max(cordx_cm)]);
        ylim([min_error_total,max_error_total]);
        [min_err, min_err_ind] = min(err);
        hold on
        plot(cordx_cm(min_err_ind), min_err, 'kx', 'linewidth', 25);
        hold off

        if params.display.errors.separate
            set(gca,'fontsize',50);
        else
            set(gca, 'fontsize', 15, 'fontweight', 'bold');
        end

        xlabel(sprintf('\\Delta %c [cm]', chx));

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

function ch = get_cord_char(num)
switch num
case 1
    ch = 'x';
case 2
    ch = 'y';
case 3
    ch = 'z';
end
