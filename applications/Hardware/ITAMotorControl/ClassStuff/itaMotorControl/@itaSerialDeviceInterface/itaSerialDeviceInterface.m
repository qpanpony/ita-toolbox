classdef itaSerialDeviceInterface < handle
    % Wrapper around a serial object. Contains initialization code and wraps functions. Is a 
    % Singleton so that outside objects can access the serial object. If communication is to 
    % take place over another interface (e.g. CAN), reuse interface of this class by abstracting
    % away the specific stuff in here, then introducing an abstract base class itaMotorInterface,
    % then inherit from it.

    properties
        mSerialObj;
        comPort = 'uninitialized';
        portOpen = false;
        baudRate = 19200;
        databits = 8;
        stopbits = 1;
        OutputBufferSize = 3072;
        Terminator = 13;
        BytesAvailableFcnMode = 'Terminator';
        bytesAvailable;
        
    end
    
    % Constructor, Destructor ------------------------------------------------------------------
    methods %(Access = private)  TODO : make private again to prevent ordinary instantiation?
        function this = itaSerialDeviceInterface(varargin)
            % config
            this.comPort = ita_preferences('movtecComPort');
            if strcmpi(this.comPort,'noDevice')
                ita_verbose_info('Please select a COM-Port in ita_preferences (Using the Movtec-Port!)',0);                 % TODO : messaging
                ita_preferences;
                return;
            end
            % init serial object
            this.initComPort();
        end
        function delete(this)
            % TODO : check if serial object is open first?
            fclose( this.mSerialObj);
        end
    end
    
    % Public interface  ------------------------------------------------------------------------
    methods 
        function setBaudRate(this,br)
            if ~any(this.validBaudRates == br)
                ita_verbose_info(sprintf('Invalid baudRate selected: %d, Valid baud rates: %s',this.baudRate, num2str(this.validBaudRates)),0);    % TODO : messaging
                return;
            end
            this.mSerialObj.baudRate = br;
        end
        function ret = query(this, msg)        
            if(this.portOpen == false)
               this.portOpen = true;
               ret = query(this.mSerialObj, sprintf(msg));
               this.portOpen = false;
            else
               ret = query(this.mSerialObj, sprintf(msg));
            end
        end
        function sendAsynch(this,msg)
%             disp(sprintf('send: %s',msg));
            fwrite(this.mSerialObj, sprintf(msg));  
        end
        function ret = recvAsynch(this)
            ret = fgetl(this.mSerialObj);
%             disp(sprintf('rec: %s',ret));
        end
        
        function avail = BytesAvailable(this)
           avail = this.mSerialObj.bytesAvailable; 
        end

        
    end
    % Singleton ------------------------------------------------------------------------------------
    methods (Static)
        % Singleton access function
        function instance = getInstance
            persistent localInstance
            if isempty(localInstance) || ~isvalid(localInstance)
                localInstance = itaSerialDeviceInterface;
            end
            instance = localInstance;
        end
    end
    
    % Getters n Setters ----------------------------------------------------------------------------
    methods
        function set.baudRate(this, value)
            this.mSerialObj.BaudRate = value;
            this.baudRate = value;
        end
        function set.portOpen(this,value)
            if(this.portOpen ~= true)
                % TODO : if this is the first time that the serial interface
                % is accessed, check if com port is correct?
                fopen(this.mSerialObj);
                this.portOpen = true;
            end
        end
        function set.comPort(this,value)
            this.comPort = value;
            this.initComPort();            
        end
        function val = get.bytesAvailable(this)
            val = this.mSerialObj.BytesAvailable;
        end
    end

    % Private functions ----------------------------------------------------------------------------
    methods (Access = private)
        function initComPort(this)
             insts               =   instrfind;         %show existing terminals using serial interface
            if ~isempty(insts)
                aux = strfind(insts.Name,this.comPort);
                if numel(aux) == 1
                    aux = {aux};
                end
                for idx = 1:numel(aux)
                    if ~isempty(aux{idx})
                        delete(insts(idx));             %delete used serial ports
                    end
                end
            end
            this.mSerialObj = serial(this.comPort,'Baudrate',this.baudRate,'Databits',this.databits,'Stopbits',this.stopbits,'OutputBufferSize',this.OutputBufferSize);
            this.mSerialObj.Terminator              =   this.Terminator;
            this.mSerialObj.BytesAvailableFcnMode   =   this.BytesAvailableFcnMode;
        end
    end
end