function varargout = ita_HRTFarc_postprocessing(varargin)

%% parse arguments
sArgs         = struct('dataPath',[],'savePath',[],'saveName',[],'path_ref',...
    [],'ref_name',[],'tWin',[],'samples',[],'flute',[],'phiAdd',0,'eimar',true,'refIsCropped',0);
sArgs         = ita_parse_arguments(sArgs,varargin);

dataPath      = sArgs.dataPath;         % Pfad des Ordners mit den HRTF Rohdaten
path_ref      = sArgs.path_ref;     % Pfad der Referenzmessung linkes Mikro
savePath      = sArgs.savePath;         % Pfad angeben, falls gefensterte HRTF gespeichert werden soll
saveName      = sArgs.saveName;         % Dateiname (ohne .ita Endung)

if isempty(sArgs.samples),
    if numel(sArgs.tWin) ==1, t2 = sArgs.tWin(1);  t1 = t2/1.25;
    else  t1 = sArgs.tWin(1); t2 = sArgs.tWin(2); 
    end
else
    SR = 44100;
    if numel(sArgs.samples) ==1,   t2 = sArgs.samples(1)/SR;  t1 = t2/1.25;
    else t1 = sArgs.samples(1); t2 = sArgs.samples(2);
    end
end
%% coord & userData
allFolders    = dir(fullfile(dataPath,'*.ita'));
numAzAngle    = size(allFolders,1);

elAngle_arc   = sArgs.flute.theta;

coordHRTF     = itaCoordinates;
coordHRTF.sph = zeros(numel(elAngle_arc)*numAzAngle ,3);
coordHRTF.r   = ones(numel(elAngle_arc)*numAzAngle,1)*1.2;
%% Post processing Window

HRTF_TMP_L = itaAudio(numAzAngle,1);
HRTF_TMP_R = itaAudio(numAzAngle,1);

channelCounter = 1;
currentPath = dataPath;

%% Main processing Ref and Window
wb = itaWaitbar(numAzAngle, 'calculate HRTF', {'azimuth'});

% reference
% first determine how many channels the measurement has
currentDataEnding = num2str(1);
currentData       = ita_merge(ita_read([currentPath   filesep currentDataEnding '.ita']));

numChannels = currentData.nChannels;

%read the reference
currentRefTmp        = ita_read([path_ref  filesep sArgs.ref_name '.ita']);
currentRef = merge(currentRefTmp(1:1:length(currentRefTmp)));

if currentRef.nChannels == 2
   error('Reference might not be cropped yet.'); 
end

if currentRef.nChannels == numChannels
    refLeftChan0  = currentRef.ch(1:2:currentRef.nChannels); % a channel cloe to theta = 90�
    refRightChan0 = currentRef.ch(2:2:currentRef.nChannels);    
else
    refLeftChan0 = currentRef;
    refRightChan0 = currentRef;   
end


refLeftChan0c  = ita_time_window(refLeftChan0,[t1 t2],'time','crop');
refRightChan0c = ita_time_window(refRightChan0 ,[t1 t2],'time','crop');
    
%.........................................................................
% Smooting
%.........................................................................
refLeftChan0c = ita_smooth_notches(refLeftChan0c,'bandwidth',1/2,...
    'threshold', 3);

refRightChan0c = ita_smooth_notches(refRightChan0c,'bandwidth',1/2,...
    'threshold', 3);
    
for iAz = 1:numAzAngle
    
    %currentAz_front   = mod(360-azAngle(iAz),360);          % vordere H�lfte des Lautsprecherbogens: Azimutwinkel = azAngle
       
    %.........................................................................
    % read HRTF raw data
    %.........................................................................
    currentDataEnding = num2str(iAz);
    
    try
        currentData       = ita_merge(ita_read([currentPath   filesep currentDataEnding '.ita']));
        if sArgs.eimar
            phi  = mod(2*pi-currentData.channelCoordinates.phi+deg2rad(sArgs.phiAdd) ,2*pi);
        else  phi = mod(currentData.channelCoordinates.phi+deg2rad(sArgs.phiAdd) ,2*pi);
        end
        
    catch
        disp('help me')
    end
       
    %.........................................................................
    % Divide itaAudio in 2 parts for left and right ear
    %.........................................................................
    currentDataS   = currentData;
    currentDataSave(iAz,1) = currentData.ch(1:2:currentDataS.dimensions);
    currentDataSL0 = ita_time_window(currentDataS.ch(1:2:currentDataS.dimensions),[t1 t2],'time','crop');
    currentDataSR0 = ita_time_window(currentDataS.ch(2:2:currentDataS.dimensions),[t1 t2],'time','crop');
    

    
%     refRightChan0S = refLeftChan0S;
%       
%     if mod(refLeftChan0S.nSamples,2)  == 1 % ungerade Anzahl an Samples!
%         refLeftChan0S.trackLength      = refLeftChan0c.trackLength-1/refLeftChan0c.samplingRate;
%         refRightChan0S.trackLength     = refLeftChan0c.trackLength-1/refLeftChan0c.samplingRate;
%         currentDataSL0.trackLength     = refLeftChan0c.trackLength-1/refLeftChan0c.samplingRate;
%         currentDataSR0.trackLength     = refLeftChan0c.trackLength-1/refLeftChan0c.samplingRate;
%     end
    %.........................................................................
    % Calculate HRTF
    %.........................................................................
    HRTF_TMP_L(iAz,1)  = ita_divide_spk(currentDataSL0,refLeftChan0c ,'regularization',[100,20000]);
    HRTF_TMP_R(iAz,1)  = ita_divide_spk(currentDataSR0,refRightChan0c,'regularization',[100,20000]);
    
    %.........................................................................
    % Coordinates
    %.........................................................................
    coordHRTF.theta(channelCounter:channelCounter+ numel(elAngle_arc)-1) =  elAngle_arc;
    coordHRTF.phi(channelCounter:channelCounter+ numel(elAngle_arc)-1)   =  phi(1:2:end);
  
    channelCounter = channelCounter+numel(elAngle_arc);
    wb.inc
end

wb.close

%% Merge HRTF
HRTF_R = HRTF_TMP_R(1:iAz).merge;
HRTF_R.channelCoordinates = coordHRTF;
HRTF_L = HRTF_TMP_L(1:iAz).merge;
HRTF_L.channelCoordinates = coordHRTF;
HRTF_sWin = ita_merge(HRTF_L,HRTF_R);
if ~isempty(sArgs.samples),HRTF_sWin.nSamples = round(t2*SR);end

%%
[~, deltaT]     = ita_time_shift( HRTF_sWin,'20dB');    % Shift der IR nach vorn
deltaTmin       = min(deltaT);  
deltaT2         = 1e-3; 

HRTF_shift      = ita_time_shift(HRTF_sWin , deltaTmin+deltaT2);   % shifte Signale an den Anfang
HRTF            = ita_time_window(HRTF_shift, [t1 t2],'time','crop'); % Window
% HRTF.ch(1:32).ptd

%% save (is it working?)
if ~isempty(saveName) &&  ~isempty(savePath)
    ita_write(HRTF,fullfile(savePath, [saveName '.ita']));
end

%% out
if nargout <4
    varargout{1} = HRTF;
    if nargout >1
        varargout{2} = coordHRTFout;
    end
end

end