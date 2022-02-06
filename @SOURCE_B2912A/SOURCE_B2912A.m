classdef SOURCE_B2912A < handle
    %SOURCE_VGS_ID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vgs
        max_ig
        vds
        max_id
        % Equipment.
        dc_bias
        % To be updated by READ
        id
        ig
        
    end
    
    methods
        function obj = SOURCE_B2912A(address)
            obj.dc_bias = KeysightB2912A(address);
        end
    
        function obj = WRITE(obj,mode)
            switch (mode)
                case 'on'
                    obj.dc_bias = obj.dc_bias.CONFIGURE('CH1','voltage',obj.vgs,obj.max_ig);
                    obj.dc_bias = obj.dc_bias.CONFIGURE('CH2','voltage',obj.vds,obj.max_id);
                    obj.dc_bias = obj.dc_bias.WRITE('on');
                case 'off'
                    obj.dc_bias = obj.dc_bias.WRITE('off');
           
            end       
        end
             
        function obj = READ(obj)
            obj.dc_bias = obj.dc_bias.READ;
            obj.id = obj.dc_bias.measured_current_CH2;
            obj.vgs = obj.dc_bias.measured_voltage_CH1;
            obj.ig = obj.dc_bias.measured_current_CH1;
            obj.vds = obj.dc_bias.measured_voltage_CH2;
        end
    end
end

