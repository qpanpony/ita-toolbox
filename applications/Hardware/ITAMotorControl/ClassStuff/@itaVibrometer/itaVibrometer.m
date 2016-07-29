classdef itaVibrometer < itaMeasurementTasksScan

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % Measurements with the Polytec Laser Doppler Vibrometer.
    
    % Author: Pascal Dietrich - July 2010
    
    % *********************************************************************
    % *********************************************************************
    properties(Hidden = true)
        % ????
        mVivo = [];
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = private)
        
    end
    % *********************************************************************
    % *********************************************************************
    methods
        function reference(this)
            %do a reference move
            this.referenceMove;
        end
        
        function moveTo(this,position)
            % Move turntable and arm to absolute position
            
            % Error checks
            if ~isa(position,'itaCoordinates')
                error('itaItalian: Should be itaCoordinates')
            end
            if ~this.isInitialized
                this.initialize
            end
        end
        
        function init(this)
            %do the initialization
            disp('test')
        end
        
        function gui(this)
            %start Laser Vibrometer GUI
            ita_vibro_lasergui(this)
        end
        
    end %methods
    
    %% Hidden Methods
    methods(Hidden = true)
        function this = referenceMove(this)
            %do a refernce move
            if ~this.isInitialized
                this.initialize;
            end
            
            if this.isReferenced
                this.moveTo(itaCoordinates([1 pi/2 0],'sph'));
            end
            
            %% Init RS232 - Empty buffer
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            fwrite(this.mSerialObj,21);% Kill old commandos
            fwrite(this.mSerialObj,85);% Release - 'Freigabe'
            pause(0.5)
            
            %% Reference Move Commando
            
            
            %% Wait for arm and turntable to reach reference position
            pause(0.5);
            this.mCurrentPosition.sph = [1 pi/2 0]; % Init-Position
            this.wait;
            
            %% empty buffer
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            
        end
    end
    
    % *********************************************************************
    % *********************************************************************
end