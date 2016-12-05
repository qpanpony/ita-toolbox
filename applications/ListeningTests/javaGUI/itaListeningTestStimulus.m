classdef itaListeningTestStimulus
%ITA_LISTENINGTEST_STIMULUS - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_listeningtest_stimulus(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_listeningtest_stimulus(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_listeningtest_stimulus">doc ita_listeningtest_stimulus</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  02-Dec-2013 

%% properties
    properties
        UseHRTF = 1;
        UseHeadphoneEquilization = 1;
        UseSoundLevelVariation = 1;
     %TODO UseTracker = 1;
        HRTFFile;

        StimulusFile;
        
        HeadphoneEquilizationFile;
        
        
    end

    
    properties(Access = private, Hidden = true)
        mHRTF;
        mHeadphoneEquilization;
        mStimulus;
    end

%% methods
    methods
        function returnSignal = getStimulusForDirection(this,azimuth, elevation, soundLevel)
            
            returnSignal = this.mStimulus;
            
            if (this.UseHRTF == 1)
                HRTF = this.getHRTFForDirection(azimuth,elevation);
                returnSignal = this.convoleSignals(returnSignal,HRTF);
            end
            
            if (this.UseHeadphoneEquilization == 1)
                returnSignal = this.convoleSignals(returnSignal,this.mHeadphoneEquilization);
            end
            
            
            if (this.UseSoundLevelVariation == 1)
                returnSignal = returnSignal./soundLevel;
            end
                
                
            % TODO: Better normalization
%             returnSignal = returnSignal./64;
        end
    end
    
%% internal methods
    methods(Access = private, Hidden = true)
        
        function signal = convoleSignals(this,signal1, signal2)
            temp = ita_convolve(signal1,signal2);

            temp = ita_time_window(temp,[signal1.trackLength-0.05 signal1.trackLength],@hann,'time');
            signal = temp;
        end
        
        function HRTF = getHRTFForDirection(this,azimuth,elevation)
%             hrtf = this.hrtfmerge;
%             coords = hrtf.channelCoordinates;
%             targetCoord = itaCoordinates(1);
%             targetCoord.phi_deg = azimuth;
%             targetCoord.theta_deg = elevation;
%             targetCoord.r = 1;
%             index = coords.findnearest(targetCoord);
%             HRTF = this.mHRTF(ceil(index/2));
            hrtf = this.mHRTF.findnearestHRTF(elevation,azimuth);
            HRTF = hrtf.itaHRTF2itaAudio;
        end
        
    end
    %% get/set methods
    methods
        function result = get.UseHRTF(this)
            result = this.UseHRTF;
        end
        function this = set.UseHRTF(this,value)
            this.UseHRTF = value;
        end

        function result = get.HRTFFile(this)
            result = this.HRTFFile;
        end
        function this = set.HRTFFile(this,value)
            
            if isa(value,'itaAudio')
                this.HRTFFile = '';
                
                this.mHRTF = itaHRTF(merge(value));  
                
                return
            end
            
            if isa(value,'itaHRTF')
                this.HRTFFile = '';
                
                this.mHRTF = value;   
                
                return
            end
            
            if ischar(value)
                try
                    this.HRTFFile = value;

                    this.mHRTF = ita_read(value);
                    
                catch e
                    
                end
                
                return
            end
                     
            error('Not a valid type');
            
        end

        function result = get.StimulusFile(this)
            result = this.StimulusFile;
        end
        function this = set.StimulusFile(this,value)
            
            if isa(value,'itaAudio')
                this.StimulusFile = '';
                
                this.mStimulus = value;  
                
                return
            end
            
            
            if ischar(value)
                try
                    this.StimulusFile = value;
                    this.mStimulus = ita_read(value);                 
                catch e
                    
                end
                return
            end
            
            error('Not a valid type');
            
        end    

        function result = get.HeadphoneEquilizationFile(this)
            result = this.HeadphoneEquilizationFile;
        end
        function this = set.HeadphoneEquilizationFile(this,value)
            
            if isa(value,'itaAudio')
                this.HeadphoneEquilizationFile = '';
                
                this.mHeadphoneEquilization = value;  
                
                return
            end
            
            
            if ischar(value)
                try
                    this.HeadphoneEquilizationFile = value;
                    this.mHeadphoneEquilization = ita_read(value);                 
                catch e
                    
                end
                return
            end
            
            error('Not a valid type');
            
            

        end
    end
end