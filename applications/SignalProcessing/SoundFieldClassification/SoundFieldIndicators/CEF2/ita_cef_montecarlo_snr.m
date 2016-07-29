%% Simulate one room many times and have a look at the coherence

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
try %#ok<TRYNC>
    matlabpool close force;
end
matlabpool open 'local';

%% Get HRTF
%HRTFFileName = 'HA_HRTF_BTE_diffuse_compensated.ita';
HRTFFileNames = {'IDEALHA_HRTF_BTE_diffuse_compensated.ita'};
%'HA_HRTF_BTE_diffuse_compensated.ita';
%'HA_HRTF_ITC_diffuse_compensated.ita'
%};
uMode = false;


for HRTFid = 1:numel(HRTFFileNames);
    
    HRTFFileName = HRTFFileNames{HRTFid};
    
    %if ~exist('HRTF','var')
    HRTF = ita_read(HRTFFileName);
    %HRTF = ita_read('IDEALHA_HRTF_BTE_diffuse_compensated.ita');
    if uMode
        HRTF = ita_split(HRTF,'left',[],'substring');
    else
        HRTF = ita_split(HRTF,'front',[],'substring');
    end
    
    HRTF = HRTF.reduce(5);
    %HRTF = single(HRTF);
    %     HRTF = HRTF.';
    %     %HRTF.time = circshift(HRTF.time,[-133 0 0]);
    %     HRTF = HRTF';
    HRTF.directions = build_search_database(HRTF.directions);
    %end
    
    for idsim = 1
        
        
        %% Room settings
        x = [5 4 3]; % Room dimensions
        T = 1;
            r_in_rh = 1./(10.^(-20./20));
            for snr = -25:5:25
            
            roomtime = datestr(now,30);
            bs = 4:0.5:20;
            
            
            
            V = x(1)*x(2)*x(3);
            S = 2*x(1)*x(2) + 2*x(1)*x(3) + 2*x(2)*x(3);
            r = r_in_rh *  (0.057 * sqrt(V/T)); %Hallradius
            mkdir(roomtime);
            save([roomtime filesep 'MonteCarloSettings.mat'],'x','T','r','bs','V','S','r_in_rh','HRTFFileName','uMode','snr')
            
            
            
            parfor id_room = 1:20
                %for id_room = 1:10
                pu_coh = itaAudio;
                
                %% GET IR
                IR = ita_stochastic_room_impulse_response('HRTF',HRTF, 'V', V ,'S', S ,'T60', T, 'sourceposition',itaCoordinates([r,pi/2,0],'sph'),'max_reflections_per_second',1000,'dynamic',100);
                %% IR postprocessing
                IR = ita_mpb_filter(IR,[50 20000],'zerophase');
                if mod(IR.nSamples,2)
                    disp('now')
                end
                
                
                %% Blocksize evaluation
                noise = ita_generate('noise',1,IR.samplingRate,max(bs)+4);
                sensornoise = merge(ita_generate('noise',1,IR.samplingRate,max(bs)+4),ita_generate('noise',1,IR.samplingRate,max(bs)+4));
                
                
                for idx = 1:numel(bs)
                    disp(num2str(bs(idx)));
                    
                    thisnoise = ita_extract_dat(noise,max(bs(idx)+3,IR.fftDegree+4) );
                    thissensornoise = ita_extract_dat(sensornoise,max(bs(idx)+3,IR.fftDegree+4) );
                    
                    signal  = ita_convolve(thisnoise,IR,'circular',true); %#ok<*PFTIN>
                    signal = ita_amplify_to(signal,0) + ita_amplify_to(thissensornoise,-snr);
                    
                    
                    
                    if uMode
                        %u calc
                        S_u = ita_velocity_from_pressure_gradient(signal,'distance',itaValue(0.01,'m')) *340;
                        S_p = (signal.ch(1) + signal.ch(2)) / 2;
                        
                        signal = merge(S_u, S_p);
                    end
                    
                    pu_coh(idx) = ita_interpolate_spk(ita_coherence(ita_extract_dat(signal,bs(idx)+4),'blocksize',2^bs(idx)), 14);
                    
                end
                
                ita_write(pu_coh,[roomtime filesep int2str(id_room) '_coh.ita']);
                ita_write(IR,[roomtime filesep int2str(id_room) '_ir.ita']);
                
                
            end
        end
    end
    clear HRTF;
end
matlabpool close;