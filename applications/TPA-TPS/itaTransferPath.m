classdef itaTransferPath %< handle

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
        Zs              = [];
        Zr              = [];
        TP              = itaAudio;
        fourpole        = [];
    end
    
    %% **************************************************************
    methods
        %% constructor
        
        
        function disp(this)
            disp(['****************** itaTransferPath *****************'])
            disp([' Name: ' this.name]);
            disp([' Type: ' this.type]);
            if ~isempty(this.signal)
                cdisp('green',['Signal: ' this.signal.comment]);
            else
                cdisp('red',['Signal: ' 'not specified']);
            end
            
            if strcmpi(this.type,'structure-borne')
            if ~isempty(this.signal)
                cdisp('green',['Zs: ' this.Zs.comment]);
            else
                cdisp('red',['Zs: ' 'not specified']);
            end
            
            if ~isempty(this.signal)
                cdisp('green',['Zr: ' this.Zr.comment]);
            else
                cdisp('red',['Zr: ' 'not specified']);
            end
            
            if ~isempty(this.signal)
                cdisp('green',['fourpole: ' fourpole.signal.comment]);
            else
                cdisp('red',['fourpole: ' 'not specified']);
            end
            
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
        
        function this = set.type(this,value)
            this.mType = value;
        end
    end

    
    
end