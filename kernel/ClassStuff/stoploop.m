classdef stoploop < handle
%  FS = STOPLOOP creates a message box window and returns an object FS that
%  holds two functions, called FS.Stop and FS.Clear. The function FS.Stop()
%  will return true, if the OK button has been clicked (or the message box
%  has been removed), so that a loop can be interrupted.
%  The function FS.Clear() can be used to remove the message box, if a loop
%  has ended without user interruption.
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%  FS = STOPLOOP(STR) uses the string STR to display instead of the default
%  'Stop'.
    
    properties
            
    end
    
    properties(Access = private, Hidden = true)
        caption = 'STOPLOOP'
        figureHandle
        fastMode = false
    end
    
    properties( Hidden = false)
        string = 'Stop'
    end
        
    methods
        function this = stoploop(this,varargin) %#ok<INUSD>
            % create a stoploop element
            % Call: handle = stoploop(name,caption)
            
            if nargin >= 2
                stringVar = varargin{1};
            else
                stringVar = this.string; % defalut value
            end
            if nargin >= 3
                this.caption = varargin{2};
            end
            if nargin >= 4
                this.fastMode = varargin{3};
            end
            
            this.figureHandle = msgbox(stringVar,this.caption);
            this.string = stringVar;   % not nice but:  setting of this.string needs valid this.figureHandle!
        end
        
        function result = stop(this)
            % True if stop was pressed, false if not pressed
            if ~this.fastMode
               drawnow 
            end
            result = ~ishandle(this.figureHandle);
        end
        
        function result = Stop(this)
            % Wrapper for this.stop for backward compatibility
           result = this.stop; 
        end
        
        function clear(this)
            % Clear the message box
            if ishandle(this.figureHandle),
                delete(this.figureHandle) ;
            end
        end
        
        function Clear(this)
            % Wrapper for this.clear
            this.clear;
        end
        
        function this = set.string(this, str)
            if ~this.Stop
                this.string = str;
                
                % das klingt nach dependent ?!?
                children = get(this.figureHandle, 'children');
                set(get(children(1), 'children'), 'string', {str});
                %              drawnow
            end
        end
    end
    
end

