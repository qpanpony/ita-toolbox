function hemisphere( ot, logData, position )
%HEMISPHERE Summary of this function goes here
%   Detailed explanation goes here

if strcmp(position, 'initial')
    % extract current calibration as initial position
    calibPosOrient = ot.dataCalibration.head;
    calibPos = calibPosOrient.position;
    x_0 = calibPos.x; 
    y_0 = calibPos.y;
    z_0 = calibPos.z;
    
    % initial orientation as reference
    calibOrient = calibPosOrient.orientation.rpy_deg;
    roll_deg  = calibOrient(1);
    pitch_deg = calibOrient(2);
    yaw_deg   = calibOrient(3);
    
elseif strcmp(position, 'current')
    x = logData.x;
    y = logData.y;
    z = logData.z;
    
    orient = itaOrientation(1);
    orient.qw = logData.qw;
    orient.qx = logData.qx;
    orient.qy = logData.qy;
    orient.qz = logData.qz;
end

% for ellipsoid
x_fac = 1;
y_fac = 1;
z_fac = 1;

if strcmp(position, 'initial')
                      % ellipsoid(x_centre, y_centre, z_centre, x_factor, y_factor, z_factor, n_gridmesh)
    [ix1, yps1, zet1] = ellipsoid(x_0, y_0, z_0, x_fac, y_fac, z_fac, 28);   
    eps = 3;
    xlim([x_0-eps  x_0+eps]);
    ylim([y_0-eps  y_0+eps]);
elseif strcmp(position, 'current')
    % head            ellipsoid(x_centre, y_centre, z_centre, x_factor, y_factor, z_factor, n_gridmesh)
    [iks, yps, zet] = ellipsoid(x, y, z, x_fac, y_fac, z_fac, 28);
    % % left ear
    % [ear_lx, ear_ly, ear_lz] = ellipsoid(ear_lx, ear_ly, ear_lz, 0.2, 0.2, 0.1, 28);
    % % right ear
    % [ear_rx, ear_ry, ear_rz] = ellipsoid(ear_rx, ear_ry, ear_rz, 0.2, 0.2, 0.1, 28);
    
    try % delete old plot
        delete(ot.movFig.head);
        delete(ot.movFig.nose);
        % delete(plt2_left_ear);
        % delete(plt2_right_ear);
    catch
        disp('ignore me');
    end
    
    hold on;
    alpha 0.3
    view(90, 0);
    axis off
    colormap('gray')
    
    iks_new = [iks(:,(ceil(size(iks,1)/4)):-1:1)   iks(:,end:-1:end-floor(size(iks,1)/4))];
    yps_new = [yps(:,(ceil(size(yps,1)/4)):-1:1)   yps(:,end:-1:end-floor(size(yps,1)/4))];
    zet_new = [zet(:,end-floor(size(zet,1)/4):end) zet(:,(ceil(size(zet,1)/4)):-1:1)];
%     iks_new = [iks(:,1:(ceil(size(iks,1)/4)))      iks(:,end-floor(size(iks,1)/4):end)];
%     yps_new = [yps(:,1:(ceil(size(yps,1)/4)))      yps(:,end-floor(size(yps,1)/4):end)];
%     zet_new = [zet(:,end-floor(size(zet,1)/4):end) zet(:,(ceil(size(zet,1)/4)):-1:1)];
    
    grey = [0.35,0.35,0.35];
    ot.movFig.nose = plot3(iks(floor(size(iks,1)/2),1), yps(floor(size(yps,1)/2),1), zet(floor(size(zet,1)/2),floor(size(zet,1)/2)), 'O', 'Color', grey, 'MarkerSize', 20);
    alpha 0.3
    ot.movFig.head = surf(iks_new, yps_new, zet_new, ...
        'EdgeColor', 'none', ...
        'FaceLighting','gouraud', ... % "gouraud" macht diese scheibenstruktur
        'FaceColor','interp',...
        'AmbientStrength',0);
    alpha 0.5
    
    if ot.iCount < 4
        light('Position',[-.5 .5 0],'Style','local');
        light('Position',[0 1 0],'Style','infinite');
    end
end


if strcmp(position, 'initial')
    green = [87/255,171/255,39/255];
    nose1 = plot3(ix1(floor(size(ix1,1)/2),1), yps1(floor(size(yps1,1)/2),1), zet1(floor(size(zet1,1)/2),floor(size(zet1,1)/2)), 'O', 'Color', green, 'MarkerSize', 20);
    alpha 0.3
    rotate(nose1, [0, 0, -1], roll_deg);
    rotate(nose1, [1, 0, 0],  pitch_deg);
    rotate(nose1, [0, 1, 0],  yaw_deg);
    hold on;
    
elseif strcmp(position, 'current')

    rotate(ot.movFig.head, [0, 0, -1], orient.roll_deg);
    rotate(ot.movFig.head, [1, 0, 0],  orient.pitch_deg);
    rotate(ot.movFig.head, [0, 1, 0],  orient.yaw_deg);
    
    rotate(ot.movFig.nose, [0, 0, -1], orient.roll_deg);
    rotate(ot.movFig.nose, [1, 0, 0],  orient.pitch_deg);
    rotate(ot.movFig.nose, [0, 1, 0],  orient.yaw_deg);
    
end

alpha 0.3;
end

