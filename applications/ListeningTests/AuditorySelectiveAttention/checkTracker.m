function checkTracker(timer, e)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

temp = get(timer, 'userdata');

s = ITAPolhemus('getsensorstate', temp.type);
    clear temp_Pos;
    temp_Pos(1:3) = s.pos;
    temp_Pos(4:6) = s.orient*180/pi;
    
    fprintf('Position=(%+0.3f, %+0.3f, %+0.3f), Orientation=(%+0.2f, %+0.2f, %+0.2f) \n',...
    temp_Pos(1), temp_Pos(2), temp_Pos(3),...
    temp_Pos(4), temp_Pos(5), temp_Pos(6));
    
    if any(temp_Pos <= temp.errorLimit(1,:) | temp_Pos >= temp.errorLimit(2,:))
        temp.moved = true;
    end
    
    temp.trackerData = [ temp.trackerData ; [temp_Pos now] ];
    
    set(timer, 'userdata', temp)
end
