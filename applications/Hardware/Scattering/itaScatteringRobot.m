classdef itaScatteringRobot < itaArduino

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    %
    %
    %     IMPORTANT FUNCTIONS:
    %
    %  move_robot(itaCoordinate):    moves the robot to a specified position
    %   move_turn_table(degrees):    rotates the turn table
    %                      reset:    resets the robot to the reference position
    %
    %
    %    UNITS:
    %           ALL of the units are in either METERS or RADIANS
    %
    %           Degrees: capable to the first decmial place. Example: pi/2
    %           Meters: accurate to the millimeter. Example: 0.375m
    %
    %
    %    MOVE_ROBOT: Takes an itaCoordinates object as an input
    %
    %             Example: object_name.move_robot(position.n(1))
    %
    %    MOVE_TURN_TABLE: Turns the table a specified amount of radians (0-2pi)
    %
    %             Example: object_name.move_turn_table(pi/36);
    %
    %
    %    RESET: The robot's current position is recorded after each movement
    %           into the 'position' variable. The reset function moves the
    %           robot back to the reference position, which SHOULD be the top.
    %
    %             Example: object_name.reset;
    %
    %
    %      Tutorial last edited: July 14th, 2011 by Nathan Willson
    %
    %
    
    properties
        position = itaCoordinates(1);
    end
    
    properties(GetAccess=private)
        up_rate = 162080;       % Milli seconds per meter of UPWARD movement (ms/m)            ie: meter value * up_rate = milli seconds required
        down_rate = 161470.588; % Milli seconds per meter of UPWARD movement (ms/m)            ie: meter value * down_rate = milli seconds required
        rot_cw_rate = 635.9832; % Milli seconds per radian of clockwise motion (ms/deg)        ie: Degree value * rot_rate = milli seconds required
    end
    
    methods
        
        function this = itaScatteringRobot(varargin) %% Constructor to intialize the object [ example temp = itaScatteringRobot  or  temp = itaScatteringRobot('COM5')]
            if nargin == 1
                if ischar(varargin{1})
                    this.port = varargin{1};
                else
                    error([upper(mfilename) '::wrong input arguments. The object has the following input structure: itaScatteringRobot(port)']);
                end
            end
            
            this.possibleMessages = {'m','t','l','r','u','d','p','n'};
            
            this.position.rho = 0;
            this.position.z = 0;
            this.position.phi  = 0;
        end      
        
        
        function move_robot(this,position) % Moves the robot to a specified position
            %
            %    MOVE_ROBOT: Takes an itaCoordinates object as an input
            %
            %             Example: object_name.move_robot(position.n(1))
            %
            %
            distance = position.z - this.position.z;
            angle = position.phi;
            
            
            if(distance<0 )
                distance = -1 * distance;
                direction = 'u';
            else
                direction='d';
            end
            
            this.send2arduino(direction,distance); % vertical/horizontal
            this.send2arduino('l', 2*pi);          % reset robot's rotational axis
            this.send2arduino('r',angle);          % move specified degrees
            
        end
        
        
        function move_turn_table(this, angle) % Moves the turn table
            %
            %    MOVE_TURN_TABLE: Turns the table a specified amount of
            %    degrees
            %
            %             Example: object_name.move_turn_table(5);
            %
            %
            if(angle < 0)
                error([upper(mfilename) '::input value for turn table must be greater than zero']);
            end
            
            % have to turn on the power, wait
            % then turn it off after the turn command and wait again
%             this.send2arduino('p'); % power on
%             pause(1);
            this.send2arduino('t',angle);
%             pause(0.5);
%             this.send2arduino('n'); % power off
%             pause(2);
%             disp('finished');
        end
        
        
        function send2arduino(this, message, distance) %% Sends a message to the arduino
            
            if ~ismember(message,this.possibleMessages)
                error([upper(mfilename) '::the message is not recognized. Current recognized messages include: ''l'' , ''r'' , ''u'' , ''d'' , ''m'',  ''t'', ''p'', ''n'' ']);
            end
            
            if isempty(this.s1)
                this.init;
            end
            
            flushinput(this.s1);
            flushoutput(this.s1);
            
            if nargin == 2 % For example obj = obj.send2arduino('UP')
                distance = .05; % default value of 5cm or 0.5 degrees
            elseif distance < 0
                error([uppper(mfilename) '::the input value for distance cannot be less than zero']);
            end
            
            % makes sure the robot does not move overbounds
            if(strcmp(message,'u') && (this.position.z - distance)<=0)
                distance = this.position.z;
            elseif(strcmp(message,'d') && (this.position.z + distance)>=.365)
                distance = .365 - this.position.z;
            elseif(strcmp(message,'l') && (this.position.phi - distance)<0)
                distance = this.position.phi;
            elseif(strcmp(message,'r') && (this.position.phi + distance)>2*pi)
                distance = 2*pi-this.position.phi;
            end
            
            % update the position variable
            if(strcmp(message,'u'))
                this.position.z = this.position.z - distance;
            elseif(strcmp(message,'d'))
                this.position.z = this.position.z + distance;
            elseif(strcmp(message,'l'))
                this.position.phi = this.position.phi - distance;
            elseif(strcmp(message,'r'))
                this.position.phi = this.position.phi + distance;
            end
            
            %If the robot is moving to the very top or the very bottom it
            %SHOULD hit a button. However, this is not always the case as
            %the robot will sometimes stop just before hitting the button.
            %Thus, IF IT SHOULD hit the button (according to the position
            %object) then an extra cenimeter is added to the distance
            %it will move to ensure that the button is pressed. (below)
            if (strcmp(message,'u') || strcmp(message,'u')) && (this.position.z == 0 || this.position.z == .365)
                distance = distance+0.01;
            end
            
            % The serial message sent to the arduino is 5 bytes long.
            % Byte 1: type, such as 'l' or 'r' or 't'
            % Byte 2,3,4: Value.
            %         Example UP/DOWN 0.15 meters = 0150
            %         Example LEFT/RIGHT/TURN pi degrees = 3140
            %
            % There is a handshake of information. Matlab sends information
            % to the robot and when the robot is done moving it sends back
            % a message. Depending on what the message is this will
            % determine if the robot is working as it should.
            
            if(strcmp(message,'r') || strcmp(message,'l') || strcmp(message,'t')) %% Parsing for RADIANS (ROBOT ROTATE AND TURN TABLE)
                if distance >= 1000
                    error([upper(mfilename) '::the rotation angle cannot exceed 2*pi radians']);
                else
                    a = num2str(round(distance*10),'%04d');
                end
                
            elseif(strcmp(message,'u') || strcmp(message,'d')) %% Parsing for METERS
                if distance >= 10
                    error([upper(mfilename) '::the distance cannot exceed 10 m']);
                else
                    a = num2str(round(distance*1000),'%04d');
                end
            elseif strcmp(message,'m')
                a = '';
            else
                a = '0500';
            end
            
            message = strcat(message, a);
            fprintf(this.s1, message);
            
            while(this.s1.bytesavailable == 0) %wait until handshake sent back
            end
            
            this.response = '';
            this.response = fgetl(this.s1);
            
            if ~isempty(this.response)
                % Conditions to assess the returned messages from the robot.
                if(strcmp(this.response(1:(length(this.response)-1)),'bottom pressed'))
                    if(this.position.z < 0.365) %If the robot is not supposed to be at the bottom
                        error([upper(mfilename) '::Robot Malfuction: Robot should not have reached the bottom']);
                    end
                elseif(strcmp(this.response(1:(length(this.response)-1)),'top pressed'))
                    if(this.position.z > 0) %If the robot is not supposed to be at the top
                        error([upper(mfilename) '::Robot Malfuction: Robot should not have reached the top']);
                    end
                elseif(strcmp(this.response(1:(length(this.response)-1)),'down complete'))
                    if(this.position.z == 0.365) %If the robot is supposed to be at the bottom
                        error([upper(mfilename) '::Robot Malfuction: Robot should have reached the bottom']);
                    elseif(this.position.z == 0) %If the robot is supposed to be at the top
                        error([upper(mfilename) '::Robot Malfuction: Robot should have reached the top']);
                    end
                elseif(strcmp(this.response(1:(length(this.response)-1)),'up complete'))
                    if(this.position.z == 0.365) %If the robot is supposed to be at the bottom
                        error([upper(mfilename) '::Robot Malfuction: Robot should have reached the bottom']);
                    elseif(this.position.z == 0) %If the robot is supposed to be at the top
                        error([upper(mfilename) '::Robot Malfuction: Robot should have reached the top']);
                    end
                end
                
                if(strcmp(message(1),'l'))
                    ita_verbose_info('Extra time for rotation reset (left)',1);
                    pause(0.5); %% Extra pause for reseting the rotation
                end
            else
                error([upper(mfilename) '::Robot Malfunction: response was empty']);
            end
        end %end print function
        
        
        function reset(this) %% Brings the robot to the top reset position
            %
            %    RESET: The robot's current position is recorded after each movement
            %           into the 'position' variable. The reset function moves the
            %           robot back to the REFERENCE POSITION, which IS THE TOP.
            %
            %             Example: object_name.reset;
            
            this.position.z = 0.365;  %% tricks the robot into thinking it's at the bottom
            
            if(this.position.z < 0)
                this.position.z = 0;
            end
            pause(1);
            
            this.send2arduino('l', 2*pi);
            this.send2arduino('u',this.position.z);
            this.position.z = 0;
            this.position.phi = 0;
            
            pause(1);
        end
    end
end
