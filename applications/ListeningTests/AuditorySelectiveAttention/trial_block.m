function result = trial_block(mainPath, h, method, iBlock, trials, proband)
% TRIAL_BLOCK performs a block of the experiment as specified by the
% trials parameter and returns the result.

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


result = cell(size(trials, 1), 16);

anzDurchlaufe=0;

for iTrials=1:size(trials,1)
    
    %Umbenennung der Variablen mit anschaulicheren Namen
    cue = trials{iTrials,1};
    notcue = trials{iTrials,2};
    congruence = trials{iTrials,3};
    play_cue = trials{iTrials,4}; % eigentlich ehemals left
    play_notcue = trials{iTrials,5}; % eigentlich ehemals right
    key_correct = trials{iTrials,6};
    key_wrong = trials{iTrials,7};
    CSI = trials{iTrials,8};
    RCI = trials{iTrials,9};
    
    anzDurchlaufe=anzDurchlaufe+1;
    
    set(h.textfeld,'Visible','off')
    visualCue = imread(sprintf('%s\\VisualCues\\VisualCue_%s.png',mainPath, cue));
    image( visualCue);
    axis off
    
    
    CSI_start = now*24*60*60;
    if h.trackerOn
        
        s = ITAPolhemus('getsensorstate', h.trackerHut);
        clear h.P;
        h.P(1:3) = s.pos;
        h.P(4:6) = s.orient*180/pi;
        h.ErrorArea = [h.P-h.ErrorLimit; h.P+h.ErrorLimit];
        
        t = timer('TimerFcn',@checkTracker, 'Period', h.trackerFreq, 'ExecutionMode', 'fixedRate', 'BusyMode' ,'queue');
        set(t, 'userdata', struct('errorLimit',h.ErrorArea, 'moved', false, 'type', h.trackerHut, 'trackerData', []))
        start(t)
    end
    
    if h.HP_On
        %Hp on head
        % load the combination of wav-files and the played direction during the CSI, this *should* be enough time
        
        %TODO
        hp_audio_cue = wavread(strcat(mainPath,'\sounds_nonindividuell\', play_cue, '_', cue,'.wav'));
        hp_audio_notcue = wavread(strcat(mainPath,'\sounds_nonindividuell\', play_notcue, '_', notcue,'.wav'));
        
        diff = size(hp_audio_cue,1) - size(hp_audio_notcue,1);
        %audio = horzcat(vertcat(hp_audio_cue, zeros(-diff,2)), ...
        %vertcat(hp_audio_notcue, zeros(diff,2)));
        
        audio = vertcat(hp_audio_cue, zeros(-diff,2))+ vertcat(hp_audio_notcue, zeros(diff,2));
        
        %Verwandelt vektor in ita_audio
        audio_ita = itaAudio(audio, 44100, 'time');
        CSI_left = str2num(CSI) - (now*24*60*60 - CSI_start);
        if CSI_left < 0
            disp(['FATAL: negative CSI left: ',num2str(CSI_left),'s.']);
        else
            %disp(['CSI left: ',num2str(CSI_left),'s.']);
            pause(CSI_left);
        end
        
        %   present stimulus
        %hier auf die Soundkarte zugreifen
        out = [1 2];
        
    else
        %LS is playing
        % load the wav-files during the CSI, this *should* be enough time
        
        audio_cue = wavread(strcat(mainPath,'\sounds_loudspeaker\', play_cue,'.wav'));
        audio_notcue = wavread(strcat(mainPath, '\sounds_loudspeaker\', play_notcue,'.wav'));
        
        diff = size(audio_cue,1) - size(audio_notcue,1);
        audio = horzcat(vertcat(audio_cue, zeros(-diff,1)), ...
            vertcat(audio_notcue, zeros(diff,1)));
        
        %Verwandelt vektor in ita_audio
        audio_ita = itaAudio(audio, 44100, 'time');
        CSI_left = str2num(CSI) - (now*24*60*60 - CSI_start);
        if CSI_left < 0
            disp(['FATAL: negative CSI left: ',num2str(CSI_left),'s.']);
        else
            %disp(['CSI left: ',num2str(CSI_left),'s.']);
            pause(CSI_left);
        end
        
        % present stimulus
        %hier auf die Soundkarte zugreifen
        directions = {'F', 'FR', 'R', 'BR', 'B', 'BL', 'L', 'FL'};
        %directionChannels = {20, 23, 2, 5, 8, 11, 14, 17}; mit Digiface
        directionChannels = {'11' '12' '13' '14' '15' '16' '17' '18'}; %mit Multiface
        %directionChannels = {'1' '2' '3' '4' '5' '6' '7' '8'};
        idx_cue = strcmp(directions, cue);
        cueChannel = str2num(directionChannels{find(idx_cue)});
        idx_notcue = strcmp(directions, notcue);
        notcueChannel = str2num(directionChannels{find(idx_notcue)});
        
        out = [cueChannel, notcueChannel];
    end
    
    if h.trackerOn
        stop(t)
        tempCSI = get(t, 'userdata');
    end
    
    if h.trackerOn
        s = ITAPolhemus('getsensorstate', h.trackerHut);
        clear h.P;
        h.P(1:3) = s.pos;
        h.P(4:6) = s.orient*180/pi;
        h.ErrorArea = [h.P-h.ErrorLimit; h.P+h.ErrorLimit];
        
        hPlayRec = ita_playrec;
        
        if ~hPlayRec('isInitialised')
            samplingRate = ita_preferences('samplingRate');
            hPlayRec('init', samplingRate, ita_preferences('playDeviceID'), -1);
            ita_verbose_info('ita_portaudio:initializing... waiting 1 second...',1);
            pause(1); %pdi: was 1 before
        end
        
        % Setzten und Starten der Timer-Funktion
        t = timer('TimerFcn',@checkTracker, 'Period', h.trackerFreq, 'ExecutionMode', 'fixedRate', 'BusyMode' ,'queue');
        set(t, 'userdata', struct('errorLimit',h.ErrorArea, 'moved', false, 'type', h.trackerHut, 'trackerData', []))
        start(t)
        
        % Reaktionszeitmessung starten
        start_time = tic();
        
        % Abspielen der Stimuli
        pageno = hPlayRec('play', audio_ita.timeData./10, out);
        
        %Warten auf Knopfdruck und speichern der Reaktionszeit
        [xTrash, yTrash, PressButton]=ginput_job(h.f);
        time = round(1000*toc(start_time));
        RCI_start = now*24*60*60;
        
        
        %Stoppen der Timerfunktion und Überprüfung ob der Kopf bewegt wurde
        stop(t)
        temp = get(t, 'userdata');
        h.bewegt = temp.moved;
        temp.moved = false;
        
        trackerData2save = struct('CSI_trackerData', tempCSI.trackerData, 'RT_trackerData', temp.trackerData, 'iBlock', iBlock, 'iTrials', iTrials, 'proband', str2num(proband));
        save(fullfile(h.trackerPath, sprintf('VP%02i_block%i_trial%i.mat',str2num(proband), iBlock, iTrials )), 'trackerData2save')
        
    else
        hPlayRec = ita_playrec;
        
        if ~hPlayRec('isInitialised')
            samplingRate = ita_preferences('samplingRate');
            hPlayRec('init', samplingRate, ita_preferences('playDeviceID'), -1);
            ita_verbose_info('ita_portaudio:initializing... waiting 1 second...',1);
            pause(1); %pdi: was 1 before
        end
        
        % Reaktionszeitmessung starten
        start_time = tic();
        
        % Abspielen der Stimuli
        pageno = hPlayRec('play', audio_ita.timeData./10, out);
        
        %Warten auf Knopfdruck und speichern der Reaktionszeit
        [xTrash, yTrash, PressButton]=ginput_job(h.f);
        time = round(1000*toc(start_time));
        
        h.bewegt = 'Not measured';
        
        RCI_start = now*24*60*60;
    end
    
    
    
    %Welche Taste wurde gedrückt?!
    if PressButton==1
        PressedKey = 'left_control';
    elseif PressButton==3
        PressedKey = 'right_control';
    elseif PressButton==2
        fprintf('Die mittlere Taste wurde betätigt!');
        PressedKey = '';
        fprintf('Wir befinden uns im %i ten Block im %i ten Durchlauf\n', iBlock, anzDurchlaufe);
    else
        fprintf('Fehler! Es wurde eine unbekannte Tase gedrückt');
        PressedKey = '';
    end
    
    %Correct or incorrect answer
    success = -1;
    if sum(strcmp(PressedKey,key_correct))~=0
        success = 1; % correct answer
        set(h.bild, 'Visible', 'off')
        set(h.textfeld,'string','','Fontsize', 0.1, 'Visible', 'on')
        drawnow;
    elseif sum(strcmp(PressedKey,key_wrong))~=0
        success = 0; % wrong answer
        set(h.bild, 'Visible', 'off')
        set(h.textfeld,'string','FALSCH!','Fontsize', 0.1, 'Visible', 'on')
        drawnow;
    end
    
    
    if iBlock==1
        iZeile=iTrials+1;
    else
        iZeile=iTrials;
    end
    % write to result array
    result(iZeile,1:9) = {proband, 'LS', iBlock, iTrials, cue, notcue, congruence, play_cue, play_notcue};
    %Probandennummer, Lautsprecher, Blocknummer, Trialnummer innerhalb
    %eines Blocks, Cue-Richtung, andere Richtung, Kongruenz, abgespielter
    %Stimulus aus Cue-Richtung, abgespielter
    %Stimulus aus anderer Richtung
    
    if strcmp(key_correct,'left_control')
        result{iZeile,10} = 1; % correct key
        if success == 1,
            result{iZeile,11} = 1; % pressed key
        else
            result{iZeile,11} = 2; % pressed key
        end
    else
        result{iZeile,10} = 2; % correct key
        if success == 1,
            result{iZeile,11} = 2; % pressed key
        else
            result{iZeile,11} = 1; % pressed key
        end
    end
    result(iZeile,12:16) = {time, str2num(CSI) * 1000, str2num(RCI) * 1000, success, h.bewegt};
    % Reaktionszeit, CSI, RCI, success 1=yes, 0=no
    
    RCI_left = str2num(RCI) - (now*24*60*60 - RCI_start);
    if RCI_left < 0
        disp(['FATAL: negative CSI left: ',num2str(RCI_left),'s.']);
    else
        %disp(['CSI left: ',num2str(CSI_left),'s.']);
        pause(RCI_left);
    end
    set(h.textfeld,'Visible', 'off', 'Fontsize', 0.05)
end
end

