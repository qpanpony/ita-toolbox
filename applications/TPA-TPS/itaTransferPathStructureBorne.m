classdef itaTransferPathStructureBorne < itaTransferPathAirborne

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    
    properties(Access = private)
        mType            = 'structure-borne'; %input/output
    end
    properties(Dependent = true, Hidden = false)

    end
    
    properties
        Zs              = [];
        Zr              = [];
        fourpole        = [];
    end
    
    %% **************************************************************
    methods
        %% constructor
        
        
        function show(this)
            
            show@itaTransferFunctionAirborne(this);
            
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
                    cdisp('green',['fourpole: ' this.fourpole.comment]);
                else
                    cdisp('red',['fourpole: ' 'not specified']);
                end
                
                
        end
        function res = fourpole_result(this)
            
            res = this.fourpole(1);
            for idx = 2:numel(this.fourpole)
                res = res * this.fourpole(idx);
            end
        end
        function res = coupling(this)
            res = ita_kernel4poles(this.Zs, this.fourpole_result, this.Zs);
        end
        
    end

    
    
end