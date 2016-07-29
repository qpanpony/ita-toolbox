classdef itaPolhemusCalibrateHelper < itaHandle
%ITAPOLHEMUSCALIBRATEHELPER - +++ Wrapper around tracker. Waits for buttonclick and returns coordinates +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   trackerHelper = itaPolhemusCalibrateHelper
%
%  Example:
%   trackerHelper = itaPolhemusCalibrateHelper
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc itaPolhemusCalibrateHelper">doc itaPolhemusCalibrateHelper</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  20-May-2015 

    properties(Access = private, Hidden = true)
        mTimer = 0;
        % this (invisible figure) is used to wait for execution
        mHelperFigure = [];
        
        mButtonClickPoint = 0;
        
        mTrackerPeriod = 0.05;
        
        mButtonPressed = 0;
    end
    
    methods
        function this = itaPolhemusCalibrateHelper()
            try
                fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');
                ITAPolhemusD('init');
%                 pause(5);
                fprintf('Initialized!!!\n');
            catch err
                fprintf('Already initialized!!!\n');
            end


            this.mTimer = timer('TimerFcn',@(h,e)this.timerCallback, 'ExecutionMode','fixedRate','Period',this.mTrackerPeriod);
            
            this.mHelperFigure = figure('Visible','off');         

        end
          
%         function results = waitForButtonClickedFrontDirection(this)
%             start(this.mTimer);
%             set(this.mHelperFigure,'Tag','true');
%             waitfor(this.mHelperFigure,'Tag','false');
%             stop(this.mTimer);
%             results = this.mButtonClickPoint;
% %             for n=1:2
% %                 s = this.mButtonClickPoint{n};
% %                 % Only show last sensor that has a button
% %                 if ~(s.hasButton)
% %                     results = s;
% %                 end
% %             end
%             
%         end
        
        
          function results = waitForButtonClicked(this)
            start(this.mTimer);
            set(this.mHelperFigure,'Tag','true');
            waitfor(this.mHelperFigure,'Tag','false');
            stop(this.mTimer);
            results = this.mButtonClickPoint;
%             for n=1:2
%                 s = this.mButtonClickPoint{n};
%                 % Only show first sensor that has a button
%                 if (s.hasButton)
%                     if (s.buttonPressed)
%                         results = s;
%                     end
%                 end
%             end
            
          end
          
    end
    
    
    methods(Hidden = true)
        
        function timerCallback(this,event,source)
            S = ITAPolhemusD('getsensorstates');
            for n=1:2
                s = S{n};
                % Only show first sensor that has a button
                if (s.hasButton)
                    if (this.mButtonPressed == n) && ~(s.buttonPressed)
                       buttonReleasedCallback(this,S); 
                    elseif (s.buttonPressed)
                        buttonClickedCallback(this,n,S);
                    end
                    
                end
            end
        end 
        
        function buttonClickedCallback(this,buttonNumber,point)
            this.mButtonClickPoint = point;
            this.mButtonPressed = buttonNumber;

        end
        
        function buttonReleasedCallback(this,S)
            stop(this.mTimer);
            this.mButtonPressed = 0;
            set(this.mHelperFigure,'Tag','false');    
        end
    end
    
    
    
end