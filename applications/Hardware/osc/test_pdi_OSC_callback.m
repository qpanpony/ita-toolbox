function test_pdi_OSC_callback(OSC)
% Author: Pascal Dietrich, Dec. 2013 - Plot IMU data send via OSC

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


persistent hfig
persistent axh
persistent dataMat

LENGTH = 100; % store last values

if isempty(hfig) || ~ishandle(hfig) 
    % first call
    hfig = figure; %open figure
    dataMat{1} = ones(3,LENGTH);
    dataMat{2} = dataMat{1};
    dataMat{3} = dataMat{1};

    titleList = {'gyro','acc','mag'};
    for idx = 1:3
        axh(idx) = subplot(3,1,idx);
        plot(1:LENGTH,dataMat{idx})
        legend({'x','y','z'})
        title(titleList{idx})
        grid on
    end
else
    figure(hfig)
end

for idx = 1:numel(OSC)
    token = OSC(idx);
    switch(token.address)
        %         case {'/gyro'}
        %             axis(axh(1));
        %             gyro = [gyro cell2mat(token.data).'];
        %             plot(1:size(gyro,2),gyro);
        %
        %         case {'/acc'}
        %             axis(axh(2));
        %             acc = [acc cell2mat(token.data).'];
        %             plot(1:size(acc,2),acc);
        %
        %         case {'/mag'}
        %             axis(axh(3));
        %             mag = [mag cell2mat(token.data).'];
        %             plot(1:size(mag,2),mag);
        case ['/alldata']
            % append data
            
            data = cell2mat(token.data).';
            dataMat{1} = [dataMat{1}(:,2:end) data(1:3)];
            c = get(axh(1),'Children');
            for jdx = 1:3
               set(c(4-jdx),'YData',dataMat{1}(jdx,:))
            end
            
            
            dataMat{2} = [dataMat{2}(:,2:end) data(4:6)];
            dataMat{3} = [dataMat{3}(:,2:end) data(7:9)];
            
            
            
            
%             subplot(3,1,1)
%             plot(1:size(gyro,2),gyro);
%             grid
%             title(titleList{1})
%             
%             subplot(3,1,2)
%             plot(1:size(acc,2),acc);
%             grid
%             title(titleList{2})
%             
%             
%             subplot(3,1,3)
%             plot(1:size(mag,2),mag);
%             grid
%             title(titleList{3})
% 
%             pause(0.1)
        otherwise
            disp(token.address)
    end
end

linkaxes(axh)

end