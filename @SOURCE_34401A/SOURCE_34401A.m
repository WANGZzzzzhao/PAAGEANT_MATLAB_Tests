classdef SOURCE_34401A < handle
    %SOURCE_34401A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Equipment
        TMP1
        
        %value to be measured
        vtemp
    end
    
    methods
        function obj = SOURCE_34401A(address)
            obj.TMP1 = Keysight_34401A(address);
        end
        
        function obj = READ(obj)
           obj.TMP1 = obj.TMP1.READ;
           obj.vtemp = obj.TMP1.voltage;
           
        end
        
        function obj = CLOSE(obj)
            obj.TMP1=obj.TMP1.CLOSE;
        end
        
    end
end