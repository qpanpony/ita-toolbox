classdef itaMeasurementTasksMovtec < itaMeasurementTasksScan
    % Measurement Tasks MOVTEC is used for all measurements involving the
    % MOVTEC controller. e.g. italian or XY table
    
    % Author: Pascal Dietrich - Mai 2010
    
    
    
    % <ITA-Toolbox>
    % This file is part of the application Movtec for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % *********************************************************************
    % *********************************************************************
    properties (Hidden = false)
        waitForSerialPort = 0.01; %time in seconds (double) to wait for tx/rx
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = protected)
        
    end
    % *********************************************************************
    % *********************************************************************
    methods
        function reset(this)
            %reset the Obj. Ready to start from scatch again...
            this.mIsInitialized = false;
            this.mCurrentPosition = cart2sph(itaCoordinates(1));
            this.mLastMeasurement = 0;
        end
        
        function init(this)
            %do a reset and also reset the serialObj
            this.reset(); % Do a reset first.
            com_port = ita_preferences('movtecComPort');
            if ~isempty(this.diaryFile)
                diary off;
                diary(this.diaryFile);
            end
            if strcmpi(com_port,'noDevice')
                ita_verbose_info('itaMeasurementTasksMovtec: Please select a COM-Port in ita_preferences',0);
                ita_preferences;
                return;
            end
            %% Init RS232 and return handle
            try
                if isempty(this.measurementSetup)
                elseif isempty(this.measurementSetup) && isempty(this.measurementSetup.inputMeasurementChain(1).coordinates.x)
                    for idx = 1:numel(this.measurementSetup.inputMeasurementChain)
                        this.measurementSetup.inputMeasurementChain(idx).coordinates = itaCoordinates([0 0 0]);
                    end
                end
                
                insts = instrfind;         %show existing terminals using serial interface
                if ~isempty(insts)
                    aux = strfind(insts.Name,com_port);
                    if numel(aux) == 1
                        aux = {aux}; %pdi bugfix
                    end
                    for idx = 1:numel(aux)
                        if ~isempty(aux{idx})
                            delete(insts(idx));             %delete used serial ports
                        end
                    end
                end
                this.mSerialObj = serial(com_port,'Baudrate',9600,'Databits',8,'Stopbits',1,'OutputBufferSize',3072);
                fopen(this.mSerialObj);                   % connection start
                
                
                %gregor:
                fwrite(this.mSerialObj,hex2dec('15'));      %21 in dec         % Kill old commandos Motor 1
                fwrite(this.mSerialObj,hex2dec('35'));               % Kill old commandos Motor 2
                %
                fwrite(this.mSerialObj,85);               % Freigabe (Motor)
                this.mIsInitialized = true;
                
                % TODO % pdi: test if MOVTEC is responding ?!
                
                fwrite(this.mSerialObj,hex2dec('11')); %ask Movetec
                pause(0.1); %avoid asking to much, RS232 will die otherwise
                H_status = ita_angle2str(dec2bin(fread(this.mSerialObj,1)),8)
                
                
            catch errmsg
                this.mIsInitialized = false;
                ita_verbose_info(errmsg.message,0);
                error('i: Unable to initialize correctly');
            end
            
            %% subfolder for data - speed reasons for lots of files
            if ~isdir(this.finalDataPath)
                mkdir(this.finalDataPath);
            end
            
        end
    end %methods
    
    %% Hidden Methods
    methods(Hidden = true)
        function res = finalDataPath(this)
            %final data path string
            res = [this.dataPath filesep 'data'];
        end
        function varargout = getPosition(this,varargin) % pdi:checked
            %this.mSerialObjGETPOSITION - returns the position of motor1 and motor2 in
            %   steps.
            %
            %   Call:   [stepsMotor1, stepsMotor2]= this.mSerialObjgetPosition
            %           [y, x]= this.mSerialObjgetPosition
            %           stepsMotor1 = this.mSerialObjxytable_getPosition('getPos1', true,...
            %                           'getPos2',false)
            %           stepsMotor2 = this.mSerialObjxytable_getPosition('getPos2', true,...
            %                           'getPos1',false)
            %   optional arguments:
            %           'serial_obj', serial_obj    % if not given, try to
            %           use a global
            %           serial_obj (global serial_movtec, created by func:this.mSerialObjinit)
            %           'getPos1', bool             % defaultvalue: true
            %           'getPos2', bool             % defaultvalue: true
            
            thisFuncStr  = [upper(mfilename) ':'];
            
            % check input arguments
            sArgs = struct('getPos1',true,'getPos2',true);
            sArgs = ita_parse_arguments(sArgs,varargin);
            serial_movtec = this.mSerialObj;
            
            if sArgs.getPos2
                fwrite(serial_movtec,hex2dec('30'));    % command to get position from motor2
                pause(0.2)
                fwrite(serial_movtec,hex2dec('30'));    % have to be send twice
                pause(0.5)
                pos2=fread(serial_movtec,2);
                pos2= hex2dec([dec2hex(pos2(2)) dec2hex(pos2(1))]);
            end
            % between the commands a small pause is required
            if sArgs.getPos1 && sArgs.getPos2
                pause(0.5)
            end
            
            if sArgs.getPos1
                fwrite(serial_movtec,hex2dec('10'));    % command to get position from motor1
                pause(0.1)
                fwrite(serial_movtec,hex2dec('10'));    % have to be send twice
                pause(0.2)
                pos1=fread(serial_movtec,2);
                pos1= hex2dec([dec2hex(pos1(2)) dec2hex(pos1(1))]);
            end
            
            if sArgs.getPos1 && sArgs.getPos2
                if (nargout==1) || nargout > 2
                    error([thisFuncStr 'Check number of your output arguments!']);
                elseif nargout == 2
                    varargout= [{pos1} {pos2}];
                else
                    disp(['The x-position is: ' num2str(pos2)]);
                    disp(['The y-position is: ' num2str(pos1)]);
                end
            elseif sArgs.getPos1
                if nargout > 1
                    error([thisFuncStr 'Check number of your output arguments!']);
                elseif nargout == 1
                    varargout = {pos1};
                else
                    disp(['The y-position is: ' num2str(pos1)]);
                end
            elseif sArgs.getPos2
                if nargout > 1
                    error([thisFuncStr 'Check number of your output arguments!']);
                elseif nargout == 1
                    varargout= {pos2};
                else
                    disp(['The x-position is: ' num2str(pos2)]);
                end
            end
            
            %EOF
        end
    end
    
    % *********************************************************************
    % *********************************************************************
    methods (Abstract)
        this = wait(this)
        %waif for the MOVTEC to finish moving
    end %methods
    % *********************************************************************
    % *********************************************************************
    
    
end