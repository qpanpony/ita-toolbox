classdef itaHRTFarc < itaEimar
    % Measurements with the ITA HRTF-Arc and the ITA italian turntable
    %
    % BE AWARE: THIS APPLICATION NEEDS THE NEW VERSION OF THE TURNTABLE
    % WITH THE NEW MOTOR AND THE NEW MOTORCONTROLLER! NOT COMPATIBLE WITH
    % THE OLD MOVTEC-CONTROLLER AND TURNTABLEMOTOR!
    %
    %
    % How-to:
    %
    % First: Assemble Hardware!
    %
    % 1) Create Object:
    %           ARC = itaHRTFarc;
    % 2) Initialize:
    %           ARC.init;
    % 3) Make reference move:
    %           ARC.reference_move
    % 3b) Check audiohardware:
    %           ARC.test_audioequipment
    %           -> Will return true if everything is ok!
    % 3c) Optimize interleaved sweep [Optional - default for ITA-RAR: twait: 30ms SR: 9.1 Oct/s]
    %           ARC.optimize
    % 4a) Make reference measurement:
    %           -> Use small stand and make sure no reflexions are within target window!
    %           ARC.reference_LS
    % 4b) Measure positions of loudspeaker:
    %           -> Change hardware to LS-measurement-system
    %           ARC.calibrate_ARC
    %           -> Use ARC.test_positions to check order
    %           -> Use ARC.test_position_overlap to check for good distances!
    % 5) Measure DUT:
    %       5)  HRTF = ARC.run
    %   OR
    %       5a) ARC.run_raw
    %       5b) ARC.process_result(ARC.raw_measurement)
    %   OR
    %       5a) ARC.run_raw
    %       5b) Cropped = ARC.process_result_crop(ARC.raw_measurement);
    %       5c) Windowed = ARC.process_result_window_dec(Cropped);
    %       5d) Shifted = ARC.process_result_shift(Windowed, 'eardistance', [0.6 0.6]);
    %       5e) Spherical = ARC.process_result_spherical(Shifted);
    %       5f) HRTF = ARC.process_result_shift(Spherical, 'eardistance', -[0.6 0.6]);
    % 6) Export DAFF:
    %           ARC.export_DAFF('Filename');
    %           -> Optional: Hand in equiangluar sampling to process_result_spherical
    %                        to get correct interpolated values! Otherwise
    %                        neares-neighbour algorithm without interpolation is used!
    % 7) Enjoy your individual HRTF!
    %
    %
    % Author: Benedikt Krechel - Oct'11-June'12
    % Contact: Benedikt.krechel@rwth-aachen.de
    % Otherwise: Ask Pascal Dietrich!
    %
    % *********************************************************************
    % *********************************************************************
    
    
    % <ITA-Toolbox>
    % This file is part of the application Movtec for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties        
        % For RME-Setup: (You need different output/inputchannels and latency for
        % Presonus-Soundcards!)
        sArgs_HRTFarc_default       =   struct(               ...
            'outputchannels'        ,   [19:2:19+63]     , ...   % Outputchannels for the Loudspeakers
            'inputchannels'         ,   [1 2 11]             , ...   % To which channels are the microphones and the reference switch connected
            'inputchannels_reference'        ,   [1 2]      , ...   % To which channels are the microphones for the reference measurement connected
            'inputchannels_ARC_calibration'  ,   [1 2]      , ...   % To which channels are the microphones for the calibration of the LS positions connected
            'outputamplification'   ,   -35                 , ...   % 
            'sweeprate_range'       ,   [4 15]              , ...   % Allowed sweeprate-range
            'freq_range'            ,   [50 20000]          , ...   % 
            'Loudspeaker'           ,   32                  , ...   % How many loudspeakers
            'pre_angle'             ,   20                  , ...   % If we measure continuously, we use pre_angle in degree
            'MeasurementPositions'  ,   96                  , ...   % Number of measurements in azimuth-direction
            'input_latency'         ,   256                 , ...   % Latency of the input
            'latency'               ,   630                 , ...   % Total latency of Soundcard
            'shelving_filter'       ,   [-20 500]           , ...   % Shelving - this small loudspeakers need it!
            'samplingRate'          ,   44100               , ...   %
            'continuous'            ,   true                , ...   % Continuous measurment?
            'additional_measurements',  10                    );     % How many additonal measurements should we make if continuously measured?
        
        sArgs_HRTFarc               =   [];                     % some variables
        
        raw_measurement             =   itaAudio;               % Raw measurement data
        reference_measurement       =   itaAudio;               % Raw reference measurement data
        
        HRTF                        =   itaAudio;               % Processed HRTF before SH-decomposition
        HRTF_sph                    =   itaAudio;               % Processed HRTF after SH-decomposition
        measured_speed              =   [];                     % Measured speed of turntable
        LSpositions                 =   itaCoordinates(40);     % Position of all loudspeakers
        
        c_meas                      =   340;                    % Speed of sound
        t_wait                      =   0.03;                   % t_wait for interleaved sweep (default 30 ms)
        sweeprate                   =   9.1;                    % Sweeprate for interleaved sweep (default 9.1 Oct/s)
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = protected)
        isOptimized                 =   false;
    end
    % *********************************************************************
    properties (Hidden = true)
        inverse_reference = itaAudio;
    end
    % *********************************************************************
    methods
        function this = itaHRTFarc(this) %#ok<INUSD>
            this.init();            
        end
        
        function init(this, varargin)
            %Initialize measurement...
            init@itaEimar(this);
            
            this.sArgs_HRTFarc          =   this.sArgs_HRTFarc_default;
            this.sArgs_HRTFarc          =   ita_parse_arguments(this.sArgs_HRTFarc, varargin);
            
            t_wait_opt                  = 	this.t_wait;
            sweeprate_opt               =   this.sweeprate;
            %-------------------------------------------------------------
            % Prepare measurement setup:
            %-------------------------------------------------------------
            t_sweep =   log2(this.sArgs_HRTFarc.freq_range(2)/...
                this.sArgs_HRTFarc.freq_range(1))/sweeprate_opt;
            
            speed   =   360/(this.sArgs_HRTFarc.MeasurementPositions*t_wait_opt*this.sArgs_HRTFarc.Loudspeaker);
            
            this.ContinuousMeasurement                  =   this.sArgs_HRTFarc.continuous;
            this.measurementSetup                       =   itaMSTFinterleaved;
            this.measurementSetup.samplingRate          =   this.sArgs_HRTFarc.samplingRate;
            this.measurementSetup.outputamplification   =   this.sArgs_HRTFarc.outputamplification;
            this.measurementSetup.outputChannels        =   this.sArgs_HRTFarc.outputchannels;
            this.measurementSetup.inputChannels         =   this.sArgs_HRTFarc.inputchannels;
            this.measurementSetup.fftDegree             =   log2(t_sweep*this.measurementSetup.samplingRate);
            this.measurementSetup.twait                 =   t_wait_opt;
            this.measurementSetup.shelving              =   this.sArgs_HRTFarc.shelving_filter;
            this.measurementSetup.freqRange             =   this.sArgs_HRTFarc.freq_range;
            this.measurementSetup.latencysamples        =   this.sArgs_HRTFarc.latency;
            if this.sArgs_HRTFarc.continuous
                this.measurementSetup.repititions       =   this.sArgs_HRTFarc.MeasurementPositions+this.sArgs_HRTFarc.additional_measurements;
                this.measurementPositions               =   itaCoordinates(2);
                this.measurementPositions.phi           =   [-this.sArgs_HRTFarc.pre_angle speed]/180*pi;
            else
                this.measurementSetup.repititions       =   1;
                this.measurementPositions               =   itaCoordinates(this.sArgs_HRTFarc.MeasurementPositions);
                this.measurementPositions.phi           =   (0:2*pi/this.sArgs_HRTFarc.MeasurementPositions:(2*pi-2*pi/this.sArgs_HRTFarc.MeasurementPositions));
            end
            %-------------------------------------------------------------
            % Initialize LSpositions: (Replace by actual measured positions later!)
            %-------------------------------------------------------------
            p                   =   ita_HRTFarc_returnIdealNewArcCoordinates;
            p                   =   p.n(1:2:p.nPoints);
            p                   =   unique(p.theta);
            this.LSpositions            =   itaCoordinates(length(p));
            this.LSpositions.azimuth    =   ones(1,length(p))*0;
            this.LSpositions.elevation  =   p;
            this.LSpositions.r          =   ones(1,length(p));
            
            this.mIsInitialized =   true;
        end
        
        function [t_wait sweeprate speed] = optimize(this)
            % Optimize interleaved sweep. Measure parameter (Level of NLIR
            % and t_RIR (length of impulse response) and run
            % itaMSTFinterleaved optimization.            
            %-------------------------------------------------------------
            % Measure room and optimize for this result:
            ita_verbose_info('Measureing nonlinearities...', 2);
            nonlinearities_level_rel    =   this.measurementSetup.measure_nonlins();
            %-------------------------------------------------------------
            ita_verbose_info(['Nonlinearities: ' num2str(nonlinearities_level_rel) ' below linear peak'], 1);
            % Try to measure time until impuls response vanished in noise:
            ita_verbose_info('I will now try to measure the time until the impulse response vanichs in noise...', 2);
            RIR_revtime                 =   this.measure_revtime();
            tRIR_vec                    =   zeros(1, RIR_revtime.nChannels);
            for i = 1:RIR_revtime.nChannels
                [~, ~, c, ~]            =   ita_roomacoustics_reverberation_time_lundeby(RIR_revtime.ch(i), 'freqRange', this.sArgs_HRTFarc.freq_range);
                tRIR_vec(i)             =   c.freqData;
            end
            % Do some ploting for the user:
            figure; plot(tRIR_vec((tRIR_vec < 3*median(tRIR_vec) & tRIR_vec > 0.1*median(tRIR_vec))));
            legend('tRIR [0.1*median(tRIR) < tRIR(i) < 3*median(tRIR)]');
            
            % Do some kind of averaging but skip values which are extraordinary high or low!
            tRIR                        =   mean(tRIR_vec((tRIR_vec < 3*median(tRIR_vec) & tRIR_vec > 0.1*median(tRIR_vec))));
            
            % Ask user if the value is ok:
            text                        =   input(sprintf('Measured time until impulse response is below noise: %0.2f ms\r Do you want to use this value? [Y/N]', tRIR*1000), 's');
            if ~strcmpi(text, 'Y')
                tRIR                    =   input('Enter value in ms (ITA-RAR = ~30ms): ')/1000;
            end
            
            % Run interleaved optimization with measured values:
            if this.sArgs_HRTFarc.continuous
                [t_wait sweeprate]          =   this.measurementSetup.optimize(...
                    'sweeprate_range'       ,   this.sArgs_HRTFarc.sweeprate_range  , ...
                    'freq_range'            ,   this.sArgs_HRTFarc.freq_range       , ...
                    'L'                     ,   this.sArgs_HRTFarc.Loudspeaker      , ...
                    'mode'                  ,   'cyclic'                            );
            else
                [t_wait sweeprate]          =   this.measurementSetup.optimize(...
                    'tRIR'                  ,   tRIR                                , ...
                    'harmonicDecreaseVector',   nonlinearities_level_rel            , ...
                    'sweeprate_range'       ,   this.sArgs_HRTFarc.sweeprate_range  , ...
                    'freq_range'            ,   this.sArgs_HRTFarc.freq_range       , ...
                    'L'                     ,   this.sArgs_HRTFarc.Loudspeaker      , ...
                    'mode'                  ,   'standard'                            );
            end

            % Set movement values for turntable:
            if this.sArgs_HRTFarc.continuous
                speed                       =   360/(this.sArgs_HRTFarc.MeasurementPositions*t_wait*this.sArgs_HRTFarc.Loudspeaker);
                this.measurementPositions.phi       =   [-this.sArgs_HRTFarc.pre_angle speed]/180*pi;
                ita_verbose_info(sprintf('\r\rOptimization done.\r\rParameters set to: \rSweeprate: %0.2f Octaves/s \r<=> Sweeplength: %0.2f s\r<=> FFT-Degree: %0.2f\rT_Wait: %0.2f ms\rRotationspeed: %0.2f °/s\r\rEstimated measurement time: %0.2f min', ...
                    sweeprate, t_sweep, this.measurementSetup.fftDegree, t_wait*1000, ...
                    speed, (t_sweep+(this.sArgs_HRTFarc.MeasurementPositions+3)*this.sArgs_HRTFarc.Loudspeaker*t_wait)/60),0);
            else
                ita_verbose_info(sprintf('\r\rOptimization done.\r\rParameters set to: \rSweeprate: %0.2f Octaves/s \r<=> Sweeplength: %0.2f s\r<=> FFT-Degree: %0.2f\rT_Wait: %0.2f ms\r\rEstimated measurement time: %0.2f min', ...
                    sweeprate, t_sweep, this.measurementSetup.fftDegree, t_wait*1000, ...
                    (this.sArgs_HRTFarc.MeasurementPositions*(t_sweep+this.sArgs_HRTFarc.Loudspeaker*t_wait+1))/60),0);
            end
            
            %-------------------------------------------------------------
            % Optimization done!
            %-------------------------------------------------------------
            this.isOptimized            =   true;
        end
        %----------------------------------------------------------------
        % Test stuff:
        function working = test_audioequipment(this, varargin)
            % Test audio equipment by checking all LS and Mics
            variables                           =   struct('SNR',20);
            variables                           =   ita_parse_arguments(variables, varargin);
            working                             =   true;
            
            % Use only one repitition and reference configuration:
            temp_repititions                    =   this.measurementSetup.repititions;
            temp_inputchannels                  =   this.measurementSetup.inputChannels;            
            this.measurementSetup.repititions   =   1;
            this.measurementSetup.inputChannels =   this.sArgs_HRTFarc.inputchannels_reference;
            % Run measurement:
            response                            =   MS.run;
            
            this.measurementSetup.repititions   =   temp_repititions;
            this.measurementSetup.inputChannels =   temp_inputchannels;
            
            % Measure peak to average:
            peaktoaverage                       =   max(abs(response.timeData)) ./ sqrt(mean(response.timeData.^2));
            n = 0;
            for i = 1:numel(peaktoaverage)/this.sArgs_HRTFarc.Loudspeaker
                mic(i)                          =   peaktoaverage((1:this.sArgs_HRTFarc.Loudspeaker)+(i-1)*this.sArgs_HRTFarc.Loudspeaker); %#ok<AGROW>
                if max(mic(i)) < (10^(variables.SNR/20))
                    ita_verbose_info(['Mic ' num2str(i) ' is not working!'], 0);
                    %mic1                            =   mic2; % Using other microphone to test LS!
                    working                         =   false;
                    n = n + 1;
                end
            end
            if n == numel(mic)
                ita_verbose_info('Loudspeaker test not possible - please check microphones first!', 0);
                return;
            end
            % Look for broken loudspeakers:
            faultyLS                            =   find(max(mic) < (10^(variables.SNR/20)));
            if isempty(faultyLS)
                ita_verbose_info('Recieving signal from all loudspeakers - seems to be ok! (Note that this does not include a correct order! Use calibrate_ARC to check the positions!)', 1)
            else
                if numel(faultyLS) == 1
                    text = ['There is one loudspeaker without signal. Please check loudspeaker ' num2str(faultyLS) '.'];
                else
                    text = ['There are ' num2str(numel(faultyLS)) ' loudspeaker without signal. Please check loudspeaker ' num2str(faultyLS(1:end-1)) ' and ' num2str(faultyLS(end)) '.'];
                end
                ita_verbose_info(text, 0);
                working                         =   false;
            end
        end
        
        function test_positions(this)
            % Show scattering plot of LS positions and distance to perfect
            % gaussian sampling:
            s_gauss                 =   ita_sph_sampling_gaussian(47);
            tempc                   =   this.LSpositions;
            temp7                   =   s_gauss.n(1:96:s_gauss.nPoints);
            temp7.x(2:2:40)         =   -temp7.x(2:2:40);
            figure;
            diff(1:20)              =   (temp7.theta(40:-2:2)-tempc.theta(1:20))/pi*180;
            diff(21:40)             =   (temp7.theta(1:2:40)-tempc.theta(21:40))/pi*180;
            % Plot:
            temp7.n(1:40).scatter('o');
            hold on
            tempc.n(1:20).scatter('*');
            tempc.n(21:40).scatter('+');
            legend({'x = Gaussian', 'o = Left side', '+ = Right side'});
            axis([-1.3 1.3 -0.1 0.1 -1.3 1.3]);
            line([zeros(20,1) -0.9.*sin(tempc.theta(1:20))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(tempc.theta(1:20))]', 'Color','g')
            line([zeros(20,1) 0.9.*sin(tempc.theta(21:40))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(tempc.theta(21:40))]', 'Color','r')
            line([zeros(20,1) 0.9.*sin(temp7.theta(1:2:40))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(temp7.theta(1:2:40))]', 'Color','b')
            line([zeros(20,1) -0.9.*sin(temp7.theta(2:2:40))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(temp7.theta(2:2:40))]', 'Color','b')
            
            texte = sprintf('The loudspeakers have following differences in degree to their ideal position:\r');
            for i = 1:20
                text(-tempc.r(i).*1.15.*sin(tempc.theta(i)), 0, tempc.r(i).*1.15.*cos(tempc.theta(i)), sprintf('%d', i), 'HorizontalAlignment', 'center');
                texte = [texte sprintf('Loudspeaker %d: %2.1f°\r', i, diff(i))]; %#ok<AGROW>
            end
            for i = 21:40
                text(tempc.r(i).*1.15.*sin(tempc.theta(i)), 0, tempc.r(i).*1.15.*cos(tempc.theta(i)), sprintf('%d', i), 'HorizontalAlignment', 'center');
                texte = [texte sprintf('Loudspeaker %d: %2.1f°\r', i, diff(i))]; %#ok<AGROW>
            end
            display(texte);
        end
        
        function test_position_overlap(this)
            % Show left and right arc at the same side. Good to see
            % whether two loudspeaker are on the same height!
            s_gauss                 =   ita_sph_sampling_gaussian(47);
            tempc                   =   this.LSpositions;
            tempc.x                 =   abs(tempc.x);
            temp7                   =   s_gauss.n(1:96:s_gauss.nPoints);
            figure;
            diff(1:20)              =   (temp7.theta(40:-2:2)-tempc.theta(1:20))/pi*180;
            diff(21:40)             =   (temp7.theta(1:2:40)-tempc.theta(21:40))/pi*180;
            temp7.n(1:40).scatter('o');
            hold on
            tempc.n(1:20).scatter('*');
            tempc.n(21:40).scatter('+');
            legend({'x = Gaussian', 'o = Left side', '+ = Right side'});
            axis([-0.1 1.3 -0.1 0.1 -1.3 1.3]);
            line([zeros(40,1) 0.9.*sin(temp7.theta(1:40))]', zeros(40,2)', [zeros(40,1) 0.9.*cos(temp7.theta(1:40))]', 'Color','b')
            line([zeros(20,1) 0.9.*sin(tempc.theta(1:20))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(tempc.theta(1:20))]', 'Color','g')
            line([zeros(20,1) 0.9.*sin(tempc.theta(21:40))]', zeros(20,2)', [zeros(20,1) 0.9.*cos(tempc.theta(21:40))]', 'Color','r')
            
            texte = sprintf('The loudspeakers have following differences in degree to their ideal position:\r');
            for i = 1:40
                text(tempc.x(i)+0.02.*tempc.rho(i), tempc.y(i), tempc.z(i), sprintf('%d', i));
                texte = [texte sprintf('Loudspeaker %d: %2.1f°\r', i, diff(i))]; %#ok<AGROW>
            end
            display(texte);
        end
        %----------------------------------------------------------------
        % Reference stuff:
        function reference(this)
            % Perform reference measurement
            if ~this.isInitialized
                this.initialize;
            end
            %-------------------------------------------------------------
            % Perform reference move:
            this.reference_turntable;
            %-------------------------------------------------------------
            % Perform latency measurement:
            %this.reference_latency;
            %-------------------------------------------------------------
            % Perform LS reference measurement:
            this.reference_LS_hidden;
            %-------------------------------------------------------------
            
            % The setup is referenced:
            this.isReferenced = true;
        end
        
        function reference_LS(this)
            % Perform only LS-reference measurement
            % Check if initialized:
            if ~this.isInitialized
                %    this.initialize;
            end
            
            this.reference_LS_hidden;
            
            ita_verbose_info('You should do a turntable reference move. Otherwise zero position is power-on position!',0);
            %-------------------------------------------------------------
            % The setup is referenced:
            this.isReferenced = true;
        end
        
        function reference_move(this)
            % Perform only reference move
            % Check if initialized:
            if ~this.isInitialized
                %    this.initialize;
            end
            %-------------------------------------------------------------
            % Perform reference move:
            %this.referenceMove;
            this.reference_turntable;
            %-------------------------------------------------------------
            %ita_verbose_info('You have not measured the latency! Please enter the latency to this.measurementSetup.latencysamples!',0);
            ita_verbose_info('You performed the reference measurement without LS and MIC measurement. Please load your reference measurement to this.reference_measurement!',0);
            %-------------------------------------------------------------
            % The setup is referenced:
            this.isReferenced = true;
        end
        
        function calibrate_ARC(this, varargin)
            % Measure LS-Positions
            if ~this.isInitialized
                this.initialize;
            end
                        
            variables       =   struct(...
                'twait'                     ,   0.5             , ...
                'measurement_positions'     ,   4               );
            variables = ita_parse_arguments(variables, varargin);
            
            MS                          =   itaMSTFinterleaved;
            MS.samplingRate             =   this.measurementSetup.samplingRate;
            MS.outputMeasurementChain   =   this.measurementSetup.outputMeasurementChain;
            MS.outputamplification      =   this.measurementSetup.outputamplification;
            MS.outputChannels           =   this.measurementSetup.outputChannels;
            MS.inputMeasurementChain    =   this.measurementSetup.inputMeasurementChain;
            MS.inputChannels            =   this.sArgs_HRTFarc.inputchannels_ARC_calibration;
            MS.freqRange                =   this.sArgs_HRTFarc.freq_range;
            MS.shelving                 =   [-20 500];
            MS.latencysamples           =   0;
            MS.twait                    =   variables.twait; % seconds
            MS.fftDegree                =   this.measurementSetup.fftDegree;
            
            % TODO @benedikt: alles bitte in Englisch AUCH
            % VARIABLEN NAMEN :-)
            
            temp                        =   itaAudio;
            for i = 1:variables.measurement_positions;
                % Measure procedure:
                %this.moveTo(360/Messpositionen*(i-1))
                this.move_turntable(360/variables.measurement_positions*(i-1), 'speed', 10, 'wait', true, 'absolut', true);
                pause(2); % Wait a little while...
                res                     =   merge(MS.run);
                temp                    =   merge(temp, res.ch([1:40 41:80]));
            end
            this.move_turntable(0, 'speed', 10, 'wait', false, 'absolut', true);
            % Oversample to get better impulse:
            temp = ita_oversample(temp, 10);
            pos_maximum = zeros(40,temp.nChannels/40);
            
            % Search maximum:
            for i = 1:this.sArgs_HRTFarc.Loudspeaker                
                [~, pos_maximum(i,:)]         =   max(abs(temp.ch(i:40:temp.nChannels).timeData));
                pos_maximum(i,:)              =   pos_maximum(i,:)./temp.samplingRate;
            end            
            
            % Run optimizer:
            ita_verbose_info('Trying to find positions.... might take a while...', 1);
            opt     =   optimset('TolFun', 1e-12,'TolX', 1e-12, 'Display', 'off', 'MaxIter', 800);
            [x, ~]  =   lsqnonlin(@(x) this.fehler2(x,pos_maximum), ...
                [repmat([2 2 2.5], 1, this.sArgs_HRTFarc.Loudspeaker) 650 650 650 650 650 0 0.8 pi/2 340], ... % Startvalue
                [repmat([-2 -2 -3.5], 1, this.sArgs_HRTFarc.Loudspeaker) 0 0 0 0 0 -pi/2 0.1 0 320], ... % Lower limit
                [repmat([2 2 3.5], 1, this.sArgs_HRTFarc.Loudspeaker) 15000 15000 15000 15000 15000 pi/2 1.3 pi 360],opt); % Upper limit
            % Solved! - Now assign variables to class:
            this.c_meas         =   x(end);             % Speed of Sound
            d                   =   x(end-2);           % Distance to rotary axis
            beta                =   x(end-1)/pi*180;    % angle of microphone stand - microphone boom
            gamma               =   x(end-3)/pi*180;    % angle of microphone holder - microphone boom
            latency             =   x((end-8):(end-4)); % Latency of soundcard
            % Assign loudspeaker positions to itaCoordinate-Object:
            LSpositions_local   =   itaCoordinates(40);
            for i = 1:40
                LSpositions_local.x(i)     =   x(1+(i-1)*3);
                LSpositions_local.y(i)     =   x(2+(i-1)*3);
                LSpositions_local.z(i)     =   x(3+(i-1)*3);                
            end
            % Compensate wrong adjustment of the calibration arm:
            y_offset                =   mean(LSpositions_local.y);
            phi_vec                 =   LSpositions_local.phi;
            phi_vec(1:20)           =   phi_vec(1:20)-pi;
            phi_vec(phi_vec > pi)	=   phi_vec(phi_vec > pi) - 2*pi;
            phi_vec(phi_vec < -pi)  =   phi_vec(phi_vec < -pi) + 2*pi;
            degree_offset           =   mean(phi_vec);
            LSpositions_local.phi	=   LSpositions_local.phi - degree_offset;
            
            % Some displaying stuff:
            ita_verbose_info('Assuming middle of ARC between loudspeaker 9 and 33.', 1);
            z_offset                =   (LSpositions_local.z(9) + LSpositions_local.z(33))/2;
            LSpositions_local.z     =   LSpositions_local.z - z_offset;
            sprintf('The calibration measured these parameters:\nAlpha: %f°\nBeta: %f° \nGamma: %f° \nDistance: %f cm\nThe soundcard has a latency between min %f and max %f samples.\nThe turntable is shifted by %f cm in Y direction.\nThe speed of sound is %f today.\r - And by the way: The temperatur is around %0.f°C', ...
                degree_offset/pi*180, beta, gamma, d*100, min(latency), max(latency), y_offset*100, this.c_meas, ((this.c_meas/331.5).^2-1)*273.15)
            sprintf(['The soundcards have a latency of: ' num2str(latenz)]);
            while true
                reply = input('Do you want to use the (lowest) measured latency for your measurement setup? [Y/N] ', 's');
                if strcmpi(reply, 'Y') || strcmpi(reply, 'J')
                    this.measurementSetup.latencysamples = floor(min(latency));
                    break;
                elseif strcmpi(reply, 'N')
                    break;
                end
            end
            %-------------------------------------------------------------
            this.LSpositions        =   LSpositions_local;
        end
        %----------------------------------------------------------------
        % Measurement stuff:
        function [result] = run_raw(this)
            % Perform raw measurement
            if ~this.isInitialized
                error('No initialization! -> No Measurement!')
            end
            if ~this.isOptimized
                ita_verbose_info('Optimization process not done! -> Using default values!', 0);
            end
            %-------------------------------------------------------------
            % Perform measurement:
            %-------------------------------------------------------------
            if this.sArgs_HRTFarc.continuous
                % Move back a few degrees:
                this.move_turntable(-20, 'absolut', true, 'speed', 20, 'wait', true);
                % Start continuous measurement:
                this.raw_measurement    =   this.runContinuousMeasurement(1);
                
                % Move back to zero position:
                this.move_turntable(0, 'absolut', true, 'speed', 10, 'wait', false);
                % Combine measurement result to one itaAudio:
                this.raw_measurement    =   merge(this.raw_measurement);
                result                  =   this.raw_measurement;
            else
                for idx = 1:this.sArgs_HRTFarc.MeasurementPositions
                    result(idx)         =   this.measurementSetup.crop(this.measurementSetup.deconvolve(this.runMeasurement(idx))); %#ok<AGROW>
                end
                this.move_turntable(0, 'absolut', true, 'speed', 10, 'wait', false);
                ins    =   numel(this.measurementSetup.inputChannels);
                outs   =   numel(this.measurementSetup.outputChannels);
                for idx = 1:ins
                    temp(idx)           =   merge(result.ch((1:outs)+(idx-1)*outs)); %#ok<AGROW>
                end
                result =   merge(temp);
            end
        end
        
        function [result] = run(this)
            % Run measurement:
            tic;
            %-------------------------------------------------------------
            result  =   this.run_raw;
            %-------------------------------------------------------------
            ita_verbose_info(['Duration of measurement: ' num2str(toc) ' seconds.'], 0);
            % Process result:
            toc
            %-------------------------------------------------------------
            result  =   this.process_result(result);
            %-------------------------------------------------------------
            ita_verbose_info(['Duration of processing: ' num2str(toc) ' seconds.'], 0);
            % Reset measurement:
            %-------------------------------------------------------------
            this.mLastMeasurement	=   0;
        end
        %----------------------------------------------------------------
        % Post-processing stuff:
        function result = process_result(this, result)
            %-------------------------------------------------------------
            % Apply window and deconvolve with reference measurement:
            %-------------------------------------------------------------
            result      =   this.process_result_crop(result);
            result      =   this.process_result_window_dec(result);
            %-------------------------------------------------------------
            % Shift middle to earposition:
            %-------------------------------------------------------------
            ear_d       =   [0.08 0.08];
            result      =   this.process_result_shift_center(result, 'eardistance', ear_d);
            %-------------------------------------------------------------
            % Transform to sperical harmonics, turn back, interpolate and
            % transform back to time domain:
            %-------------------------------------------------------------
            result      =   this.process_result_spherical(result, 'NMAX_measured', 30, 'NMAX_target', 47);
            %-------------------------------------------------------------
            % Shift back to head middle:
            %-------------------------------------------------------------
            result      =   this.process_result_shift_center(result, 'eardistance', -ear_d);
        end
        
        function result = process_result_crop(this, result)
            % Crop result:
            result      =   this.measurementSetup.crop(result);
            if max(size(result)) > 1
                result  =   merge(result);
                result  =   result.ch([1:3:result.nChannels 2:3:result.nChannels 3:3:result.nChannels]);
            end
        end
        
        function result = process_result_window_dec(this, result, varargin)
            % Evaluate motor switch, calculate measurement positions, apply
            % window and deconvolve with reference measurement:            
            variables       =   struct(...
                'offset_measurement'        ,   0               , ...
                'window'                    ,   [18 1 (round([0.002 0.003].*this.measurementSetup.samplingRate)+8)]     , ...
                'offsetpeak'                ,   10              , ... % end opening-slope of window n Samples before peak
                'secondwindow'              ,   false           , ...
                'IRstep'                    ,   20              , ...
                'rotation_axis_shift'       ,   [0 0 0]         , ...
                'shiftminimum'              ,   false           , ...
                'window_type'               ,   'geometric'     , ... % geometric, seperate, none
                'ins'                       ,   numel(this.measurementSetup.inputChannels)  , ...
                'motorchannel'              ,   this.measurementSetup.inputChannels(end)    , ...
                'use_saved_inverse'         ,   false            , ...
                'use_reference'             ,   true            , ...
                'freqRange'                 ,   [50 20000]      );
            variables = ita_parse_arguments(variables, varargin);
            %-------------------------------------------------------------
            % Calculate measurement positions:
            %-------------------------------------------------------------
            if this.sArgs_HRTFarc.continuous
                %final_positions     =   this.Calculate_measurement_positions(result, variables);
                %-------------------------------------------------------------
                % Get motor speed:
                %-------------------------------------------------------------
                % Read switch channels: (always the last channel!)
                motor               =   result.ch(result.nChannels/variables.ins*(variables.ins-1)+1:result.nChannels);
                result              =   result.ch(1:result.nChannels/variables.ins*(variables.ins-1));
                variables.ins = variables.ins -1;
                % Convert back to one channel:
                motor.timeData      =   reshape(motor.timeData, motor.nChannels * motor.nSamples, 1);
                % Generate sweep to undo the deconvolution: %TODO!!!!!!
                % WRONG SWEEP!!!!
                if ischar(this.measurementSetup.type)
                    sweep               =   ita_generate_sweep('fftdegree', this.measurementSetup.fftDegree);
                else
                    sweep               =   this.measurementSetup.type;
                end
                
                % Convolve with the sweep:
                motor               =   ita_convolve(motor, sweep, 'circular', true);
                % Correction for input latency:
                add_latency         =   this.measurementSetup.latencysamples - this.sArgs_HRTFarc.input_latency;
                motor               =   ita_time_shift(motor, add_latency,'samples');
                % Filter some trash:
                motor2              =   ita_mpb_filter(motor,[500 10000],'zerophase');
                % Search first 5 seconds for reference switch:
                deadarea = 5;
                [peakvalue, peakposition(1)] = max(abs(motor2.timeData));
                for idx = 2:100
                    killthisarea = max(1,peakposition(idx-1)-deadarea*motor2.samplingRate):min(peakposition(idx-1)+deadarea*motor2.samplingRate, motor2.nSamples);
                    motor2.timeData(killthisarea) = zeros(1, numel(killthisarea));
                    [value, peakposition(idx)] = max(abs(motor2.timeData)); %#ok<AGROW>
                    if value < 0.3*peakvalue
                        peakposition(idx) = []; %#ok<AGROW>
                        break;
                    end
                end
                peakposition = sort(peakposition);
                %temp                =   itaAudio;
                %temp.timeData       =   (motor2.timeData(1:5*motor.samplingRate));
                %impulse(1)          =   ita_start_IR(temp);
                % Search 350 degree until end for next switch signal:
                %temp_SP             =   round(impulse(1)/motor.samplingRate + 350/(this.measurementPositions.phi(2)/pi*180)* motor.samplingRate);
                %temp.timeData       =   (motor2.timeData(temp_SP+1:end));
                %impulse(2)          =   ita_start_IR(temp) + temp_SP;
                % Calculate speed:
                this.measured_speed =   360/((peakposition(2) - peakposition(1))/motor.samplingRate);
                %-------------------------------------------------------------
                % Calculate measurement positions:
                %-------------------------------------------------------------
                % Calculate startposition:
                startpos            =   -peakposition(1)/motor.samplingRate*this.measured_speed;
                % Calculate rotated coordinates:
                clear temp;
                total_degree = this.sArgs_HRTFarc.MeasurementPositions*this.measurementSetup.twait*this.sArgs_HRTFarc.Loudspeaker*this.measured_speed;
                
                for i = 1:this.sArgs_HRTFarc.MeasurementPositions
                    temp            =   this.LSpositions;
                    temp.r          =   1; % correction done with reference measurement!
                    temp.x          =   temp.x + variables.rotation_axis_shift(1); % correction of the axis. Should normaly not be necessary!
                    temp.y          =   temp.y + variables.rotation_axis_shift(2);
                    temp.z          =   temp.z + variables.rotation_axis_shift(3);
                    for j = 1:this.sArgs_HRTFarc.Loudspeaker
                        temp.phi(j) =   temp.phi(j) - ((i-1+variables.offset_measurement)*total_degree/this.sArgs_HRTFarc.MeasurementPositions + (j-1)*this.measurementSetup.twait*this.measured_speed + startpos)/180*pi;
                    end
                    if i >= 2
                        final_positions     =   merge(final_positions, temp);
                    else
                        final_positions     =   temp;
                    end
                end
            else %Not continuously:
                for i = 1:this.sArgs_HRTFarc.MeasurementPositions
                    temp            =   this.LSpositions;
                    temp.r          =   1; % correction done with reference measurement!
                    temp.x          =   temp.x + variables.rotation_axis_shift(1); % correction of the axis. Should normaly not be necessary!
                    temp.y          =   temp.y + variables.rotation_axis_shift(2);
                    temp.z          =   temp.z + variables.rotation_axis_shift(3);
                    for j = 1:this.sArgs_HRTFarc.Loudspeaker
                        temp.phi(j) =   temp.phi(j) - ((i-1)*2*pi/this.sArgs_HRTFarc.MeasurementPositions);
                    end
                    if i >= 2
                        final_positions     =   merge(final_positions, temp);
                    else
                        final_positions     =   temp;
                    end
                end
            end
            %-------------------------------------------------------------
            % Process data:
            %-------------------------------------------------------------
            % Read raw measurement data and cut to even sample number:
            
            if isempty(this.reference_measurement)
                reference   =   itaAudio;
                variables.use_reference = false;
            else
                if (this.reference_measurement.nChannels == variables.ins) || (this.reference_measurement.nChannels == variables.ins+1)
                    ita_verbose_info('Reference measurement not cropped - I will fix this for you...', 0);
                    reference =   this.process_result_crop(this.reference_measurement);
                else
                    reference   =   this.reference_measurement;
                end
                if this.sArgs_HRTFarc.continuous
                    reference   =   reference.ch(1:result.nChannels/variables.ins+1*(variables.ins-1));
                end
                if (reference.nChannels ~= result.nChannels)
                    ita_verbose_info('Reference Measurement: Channel number does not fit!', 0)
                    return;
                end
            end
            
            %-------------------------------------------------------------
            % Apply window:
            %-------------------------------------------------------------
            if strcmpi(variables.window_type, 'none')
                ita_verbose_info('No window applied!', 0);
            elseif strcmpi(variables.window_type, 'geometric')
                % Precalculate window position:
                window_local          =   this.get_geometric_window(final_positions);
                %window_local          = repmat([114   100   323   350], 40,1);
                for i = 1:size(window_local, 1)
                    pure_window(i,:)  =   ita_time_window(result(1).ch(1), window_local(i,:), 'samples', 'returnwindow'); %#ok<AGROW>
                end
                % Apply geometric window:
                result.timeData         =   bsxfun(@times, result.timeData, repmat(pure_window', 1, result.nChannels/size(window_local, 1)));                
                if variables.use_reference                    
                    reference.timeData          =   bsxfun(@times, reference.timeData, repmat(pure_window', 1, reference.nChannels/size(window_local, 1)));
                end
            else % Apply individual window:               
                % Look for impulse:                
                stpos               =   ita_start_IR(result, 'threshold', variables.IRstep);
                fenster             = stpos' * [1 1 1 1] + repmat(variables.window,  numel(stpos),1);
                for i = 1:size(fenster, 1)
                    pure_window(i,:) =  ita_time_window(result.ch(1), fenster(i,:), 'samples', 'returnwindow'); %#ok<AGROW>
                end
                result.timeData     =   bsxfun(@times, result.timeData, pure_window');
                if variables.use_reference
                    reference.timeData         =   bsxfun(@times, reference.timeData, pure_window');
                end                 
            end
            
            
            for i = 1:variables.ins
                % Split into channels and cut to even sample number:
                input_channel(i)            =   result.ch((result.nChannels/variables.ins*(i-1)+1):(result.nChannels/variables.ins*i)); %#ok<AGROW>
                input_channel(i).fftDegree  =   floor(input_channel(i).nSamples/2)*2; %#ok<AGROW>
                input_channel(i)            =   input_channel(i).ch((1:this.sArgs_HRTFarc.MeasurementPositions*this.sArgs_HRTFarc.Loudspeaker)+variables.offset_measurement*this.sArgs_HRTFarc.Loudspeaker); %#ok<AGROW>
            end
            
            if variables.use_reference
                % Split reference measurement and cut to even sample number:
                for i = 1:variables.ins
                    input_reference(i)            =   reference.ch((reference.nChannels/variables.ins*(i-1)+1):(reference.nChannels/variables.ins*i)); %#ok<AGROW>
                    input_reference(i).fftDegree  =   floor(input_reference(i).nSamples/2)*2; %#ok<AGROW>
                    input_reference(i)            =   input_reference(i).ch((1:this.sArgs_HRTFarc.MeasurementPositions*this.sArgs_HRTFarc.Loudspeaker)+variables.offset_measurement*this.sArgs_HRTFarc.Loudspeaker); %#ok<AGROW>
                end
            end
                       
            %-------------------------------------------------------------
            % Invert reference measurement:
            %-------------------------------------------------------------
            if variables.use_reference                
                %-------------------------------------------------------------
                % Select reference case: (1mic/1mic-n-positions/n-mics/n-mics-n-positions)
                %-------------------------------------------------------------
                % Check if we are allowed to use a stored inverse:
                if ~isempty(this.inverse_reference) && (this.inverse_reference.nChannels ~= 0)
                    input_reference =   this.inverse_reference;
                else
                    for i = 1:numel(input_reference)
                        input_reference(i) =   ita_invert_spk_regularization(input_reference(i), variables.freqRange); %#ok<AGROW>
                    end
                    
                    if (input_reference(1).nChannels == this.sArgs_HRTFarc.Loudspeaker)
                        % Only at one position
                        for i = 1:numel(input_reference)
                            
                        end
                    end
                    if numel(input_reference) == 1
                        % Only one reference channel at all positions
                        for i = 2:numel(input_channel)
                            input_reference(i) = input_reference(1); %#ok<AGROW>
                        end
                    end
                    % Store for later...:
                    this.inverse_reference = input_reference;
                end
                if (numel(input_reference) == numel(input_channel)) && (input_reference(1).nChannels == input_channel(1).nChannels)
                    % Deconvolve:
                    for i = 1:variables.ins
                        input_channel(i)    =   input_channel(i) * input_reference(i); %#ok<AGROW>
                        input_channel(i).freqData(1,:) = 1; %#ok<AGROW>
                    end
                else
                    ita_verbose_info('Something is wrong with the reference measurement!', 0);
                    return;
                end
            else
                %-------------------------------------------------------------
                % No reference measurement loaded. Throw warning and return
                % data without reference!
                %-------------------------------------------------------------
                ita_verbose_info('No reference data loaded. Returning data without reference!',0);
            end

            % Assign data and corrected positions:
            result                      =   input_channel;
            %this.HRTF                   =   input_channel;
            for i = 1:numel(result)
                result(i).channelCoordinates    =   final_positions;
                %this.HRTF                       =   final_positions;
            end
        end
        
        function result = process_result_shift_center(this, result, varargin)
            % Change origin of coordinate system:
            variables   =   struct('rotationshift', [0 0 0], 'eardistance', [0.06 0.11]);
            variables   =   ita_parse_arguments(variables, varargin);
            
            if numel(variables.eardistance) == 1 % if only one value then make it symmetric!
                variables.eardistance(2)    =   variables.eardistance(1);
            end
            
            %-------------------------------------------------------------
            % Shift center to ear position (or even further):
            % -------------------------------------------------------------
            result(1).channelCoordinates.x  =   result(1).channelCoordinates.x + variables.eardistance(1) + variables.rotationshift(1);
            result(1).channelCoordinates.y  =   result(1).channelCoordinates.y + variables.rotationshift(2);
            result(1).channelCoordinates.z  =   result(1).channelCoordinates.z + variables.rotationshift(3);
            result(2).channelCoordinates.x  =   result(2).channelCoordinates.x - variables.eardistance(2) + variables.rotationshift(1);
            result(2).channelCoordinates.y  =   result(2).channelCoordinates.y + variables.rotationshift(2);
            result(2).channelCoordinates.z  =   result(2).channelCoordinates.z + variables.rotationshift(3);
            result                          =   this.process_result_delay_correction(result, 1);
        end
        
        function result = process_result_delay_correction(this, result, target_d)
            % shift every measurement point to target_d by applying a
            % phase shift to the channel: (simplified!)
            freq_L              =   result(1).freqVector;
            freq_R              =   result(2).freqVector;
            
            add_phase_L         =   (result(1).channelCoordinates.r - target_d)* (freq_L./this.c_meas)' .* 2.*pi;
            add_phase_R         =   (result(2).channelCoordinates.r - target_d)* (freq_R./this.c_meas)' .* 2.*pi;
            result(1).freqData  =   result(1).freqData .* exp(1i.*add_phase_L');
            result(2).freqData  =   result(2).freqData .* exp(1i.*add_phase_R');
            
            result(1).channelCoordinates.r  =   target_d;
            result(2).channelCoordinates.r  =   target_d;
        end
        
        function result = process_result_spherical(this, result, varargin)
            % Decompose into SH-Base-Functions, compensate rotation and
            % transform back to freq-domain.
            
            %for i = 1:numel(result) % <- frag mich nicht warum ich hier sortiert habe... ich weiß es selber nimmer...
            %    % Sort for gaussian order:
            %    [~, vec]            =   sort(result(i).channelCoordinates.theta + result(i).channelCoordinates.phi/1000);
            %    HRTF_local(i)        =   result(i).ch(vec);
            %end
            %clear muell vec
            
            %--------------------------------------------------------------
            variables           =   struct( ...
                'NMAX_target'           ,   HRTF_L_local.nChannels / 40 / 2 -1  , ...
                'NMAX_measured'         ,   HRTF_L_local.nChannels / 40 / 2 -1  , ...
                'sampling'              ,   ita_sph_sampling_gaussian(0)        , ...
                'no_interpolation'      ,   false                               , ...
                'use_saved_inverse'     ,   true                                );
            variables           =   ita_parse_arguments(variables, varargin);
            if variables.sampling.nmax == 0
                variables.sampling  =   ita_sph_sampling_gaussian(variables.NMAX_target);
            end
            %--------------------------------------------------------------
            % Now spherical harmonics:
            %--------------------------------------------------------------
            % Make sure everything has the same distance:
            temp = 0;
            for i = 1:numel(result)
                temp = temp + sum(diff(result(i).channelCoordinates.r));
            end
            if temp < 0.0000001
                ita_verbose_info('Moving data to equal distance!', 0);
                result          =   this.process_result_delay_correction(result, 1);
            end
            %--------------------------------------------------------------
            % Create an itaSamplingSph:
            for i = 1:numel(result)
                s_measured(i)        =   itaSamplingSph(result(i).channelCoordinates.sph, 'sph'); %#ok<AGROW>
                s_measured(i).nmax   =   variables.NMAX_measured; %#ok<AGROW>
            end            
            %--------------------------------------------------------------
            % Calculte transformation matrix:
            
            % use previously calculated inverse:
            global inv_Y;
            if ~isempty(inv_Y) && variables.use_saved_inverse
                % nothing             
            else
                % Using Decomposition-order dependent Tikhonov regularization:
                epsilon         =   1*10^(-1);
                n               =   ita_sph_linear2degreeorder(1:(variables.NMAX_measured+1)^2);
                D               =   diag(1+(n.*(n+1)));
                for i = 1:numel(s_measured(i))
                    inv_Y{i}           =   ((s_measured(i).Y'*s_measured(i).Y + epsilon * D)\s_measured(i).Y');                
                end
            end
            
            %--------------------------------------------------------------
            % Transform into SH-Domain:
            for i = 1:numel(s_measured)
                spherical{i}         =   inv_Y{i}(:, 1:result(i).nChannels)*double((HRTF_L_local(i).freqData.'));%#ok<AGROW> %.*repmat(weightsvec', 1, HRTF_L_local.nBins)); 
            end
            %--------------------------------------------------------------
            if this.sArgs_HRTFarc.continuous
                % Compensate rotation: (Rotate x Degree)
                sweep_rate          =   log2(this.sArgs_HRTFarc.freq_range(2)/this.sArgs_HRTFarc.freq_range(1))/(2^this.measurementSetup.fftDegree/this.measurementSetup.samplingRate);
                degree              =   log2(result(1).freqVector./this.sArgs_HRTFarc.freq_range(1))./sweep_rate.*this.measured_speed/180*pi;
                degree(1)           =   0; % Otherwise it would be -inf which is wrong!
                % Todo: needs speedup!
                for i=1:HRTF_local.nBins
                    for j = 1:numel(s_measured);
                        spherical{j}(:, i)   =   ita_sph_zrotT(degree(i), s_measured(i).nmax) * spherical{j}(:,i); %#ok<AGROW>
                    end
                end
            end
            %--------------------------------------------------------------
            % Transformiere zurück auf ein gaussian sampling inkl.
            % interpolation der fehlenden unteren LS:
            
            % transfer back to measured grid:
            if variables.no_interpolation
                for i = 1:numel(s_measured);
                    this.HRTF_sph(i).freqData            =   (s_measured(i).Y*spherical{i}).';
                    this.HRTF_sph(i).channelCoordinates  =   itaCoordinates(s_measured(i));                
                end
            else
                for i = 1:numel(s_measured);
                    spherical{i}    =   [spherical{i}(1:min(size(variables.sampling.Y,2), size(spherical{i}, 1)), :); zeros(size(variables.sampling.Y,2) - size(spherical{i}, 1), size(spherical{i}, 2))]; %#ok<AGROW>
                    this.HRTF_sph(i).freqData            =   (variables.sampling.Y*spherical{i}(1:size(variables.sampling.Y,2),:)).';
                    this.HRTF_sph(i).channelCoordinates  =   itaCoordinates(variables.sampling);
                end
            end
            
            result              =   this.HRTF_sph;
        end
        %----------------------------------------------------------------
        % Export functions:
        function export_DAFF(this, result, filename, varargin)
            % Export result with 2 itaAudio-Objects to DAFF-File:
            
            if (max(size(filename)) < 0)
                error('Filename not set!')
            end
            try
                values          =   struct(...
                    'phires'    ,   3.75        ,...
                    'thetares'  ,   7.5         ,...
                    'phirange'  ,   [0 360]     ,...
                    'thetarange',   [min(180-result(1).channelCoordinates.theta/pi*180) 180]    ,...
                    'channels'  ,   2           ,...
                    'spherical_interpolation' ,   true);
                values          =   ita_parse_arguments(values,varargin);
                if size(result, 2) ~= values.channels
                    error('Wrong input!')
                end
                if values.spherical_interpolation
                    s           =   ita_sph_sampling_equiangular(360/values.phires, 360/values.thetares);
                    result      =   this.process_result_spherical(result, s);
                    % Create empty daff-set:
                    dataset     =   daff_create_dataset(      ...
                        'alphares'  ,   values.phires   , ...
                        'betarange' ,   360             , ...
                        'betares'   ,   values.thetares , ...
                        'channels'  ,   2               );
                else
                    % Create empty daff-set:
                    dataset     =   daff_create_dataset(      ...
                        'alphares'  ,   values.phires   , ...
                        'betarange' ,   round(values.thetarange)    , ...
                        'betares'   ,   values.thetares , ...
                        'channels'  ,   2               );
                end
                % Set sample rate:
                dataset.samplerate      =   result(1).samplingRate;
                % Set some metainformation:
                dataset.metadata.desc   =   'HRIR_Nearest_Neighbor';
                % Now add the data to the daff:
                for i=1:dataset.numrecords
                    phi         =   dataset.records{i}.alpha/180*pi;
                    theta       =   pi-dataset.records{i}.beta/180*pi;
                    [~, idx]    =   min(sqrt(min((result(1).channelCoordinates.phi-phi).^2, (result(1).channelCoordinates.phi-2*pi-phi).^2) + (result(1).channelCoordinates.theta-theta).^2));
                    
                    % Finally store the data in the dataset
                    dataset.records{i}.data     =   [result(1).ch(idx).timeData result(2).ch(idx).timeData]';
                end
                if ~strcmpi(filename(end-5:end), '.daff')
                    filename            =   [filename '.daff'];
                end
                daff_write('filename', filename, ...
                    'content', 'IR', ...
                    'dataset', dataset, 'verbose');
            catch %#ok<CTCH>
                error('Something went wrong. Maybe OpenDAFF is not in your path!')
            end
        end
        
        %----------------------------------------------------------------
        % Other (maybe useless) stuff:
        function gui(this) %#ok<MANU>
            %call ita italian GUI
            %ita_italian_gui(this) (old!)
            error('There is no GUI - sorry! But you can build one if you like!')
        end
        
    end %methods
    % *********************************************************************
    % *********************************************************************
    methods(Hidden = true)       
        function [geometric_window] = get_geometric_window(this, final_positions, varargin)
            % Calculate window depending on the geometric dimensions of the
            % setup:
            variables               =   struct(                   ...
                'h_floor'               ,   1.3         , ...% Distance Origin-Turntable
                'h_ceiling'             ,   1.6         , ... % Distance Origin-Ceiling
                'd_wall_left'           ,   2           , ... % Distance Origin-Wall_left
                'd_wall_right'          ,   3           , ... % Distance Origin-Wall_right
                'd_wall_front'          ,   1.6         , ... % Distance Origin-Wall_front
                'd_wall_back'           ,   2           , ... % Distance Origin-Wall_back
                'opentime_before_peak'  ,   0.3/1000    , ... % in ms
                'windowtime_wanted'     ,   2.5/1000    , ... % Open after peak
                'fade_time_in'          ,   0.3/1000  , ... % in ms
                'fade_time_out'         ,   0.3/1000  , ... % in ms
                'sample_rate'           ,   44100       );
            
            variables = ita_parse_arguments(variables, varargin);
            
            pos_middle          =   final_positions.n(1:this.sArgs_HRTFarc.Loudspeaker);
            % Calculate Floor:
            pos_floor           =   pos_middle;
            pos_floor.z         =   (pos_floor.z + 2*variables.h_floor).* -1;
            % Ceiling
            pos_ceiling         =   pos_middle;
            pos_ceiling.z       =   (pos_ceiling.z - 2*variables.h_ceiling).* -1;
            % Wall 1: (right)
            pos_wall_right      =   pos_middle;
            pos_wall_right.x    =   (pos_wall_right.x - 2*variables.d_wall_left) .* -1;
            % Wall 2: (left)
            pos_wall_left       =   pos_middle;
            pos_wall_left.x     =   (pos_wall_left.x + 2*variables.d_wall_right) .* -1;
            % Wall 3: (front)
            pos_wall_front      =   pos_middle;
            pos_wall_front.y    =   (pos_wall_front.y - 2*variables.d_wall_front) .* -1;
            % Wall 4: (back)
            pos_wall_back       =   pos_middle;
            pos_wall_back.y     =   (pos_wall_back.y + 2*variables.d_wall_back) .* -1;
            clear reflexion
            % Now calculate reflexion distance for each wall/ceiling/floor:
            reflexion(1,:)      =   pos_floor.r - pos_middle.r;
            reflexion(2,:)      =   pos_ceiling.r - pos_middle.r;
            reflexion(3,:)      =   pos_wall_front.r - pos_middle.r;
            reflexion(4,:)      =   pos_wall_left.r - pos_middle.r;
            reflexion(5,:)      =   pos_wall_right.r - pos_middle.r;
            reflexion(6,:)      =   pos_wall_back.r - pos_middle.r;
            % Calculate shortest distance and therefore the earliest
            % reflexion:
            maxwindowtime       =   min(reflexion)./this.c_meas*variables.sample_rate; % maximum window length calculated from geometric!
            
            peakposition        =   pos_middle.r./this.c_meas*variables.sample_rate;
            % Calculate window:
            clear window_local
            window_local(:,1)   =   peakposition - variables.opentime_before_peak*variables.sample_rate;
            window_local(:,2)   =   peakposition - variables.opentime_before_peak*variables.sample_rate - variables.fade_time_in*variables.sample_rate;
            window_local(:,3)   =   peakposition + min(variables.windowtime_wanted*variables.sample_rate, maxwindowtime-variables.fade_time_out*variables.sample_rate)';
            window_local(:,4)   =   peakposition + min(variables.windowtime_wanted*variables.sample_rate+variables.fade_time_out*variables.sample_rate, maxwindowtime*variables.sample_rate)';
            geometric_window    =   round(window_local);
        end
        
        function [RIR] = measure_revtime(this)
            % Measure the room impulse response for each loudspeaker:            
            MS                          =   itaMSTFinterleaved;
            MS.outputMeasurementChain   =   this.measurementSetup.outputMeasurementChain;
            MS.inputMeasurementChain    =   this.measurementSetup.inputMeasurementChain;
            MS.outputamplification      =   this.measurementSetup.outputamplification;
            MS.outputChannels           =   this.measurementSetup.outputChannels;
            MS.inputChannels            =   this.sArgs_HRTFarc.inputchannels_reference;
            MS.fftDegree                =   this.measurementSetup.fftDegree;
            MS.twait                    =   2.^(this.measurementSetup.fftDegree)./this.sArgs_HRTFarc.samplingRate; % Do not overlap/interleave!!
            MS.latencysamples           =   this.measurementSetup.latencysamples;
            MS.freqRange                =   this.measurementSetup.freqRange;
            MS.shelving                 =   this.sArgs_HRTFarc.shelving_filter;
            MS.repititions              =   2;
            
            RIR                         =   MS.run;
        end
        
        function err = fehler2(this, x, r)
            % x: optimized Position of Loudspeakers + Latency + Micdistance + Angle + Speed of sound
            % M: Koordinates of the microphones
            % r: Distance Microphone-Loudspeaker incl. latence!
            
            % Assign new variable names for better reading:
            Latenz  =   x((end-8:end-4));
            d       =   x(end-2);
            beta    =   x(end-1);
            gamma   =   x(end-3);
            % Calculate position of the microphones:
            dy      =   sin(beta)*d;
            dz      =   -cos(beta)*d;
            ax      =   sin(gamma)*0.2;
            ay      =   cos(beta)*cos(gamma)*0.2;
            az      =   sin(beta)*cos(gamma)*0.2;
            % Now assign the microphone positions: (Assuming equaly spaced rotation e.g. positions 0°,90°,180° and 270°
            for i = 1:2:size(r,2)
                phi         =   2*pi/size(r,2)*(i-1);
                M(:,i)      =   [cos(phi)*ax-sin(phi)*(dy+ay); cos(phi)*(dy+ay)+sin(phi)*ax; dz+az]; %#ok<AGROW>
                M(:,i+1)    =   [-cos(phi)*ax-sin(phi)*(dy-ay); cos(phi)*(dy-ay)-sin(phi)*ax; dz-az]; %#ok<AGROW>
            end
            % Allocate memory:
            err     =   ones(size(r,1)*size(M,2),1);
            % Run error calculation:
            for j = 1:(size(r, 1))
                for i = 1:(size(M, 2))
                    err((j-1)*size(M,2)+i)  =   (sqrt(sum((x((1:3)+(j-1)*3)'-M(:,i)).^2)) - (r(j,i)-Latenz(ceil(j/8))/this.measurementSetup.samplingRate)*x(end));
                end
            end
        end
        
        function reference_LS_hidden(this)
            %-------------------------------------------------------------
            % Perform reference measurement: (rotating!)
            %-------------------------------------------------------------
            % Delete old inverse reference - we are measureing a new one!
            clear global inv_ref;
            % Save raw measurement to another variable:
            temp                        =   this.raw_measurement;
            % Run measurement:
            this.run_raw;
            % Crop measurement and assign to reference measurement variable:
            this.reference_measurement  =   this.process_result_crop(this.raw_measurement);
            % Reassign the old raw measurement to raw_measurement:
            this.raw_measurement        =   temp;
        end
    end
end
