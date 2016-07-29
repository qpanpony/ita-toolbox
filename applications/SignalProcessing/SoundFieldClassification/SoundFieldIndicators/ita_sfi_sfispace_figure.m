function fgh = ita_sfi_sfispace_figure(varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs = struct('axh',[],'legend',true,'slices',false,'linewidth',4);
sArgs = ita_parse_arguments(sArgs,varargin);

%% Create and prepare figure
if isempty(sArgs.axh)
    fgh = figure();
    axh = axes();
else
    axh = sArgs.axh;
    axes(sArgs.axh);
end

slices = sArgs.slices;
ideal = true;

xlabel('$|C_{pp}|$');
ylabel('$\angle C_{pu}$');
zlabel('$|C_{pu}|$');
hold on;
set(axh,'Color','none');
set(axh,'Box','on');

%% Ideal Sound fields
if ideal
    % (Sensor) Noise %1
         npoints = 20;
    %     [x,y,z] = meshgrid(zeros(npoints,1),linspace(0,2*pi,npoints),linspace(0,1,npoints));
    %lh(1) = scatter3(x(:),y(:),z(:),'o');
        lh(1) = scatter3(zeros(1,npoints),linspace(0,2.*pi,npoints),zeros(1,npoints),'o');

 %   lh(1) = scatter3([0 0 0 0],[0 2*pi 2*pi 0],[0 0 1 1],'o');
    %set(lh(1),'FaceColor','none')
    %set(lh(1),'FaceColor',zeros(3,1));
    set(lh(1),'CData',[0 0 0],'LineWidth',sArgs.linewidth);
    % Diffuse sound field %2
    %lh(2) = plot3([1 1],[0 1], [0 0],'r');
    %set(lh(2),'Color',[1 0.5 0],'LineWidth',4);
    lh(2) = scatter3(ones(1,npoints),linspace(0,2.*pi,npoints),zeros(1,npoints),'o');
    %lh(2) = scatter3([1 1],[pi/2 3*pi/2],[0 0],'o');
    set(lh(2),'CData',[1 0 0],'LineWidth',sArgs.linewidth);
    % Modal %4
    lh(3) = scatter3([1 1],[pi/2 3*pi/2],[1 1],'o');
    set(lh(3),'CData',[0 0 1],'LineWidth',sArgs.linewidth);
    % Free field %3
    lh(4) = scatter3([1 1 1],[0 pi 2*pi] , [1 1 1],'o');
    set(lh(4),'CData',[0 1 0.5],'LineWidth',sArgs.linewidth);
    legend({'Noise','Diffuse','Reactive','Free'},'Location','EastOutside')
end


%
%
% % Get colors
% for idc = 1:numel(lh)
%     h = get(lh(idc));
%     if isfield(h,'Color')
%         cmap(idc,:) = h.Color;
%     else
%         cmap(idc,:) = h.CData;
%     end
% end
% for idx = 1:3
% cmap2(:,idx) = interp1(linspace(0,1,numel(lh)), cmap(:,idx), 0:0.1:1)
% end
% cmap2 = max(cmap2,0);
% cmap2 = min(cmap2,1);
% colormap(cmap2);

%colormap(cmap);

if slices
    
    [x,y,z] = meshgrid(0:1,[0 2*pi],0:1);
    V = rand(size(x));
    rStep = 0.01;
    [xi,yi,zi] = meshgrid(0:rStep:1,(0:rStep:1).*(2*pi),0:rStep:1);
    Vi = interp3(x,y,z,V,xi,yi,zi);
    
    xs = [1];
    ys = [2*pi];
    zs = [0];
    % sh = slice(xi,yi,zi,Vi,xs,ys,zs);
    
    sh = slice(xi,yi,zi,Vi,xs,ys,zs);
    
    for idx = 1:numel(sh);
        tmp = get(sh(idx));
        %nCData(:,:,1) = tmp.XData;
        %nCData(:,:,2) = tmp.YData;
        %nCData(:,:,3) = tmp.ZData;
        
        tmp.YData = abs( pi/2- mod(tmp.YData,pi))/pi*2; 
        
        nCData(:,:,3) = (1-tmp.YData) .* tmp.ZData;
        nCData(:,:,2) = (tmp.YData);
        nCData(:,:,1) = (1-tmp.ZData);
        
        nCData = bsxfun(@times,nCData, tmp.XData.^2);
        %nCData(1,:,:) = 0;
        
        set(sh(idx),'CData',nCData,'FaceAlpha',1,'LineStyle','none');
        clear nCData;
    end
else
    grid on;
end

%shading interp

% text(-0.1,0.5,0.5,'Noise')
% text(1.1,1.1,1.1,'Free')
% text(1.1,-0.1,1.1,'Reactive')
%  text(1.1,0.5,-0.1,'Diffuse')

%% Create patches
% % |C_pu| - |C_pp| - Ebene
% xdata = [0 1 0 ];
% ydata = [0 1 1 ];
% zdata = [0 0 0 ];
% cdata = [1 0 0 ;
%          0.5 1 0 ;
%          1 1 0];
% p = patch(xdata, ydata, zdata, zeros(size(xdata)));
%
% set(p,'FaceColor','interp',...
% 'FaceVertexCData',cdata);
%
% % <C_pu - |C_pp| - Ebene
% xdata = [0 0 0 0];
% ydata = [0 1 1 0];
% zdata = [0 0 1 1];
% cdata = [1 0 0 ;
%          1 1 0 ;
%          1 1 0;
%          1 0 0];
% p = patch(xdata, ydata, zdata, zeros(size(xdata)));
%
% set(p,'FaceColor','interp',...
% 'FaceVertexCData',cdata);
%
% % <C_pu - |C_pu| - Ebene
% xdata = [0 1 1 0];
% ydata = [1 1 1 1];
% zdata = [0 0 1 1];
% cdata = [1 1 0 ;
%          .5 1 0 ;
%          0 1 1;
%          1 1 0];
% p = patch(xdata, ydata, zdata, zeros(size(xdata)));
%
% set(p,'FaceColor','interp',...
% 'FaceVertexCData',cdata);
%

%% Limits
xlim([0 1]);
ylim([0 2*pi]);
zlim([0 1]);
view(-20,30);

set(axh,'YTick',(0:0.5:2)*pi)
set(axh,'YTickLabel',['$0               $'; '$\frac{1}{2} \pi $'; '$\pi             $'; '$\frac{3}{2} \pi $'; '$2\pi            $'])


%ita_savethisplot_rsc('filename','sfispace','graphsize',{'LineWidth'},'dpi',600)