classdef itaHpTF_MS < itaHpTF
    %ITAHPTF_Meas - Calculation of the HpTF from measured TF and Mic.
    %Reference Measurements
    %
    %
    % Derived from itaHpTF. See itaHpTF_Meas for measurement
    % Without any argument ita_itaHpTF_setup is called. Otherwise use and
    % itaMSTF as input (To Do)

    %
    % itaHpTF_Meas Properties:
    %         TF            (measured transfer function)
    %         fLower        (lower frequency for extrapolation)
    %         fUpper        (upper frequency for regularization)
    %         method        (mSTD, max, mean: see Masiero, Bruno; Fels, Janina: "Perceptually Robust Headphone Equalization for Binaural Reproduction"
    %                                             Audio Engineering Society Convention 130, May 2011)
    %         normalized    (Normalization of HpTF)
    % itaHpTF_Meas Methods:
    %         run           Will be called immediatly after the GUI. Can
    %                       also be used with the subjects' name: this.run('Hans'). This method will return an itaHpTF_Audio to the workspace. 
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mMSTF        = itaMSTF;
    end
    
    properties(Dependent = true, Hidden = false)

        MSTF        = [];
    end
    
    properties (Dependent = true, SetAccess = private)
    end
    
    methods
        function this = itaHpTF_MS(varargin)
            
            this = this@itaHpTF();
            
            this.MSTF.inputChannels = [1 2];
            this.MSTF.outputChannels = [1 2];
            if nargin == 1
                % init
                if isa(varargin{1},'itaHpTF')
                    this.init = varargin;
                elseif isa(varargin{1},'itaMSTF') % calibration input
                    this.MSTF = varargin{1};
                end
                this.dimensions = 2*this.repeat;
                this.fftDegree = this.MSTF.fftDegree;
                
            else
                this_tmp = ita_itaHpTF_setup(this);
                if ~isempty(this_tmp)
                    this = this_tmp;
                    this.dimensions = 2*this.repeat;
                    this.fftDegree = this.MSTF.fftDegree;
                    HpTF = this.run; %#ok<NASGU>
                end
            end
            this.signalType = 'energy';
        end
        
        
        function HpTF = run(this,varargin) % run measurement
            if nargin == 2
                if ischar(varargin{1}), this.nameSubj = varargin{1}; end 
            end
            
            chIn    = this.MSTF.inputChannels; % TO DO setzt sich zurück
            chOut   = this.MSTF.outputChannels;
            MS      = this.MSTF;
            
            for idxM=1:this.repeat
                strL = [this.nameHP ', '  this.nameSubj ', run ',num2str(idxM) ' L'];
                strR = [this.nameHP ', '  this.nameSubj ', run ',num2str(idxM) ' R'];
                
                % Measure Left side
                MS.inputChannels = chIn(1);
                MS.outputChannels = chOut(1);
                resultL = MS.run;
                resultL.channelNames{1} = strL;
                
                % Measure Right side
                MS.inputChannels = chIn(2);
                MS.outputChannels = chOut(2);
                resultR = MS.run;
                resultR.channelNames{1} = strR;
                
                % Store data
                result2ch = ita_merge(resultL,resultR);
%                 if ~isempty(this.savePath)
%                     ita_write(result2ch,[this.savePath,'\HP_' this.nameHP '_Subj_' ...
%                         this.nameSubj '_run_',num2str(idxM) '.ita']);
%                 end
                
                this.freqData(:,[2*idxM-1,2*idxM]) = result2ch.freqData(:,[1 2]);
                this.channelNames{2*idxM-1} = strL;
                this.channelNames{2*idxM}   = strR;
                
                % Display on command window and continue
                if idxM~=this.repeat
                    commandwindow
                    disp(['Measurement ',num2str(idxM),'/',num2str(this.repeat),' finished.'])
                    disp('Put headphones off and on again. Press any key to continue.')
                    pause
                    pause(2)
                else
                    commandwindow
                    fprintf('\nMEASUREMENT DONE!\n')
                end
            end
            MS.outputChannels = chOut;
            MS.inputChannels = chIn;
            
            HpTF = itaHpTF_Audio(this);
            assignin('base', ['HpTF_' this.nameSubj], HpTF)
        end
        
        function display(this)
            this.displayLineStart
            this.disp
        end
        
        function disp(this)
            disp@itaHpTF(this)
        end
        
        %% ................................................................
        % GET
        %..................................................................

        
        function MSTF = get.MSTF(this)
            MSTF = this.mMSTF; end
        
        %% ................................................................
        % SET
        %..................................................................
        function this = set.MSTF(this,MSTF)
            this.mMSTF = MSTF; end
        
    end
    
    methods(Hidden = true)
    end
    
    methods(Hidden = true)
        function sObj = saveobj(this)
            % To Do!
            %             % Called whenever an object is saved
            %             % have to get save objects for both base classes
            
            sObj = saveobj@itaHpTF(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaHpTF_MS.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            this = itaHpTF_MS(sObj);
        end
        
        function result = propertiesSaved
            result = {'MSTF'};
        end
        
        function result = propertiesLoad
            result = {'mMSTF'};
        end
    end
end


