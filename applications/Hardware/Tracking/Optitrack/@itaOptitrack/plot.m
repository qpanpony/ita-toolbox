function varargout = plot(this, varargin)
% Plot routine for itaOptitrack objects
% 
% % options: 'stepSize' ... only display every stepSize frame during animation [double]
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

sArgs          = struct('stepSize',7);
sArgs          = ita_parse_arguments(sArgs,varargin,1);
stepSize       = sArgs.stepSize; % step size for view/up animation

time = linspace(0,this.info.TotalFrames/this.info.CaptureFrameRate,this.info.TotalFrames);

hFig = figure('units','normalized','outerposition',[0 0 1 1]);
qFig1 = gobjects(this.numRigidBodies,1);
qFig2 = qFig1;
pFig4 = qFig1;
pFigt4 = qFig1;
hl1 = qFig1;
hl2 = qFig1;

vu = zeros(this.info.TotalFrames,6,this.numRigidBodies);
for jdx = 1:this.numRigidBodies
    vu(:,:,jdx) = this.data(jdx).orientation.vu;
end

numColumns=4;
for idx=1:this.numRigidBodies
    
    % initial orientation
    subplot(this.numRigidBodies,numColumns,numColumns*(idx-1)+1)
    plot(time,this.data(idx).orientation.roll_deg)
    hold on
    plot(time,this.data(idx).orientation.pitch_deg,'r')
    plot(time,this.data(idx).orientation.yaw_deg,'g')
    title(['Orientation ',this.data(idx).rigidBodyName])
    xlabel('Time in [sec]')
    ylabel('Orientation in [deg]')
    grid on
    axis square
    
    % plot time cursor
    minvalOri = min([this.data(idx).orientation.roll_deg; this.data(idx).orientation.pitch_deg; this.data(idx).orientation.yaw_deg]);
    maxvalOri = max([this.data(idx).orientation.roll_deg; this.data(idx).orientation.pitch_deg; this.data(idx).orientation.yaw_deg]);
    hl1(idx) = line([0 0],[minvalOri maxvalOri],'color',[.5 .5 .5]);
    legend('Roll','Pitch','Yaw','Current Time Frame')
    
    % initial vu animation
    subplot(this.numRigidBodies,numColumns,numColumns*(idx-1)+2);
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
    axis vis3d

    hold on
    
    qFig1(idx)=quiver3(0,0,0,vu(1,1,idx),vu(1,3,idx),vu(1,2,idx),'color','r','maxheadsize',.5,'linewidth',5);
    xlabel('x'),
    ylabel('z'),
    zlabel('y');
    hold on;

    qFig2(idx)=quiver3(0,0,0,vu(1,4,idx),vu(1,6,idx),vu(1,5,idx),'color','g','maxheadsize',.5,'linewidth',5);
    title(['View/Up vector ',this.data(idx).rigidBodyName])
    
    % initial position
    subplot(this.numRigidBodies,numColumns,numColumns*(idx-1)+3)
    plot(time,this.data(idx).position.x)
    hold on
    plot(time,this.data(idx).position.y,'r')
    plot(time,this.data(idx).position.z,'g')
    title(['Position ',this.data(idx).rigidBodyName])
    xlabel('Time in [sec]')
    ylabel('Position in [m]')
    grid on
    axis square
    
    % plot time cursor
    xmin=min(this.data(idx).position.x); xmax=max(this.data(idx).position.x);
    ymin=min(this.data(idx).position.y); ymax=max(this.data(idx).position.y);
    zmin=min(this.data(idx).position.z); zmax=max(this.data(idx).position.z);
    minvalPos = min([xmin;ymin;zmin]);
    maxvalPos = max([xmax;ymax;zmax]);
    hl2(idx) = line([0 0],[minvalPos maxvalPos],'color',[.5 .5 .5]);
    legend('Roll','Pitch','Yaw','Current Time Frame')
    
    % initial position animation
    subplot(this.numRigidBodies,numColumns,numColumns*(idx-1)+4);
    
    pFig4(idx)=plot3(this.data(idx).position.x(1),this.data(idx).position.y(1),this.data(idx).position.z(1),'Marker','o','MarkerSize',10,'LineWidth',1.5);
    set(gca,'Xlim',[xmin-0.3,xmax+0.3], 'Zlim',[zmin-0.3,zmax+0.3])
    grid on;
    view(0,180)
    axis vis3d   
    title(['Position ',this.data(idx).rigidBodyName])
    pFigt4(idx)=text(xmin-0.25,ymin,zmin-0.25,sprintf('y=%.3f m',round(this.data(idx).position.y(1)*1000)/1000));
    xlabel('x')
    zlabel('z')
    axis square

end

%% play vu animation

if stepSize>1    
   fprintf('[itaOptitrack.plot] Only every %d frame is displayed in animation!\n',stepSize)
end

for idx=2:stepSize:this.info.TotalFrames
    for idx2=1:this.numRigidBodies
        
        if ~isnan(vu(idx,1,idx2))
            
            qFig1(idx2).UData = vu(idx,1,idx2);
            qFig1(idx2).VData = vu(idx,3,idx2);
            qFig1(idx2).WData = vu(idx,2,idx2);
            
            qFig2(idx2).UData = vu(idx,4,idx2);
            qFig2(idx2).VData = vu(idx,6,idx2);
            qFig2(idx2).WData = vu(idx,5,idx2);
            
            pFig4(idx2).XData = this.data(idx2).position.x(idx);
            pFig4(idx2).YData = this.data(idx2).position.y(idx);
            pFig4(idx2).ZData = this.data(idx2).position.z(idx);
            
            pFigt4(idx2).String = sprintf('y=%.3f m',round(this.data(idx2).position.y(idx)*1000)/1000);
            
            hl1(idx2).XData = [time(idx) time(idx)];
            hl2(idx2).XData = [time(idx) time(idx)];
            
        end
        
    end
    
    drawnow
end

if nargout
    varargout = {hFig};
else
    varargout = {};
end

end