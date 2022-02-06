classdef SOURCE_E3631A < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % to be used in WRITE. These are CONF
        v_pv6
        i_pv6
       
        v_pv25
        i_pv25
        state
        mode
        % Equipment
        source
        % To be updated by READ. These are data
        p25v_i
        p6v_i
    end
    
    methods
        % Constructor:
        function obj = SOURCE_E3631A(address)
            obj.source = Keysight_E3631A(address);
        end
        
       
%        function obj = WRITE(obj) 
%            obj.source = obj.source.CONFIGURE('P6V',obj.v_pv6,obj.i_pv6,'Source_PV6');
%            obj.source = obj.source.CONFIGURE('P25V',obj.v_pv25,obj.i_pv25,'Source_PV25');
%            obj.source = obj.source.WRITE;  
%         end

        function obj = WRITE(obj,mode)
            switch (mode)
                case 'on'
%                  obj.source.state ='on';
                   obj.source = obj.source.CONFIGURE_P6V(obj.v_pv6,obj.i_pv6,'Source_PV6') ;
                   obj.source = obj.source.WRITE('on'); 
           
                case 'off'
                    obj.source=obj.source.WRITE('off');
            end
        end
      
        function obj = READ(obj)
           obj.source = obj.source.READ_v6;
           obj. p25v_i = obj.source.current_P25V;
           obj.p6v_i = obj.source.current_P6V;
        end
       
        function obj = CLOSE(obj)
             obj.source=obj.source.CLOSE;
        end
 
    end
end

