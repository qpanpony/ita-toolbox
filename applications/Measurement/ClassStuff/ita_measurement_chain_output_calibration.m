function MS = ita_measurement_chain_output_calibration(MS,input_chain_number,ele_idx,old_sens)
% ITA_MEASUREMENT_CHAIN_OUTPUT_CALIBRATION - calibrate output
% measurementchain for all channels

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

sensFactor = 1;
thisFuncStr = [upper(mfilename) '::'];
% for ele_idx = 1:length(MS.outputMeasurementChain)
MC = MS.outputMeasurementChain(1); %always get the latest measurement chain to be on the save side

if MC.elements(ele_idx).calibrated ~= -1
    %% switch to reference?
    %% GUI
    pListExtra = {};
    
    MCE = MC.elements(ele_idx);
    
    if ~exist('old_sens','var')
        old_sens_str = '';
    else
        if ~isnan(double(old_sens)) && isfinite(double(old_sens))
            old_sens_str = [' {old: ' num2str(old_sens) '; change: ' num2str(round(20.*log10(double(MCE.sensitivity)/double(old_sens)),3)) 'dB}'];
        else
            old_sens_str = [' {old: ' num2str(old_sens) '; change: N/A}'];
        end
    end
    
     if any(strfind(lower(MCE.name),'robo')) || any(strfind(lower(MCE.type),'robo')) || ...
            any(strfind(lower(MCE.name),'modulita')) || any(strfind(lower(MCE.type),'modulita')) || ...
            any(strfind(lower(MCE.name),'aurelio')) || any(strfind(lower(MCE.type),'aurelio'))
        default_output2input = 'preamp';
    elseif ismember(MCE.type,{'actuator'})
        default_output2input = 'sensor';
    elseif ismember(MCE.type,{'loudspeaker'})
        default_output2input = 'sensor';
        
       
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Distance to Loudspeaker [m]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'distance in meters'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 1; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Microphone on the floor?'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'semi-anechoic chamber, microphone on the floor'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Window start time[s]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'starting time of symmetrical window function'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 0.05; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Window end time[s]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'end time of symmetrical window function'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 0.1; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.datatype    = 'line';
    else
        default_output2input = 'ad';
    end
    
    hw_ch = MC.hardware_channel;

    
    pList = [];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Calibrating: ' upper(MCE.type) '::' MCE.name '::'  'Hardware Channel: ' num2str(hw_ch) '...'];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    calibrated_str = '';
    if  MCE.calibrated == 0
        calibrated_str = '(UNCALIBRATED)';
    end
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Current Sensitivity: ' num2str(MCE.sensitivity) ' ' calibrated_str  old_sens_str];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'output2input'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Output is connected to this element'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.list        = 'ad|preamp|sensor';
    pList{ele}.default     = default_output2input; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'outputamplification'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'in dBFS'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = MS.outputamplification; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Robo'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Call ita_robocontrol GUI to set values'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'simple_button'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{ele}.callback    = 'ita_robocontrol';
    
    
    ele = numel(pList)+1;
    pList{ele}.description = 'ModulITA'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Call ita_robocontrol GUI to set values'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'simple_button'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{ele}.callback    = 'ita_modulita_control';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Aurelio';
    pList{ele}.helptext    = 'Call ita_aurelio_control() GUI';
    pList{ele}.datatype    = 'simple_button';
    pList{ele}.default     = '';
    pList{ele}.callback    = 'ita_aurelio_control();';
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    pList = [pList pListExtra];
    
    %call GUI
    pList = ita_parametric_GUI(pList,['Calibration: ' MCE.type '::' MCE.name ' - hwch: ' num2str(hw_ch)],'buttonnames',{'Accept','Calibrate'});
    
    if isempty(pList)
        ita_verbose_info([thisFuncStr 'Accepting sensitivity for ' MCE.type ' - ' MCE.name ' - hwch: ' num2str(hw_ch)],1)
        MC.elements(ele_idx).sensitivity = MCE.sensitivity; %set sensitivity
        MS.outputMeasurementChain = MC;
        return;
    else
        
        output2input = pList{1};
        MS.outputamplification = pList{2};
        
        %% measurement
        %try to get the sensitivity of the chain. modulita and robo could
        %be uninitialized
        old_sens = MCE.sensitivity;
        
        
        MS.inputChannels = MS.inputMeasurementChain(input_chain_number).hardware_channel;
        %TODO: Create latency vector
        if MS.latencysamples == 0
            MS.run_latency;
        end
        if ~strcmpi(output2input,'sensor')
            MS.run_autorange(0,pList{2});
        end
        
        if isa(MS,'itaMSTFaurelio') && MS.samplingRate > 96000
            changedSamplingRate = true;
            samplingRate = MS.samplingRate / 2;            
            inputChannels = [MS.inputChannels  4+MS.inputChannels];
            outputChannels = [MS.outputChannels  2+MS.outputChannels];
            
            final_excitation = MS.final_excitation;
            final_excitation.timeData = [final_excitation.timeData(1:2:end,:) final_excitation.timeData(2:2:end,:)];
            final_excitation.samplingRate = samplingRate;
            
            latencysamples = MS.latencysamples/2;
            if ~isnatural(latencysamples)
                ita_verbose_info('Warning, your latencysettings do not make sense, willl remeasure latency',0);
                MS.run_latency;
                latencysamples = MS.latencysamples/2;
            end
        else
            changedSamplingRate = false;
            inputChannels = MS.inputChannels;
            outputChannels = MS.outputChannels;
            samplingRate = MS.samplingRate;
            final_excitation = MS.final_excitation;
            latencysamples = MS.latencysamples;
        end
        
        a = ita_portaudio(final_excitation,'InputChannels',inputChannels, ...
            'OutputChannels', outputChannels,'latencysamples',latencysamples,'samplingRate',samplingRate);
        
        if changedSamplingRate
            tmp = (a.time.');
            a.time = tmp(:);
            a.samplingRate = MS.samplingRate;
        end
            
        a = a * MS.compensation / MS.outputamplification_lin;
        a.signalType = 'energy';
        
        if ~isempty(pListExtra)
            %% compensation of distance
            distance = itaValue(pList{3},'m');
            travel_time = distance / ita_constants('c');
            
            a = ita_time_shift(a,-double(travel_time),'time');
            a = a * distance;
            
            %% floor compensation
            if pList{4}
                a = ita_amplify(a,'-6dB');
            end
            
            %% time windowing
            a = ita_time_window(a,[pList{5} pList{6}],'time','symmetric');
            
        end
        
        %% get FRF up to this point
        frf_upto = MC.response(lower(MC.elements(ele_idx).type));
        if ~isempty(frf_upto)
            a = a*ita_invert_spk_regularization(frf_upto,[1 MS.samplingRate/2],'filter');
        end
        
        %% get sensitivity of element
        value = itaValue ( mean(abs(a.freq2value(950:1050))) , a.channelUnits{1});
        MC.elements(ele_idx).response = a / value;
        switch lower(output2input)
            case {'ad'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity('preamp') ...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
                
            case {'preamp'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity('sensor')...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
                
            case {'sensor'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity()...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
            otherwise
                error('element type unknown')
        end
        
        MC.elements(ele_idx).sensitivity = value;
        MS.outputMeasurementChain = MC;
        
    end
    
    MS = ita_measurement_chain_output_calibration(MS,input_chain_number,ele_idx,old_sens);
    
end
% end

end