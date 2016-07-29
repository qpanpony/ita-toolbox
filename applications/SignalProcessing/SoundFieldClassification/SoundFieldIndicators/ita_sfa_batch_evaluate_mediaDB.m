%ccx;

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

function ita_sfa_batch_evaluate_mediaDB
%% Settings

waitUntilTrained = true; % Wait until autocompensation is all done
reRun = true; % Overwrite old results?
for compensate = [false]
    for sfc_method = [5]
        for sfd_method = [2]
            for autocompensate = [true]

                % SFA Settings
                settings = {'sfdmode',sfd_method,'sfcmethod',sfc_method,'blocksize',2^7,'overlap',0.75,'sensorspacing',0.014,'direct_plot',false,'compensate',false,'fraction',3,'t_c',0.5,'flimit',[100 10000],'psdbands',false,'autocompamp',autocompensate,'autocompphase',autocompensate};
                
                %% Get MediaDB folder
                MDBfolder = ita_preferences('SFC_MediaDBFolder');
                
                %% Read xls
                xlsfiles = dir([MDBfolder filesep 'data*.xls']);
                [~, ~, calibTab] = xlsread([MDBfolder filesep 'CalibData.xls'],'','','basic');
                
                if numel(xlsfiles) > 1
                    error('More than one xls file found')
                end
                [~, ~, xlsinfo] = xlsread([MDBfolder filesep xlsfiles(1).name],'','','basic');
                
                MDBinfo = cell2struct(xlsinfo(2:end,:),xlsinfo(1,:),2);
                CalibInfo = cell2struct(calibTab(2:end,:),ita_guisupport_removewhitespaces(calibTab(1,:)),2);
                
                %% Prepare Calibration Data
                %BTE1
                %if compensate
                BTE1RF = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE01' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE01_PN_RF.wav']);
                BTE1RB = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE01' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE01_PN_RB.wav']);
                BTE1LF = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE01' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE01_PN_LF.wav']);
                BTE1LB = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE01' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE01_PN_LB.wav']);
                compBTE1R = BTE1RF/BTE1RB;
                compBTE1R = ita_time_window(compBTE1R,[0.005 0.01],'symmetric');
                compBTE1R = ita_interpolate_spk(ita_resample(compBTE1R,22050),12);
                compBTE1L = BTE1LF/BTE1LB;
                compBTE1L = ita_time_window(compBTE1L,[0.005 0.01],'symmetric');
                compBTE1L =  ita_interpolate_spk(ita_resample(compBTE1L,22050),12);
                compBTE(1) = merge(ita_generate('impulse',1,compBTE1R.samplingRate,compBTE1R.fftDegree), compBTE1L, ita_generate('impulse',1,compBTE1R.samplingRate,compBTE1R.fftDegree), compBTE1R );
                
                %BTE2
                BTE1RF = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE02' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE02_PN_RF.wav']);
                BTE1RB = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE02' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE02_PN_RB.wav']);
                BTE1LF = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE02' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE02_PN_LF.wav']);
                BTE1LB = ita_read([MDBfolder filesep '..' filesep '..' filesep 'CalibrationData' filesep 'BTE02' filesep 'AnechChamberFF' filesep '20090625' filesep 'BTE02_PN_LB.wav']);
                compBTE1R = BTE1RF/BTE1RB;
                compBTE1R = ita_time_window(compBTE1R,[0.005 0.01],'symmetric');
                compBTE1R = ita_interpolate_spk(ita_resample(compBTE1R,22050),12);
                compBTE1L = BTE1LF/BTE1LB;
                compBTE1L = ita_time_window(compBTE1L,[0.005 0.01],'symmetric');
                compBTE1L =  ita_interpolate_spk(ita_resample(compBTE1L,22050),12);
                compBTE(2) = merge(ita_generate('impulse',1,compBTE1R.samplingRate,compBTE1R.fftDegree), compBTE1L, ita_generate('impulse',1,compBTE1R.samplingRate,compBTE1R.fftDegree), compBTE1R );
                
                clear compBTE1L compBTE1R BTE1*
                %end
                
                autoComp = ones(2^7/2+1,1);
                autoComp = repmat({autoComp},2,2);
                sampmm = repmat({1},2,2);
                sgdelay = repmat({0},2,2);
                
                %% ita_sfa_run on every folder / HA
                subfolders = dir(MDBfolder);
                subfolders = subfolders([subfolders.isdir] & ~strncmpi({subfolders.name},'.',1)); % only folders, no hidden
                
                % find ids
                % for idx = 1:numel(subfolders)
                %     ids(idx) = str2double(subfolders(idx).name(isstrprop(subfolders(idx).name,'digit')));
                % end
                %[~, ids] = sort(ids);
                
                channelNames = {'BTE LF', 'BTE LB', 'BTE RF', 'BTE RB', 'ITE LF', 'ITE LB (CIC L)', 'ITE RF', 'ITE RB (CIC R)', 'W', 'X', 'Y', 'Z'};
                for idx = 1:numel(subfolders)
                    disp(subfolders(idx).name);
                    id = str2double(subfolders(idx).name(isstrprop(subfolders(idx).name,'digit')))-1; %ids(idx);
                    folder = [MDBfolder filesep subfolders(idx).name];
                    resultfilename = [folder filesep 'sfresult.mat'];
                    if reRun || isempty(dir(resultfilename))
                        if ~isempty(dir(resultfilename))
                            delete(resultfilename);
                        end
                        %audio = merge(ita_read([folder filesep '*.wav']));
                        audio = merge(ita_read([folder filesep 'Audio_1.wav']),ita_read([folder filesep 'Audio_2.wav']),ita_read([folder filesep 'Audio_3.wav']),ita_read([folder filesep 'Audio_4.wav']));
                        if compensate && (audio.samplingRate ~= compBTE(1).samplingRate)
                            audio = ita_resample(audio,compBTE(1).samplingRate);
                        end
                        if mod(audio.nSamples,2)
                            audio = ita_extract_dat(audio,audio.nSamples-1);
                        end
                        availChannels = dir([folder filesep '*.wav']);
                        availChannels = ({availChannels.name});
                        availableChannels = [];
                        for idch = 1:min(numel(availChannels),audio.nChannels)
                            availableChannels(end+1) = str2num(availChannels{idch}(isstrprop(availChannels{idch},'digit'))); %#ok<ST2NM,AGROW>
                        end
                        audio.channelNames = channelNames(sort(availableChannels));
                        
                        result = struct();
                        result.MDBinfo = MDBinfo(id);

                        % What satelite are we using?
                        line = find([CalibInfo.MDBPackageID] == MDBinfo(id).PackageID,1); % The line of info we search
                        satID = CalibInfo(line).SatID;
                        if ~isempty(satID)
                            satID = str2num(satID(isstrprop(satID,'digit')));
                        else
                            satID = 3;
                        end
                        disp(['satID: ' int2str(satID)]); 
                        
                        % Compensate
                        if compensate && satID > 0 && satID < 3
                            audio = (audio * ita_extend_dat(compBTE(satID),audio.nSamples,'symmetric')).';
                        end
                        
                        for idch = 1:2
                            stopKrit = false;
                            a = [];
                            b = [];
                            idr = 1;
                            while ~stopKrit
                                disp(idr);
                                result.sf(idch) = ita_sfa_run(audio.ch((idch-1)*2+[1 2]),settings{:},'compinit',autoComp{satID,idch},'ampmminit',sampmm{satID,idch},'gdelayinit',sgdelay{satID,idch}); %#ok<*PFBNS>
                                a(idr) = result.sf(idch).ampmm;
                                b(idr) = result.sf(idch).gdelay;
                                autoComp{satID,1} = result.sf(idch).comp; % Remember compensation
                                sampmm{satID,idch} = result.sf(idch).ampmm;
                                sgdelay{satID,idch} = result.sf(idch).gdelay;
                                disp([20*log10(sampmm{satID,idch}) sgdelay{satID,idch}*1e6]);
                                if idr >= 2
                                    stopKrit = abs((a(idr)-a(idr-1))/a(idr)) < 0.01 & (abs((b(idr)-b(idr-1))/b(idr)) < 0.01 | b(idr) == 0) | ~autocompensate | ~waitUntilTrained;
                                end
                                idr = idr+1;
                            end
                        end
                        
                        result.settings = settings;
                        result.compensate = compensate;
                        result.autocompensate = autocompensate;
                        result.sfc_method = sfc_method;
                        result.sfd_method = sfd_method;
                        saveresult(resultfilename,result); %necessary for parfor
                        
                    end
                end
                ita_sfa_get_mediaDB_results();
            end
        end
    end
end

end

function saveresult(resultfilename,result) %#ok<INUSD>
idx = 1;
while idx < 100
    try
        save(resultfilename,'result');
        return;
    catch
        pause(1);
        idx = idx+1;
        disp('Write error, retry');
    end
end
end

