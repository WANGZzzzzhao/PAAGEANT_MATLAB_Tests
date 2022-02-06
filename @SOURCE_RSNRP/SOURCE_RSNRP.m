classdef SOURCE_RSNRP < handle
    %SOURCE4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        power
        rspm
    end
    
    methods
        function obj = SOURCE_RSNRP(address)
            obj.rspm = RSNRP(address);
        end
        
        function obj = READ(obj)
            obj.rspm=obj.rspm.READ;
            obj.power=obj.rspm.power;
            
        end
    end
end

