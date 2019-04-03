classdef itaSubjectOrientationFeedback < handle
    % class itaSubjectOrientationFeedback
    %
    % Provides visual real-time feedback about how to correct a current 
    % orientation for a person in motion, e.g. during HRTF measurements
    % where no movement is desired.
    % Needs position and orientation data provided by a tracking system.
    %
    % Author:  Saskia Wepner, swe@akustik.rwth-aachen.de
    % Version: 2019-04-03
    %
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(GetAccess = 'public')
        ot = []; % store Optitrack object here
    end
    methods
        % Constructor 
        function sof = itaSubjectOrientationFeedback(optitrackObj)
            sof.ot = optitrackObj;
        end
    end
     
end