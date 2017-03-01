classdef itaMSTF_NLMS < itaMSTF
    % This is a class for Transfer Function measurements with novel
    % NLMS method. It is particulary made for
    % 3D - continuous-azimuth acquisition of Head-Related Impuls Responses using multichannel
    % adaptive filtering.
    
    
    % Instructions for a nice result:
    % 1. define the measurement data (fftDegree, samplingRate, outputamplification, T360 etc.)
    % 2. (optional) run a referece measurement and save the result
    % 3. run the NLMS measurement
    % 4. define a grid with the greatcircle_grid function
    % 5. Process the headtracker data of the measurement as described in the doNLMS function
    % 6. run the NLMS algorithm
    % 7. enjoy !!
    
    % It is recommended to have a look at the measure_itaMSTF_NLMS skript to get a better overview/idea
    % how to use this class
    
    
    % Authors: Alexander Fu?, Fabian Brinkmann, Mina Fallahi
    % TU Berlin, audio communication group, 2013
    
    
    properties(Access = protected)
        mFinalExcitation = [];           % Final data
        
    end
    
    properties(Access = public, Hidden = false)
        T360            = 1;            % Revolution time in sec
        Tadapt          = 0;
        sweepNfft;                      % sweeplength in samples
        NstopMargin;                    % stopMargin in Samples
        inputRef        = 1;            % inputchannel for the reference measurement (only one channel)
        inputMeasure    = 1:2;          % inputchannels for the measurment (should be 2 channels for HRTF measurement)
        Tbegin;                         % serial time data -> time the measurement began
        Tend;                           % serial time data -> time the measurment was finished
        el              = -90:5:90;     % vector containing all elevation in degree (row- or column-vector) for the grid
        max_ang         = 4;            % maximum great circle distance between to neighboring points of the same elevation in the grid
        fit             = 90;           % great circle distance is choosen to include a point each 'fit' degrees. If fit = 90, median and frontal plane are included in the grid (default = 90)
        ch2elMap        = [];           % a vector with elevations corresponding to the channelnumber
        mu              = 1;
    end
    
    properties(Dependent = true)
        %sweepNfft % sweeplength in samples
        %NstopMargin % stopMargin in Samples
    end
    %...
    
    methods
        
        %% CONSTRUCT
        
        function this = itaMSTF_NLMS(varargin)
            % itaMSTFinterleaved - Constructs an itaMSTFinterleaved object.
            %
            % This function formally constructs a new itaMSTF_NLMS
            % class object, although it actually only does the exception
            % handling for the case that an input arguemnt is given. The
            % construction of the class object itself is being done by the
            % Matlab class handler, according to the list of properties in
            % this class and its parent class.
            
            % Create itaMSTF class object as base for the
            % itaMSTFinterleaved object.
            %             this = this@itaMSTF(varargin{:});
            
            % Given input arguments have to be structs created with the
            % saveobj method or itaMSTF_NLMS objects.
            
            if nargin == 1
                
                % Standard itaMSTF objects cannot be converted.
                % Keep in mind  that isa(... 'itaMSTF') will always be true for
                % itaMSTF_NLMS objects, since they are derived from
                % the itaMSTF class, so just testing for that doesn't work
                % too well.
                if isa(varargin{1},'itaMSTF') && ~isa(varargin{1}, 'itaMSTF_NLMS')
                    error('Conversion from itaMSTF to itaMSTF_NLMS is not allowed');
                    
                    % The list of to be saved properties of the given
                    % itaMSTF_NLMS object can be obtained by using the
                    % propertiesSaved method.
                    % Try to copy all the properties over to the new
                    % itaMSTFinterleaved object.
                elseif isa(varargin{1}, 'itaMSTF_NLMS')
                    prop = this.propertiesSaved;
                    for idx = 1:length(prop)
                        this.(prop{idx}) = varargin{1}.(prop{idx});
                    end
                    f
                    % The struct created by the saveobj method contains
                    % list of saved properties in its first field.
                    % Since the propertiesSaved field is the first in the save
                    % struct, try to copy all the properties, starting with
                    % element 2 in the list, over to the new itaMSTF_NLMS
                    % object.
                elseif isstruct(varargin{1})
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                    fieldName = fieldnames(varargin{1});
                    for ind = 2:numel(fieldName);
                        try this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg; disp(errmsg);
                        end
                    end
                end
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            
            
            addlistener(this,'outputChannels','PreSet',@this.init);
        end
        
        %% INIT
        function init(this,varargin)
            % init - Initialize the itaMSTF class object.
            %
            % This function initializes the itaMSTF class object by
            % deleting its excitation, causing the excitation to be built
            % anew, according to the properties specified in the
            % measurement setup, the next time it is needed.
            
            ita_verbose_info('MeasurementSetup::Initializing...',1)
            this.excitation = itaAudio;
            this.mFinalExcitation = [];
            this.compensation = [];
        end
        
        %% SPECIAL PROPERTIES
        
        
        
        %% NLMS
        
        function result = calculate_excitation(this)
            % this function calculates the exitation signal for
            % multichannel NLMS measurement
            
            this.checkready; % input/output Channels set?
            if strcmp(this.mType,'perfect')~=1
                error(['itaMSTF_NLMS: the exitation signal must be a perfect sweep: mType = ''perfect''.'])
            end
            % calculate new sweeplength in samples
            this.sweepNfft   = this.mNSamples*length(this.outputChannels);
            disp(['itaMSFT_NLMS: new sweeplength is now:', num2str(this.sweepNfft), ...
                '(mNSamples * number of output channels)'] );
            % generate perfect sweep
            perfectSweep_raw = ita_generate_sweep('mode',this.type,'fftDegree',this.sweepNfft,...
                'samplingRate',this.samplingRate,'stopMargin',0,...
                'bandwidth',this.bandwidth,'gui',false);
            
            
            
            % calculate measurement duration in samples N
            N=this.samplingRate*this.T360+this.Tadapt;
            % arrange sweep for measurament
            repeat = floor(N/this.sweepNfft);
            Total_length = this.T360*this.samplingRate + this.Tadapt;
            rest = Total_length - repeat*this.sweepNfft;
            x = repmat(perfectSweep_raw.timeData, repeat+1,1);
            
            % create sweepmatrix with the exitation signals for multichannel
            % NLMS measurement
            XMulti = zeros(length(x),length(this.outputChannels));
            for i = 1 : length(this.outputChannels)
                XMulti(:,i) = circshift(x,(i-1)*this.mNSamples);
            end
            
            % cut sweepmatrix
            XMulti=XMulti(1:end-(this.sweepNfft-rest),:);
            
            % stopMargin (time) -> NstopMargin (samples)
            this.NstopMargin=round(this.stopMargin*this.samplingRate);
            XMulti=[XMulti; zeros(this.NstopMargin,length(this.outputChannels))]; %Measurement length in samples is now: this.samplingRate*this.T360+this.Tadapt+this.NstopMargin
            result=itaAudio;
            result.time=XMulti;
            
        end
        
        
        function res = get_final_excitation(this)
            % get the excitation signal
            
            % if isempty(this.mFinalExcitation)
            res  = this.calculate_excitation; %not greater than 0dBFS
            this.mFinalExcitation = res;
            % end
            res = this.mFinalExcitation .*  this.pre_scaling .* this.outputamplification_lin;
        end
        
        
        function [h_fin1, h_fin2] = doNLMS(this, varargin)
            %this funktion performs the NLMS algorithm
            noRef                     = 0
            refResult1                = itaAudio;
            refResult2                = itaAudio;
            measurementResult         = itaAudio;
            hrtf_grid                 = itaCoordinates;
            %% INITS
            sArgs = struct(...
                'refResult1',refResult1,...
                'refResult2',refResult2,...
                'measurementResult', measurementResult,...
                'hrtf_grid',hrtf_grid,...
                'HT_Data',0,...   % the headtracker data has to have the same samplingrate as the measurement result and should start at Tbegin+Tadapt. the length should be T360*samplingrate
                'ch2elMap',10000,... % Mapping of the channels to there corresponding elevation angle
                'shiftValue',0,... % optional circshift parameter for the measurement result y
                'mu',1);
            
            %input parsing
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            if sArgs.refResult1.trackLength==0 || sArgs.refResult2.trackLength==0
                
                sArgs.refResult1=get_final_excitation(this);% take the exitation signal for further calculations
                sArgs.refResult2=get_final_excitation(this);
                noRef                     =1;
                disp('itaMSTF_NLMS|doNLMS : At least one reference measurement is missing. Using exitation signal for both channels in stead of reference measurement for NLMS algorithm');
                warning(['itaMSTF_NLMS|doNLMS : you are using the exitation signal instead of the reference measurement result.'...
                    'To get reliable results you should run two reference measurements (one for each channel) and pass its outcome to this function (just a hint)']);
            end
            
            if sArgs.measurementResult.trackLength==0 % if there is no reference Measurement...
                error(['itaMSTF_NLMS|doNLMS needs the Measurement results of runNLMS_measurment to run the NLMS algorithm'...
                    ' | run  [result max_rec_lvl] = runNLMS_measurment(this) and pass its outcome as ''measurementResult'' to this function'])
            end
            
            if sArgs.hrtf_grid.nPoints==0 % HRTF Grid is necessary
                error('itaMSTF_NLMS|doNLMS : No grid. please use greatcircle_grid function to generate a grid  and pass its outcome as ''hrtf_grid'' to this function ');
            end
            
            if sArgs.HT_Data==0 % HRTF Grid is necessary
                error('itaMSTF_NLMS|doNLMS : No Head-Tracker data.');
            end
            
            if sArgs.ch2elMap==10000 % HRTF Grid is necessary
                error(['itaMSTF_NLMS|doNLMS : No ch2elMap. That is an array with the length of your channelnumberwith a Mapping of the channels to there corresponding elevation angle'...
                    'e.g. ch2elMap=[-30 -20 -10 0 10 20 30] for 7 channels'  ]);
            end
            
            % define variables
            
            Nfft    = this.mNSamples; % sweeplength before multiplying with the number of channels
            y1      = sArgs.measurementResult.time(:,1); % result of the NLMS measurement: ch1
            y2      = sArgs.measurementResult.time(:,2); % result of the NLMS measurement: ch2
            if sArgs.shiftValue ~=0 % perform optional circshift of the measurement data
                y1      = circshift( y1,sArgs.shiftValue);
                y2      = circshift( y2,sArgs.shiftValue);
            end
            Ref1    = sArgs.refResult1.time; % result of the reference measurement: ch1
            Ref2    = sArgs.refResult2.time; % result of the reference measurement: ch2
            
            mu      = sArgs.mu  % stepsize factor of the NLMS algorithm
            ch2elMap= sArgs.ch2elMap; % order of the loudsprecker-elevations
            grid    = sArgs.hrtf_grid;
            HT_Data = sArgs.HT_Data; % Head-Tracker data with T360*this.samplingrate azimuth angles
            
            
            h1      = zeros(Nfft,length(this.outputChannels)); % preallocate memory
            h2      = zeros(Nfft,length(this.outputChannels)); % preallocate memory
            X1      = zeros(Nfft,length(this.outputChannels)); % preallocate memory
            X2      = zeros(Nfft,length(this.outputChannels)); % preallocate memory
            result1  = zeros(Nfft,length(grid.elevation)); % preallocate memory
            result2  = zeros(Nfft,length(grid.elevation)); % preallocate memory
            
            % determine the saving destinations depending on the channel
            % elevations positions and the grid
            for i=1:length(ch2elMap)
                el_idxArray{i}=find(round(grid.elevation)==ch2elMap(i));
                for j=1:length(el_idxArray{i})
                    [~, idx]=min(abs(HT_Data-grid.azimuth(el_idxArray{i}(j))));
                    save_h_idx_el{i}(j)=idx;
                end
            end
            
            wb = itaWaitbar(length(y1)/1000,'calculating NLMS result')
            for k = 1 : length(y1) % calulation for every sample of the measurement (number of samples of the hole measurement: T360*samplingrate*Nstopmargin)
                if ~mod(k-1, 1000)
                    wb.inc
                end
                nm = max([1 k-Nfft+1]);
                nt = min([k, Nfft]);
                X1(1:nt,:) = Ref1(k:-1:nm,:);
                X2(1:nt,:) = Ref2(k:-1:nm,:);
                
                y_hat1 = 0;
                y_hat2 = 0;
                pp1 = 0;
                pp2 = 0;
                
                % start of the actual NLMS algorithm
                for j = 1 : length(this.outputChannels)
                    y_hat1  = y_hat1 + h1(:,j)'*X1(:,j);
                    y_hat2  = y_hat2 + h2(:,j)'*X2(:,j);
                    pp1     = pp1 + X1(:,j)'*X1(:,j);
                    pp2     = pp1 + X2(:,j)'*X2(:,j);
                end
                
                e1 = y1(k) - y_hat1;
                e2 = y2(k) - y_hat2;
                
                for j = 1 : length(this.outputChannels)
                    if pp1 ~= 0 || pp2 ~= 0
                        h1(:,j) = h1(:,j) + mu*e1*X1(:,j)/pp1;
                        h2(:,j) = h2(:,j) + mu*e2*X2(:,j)/pp2;
                    else
                        h1(:,j) = h1(:,j) + mu*e1*X1(:,j);
                        h2(:,j) = h2(:,j) + mu*e2*X2(:,j);
                    end
                    
                    
                end
                
                % start saving when filter adaption is over
                if k>this.Tadapt
                    knew=k-this.Tadapt;
                    
                    for o=1:length(save_h_idx_el)
                        for s=1:length(save_h_idx_el{o})
                            if knew==save_h_idx_el{o}(s)
                                result1(:,el_idxArray{o}(s))=h1(:,o);
                                result2(:,el_idxArray{o}(s))=h2(:,o);
                            end
                        end
                    end
                end
            end
            
            h_fin1=result1;
            h_fin2=result2;
            
        end
        
        function [h_fin1, h_fin2] = doNLMS_fast(this, varargin)
            %this funktion performs the NLMS algorithm using a compiled mex
            %file
            %It is recommended to use this function instead of doNLMS, it is
            %about 100 times faster.
            %
            %If possible use a CPU that supports SSE 4.2
            
            %TODO which unit is Tadapt in?
            %Is it seconds?  In htis case must calculate Tadapt = Tadapt*Fs
            %!!!
            
            noRef                     = 0;
            refResult1                = itaAudio;
            refResult2                = itaAudio;
            measurementResult         = itaAudio;
            usedExcitation            = itaAudio;
            hrtf_grid                 = itaCoordinates;
            %% INITS
            sArgs = struct(...
                'refResult1',refResult1,...
                'refResult2',refResult2,...
                'measurementResult', measurementResult,...
                'hrtf_grid',hrtf_grid,...
                'HT_Data',0,...   % the headtracker data has to have the same samplingrate as the measurement result and should start at Tbegin+Tadapt. the length should be T360*samplingrate
                'ch2elMap',10000,...  % Mapping of the channels to there corresponding elevation angle
                'shiftValue',0,... % optional circshift parameter for the measurement result y
                'usedExcitation',usedExcitation,...
                'mu',1);
            
            %input parsing
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            if sArgs.refResult1.trackLength==0 || sArgs.refResult2.trackLength==0
                disp('itaMSTF_NLMS|doNLMS : At least one reference measurement is missing. Using exitation signal for both channels in stead of reference measurement for NLMS algorithm');
                warning('ref:type', 'itaMSTF_NLMS|doNLMS : you are using the exitation signal instead of the reference measurement result.');
                pause(.1);
                if sArgs.usedExcitation.trackLength~=0
                    sArgs.refResult1=sArgs.usedExcitation;
                    sArgs.refResult2=sArgs.usedExcitation;
                else
                    sArgs.refResult1=get_final_excitation(this);% take the exitation signal for further calculations
                    sArgs.refResult2=sArgs.refResult1;
                end
                noRef                     =1;
            end
            
            
            if sArgs.measurementResult.trackLength==0 % if there is no reference Measurement...
                error(['itaMSTF_NLMS|doNLMS needs the Measurement results of runNLMS_measurment to run the NLMS algorithm'...
                    ' | run  [result max_rec_lvl] = runNLMS_measurment(this) and pass its outcome as ''measurementResult'' to this function'])
            end
            
            if sArgs.hrtf_grid.nPoints==0 % HRTF Grid is necessary
                error('itaMSTF_NLMS|doNLMS : No grid. please use greatcircle_grid function to generate a grid  and pass its outcome as ''hrtf_grid'' to this function ');
            end
            
            if sArgs.HT_Data==0 % HRTF Grid is necessary
                error('itaMSTF_NLMS|doNLMS : No Head-Tracker data.');
            end
            
            if sArgs.ch2elMap==10000 % HRTF Grid is necessary
                error(['itaMSTF_NLMS|doNLMS : No ch2elMap. That is an array with the length of your channelnumberwith a Mapping of the channels to there corresponding elevation angle'...
                    'e.g. ch2elMap=[-30 -20 -10 0 10 20 30] for 7 channels'  ]);
            end
            
            % define variables
            
            Nfft    = this.mNSamples; % sweeplength before multiplying with the number of channels
            Tadapt = this.Tadapt;
            y1      = single(sArgs.measurementResult.time(:,1)); % result of the NLMS measurement: ch1
            y2      = single(sArgs.measurementResult.time(:,2)); % result of the NLMS measurement: ch2
            if sArgs.shiftValue ~=0 % perform optional circshift of the measurement data
                y1      = circshift( y1,sArgs.shiftValue);
                y2      = circshift( y2,sArgs.shiftValue);
            end
            Ref1    = single(sArgs.refResult1.time); % result of the reference measurement: ch1
            Ref2    = single(sArgs.refResult2.time); % result of the reference measurement: ch2
            mu      = single(sArgs.mu); % stepsize factor of the NLMS algorithm
            ch2elMap= sArgs.ch2elMap; % order of the loudsprecker-elevations
            grid    = [sArgs.hrtf_grid.azimuth sArgs.hrtf_grid.elevation];
            HT_Data = sArgs.HT_Data; % Head-Tracker data with T360*this.samplingrate azimuth angles
            
            clear sArgs
            
            %debugOut('Mapping grid');
            % Use sensor data to align grid with measurement data
            % and extract the time signal indixes
            % also make sure there are no saves in the adaption time
            
            %  To map the azimuth degrees to azimuth indices
            %  a list of all the unique degrees is created,
            %  mapped to the corresponding indices
            %  and this list then used as a lookup table
            %  This significantly speeds up the process
            
            grid2 = zeros(size(grid));
            
            %create unique list of azimuths
            azimListDegree = unique(grid(:,1));
            azimListIdx = zeros(size(azimListDegree));
            
            % Make sure sensor data is modulo 360
            sensor_data  = mod(HT_Data,360);
            
            %Map degree to idx
            for i=1:size(azimListDegree)
                [~,idx] = min(abs(sensor_data-azimListDegree(i)));
                azimListIdx(i) = idx-1+Tadapt;
            end
            
            %Sort list of azimuth indices
            [azimListIdx, sort_id] = sort(azimListIdx);
            azimListDegree = azimListDegree(sort_id);
            
            %use azimListIdx to map whole grid
            for i = 1:size(grid(:,1))
                
                %map azimuth degrees to idx
                f = find(azimListDegree == grid(i,1));
                grid2(i,1) = azimListIdx(f(1));
                
                %map elevation degree to channel number
                grid2(i,2) =  find(round(grid(i,2)) == ch2elMap)-1;
                
            end
            
            %clear variables not used anymore to save ram
            clear t sensor_data azim azimListDegree idx i ch2elMap Tadapt
            
            disp 'Calculating HRIRs'
            pause(.01)
            
            % new version needs libgomb dll to work
            [h_fin1,h_fin2] = nlms_sp_multithread_unroll_SSE(y1',y2',Ref1, uint32(Nfft),mu,uint32(azimListIdx),uint32(grid2));
            
        end
        
        
        %% RUN
        
        
        function [result] = runReference(this)
            % run - Run NLMS measurement.
            %
            % This function runs a measurement, using only
            % one channel at a time. The exitation signal used in this
            % reference measurement is the same as in the actual
            % NLMS measurement.
            % The result can be used in the NLMS algorithm.
            
            XMulti             = get_final_excitation(this);
            tempExitation      = itaAudio;
            resultTemp         = itaAudio;
            XMultiRef          = zeros(length(XMulti.time(:,1)),numel(this.outputChannels));
            this.inputChannels = this.inputRef;
            for idx = 1:numel(this.outputChannels)
                tempExitation.time = XMulti.time(:,idx);
                resultTemp(idx)    = ita_portaudio(tempExitation,'inputChannels',this.inputChannels(1),'outputChannels',this.outputChannels(idx));
                XMultiRef(:,idx)   = resultTemp(idx).time;
            end
            
            result         = itaAudio;
            result.time    = XMultiRef;
            
            this.mFinalExcitation = [];
        end
        
        
        function [result max_rec_lvl] = runNLMS_measurment(this)
            % run - Run NLMS measurement.
            %
            % This function runs a standard NLMS measurement, using
            % the run_raw_imc function (in itaMSRecord).It only regards the
            % input chain properties, thus yielding the unaltered measurement
            % signal present at the receiving position.
            % The result will be used in the NLMS algorithm.
            
            %specify inputchannel for NLMS measurement
            this.inputChannels=this.inputMeasure;
            [result, max_rec_lvl] = run_raw_imc(this);
            
        end
        
        
        function [result max_rec_lvl] = runNLMS_measurment2(this, varargin)
            % Run NLMS measurement
            % this funktion performs the NLMS algorithm
            NLMSexcitation = itaAudio;
            %% INITS
            sArgs = struct(...
                'NLMSexcitation',NLMSexcitation);
            %input parsing
            sArgs = ita_parse_arguments(sArgs,varargin);
            if sArgs.NLMSexcitation.trackLength==0
                %if no excitation array has been given -> do it the old
                %fashion way
                warning('calculating excitation signal from scratch');
                this.inputChannels=this.inputMeasure;
                [result, max_rec_lvl] = run_raw_imc(this);
            else
                % use given excitation array
                NLMSexcitation=sArgs.NLMSexcitation;
                
                % if Anzahl der kan?le von NLMSexcitation ist ungleich
                % anzahl der outputchannels -> Error
                
                if size(NLMSexcitation.time,2)~=size(this.outputChannels,2)
                    error('itaMSTF_NLMS:runNLMS_measurment2:wrongChannelNumber: Number of outputChannels and channelnumer of the exitation array must be the same')
                end
                
                this.checkready;
                singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
                
                this.inputChannels=this.inputMeasure;
                
                result = ita_portaudio(NLMSexcitation,'InputChannels',this.inputChannels, ...
                    'OutputChannels', this.outputChannels,'repeats',1,...
                    'latencysamples',this.latencysamples,'singleprecision',singleprecision,'reset', this.reset);
                
                max_rec_lvl = max(abs(result.timeData),[],1);
                
            end
            
        end
        

        
        %% SAVE/LOAD
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a sturct.
            %
            % This function gets the list of to be saved properties for
            % this measurement class and saves all the according items of
            % the current measurement setup to a struct, which can later
            % be used to create an exact copy of this measurement setup.
            % Even though it is the exact same function as in the parent
            % class, this piece of code is neccessary here, to be able to
            % access the 'm' properties.
            
            % Get list of properties to be saved for this measurement
            % class.
            
            
            sObj = saveobj@itaMSTF(this);
            
            propertylist = itaMSTF_NLMS.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
        end
        
    end
    
    methods(Static, Hidden = true)
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the basic list of all to be saved
            % properties from its parent class and adds its own special
            % properties to the list, creating the final list of all
            % properties to be saved during the savin process.
            
            
            result = {'inputRef', 'T360', 'Tadapt', 'mu', 'ch2elMap', 'fit', 'max_ang', 'el', 'inputMeasure'};
            
        end
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTF_NLMS(sObj);
            
        end
        
    end
    
end