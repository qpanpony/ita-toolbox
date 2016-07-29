classdef itaOSC < handle
    %Open Sound Control - documentation on OSC can be found here: http://opensoundcontrol.org
    % This class realizes OSC communication over UDP/TCP - sending and
    % receiving. It can e.g. be used to remote control KLANG:fabrik from MATLAB 
    % Example: 
    %  TargetIP        = '192.168.1.255';
    %  TargetPort      = 9110;
    %  ReceivePort     = 9113;
    %  osc = itaOSC(TargetIP, TargetPort, ReceivePort);
    %  osc.send(('/Kf/ui/01/ch/01/gain','f',0.5)
    
    % <ITA-Toolbox>
    % This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    
    % author: Dr. Pascal Dietrich | KLANG:technologies GmbH, Aachen
    % TODO pdi; implement OSC msg without args ! oct 2014
    
    % Tutorial -> see itaOSC.tutorial
    
    %% ********************************************************************
    
    properties (Hidden = false, Transient = true, AbortSet = true, SetObservable = true)
        sendPort        = 9000;                    % send on this port
        receivePort     = 9000;                    % receive on this port
        host            = 'localhost';             %
        callback        = '' % pass available data to function for post processing
        timeOut         = 0.3; % wait this time in ms for an response
    end
    
    properties(Hidden = true)
        udp_handle      = [];    % handle to UDP network object
        messageBuffer   = [];    % last message
        verbose         = false; % enable to see some debug information
        %
        %         defaultPause    = 1/1000;% Sometimes a small pause is necessary. Increase for better result, decrease if urgent. Too low is BAD!
    end
    
    properties(Hidden = true)
        isInitialized   = false;          % true:
    end
    
    %% ********************************************************************
    
    methods
        function this = itaOSC(varargin)
            % constructor
            % itaOSC() or itaOSC(host, sendPort, receivePort)
            
            % define listener to keep object up to date
            addlistener(this,'receivePort','PostSet',@this.reset);
            addlistener(this,'sendPort','PostSet',@this.reset);
            addlistener(this,'host','PostSet',@this.reset);
            addlistener(this,'callback','PreSet',@this.reset);
            addlistener(this,'callback','PostSet',@this.init);
            
            if nargin == 3 % directly set host, send and receive port
                this.host            = varargin{1};
                this.sendPort        = varargin{2};
                this.receivePort     = varargin{3};
                this.init
            end
            
        end
        
        function init(this,varargin)
            %Initialize the object and open ports
            if this.isInitialized
                this.reset
            end
            
            this.udp_handle           = udp(this.host,this.sendPort, 'LocalPort', this.receivePort,'InputBufferSize',2^16);
            this.udp_handle.ByteOrder = 'littleEndian';
            
            this.udp_handle.BytesAvailableFcnCount = 4;
            this.udp_handle.BytesAvailableFcnMode = 'byte';
            if strcmpi(this.callback, 'disp')
                this.udp_handle.BytesAvailableFcn = @this.showReceivedMessage;
            else
                this.udp_handle.BytesAvailableFcn = @this.callback_routine;
            end
            fopen(this.udp_handle);
            
            this.isInitialized = true;
            
            
            %             disp('itaOSC init')
        end
        %         function x = callbackReceiveTOC(this,varargin)
        %             this
        %             x = toc
        %         end
        function callback_routine(this,varargin)
            % call the external callback fct - only used internally
            if ~isempty(this.callback)
                OSC = this.receive; %#ok<NASGU>
                eval([this.callback '(OSC)'])
            end
        end
        
        function flush(this)
            flushinput(this.udp_handle);
            disp('itaOSC::flushing completed')
            
        end
        function showReceivedMessage(this,varargin)
            % display the message
            OSC = this.receive;
            for idx = 1:length(OSC)
                disp(OSC(idx))
            end
        end
        
        function reset(this,varargin)
            % reset the object and close ports
            if ~isempty(this.udp_handle)
                try
                    fclose(this.udp_handle);
                    delete(this.udp_handle);
                catch
                    disp('reset not successful')
                end
            end
            this.isInitialized = false; % set to not initiliazed
        end
        
        function message = encode(this,OSCaddress, dataTypes, varargin)
            % encode data into OSC message
            % syntax encode(OSCaddress, type_list, data_list)
            % example: encode('/test', 'if', 10, 0.5)
            
            % set type
            %             if nargin >= 2
            %                 types = this.oscstr([',' varargin{1}]);
            %             else
            %                 types = this.oscstr(',');
            %             end;
            
            % set args (either a matrix, or varargin)
            %             if nargin == 3 && length(types) > 2
            %                 args = varargin{2};
            %             else
            if nargin == 2
                %                 data_packet = []; % pdi: bugfix oct 2014
                dataTypes   = [','];
                data_packet = [this.oscstr(dataTypes)];
                
            else
                args = varargin(1:end);
                %             end;
                
                % convert arguments to the right bytes
                data = [];
                jdx  = 1; % used for the arguments
                for idx = 1:numel(dataTypes) %:length(args) % used for the dataTypes
                    switch(dataTypes(idx))
                        case 'i' % integer
                            data = [data this.oscint(args{jdx})]; %#ok<*AGROW>
                            jdx  = jdx  + 1;
                        case 'f' % float
                            data = [data this.oscfloat(args{jdx})];
                            jdx  = jdx  + 1;
                        case 's' % string
                            data = [data this.oscstr(args{jdx})];
                            jdx  = jdx  + 1;
                        case 'B' % bool
                            if args{jdx}
                                dataTypes(idx) = 'T';
                            else
                                dataTypes(idx) = 'F';
                            end;
                            jdx  = jdx  + 1;
                        case {'N','I','T','F'}
                            %ignore data
                            jdx = jdx; % no increase since no data!
                        otherwise
                            warning(['Unsupported type: ' types(idx+1)]);
                    end;
                end;
                
                %write data to UDP
                dataTypes   = [',' dataTypes];
                data_packet = [this.oscstr(dataTypes) data];
            end
            message     = [this.oscstr(OSCaddress) data_packet];
        end
        
        function send(this,varargin)
            % send the encoded message via UDP
            if ~this.isInitialized
                this.init
            end
            message = this.encode(varargin{:});
            fwrite(this.udp_handle, message);
        end
        
        function OSC = receive(this)
            % receive OSC commands over UDP, decode and return a struct
            
            OSC = [];
            if ~this.isInitialized
                this.init
            end
            while this.udp_handle.BytesAvailable
                raw_data    = fread(this.udp_handle);
                if this.verbose
                    disp('raw udp packet data:')
                    disp(raw_data)
                end
                OSC         = [OSC this.decode(raw_data)];
            end
            this.messageBuffer  = OSC;
        end
        
        function OSC = receive_wait(this)
            x1 = now;
            x2 = 0;
            while (x2-x1)*24*3600 < this.timeOut
                x2  = now;
                OSC = this.receive;
                if ~isempty(OSC)
                    if this.verbose
                        disp(['response time: ' num2str((x2-x1)*24*3600*1000) ' ms'])
                    end
                    break
                end
            end
            
            
        end
        
    end
    
    %% ********************************************************************
    methods(Hidden = true, Static = true)
        function tutorial
            % Example / Tutorial
            a = itaOSC('localhost',9000,9000);
            a.init
            a.send('/acc','iii',1,2,3)
            pause(0.01)
            OSC = a.receive
            
            
            a.callback = 'disp';
            a.send('/i3DPIEM/TOSC/mainFader','ifsisf', 80, 2, 'ls ks lsk' , 10, 'hallo ich', 0.4);
            pause(0.2)
            
            %             a.callback = @itaOSC.callbackReceiveTOC;
            a.udp_handle.BytesAvailableFcn = @itaOSC.callbackReceiveTOC;
            
            tic
            a.send('/acc','iii',1,2,3)
            
            pause(1)
            
            
            a.reset
            delete(a)
        end
        
        %Conversion from double to float
        function float = oscfloat(float)
            float = typecast(swapbytes(single(float)),'uint8');
        end
        
        %Conversion to int
        function int = oscint(int)
            int = typecast(swapbytes(int32(int)),'uint8');
        end
        
        %Conversion to string (null-terminated, in multiples of 4 bytes)
        function string = oscstr(string)
            
            string = [string zeros(1,4 - mod(length(string),4))];
            %             string = string(1:end-mod(length(string),4));
        end
        
        function OSC = decode(udpMessage_raw)
            % decode an UDP message to OSC content
            
            %% OSC data receive struct
            OSC.address = '';
            OSC.data    = {};
            OSC.type    = {};
            
            udpMessage_raw_backup = udpMessage_raw;
            
            %% udpMessage_raw = udpMessage_raw_backup
            
            %% check length of packet
            if isempty(udpMessage_raw)
                disp('itaOSC: packet is empty')
                return;
            elseif ~isnatural(length(udpMessage_raw)/4)
                disp(['itaOSC: packet length is ' num2str(length(udpMessage_raw)) ' and not a multiple of 4 bytes:'])
                disp(udpMessage_raw)
                return;
            end
            
            %% Get rid off old message parts before OSC address
            if udpMessage_raw(1) ~= '/'
                ita_disp
                disp(char(udpMessage_raw)')
                udpMessage_raw = udpMessage_raw(find(udpMessage_raw=='/',1,'first'):end);
            end
            
            % Convert to string
            udpMessage_Str = char(udpMessage_raw)';
            
            % % show the message !!!
            % aux = num2str(udpMessage_raw);
            % aux = [aux repmat(' ',size(aux)) udpMessage_Str'  ];
            % aux(1:4:size(aux,1),5) =  '*'
            
            %% find the address, types and data
            idxxMessage_type    = min(findstr(udpMessage_Str(:).', ','));
            
            OSC.address         = strtrim(udpMessage_Str(1:(idxxMessage_type-1)));
            OSC.address         = strtrim(OSC.address(OSC.address ~= 0 ));
            
            % find the end of the type list
            type_list_length    = ceil( (find( udpMessage_raw(idxxMessage_type:end) == 0,1,'first' ) ) / 4)*4;
            
            osc_types           = udpMessage_Str( idxxMessage_type+(1:(type_list_length-1)) ) ;
            osc_types           = osc_types(osc_types ~= 0);
            
            udpMessage_raw      = udpMessage_raw((idxxMessage_type+ type_list_length):end);
            
            for idx = 1:length(osc_types) % go thru all types of data
                OSC.type{idx}   = osc_types(idx);
                res             = [];
                switch(osc_types(idx))
                    case ('i') % integer
                        res = double(swapbytes(typecast(uint8(udpMessage_raw(1:4)),'int32')));
                        udpMessage_raw(1:4) = []; % delete parse data
                        
                    case ('f') % float
                        res = double(swapbytes(typecast(uint8(udpMessage_raw(1:4)),'single')));
                        udpMessage_raw(1:4) = []; % delete parse data
                        
                    case ('s') % string
                        end_idx = min(findstr(char([0]),char(udpMessage_raw(:)')));
                        if isempty(end_idx)
                            end_idx = numel(udpMessage_raw);
                        end
                        res     = char(udpMessage_raw(1:(end_idx-1)))';
                        udpMessage_raw(1:(4* ceil(end_idx/4))) = []; % delete parse data
                    case {'T'} % TRUE
                        res = true;
                    case {'F'} % FALSE
                        res = false;
                    case {'N'} % NIL
                        
                        
                    case {'b'} % blob
                        nBytes = double(swapbytes(typecast(uint8(udpMessage_raw(1:4)),'int32'))); % number of data bytes followed
                        res = udpMessage_raw((1:nBytes) + 4);
                        %                         for byteCount = 1:nBytes
                        %
                        %                             res = [res dec2bin(typecast(uint8(udpMessage_raw(byteCount + 4)),'uint8') ,8)]; %PDI: not testet yet
                        %                         end
                        end_idx = 4 + nBytes;
                        udpMessage_raw(1:(4* ceil(end_idx/4))) = []; % delete parse data
                        
                        
                    otherwise
                        disp('error')
                end
                
                OSC.data{idx} = res;
            end
            
            %% if still not empty, recursion
            if ~isempty(udpMessage_raw)
                disp('recursion')
                OSC = [OSC itaOSC.decode(udpMessage_raw)];
            end
        end
        
        
    end
    
    %% ********************************************************************
    
    
    methods(Hidden = true)
        function delete(this)
            % delete the object
            try
                this.reset
            end
            try
                delete(this.udp_handle)
            end
            
        end
    end
    
end

