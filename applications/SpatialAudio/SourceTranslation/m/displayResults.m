function displayResults(params, state, results, dirs);
% displayPsamp.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
% displayResults(params, state, results, dirs);
% Display the assumed function p(k,th,ph) after finding the center.
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%   results - final results.
%   dirs - directories and file names.
%
% Output Parameters;
%   none.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display interpolated p(k,th,phi) after sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k_indices = params.display.results.k;
f = params.fft.f(k_indices);
Nc = params.source.N;
Na = params.array.N;
result_indices = params.display.results.indices;
rows = length(result_indices);
cols = length(k_indices);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto')
if ~params.display.results.separate
    fontsize = 15;
else
    fontsize = 60;
end

for k_ind = 1:length(k_indices)
    for result_ind = 1:length(result_indices)
        type = result_indices(result_ind);
        type_ind = type + 1;

        if ~params.display.results.separate
            subplot(rows,cols,k_ind+(result_ind-1)*length(k_indices));
        end

        if ~type_ind
            p = state.interp.interp_p(:,k_ind);
        else
            p = results.interp_p(:,k_ind,type_ind);
            loc_cm = round(100*results.loc(k_ind,:,type_ind));
        end
        p = p/norm(p);

        surf(params.display.grid, p);

        if type < 0
            baloon_str = sprintf('p_{samp} %d Hz', round(f(k_ind)));
        elseif type < 4 
            baloon_str = sprintf('p_{c} %d Hz\n\\Deltar=[%s] cm',...
                               round(f(k_ind)), num2str(loc_cm));
        else
            baloon_str = sprintf('p_{p} %d Hz\n\\Deltar=[%s] cm',...
                               round(f(k_ind)), num2str(loc_cm));
        end

        if result_ind==1
            t = colorbar('peer',gca);
            set(get(t,'ylabel'),'string','rad','fontsize',fontsize,'fontweight','bold');
            remove_colorbar = false;
        else
            remove_colorbar = true;
        end
        set(gca, 'FontSize', fontsize, 'Fontweight', 'bold');
        
        set(gca,'xtick',[],'ytick',[],'ztick',[],'xticklabel',{[]},'yticklabel',{[]},'zticklabel',{[]});
        xlabel('');
        ylabel('');
        zlabel('');

        handel=title(baloon_str);
        pos = get(handel,'position');
        set(handel,'position',[pos(1) pos(2) pos(3)*0.70]);

        if remove_colorbar
            ch=findall(gcf,'tag','Colorbar');
            delete(ch);
        end

%        set(gcf, 'Renderer', 'opengl');
        if params.display.results.separate
            filename_addition = sprintf('j%d_f%d', type, k_ind);
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.jpg_dir,...
                     dirs.slash, dirs.results_filename,...
                     '_', filename_addition],...
                     'jpg');
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                     dirs.slash, dirs.results_filename,...
                     '_', filename_addition, '_color'],...
                     'epsc');
            colormap gray;
            saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
                     dirs.slash, dirs.results_filename,...
                     '_', filename_addition],...
                     'eps');
            colormap default
        end
    end
end
if ~params.display.results.separate
    saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.jpg_dir,...
             dirs.slash, dirs.results_filename],...
             'jpg');
    saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
             dirs.slash, dirs.results_filename, '_color'],...
             'epsc');
    colormap gray;
    saveas(gcf, [dirs.parent_dir, dirs.slash, dirs.eps_dir,...
             dirs.slash, dirs.results_filename],...
             'eps');
    colormap default
end
