classdef ReceiverType
    %ReceiverType Used to specify the geometry of an itaReceiver for
    %wave-based simulations
    %   ...
    
    enumeration
        Monaural, DummyHead, UserDefined
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