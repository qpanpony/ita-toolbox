classdef itaTransferPathAirborne %< handle

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    
    properties(Access = private)
        mType            = 'airborne'; %input/output
    end
    properties(Dependent = true, Hidden = false)
        type
    end
    
    properties
        name            = '';
        amplification   = '0dB';
        signal          = itaAudio;
        TP              = itaAudio;
    end
    
    %% **************************************************************
    methods
        %% constructor
        
        
        function show(this)
            disp(['****************** ' class(this) ' *****************'])
            disp([' Name: ' this.name]);
            if ~isempty(this.signal)
                cdisp('green',['Signal: ' this.signal.comment]);
            else
                cdisp('red',['Signal: ' 'not specified']);
            end
            
           
            if ~isempty(this.TP)
                cdisp('green',['TP: ' this.TP.comment]);
            else
                cdisp('red',['TP: ' 'not specified']);
            end
            
        end
        
        function res = get.type(this)
            res = this.mType;
        end
    end

    
    
end