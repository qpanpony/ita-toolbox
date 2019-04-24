classdef ReceiverType
    %ReceiverType Used to specify the geometry of an itaReceiver for
    %wave-based simulations
    
    enumeration
        Monaural, ITADummyHead, UserDefined
    end
    
    methods
        function bool = IsMonaural(this)
            bool = ReceiverType.Monaural == this;
        end
        function bool = IsBinaural(this)
            bool = ~this.IsMonaural();
        end
        function bool = NeedsGeometryFile(this)
            bool = this == ReceiverType.ITADummyHead ||...
                this == ReceiverType.UserDefined;
        end
    end
    
end