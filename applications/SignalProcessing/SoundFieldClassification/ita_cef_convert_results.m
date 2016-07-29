%function result = parse_results()

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;

%matlabpool open local;

%% Monte Settings
bs = 4:0.5:20; % Blocksizes the cef shall be calculated for
%lT = [0.1 0.2 0.3 0.4 0.5 0.75 1 1.5 2 3];%1.5 2]; % Reverberation Times to be simulated
%lDRR = [-30 -20 -15 -12.5 -10:2.5:10 12.5 15 20 30]; % DRRs to be simulated
lSNR = [-30]; % SNRs to be simulated
%nReps = 5; % Number of repetitions of each setting;
signalFFTDegree = 22;
rootpath = [cd filesep 'Results']; % Where do the results go?
mkdir(rootpath);

t_c = 1;
mode = '3d'; %'3d' 1d or 3d mode (hearing aid or sound field mic)
sfc_settings = {'sfcmethod',6, 'sfdmode',2,'blocksize',2^12,'overlap',0.75,'direct_plot',false,'compensate',false,'fraction',3,'t_c',t_c,'flimit',[20 20000],'psdbands',false,'calc_cef',true,'cef_blocksizes',bs};

d_sf_mic = 0.01; % diameter of sound field mic;
d_rep = 0.0115;
timestamp = datestr(now,30);

fileList = dir('IR_T_1_DRR_-20_rep_1.ita');
if ismac
    fileList = fileList(end:-1:1);
end

wb = itaWaitbar([numel(fileList) numel(lSNR)]);
for idx = 1:numel(fileList)
    tmp = sscanf(fileList(idx).name,'IR_T_%f_DRR_%f_rep_%i.ita');
    T = tmp(1);
    DRR = tmp(2);
    idRep = tmp(3);
    IR = ita_read(fileList(idx).name);
    
        
    switch mode
        case '1d'
            sfc_fun = @ita_sfa_run;
        case '3d'
            sfc_fun = @ita_sfa_3D;
    end
    
    
    for idSNR = 1:numel(lSNR)
        wb.inc();
        SNR = lSNR(idSNR);
        fName = [rootpath filesep 'T_' num2str(T) '_DRR_' num2str(DRR) '_SNR_' num2str(SNR) '_rep_' int2str(idRep) '_SFC.mat'];
        if ~exist(fName,'file')
            savethis(fName,struct('tmp','tmp'));
            noise = itaAudio(4,1);
            %% Generate input signal
            sourcesignal = ita_generate('noise',1,44100,signalFFTDegree);
            signal = ita_convolve(sourcesignal,IR);
            signal = ita_extract_dat(signal,signalFFTDegree);
            signal = ita_amplify_to(signal,0);
            
%             if ~isinf(SNR)
%                 for idch= 1:signal.nChannels
%                     noise(idch) = ita_amplify_to(ita_generate('noise',1,44100,signal.fftDegree),-SNR);
%                 end
%                 signal = signal+merge(noise);
%             end
            
            %% Sound Field Classification
            sfc_result = sfc_fun(signal,sfc_settings{:},'sensorspacing', d_rep,'cef_snr',SNR);
            saveData = struct('sfc_result',sfc_result,'sfc_settings',{sfc_settings},'bs',bs,'mode',mode,'d_sf_mic',d_sf_mic,'d_rep',d_rep,'fName',fName,'IR',IR,'signalFFTDegree',signalFFTDegree,'DRR',DRR,'SNR',SNR,'T',T,'idRep',idRep);
            %save(fName,'sfc_result','sfc_settings','c','N','bs','lT','lDRR','lSNR','nReps','mode','d_sf_mic','idDRR','idSNR','idT','idRep','fName','IR','signalFFTDegree','DRR','SNR','T');
            savethis(fName,saveData)
        end
    end
end
wb.close();
%matlabpool close force;