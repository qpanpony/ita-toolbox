% % itaDeviceDrivers('Init')
% % btn = zeros(4,1);
% % while ~(any(btn));
% %     [pos, up, view, btn] = itaDeviceDrivers('GetSensorStates');
% % %     basistransformation(pos(2,:), pos(1,:), view(1,:), up(1,:))
% % pos(2,:)
% % end
% a = ita_generate('sine',.05,1000,44100,14);
% %% Get position Left Ear
% disp('Press the pointing device button to sample the positions');
% btn = zeros(4,1);
% while ~(any(btn));
%     [posL1, upL1, viewL1, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posL2, upL2, viewL2, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posL3, upL3, viewL3, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% 
% posLeftEar_refHeadSensor_1 = basistransformation(posL1(2,:), posL1(1,:), viewL1(1,:), upL1(1,:));
% posLeftEar_refHeadSensor_2 = basistransformation(posL2(2,:), posL2(1,:), viewL2(1,:), upL2(1,:));
% posLeftEar_refHeadSensor_3 = basistransformation(posL3(2,:), posL3(1,:), viewL3(1,:), upL3(1,:));
% posLeftEar_refHeadSensor = mean([posLeftEar_refHeadSensor_1;posLeftEar_refHeadSensor_2;posLeftEar_refHeadSensor_3],1);
% 
% %% Get position Left Ear
% disp('Press the pointing device button to sample the positions');
% btn = zeros(4,1);
% while ~(any(btn));
%     [posR1, upR1, viewR1, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posR2, upR2, viewR2, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posR3, upR3, viewR3, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% 
% posRightEar_refHeadSensor_1 = basistransformation(posR1(2,:), posR1(1,:), viewR1(1,:), upR1(1,:));
% posRightEar_refHeadSensor_2 = basistransformation(posR2(2,:), posR2(1,:), viewR2(1,:), upR2(1,:));
% posRightEar_refHeadSensor_3 = basistransformation(posR3(2,:), posR3(1,:), viewR3(1,:), upR3(1,:));
% posRightEar_refHeadSensor = mean([posRightEar_refHeadSensor_1;posRightEar_refHeadSensor_2;posRightEar_refHeadSensor_3],1);
% 
% 
% 
% %% Get position Nose
% disp('Press the pointing device button to sample the positions');
% btn = zeros(4,1);
% while ~(any(btn));
%     [posN1, upN1, viewN1, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posN2, upN2, viewN2, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% btn = zeros(4,1);
% while ~(any(btn));
%     [posN3, upN3, viewN3, btn] = itaDeviceDrivers('GetSensorStates');
% end
% a.play
% 
% posNose_refHeadSensor_1 = basistransformation(posN1(2,:), posN1(1,:), viewN1(1,:), upN1(1,:));
% posNose_refHeadSensor_2 = basistransformation(posN2(2,:), posN2(1,:), viewN2(1,:), upN2(1,:));
% posNose_refHeadSensor_3 = basistransformation(posN3(2,:), posN3(1,:), viewN3(1,:), upN3(1,:));
% posNose_refHeadSensor = mean([posNose_refHeadSensor_1;posNose_refHeadSensor_2;posNose_refHeadSensor_3],1);
% 
% 
% %% Define center of head, in relation to sensor
% 
% cPos_refHeadSensor = (posLeftEar_refHeadSensor + posRightEar_refHeadSensor)/2;
% 
% %% Define coordinate system of the head
% 
% % choose one fixed position and calculate everything in room coordinates
% side = cross(viewL1(1,:),upL1(1,:));
% % Generate the basis transformation matrix
% T = [viewL1(1,:);
%      upL1(1,:);
%      side];
%  
% posLeftEar_refRoom = posL1(1,:) + posLeftEar_refHeadSensor*T;
% posRightEar_refRoom = posL1(1,:) + posRightEar_refHeadSensor*T;
% posNose_refRoom = posL1(1,:) + posNose_refHeadSensor*T;
% 
% % find center of head
% cPos_refRoom = (posLeftEar_refRoom + posRightEar_refRoom)/2;
% 
% % center points around head center
% CposLeftEar_refRoom = posLeftEar_refRoom - cPos_refRoom;
% CposRightEar_refRoom = posRightEar_refRoom - cPos_refRoom;
% CposNose_refRoom = posNose_refRoom - cPos_refRoom;
% 
% % Define view vector from nose point and perpendicular to ear points
% % just use the x,z coordinates, as y is defined as the same as the room.
% t = [0 -1; 1 0]; %rotate 90°
% aux = [CposLeftEar_refRoom([1 3])*t'; CposNose_refRoom([1 3])];
% M = mean(aux(:,1)./aux(:,2));
% V = sign(CposNose_refRoom(1))*[M 0 1];
% V = V/norm(V);
% U = [0 1 0];    %define the up vector as the same up from room Coord. Sys.
% S = cross(V,U);
% 
% % matrix of head V,U,S given in room coordinates
% Hvus = [V;U;S];    
% 
% % matrix of sensor V,U,S given in room coordinates
% Svus = [viewL1(1,:);upL1(1,:);cross(viewL1(1,:),upL1(1,:))];
% 
% % We need the rotation matrix R such that Svus*R = Hvus
% R = Svus\Hvus;

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Measure Head Position

N = 10;
count = 1;
P = zeros(60/N*120,3);
U = zeros(60/N*120,3);
V = zeros(60/N*120,3);

pause(5)
a.play

tag = N/60;
tic;
while toc <= 12
    [pos, up, view, btn] = itaDeviceDrivers('GetSensorStates');
    svus = [view(1,:);up(1,:);cross(view(1,:),up(1,:))];
    P(count,:) = pos(1,:) + cPos_refHeadSensor*svus;
    aux = svus*R;
    V(count,:) = aux(1,:);
    U(count,:) = aux(2,:);
    while (toc - tag*count) < 0; end
    count = count + 1;
end
P(count:end,:) = [];
V(count:end,:) = [];
U(count:end,:) = [];
a.play