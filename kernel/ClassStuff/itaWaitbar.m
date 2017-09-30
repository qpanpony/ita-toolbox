classdef  itaWaitbar < itaHandle
    
    %itaWaitbar - progress bar class
    %
    %
    % These objects display the progress of a calculation. They are comparable 
    % to the matlab function waitbar(), but easier to use (simple increase of a
    % counter instead of calculation of progress), allows nested loops and shows
    % estimated time left.
    %
    %  init:
    %     wb = itaWaitbar(nLoops);     % init with number of loops  OR
    %     wb = itaWaitbar(nLoops, 'start calculation...' );     % init with number of loops and message
    %
    % increas counter
    %     wb.inc;                         % increase loop counter OR
    %     wb.inc('calculating level');    % increase loop counter and update message
    %
    % close
    %     close(wb)    OR
    %     wb.close
    %
    % simple example
    % nChannels = 11;
    % wb = itaWaitbar(nChannels);     % init with number of loops
    % for iChannel = 1:nChannels
    %     wb.inc;                     % increase loop counter
    %     pause(0.5) % here comes your calculation
    % end
    %
    %  more examples: see test_itaWaitbar

    %
    %   Reference page in Help browser
    %        <a href="matlab:doc itaWaitbar">doc itaWaitbar</a>
    
    % Author: Martin Guski
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
        
    properties
        
    end
    
    properties(Access = private, Hidden = true)
        figHandle       = 0;
        axHandle        = 0;
        patchHandle     = 0;
        txtHandle       = 0;
        txtTimeLeft     = 0;
        txtMessage      = 0;
        pauseToggle     = 0;
        
        startTimeLastLoop       = [];
        startTimeWaitbar        = nan;
        iLoopIntern             = 0;
        nLoopsIntern            = 100;
        nNestings               = 1;
        iLoopForEveryNesting    = {1};
        loopNameCell            = 0;
        
        loopFactor = 1 % jri: if the loop does not take very long, only update every loopFactor
        useJava = 1; % if java is not loaded, don't show the figure but display remaining time
    end
    
    properties(Dependent = true, Hidden = false)
        iLoop   % current loop counter
        nLoops  % total loop counter        
    end
    
    methods
        function this = itaWaitbar(varargin)
            % constructor
            openWaitbars = findobj(allchild(0),  'tag', 'itaWaitbar');
            
            % input parsing
            if nargin >=1
                nLoopCount = varargin{1};
            else
                nLoopCount = 100;
            end
            
            messageStr = '';
            if nargin >=2
                if ischar(varargin{2})
                    messageStr = varargin{2};
                else
                    error('wrong input at position 2. STRING expected')
                end
            end
            
            if usejava('jvm')
                this.useJava = 1;
            else
                this.useJava = 0;
            end
            
            this.nNestings = numel(nLoopCount);
            
             if    nargin >=3 &&  iscell(varargin{3}) && numel(varargin{3}) == this.nNestings
                    this.loopNameCell = varargin{3};
             else
                    this.loopNameCell = repmat({''}, this.nNestings, 1);
             end
            
            
            
            this.iLoopForEveryNesting = cell(this.nNestings,1);
            
            axSize  = [240 20];
            figSize = [300 axSize(2)*2*(this.nNestings+1.5)];
            screenSize = get(0, 'screensize');
            
            figPosition = [(screenSize(1,3:4)-figSize)/2 figSize];
            
            
            if this.useJava == 1
                this.figHandle = figure('position', figPosition, 'name', 'itaWaitbar', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'tag', 'itaWaitbar', 'nextPlot', 'new');
            
            
                if ~isempty(openWaitbars) % if other waitbar is open => put new below old
                    posOfLastWB = get(openWaitbars(1), 'outerposition');
                    figPosition = get(this.figHandle, 'outerposition');
                    figPosition(1) = posOfLastWB(1);
                    figPosition(2) = posOfLastWB(2) - figPosition(4);
                    set(this.figHandle, 'outerposition', figPosition)
                end

                for iNesting = 1:this.nNestings
                    this.axHandle(this.nNestings-iNesting+1)     = axes('parent', this.figHandle,'units', 'pixels', 'position', [0.1*figSize(1) iNesting*2*axSize(2)  axSize ], 'XTick',[], 'YTick', [], 'xlim', [0 max(nLoopCount(this.nNestings-iNesting+1),1)], 'box', 'on');
                    this.patchHandle(this.nNestings-iNesting+1)  = patch([0 0 0 0], [0 0 1 1], [1 .3 .3], 'parent', this.axHandle(this.nNestings-iNesting+1));
                    this.txtHandle(this.nNestings-iNesting+1)    = text(nLoopCount(this.nNestings-iNesting+1)/2,0.5, 'asdd', 'parent', this.axHandle(this.nNestings-iNesting+1), 'HorizontalAlignment', 'center', 'fontsize', 11) ;
                end
                this.txtTimeLeft    = uicontrol('style', 'text','units', 'pixels',  'position', [0.1*figSize(1) axSize(2)/2  axSize ], 'string', '', 'parent', this.figHandle, 'HorizontalAlignment', 'center', 'fontsize', 9, 'backgroundcolor', get(this.figHandle, 'color')) ;
                this.txtMessage     = uicontrol('style', 'text','units', 'pixels',  'position', [0.1*figSize(1) figSize(2)-axSize(2)*1.5  axSize ], 'string', messageStr, 'parent', this.figHandle, 'HorizontalAlignment', 'center', 'fontsize', 11, 'backgroundcolor', get(this.figHandle, 'color')) ;
                this.pauseToggle    = uicontrol('style', 'toggleButton','units', 'pixels',  'position', [3 3  50 22 ], 'string', 'pause' , 'parent', this.figHandle, 'HorizontalAlignment', 'center', 'fontsize', 11, 'backgroundcolor', [1 1 1] * 0.9, 'callback', {@this.pauseCalculation}) ;
            end
            this.nLoopsIntern = nLoopCount;
            
            this.updateBar
            this.startTimeLastLoop = []; 
        end
        
        function inc(varargin) 
            % new loop, increase counter
            this = varargin{1};
            this.iLoopIntern = this.iLoopIntern + 1;
            if mod(this.iLoopIntern,this.loopFactor) == 0
                this.updateBar(varargin{2:end})
            end
        end
        
        function showTotalTime(this) 
            % shows time since start
            if this.iLoop
                timeStr = ['total time: ' datestr(   datetime('now') - this.startTimeWaitbar ,'HH:MM:SS')];
            else
                timeStr = '';
            end
            set(this.txtTimeLeft, 'string', timeStr)
            set(this.patchHandle, 'facecolor', [1 .8 .8])
	    drawnow()
        end
        
        function updateBar(this, updateMessage)
            if this.useJava
                % update the bar in the figure
                if nargin > 1
                    set(this.txtMessage, 'string', updateMessage);
                end

                % global loop index iLoop => nested loop indices
                if this.iLoop
                    [this.iLoopForEveryNesting{end:-1:1}] = ind2sub(this.nLoops(end:-1:1), this.iLoop); 
                else % iLoop == 0 => all nested loops == 0
                    [this.iLoopForEveryNesting{:}] = deal(0);
                end

                yValues = [0 0 1 1];
                for iNesting = 1:this.nNestings
                    xValues = [0 this.iLoopForEveryNesting{iNesting} * [1 1] 0];

                    set(this.patchHandle(iNesting), 'vertices', [xValues(:), yValues(:)]);

                    set(this.txtHandle(iNesting), 'string', sprintf('%s  %i of %2.0f ', this.loopNameCell{iNesting}, this.iLoopForEveryNesting{iNesting}, this.nLoops(iNesting)));
                end
            end
            
            % update time left
            
            if isempty(this.startTimeLastLoop)
                this.startTimeLastLoop  = datetime('now');
                remainingTimeStr        = '';
%             elseif this.iLoopIntern > 1 && ~isnan(this.startTimeLastLoop)
            else
                startTimeThisLoop       = datetime('now');
                timeForLastLoop         = startTimeThisLoop - this.startTimeLastLoop;
                this.startTimeLastLoop  = startTimeThisLoop;
                timeLeft = timeForLastLoop/this.loopFactor*(prod(this.nLoopsIntern)-this.iLoopIntern+1);
                remainingTimeStr        = ['time left: ' datestr(timeLeft,'HH:MM:SS')];
%                 if timeLeft > 1
%                     remainingTimeStr = [remainingTimeStr(1:11) sprintf(' %i d  ', floor(timeLeft)) remainingTimeStr(12:end)];
%                 end
                
                if timeForLastLoop < duration(0,0,2)
                    this.loopFactor = this.loopFactor*2;
                end
                
            end
            
            % if no desktop is available, show the remaining time as disp
            if ~usejava('desktop')
                disp(remainingTimeStr)
            end
            if this.useJava
                set(this.txtTimeLeft, 'string', remainingTimeStr)
                drawnow()
            end
            
            if this.iLoop == 1
                this.startTimeWaitbar = this.startTimeLastLoop;
            end
            
            
        end
        
        function close(this) % close itaWaitbar figure
            if this.useJava
                close(this.figHandle)
            end
        end
        
        function pauseCalculation(this, self, eventData)
            if get(self, 'value') % pause on
                this.startTimeLastLoop = []; % no estimation possible for next loop
                set(this.patchHandle, 'facecolor', [1 1 1]*.5)
                for iNesting = 1:this.nNestings
                    oldStr = get(this.txtHandle(iNesting) , 'string');
                    set(this.txtHandle(iNesting) , 'string',['pause at ' oldStr ] );
                end
                
                btnColorVar = 0;
                while get(self, 'value')
                    btnColorVar = btnColorVar + 0.1;
                    pause(0.1)
                    set(self, 'backgroundcolor', [0.9  abs(sin(btnColorVar))*0.9*[1 1]])
                end
                set(self, 'backgroundcolor', 0.9*[1 1 1])
            else % pause off
                set(this.patchHandle, 'facecolor', [1 .3 .3])
                this.updateBar
            end
        end

        function set.iLoop(this, iLoop_new)
            this.iLoopIntern = iLoop_new;
            this.startTimeLastLoop = [];
            this.updateBar
        end
        
        function set.nLoops(this, nLoops_new)
            this.nLoopsIntern = nLoops_new;
            this.startTimeLastLoop = [];
            set(this.axHandle, 'xlim', [0 nLoops_new])
            this.updateBar
        end
        
        function out = get.iLoop(this)
            out = this.iLoopIntern;
        end

        function out = get.nLoops(this)
            out = this.nLoopsIntern;
        end

    end
end
