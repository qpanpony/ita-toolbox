function crosshair( otf, currentTrackingData, caseToPlot )
%CROSSHAIR plots the crosshair of an initial and a current position/orientation
% 
%crosshair([itaOptitrack] OptiTrack_object, 
%          [struct] currentTrackingData, 
%          [string] positionToPlot)
%   
%   
% [itaOptitrack] OptiTrack_object 
% [struct] currentTrackingData 
% [string] positionToPlot: 'initial' -- plot position to be reached
%                          'current' -- plot position to be corrected
% IMPORTANT:
% to get a proper plot of the crosshair, please do the following steps:
% 1.) place the tracking body (Rigid Body 1) on the test subject's head
% 2.) place the test subject on the right position in the correct orientation
% 3.) in Motive, go to "Capture Layout", select Rigid Body 1, go to 
%     "Transformation" and press "Reset To Current Orientation"
% 4.) now, immediately calibrate the head of the test subject
%     the suject must not move within steps 3 and 4!


% fprintf('i''m inside crosshair, %i\n', ot.iCount)
%% define plot colours
grey      = [0.25, 0.25, 0.25];
green     = [87/255,171/255,39/255]; % greenBright = [189/255, 205/255, 0];
blue      = [0/255,84/255,159/255];
yellow    = [246/255, 168/255, 0/255];
red       = [204/255, 7/255, 30/255];

% if ot.iCount == 1
if strcmp(caseToPlot, 'initial')
        subplotIndex = generate_figure_properties(otf); % add properties to figure
        prepare_images(otf, subplotIndex);                     % load smileys etc.
%     elseif strcmp(caseToPlot, 'training')
%         subplotIndex = generate_figure_properties(ot, true); % add properties to figure
%         prepare_images(ot, subplotIndex);                    % load smileys etc.
%     end
end

pauseTimeNormal = 2;
pauseTimeGOOD   = 1.5;
pauseTimeRead   = 6.5;
% pauseTimeNormal = .5;
% pauseTimeGOOD   = .5;
% pauseTimeRead   = .5;


%% extract position and orientation (initial and current)
% extract current calibration as initial position
% initial position as reference
calibPosOrient = otf.optiTrackObject.dataCalibration.head;
calibPos = calibPosOrient.position;
x_ref = calibPos.x; 
y_ref = calibPos.y;
z_ref = calibPos.z;

centre_ref = [x_ref, y_ref, z_ref];

% current position (centre_cur = current point)
x_0 = currentTrackingData.x;
y_0 = currentTrackingData.y;
z_0 = currentTrackingData.z;

% extract initial and current orientation
% initial orientation as reference
calibOrient = calibPosOrient.orientation;

a = -calibOrient.roll;
b = calibOrient.yaw;
c = calibOrient.pitch;

% rotation roll-pitch-yaw
R_ref = calculate_rotation_matrix(a,b,c);

% current orientation
orient    = itaOrientation(1);
orient.qw = currentTrackingData.qw;
orient.qx = currentTrackingData.qx;
orient.qy = currentTrackingData.qy;
orient.qz = currentTrackingData.qz;   

% define matrix for rotation roll-pitch-yaw
a = -orient.roll;
b = orient.yaw;
c = orient.pitch;

R_curr = calculate_rotation_matrix(a,b,c);

%% define tolerances to show whether subject hast to correct its position
                % [smallTolerance, mediumTolerance, largeTolerance]
toleranceOrient = [     0.8,            1.5,            10;  ...      % in °
                        0.8,            1.5,            10;  ...
                        0.6,            1.3,            10;       ];
tolerancePos    = [       1,            3.5,            5;   ...      % in cm
                          1,            3.5,            2.5; ... 
                          1,            3.5,            5;        ];


% calculate differences of current and initial position
rolDiff  = orient.roll_deg  - calibPosOrient.orientation.roll_deg;
pitDiff  = orient.pitch_deg - calibPosOrient.orientation.pitch_deg;
yawDiff  = orient.yaw_deg   - calibPosOrient.orientation.yaw_deg;
orientDiffs = [rolDiff, pitDiff, yawDiff];

xDiff    = (x_0 - x_ref)*10^2; % values in cm, therefore *10^2
yDiff    = (y_0 - y_ref)*10^2;
zDiff    = (z_0 - z_ref)*10^2;
% posDiffs = [xDiff; yDiff; zDiff;];

% define radius of circle and size of cross
r = 7;
x = [0, 0];  y = [-0.1*r, 0.1*r];  z = [0, 0];
lim = 1.2; % range for plot size

if strcmp(caseToPlot, 'initial') % plot green cross-hair as reference only in the first call of this function
    
    alpha(1) = 0; alpha(2) = 360; % temporary helper variable to plot circle
    radius = r;
    [xCirc, yCirc, zCirc] = create_circle(radius, alpha);
    
    subplot('position',  [0.24, 0.3, 0.56, 0.56])

    xyz1 = [x; y; z];
    xyz1 = R_ref*xyz1;
    xyz2 = [y; x; z];
    xyz2 = R_ref*xyz2;

    xyzCirc = [xCirc; yCirc; zCirc];
    xyzCirc = R_ref*xyzCirc;

    otf.(otf.figName).crss_ref = plot3(xyz1(1,:) + x_ref, xyz1(2,:) + y_ref, xyz1(3,:) + z_ref, '-', ...
                               xyz2(1,:) + x_ref, xyz2(2,:) + y_ref, xyz2(3,:) + z_ref, '-', ...
                               'Color', green, 'LineWidth', 2.5);
    hold on;
    otf.(otf.figName).circ_ref = plot3(xyzCirc(1,:) + x_ref, ...
                               xyzCirc(2,:) + y_ref, ...
                               xyzCirc(3,:) + z_ref, ...
                               'LineWidth', 2.5, 'Color', green);

    view(0,90);
    xlim 'manual'; xlim([-lim+x_ref,  lim+x_ref]);
    ylim 'manual'; ylim([-lim+y_ref,  lim+y_ref]);
    zlim 'manual'; zlim([-lim+z_ref,  lim+z_ref]);
    axis equal;
    axis off;

%     set(ot.(ot.figName), 'MenuBar', 'figure'); % 2DO: wieder raus

    % draw arrow for roll
    whichArrow = 'rol';
    draw_orientation_arrows(otf, r, centre_ref, blue, whichArrow, orientDiffs, orient, R_ref, toleranceOrient(1,:), rolDiff);
    
    % draw arrows for x, y, z
    draw_position_arrows(otf, x,y,z, centre_ref, blue, 'y');
    draw_position_arrows(otf, x,y,z, centre_ref, blue, 'x');
%     draw_position_arrows(ot, x,y,z, centre_ref, blue, 'z');
    
    
%% current position and orientation
elseif strcmp(caseToPlot, 'current')

    % delete plots of old frame
    try %#ok<TRYNC>
        delete(otf.(otf.figName).crss);
        delete(otf.(otf.figName).circ);
        
        delete(otf.(otf.figName).pitArrow);
        
        delete(otf.(otf.figName).xxxAnnotation);
        delete(otf.(otf.figName).yyyAnnotation);
        delete(otf.(otf.figName).zzzAnnotation);
        delete(otf.(otf.figName).rolAnnotation);
        delete(otf.(otf.figName).pitAnnotation);
        delete(otf.(otf.figName).yawAnnotation);
    end
    
    % make new plots of current frame
    radius = r + (z_ref - z_0)*10; % zoom for front/back
    y = [-0.1*radius, 0.1*radius]; % endpoints of cross' line
    alpha(1) = 0;    alpha(2) = 360;

    [xCirc, yCirc, zCirc] = create_circle(radius, alpha);

    % rotate cross
    xyz1 = [x; y; z];
    xyz1 = R_curr*xyz1;
    xyz2 = [y; x; z];
    xyz2 = R_curr*xyz2;
    % rotate circle
    xyzCirc = [xCirc; yCirc; zCirc];
    xyzCirc = R_curr*xyzCirc;
    
    % plot cross and circle of current position
    subplot('position',  [0.24, 0.3, 0.56, 0.56]);
    hold on;
    otf.(otf.figName).crss = plot3(xyz1(1,:) + x_0, xyz1(2,:) + y_0, xyz1(3,:) + z_0, '-', ...
                           xyz2(1,:) + x_0, xyz2(2,:) + y_0, xyz2(3,:) + z_0, '-', ...
                           'Color', grey, 'LineWidth', 2.5);
    otf.(otf.figName).circ = plot3(xyzCirc(1,:) + x_0, xyzCirc(2,:) + y_0, xyzCirc(3,:) + z_0, ...
                           'LineWidth', 2.5, 'Color', grey);
% 	view(0,90);
    show_arrows(otf, rolDiff, 'rol', toleranceOrient(1,:));
    show_arrows(otf, yDiff,   'y',   tolerancePos(1,:));
    
    % show nose for pitch and yaw
    draw_orientation_arrows(otf, r, centre_ref, blue, 'pit', orientDiffs, orient, R_ref, toleranceOrient(2,:), pitDiff);
    % show arrow for z
%     show_arrows(ot, zDiff,   'z',   tolerancePos(3,:));

    % show arrows for yaw, x and z -- (display only in figure south west)
    show_arrows(otf, xDiff, 'x', tolerancePos(1,:));
    
    % show difference of initial and current position via smileys
    myColour = [green; yellow; red;];
    show_some_smileys(otf, yDiff,   'yyyDiff', tolerancePos(2,:),    myColour, 32);
    show_some_smileys(otf, pitDiff, 'pitDiff', toleranceOrient(2,:), myColour, 35);
    show_some_smileys(otf, rolDiff, 'rolDiff', toleranceOrient(1,:), myColour, 34);

    show_some_smileys(otf, yawDiff, 'yawDiff', toleranceOrient(3,:), myColour, 36);
    show_some_smileys(otf, xDiff,   'xxxDiff', tolerancePos(1,:),    myColour, 31);
    show_some_smileys(otf, zDiff,   'zzzDiff', tolerancePos(3,:),    myColour, 33);
%     centre_ref
    
elseif strcmp(caseToPlot, 'training')
    
%     centre_ref
    if otf.iCount == 1
        
        % create all the text parts and their text fields
        createTxtPartsAndFields(otf);
        
        showExplanation(otf, grey);
        
        %% draw initial crosshair
        
        alpha(1) = 0; alpha(2) = 360;
        radius = r;
        [xCirc, yCirc, zCirc] = create_circle(radius, alpha);
        if ~strcmp(otf.train, 'all') && ~strcmp(otf.train, '') && ~strcmp(otf.train, 'end')
            subplot(2,3,5);
            ax = gca;
            ax.YDir = 'normal';
            hold on;

            % create points for cross of crosshair
            xyz1 = [x; y; z];
            xyz1 = R_ref*xyz1;
            xyz2 = [y; x; z];
            xyz2 = R_ref*xyz2;

            xyzCirc = [xCirc; yCirc; zCirc];
            xyzCirc = R_ref*xyzCirc;

            otf.(otf.figName).crss_ref = plot3(xyz1(1,:) + x_ref, xyz1(2,:) + y_ref, xyz1(3,:) + z_ref, '-', ...
                xyz2(1,:) + x_ref, xyz2(2,:) + y_ref, xyz2(3,:) + z_ref, '-', ...
                'Color', green, 'LineWidth', 2.5);
            otf.(otf.figName).circ_ref = plot3(xyzCirc(1,:) + x_ref, ...
                xyzCirc(2,:) + y_ref, ...
                xyzCirc(3,:) + z_ref, ...
                'LineWidth', 2.5, 'Color', green);

%             view(0,90);
            xlim 'manual'; xlim([-2*lim+x_ref,  2*lim+x_ref]);
            ylim 'manual'; ylim([-2*lim+y_ref,  2*lim+y_ref]);
            zlim 'manual'; zlim([-2*lim+z_ref,  2*lim+z_ref]);
            axis off

            % draw arrow for x, y, z
            draw_position_arrows(otf, x,y,z, centre_ref, blue, 'x');
            draw_position_arrows(otf, x,y,z, centre_ref, blue, 'y');
%             draw_position_arrows(ot, x,y,z, centre_ref, blue, 'z');

            % draw arrow for roll
            draw_orientation_arrows(otf, r, centre_ref, blue, 'rol', orientDiffs, orient, R_ref, toleranceOrient(1,:), rolDiff);

            otf.train = 'x';
        end
    end
    
    % delete old plot
    try
        delete(otf.(otf.figName).crss);
        delete(otf.(otf.figName).circ);
        delete(otf.(otf.figName).pitArrow);
    catch
        error('what a pitty');
    end
    %% draw current crosshair for left side plot
    radius = r + (z_ref - z_0)*10; % zoom for front/back
    y = [-0.1*radius, 0.1*radius]; % endpoints of cross' line
    alpha(1) = 0;    alpha(2) = 360;

    [xCirc, yCirc, zCirc] = create_circle(radius, alpha);
    if ~strcmp(otf.train, 'all') && ~strcmp(otf.train, '') && ~strcmp(otf.train, 'end')
        subplot(2,3,5);
        ax = gca;
        ax.YDir = 'normal';
        % rotate cross
        xyz1 = [x; y; z];
        xyz1 = R_curr*xyz1;
        xyz2 = [y; x; z];
        xyz2 = R_curr*xyz2;
        % rotate circle
        xyzCirc = [xCirc; yCirc; zCirc];
        xyzCirc = R_curr*xyzCirc;
        
        % plot cross and circle of current position
        otf.(otf.figName).crss = plot3(xyz1(1,:) + x_0, xyz1(2,:) + y_0, xyz1(3,:) + z_0, '-', ...
                               xyz2(1,:) + x_0, xyz2(2,:) + y_0, xyz2(3,:) + z_0, '-', ...
                               'Color', grey, 'LineWidth', 2.5);
        otf.(otf.figName).circ = plot3(xyzCirc(1,:) + x_0, xyzCirc(2,:) + y_0, xyzCirc(3,:) + z_0, ...
                               'LineWidth', 2.5, 'Color', grey);
    end
    %% train orientations for plot on the right
%     draw_orientation_arrows(ot, r, centre_ref, blue, ot.train, orientDiffs, orient, R_ref, toleranceOrient(3,:), yawDiff);
%     draw_orientation_arrows(ot, r, centre_ref, blue, ot.train, orientDiffs, orient, R_ref, toleranceOrient(2,:), pitDiff);
    if strcmp(otf.train, 'x')
        set(otf.txtField{7},'string',otf.txtPart{17},  'HorizontalAlignment', 'center', 'Visible', 'on');
        show_arrows(otf, xDiff, otf.train, tolerancePos(1,:))
        
        if otf.first && otf.second && otf.third
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1}, 'visible', 'off');
            otf.train = 'y';
            otf.first  = 0;
            otf.second = 0;
            otf.third  = 0;
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);
            
            set(otf.txtField{6},'string',otf.txtPart{25},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeNormal);
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{6}, 'visible', 'off');
            
            set(otf.(otf.figName).xArrowTipLowr, 'visible', 'off');
            set(otf.(otf.figName).xArrowTipGrtr, 'visible', 'off');
            set(otf.(otf.figName).xArrow, 'visible', 'off');
        end
    elseif strcmp(otf.train, 'y')
        set(otf.txtField{7},'string',otf.txtPart{22},  'HorizontalAlignment', 'center', 'Visible', 'on');
%         show_arrows(ot, yDiff,   ot.train,   tolerancePos(2,:))
        show_arrows(otf, -yDiff,   otf.train,   tolerancePos(2,:)) % HIER:(07.03.) -yDiff
        
        if otf.first && otf.second && otf.third
            set(otf.txtField{1}, 'visible', 'off');
            otf.train = 'z';
            otf.first  = 0;
            otf.second = 0;
            otf.third  = 0;
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);
            
            set(otf.txtField{6},'string',otf.txtPart{26},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeNormal);
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{6}, 'visible', 'off');
            
            set(otf.(otf.figName).yArrowTipLowr, 'visible', 'off');
            set(otf.(otf.figName).yArrowTipGrtr, 'visible', 'off');
            set(otf.(otf.figName).yArrow, 'visible', 'off');
        end
    elseif strcmp(otf.train, 'z')
        set(otf.txtField{7},'string',otf.txtPart{19},  'HorizontalAlignment', 'center', 'Visible', 'on');
        show_arrows(otf, zDiff, otf.train, tolerancePos(3,:))
        
        if otf.first && otf.second && otf.third
            set(otf.txtField{1}, 'visible', 'off');
            otf.train = 'yaw';
            otf.first  = 0;
            otf.second = 0;
            otf.third  = 0;
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);

            set(otf.txtField{6},'string',otf.txtPart{21},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeRead);
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{6}, 'visible', 'off');
            
%             set(ot.(ot.figName).zArrowTipLowr, 'visible', 'off');
%             set(ot.(ot.figName).zArrowTipGrtr, 'visible', 'off');
%             set(ot.(ot.figName).zArrow, 'visible', 'off');
        end
    elseif strcmp(otf.train, 'yaw')
        set(otf.txtField{7},'string',otf.txtPart{20},  'HorizontalAlignment', 'center', 'Visible', 'on');
        draw_orientation_arrows(otf, r, centre_ref, blue, otf.train, orientDiffs, orient, R_ref, toleranceOrient(3,:), yawDiff);
        
        if otf.first && otf.second && otf.third
            set(otf.txtField{1}, 'visible', 'off');
            otf.train = 'rol';
            otf.first  = 0;
            otf.second = 0;
            otf.third  = 0;
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);
            set(otf.txtField{1}, 'visible', 'off');
            
            set(otf.txtField{6},'string',otf.txtPart{27},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeNormal);
            set(otf.txtField{6}, 'visible', 'off');
            
        end
    elseif strcmp(otf.train, 'rol')
        set(otf.txtField{7},'string',otf.txtPart{23},  'HorizontalAlignment', 'center', 'Visible', 'on');
        show_arrows(otf, rolDiff,   otf.train,   toleranceOrient(1,:))
        
        if otf.first && otf.second && otf.third
            set(otf.txtField{1}, 'visible', 'off');
            otf.train = 'pit';
            otf.first  = 0;
            otf.second = 0;
            otf.third  = 0;
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);
            
            set(otf.txtField{6},'string',otf.txtPart{28},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeRead);
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{6}, 'visible', 'off');
            
            set(otf.(otf.figName).rolArrowTipLowr, 'visible', 'off');
            set(otf.(otf.figName).rolArrowTipGrtr, 'visible', 'off');
            set(otf.(otf.figName).rolArrow, 'visible', 'off');
        end
    elseif strcmp(otf.train, 'pit')
        set(otf.txtField{7},'string',otf.txtPart{24},  'HorizontalAlignment', 'center', 'Visible', 'on');
        try
            delete(otf.(otf.figName).pitArrow);
        catch
            error('what a pitty');
        end
        % 2DO: ersetzt ja yaw-arrow, aber die yawDiff wird hier nicht
        draw_orientation_arrows(otf, r, centre_ref, blue, otf.train, orientDiffs, orient, R_ref, toleranceOrient(2,:), pitDiff);
        if otf.first && otf.second && otf.third
            otf.train = 'all';
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{7}, 'visible', 'off');
            set(otf.txtField{1},'string',otf.txtPart{18},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeGOOD);
            
            try %#ok<TRYNC>
                set(otf.(otf.figName).crss, 'visible', 'off');
                set(otf.(otf.figName).circ, 'visible', 'off');
                set(otf.(otf.figName).circ_ref, 'visible', 'off');
                set(otf.(otf.figName).crss_ref, 'visible', 'off');
                set(otf.(otf.figName).pitArrow, 'visible', 'off');
                set(otf.(otf.figName).rolArrow, 'visible', 'off');
                set(otf.(otf.figName).rolArrowTipLowr, 'visible', 'off');
                set(otf.(otf.figName).rolArrowTipGrtr, 'visible', 'off');
                set(otf.(otf.figName).xArrow, 'visible', 'off');
                set(otf.(otf.figName).xArrowTipLowr, 'visible', 'off');
                set(otf.(otf.figName).xArrowTipGrtr, 'visible', 'off');
                set(otf.(otf.figName).yArrow, 'visible', 'off');
                set(otf.(otf.figName).yArrowTipGrtr, 'visible', 'off');
                set(otf.(otf.figName).yArrowTipLowr, 'visible', 'off');
            end
            
            set(otf.txtField{6},'string',otf.txtPart{29},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeNormal);
            set(otf.txtField{1}, 'visible', 'off');
            set(otf.txtField{6}, 'visible', 'off');
            set(otf.(otf.figName).pitArrow, 'visible', 'off');
            
            set(otf.txtField{1},'string',otf.txtPart{31},  'HorizontalAlignment', 'center', 'Visible', 'on');
            pause(pauseTimeNormal);
            set(otf.txtField{1}, 'visible', 'off');
 
        end
    elseif strcmp(otf.train, 'all')

        otf.iCount = 0;
        otf.train = '';
%         ot.doTraining = false;
        try %#ok<TRYNC>
            delete(otf.(otf.figName).crss);
            delete(otf.(otf.figName).circ);
            delete(otf.(otf.figName).crss_ref);
            delete(otf.(otf.figName).circ_ref);
            
            
        end
        return;
    elseif strcmp(otf.train, '')
        otf.doTraining = false;  % HIER: gucken, ob das das problem löst, dass der plot noch mal kurz aufploppt am ende des trainings
        try %#ok<TRYNC>
            delete(otf.(otf.figName).crss);
            delete(otf.(otf.figName).circ);
            delete(otf.(otf.figName).crss_ref);
            delete(otf.(otf.figName).circ_ref);
            
            
        end
    end
    
else
    error('invalid input for caseToPlot: %s', caseToPlot);
    
end

end

function draw_position_arrows(ot, x,y,z, centre_ref, colour, whichArrow)
% draw arrows that show how the subject has to correct its position
    
    x_ref = centre_ref(1); 
    y_ref = centre_ref(2);
    z_ref = centre_ref(3);
    additive = 0.75;
    if strcmp(whichArrow, 'x')
        plotAsX = y + x_ref;
        plotAsY = x + y_ref - 1.25*additive;
        plotAsZ = z + z_ref ;
    elseif strcmp(whichArrow, 'y')
        plotAsX = x + x_ref + 1.25*additive;
        plotAsY = y + y_ref;
        plotAsZ = z + z_ref;
    elseif strcmp(whichArrow, 'z')
        plotAsX = x + x_ref - 1.25*additive;
        plotAsY = z + y_ref;
        plotAsZ = y + z_ref;
    end
%     if ~strcmp(ot.train, '') || ~strcmp(ot.train, 'end')
%         view(0,-90);
%     end
%     axis on;
    if ~strcmp(whichArrow, 'z')
        ot.(ot.figName).([whichArrow, 'Arrow'])  = plot3(plotAsX, plotAsY, plotAsZ, 'LineWidth', 2.5, 'Color', colour);
    else
        ot.(ot.figName).([whichArrow, 'Arrow'])  = plot3(plotAsX, plotAsY, plotAsZ, 'O', 'MarkerSize', 15, 'LineWidth', 2.5, 'Color', colour);
    end
    
    switch whichArrow
        case 'x'
            % create and plot tip for lower arrow
            p1 = [y(end) + x_ref; ...
                  x(end) + y_ref - 1.25*additive; ...
                  z(end) + z_ref;];
            p2 = p1 + [1;0;0];
            ot.(ot.figName).xArrowTipLowr = draw_tip(p1, p2, colour, whichArrow);
            % create and plot tip for greater arrow
            p1 = [y(1) + x_ref; ...
                  x(1) + y_ref - 1.25*additive; ...
                  z(1) + z_ref;];
            p2 = p1 - [1;0;0];
            ot.(ot.figName).xArrowTipGrtr = draw_tip(p1, p2, colour, whichArrow);
            
        case 'y'
            % create and plot tip for lower arrow
            p1 = [x(end) + x_ref + 1.25*additive; ...
                  y(end) + y_ref; ...
                  z(end) + z_ref;];
            p2 = p1 - [0;1;0];
            ot.(ot.figName).yArrowTipLowr = draw_tip(p1, p2, colour, whichArrow);
            
            % create and plot tip for greater arrow
            p1 = [x(1) + x_ref + 1.25*additive; ...
                  y(1) + y_ref; ...
                  z(1) + z_ref;];
            p2 = p1 + [0;1;0];
            ot.(ot.figName).yArrowTipGrtr = draw_tip(p1, p2, colour, whichArrow);
     %% für training vielleicht noch behalten
%         case 'z'
%             
%             % create and plot tip for lower arrow
%             p1 = [x(end) + x_ref - 1.25*additive; ...
%                   z(end) + y_ref; ...
%                   y(end) + z_ref;];
%             p2 = p1 + [0;0;1];
%             ot.(ot.figName).zArrowTipLowr = draw_tip(p1, p2, colour, whichArrow);
%             
%             % create and plot tip for greater arrow
%             p1 = [x(1) + x_ref - 1.25*additive; ...
%                   z(1) + y_ref; ...
%                   y(1) + z_ref;];
%             p2 = p1 - [0;0;1];
%             ot.(ot.figName).zArrowTipGrtr = draw_tip(p1, p2, colour, whichArrow);
        case 'z'
            ot.(ot.figName).([whichArrow, 'ArrowTipGrtr'])  = plot3(plotAsX, plotAsY, plotAsZ, 'X', 'MarkerSize', 15, 'LineWidth', 2.5, 'Color', colour);
            ot.(ot.figName).([whichArrow, 'ArrowTipLowr'])  = plot3(plotAsX, plotAsY, plotAsZ, 'O', 'MarkerSize', 2, 'LineWidth', 2.5, 'Color', colour);
        otherwise
            disp('ungültige eingabe für whichArrow in crosshair>draw_arrows, %s', whichArrow);
    end
    
    set(ot.(ot.figName).([whichArrow, 'Arrow']), 'visible', 'off');
    set(ot.(ot.figName).([whichArrow, 'ArrowTipLowr']), 'visible', 'off');
    set(ot.(ot.figName).([whichArrow, 'ArrowTipGrtr']), 'visible', 'off');
    
end

function draw_orientation_arrows(varargin)
%        draw_orientation_arrows(ot, r, centre_ref, colour, whichArrow, orientDiffs, orient, R, tolerance, thatDiff)
% draw arrows that show how the subject has to correct its orientation
% exception: for "pitch", there is no arrow but a virtual 'nose' shown at
%            the reference crosshair

ot          = varargin{1};
r           = varargin{2};
centre_ref  = varargin{3};
colour      = varargin{4};
whichArrow  = varargin{5};
orientDiffs = varargin{6};
orient = varargin{7};
R = varargin{8};
if nargin > 8
    tolerance = varargin{9};
    thatDiff  = varargin{10};
end
% if ~strcmp(ot.train, '') || ~strcmp(ot.train, 'end')
%     view(0,-90);
% end
% axis on;
    switch whichArrow
        case 'rol'
            inx = 1;
            alpha(1) = 40;  alpha(2) = 140;
            radius = r + 2.5;
            [xCirc, yCirc, zCirc] = create_circle(radius, alpha);
            xyzCirc = [xCirc; yCirc; zCirc];
            xyzCirc = R*xyzCirc; % rotate
            xyzCirc = [xyzCirc(1,:) + centre_ref(1); xyzCirc(2,:) + centre_ref(2); xyzCirc(3,:) + centre_ref(3)];
            
            % show roll arrow (display only in figure north east)
            ot.(ot.figName).rolArrow        = plot3(xyzCirc(1,:), xyzCirc(2,:), xyzCirc(3,:), 'LineWidth', 2.5, 'Color', colour);
            ot.(ot.figName).rolArrowTipLowr = draw_tip(xyzCirc(:,1), xyzCirc(:,2), colour, whichArrow); % 2DO: eig müssen die andersherum
            ot.(ot.figName).rolArrowTipGrtr = draw_tip(xyzCirc(:,end), xyzCirc(:,end-1), colour, whichArrow);
            
            if sign(orientDiffs(inx)) > 0
                set(ot.(ot.figName).rolArrowTipLowr, 'visible', 'off');
            else
                set(ot.(ot.figName).rolArrowTipGrtr, 'visible', 'off');
            end
            xlim([centre_ref(1)-1, centre_ref(1)+1])
            ylim([centre_ref(2)-1, centre_ref(2)+1])
            
            if ot.doTraining
               set(ot.(ot.figName).rolArrow, 'visible', 'off');
               set(ot.(ot.figName).rolArrowTipLowr, 'visible', 'off');
               set(ot.(ot.figName).rolArrowTipGrtr, 'visible', 'off');
            end
           
        case {'pit', 'yaw'}

            xyz = centre_ref';
            additive = [-orient.yaw;orient.pitch;-.1]; % translate pitch movement to y-translation % HIER: 26.02. (0 durch -orient.yaw ersetzt)
            ot.(ot.figName).pitArrow = plot3((xyz(1) + additive(1)), ...
                                             (xyz(2) + additive(2)), ...
                                             (xyz(3) + additive(3)), ...
                                             'O', 'MarkerSize', 15, 'Color', colour, ...
                                             'LineWidth', 2.5);
            if strcmp(whichArrow, 'pit')
                inx = 2;
            else
                inx = 3;
            end
            if ot.doTraining && (abs(orientDiffs(inx)) > tolerance(3))
               if sign(thatDiff) == -1
                   ot.first  = 1;
               elseif sign(thatDiff) == 1
                   ot.second = 1;
               end
           end
           if ot.doTraining && ot.first && ot.second && (abs(orientDiffs(inx)) < tolerance(1))
               ot.third = 1;
           end
        otherwise
            disp('ungültige eingabe für whichArrow in crosshair>draw_arrows, %s', whichArrow);
    end

end

function [tip] = draw_tip(varargin)
%        [tip] = draw_tip(p1, p2, colour, posOrOrient, diff)
% this function draws the tips of the position and orientation arrows

p1          = varargin{1};
p2          = varargin{2};
colour      = varargin{3};
posOrOrient = varargin{4};
    
    linSeg = p1 - p2;
    len = 0.1;

    switch posOrOrient
%         case 'yaw'
%             no2 = [-linSeg(1);  linSeg(2); linSeg(3)];
%             no2 = 0.01*no2/norm(no2);
%             no1 = [ linSeg(1); -linSeg(2); linSeg(3)];
%             no1 = 0.01*no1/norm(no1);
%             temp = [0;len;0];
        case 'rol'
            no1 = [-linSeg(2);  linSeg(1); linSeg(3)];
            no2 = [ linSeg(2); -linSeg(1); linSeg(3)];
        case 'pit'
            error('not here');
        case 'x'
            no1 = [-linSeg(2);  linSeg(1);  linSeg(3)];
            no1 = 0.01*no1/norm(no1);
            no2 = [ linSeg(2); -linSeg(1); -linSeg(3)];
            no2 = 0.01*no2/norm(no2);
            temp = [len;0;0];
        case 'y'
            no2 = [-linSeg(2);  linSeg(1); linSeg(3)];
            no2 = 0.01*no2/norm(no2);
            no1 = [ linSeg(2); -linSeg(1); linSeg(3)];
            no1 = 0.01*no1/norm(no1);
            temp = [0;len;0];
        case 'z'
            no2 = [-linSeg(3);  linSeg(2); linSeg(1)];
            no2 = 0.01*no2/norm(no2);
            no1 = [ linSeg(3); -linSeg(2); linSeg(1)];
            no1 = 0.01*no1/norm(no1);
            temp = [0;len;0];
        otherwise
            error('[crosshair>draw_tip]: invalid input for posOrOrient: %s\nchoose one of "x", "y", "z" or "rol", "pit", "yaw".', posOrOrient);
    end
    
    newPt1  = p1 + 5*no1;
    newLin1 = [p1, newPt1];
    newPt2  = p1 + 5*no2;
    newLin2 = [p1, newPt2];
    plt1 = plot3(newLin1(1,:), newLin1(2,:), newLin1(3,:), '-', 'LineWidth', 2.5, 'Color', colour);
    plt2 = plot3(newLin2(1,:), newLin2(2,:), newLin2(3,:), '-', 'LineWidth', 2.5, 'Color', colour);

    % define direction of arrow tip
    if strcmp(posOrOrient, 'rol')
        tmp = no1 - no2;
        switch posOrOrient
%             case 'yaw' % für training behalten
%                 tang = [-tmp(3); tmp(2); tmp(1)];
            case 'rol'
                tang = [-tmp(2); tmp(1); tmp(3)]; % [tmp(2); -tmp(1); tmp(3)];
            otherwise
                error('[crosshair>draw_tip] should not see this: %s', posOrOrient);
        end
        newPt = p1 - 5*tang;
    elseif strcmp(posOrOrient, 'x')
        newdiff = p1(1) - p2(1);
        if newdiff > 0
            newPt = p1 - temp;
        else
            newPt = p1 + temp;
        end
    elseif strcmp(posOrOrient, 'y')
        newdiff = p1(2) - p2(2);
        if newdiff < 0
            newPt = p1 - temp;
        else
            newPt = p1 + temp;
        end
    elseif strcmp(posOrOrient, 'z') % für training behalten
        newdiff = p1(3) - p2(3);
        if newdiff > 0
            newPt = p1 - temp;
        else
            newPt = p1 + temp;
        end
    end
    
    % plot rest of arrow tip
    Lin1 = [newPt1, newPt];
    Lin2 = [newPt2, newPt];
    plt3 = plot3(Lin1(1,:), Lin1(2,:), Lin1(3,:), '-', 'LineWidth', 2.5, 'Color', colour);
    plt4 = plot3(Lin2(1,:), Lin2(2,:), Lin2(3,:), '-', 'LineWidth', 2.5, 'Color', colour);
    
    tip = [plt1, plt2, plt3, plt4];
end

function show_arrows(ot, thatDiff, thatDiffName, tolerance)
% set arrow(s) of thatDiffName visible if thatDiff greater that tolerance
% otherwise set arrow(s) invisible

    if ot.doTraining && (abs(thatDiff) > tolerance(3))
        if sign(thatDiff) == -1
            ot.first  = 1;
        elseif sign(thatDiff) == 1
            ot.second = 1;
        end
    end
    if abs(thatDiff) > tolerance(1)
        if ~strcmp(thatDiffName, 'z') && ~strcmp(ot.train, 'y')% don't show arrows for z as they are not helpful
            set(ot.(ot.figName).([thatDiffName, 'Arrow']), 'visible', 'on');
            if sign(thatDiff) < 0
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipLowr']), 'visible', 'on');
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipGrtr']), 'visible', 'off');
            else
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipGrtr']), 'visible', 'on');
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipLowr']), 'visible', 'off');
            end
        end
    else
        if ~strcmp(thatDiffName, 'z')
            set(ot.(ot.figName).([thatDiffName, 'Arrow'       ]), 'visible', 'off');
            set(ot.(ot.figName).([thatDiffName, 'ArrowTipLowr']), 'visible', 'off');
            set(ot.(ot.figName).([thatDiffName, 'ArrowTipGrtr']), 'visible', 'off');
        end
        if strcmp(thatDiffName, 'y') && strcmp(ot.train, 'y')
            set(ot.(ot.figName).([thatDiffName, 'Arrow']), 'visible', 'on');
            if sign(thatDiff) < 0
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipLowr']), 'visible', 'off');
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipGrtr']), 'visible', 'on');
            else
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipGrtr']), 'visible', 'off');
                set(ot.(ot.figName).([thatDiffName, 'ArrowTipLowr']), 'visible', 'on');
            end
        end
        % if both extremes have been reached, while training 
        if ot.doTraining && (ot.first && ot.second)
            ot.third = 1;
        end
    end
end

function show_some_smileys(ot, thatDiff, thatDiffName, tolerance, colour, subplotIndex)
%        show_some_smileys(ot, posOrOriDiffs, posOriDiffNames, toleranceOri, tolerancePos, colour, subplotIndex)
% this function shows smileys depending on the current orientation of the
% subject

    % define plot parameters ...
    LinWid = 1.5; marg = 0.5; FonSiz = 11*exp(ot.(ot.figName).Position(4)/550-1);
    
    tmpPos = get(ot.(ot.figName).(['sp_', num2str(subplotIndex)]), 'Position');
    plotPos = [tmpPos(1), tmpPos(2)-0.1, tmpPos(3), 2*tmpPos(4)];
    toleranceSmall = tolerance(1);
    toleranceLarge = tolerance(2);
    switch thatDiffName
        case {'rolDiff', 'pitDiff', 'yawDiff'}
            unit = '°';
            if strcmp(thatDiffName, 'rolDiff')
                posOrientNames = 'roll';
            elseif strcmp(thatDiffName, 'pitDiff')
                posOrientNames = 'pitch';
            elseif strcmp(thatDiffName, 'yawDiff')
                posOrientNames = 'yaw';
            else
                error('[crosshair>show_some_smileys] should not see this');
            end
        case {'xxxDiff', 'yyyDiff', 'zzzDiff'}
            unit = 'cm';
            if strcmp(thatDiffName, 'xxxDiff')
                posOrientNames = 'left-right'; % 2DO: check whether that does still fit into the smileys' frames
            elseif strcmp(thatDiffName, 'yyyDiff')
                posOrientNames = 'up-down'; % 2DO: check whether that does still fit into the smileys' frames
            elseif strcmp(thatDiffName, 'zzzDiff')
                posOrientNames = 'front-back'; % 2DO: check whether that does still fit into the smileys' frames
            else
                error('[crosshair>show_some_smileys] should not see this');
            end
        otherwise
             error('[crosshair>show_some_smileys] invalid position or orientation: %s', thatDiffName);
    end

    % set old frame invisible
    set(ot.(ot.figName).(thatDiffName), 'visible', 'off');
    
%     tmpName = thatDiffName(1:3);
%     ot.(ot.figName).([tmpName, 'Annotation']) = annotation('textbox', plotPos, 'String', {sprintf('\n\n %s', posOrientNames)}, ...
%             'FontSize',FonSiz, 'FontName','Arial', 'Margin', marg+1, 'VerticalAlignment', 'middle', ...
%             'HorizontalAlignment', 'left', 'LineStyle','-', 'LineWidth',LinWid, 'Color',colour(1));
        
    if abs(thatDiff) > toleranceLarge % ( = worst case )
        ot.(ot.figName).(thatDiffName) = annotation('textbox', plotPos, ...
            'String', {sprintf('\n\n %s\n %.2f%s', posOrientNames, thatDiff, unit)}, ...
            'FontSize',FonSiz, 'FontName','Arial', 'Margin', marg+1, 'VerticalAlignment', 'middle', ...
            'HorizontalAlignment', 'left', 'LineStyle','-', 'LineWidth',LinWid, 'EdgeColor',colour(3,:) , 'Color',colour(3,:));
        smiley = 3;
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(1), 'visible', 'off');
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(2), 'visible', 'off');
    elseif abs(thatDiff) < toleranceLarge && abs(thatDiff) > toleranceSmall
        ot.(ot.figName).(thatDiffName) = annotation('textbox', plotPos, ...
            'String', {sprintf('\n\n %s\n %.2f%s', posOrientNames, thatDiff, unit)}, ...
            'FontSize',FonSiz, 'FontName','Arial', 'Margin', marg+1, 'VerticalAlignment', 'middle', ...
            'HorizontalAlignment', 'left', 'LineStyle','-', 'LineWidth',LinWid, 'EdgeColor',colour(2,:) , 'Color',colour(2,:));
        smiley = 2;
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(1), 'visible', 'off');
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(3), 'visible', 'off');
    else % ( = best case )
        tmpName = thatDiffName(1:3);
        ot.(ot.figName).([tmpName, 'Annotation']) = annotation('textbox', plotPos, 'String', {sprintf('\n\n %s', posOrientNames)}, ...
                    'FontSize',FonSiz, 'FontName','Arial', 'Margin', marg+1, 'VerticalAlignment', 'middle', ...
                    'HorizontalAlignment', 'left', 'LineStyle','-', 'LineWidth',LinWid, 'EdgeColor',colour(1,:) , 'Color',colour(1,:));
        smiley = 1;
        set(ot.(ot.figName).(thatDiffName), 'visible', 'off'); % annotation off
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(2), 'visible', 'off');
        set(ot.tmpImgs.(['field', num2str(subplotIndex)])(3), 'visible', 'off');
    end
    set(ot.tmpImgs.(['field', num2str(subplotIndex)])(smiley), 'visible', 'on'); % smiley on
end

function [xCirc, yCirc, zCirc] = create_circle(varargin)
% this function creates a [part of a] circle with radius r
% between angles alpha(1) and alpha(2) in degrees
r     = varargin{1};
alpha = varargin{2};

    te  = linspace(deg2rad(alpha(1)),deg2rad(alpha(2)));
    
    if nargin > 2 % plot yaw arrows in other plane (xz)
        xt1 = 0.1*r*cos(1*te);
        yt1 = 0.1*r*sin(0*te);
        zt1 = 0.1*r*sin(1*te);
        
    else
        xt1 = 0.1*r*cos(1*te);
        yt1 = 0.1*r*sin(1*te);
        zt1 = 0.1*r*sin(0*te);
    end
    xCirc = xt1(1:size(xt1,2));
    yCirc = yt1(1:size(xt1,2));
    zCirc = zt1(1:size(xt1,2));
    
end

function [R] = calculate_rotation_matrix(a,b,c)
% this function calculates the rotation (roll-pitch-yaw) of the subject
R = [cos(a)*cos(b),   cos(a)*sin(b)*sin(c) - sin(a)*cos(c),   cos(a)*sin(b)*cos(c) + sin(a)*sin(c); ...
     sin(a)*cos(b),   sin(a)*sin(b)*sin(c) + cos(a)*cos(c),   sin(a)*sin(b)*cos(c) - cos(a)*sin(c); ...
           -sin(b),                          cos(b)*sin(c),                          cos(b)*cos(c);];
end

function prepare_images(otf, subplotIndex)
% this function preloads images for smileys and save them as properties of 
    [folder, ~, ~] = fileparts(which(mfilename));
    otf.(otf.figName).smiley_hap = imread(fullfile(folder,'pic\smileys\smiley_happy.png'));
    otf.(otf.figName).smiley_wor = imread(fullfile(folder,'pic\smileys\smiley_worried.png'));
    otf.(otf.figName).smiley_sad = imread(fullfile(folder,'pic\smileys\smiley_sad.png'));
    
    varPrefix = ['sp_'; 'sm_';];
    nDOF = 6;
    for indx = 1 : nDOF
        otf.(otf.figName).([(varPrefix(1,:)), num2str(subplotIndex(indx))]) = subplot(6,6,subplotIndex(indx,1));
        tmp_hap = imshow(otf.(otf.figName).smiley_hap); % rgb2gray(.)
        set(otf.(otf.figName).([(varPrefix(1,:)), num2str(subplotIndex(indx))]), 'NextPlot', 'add');
        set(tmp_hap, 'visible', 'off');
        
        tmp_wor = imshow(otf.(otf.figName).smiley_wor);
        set(otf.(otf.figName).([(varPrefix(1,:)), num2str(subplotIndex(indx))]), 'NextPlot', 'add');
        set(tmp_wor, 'visible', 'off');
        
        tmp_sad = imshow(otf.(otf.figName).smiley_sad);
        set(otf.(otf.figName).([(varPrefix(1,:)), num2str(subplotIndex(indx))]), 'NextPlot', 'add');
        set(tmp_sad, 'visible', 'off');
        
        % save all images in field of struct "tmpImgs" for later use in
        % function "show_smileys"
        otf.tmpImgs.(['field', num2str(subplotIndex(indx))]) = [tmp_hap, tmp_wor, tmp_sad];
    end
end

function [subplotIndex] = generate_figure_properties(ot) %#ok
% generate all figure properties that are needed for the real-time plot 
% thus, no need to reload them on the fly for every position/orientation
% update
    nDOF = 6;
    % reference position
    varName_ref = ['crss_ref'; 'circ_ref';];
    for index = 1 : size(varName_ref,1)
        eval('if ~isprop(ot.(ot.figName), varName_ref(index,:)) addprop(ot.(ot.figName), varName_ref(index,:)); end')
    end
    
    % current position
    varName = ['crss'; 'circ';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end

    % orientation angles and distance of position
    varName = ['rolDiff'; 'pitDiff'; 'yawDiff'; 'xxxDiff'; 'yyyDiff'; 'zzzDiff';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end

    % orientation arrows
    varName = ['rolArrow'; 'pitArrow';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end

    varName = ['xxx'; 'yyy'; 'zzz'; 'rol'; 'pit'; 'yaw';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), [varName(index,:), ''Annotation'']) addprop(ot.(ot.figName), [varName(index,:), ''Annotation'']); end')
    end
    
    % position arrows
    varName = ['xArrow'; 'yArrow';]; % 'zArrow';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end
    
    % arrow tips
    varName = ['rolArrowTipLowr'; 'rolArrowTipGrtr'; 'pitArrowTipLowr'; 'pitArrowTipGrtr';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end
    varName = ['xArrowTipLowr'; 'xArrowTipGrtr'; 'yArrowTipLowr'; 'yArrowTipGrtr';]; % 'zArrowTipLowr'; 'zArrowTipGrtr';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end
    
    % smileys
    varName = ['smiley_hap'; 'smiley_wor'; 'smiley_sad';];
    for index = 1 : size(varName,1)
        eval('if ~isprop(ot.(ot.figName), varName(index,:)) addprop(ot.(ot.figName), varName(index,:)); end')
    end
    
    % subplots for smileys
    varName = ['hap'; 'wor'; 'sad';]; %#ok
    subplotIndex = [31;  32;  33;  34; 35; 36;];
    for index = 1 : nDOF
        eval('if ~isprop(ot.(ot.figName), [''sp_'', num2str(subplotIndex(index))]) addprop(ot.(ot.figName), [''sp_'', num2str(subplotIndex(index))]); end');
    end

end

function showExplanation(ot, grey)
% this function is called during the training procedure. 
% for every DoF, a short training has to be conducted. explanations of what
% to do are displayed here.
    [folder, ~, ~] = fileparts(which(mfilename));
    
    % load images
    whatIsACrosshairPic = imread(fullfile(folder,'pic\introPictures\crosshair.png'));
    twoCrosshairsPic    = imread(fullfile(folder,'pic\introPictures\crosshairs.png'));
    discrepancyPic      = imread(fullfile(folder,'pic\introPictures\discrepancy.png'));
    xPic                = imread(fullfile(folder,'pic\introPictures\xPos.png'));
    yPic                = imread(fullfile(folder,'pic\introPictures\yPos.png'));
    zPic                = imread(fullfile(folder,'pic\introPictures\zPos.png'));
    rolPic              = imread(fullfile(folder,'pic\introPictures\rolOri.png'));
    pitPic              = imread(fullfile(folder,'pic\introPictures\pitOri.png'));
    yawPic              = imread(fullfile(folder,'pic\introPictures\yawOri.png'));
    
    % welcome to training
    set(ot.txtField{1},'string',ot.txtPart{1}, 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
    
    % head -> cross-hair; this is a cross-hair
    set(ot.txtField{7},'string',ot.txtPart{2}, 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{7}, 'visible', 'off');
    subplot(1,1,1);
    axis off; 
    curPic = imshow(whatIsACrosshairPic, 'InitialMagnification','fit');
    waitforbuttonpress
    set(curPic, 'visible', 'off');

    % discrepancy: init vs. current
    set(ot.txtField{1},'string',ot.txtPart{4}, 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
    curPic = imshow(twoCrosshairsPic, 'InitialMagnification','fit');
    waitforbuttonpress
    set(curPic, 'visible', 'off');

    % smileys and arrows ...
    set(ot.txtField{1},'string',ot.txtPart{5}, 'HorizontalAlignment', 'center', 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
    curPic = imshow(discrepancyPic, 'InitialMagnification','fit');
    waitforbuttonpress
    set(curPic, 'visible', 'off')
    
    % DOFs -- positions
    set(ot.txtField{1},'string',ot.txtPart{6}, 'HorizontalAlignment', 'center', 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
    % x y z with picture
    set(ot.txtField{2},'string',ot.txtPart{9},  'HorizontalAlignment', 'center', 'visible', 'on');
    set(ot.txtField{3},'string',ot.txtPart{10}, 'HorizontalAlignment', 'center', 'visible', 'on');
    set(ot.txtField{4},'string',ot.txtPart{13}, 'HorizontalAlignment', 'center', 'visible', 'on');
%     subplot(2,2,[3,4]);
    subplot(2,3,4)
    curPic1 = imshow(xPic, 'InitialMagnification','fit');
    subplot(2,3,5)
    curPic2 = imshow(yPic, 'InitialMagnification','fit');
    subplot(2,3,6)
    curPic3 = imshow(zPic, 'InitialMagnification','fit');

    leftLine  = annotation('line', [1/3 1/3], [0.03 1-0.03], 'LineWidth', 2, 'color', grey);
    rightLine = annotation('line', [2/3 2/3], [0.03 1-0.03], 'LineWidth', 2, 'color', grey);
    waitforbuttonpress
    set(ot.txtField{2}, 'visible', 'off');
    set(ot.txtField{3}, 'visible', 'off');
    set(ot.txtField{4}, 'visible', 'off');
    set(leftLine,  'visible', 'off');
    set(rightLine, 'visible', 'off');
    set(curPic1, 'visible', 'off');
    set(curPic2, 'visible', 'off');
    set(curPic3, 'visible', 'off');

    % DOFs -- orientations
    set(ot.txtField{1},'string',ot.txtPart{7}, 'HorizontalAlignment', 'center', 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
    % roll pitch yaw
    set(ot.txtField{2},'string',ot.txtPart{14}, 'HorizontalAlignment', 'center', 'visible', 'on');
    set(ot.txtField{3},'string',ot.txtPart{15}, 'HorizontalAlignment', 'center', 'visible', 'on');
    set(ot.txtField{4},'string',ot.txtPart{11}, 'HorizontalAlignment', 'center', 'visible', 'on');
    subplot(2,3,4)
    curPic1 = imshow(rolPic, 'InitialMagnification','fit');
    subplot(2,3,5)
    curPic2 = imshow(pitPic, 'InitialMagnification','fit');
    subplot(2,3,6)
    curPic3 = imshow(yawPic, 'InitialMagnification','fit');
    leftLine  = annotation('line', [0.38 0.38], [0.03 0.97], 'LineWidth', 2, 'color', grey);
    rightLine = annotation('line', [0.64 0.64], [0.03 0.97], 'LineWidth', 2, 'color', grey);
    waitforbuttonpress
    set(ot.txtField{2}, 'visible', 'off');
    set(ot.txtField{3}, 'visible', 'off');
    set(ot.txtField{4}, 'visible', 'off');
    set(leftLine,  'visible', 'off');
    set(rightLine, 'visible', 'off');
    set(curPic1, 'visible', 'off');
    set(curPic2, 'visible', 'off');
    set(curPic3, 'visible', 'off');

    % start training with x
    set(ot.txtField{1},'string',ot.txtPart{16},  'HorizontalAlignment', 'center', 'visible', 'on');
    waitforbuttonpress
    set(ot.txtField{1}, 'visible', 'off');
end
