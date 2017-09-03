classdef itaMotorNanotec < itaHandle
    properties(Access = protected, Hidden = true)
       motorID = [];
       motorName = [];
%        mInUse = false;
       
       old_position        =   itaCoordinates(1);
       
       mIsReferenced = false;
       mIsInit = false;
       
       motorLimits = [];
    end
    
    properties
        
    end
    
    methods(Abstract)
        % basic motor functions
        this = init(this);
        stop(this);
        active = isActive(this);
        setActive(this,value);
        
%         isInitialized(this);
        getStatus(this);
        getMotorID(this);
        getMotorName(this);
        % basic moves: requires execution to halt while something is moving
        this = moveToReferencePosition(this);
        this = startMoveToPosition(this);
        disableReference(this,value);
%         this = freeFromStopButton(this);
        ret = prepareMove(this,position,varargin);
    end
    
    methods
        function setReferenced(this,value)
           this.mIsReferenced = value; 
        end
    end
end