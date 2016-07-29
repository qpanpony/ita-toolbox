% Plot SFC error against sensor mismatch

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
%matlabpool;
bwoutput = false;



% Fast results
% amp_mismatch = 0:0.5:3;
% gdelay_mismatch = (0:0.05:0.3)/1000;
% phase_mismatch = (0:30:180);
addpath(ita_preferences('SFC_AudioFolder'));

%% Loop
for sigID = 2
    for auto_compensate = [true false]
        for pumode = [false true]
            for errormode = 2 % 1 Amp error, 2 delay, 3 phase mismatch
                 
                %% SFC Settings
                settings = {'sfcmethod',5,'sfdmode',2,'blocksize',2^8,'overlap',0.75,'sensorspacing',0.014,'bandidplot',10,'direct_plot',false,'compensate',false,'fraction',3,'t_c',1,'flimit',[200 4000],'psdbands',false,'autocompphase',auto_compensate,'autocompamp',auto_compensate,'t_autocalib', 10};
                
                %% Error - Nice resolution
                amp_mismatch = 0:0.05:3;
                phase_mismatch = (0:1:180);
                gdelay_mismatch = (0:0.005:0.3)/1000;
                
                %% Input Signal
                switch sigID
                    case 1
                        %% Speech in Vorraum Hallraum
                        speech = ita_read('Lang1.wav');
                        %speech = ita_append(ita_generate('emptydat',44100,10),ita_extract_dat(speech.ch(1),20));
                        %speech = ita_append(ita_generate('emptydat',44100,10),ita_extract_dat(speech.ch(1),22));
                        speech = ita_append(ita_generate('emptydat',44100,10),ita_extract_dat(speech.ch(1),19));
                        
                        TF = ita_read('vorraum_hallraum_pos3_TF.ita');
                        TF = ita_time_window(TF.ch([1 2]),[0.6 0.8],'crop');
                        
                        signal = ita_normalize_dat(ita_convolve(speech,TF));
                        
                        signal = signal.ch([1 2]);
                        name = 'VorraumHallraum_fine';
                        signal = ita_filter_bandpass(signal,'lower',50,'upper',12000);
                        
                    case 2
                        %% Basic Sound Field Sequence - IDEAL
                        signal = ita_read('IdealSoundFields_IDEALHA_HRTF_BTE_non_compensated.ita');
                        signal = signal.ch([1 2]);
                        name = 'BSFS';
                        if auto_compensate % Three times to allow training
                            signal = ita_append(ita_append(signal, signal), signal);
                        end
                        signal = ita_filter_bandpass(signal,'lower',50,'upper',12000);
                end
                signal = ifft(signal);
                
                if pumode
                    signal = merge((signal.ch(1)+signal.ch(2))/2, ita_velocity_from_pressure_gradient(signal.ch([1 2]),'distance',0.012,'normalized')); % Get pu signal
                end
                               
                %% Reference
                comp = [];
                sampmm = 1;
                sgdelay = 0;
                stopKrit = false;
                idx = 1;
                while ~stopKrit
                    disp(idx);
                    [tsfi, tsfd, tsfc, tsfa,comp,sampmm, sgdelay] = ita_sfa_run(signal,settings{:},'puinput',pumode,'compinit',comp,'ampmminit',sampmm,'gdelayinit',sgdelay);
                    a(idx) = sampmm;
                    b(idx) = sgdelay;
                    disp([20*log10(sampmm) sgdelay*1e6]);
                    if idx >= 2
                        stopKrit = abs((a(idx)-a(idx-1))/a(idx)) < 0.01 & abs((b(idx)-b(idx-1))/b(idx)) < 0.01 | ~auto_compensate;
                    end
                    idx = idx+1;
                end
             
                %% Error
                err = [];
                %comp = [];
                %sampmm = 1;
                %sgdelay = 0;
                errorsize = numel(amp_mismatch) * (errormode == 1) + numel(gdelay_mismatch) * (errormode == 2) + numel(phase_mismatch) * (errormode == 3);
                
                for idx = 1:errorsize
                    disp(idx/errorsize*100);
                    thissignal = signal;
                    %thissignal = merge(signal.ch(1), signal.ch(2) * 10^(amp_mismatch(idx)/20));
                    a = [];
                    b = [];
                    stopKrit = false;
                    idy = 1;
                    try
                        thisamp_mismatch = amp_mismatch(idx) * (errormode == 1);
                        thisgdelay_mismatch = gdelay_mismatch(idx) * (errormode == 2);
                        thisphase_mismatch = phase_mismatch(idx) * (errormode == 3);
                    end
                    while ~stopKrit
                        disp([idx idy]);                      
                        [isfi, isfd, isfc, isfa, comp,sampmm,sgdelay] = ita_sfa_run(thissignal,settings{:},'puinput',pumode,'compinit',comp,'ampmismatch',thisamp_mismatch,'gdelay',thisgdelay_mismatch,'phasemismatch',thisphase_mismatch,'ampmminit',sampmm,'gdelayinit',sgdelay);
                        a(idy) = sampmm;
                        b(idy) = sgdelay;
                        disp([20*log10(sampmm) sgdelay*1e6]);
                        if idy >= 2
                            %disp(abs((a(idy)-a(idy-1))/a(idy)*100));
                            %disp(abs((b(idy)-b(idy-1))/b(idy))* 1e6);
                            stopKrit = abs((a(idy)-a(idy-1))/a(idy)) < 0.01 & abs((b(idy)-b(idy-1))/b(idy)) < 0.01 | ~auto_compensate;
                        end
                        idy = idy+1;
                    end
                    sfc_error_absolute = abs(tsfc-isfc);
                    
                    err(idx,:) = nanmean(nanmean(sfc_error_absolute.time,1),2);
                    
                end
                
                figure();
                
                switch errormode
                    case 1
                        plot(amp_mismatch,err,'LineWidth',2);
                        hold all
                        plot(amp_mismatch,sum(abs(err),2),'LineWidth',2,'Color',[0 0 0],'LineStyle',':');
                        xlim([min(amp_mismatch) max(amp_mismatch)]);
                        xlabel('Amplitude Mismatch in dB');
                        
                    case 2
                        pgdelay_mismatch = gdelay_mismatch * 1e6;
                        plot(pgdelay_mismatch,err,'LineWidth',2);
                        hold all
                        plot(pgdelay_mismatch,sum(abs(err),2),'LineWidth',2,'Color',[0 0 0],'LineStyle',':');
                        xlim([min(pgdelay_mismatch) max(pgdelay_mismatch)]);
                        xlabel('Groupdelay in us');
                    case 3
                        plot(phase_mismatch,err,'LineWidth',2);
                        hold all
                        plot(phase_mismatch,sum(abs(err),2),'LineWidth',2,'Color',[0 0 0],'LineStyle',':');
                        xlim([min(phase_mismatch) max(phase_mismatch)]);
                        xlabel('Phase mismatch in deg');
                end
                ylim([0 1]);
                ylabel('Mean Absolute Error');
                legend([tsfc.channelNames; {'Total'}]);
                fname = ['ErrVSMM_' name '_pumode' int2str(pumode) '_errormode'  int2str(errormode) '_autocomp' int2str(auto_compensate)];
                
                ita_savethisplot_gle('fileName',fname,'output','png pdf','font_scale',1.5,'blackandwhite',bwoutput); 
            end
        end
    end
end
%matlabpool close;