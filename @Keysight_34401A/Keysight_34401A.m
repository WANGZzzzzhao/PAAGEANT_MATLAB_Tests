classdef Keysight_34401A < handle
    %   Multimetter Agilent 34401A
    %   Author: Josep Altet. 18/5/2021 inspired by the program developed by
    %           Quique Barajas. 
    
    properties %(Access = protected)
        % Extracted from the file INSTRUMENTS
        %INSTR.instrument='Keysight 34401A';
        address='GPIB0::5::INSTR'
        handler=[]
        %INSTR.name='VM_tsensor';
        state {mustBeMember(state,{'close','init'})}='close'
        name='tmp'
        name2 = 'VM_tsensor'
        % To be done: properties that set up the range and resolution
    end
    properties
        voltage
    end
    
    methods
        %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = Keysight_34401A(physical_address)
           if nargin > 0 
               % Addess assigned to object property
                obj.address = physical_address; 
           else    % Else the default value is keept.
            disp('Default GPIB Address for the multimeter is used')
           end
           
                try
                 % Let's try to connect with the device
                    obj.handler=visa('agilent', obj.address);
                    %obj.handler.OutputBufferSize = 1024;
                    %obj.handler.InputBufferSize = 102400;
                    fopen(obj.handler);
                 % Source is set to reset state. Refer to user manual to see
                 % all implications
                  fprintf(obj.handler,'*RST'); %reset (manually set state to off) 
                  
                 % DEFAULT CONFIGURATION. GENERAL CONFIGURATION FUNCTION
                 % PENDENT <- IMPORTANT FOR REUSABILITY.
                        fprintf(obj.handler,'*CLS');
                        % DCV measurements 
                        fprintf(obj.handler,'SENSE:VOLTage:DC:RANGe 10');
                        fprintf(obj.handler,'SENSE:VOLTage:DC:RANGe:AUTO OFF');
                        fprintf(obj.handler,'SENSE:VOLTage:DC:RESolution 0.001'); % 4.5 digits
                        fprintf(obj.handler,'SENSE:VOLTage:DC:NPLCycles 1');

                         % display name
                        fprintf(obj.handler,['DISPlay:TEXT "',upper(obj.name2),'"']);
                  obj.state = 'init';
                  disp('Conection with Multimeter Stablished. You can measure!')
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the Multimeter. Please, check connection');
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
                disp('Error closing multimeter: device already closed');
            else
                try
                 fclose(obj.handler);
                 %delete(obj.handler);
                 obj.state = 'close';
                 disp('Multimeter: device closed. The brokil is over!');
                catch
                 disp('Multimeter:visa connection error');
                end
            end
            
        end
% ------------------------------------------------------------------------
        % Class destructor
        % Post: file is closed.
        % Post: State is close.
            function delete(obj)
                 fclose(obj.handler);
                 delete(obj.handler);
                 obj.state = 'close';
           % 
            
            end
        
  
        
        %READ
        function obj =READ(obj)
            if (strcmp(obj.state,'close'))
                disp('Error reading from multimeter: device is closed');
             else
                % read voltage
                fprintf(obj.handler,'READ?');
                obj.voltage=str2double(fscanf(obj.handler,'%s'));
                voltage = obj.voltage;
                % display value
                text=([upper(obj.name),': ',num2str(voltage,'%0.4f')]);
                fprintf(obj.handler,['DISPlay:TEXT "',text,'"']);
            end
        end
        
       
    end
end

