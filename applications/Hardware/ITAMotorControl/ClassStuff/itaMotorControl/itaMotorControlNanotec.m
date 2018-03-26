classdef itaMotorControlNanotec < itaMotorControl
    %ITAMOTORCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected, Hidden = true)
        mInUse = false;
        commandlist         =   []; % Store commands in here...
        receivedlist        =   []; % All responses from all motors
        actual_status       =   []; % Store status - don't send the same command again!

        started;
        preparedList        =   []; % continuous move. prepare first and start later
    end
    
    properties 

        motorIDList = [];
        motorList = [];

        waitForSerialPort   =     0.15;   % Time to wait between two commands
        timeout_response    =     0.4;    % Time in seconds within each motor has to response to a command!
        timeout_move        =   300;      % Time in seconds within each device has to reach their new position!
        failed_command_repititions  =   5;  % How often do we repeat commands until we throw an error?
  
        
        
    end
    
    methods
        
        function this = itaMotorControlNanotec(varargin)
            this.baudrate = 19200;
            this.databits = 8;
            this.stopbits = 1;
            this.OutputBufferSize = 3072;  
            
            
            
           this.init(); 
        end
        
        function this = init(this)
            this.mSerialObj = itaSerialDeviceInterface.getInstance();
            
            this.mSerialObj.portOpen = true;
            
            %load all the motors and init them to get the list of connected
            %motors
            this.motorList{1} = itaMotorNanotec_Turntable('motorControl',this);
            this.motorList{2} = itaMotorNanotec_HRTFarc('motorControl',this);
            this.motorList{3} = itaMotorNanotec_Arm('motorControl',this);
            
            % get status for all motors
            for index = 1:length(this.motorList)
               motorID(index) = this.motorList{index}.getMotorID();
               status(index) = this.motorList{index}.isActive();
            end
            
            idx = 0;
            while idx < 50
                if this.mSerialObj.BytesAvailable ~= 0
                    resp = this.mSerialObj.recvAsynch();
                    if length(resp) < 3  
                        return
                    end
                    idNum = str2num(resp(3));
                    
                    for index = 1:length(this.motorList)
                        if ~isempty(find(motorID(index) == idNum, 1))
                            status(index) = 1;
                            this.motorList{index}.setActive(1);
                        end
                    end
                end
                pause(0.01) % Half second to respond... more than enough!
                idx = idx + 1;
            end
            
            
            this.motorList = this.motorList(status);
            this.motorIDList = motorID(status);
            this.started(1:length(this.motorIDList)) = false;
            
            % send configuration for all active motors
            for index = 1:length(this.motorList)
                this.motorList{index}.sendConfiguration;
                this.motorList{index}.setActive(true);
                if ~this.send_commandlist(this.failed_command_repititions)
                    this.mIsInitialized             =   false;
                    error(sprintf('Motor %s is not responding!',this.motorList{index}.getMotorName));
                end
            end
            
            this.displayMotors();
        end
        
        function setWait(this,value)
           this.wait = value; 
        end
        
        function stopAllMotors(this)
            for i = 1:5 % repeat several times to ensure that every motor stops!
                for index = 1:length(this.motorList)
                    this.mSerialObj.sendAsynch(sprintf('#%dS\r'        , this.motorIDList(index)));
                end
            end    
        end
        
        
        function ret = sendControlSequenceAndPrintResults(this,sequence)
            for index = 1:length(this.motorIDList)
                tmpID = this.motorIDList(index);
                this.mSerialObj.sendAsynch(sprintf('#%d%s\r'        , tmpID,sequence));
%                 this.mSerialObj.sendAsynch(sprintf('%s\r'        , tmpID,sequence));
            end
            pause(this.waitForSerialPort);
            ret = [];
            while (this.mSerialObj.BytesAvailable)
                resp    =   this.mSerialObj.recvAsynch;
                ret{end+1} = resp;
%                 disp(resp)
                pause(this.waitForSerialPort);
            end
        end
         
        
        function moveTo(this,varargin)
            % if itaCoordinates are given, the position is passed to all
            % motors. they have to decide if they move
            
            controlOptions.start = 1;
            controlOptions.wait = 1;
            
            this.clear_receivedlist;
            %prepare moves
            if length(varargin) ~= 1

                for index = 1:length(this.motorList)
                   sArgs.(this.motorList{index}.getMotorName()) = nan(1);
                end
                
                [sArgs, notFound] = ita_parse_arguments(sArgs, varargin);
                % parse the notfound options for wait

                [controlOptions, notFound] = ita_parse_arguments(controlOptions,notFound);
                this.wait = controlOptions.wait;
                for index = 1:length(this.motorList)
                    motorposition = sArgs.(this.motorList{index}.getMotorName());
                    this.started(index) = this.motorList{index}.prepareMove(motorposition,notFound{:});
                end
            else
                position = varargin{1}; 
                for index = 1:length(this.motorList)
                    this.started(index) = this.motorList{index}.prepareMove(position);
                end
            end
            
            if controlOptions.start == 1
                % start moves
                for index = 1:length(this.motorList)
                    if this.started(index)
                        this.motorList{index}.startMoveToPosition();
                    end
                end
            end

            
            % send commands
            if ~this.send_commandlist(this.failed_command_repititions)
                error(sprintf('Motor %s is not responding!',this.motorList{index}.getMotorName));
            end
            
           if controlOptions.start == 1
                this.wait = controlOptions.wait;
                % wait
                this.wait4everything
                this.wait = 1;
           end
            
        end
        
        
        function freeFromStopButton(this)
            for index = 1:length(this.motorList)
                    this.motorList{index}.freeFromStopButton();
            end            
        end
        
        function reference(this)
            this.clear_commandlist;
            for index = 1:length(this.motorList)
               this.started(index) = true;
               this.motorList{index}.moveToReferencePosition();
               this.started(index) = true;
                if ~this.send_commandlist(this.failed_command_repititions)
                    error(sprintf('Motor %s is not responding!',this.motorList{index}.getMotorName));
                end

            end
            this.wait4everything;
            
            for index = 1:length(this.motorList)
               this.motorList{index}.setReferenced(true); 
            end
        end
        
        function prepareForContinuousMeasurement(this,varargin)
            % determine the motor name
            % for now, this only works if one motor is connected (turntable
            % or hrtfarc)
            motorName = '';
            if length(this.motorList) == 1
               motorName = this.motorList{1}.getMotorName();
            end
            if ~(strcmp(motorName,'HRTFArc') || strcmp(motorName,'Turntable'))
               error('Only HRTFArc or Turntable supported'); 
            end
            
            if ~isempty(this.preparedList)
                error('Already prepared?');
            end
            % get the preangle and the speed
            sArgs.preAngle = 0;
            sArgs.speed = 2;
            sArgs.postAngle = 10;
            [sArgs notFound] = ita_parse_arguments(sArgs, varargin);

            % first, do a reference move
            ita_verbose_info('Moving to reference',1)
            this.reference
            ita_verbose_info('Disable reference position',1)
            this.motorList{1}.disableReference(1);
            ita_verbose_info('Moving to pre angle',1)
            this.moveTo(motorName,-sArgs.preAngle,'absolut',false,'speed',2)
            
            
            % now prepare the big move but don't start it
            moveAngle = 360 + sArgs.preAngle + sArgs.postAngle;
            this.moveTo(motorName,moveAngle,'speed',sArgs.speed,'absolut',false,'start',0,'limit',0,'direct',1);
            this.preparedList = motorName;
            ita_verbose_info('Finished preparing',2)
        end
        
        function startMove(this)
            for index = 1:length(this.motorList)
                if this.started(index)
                    this.motorList{index}.startMoveToPosition();
                end
            end
            this.wait4everything;
        end
        
        function startContinuousMoveNow(this)
            % start moves
            for index = 1:length(this.motorList)
                if strcmp(this.preparedList,this.motorList{index}.getMotorName())
                    this.motorList{index}.startMoveToPosition();
                end
            end
            
            % send commands
            if ~this.send_commandlist(this.failed_command_repititions)
                this.mIsInitialized             =   false;
                error(sprintf('Motor %s is not responding!',this.motorList{index}.getMotorName));
            end
            this.wait4everything
            this.preparedList = [];
            ita_verbose_info('Enable reference position',1)
%             this.sendControlSequenceAndPrintResults(':port_in_a=7');
        end
        
        function success = add_to_commandlist(this, string_to_send)
            % Add command to commandlist
            this.commandlist{end+1}             =   string_to_send;
            success             =   1;
        end
        
        
        function success = send_commandlist(this, repititions, sendStarts)
            
            % this function first selects all commands but the start
            % commands *A and checks if they are sucessfully transmitted.
            % afterwards the start commands are send. 
            if ~exist('sendStarts','var')
                sendStarts = 0;
            end
            
            if sendStarts == 0
               pattern = '.*A';
               startCommands = regexp(this.commandlist,pattern);
            else
               pattern = '.*';
               startCommands = regexp(this.commandlist,pattern);
            end
            
            tmpCommandList = [];
            tmpStartList = [];
            for index = 1:length(this.commandlist) % sorry.. does not work any other way
                if isempty(startCommands{index})
                    tmpCommandList{end+1} = this.commandlist{index};
                else
                    tmpStartList{end + 1} = this.commandlist{index};
                end
                
            end
            
            % if you want to get rid of the for loop, start somewhere with
            % this. did not work because of empty cells
%             tmpCommandList = this.commandlist(logical(cell2mat(startCommands)));
%             tmpStartList = this.commandlist(~logical(cell2mat(startCommands)));
            

            % first, set the commandlist to the tmpCommandList
            % after this is done, call the function again with the
            % startList as commandlist
            if sendStarts
                this.commandlist = tmpStartList ;
            else
                this.commandlist = tmpCommandList;
            end
            % Send all commands in the commandlist. Check response. Repeat
            % command if no response. Argument is the number of
            % max repititions.
            success = false;
            this.clear_receivedlist;
            %
            ita_verbose_info(['Sending ' num2str(numel(this.commandlist)) ' commands...'], 2);
            % Send all commands:
            for i = 1:numel(this.commandlist)
                this.mSerialObj.sendAsynch(this.commandlist{i});
                pause(this.waitForSerialPort);
            end
            
            cnt                 =   round(this.timeout_response / this.waitForSerialPort);
            responseList = cell(1,1);
            while (cnt > 0) && ~isempty(this.commandlist)
                if this.mSerialObj.BytesAvailable
                    resp        =   this.mSerialObj.recvAsynch;
                    responseList{end+1}            = resp;
                    
                    
                    found       =   strfind(this.commandlist, resp(1:end)); % search command...
                    founditem   =   false;
                    for i = 1:numel(found)
                        if ~isempty(found{i})
                            this.commandlist(i)     =   [];
                            foundlist{i}            = resp;
                            founditem               =   true;
                            
                            if ~isempty(strfind(resp, '='))
                                % Set some parameter - now store it local and avoid sending it again!
                                parametername = genvarname(regexprep(['Motor_' resp(1) '_Parameter_' resp(2:strfind(resp, '=')-1)], ':', ''));
                                value = resp(strfind(resp, '=')+1:end);
                                this.actual_status.(parametername) = value;
                            end
                            
                            break;
                        end
                    end
                    if founditem == false
                        this.receivedlist{end+1}    =   resp;
                    end
                else
                    pause(this.waitForSerialPort);
                    cnt         =   cnt - 1;
                end
            end
            % Check if all commands are confirmed:
            if isempty(this.commandlist)
                success         =   true;
                
                if sendStarts == 0 && ~isempty(tmpStartList)
                    % send all the start commands now
                    ita_verbose_info(['All commands succesfully send. Sending start commands'], 2);
                    this.commandlist = tmpStartList;
                    this.send_commandlist(this.failed_command_repititions,1);
                else
                    ita_verbose_info('All commands succesfully send.', 2);
                end
            else
                % Not all commands are confirmed within given time - check
                % if we are allowed to send them again!
                if repititions > 0
                    ita_verbose_info([num2str(numel(this.commandlist)) ' commands left without a response! I will send them again!'], 0);
                    success     =   this.send_commandlist(repititions - 1);
                else
                    ita_verbose_info('Some commands left without a response!', 0);
                    for i = 1:numel(this.commandlist)
                        ita_verbose_info(['itaEimar: ' this.commandlist{i}(1:end-1)], 0);
                    end
                    success     =   false;
                end
            end
            % *********************************************************************
            if ~isempty(this.receivedlist)
                % Show user what is received without expected to be received:
                ita_verbose_info([sprintf('I could not assign these motor responses to a request:\r') this.receivedlist{:}], 0);
            end
        end
        
        function wait4everything(this, varargin)     
            if this.wait
                %  This function checks if the turntable has reached the end
                %  position and only returns when the end position is reached.
                pause(0.5);

                for index = 1:length(this.motorIDList)
                    tmpID = this.motorIDList(index);
                    if (this.started(index) == true)
                        ita_verbose_info('Waiting for Motor %s to reach position...',2);
                    end
                end

                % Initialize some counter:
                idx     =   0;
                idxMAX  =   round(this.timeout_move / this.waitForSerialPort); %Stop after 300 sec!
                time    =   (clock+[0 0 0 0 0 this.timeout_move]);
                temp    =   floor(time./ [inf inf inf 24*60*60 60*60 60]);
                time    =   time + [temp(2:6) 0] - temp(1:6).*[0 0 0 24 60 60];
                temp    =   floor(time./ [inf inf inf 24*60*60 60*60 60]);
                time    =   time + [temp(2:6) 0] - temp(1:6).*[0 0 0 24 60 60];
                ita_verbose_info(sprintf('Timeout (%d seconds) will occur at %d:%d:%d if >=1 motor has not reached it''s target position until then!', ...
                    this.timeout_move, time(4), time(5), round(time(6))), 1)
                errors  =   false;
                % Wait till all motors stopped:
                while sum(this.started > 0)
                    % If motor responses are available:
                    if this.mSerialObj.BytesAvailable || ~isempty(this.receivedlist)
                        if isempty(this.receivedlist)
                            resp    =   this.mSerialObj.recvAsynch;
                        else
                            % If there are pending answers - check them:
                            resp    =   this.receivedlist{1};
                            this.receivedlist(1)    =   [];
                        end
                        if size(resp, 2) > 5
                            if strcmpi(resp(4), 'j') || strcmpi(resp(4), '$')
                                byte = str2double(resp(5:end));
                                if isnumeric(byte) && ~isinf(byte) && ~isnan(byte)
                                    byte = dec2bin(byte, 8);
                                    answerID = str2num(resp(3));
                                    for index = 1:length(this.motorIDList)
                                        tmpID = this.motorIDList(index);
                                        if ~isempty(find(answerID == tmpID, 1))
                                            if (strcmp(byte(end), '1') && ~strcmp(byte(end-2), '1'))
                                                this.started(index)   =   false;
                                                ita_verbose_info('Motor reached position...',2);    
                                            elseif strcmp(byte(end-2), '1')
                                                this.started(index)   =   false;
                                                ita_verbose_info('Motor position error...',0);
                                                errors              =   true;
                                                this.add_to_commandlist(sprintf('#%dD\r'    , tmpID));
                                            end
                                        end 
                                    end
                                end
                            end
                        end
                    end
                    idx             =   idx + 1;
                    if idx > idxMAX
                        error('No response within %d seconds.... something is wrong!', this.timeout_move)
                    end
                    % Send a status request every few seconds... (To check for position errors!)
                    if mod(idx, idxMAX/50) == 3; %idxMAX/50-8
                        ita_verbose_info('Continuouly checking for position errors every few seconds...', 2);

                        for index = 1:length(this.motorIDList)
                            tmpID = this.motorIDList(index);
                            this.mSerialObj.sendAsynch(sprintf('#%d$\r'        , tmpID));
                        end
                    end
                    pause(this.waitForSerialPort);
                end
                % Check if any errors occured:
                if errors == false
                    ita_verbose_info('Position reached',1);
                else
                    ita_verbose_info('Position NOT reached! - Check for errors!', 0);
                    
                    %assuming stop button clicked
                    %call freefrombutton function
%                     this.freeFromStopButton
%                     this.send_commandlist(this.failed_command_repititions); % mpo: bugfix: send_commandlist needs argument
%                     this.isReferenced = false;
                end
                this.clear_receivedlist;
                this.started(1:length(this.motorIDList)) = false;
            end
        end
    end
    
    methods(Hidden = true)
        function openSerialConnection(this)
            try
            if(this.mSerialObj.portOpen == false) 
                iMI.portOpen = true;                        % start asynchronous communication
            end
            catch errmsg
                ita_verbose_info(errmsg.message,0);
                ita_verbose_info('Could not open port... something might be wrong!', 0);
            end
        end
        
       function displayMotors(this)
           disp('Active Motors:')
           if (isempty(this.motorList))
               disp('None!');
           end
           for index = 1:length(this.motorList)
               disp(sprintf('%s',this.motorList{index}.getMotorName));
           end
        end
 
        
        function clear_commandlist(this)
            % Delete commandlist
            this.commandlist    =   [];
        end
        function clear_receivedlist(this)
            % Clear list of motor-responses which could not be assigned to
            % a request
            this.receivedlist   =   [];
        end
    end
    
end

