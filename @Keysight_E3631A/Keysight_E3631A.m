classdef Keysight_E3631A < handle
    %Keysight_E3631A Summary of this class goes here
    %Class devoted to interact with the DC source Keysight E3631A
    %Handle class: each object refers to an unique equipment.
    %Functions:
    %Class constructor stablishes connection with the equipment
    %Functions to set the values of the source
    %Function to activate the source.
    %DATE: 15-05-2021. Author: Josep Altet.
    
    properties (Constant)  %Used to check if values entered by user are OK
        max_voltage_P25V = 25.75 %V Maximum voltage source: 25V positive.
        max_voltage_P6V = 6.18   %V Maximum voltage source: 6V positive.
        max_current_P25V = 1.03  %A Maximum corrent source 25V positive.
        max_current_P6V = 5.15   % Maximum current source 6V positive.
    end
   
    % EXTRACTED FROM CONF STRUCTURE BY QUIQUE.
    % Updated by the CONFIGURE function. Used in the WRITE
    % address is used in the class constructor.
    properties (Access = protected)
        %Variables needed to stablish connection
        address = 'GPIB0::7::INSTR'
        %handler = []
        %---------------------------------------------------
        %Internal variable to track the status of the source
       
        %---------------------------------------------------
        %Variables to set the P6V source.
        name_P6V ='Source 6V' %Name to be displayed in the LCD
        voltage_P6V {mustBeGreaterThanOrEqual(voltage_P6V,0)} = 0.0
        currentlimit_P6V {mustBeGreaterThanOrEqual(currentlimit_P6V,0)} = 0.05
        %---------------------------------------------------
        %Variables to set the P6V source.
        name_P25V ='Source 25V' %Name to be displayed in the LCD
        voltage_P25V {mustBeGreaterThanOrEqual(voltage_P25V,0)} = 0.0
        currentlimit_P25V {mustBeGreaterThanOrEqual(currentlimit_P25V,0)}= 0.2
    end
    
    % EXTRACTED FROM DATA STRUCTURE BY QUIQUE.
    % Updated in the READ function
    properties
        current_P6V
        current_P25V
        handler = []
         state {mustBeMember(state,{'close','init','active'})}='close'
    end
    
    methods 
        %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = Keysight_E3631A(physical_address)
           if nargin > 0 
               % Addess assigned to object property
                obj.address = physical_address; 
           else    % Else the default value is keept.
            disp('Default GPIB Address for the E3631A used')
           end
           
                try
                 % Let's try to connect with the device
                    obj.handler=visa('agilent', obj.address);
                    obj.handler.OutputBufferSize = 1024;
                    obj.handler.InputBufferSize = 102400;
                    fopen(obj.handler);
                 % Source is set to reset state. Refer to user manual to see
                 % all implications
                  fprintf(obj.handler,'*RST'); %reset (manually set state to off) 
                  obj.state = 'init';
                  disp('Conection with E3631A Stablished. Go ahead! Make my day!')
                  % https://youtu.be/CJulx2Zg_oU
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the Keysight_E3631A. Please, check connection');
                end
            end
%--------------------------------------------------------------------------        
        % function CLOSE
        % Input parameter: 
        % the function closes connection with device.
        % POST: state is close
        function obj = CLOSE(obj)
           % assume VISA connection (gpib or ethernet)
            %visa & fopen
            if (strcmp(obj.state,'close'))
                disp('Keysight_E3631A: device already closed');
            else
                try
                 fclose(obj.handler);
                 %delete(obj.handler);
                 obj.state = 'close';
                 disp('Keysight_E3631A: device closed. The brokil is over!');
                catch
                 disp('Keysight_E3631A:visa connection error');
                end
            end
            
        end
% ------------------------------------------------------------------------
        % Class destructor
        % Post: file is closed.
        % Post: State is close.
            function delete(obj)
                 fclose(obj.handler);
                % delete(obj.handler);
                 obj.state = 'close';
            end
%--------------------------------------------------------------------------        
         % function CONFIGURE
        % Input parameter: voltage value, voltage limit and current limit
        % for both sources
        % POST: Properties for P6V and P25V are updated.  
         function obj = CONFIGURE(obj,v_PV6,cl_PV6,message_PV6,...
                 v_PV25,cl_PV25,message_PV25)
            obj.voltage_P6V  = v_PV6;
            obj.currentlimit_P6V  = cl_PV6;
            obj.name_P6V = message_PV6;
            obj.voltage_P25V  = v_PV25;
            obj.currentlimit_P25V  = cl_PV25;
            obj.name_P25V = message_PV25;
         end
    
         
         %---------------------------------------------------------------      
         % function WRITE
        % PRE: voltage value and limits are already set.
        % PRE: source is activated.
        % POST: Source ON or OFF depending on STATUS.
        function obj = WRITE(obj,status)
            %Status = 'on' or 'off' to activate or deactivate the source.
            if (strcmp(obj.state,'close'))
                disp('Keysight_E3631A: before writing, device must be initialized');
            else
                fprintf(obj.handler,['INSTrument:SELect P25V']); % output select
                % Current limit
                fprintf(obj.handler,['SOURce:CURR:LEVel:IMMediate:AMPLitude ', num2str(obj.currentlimit_P25V)]);
                % Ploting name
               % fprintf(obj.handler,['DISPlay:TEXT "',obj.name_P25V,'"']);
                 % output voltage
                fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.voltage_P25V)]);

                
                fprintf(obj.handler,['INSTrument:SELect P6V']); % output select
                % Current limit
                fprintf(obj.handler,['SOURce:CURR:LEVel:IMMediate:AMPLitude ', num2str(obj.currentlimit_P6V)]);
                % Ploting name
              %  fprintf(obj.handler,['DISPlay:TEXT "',obj.name_P6V,'"']);
                 % output voltage
                fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.voltage_P6V)]);
               
                
                if (strcmp(status,'off'))
                disp('Agilent E3631 is OFF');
                        fprintf(obj.handler,['OUTPut:STATe 0']);
                         obj.state = 'init';
                elseif (strcmp(status,'on'))
                        fprintf(obj.handler,['OUTPut:STATe 1']);
                        query(obj.handler,[':MEASure:CURRent:DC?']);
                         obj.state = 'active';
                  
                else
                    disp('DC surce write status not correct. Either on or off');
                end
            end
        end   
        
        %---------------------------------------------------------------      
         %-----------------------------------------------------------------------       
         % function READ
        % PRE: voltage value and limits are already set.
        % PRE: source is activated.
        % POST: Source active. Displays updated.
        function obj = READ(obj)
             if (strcmp(obj.state,'close'))
                disp('Keysight_E3631A: before reading, device must be initialized');
            else
                 fprintf(obj.handler,['INSTrument:SELect P25V']); % output select
                fprintf(obj.handler,[':MEASure:CURRent:DC?']);
                obj.current_P25V = str2double(fscanf(obj.handler,'%s'));
                  fprintf(obj.handler,['INSTrument:SELect P6V']); % output select
                fprintf(obj.handler,[':MEASure:CURRent:DC?']);
                obj.current_P6V = str2double(fscanf(obj.handler,'%s'));
             end
        end  
        

%-------------------------------------------------------------------------
% PARTIAL FUNCTIONS. Other functions that can be used.
%-------------------------------------------------------------------------
        % function Conf_P6V. Partial configure function.
        % Input parameter: voltage value, voltage limit and current limit
        % POST: Properties for output P6V are updated.
        function obj = CONFIGURE_P6V(obj,voltage,current_limit,message)
            obj.voltage_P6V  = voltage;
            obj.currentlimit_P6V  = current_limit;
            obj.name_P6V = message;
        end
        
%--------------------------------------------------------------------------        
         % function Conf_P25V. Partial configure function.
        % Input parameter: voltage value, voltage limit and current limit
        % POST: Properties for output P25V are updated.
        function obj = CONFIGURE_P25V(obj,voltage,current_limit,message)
            obj.voltage_P25V  = voltage;
            obj.currentlimit_P25V  = current_limit;
            obj.name_P25V = message;
        end  
        

         %---------------------------------------------------------------      
         % function WRITE_P25V
        % PRE: voltage value and limits are already set.
        % PRE: source is activated.
        % POST: Source active. Displays updated.
        function obj = WRITE_P25V(obj)
            fprintf(obj.handler,['INSTrument:SELect P25V']); % output select
            
            % Current limit
            fprintf(obj.handler,['SOURce:CURR:LEVel:IMMediate:AMPLitude ', num2str(obj.currentlimit_P25V)]);
            % Ploting name
            %fprintf(obj.handler,['DISPlay:TEXT "',obj.name_P25V,'"']);
            
             % output voltage
            fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.voltage_P25V)]);
            obj.state = 'active';
        end  
          %-----------------------------------------------------------------------       
         % function WRITE_P6V
        % PRE: voltage value and limits are already set.
        % PRE: source is activated.
        % POST: Source active. Displays updated.
         function obj = WRITE_P6V(obj)
            fprintf(obj.handler,['INSTrument:SELect P6V']); % output select
            
            % Current limit
            fprintf(obj.handler,['SOURce:CURR:LEVel:IMMediate:AMPLitude ', num2str(obj.currentlimit_P6V)]);
            % Ploting name
            %fprintf(obj.handler,['DISPlay:TEXT "',obj.name_P6V,'"']);
            
             % output voltage
            fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.voltage_P6V)]);
            obj.state = 'active';
         end  
        
         %------------------------------------------------------------------------
 % These functions are automatically invoked when the selected properties
 % are updated.
        % Set functions for the source parameters:
        function set.voltage_P6V(obj,value)
            if (value <= obj.max_voltage_P6V)
                obj.voltage_P6V = value;
            else
               error('Keysight_E3631A: max voltage value exceeded for P6V') 
            end
        end
        function set.currentlimit_P6V(obj,value)
            if (value <= obj.max_current_P6V)
                obj.currentlimit_P6V = value;
            else
               error('Keysight_E3631A: max current limit exceeded for P6V') 
            end
        end
         function set.voltage_P25V(obj,value)
            if (value <= obj.max_voltage_P25V)
                obj.voltage_P25V = value;
            else
               error('Keysight_E3631A: max voltage value exceeded for P25V') 
            end
        end
        function set.currentlimit_P25V(obj,value)
            if (value <= obj.max_current_P25V)
                obj.currentlimit_P25V = value;
            else
               error('Keysight_E3631A:Error: max current limit exceeded for P25V') 
            end
        end    

 
    end
end

