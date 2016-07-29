classdef itaHandle < handle
    %itHandle - a new handle super class with hidden properties
    %   This class is inherited from the handle super class and hides all
    %   nasty standard methods.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

    
    % Author: Pascal Dietrich - 2012 - pdi@akustik.rwth-aachen.de
    
    properties
    end
    
    methods
        
        
    end
    
    methods(Hidden = true)
        function varargout = ge(varargin)
            varargout = builtin('ge',varargin);
        end
%         function varargout = addlistener(this,varargin)
%            varargout{1} = addlistener@handle(handle(this),varargin{:}); 
%         end
        function varargout = eq(this,varargin)
            varargout{1} = eq@handle(handle(this),varargin{:});
        end
        function varargout = delete(this,varargin)
            varargout{1} = delete@handle(handle(this),varargin{:});
        end
        function varargout = findobj(this,varargin)
            varargout{1} = findobj@handle(handle(this),varargin{:});
        end
        
        function varargout = findprop(this,varargin)
            varargout{1} = findprop@handle(handle(this),varargin{:});
        end
        %         function varargout = isvalid(this,varargin)
        %             varargout{1} = isvalid@handle(handle(this),varargin{:});
        %         end
        function varargout = gt(this,varargin)
            varargout{1} = gt@handle(handle(this),varargin{:});
        end
        function varargout = lt(this,varargin)
            varargout{1} = lt@handle(handle(this),varargin{:});
        end
        function varargout = ne(this,varargin)
            varargout{1} = ne@handle(handle(this),varargin{:});
        end
        function varargout = notify(this,varargin)
            varargout{1} = notify@handle(handle(this),varargin{:});
        end
                function varargout = le(this,varargin)
           varargout{1} = le@handle(handle(this),varargin{:}); 
        end
    end
end

