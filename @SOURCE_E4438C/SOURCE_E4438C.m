classdef SOURCE_E4438C  < handle
    %SOURCE3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        freq 
        power
        %mtonestate
        ntones
        fspacing
        
        rf_signal
    end
    
    methods
        function obj = SOURCE_E4438C(address)
            obj.rf_signal = AgilentE4438C(address);
        end
        
       function obj = WRITE(obj,mode)
                   switch(mode)
                       case 'on'
                           obj.rf_signal = obj.rf_signal.CONFIGURE(obj.freq,obj.power);
                           obj.rf_signal = obj.rf_signal.WRITE('on');
                       case 'off'
                           obj.rf_signal = obj.rf_signal.WRITE('off');
                   end
       end

    end
end

