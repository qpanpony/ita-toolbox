classdef itaHpTF_Audio < itaHpTF
    %ITAHPTF_AUDIO - Calculation of the HpTF from measured TF and Mic.
    %Reference Measurements
    %
    %
    % Derived from itaHpTF. See itaHpTF_Meas for measurement
    %
    %
    % itaHpTF_Audio Properties:
    %         TF                (measured transfer function)
    %         fLower            (lower frequency for extrapolation)
    %         fUpper            (upper frequency for regularization)
    %         method            (mSTD, max, mean: see Masiero, Bruno; Fels, Janina: "Perceptually Robust Headphone Equalization for Binaural Reproduction"
    %                                             Audio Engineering Society Convention 130, May 2011)
    %         normalized        (Normalization of HpTF)
    %         smoothing         (Smoothing bandwidth has to be defined in fractions of octaves, see also ita_smooth)
    %         mic               (measured microphone transfer funcions - not inverted: length does not matter; will be adapted)
    %
    % itaHpTF_Audio Methods (private):
    %         HP_equalization   If this.mic is not set, it will be unused 
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>

    
    properties(Access = private)
        mTF          = itaAudio;
        m_fLower     = 100;
        m_fUpper     = 18000;
        mMethod      = 'mSTD';
        mNormalized  = true;
        mGainComp    = true;
        mSmoothing   = 1/6;
        mSelectMeas    = 1:8; % select the channels which should be used for the HpTF
    end
    
    properties(Dependent = true, Hidden = false)
        TF          = itaAudio;
        fLower      = 100;
        fUpper      = 18000;
        method      = 'mSTD';
        normalized  = true; % normalization of the signal
        gainComp    = true; % microphone compensation
        smoothing   = 1/6;
        selectMeas   = 1:8; % select specific measurements
    end
    
    properties (Dependent = true, SetAccess = private)
       init 
    end
    
    properties (Dependent = true, SetAccess = private)
    end
    
    methods
        function this = itaHpTF_Audio(varargin)
            
            this = this@itaHpTF();
            
            if nargin == 1
                % init
                if isa(varargin{1},'itaHpTF_Audio')
                    this = varargin;
                elseif isa(varargin{1},'itaHpTF_MS')
                    this.init = varargin{1};
                    
                 elseif nargin ==1 && isstruct(varargin{1}) % only for loading
                    obj = varargin{1};
                    this.data = obj.data;
                    
                    this.signalType = 'energy';
                    % additional itaHRTF data
                    objFNsaved = this.propertiesSaved;
                    objFNload = this.propertiesLoad;
                             
                    for i1 = 1:numel(objFNload)
                        this.(objFNload{i1}) = obj.(objFNsaved{i1});
                    end

                end
            end
        end
        
        function display(this)
            this.displayLineStart
            this.disp
        end
        
        function disp(this)
            stringM = this.method;
            classnamestring = ['^--|' mfilename('class') '|'];
            
            disp@itaHpTF(this)
            
            fullline = repmat(' ',1,this.LINE_LENGTH);
            stringS = ['      Method       ' stringM ];
            fullline(1:numel(stringS)) = stringS; 
            startvalue = length(classnamestring);
            fullline(length(fullline)-startvalue+1:end) = classnamestring;
            disp(fullline);
            
            dir = num2str(this.repeat,5);
            stringD = [dir ' repetition(s) '];
            
            middleLine = this.LINE_MIDDLE;
            middleLine(3:(2+length(stringD))) = stringD;
            fprintf([middleLine '\n']);
        end
        
        %% ................................................................
        % GET
        %..................................................................       
        function fLower= get.fLower(this)
            fLower = this.m_fLower; end
        
        function fUpper = get.fUpper(this)
            fUpper = this.m_fUpper; end
        
        function method = get.method(this)
            method = this.mMethod; end
        
        function TF = get.TF(this)
            TF = this.mTF; end
        
        function normalized = get.normalized(this)
            normalized = this.mNormalized; end
        
        function comp = get.gainComp(this)
            comp = this.mGainComp; end
        
        function sel = get.selectMeas(this)
            sel = this.mSelectMeas; end
        
        
        function smoothing = get.smoothing(this)
            smoothing = this.mSmoothing; end
        %% ................................................................
        % SET
        %.................................................................. 
        function this = set.fLower(this,fLower)
            this.m_fLower = fLower;
            this = HP_equalization(this);
        end
        
        function this = set.fUpper(this,fUpper)
            this.m_fUpper = fUpper;
            this = HP_equalization(this);
        end
        
        function this = set.method(this,method)      
                if sum(strcmpi(method,this.propertiesMethod))==1
                    this.mMethod = method;
                    this = HP_equalization(this);
                else
                    error('itaHpTF:Def', ' Valid methods: mSTD, max, mean.')
                end
        end
        
        function this = set.normalized(this,normalized)
            this.mNormalized = normalized;
            this = HP_equalization(this);
        end
        
        function this = set.selectMeas(this,ch)
            this.mSelectMeas = ch;
            this = HP_equalization(this);
        end
        
        function this = set.gainComp(this,comp)
            this.mGainComp = comp;
            this = HP_equalization(this);
        end
        
        function this = set.smoothing(this,smoothing)
            this.mSmoothing = smoothing;
            this = HP_equalization(this);
        end
        
        function this = set.TF(this,TF)
            this.mTF = TF; end
        %% ................................................................
        % SET PRIVATE
        %..................................................................
        function this = set.init(this,var)
             this.nameHP      = var.nameHP;
            this.nameMic     = var.nameMic;
            this.nameSubj    = var.nameSubj;
            this.repeat      = var.repeat;
            this.mTF.time    = var.time;
            this.selectMeas  = 1:var.repeat;
            this = HP_equalization(this);
        end
        
        function thisEQ = HP_equalization(this) 
            % Masiero, Bruno; Fels, Janina: "Perceptually Robust Headphone Equalization for Binaural Reproduction"
            %     Audio Engineering Society Convention 130, May 2011
            
            tWin    = this.TF.trackLength; % crop HPTF
            measSel = sort([2*this.selectMeas-1 2*this.selectMeas]);
            TF = this.TF.ch(measSel);
            
            %init
            thisEQ  = this;
            Rec     = itaAudio(zeros(TF.nSamples,1), TF.samplingRate, 'time');
            Rec.signalType = 'energy';
            mRec    = Rec;
            HpTF    = itaAudio(zeros(this.TF.nSamples,2), this.TF.samplingRate, 'time');
            HpTF.signalType = 'energy';
            
            for cdx = 1:2 % L/R ...
                switch this.method
                    case 'mean'
                        Rec.freqData = mean(abs(TF.freqData(:,cdx:2:end)),2);
                    case 'max'
                        Rec.freqData = max(abs(TF.freqData(:,cdx:2:end)),[],2);
                    case 'mSTD'
                        Rec.freqData = mean(abs(TF.freqData(:,cdx:2:end)),2) + 2*std(abs(TF.freqData(:,cdx:2:end)),0,2);
                    otherwise
                        error('Unknown type');
                end
                
                if this.mic.dimensions == 2 % Compensation of mic
                    minMic  = ita_minimumphase(this.mic);
                    RecM    = ita_convolve(Rec,minMic.ch(cdx));
                    RecM.fftDegree = TF.fftDegree;
                else
                    RecM = Rec;
                end
                %% Short Filter with no correction for low freqs and minimum phase
                aux = max(abs(RecM.freqData),[],2);
                
                % find first maximum and truncate low freq correction at this point
                idxDF   = RecM.freq2index([this.fLower  this.fLower*1.5 ]);
                d_aux   = diff(aux(idxDF(1):idxDF(2)));
                idx     = find(diff(sign(d_aux)) ~= 0,1,'first'); % Bruno style...
                aux(1:idxDF(1)+idx+1) = aux(idxDF(1)+idx+2);
                aux(aux==0) = rand(1)*eps; % für die Regularisierung ~=0
                mRec.freqData = aux;
                
                % smoothing
                mRec_s = ita_smooth(mRec,'LogFreqOctave1',this.smoothing,'Abs');
                HpTF_tmp  = ita_invert_spk_regularization(mRec_s ,[0 this.fUpper]);
                
                HpTF.freqData(:,cdx) = HpTF_tmp.freqData;
            end
            
            % or guaranty that the average level of the signal is not altered
            % this also means that the overall loudness of the signal will not be
            % considerably altered.
            this_min   = ita_minimumphase(ita_time_shift(HpTF,tWin/2));
            this_win   = ita_time_window(this_min,[tWin*0.99,tWin],'time','crop');
           
            if this.gainComp % compensate gains from mics (equalize)
                idxDF   = this_win.freq2index(this.fLower);
                chGain  = 20*log10(abs(this_win.freqData(idxDF,:)));
                this_comp = this_win;
                this_comp.freqData = bsxfun(@times,this_win.freqData,10.^(-chGain/20));
            else, this_comp = this_win;
            end
            
            if this.normalized
                this_norm = ita_normalize_dat(this_comp);
                thisEQ.timeData = this_norm.timeData;
            else, thisEQ.timeData = this_comp.timeData;
            end
            
            if ~isempty(this.savePath)
                HpTFaudio = itaAudio(thisEQ.timeData, TF.samplingRate, 'time');
                ita_write(HpTFaudio,[this.savePath,'\HpTF_HP_' this.nameHP '_Subj_' ...
                    this.nameSubj '.ita']);
                ita_write(thisEQ,[this.savePath,'\HP_' this.nameHP '_Subj_' ...
                    this.nameSubj '.ita']);
            end
        end
        
    end
    
    methods(Hidden = true)
    end
    
    methods(Hidden = true)
        function sObj = saveobj(this)
            %             % Called whenever an object is saved
            %             % have to get save objects for both base classes
            
            sObj = saveobj@itaHpTF(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaHpTF_Audio.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            this = itaHpTF_Audio(sObj);
        end
        
        function result = propertiesSaved
            result = {'nameHP','nameMic','nameSubj','repeat','mic','savePath',...
                'TF','fLower','fUpper','method','normalized','smoothing'};
        end
        
        function result = propertiesLoad
            result = {'nameHP','nameMic','nameSubj','repeat','mic','savePath',...
                'mTF','m_fLower','m_fUpper','mMethod','mNormalized','mSmoothing'};
        end
        
        function result = propertiesMethod
            result = {'mSTD', 'max','mean'};
        end
    end
end


