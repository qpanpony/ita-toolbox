classdef itaArduino < handle
    
    % <ITA-Toolbox>
    % This file is part of the application Arduino for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    
    
    properties
        s1 = [];
        port = 'COM5';
        temperature = 0;
        humidity = 0;
        waitForArduinoResponse = 0; % in sec
        defaultAverages = 5;
        nSensors = 1;
    end
    
    properties (Constant)
        baud = 9600
    end
    
    properties(GetAccess=protected)
        possibleMessages = {'m','r'};
        response = ''; % variable to hold the message sent back from arduino
    end
    
    methods
        function this = itaArduino(varargin) % example temp = itaArduino or  temp = itaArduino('COM5')
            if nargin >= 1
                if ischar(varargin{1})
                    this.port = varargin{1};
                else
                    error([upper(mfilename) '::wrong input arguments. The object has the following input structure: itaArduino(port)']);
                end
            end
            
            if nargin >= 2
                
                switch lower(varargin{2})
                    case 'temperaturearray'
                        this.init
                        this.s1.Parity              = 'odd';
                        this.s1.DataBits            = 7;
                        this.waitForArduinoResponse = 0;
                        this.defaultAverages        = 1;
                        this.nSensors               = 8;
                    case 'reverberationroom'
                        this.init
                        this.s1.Parity              = 'odd';
                        this.s1.DataBits            = 7;
                        this.waitForArduinoResponse = 0;
                        this.defaultAverages        = 3;
                    case 'ohmmeter'
                        this.init
                        this.s1.Parity              = 'none';
                        this.s1.DataBits            = 8;
                        this.waitForArduinoResponse = 0;
                        this.defaultAverages        = 1;
                    otherwise
                        error([upper(mfilename) '::wrong input arguments. The object has the following input structure: itaArduino(port, arduinoName) ']);
                end
                
            end
            
            ita_verbose_info('\nNOTE: If you change the BAUD rate then you must change it on the arduino as well.\n');
        end
        
        
        function init(this)
            % set up serial communication
            if isempty(this.s1)
                this.s1 = serial(this.port,'BaudRate',this.baud);
                this.open;
            else
                this.close();
                this.open();
            end
        end
        
        
        function [T,RH] = get_temperature_humidity(this,nAverage)
            %
            %    GET_TEMPERATURE_HUMDITY: Measures the temperature and humidity and
            %                             saves the value in the object. Access the
            %                             values with object_name.temperature and
            %                             object_name.humidity
            %
            %             Example: object_name.get_temperature_humidity
            %
            if nargin < 2
                nAverage = this.defaultAverages;
            end
            
            [T, RH] = deal(nan(nAverage,this.nSensors));
            for iAverage = 1:nAverage
                send2arduino(this,'m'); % m for measurement
                resultStr = this.response;
                
                if this.nSensors == 1
                    idxComma = strfind(resultStr,',');
                    if ~isempty(idxComma)
                        T(iAverage)   = str2double(resultStr(1:idxComma-1));
                        RH(iAverage)  = str2double(resultStr(idxComma+1:end));
                    end
                else % temperature array
                    
                    singleSensorResponses = regexp(strtrim(resultStr), ';', 'split');
                    singleSensorResponses = singleSensorResponses (1:end-1); % last element is empty ( or incomplete)
                    if numel(singleSensorResponses) ~= this.nSensors
                        ita_verbose_info(sprintf('this.nSensors = %i, but Arduino send %i sensor responses.',  this.nSensors, numel(singleSensorResponses) ),0)
                        nReturnedSensorValues = numel(singleSensorResponses);
                    else
                        nReturnedSensorValues = this.nSensors;
                    end
                    
                    for iSensor = 1:nReturnedSensorValues
                        idxComma = strfind(singleSensorResponses{iSensor},',');
                        
                        if isempty(idxComma) % this is temperature sensor, no humidity
                            T(iAverage, iSensor)  = str2double(singleSensorResponses{iSensor});
                            RH(iAverage, iSensor) = nan;
                        else % temp & humidity
                            T(iAverage, iSensor)  = str2double(singleSensorResponses{iSensor}(1:idxComma-1));
                            RH(iAverage, iSensor) = str2double(singleSensorResponses{iSensor}(idxComma+1:end));
                        end
                    end
                    
                end
            end
            
            if nAverage > 1
                if this.nSensors == 1
                    T                   = round(mean(T(T~=0))*100)/100;
                    RH                  = round(mean(RH(RH~=0))*100)/100;
                else
                    T                   = round(mean(T,1)*100)/100;
                    RH                  = round(mean(RH,1)*100)/100;
                end
            end
            
            this.temperature    = T;
            this.humidity       = RH;
        end
        
        function [R,Vm] = get_resistance(this,nAverage)
            if nargin < 2
                nAverage = this.defaultAverages;
            end
            [Vm, R] = deal(nan(nAverage,1));
            for iAverage = 1:nAverage
                send2arduino(this,'r'); % r for resistance
                resultStr = this.response;
                idxComma = strfind(resultStr,',');
                if ~isempty(idxComma)
                    Vm(iAverage) = str2double(resultStr(1:idxComma-1));
                    R(iAverage) = str2double(resultStr(idxComma+1:end));
                end
            end
        end
        
        function send2arduino(this, message) % Sends a message to the arduino
            
            if ~ismember(message,this.possibleMessages)
                error([upper(mfilename) '::the message is not recognized. Current recognized messages include: ''m''']);
            end
            
            if isempty(this.s1)
                this.init;
            end
            
            flushinput(this.s1);
            flushoutput(this.s1);
            
            fprintf(this.s1, message);
            
            if this.waitForArduinoResponse   % temperature array needs more time to send data
                fprintf('\t itaArduino: receiving data')
                for iSec = 1:floor(this.waitForArduinoResponse)
                    fprintf('.')
                    pause(1)
                end
                pause(rem(this.waitForArduinoResponse,1)) % wair rest time
                fprintf('done\n')
            end
            
            while(this.s1.bytesavailable == 0)        % wait until handshake sent back
            end
            
            this.response = fgetl(this.s1);
            
            if isempty(this.response)
                error([upper(mfilename) '::Malfunction, response was empty']);
            end
        end %end send2arduino function
        
        
        function open(this) % opens the serial port
            %
            %    OPEN: A serial port MUST BE OPENED in order to communicate with the
            %          arduino.
            %
            %             Example: object_name.open;
            %
            fopen(this.s1);
            if ~strcmpi(this.s1.Status,'open')
                try
                    fopen(this.s1);
                    pause(3);
                catch theError
                    error([upper(mfilename) '::serial object cannot be opened:\n' theError.message]);
                end
                
                if ~strcmpi(this.s1.Status,'open')
                    error([upper(mfilename) '::serial object cannot be opened']);
                end
            end
            pause(4); % Takes time to open the serial port
        end
        
        
        function close(this) % Stops the serial port
            %
            %    CLOSE: The serial port MUST BE CLOSED before variable deletion,
            %           otherwise MATLAB will have to be restarted (or ccx).
            %
            %             Example: object_name = object_name.close;
            %
            %           The function only returns the object for the sake of
            %           following the same format of obj_name = obj_name.fuction_name
            %
            fclose(this.s1);
        end
    end
end
