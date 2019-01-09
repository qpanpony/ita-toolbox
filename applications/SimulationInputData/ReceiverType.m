classdef ReceiverType
    %ReceiverType Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        Monaural, DummyHead
    end
    
    methods
        function bool = IsMonaural(this)
            bool = ReceiverType.Monaural == this;
        end
        function bool = IsBinaural(this)
            bool = ~this.IsMonaural();
        end
    end
    
end