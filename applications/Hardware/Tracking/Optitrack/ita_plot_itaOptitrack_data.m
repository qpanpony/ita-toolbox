function varargout = ita_plot_itaOptitrack_data(LogData, LogInfo, varargin)
% function varargout = ita_plot_itaOptitrack_data(LogData, LogInfo, options)
%
% Plot routine for logged data after using itaOptitrack.startLogging /
% .stopLogging
%
% options: 'stepSize' ... only display every stepSize frame during animation [double]
%
% Author:  Florian Pausch, fpa@akustik.rwth-aachen.d
% Version: 2016-07-07
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

if nargin<2
   error('Function needs at least two input arguments!') 
end

sArgs          = struct('stepSize',7);
sArgs          = ita_parse_arguments(sArgs,varargin,1);
stepSize       = sArgs.stepSize; % step size for view/up animation

time = linspace(0,LogInfo.TotalFrames/LogInfo.CaptureFrameRate,LogInfo.TotalFrames);

hFig = figure('units','normalized','outerposition',[0 0 1 1]);
qFig1 = gobjects(size(LogData,2),1);
qFig2 = qFig1;
pFig4 = qFig1;
pFigt4 = qFig1;
hl1 = qFig1;
hl2 = qFig1;

vu = zeros(LogInfo.TotalFrames,6,size(LogData,2));
for jdx = 1:size(LogData,2)
    vu(:,:,jdx) = LogData(jdx).orientation.vu;
end

numColumns=4;
for idx=1:size(LogData,2)
    
    % initial orientation
    subplot(size(LogData,2),numColumns,numColumns*(idx-1)+1)
    plot(time,LogData(jdx).orientation.roll_deg)
    hold on
    plot(time,LogData(jdx).orientation.pitch_deg,'r')
    plot(time,LogData(jdx).orientation.yaw_deg,'g')
    title(['Orientation ',LogData(jdx).rigidBodyName])
    xlabel('Time in [sec]')
    ylabel('Orientation in [deg]')
    grid on
    axis tight
    
    % plot time cursor
    minvalOri = min([LogData(jdx).orientation.roll_deg; LogData(jdx).orientation.pitch_deg; LogData(jdx).orientation.yaw_deg]);
    maxvalOri = max([LogData(jdx).orientation.roll_deg; LogData(jdx).orientation.pitch_deg; LogData(jdx).orientation.yaw_deg]);
    hl1(idx) = line([0 0],[minvalOri maxvalOri],'color',[.5 .5 .5]);
    legend('Roll','Pitch','Yaw','Current Time Frame')
    
    % initial vu animation
    subplot(size(LogData,2),numColumns,numColumns*(idx-1)+2);
    % plot transparent sphere
    r = 1;
    [x,y,z] = sphere(20);
    x = x*r;
    y = y*r;
    z = z*r;
    
    lightGrey = 0.85*[1 1 1];
    s=surface(x,y,z,'FaceColor', 'none','EdgeColor',lightGrey);
    alpha(s,0.3)
    hold on
    
    axis([-r r -r r -r r])
    view([-1 1 1])
%     zoom(1.1)
    
    hold on
    
    qFig1(idx)=quiver3(0,0,0,vu(1,1,idx),vu(1,3,idx),vu(1,2,idx),'color','r','maxheadsize',.5,'linewidth',5);
    xlabel('x'),
    ylabel('z'),
    zlabel('y');
    hold on;

    qFig2(idx)=quiver3(0,0,0,vu(1,4,idx),vu(1,6,idx),vu(1,5,idx),'color','g','maxheadsize',.5,'linewidth',5);
    title(['View/Up vector ',LogData(jdx).rigidBodyName])
    
    % initial position
    subplot(size(LogData,2),numColumns,numColumns*(idx-1)+3)
    plot(time,LogData(jdx).position.x)
    hold on
    plot(time,LogData(jdx).position.y,'r')
    plot(time,LogData(jdx).position.z,'g')
    title(['Position ',LogData(jdx).rigidBodyName])
    xlabel('Time in [sec]')
    ylabel('Position in [m]')
    grid on
    legend('X','Y','Z')
    axis tight
    
    % plot time cursor
    xmin=min(LogData(jdx).position.x); xmax=max(LogData(jdx).position.x);
    ymin=min(LogData(jdx).position.y); ymax=max(LogData(jdx).position.y);
    zmin=min(LogData(jdx).position.z); zmax=max(LogData(jdx).position.z);
    minvalPos = min([xmin;ymin;zmin]);
    maxvalPos = max([xmax;ymax;zmax]);
    hl2(idx) = line([0 0],[minvalPos maxvalPos],'color',[.5 .5 .5]);
    
    % initial position animation
    subplot(size(LogData,2),numColumns,numColumns*(idx-1)+4);
    
    pFig4(idx)=plot3(LogData(jdx).position.x(1),LogData(jdx).position.y(1),LogData(jdx).position.z(1),'Marker','o','MarkerSize',10,'LineWidth',1.5);
    set(gca,'Xlim',[xmin-0.3,xmax+0.3], 'Zlim',[zmin-0.3,zmax+0.3])
    grid on;
    view(0,180)
    axis vis3d   
    title(['Position ',LogData(jdx).rigidBodyName])
    pFigt4(idx)=text(xmin-0.25,ymin,zmin-0.25,sprintf('y=%.3f m',round(LogData(jdx).position.y(1)*1000)/1000));
    xlabel('x')
    zlabel('z')

end

%% play vu animation

if stepSize>1    
   fprintf('[itaOptitrack.plot] Only every %d frame is displayed in animation!\n',stepSize)
end

for idx=2:stepSize:LogInfo.TotalFrames
    for idx2=1:size(LogData,2)
        
        if ~isnan(vu(idx,1,idx2))
            
            qFig1(idx2).UData = vu(idx,1,idx2);
            qFig1(idx2).VData = vu(idx,3,idx2);
            qFig1(idx2).WData = vu(idx,2,idx2);
            
            qFig2(idx2).UData = vu(idx,4,idx2);
            qFig2(idx2).VData = vu(idx,6,idx2);
            qFig2(idx2).WData = vu(idx,5,idx2);
            
            pFig4(idx2).XData = LogData(jdx).position.x(idx);
            pFig4(idx2).YData = LogData(jdx).position.y(idx);
            pFig4(idx2).ZData = LogData(jdx).position.z(idx);
            
            pFigt4(idx2).String = sprintf('y=%.3f m',round(LogData(jdx).position.y(idx)*1000)/1000);
            
            hl1(idx2).XData = [time(idx) time(idx)];
            hl2(idx2).XData = [time(idx) time(idx)];
            
        end
        
        drawnow
        
    end
end

if nargout
    varargout = {hFig};
else
    varargout = {};
end

end