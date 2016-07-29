classdef itaMeasuringStation

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % Standard settings of measurement stations at ITA.
    %
    % See also: itaMeasurementSetupSuper, itaMeasurementChainElements,
    %            ita_measurement
    
    properties
        name                    = ''; %name of the station
        description             = ''; %description of the equipment at this station in the lab
        inputMeasurementChain   = itaMeasurementChain; %standard input measurement chain
        outputMeasurementChain  = itaMeasurementChain; %standard output measurement chain
    end
    methods
        %% constructor
        function this = itaMeasuringStation(varargin)
            % constructor
            if nargin == 1 && varargin{1} == 0
                %return empty chain
            else
                playDeviceID = ita_preferences('playDeviceID');
                recDeviceID  = ita_preferences('recDeviceID');
                if playDeviceID == -1 || recDeviceID == -1
                    disp('no device found')
                    return;
                end
                [playDeviceName playDeviceInfo] = ita_portaudio_deviceID2string(playDeviceID);
                [recDeviceName recDeviceInfo]   = ita_portaudio_deviceID2string(recDeviceID);
                
                if nargin >= 1 && ~isempty(varargin{1}) && ischar(varargin{1})
                    this.name = varargin{1};
                else
                    this.name = ['play: ' playDeviceName ' - rec: ' recDeviceName];
                end
                this.name = ita_guisupport_removewhitespaces(this.name);
                
                out = 1:playDeviceInfo.outputChans;
                outputChannels = max(out,1); %Filter '-1' in case that no device is selected
                in  = 1:recDeviceInfo.inputChans;
                inputChannels  = max(in,1); %Filter '-1' in case that no device is selected
                
                %% GUI
                pList = {};
                ele = numel(pList)+1;
                pList{ele}.description = 'Input Channels';
                pList{ele}.helptext    = 'Vector with the input channel numbers. The order specified here is respected!';
                pList{ele}.datatype    = 'int_result_button';
                pList{ele}.default     = inputChannels;
                pList{ele}.callback    = 'ita_channelselect_gui([$$],[],''onlyinput'')';
                
                ele = numel(pList)+1;
                pList{ele}.description = 'Output Channels';
                pList{ele}.helptext    = 'Vector with the output channel numbers. The order specified here is respected!';
                pList{ele}.datatype    = 'int_result_button';
                pList{ele}.default     = outputChannels;
                pList{ele}.callback    = 'ita_channelselect_gui([],[$$],''onlyoutput'')';
                
                ele = numel(pList)+1;
                pList{ele}.datatype    = 'line';
                
                ele = numel(pList)+1;
                pList{ele}.description = 'Name';
                pList{ele}.helptext    = 'Name of your Measuring Station';
                pList{ele}.datatype    = 'char';
                pList{ele}.default     = 'pc_ID';
                
                ele = numel(pList)+1;
                pList{ele}.description = 'Description';
                pList{ele}.helptext    = 'Say something about your measurement hardware';
                pList{ele}.datatype    = 'char';
                pList{ele}.default     = 'what are you using here?';

                
                pList = ita_parametric_GUI(pList,[mfilename ' - Generate a Measurement Setup']);
                pause(0.02); %wait for GUI to close first
    
                inputChannels    = pList{1};
                outputChannels   = pList{2};
                this.name        = pList{3};
                this.description = pList{4};
                
                this.inputMeasurementChain  = ita_measurement_chain(inputChannels);
                this.outputMeasurementChain = ita_measurement_chain_output(outputChannels);

                %% get Measurement Setup
                this = calibrate(this);
            end
        end
        
        
        function write2disk(iMS)
            % write measuring station data to harddrive
            folder = fileparts(which(mfilename));
            save([folder filesep 'itaMeasuringStation_' iMS.name '.iMS'],'iMS','-mat');
        end
        
        function this = calibrate(this)
            inputChannels  = this.inputMeasurementChain.hw_ch;
            outputChannels = this.outputMeasurementChain.hw_ch;
            sr = ita_preferences('samplingRate');
            MS = ita_measurement_setup_transferfunction(inputChannels, outputChannels, sr, 16, [5 sr/2], 'excitation', 'exp', 'stopmargin', 0.1, 'outputamplification', '-10dB', 'comment', 'ita measuring station', 'pause', 0, 'averages', 1,'measurementChain',false);
            MS.inputMeasurementChain  = this.inputMeasurementChain;
            MS.outputMeasurementChain = this.outputMeasurementChain;
            MS.calibrate;
            this.inputMeasurementChain  = MS.inputMeasurementChain;
            this.outputMeasurementChain = MS.outputMeasurementChain;
        end
        
    end
    %% Static methods
    methods(Static, Hidden = false)
        function preferences()
            % GUI to choose the measuring station
            pList{1}.description = 'Measuring Station Standard'; %this text will be shown in the GUI
            pList{1}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
            pList{1}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
            pList{1}.list        = itaMeasuringStation.getString;
            defaultstr = ita_preferences('MeasuringStation');
            if isempty(defaultstr)
                defaultstr = 'none';
            end
            pList{1}.default     = defaultstr; %default value, could also be empty, otherwise it has to be of the datatype specified above
            
            
            pList{2}.datatype = 'line';
            
            pOutList = ita_parametric_GUI(pList,'Measuring Station','wait','on');
            
            if ~isempty(pOutList)
                
                ita_preferences('MeasuringStation',pOutList{1});
            end
            
        end
        function str = getString() 
            %get String for GUI
            x = dir([fileparts(which('itaMeasuringStation.m')) filesep 'itaMeasuringStation_*.iMS']);
            str = 'none';
            for idx = 1:numel(x)
                str = [str '|' x(idx).name(21:end-4)]; %#ok<AGROW>
            end
        end
        
        function iMS = loadSettings(str) 
            %load input/output Measurement Chain according to prefered
            %measuring station
            if exist('str','var')
                if strcmpi(str,'none')
                    iMS = itaMeasuringStation(0);
                    return;
                end
                folder = fileparts(which(mfilename));
                try
                    iMS = load([folder filesep 'itaMeasuringStation_' str '.iMS'] , '-mat');
                    iMS = iMS.iMS;
                catch theException
                    ita_verbose_info([upper(mfilename) ':MeasuringStation cannot be loaded because ' theException.message],0);
                    iMS = itaMeasuringStation(0);
                end
            else
                try
                    iMS = itaMeasuringStation.loadSettings(ita_preferences('MeasuringStation'));
                catch theException
                    ita_verbose_info([upper(mfilename) ':MeasuringStation cannot be loaded because ' theException.message],0);
                    iMS = itaMeasuringStation(0);
                end
            end
        end
        function MC = loadCurrentInputMC()
            % load the choosen input MC
            this = itaMeasuringStation.loadSettings(ita_preferences('MeasuringStation'));
            MC   = this.inputMeasurementChain;
        end
        function MC = loadCurrentOutputMC()
            % load the choosen output MC
            this = itaMeasuringStation.loadSettings(ita_preferences('MeasuringStation'));
            MC   = this.outputMeasurementChain;
        end
    end
    
        

    
end
