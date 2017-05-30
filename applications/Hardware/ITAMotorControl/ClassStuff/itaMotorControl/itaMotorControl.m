classdef itaMotorControl < itaHandle
    %ITAMOTORCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected, Hidden = true)
        mSerialObj; % the serial connection
    end
    
    properties 
       comPort = ita_preferences('movtecComPort');
       baudrate = 9600;
       databits = 8;
       stopbits = 1;
       OutputBufferSize = 3072;
       
       wait                =   true;        % Status - do we wait for motors to reach final position? -> Set by prepare-functions!
   
    end
    
    methods(Abstract)
        % basic motor functions
        this = init(this);
        stopAllMotors(this);
        setWait(this,value);
%         isInitialized(this);
        
        % basic moves: requires execution to halt while something is moving
        this = reference(this);
        this = moveTo(this,targetPosition);
        
        ret = prepareForContinuousMeasurement(this);
        startContinuousMoveNow(this);
    end
    
    methods(Abstract, Hidden=true)
        displayMotors(this)
    end
    
end

