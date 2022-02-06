classdef AgilentE4438C < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %instrument='Keysight E4438C';
        address='TCPIP0::192.168.137.24::inst0::INSTR';
        handler=[];
        %name='RF_signalgen';
        state='close';
        %out1.name='rfin';
        %out1.freq=200e6;
        %out1.power=-136; %dBm
        freq =200;  % MHz
        power=-136; %dBm
        mtonestate=0;
        ntones=2; %2tones
        fspacing=1013; %Hz %1013
        mtoneamplitude=-3; %dB
        
      
    end
    
    methods
        %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = AgilentE4438C(physical_address)
           if nargin > 0 
               % Addess assigned to object property
                obj.address = physical_address; 
           else    % Else the default value is keept.
            disp('Default GPIB Address for the E3631A used')
           end
           
                try
                 % Let's try to connect with the device
                    obj.handler=visa('agilent', obj.address);
                    %obj.handler=visadev(obj.address);
                    obj.handler.OutputBufferSize = 1024;
                    obj.handler.InputBufferSize = 102400;
                    fopen(obj.handler);
                 % Source is set to reset state. Refer to user manual to see
                 % all implications
                  fprintf(obj.handler,'*RST'); %reset (manually set state to off) 
                  obj.state = 'init';
                  disp('Conection with RF Signal Generator Stablished. Light-me UP!')
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the RF Signal Generator. Please, check connection');
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
            end
%--------------------------------------------------------------------------        
           % function CONFIGURE
        % Input parameter: voltage value, voltage limit and current limit
        % for both sources
        % POST: Properties for P6V and P25V are updated.  
         function obj = CONFIGURE(obj,varargin)
          % Input parameters should be in this order.
          %freq,power,ntones,fspacing
            obj.freq = varargin{1};
            obj.power =varargin{2};
             obj.mtonestate = 0;
            
          % Sending values to the equipment
           fprintf(obj.handler,['SOURce:POWer:LEVel:IMMediate:AMPLitude ', num2str(obj.power), ' DBM']);
           fprintf(obj.handler,['SOURce:FREQuency:CW ', num2str(obj.freq), ' MHz']);
          % If Mtone situation, parameters must be 6
            if nargin > 3   %TO BE FINISHED!!!!! IMPORTANT!!!!!!
                obj.mtonestate = 1;
                obj.ntones=varargin{3};
                obj.fspacing=varargin{4};
               % obj.mtoneamplitude=varargin{5}; %dB)
                
                % Sending values to the equipment
                
                fprintf(obj.handler,'*RST'); %reset (manually set state to off)
                 fprintf(obj.handler,['SOURce:FREQuency:CW ', num2str(obj.freq), ' MHz']);
                 fprintf(obj.handler,['SOURce:POWer:LEVel:IMMediate:AMPLitude ', num2str(obj.power), ' DBM']);
                 fprintf(obj.handler,['SOURce:RADio:MTONe:ARB:SETup:TABLe:NTONes ', num2str(obj.ntones)]);
                 fprintf(obj.handler,['SOURce:RADio:MTONe:ARB:SETup:TABLe:FSPacing ', num2str(obj.fspacing)]);
                 fprintf(obj.handler,['SOURce:RADio:MTONe:ARB:SETup:TABLe:ROW ', num2str('1, -3, 0, 1')]); %aqui caldria fer-ho dependre de les variables però de moment poso els numeros a lo bruto.
                 fprintf(obj.handler,['SOURce:RADio:MTONe:ARB:SETup:TABLe:ROW ', num2str('2, -3, 0, 1')]);
                % fprintf(resource.handler,['SOURce:RADio:MTONe:ARB:STATe 1', num2str(strcmp(resource.mtone,'1'))]);
                 
                 % These are in Quique's program... surely are important!!
                  % fprintf(resource.handler,['SOURce:RADio:MTONe:ARB:SETup default']);
                %fprintf(resource.handler,['SOURce:RADio:MTONe:ARB:STATe', num2str(strcmp(resource.mtone,'ON'))]);
            end
         end
           
         
           % function WRITE
        % PRE: voltage value and limits are already set.
        % PRE: source is activated.
        % POST: Source ON. Displays updated.
        function obj = WRITE(obj,status)
            if (strcmp(status,'off'))
                disp('RF Generator is OFF');
                switch(obj.mtonestate)
                    case 0
                        fprintf(obj.handler,['OUTPut:STATe 0']);
                    case 1
                        fprintf(obj.handler,'SOURce:RADio:MTONe:ARB:STATe 0');
                        fprintf(obj.handler,['OUTPut:STATe 0']);
                end
                obj.state = 'off';
            elseif (strcmp(status,'on'))
                switch(obj.mtonestate)
                    case 0
                        fprintf(obj.handler,['OUTPut:STATe 1']);
                    case 1
                        fprintf(obj.handler,'SOURce:RADio:MTONe:ARB:STATe 1');
                        fprintf(obj.handler,['OUTPut:STATe 1']);
                end
                disp('RF Generator is ON');
                obj.state = 'on';
            else
                disp('rf generator status not correct. Either on or off');
            end
        end   
         
         
         
    end
end

