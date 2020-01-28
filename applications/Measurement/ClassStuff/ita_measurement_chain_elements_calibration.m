function varargout = ita_measurement_chain_elements_calibration(MC,element_idx,oldSens,oldReference)
%ITA_MEASUREMENT_CHAIN_ELEMENTS_CALIBRATION - Calibration of Multiface, Robo, Octamic

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Reference
MCE = MC(1).elements(element_idx);
if ~exist('oldSens','var')
    old_sens_str = '';
else
    if ~isnan(double(oldSens)) && isfinite(double(oldSens))
        old_sens_str = [' {old: ' num2str(oldSens) '; change: ' num2str(round(20.*log10(double(MCE.sensitivity)/double(oldSens)),3)) 'dB}'];
    else
        old_sens_str = [' {old: ' num2str(oldSens) '; change: N/A}'];
    end
end

hw_ch = MC(1).hardware_channel;
preamp_var = false;
switch(lower(MCE.type))
    case {'sensor'}
        tmp = itaValue(1,'V')/MCE.sensitivity;
        switch tmp.unit
            case 'Pa'
                sInit.Reference = '94';
                sInit.Unit = 'dB re Pa';
            case 'm/s'
                sInit.Reference = '1';
                sInit.Unit = 'm/s';
            case 'm/s^2'
                sInit.Reference = '9.8';
                sInit.Unit = 'm/s^2';
            case 'N'
                sInit.Reference = '1';
                sInit.Unit = 'N';
            otherwise
                sInit.Reference = '1';
                sInit.Unit = '1';
        end
    case {'preamp','ad','preamp_robo_fix','preamp_modulita_fix','preamp_aurelio_fix'}
        sInit.Reference = '1';
        sInit.Unit = 'V';
    case ('preamp_var')
        preamp_var = true;
    case ('none')
        varargout(1) = {1};
        return
    otherwise
        error([thisFuncStr 'which element type is this - ' lower(MCE.type)]);
end

if exist('oldReference','var')
    sInit.Reference = oldReference;
end

%% GUI
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

if preamp_var
    ele = numel(pList)+1;
    pList{ele}.description = 'Ext. Preamp Gain [dB]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'External gain of preamp, e.g. BK Type 2610'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 20*log10(double(MCE.sensitivity_silent)); %default value, could also be empty, otherwise it has to be of the datatype specified above
else
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Current Sensitivity: ' num2str(MCE.sensitivity) ' ' calibrated_str  old_sens_str];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.description = ['Reference [' num2str(sInit.Unit) ']']; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Reference voltage or sound pressure level'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = sInit.Reference; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Sampling Rate [Hz]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Sampling Rate'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ita_preferences('samplingRate'); %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Length [s]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Time to wait for the calibration to be finished'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 2; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
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
    pList{ele}.description  = 'Aurelio';
    pList{ele}.helptext     = 'Call ita_aurelio_control() GUI';
    pList{ele}.datatype     = 'simple_button';
    pList{ele}.default      = '';
    pList{ele}.callback     = 'ita_aurelio_control();';
end

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

%call GUI
if preamp_var
    pList = ita_parametric_GUI(pList,['Ext. Preamp Gain: ' MCE.type '::' MCE.name ' - hwch: ' ...
        num2str(hw_ch)]);
    if isempty(pList)
        varargout{1} = MCE.sensitivity;
    else
        varargout{1} = 10^(pList{1}/20);
    end
    return;
else
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Settings for Calibration Device';
    
    pList = ita_parametric_GUI(pList,['Calibration: ' MCE.type '::' MCE.name ' - hwch: ' num2str(hw_ch)],'buttonnames',{'Accept','Calibrate'});
end

if isempty(pList)
    ita_verbose_info([thisFuncStr 'Accepting sensitivity for ' MCE.type ' - ' MCE.name ' - hwch: ' num2str(hw_ch)],1)
    varargout{1} = MCE.sensitivity;
    return;
end

%% Initialization
%default init struct
oldSens = MCE.sensitivity;
sInit.Channel       = hw_ch;
if strcmpi(sInit.Unit,'V')
    sInit.Reference = itaValue(pList{1},'V');
elseif strcmpi(sInit.Unit,'dB re Pa')
    sInit.Reference = itaValue(10^(pList{1}/20)*2e-5,'Pa');
else
    sInit.Reference = itaValue(pList{1},sInit.Unit);
end
sInit.samplingRate = pList{2};
sInit.length = pList{3}*sInit.samplingRate;

%% Aurelio stuff
usingAurelio = false;
for iElem = 1:numel(MC.elements)
    if any(strfind(MC.elements(iElem).name,'aurelio'))
        usingAurelio = true;
        break;
    end
end

if usingAurelio
    ita_aurelio_control('samplingRate',sInit.samplingRate);
    if sInit.samplingRate > 96000
        changedSamplingRate = true;
        sInit.samplingRate = sInit.samplingRate/2;
        sInit.Channel = [sInit.Channel 4+sInit.Channel];
    else
        changedSamplingRate = false;
    end
end

%% Measurement
signalRecord = ita_portaudio(sInit.length,'inputchannels', sInit.Channel,'samplingRate',sInit.samplingRate);
signalRecord = signalRecord / MC(1).sensitivity(MCE.type); % compensation of rest

%% Postprocess
if usingAurelio && changedSamplingRate
    sInit.samplingRate = sInit.samplingRate*2;
    tmp = signalRecord.time.';
    signalRecord.time = tmp(:);
    signalRecord.samplingRate = sInit.samplingRate;
    ita_aurelio_control('samplingRate',ita_preferences('samplingRate'));
end

%% Evaluate
calibrationDomain = ita_preferences('calibrationDomain');
if ~(strcmpi(calibrationDomain,'time') || strcmpi(calibrationDomain,'frequency'))
    error('ita_measurement_chain_elements_calibration: Unknown calibration mode. Please set calibration mode in ita_preferences->ExpertSettings to either ''Time'' or ''Frequency''!');
end

validCalibFreqs = ita_preferences('calibrationFrequencies');
if numel(validCalibFreqs)==0 || any(validCalibFreqs<0)
    error('ita_measurement_chain_elements_calibration: No valid calibration Frequency defined. Please set list of valid calibration frequencies in ita_preferences->ExpertSettings!');
end

calibFreqTolerance = ita_preferences('calibrationFrequencyTolerance');
if ~isnumeric(calibFreqTolerance) || ~isfinite(calibFreqTolerance) || calibFreqTolerance<0
    error('ita_measurement_chain_elements_calibration: Invalid calibration frequency tolerance. Please set calibration frequency tolerance  in Cent (Default 100) in ita_preferences->ExpertSettings!');
end

if strcmpi(calibrationDomain,'time')
    nBlocks = 5;
    % Signal Segmentation
    for idxBlock = 1:nBlocks
        signalSegment(idxBlock) = ita_time_crop(signalRecord,[((idxBlock-1)*signalRecord.nSamples/nBlocks+1),(idxBlock*signalRecord.nSamples/nBlocks)],'samples'); %#ok<AGROW>
        signalSegment(idxBlock).comment = ['Block number ' num2str(idxBlock)]; %#ok<AGROW>
    end
    signalSegment = signalSegment.merge;
    
    % Test single blocks for correct frequency
    % in case of low battery or bad signal, the frequency will change
    signalTimeWindow = ita_time_window(signalSegment, ...
        [round(0.5*signalSegment.nSamples), 1, ...
        round(0.5*signalSegment.nSamples)+1, signalSegment.nSamples], ...
        'samples',@hann); % multiply with window before FFT
    freq_vec = signalTimeWindow.freqVector;
    rmsVals  = signalSegment.rms;
    % look for maxMagnitude and its frequency -> should be somewhere near
    % calibration frequency; if not, don't consider block for sensitivity calculation
    [dummy,maxFrequencyIdx] = max(abs(signalTimeWindow.freq),[],1); %#ok<ASGLU>
    maxFrequency = freq_vec(maxFrequencyIdx);
    idxRMSValid = 0;
    validBlock = zeros(nBlocks,1);
    for idxBlock = 1:nBlocks
        ita_verbose_info([thisFuncStr 'maxFrequency of block number :' num2str(idxBlock) ': ' num2str(maxFrequency(idxBlock)) 'Hz'],1)
        validBlock(idxBlock) = any((maxFrequency(idxBlock) > (validCalibFreqs*2.^(-calibFreqTolerance/1200))) & (maxFrequency(idxBlock) < (validCalibFreqs*2.^(calibFreqTolerance/1200))));
        if validBlock(idxBlock)==0
            ita_verbose_info([thisFuncStr 'Invalid frequency detected'],0);
        else % Calculate rms value for each valid block
            idxRMSValid = idxRMSValid+1;
            rmsValid(idxRMSValid) = rmsVals(idxBlock); %#ok<AGROW>
        end
    end
    ita_verbose_info([thisFuncStr 'Number of valid blocks: ' num2str(idxRMSValid)],2)
    
    % Take Median as most representative value
    % check first if enough blocks have been verified as valid
    if idxRMSValid == 0
        signalRecord.channelNames{1} = 'CALIBRATION FAILED::INPUT SIGNAL LOOKS LIKE THIS!';
        ita_plot_time(signalRecord);
        ita_verbose_info([thisFuncStr 'Signal does not have any of the allowed calibration frequencies.'],0);
        SensValid = MCE.sensitivity;
    elseif idxRMSValid <= round(nBlocks/2)
        ita_verbose_info([thisFuncStr 'Measurement might not be accurate. Bad signal.'],1);
        SensValid = itaValue(median(rmsValid),signalRecord.channelUnits{1})/sInit.Reference;
    else
        SensValid = itaValue(median(rmsValid),signalRecord.channelUnits{1})/sInit.Reference;
    end
    
elseif strcmpi(calibrationDomain,'frequency')
    str = num2cell(validCalibFreqs);
    ok = 0;
    while ~ok
        [selection,ok] = listdlg('PromptString','Select a calibration frequency:',...
            'SelectionMode','single',...
            'ListString',str);
        if ok
            freqStart = validCalibFreqs(selection)*2^(-calibFreqTolerance/1200);
            freqStop  = validCalibFreqs(selection)*2^(+calibFreqTolerance/1200);
            
            % look for maxMagnitude and its frequency -> should be somewhere near
            % the chosen calibration frequency; if not, give out warning
            freq_vec = signalRecord.freqVector;
            [dummy,maxIdx] = max(abs(signalRecord.freqData),[],1); %#ok<ASGLU>
            maxFrequency = freq_vec(maxIdx);
            ita_verbose_info([thisFuncStr 'Frequency with highest Amplitude in recorded signal :' num2str(maxFrequency) 'Hz'],1)
            if (maxFrequency < freqStart) || (maxFrequency > freqStop)
                ita_verbose_info([thisFuncStr 'Oh dear, the signal at you''re calibration frequency is not the strongest component in your signal. I hope you know what you''re doing!'],0);
                ita_plot_freq(signalRecord)
            end
            
            % Calculate RMS at calibration frequency and consider leakage
            calibValues = signalRecord.freq2value(freqStart,freqStop).'; % make row vector
            calibRMS = sqrt(calibValues * calibValues');
            SensValid = itaValue(calibRMS,signalRecord.channelUnits{1})/sInit.Reference;
        else
            disp('ita_measurement_chain_elements_calibration: Please choose a calibration frequency!');
        end
    end
end

MC(1).elements(element_idx).sensitivity = SensValid;
SensValid = ita_measurement_chain_elements_calibration(MC,element_idx,oldSens,pList{1});

varargout(1) = {SensValid};
end