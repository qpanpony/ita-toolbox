classdef itaHpTF < itaAudio
    %ITAHPTF - super class for HpTF measurements and signal processing
    %
    %
    % Derived from itaAudio. See itaHpTF_Meas for measurement or
    % itaHpTF_Audio for HpTF manipulations

    %
    % itaAudio Properties:
    %         nameHP  
    %         nameMic  
    %         nameSubj 
    %         repeat 
    %         mic       
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>

    
    properties(Access = private)
        mNameHP      = 'HP';
        mNameMic     = 'KE 3';
        mMic         = itaAudio;
        mNameSubj    = 'Karl';
        mRepeat      = 8;
                mSavePath    = [];
    end
    
    properties(Dependent = true, Hidden = false)
        nameHP      = 'HP';
        nameMic     = 'KE 3';
        nameSubj    = 'Karl';
        repeat      = 8;
        mic         = itaAudio;
                savePath    = [];
    end
    
    properties (Dependent = true, SetAccess = private)
    end
    
    methods
        function this = itaHpTF(varargin)
            
            this = this@itaAudio();
            
            if nargin == 1
                % init
                if isa(this,'itaHpTF')
                    this.init = varargin;
                end
            end
            this.dimensions = 2;
            this.fftDegree = 16;
            this.signalType = 'energy';
        end
        
               
        function display(this)
            this.displayLineStart
            this.disp
        end
        
        function disp(this)
            
            disp@itaAudio(this)
            
            stringHP = this.nameHP;
            stringMic = this.nameMic;
            stringSub = this.nameSubj;

            % this block adds the class name
            classnamestring = ['^--|' mfilename('class') '|'];
            
            fullline = repmat(' ',1,this.LINE_LENGTH);
            stringH = ['      Headphone    ' stringHP ];
            fullline(1:numel(stringH)) = stringH; disp(fullline)
            
            fullline = repmat(' ',1,this.LINE_LENGTH);
            stringM = ['      Microphone   ' stringMic ]; 
            fullline(1:numel(stringM)) = stringM; disp(fullline)
            
            fullline = repmat(' ',1,this.LINE_LENGTH);
            stringS = ['      Subject      ' stringSub ];
            fullline(1:numel(stringS)) = stringS; 
            startvalue = length(classnamestring);
            fullline(length(fullline)-startvalue+1:end) = classnamestring;
            disp(fullline);
            
            % end line
        end
        
        %% ................................................................
        % GET
        %..................................................................       
        function nameHP = get.nameHP(this)
            nameHP = this.mNameHP; end
        
        function nameMic = get.nameMic(this)
            nameMic = this.mNameMic; end
        
        function mic = get.mic(this)
            mic = this.mMic; end
        
        function nameSubj = get.nameSubj(this)
            nameSubj = this.mNameSubj; end
        
        function repeat = get.repeat(this)
            repeat = this.mRepeat; end
        
        function savePath = get.savePath(this)
            savePath = this.mSavePath; end
        
        %% ................................................................
        % SET
        %..................................................................
       
        function this = set.nameHP(this,nameHP)
            this.mNameHP = nameHP; end
        
        function this = set.nameMic(this,nameMic)
            this.mNameMic = nameMic; end
        
        function this = set.mic(this,mic)
            this.mMic = mic; end
        
        function this = set.nameSubj(this,nameSubj)
            this.mNameSubj = nameSubj; end
        
        function this = set.repeat(this,repeat)
            this.mRepeat = repeat; end
        
        function this = set.savePath(this,savePath)
            this.mSavePath = savePath; end

    end
    
    methods(Hidden = true)
    end
    
    methods(Hidden = true)
        function sObj = saveobj(this)
            %             % Called whenever an object is saved
            %             % have to get save objects for both base classes
            
            sObj = saveobj@itaAudio(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaHpTF.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            this = itaHpTF(sObj);
        end
        
        function result = propertiesSaved
            result = {'nameHP','nameMic','nameSubj','repeat','mic','savePath'};
        end
        
        function result = propertiesLoad
            result = {'mNameHp','mNameMic','mNameSubj','mRepeat','mMic','mSavePath'};
        end
    end
end


