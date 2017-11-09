classdef v2
    % V2 Laboratory
    % Sound Insulation measurement of several plates differing in material,
    % thickness and geometry (single plate/single plate with opening/double
    % plate).
    %

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    % This class encapsulates most of the functionality. Use together with
    % v2gui.
    %
    % v1.0, 7.10.2014
    % Florian Theviﬂen, Florian.Thevissen@rwth-aachen.de
    % Institute of Technical Acoustics (ITA), RWTH Aachen University
    
    properties (Access=public)
        recordingRoom;                  % : struct
        materialProperties;             % : struct
        measurementProperties;          % : struct
        outputDirectory;                % : string (full path to folder)
        calibrationFile;                % : string (full path to file)
        MS;                             % : itaMSTF
        SNR;                            % : itaResult(1:i),  SNR vector of measurements
        SNR_m;                          % : itaResult,       Mean of SNR measurements
        Signals;                        % : itaAudio(1:i),   Recorded signals
        Signals_m;                      % : itaAudio,        Mean of signals
        Noise;                          % : itaAudio,        Estimated background noise
        Noise_m;                        % : itaAudio,        Mean of estimated background noises
        RT;                              % : itaResult        Reverberation time measurement
        TF;                             % : itaResult        Transfer function between rooms
        R;                              % : itaResult        Sound insulation
        soundInsulationIndex            % : double
        soundInsulationCurve
    end
    methods
        %% public interface
        % constructor
        function obj=v2(recordingRoom, materialProperties, measurementProperties,...
                outputDirectory, calibrationFile)
            
            obj.recordingRoom = recordingRoom;
            obj.materialProperties = materialProperties;
            obj.measurementProperties = measurementProperties;
            obj.outputDirectory = outputDirectory;
            obj.calibrationFile = calibrationFile;
            
            obj = obj.setupMS();
        end
        
        % measure everything there is to measure, then calculate R. After
        % execution all parameters listed above should be accessible.
        function obj = exec(obj)
            obj = obj.measureSignals();
            obj = obj.measureRT();
            obj = obj.calculateR();
        end
        
        % generates a string describing the material of the plate
        function str = genMaterialString(obj)
            str = ['Material: ' obj.materialProperties.material ',  d_1 = '...
                num2str(obj.materialProperties.thickness1*1000) 'mm'];
            switch obj.materialProperties.material
                case 'MDF'
                    disp('');
                case 'Aluminium'
                    disp('');
                case 'Brass'
                    disp('');
                case 'MDF double plate'
                    str = [str ', d_2 = ' num2str(obj.materialProperties.thickness2*1000)...
                        'mm, d_air = ' num2str(obj.materialProperties.thicknessAir*1000) 'mm'];
                case 'Plate with opening area'
                    str = [str ', A = ' num2str(obj.materialProperties.openingArea*10^6) 'mm2'];
                otherwise
                    warning('Unexpected material type. No material string created.');
            end
        end
        
        % generates a string describing the material of the plate
        % (filename-friendly)
        function str = genFilenameString(obj)
            m = obj.materialProperties.material; % shorthand for line underneath
            str = [datestr(now, 'yymmdd_HHMM'),'h_',m((~isspace(m)))...
                '_' num2str(round(obj.materialProperties.thickness1*1000)) 'mm'];
            switch obj.materialProperties.material
                case 'MDF'
                    disp('');
                case 'Aluminium'
                    disp('');
                case 'Brass'
                    disp('');
                case 'MDF double plate'
                    str = [str '_' num2str(round(obj.materialProperties.thickness2*1000))...
                        'mm_' num2str(round(obj.materialProperties.thicknessAir*1000)) 'mm'];
                case 'Plate with opening area'
                    str = [str '_' num2str(round(obj.materialProperties.openingArea*10^6)) 'mm2'];
                otherwise
                    warning('Unexpected material type. No filename created.');
                    return;
            end
            str = [str '_' num2str(obj.measurementProperties.sourcePositions) 'pos'];
        end
        
        %% private helper functions
        % initialization of itaMSTF instance
        function obj = setupMS(obj)
            load(obj.calibrationFile);
            obj.MS = V2_calib;
            obj.MS.outputamplification = 22;
            obj.MS.fftDegree = 16; %init.
            obj.MS.averages = 1;
            obj.MS.fftDegree = obj.measurementProperties.samples;
        end
        
        % measure SNR and Signals in both sending and receiving room
        function obj = measureSignals(obj)
            obj.Signals = itaAudio(obj.measurementProperties.sourcePositions,1);     % preallocation? is necessary?
            obj.SNR = itaResult(obj.measurementProperties.sourcePositions,1);
            obj.Noise = itaAudio(obj.measurementProperties.sourcePositions,1);
            for i = 1:obj.measurementProperties.sourcePositions
                ita_verbose_info('Getting Background Noise and Signal Level',0);
                try
                    [obj.SNR(i),obj.Signals(i),obj.Noise(i)] = obj.MS.run_snr;
                    obj.SNR(i) = ita_merge(obj.SNR(i),ita_mean(obj.SNR(i).ch(1:4)),ita_mean(obj.SNR(i).ch(5:8)));
                    obj.SNR(i).channelNames={'SNR(ch1)', 'SNR(ch2)', 'SNR(ch3)','SNR(ch4)',...
                        'SNR(ch5)','SNR(ch6)','SNR(ch7)','SNR(ch8)','mean(SNR_S)','mean(SNR_R)'};
                    obj.SNR(i).comment = [obj.SNR(i).comment '  , ' obj.genMaterialString()];
                catch errorObj
                    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
                end
                if i < obj.measurementProperties.sourcePositions
                    uiwait(msgbox('Measurement done, move the source to the next position and press OK'));
                end
            end
            
            % plot one measurement result and save it to lab course folder
            % do this only for the first measurement of the lab course to discuss
            % the measurement wrt. to modes and Schroeder frequency
            if ~exist([obj.outputDirectory,'\measurement_result_S.jpg'],'file')
               % plotSignalsS = ita_merge([ita_merge(obj.Signals.ch(1:4)),ita_mean(obj.Signals.ch(1:4))]);
               plotSignalsS = ita_merge([obj.Signals.ch(1:4)]);
               plotSignalsS.channelNames = {'ch(1)','ch(2)','ch(3)','ch(4)'};
               plotSignalsS.comment = 'Sound pressure measured at the 4 microphone positions in transmitter room';
               hS=ita_plot_freq(plotSignalsS);
               hline = findobj(hS, 'type', 'line');
               set(hline,'LineStyle','-', 'LineWidth', 1);
%                set(hline(11),'LineWidth',2,'LineStyle','-');
               
               mkdir(obj.outputDirectory)
               saveas(hS,[obj.outputDirectory,'\measurement_result_S'],'jpg')
               saveas(hS,[obj.outputDirectory,'\measurement_result_S'],'fig')
               
               % plotSignalsR = ita_merge([obj.Signals.ch(5:8),ita_mean(obj.Signals.ch(5:8))]);
               plotSignalsR = ita_merge([obj.Signals.ch(5:8)]);
               plotSignalsR.channelNames = {'ch(5)','ch(6)','ch(7)','ch(8)'};
               plotSignalsR.comment = 'Sound pressure measured at the 4 microphone positions in receiver room';
               hR=ita_plot_freq(plotSignalsR);
               hline = findobj(hR, 'type', 'line');
               set(hline,'LineStyle','-', 'LineWidth', 1);
%                set(hline(11),'LineWidth',2,'LineStyle','-');
               
               saveas(hR,[obj.outputDirectory,'\measurement_result_R'],'jpg')
               saveas(hR,[obj.outputDirectory,'\measurement_result_R'],'fig')
               
               uistack(hS,'bottom')
               uistack(hR,'bottom')
            end
            
            % post measurement: get mean SNR over 'sourcePositions' measurements
            obj.Signals_m = ita_mean(obj.Signals.merge,'same_channelnames_only');
            obj.Noise_m = ita_mean(obj.Noise.merge,'same_channelnames_only');
            N       = ita_spk2frequencybands(obj.Noise_m,'bandsperoctave',3,'freqRange',[min(obj.MS.freqRange(:)) max(obj.MS.freqRange(:))]);
            sig     = sqrt(abs(obj.Signals_m')^2 - abs(obj.Noise_m')^2);
            S       = ita_spk2frequencybands(sig,'bandsperoctave',3,'freqRange',[min(obj.MS.freqRange(:)) max(obj.MS.freqRange(:))]);
            SNR_mult = S/N;
            obj.SNR_m  = ita_merge(SNR_mult,ita_mean(SNR_mult.ch(1:4)),ita_mean(SNR_mult.ch(5:8)));
            obj.SNR_m.channelNames={'mean(SNR(ch1))', 'mean(SNR(ch2))', 'mean(SNR(ch3))','mean(SNR(ch4))',...
                        'mean(SNR(ch5))','mean(SNR(ch6))','mean(SNR(ch7))','mean(SNR(ch8))','mean(mean(SNR_S))','mean(mean(SNR_R))'};
        end
        
        % calculate sound insulation
        function obj = calculateR(obj)
            obj.TF = obj.Signals_m*obj.MS.compensation/obj.MS.outputamplification_lin;
            obj.TF.signalType = 'energy';
            obj.TF.comment = obj.genMaterialString();
            ita_setinbase([obj.genFilenameString() '_no' num2str(obj.measurementProperties.sourcePositions)], obj.TF);     % necessary?
            
            fraction = 3;
            [obj.R,fc,p,pSendMean,pRecMean] = ita_laboratory_v2_sound_reduction_index(ita_extract_dat(obj.TF,16),'fraction',fraction,'sendChannels',1:4,'recChannels',5:8,'RT',obj.RT,'density',obj.materialProperties.density,...
                'Thickness_I',obj.materialProperties.thickness1, 'Thickness_II', obj.materialProperties.thickness2, 'Thickness_Air', obj.materialProperties.thicknessAir, 'OpeningArea', obj.materialProperties.openingArea, 'YoungsModulus',obj.materialProperties.youngsModulus,'Material',obj.materialProperties.material,...
                'Swall',obj.recordingRoom.width*obj.recordingRoom.height,'VrecRoom',obj.recordingRoom.width*obj.recordingRoom.height*obj.recordingRoom.depth);
            
            warning('off', 'ita_soundInsulationIndex:input')
            [obj.soundInsulationIndex, obj.soundInsulationCurve] = ita_soundInsulationIndexAirborne(obj.R);
        end
        
        % measure reverberation time of receiving and sending rooms
        function obj = measureRT(obj)
            % placeholder function. RT is currently not measured.
            obj.RT = ita_read('RT_rop_fpa.ita');
        end
        
        function plotR(obj, figureHandle)
            if nargin == 1
                % figure handle passed -> use it
                h_R = ita_plot_freq(R,'ylim',[0 60],'xlim',[315 20000], 'figureHandle', figureHandle);
            elseif nargin == 0
                % no figure handle passed -> open new figure for plot
                h_R = ita_plot_freq(R,'ylim',[0 60],'xlim',[315 20000], 'figureHandle');
            end
            title(['R_W(f=500Hz) = ' num2str(soundInsulationIndex) 'dB']);
            ylabel('Sound insulation [dB]')
            xlabel('Frequency [Hz]')
        end
    end
end