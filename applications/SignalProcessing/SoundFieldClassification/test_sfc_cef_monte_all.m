%%% Verification of the sound field classification by a point source in a reverberant room

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;

%matlabpool local 2;

startidDRR = 1;
startidT = 1;

%% Monte Settings
c = 340;
N = 25; % Number of Simulations per Room
bs = 4:0.5:20; % Blocksizes the cef shall be calculated for
lT = [0.1 0.2 0.3 0.4 0.5 0.75 1 1.5 2 3];%1.5 2]; % Reverberation Times to be simulated
lDRR = [-30 -20 -15 -12.5 -10:2.5:10 12.5 15 20 30]; % DRRs to be simulated
lSNR = [inf]; % SNRs to be simulated
nReps = 5; % Number of repetitions of each setting;
signalFFTDegree = 21;
rootpath = [cd filesep 'Results']; % Where do the results go?
mkdir(rootpath);
%% sfc_settings
t_c = 1;
mode = '3d'; %'3d' 1d or 3d mode (hearing aid or sound field mic)
sfc_settings = {'sfcmethod',6, 'sfdmode',2,'blocksize',2^12,'overlap',0.75,'direct_plot',false,'compensate',false,'fraction',3,'t_c',t_c,'flimit',[20 20000],'psdbands',false,'calc_cef',true,'cef_blocksizes',bs};

d_sf_mic = 0.01; % diameter of sound field mic;
timestamp = datestr(now,30);
%hrtfName = ['HA_HRTF_d_sf_mic_0.01.ita'];

switch mode
    case '1d'
        sfc_fun = @ita_sfa_run;
    case '3d'
        sfc_fun = @ita_sfa_3D;
end


%% Create HRTF
n_d = 5;
resolution = 5;
d = logspace(log10(0.1),log10(10),n_d);
%d(d>5) = [];
switch mode
    case '1d'
        [hrtf, d_rep] = ita_analytic_directivity_hearing_aid(d_sf_mic,d,resolution);
    case '3d'
        [hrtf, d_rep] = ita_analytic_directivity_soundfield_mic(d_sf_mic,d,resolution);
end
hrtf.directions = build_search_database(hrtf.directions);

%% Room settings
for idRep = 1:nReps
    for idDRR = startidDRR:numel(lDRR)
        for idT = startidT:numel(lT) %s
            T = lT(idT);
            DRR = lDRR(idDRR);
            % Fixed Room Size
            %x = [5 4 3].*3; % Room dimensions
            %V = x(1)*x(2)*x(3);
            %S = 2*x(1)*x(2) + 2*x(1)*x(3) + 2*x(2)*x(3);
            
            % Room size typical for T
            V = (T*6.4*0.26/0.161).^3;
            S = 6* V^(2/3);
            
            rh = (0.057 * sqrt(V/T)); % Hallradius
            r = rh / sqrt(10^(DRR/10));
            
            %% Simulate
            SNR = lSNR(1);
                fName = [rootpath filesep 'IR_T_' num2str(T) '_DRR_' num2str(DRR) '_rep_' int2str(idRep) '.ita'];
            %disp(fName);
            if ~exist(fName,'file')
                %% generate RIR
                dynamic = 80+max(0,20*log10(r));
                %IR = ita_stochastic_room_impulse_response('HRTF',hrtf, 'V', V ,'S', S ,'T60', T, 'sourceposition',itaCoordinates([r,pi/2,0],'sph'),'max_reflections_per_second',1000*max(1,10*log10(r)),'dynamic',dynamic,'first_reflection',-1);
                IR = ita_stochastic_room_impulse_response('HRTF',hrtf, 'V', V ,'S', S ,'T60', T, 'sourceposition',itaCoordinates([r,pi/2,0],'sph'),'max_reflections_per_second',1000,'dynamic',dynamic,'first_reflection',-1);
                
                ita_write(IR,fName);
%                 for idSNR = 1:numel(lSNR)
%                     SNR = lSNR(idSNR);
%                     fName = [rootpath filesep 'T_' num2str(T) '_DRR_' num2str(DRR) '_SNR_' num2str(SNR) '_rep_' int2str(idRep) '_SFC.mat'];
%                     if ~exist(fName,'file')
%                         noise = itaAudio(4,1);
%                         %% Generate input signal
%                         sourcesignal = ita_generate('noise',1,44100,signalFFTDegree);
%                         signal = ita_convolve(sourcesignal,IR);
%                         signal = ita_extract_dat(signal,signalFFTDegree);
%                         signal = ita_amplify_to(signal,0);
%                         
%                         if ~isinf(SNR)
%                             for idch= 1:signal.nChannels
%                                 noise(idch) = ita_amplify_to(ita_generate('noise',1,44100,signal.fftDegree),-SNR);
%                             end
%                             signal = signal+merge(noise);
%                         end
%                         
%                         %% Sound Field Classification
%                         sfc_result = sfc_fun(signal,sfc_settings{:},'sensorspacing', d_rep);
%                         saveData = struct('sfc_result',sfc_result,'sfc_settings',{sfc_settings},'c',c,'N',N,'bs',bs,'lT',lT,'lDRR',lDRR,'lSNR',lSNR,'nReps',nReps,'mode',mode,'d_sf_mic',d_sf_mic,'idDRR',idDRR,'idSNR',idSNR,'idT',idT,'idRep',idRep,'fName',fName,'IR',IR,'signalFFTDegree',signalFFTDegree,'DRR',DRR,'SNR',SNR,'T',T);
%                         %save(fName,'sfc_result','sfc_settings','c','N','bs','lT','lDRR','lSNR','nReps','mode','d_sf_mic','idDRR','idSNR','idT','idRep','fName','IR','signalFFTDegree','DRR','SNR','T');
%                         savethis(fName,saveData)
%                     end
%                 end
            end
        end
        %hrtf.directions = clear_search_database(hrtf.directions);
        %clear hrtf;
    end
end

%matlabpool close force;


