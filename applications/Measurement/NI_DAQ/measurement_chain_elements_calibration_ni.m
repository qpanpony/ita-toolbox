function varargout = measurement_chain_elements_calibration_ni(niSession,MC,element_idx,oldSens,oldReference)
% calibration routine for input elements using the NI hardware (ita_NI_daq_run)
% otherwise identical to ita_measurement_chain_elements_calibration (except ModulITA, Aurelio etc.)

% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Created:  10-May-2017

MCE = MC(1).elements(element_idx);
if ~exist('oldSens','var')
    oldSens = MCE.sensitivity_silent;
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
    case {'preamp','ad','preamp_robo_fix'}
        sInit.Reference = '1';
        sInit.Unit = 'V';
    case ('preamp_var')
        preamp_var = true;
    case ('none')
        varargout(1) = {1};
        return
    otherwise
        error(['which element type is this - ' lower(MCE.type)]);
end

if exist('oldReference','var')
    sInit.Reference = oldReference;
end

old_sens_str = [' {old: ' num2str(oldSens) '}'];

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
    ita_verbose_info(['Accepting sensitivity for ' MCE.type ' - ' MCE.name ' - hwch: ' num2str(hw_ch)],1)
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

%% Measurement
% record data
signalRecord = ita_NI_daq_run(sInit.length,niSession,'inputchannels',sInit.Channel,'samplingRate',sInit.samplingRate);
signalRecord = ita_filter_bandpass(signalRecord,'lower',20,'zerophase',false);
signalRecord = signalRecord / MC(1).sensitivity(MCE.type); % compensation of rest

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
        ita_verbose_info(['maxFrequency of block number :' num2str(idxBlock) ': ' num2str(maxFrequency(idxBlock)) 'Hz'],1)
        validBlock(idxBlock) = any((maxFrequency(idxBlock) > (validCalibFreqs*2.^(-calibFreqTolerance/1200))) & (maxFrequency(idxBlock) < (validCalibFreqs*2.^(calibFreqTolerance/1200))));
        if validBlock(idxBlock)==0
            ita_verbose_info('Invalid frequency detected',0);
        else % Calculate rms value for each valid block
            idxRMSValid = idxRMSValid+1;
            rmsValid(idxRMSValid) = rmsVals(idxBlock); %#ok<AGROW>
        end
    end
    ita_verbose_info(['Number of valid blocks: ' num2str(idxRMSValid)],2)
    
    % Take Median as most representative value
    % check first if enough blocks have been verified as valid
    if idxRMSValid == 0
        signalRecord.channelNames{1} = 'CALIBRATION FAILED::INPUT SIGNAL LOOKS LIKE THIS!';
        ita_plot_time(signalRecord);
        ita_verbose_info('Signal does not have any of the allowed calibration frequencies.',0);
        SensValid = MCE.sensitivity;
    elseif idxRMSValid <= round(nBlocks/2)
        ita_verbose_info('Measurement might not be accurate. Bad signal.',1);
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
            ita_verbose_info(['Frequency with highest Amplitude in recorded signal :' num2str(maxFrequency) 'Hz'],1)
            if (maxFrequency < freqStart) || (maxFrequency > freqStop)
                ita_verbose_info('Oh dear, the signal at you''re calibration frequency is not the strongest component in your signal. I hope you know what you''re doing!',0);
                ita_plot_freq(signalRecord)
            end
            
            % Calculate RMS at calibration frequency and consider leakage
            calibValues = signalRecord.freq2value(freqStart,freqStop); % make row vector
            calibRMS = sqrt(calibValues' * calibValues);
            SensValid = itaValue(calibRMS,signalRecord.channelUnits{1})/sInit.Reference;
        else
            disp('ita_measurement_chain_elements_calibration: Please choose a calibration frequency!');
        end
    end
end

MC(1).elements(element_idx).sensitivity = SensValid;
SensValid = measurement_chain_elements_calibration_ni(niSession,MC,element_idx,oldSens,pList{1});

varargout(1) = {SensValid};
end % function