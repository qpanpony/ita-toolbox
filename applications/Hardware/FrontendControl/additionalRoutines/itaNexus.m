classdef itaNexus < handle

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    % Measurement Tasks are unified Setups for common Measurements
    
    % Author: Pascal Dietrich - Mai 2010
    
    % *********************************************************************
    % *********************************************************************
    properties
        serialObj = []; %serialObj
        deviceList = {};
        remote = false;
        currentSettings = [];
        waitForSerial = 0.02;
        nexusSetup = [];
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = protected)
        mIsInitialized = false;
        mTerminator = 10;
    end
    
    methods (Static)
        function out_str = available_devices(in_str)
            list = {'2172853','G0933';...
                '2192235','G0934';...
                '2049653','G0932';...
                'XXXXXXX','G0XXX'};
            
            if nargin == 0
                for idx = 1:size(list,1)
                    out_str{idx} = [list{idx,1} '(' list{idx,2} ')']; %#ok<AGROW>
                end
            else
                idx = ismember(list,in_str);
                out_str = (list(fliplr(idx)));
            end
            
        end
    end
    
    % *********************************************************************
    % *********************************************************************
    methods
      
        function res = isInitialized(this)
            res = this.mIsInitialized;
        end
        
        function varargout = write(this,message,varargin)
            sArgs = struct('Terminator','on','Initialize','on');
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            if sArgs.Initialize, if this.mIsInitialized == 0; this.init; end; end;
            if this.serialObj.BytesAvailable ~= 0
                fclose(this.serialObj);
                fopen(this.serialObj);
            end
            ita_verbose_info(['itaNexus::Sent: ' message],2);
            data_in = uint8(message);
            if sArgs.Terminator %do you want to send a terminator
                data_in = [data_in this.serialObj.Terminator]; % add Terminator <Te>
            end
            blocklength = 4;
            restlength = rem(length(data_in),blocklength);                                                 % divide into blocks and find out the rest length
            for i = 1:length(data_in)/blocklength;                                                        % write blocks
                fwrite(this.serialObj, data_in([i*blocklength-(blocklength-1):i*blocklength]))
                pause(this.waitForSerial)
            end
            if ~isempty(data_in([end-restlength+1:end]))
                fwrite(this.serialObj, data_in([end-restlength+1:end]))
            end % write rest
            
            res = this.read(length(data_in));
            
            if nargout == 1
                varargout{1} = res;
            end
        end
        
        function res = read(this,nBytes)
            if ~exist('nBytes','var')
                pause(0.05)
                nBytes =  this.serialObj.BytesAvailable;
            end
            if nBytes > this.serialObj.BytesAvailable
                pause (0.1)
                nBytes = this.serialObj.BytesAvailable;
                
            end
            if nBytes ~= 0
                res = fscanf(this.serialObj,'%c',nBytes);
            else
                res = '*** nothing received ***';
            end
            if (this.serialObj.BytesAvailable  ~= 0)
                ita_verbose_info(['itaNexus::There are still ' num2str(this.serialObj.BytesAvailable) ' bytes to be read: ' ],2);
                
            end
            ita_verbose_info(['itaNexus::Received: ' res],2);
            
        end
        
        
        function msg = query(this,data_in,varargin)
            this.write(data_in,varargin{:});
            pause(0.2)
            msg = this.read;
        end
        
        %% ****************************************************************
        
        
        function this = handshake(this)
            this.mIsInitialized = false;

            % Enables communication with all connected Nexus units
            data_in = 'NEXUS00 DATEND';
            this.write(data_in,'Initialize','off');
           
            % Reset previously assigned numbers to unassigned status
            data_in = 'NEXUS00 IDRESET';
            this.write(data_in,'Initialize','off')
            
            
            for idx =1:length(this.deviceList)
                data_in = ['NEXUS00 IDNUM0',num2str(idx)];
                res = this.query(this,data_in,'Initialize','off');
                
                test_str = this.available_devices(res);
                if ~isempty(test_str)
                    this.mIsInitialized = true;
                    ita_verbose_info(['nexus device found',2])
                    
                end
                % %
                % %                 if strcmp(res,'2192235')
                % %                     res = this.query(this,res);
                % %                     if strcmp(res,'OK')
                % %                         this.write(this,this.serialObj.Terminator)
                % %                     else
                % %                     end
                % %                 else
                % %
                % %                 end
                % %
                % %                 %% old code below
                % %
                % %                 if s.BytesAvailable == 0
                % %                     if isempty(comportList)
                % %                         error([thisFuncStr, 'I could not find a device on the available COM ports. Check the connection and restart matlab to update the comports'])
                % %                     else
                % %                         new_comport = comportList(end);
                % %                         ita_nexus_setup('comport',new_comport,'comportList',comportList,'numberOfDevices',sArgs.numberOfDevices,'remote',sArgs.remote)
                % %                         return;
                % %                     end
                % %                 end
                % %                 pause(sArgs.pause)
                % %                 if (s.BytesAvailable ~= 0)
                % %                     data_out = fscanf(s,'%c',s.BytesAvailable);
                % %                     msg = data_out(16:end); % 'NEXUS00 IDNUM0idx' (sent command) are the first 15 signs
                % %                     data_in = msg;
                % %                     data_in = uint8(msg);
                % %                     for i = 1:length(data_in)
                % %                         fwrite(s, data_in(i))
                % %                         pause(0.02)
                % %                     end
                % %                     if s.BytesAvailable == 0
                % %                         status = 'ERROR';
                % %                     else
                % %                         status = fscanf(s,'%c',s.BytesAvailable); % OK?
                % %                         status = status(8:end);
                % %                         status = regexprep(status,'\s$','');
                % %                     end
                % %                     if s.BytesAvailable ~= 0
                % %                         data_out = fscanf(s,'%c',s.BytesAvailable); %#ok<NASGU>
                % %                     end
                % %                 else
                % %                     status = 'ERROR';
                % %                 end
                % %                 if strcmp(status,'OK') % if status is 'OK' the Nexus is adressed and the right Comport was used
                % %                     holdComport = 1; % found right Comport, don't search anymore
                % %                     fwrite(s,s.Terminator); % Send Terminator <Te>
                % %                     pause(sArgs.pause);
                % %                     data_out = fscanf(s);
                % %                     NexusSetup.ComPort = comport;
                % %                     if (sArgs.detectComport == true) % just return the Comport
                % %                         if (s.BytesAvailable ~= 0)
                % %                             data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                % %                         end
                % %                         if (s.BytesAvailable ~= 0)
                % %                             data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                % %                         end
                % %                         fclose(instrfind);
                % %                         ita_verbose_info([thisFuncStr 'Nexus Comport detected. Devices are connected to ' char(comport) '.'],1);
                % %
                % %                         varargout{1} = comport;
                % %                         return;
                % %                     end
                % %                     NexusSetup.IDs{idx} = msg;
                % %                     if strcmp(msg,'2172853')
                % %                         NexusSetup.Devices{idx} = 'G0933';
                % %                     elseif strcmp(msg,'2192235')
                % %                         NexusSetup.Devices{idx} = 'G0934';
                % %                     elseif strcmp(msg,'2049653')
                % %                         NexusSetup.Devices{idx} = 'G0932';
                % %                     end
                % %                     ita_verbose_info([thisFuncStr 'Status: device ' num2str(idx) '(Nexus-ID: ' NexusSetup.IDs{idx} ')' ' OK'],1);
                % %                     if ~isempty(comportList)
                % %                         comportList = []; %empty comportList, right Comport already found
                % %                     end
                % %                 else %status != OK... wrong Comport?...
                % %                     if ~exist('holdComport','var')
                % %                         if ~isempty(comportList)
                % %                             if s.BytesAvailable ~= 0
                % %                                 data_out = fscanf(s,'%c',s.BytesAvailable); %read out any rest data...
                % %                             end
                % %                             %                 fclose(s);
                % %                             new_comport = comportList(end);
                % %                             ita_nexus_setup('comport',new_comport,'comportList',comportList,'numberOfDevices',sArgs.numberOfDevices,'remote',sArgs.remote) %funciton is called recursively with new Comportlist
                % %                         else
                % %                             error(['        All available Comports have been checked. Initialization of Nexus Device ',num2str(idx),' failed. Please ensure the cable is connected correctly.    '])
                % %                         end
                % %                     else
                % %                         break;
                % %                     end
                % %
                % %
                    
                    
%                 end
            end
            
        end
        function this = init(this)
            % only serial handling
            this.mIsInitialized = false;

            try
                insts = instrfind;         %show existing terminals using serial interface
                delete(insts);             %delete used serial ports
                this.serialObj = serial(ita_preferences('nexusComPort'),'Baudrate',9600,'Databits',8,'Stopbits',1,'OutputBufferSize',3072); % create serial object;
                fopen(this.serialObj);                   % connection start
                this.serialObj.Terminator = this.mTerminator;
                
               
            catch errmsg
                this.mIsInitialized = false;
                ita_verbose_info(errmsg.message,0);
                error('i: Unable to initialize correctly');
            end
                    
            this = handshake(this);
            
        end
        
        function this = detectComport(this)
            ComPortList = flipud(ita_get_available_comports())
            i = strmatch ('noDevice', ComPortList);
            if ~isempty(i)
                ComPortList(i) = [];
            end
            
            for idx = 1:length(ComPortList)
                %try to access
                ita_preferences('nexusComPort',ComPortList{idx});
                try
                    disp([ 'trying: ' ita_preferences('nexusComPort') ]   )
                    
                    this.init;
                    if this.isInitialized
                        disp('device found')
                        break;
                    end
                catch
                    ita_verbose_info('no found, yet')
                end
            end
            
        end
        
    end

    % *********************************************************************
    % *********************************************************************
end