classdef SOURCE_B2902A < handle
    %SOURCE_VGS_ID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
        vsen1b
        max_i
        current
        % Equipment.
        ISEN1B
        % To be updated by READ
        N
        
    end
    
    methods
        function obj = SOURCE_B2902A(address)
            obj.ISEN1B = KeysightB2912A(address);
        end
    
        function obj = WRITE(obj,mode)
            switch (mode)
                case 'on'
                    obj.ISEN1B = obj.ISEN1B.CONFIGURE('CH1','voltage',obj.vsen1b,obj.max_i);
                    %obj.ISEN1B = obj.temp.CONFIGURE('CH2','voltage',obj.vds,obj.max_id);
                    obj.ISEN1B = obj.ISEN1B.WRITE('on');
                case 'off'
                    obj.ISEN1B = obj.ISEN1B.WRITE('off');
           
            end       
        end
             
        function obj = READ(obj)
            obj.ISEN1B = obj.ISEN1B.READ;
            obj.current = obj.ISEN1B.measured_current_CH1;
            obj.vsen1b = obj.ISEN1B.measured_voltage_CH1;
%             obj.ig = obj.temp.measured_current_CH1;
%             obj.vds = obj.temp.measured_voltage_CH2;
        end
    end
end