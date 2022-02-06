classdef KeysightB2912A < handle
    %    To be filled.
    
   % properties
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
        address = 'TCPIP0::192.168.137.30::inst0::INSTR'
        handler = []
        %---------------------------------------------------
        %Internal variable to track the status of the source
        state {mustBeMember(state,{'close','init','active'})}='close'
        %---------------------------------------------------
        %Variables to set the P6V source.
        name_CH1 ='Chanel1' %Name to be displayed in the LCD
        voltage_CH1 = 0.0
        current_CH1 = 0.0
        currentlimit_CH1  = 0.05
        voltagelimit_CH1 = 1
        modeCH1 {mustBeMember(modeCH1,{'voltage','current'})}='voltage'
        %---------------------------------------------------
        %Variables to set the P6V source.
        name_CH2 ='Chanel2' %Name to be displayed in the LCD
        voltage_CH2  = 0.0
        current_CH2 = 0.0
        currentlimit_CH2 = 0.2
        voltagelimit_CH2 = 20e-3
        modeCH2 {mustBeMember(modeCH2,{'voltage','current'})}='voltage'
    end
    
    % EXTRACTED FROM DATA STRUCTURE BY QUIQUE.
    % Updated in the READ function
    properties
        measured_current_CH1
        measured_current_CH2
        measured_voltage_CH1
        measured_voltage_CH2
    end
    
    
    methods
         %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = KeysightB2912A(physical_address)
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
                  disp('Conection with SMU KeysightB2912A!. Be precise!')
                  % 
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the SMU. Please, check connection');
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
 
 %-------------------------------------------------------------------------
 % Function CONFIGURE
 % channel = 'CH1' or 'CH2'
 % mode = 'voltage' or 'current'
 % value = value of the source (either voltage or current)
 % limit = limit of the source (either current or voltage)
 function obj = CONFIGURE(obj,channel,mode,value,limit)
     switch (channel)
         case 'CH1'
                 switch mode
                     case 'voltage'
                         obj.voltage_CH1 = value;
                         obj.currentlimit_CH1 = limit;
                         obj.modeCH1 = 'voltage';
                         fprintf(obj.handler,'OUTPut1:OFF:MODE NORMal'); % normal off mode
                          fprintf(obj.handler,'SOURce1:FUNCtion:MODE VOLTage'); % voltage mode
                          fprintf(obj.handler,'SOURce1:VOLTage:MODE FIXed'); % fixed current mode
                          fprintf(obj.handler,['SENSe1:CURRent:DC:PROTection:LEVel ',num2str(obj.currentlimit_CH1)]);
                          fprintf(obj.handler,'OUTP1:ON:AUTO 0'); % disable auto on mode
                     case 'current'
                         obj.current_CH1 = value;
                         obj.voltagelimit_CH1 = limit;
                         obj.modeCH1 = 'current';
                          fprintf(obj.handler,'OUTPut1:OFF:MODE NORMal'); % normal off mode
                          fprintf(obj.handler,'SOURce1:FUNCtion:MODE CURRent'); % current mode
                          fprintf(obj.handler,'SOURce1:CURRent:MODE FIXed'); % fixed current mode
                          fprintf(obj.handler,['SENSe1:VOLTage:DC:PROTection:LEVel ',num2str(obj.voltagelimit_CH1)]);
                          fprintf(obj.handler,'OUTP1:ON:AUTO 0'); % disable auto on mode
                  end
           case 'CH2'
                 switch mode
                     case 'voltage'
                         obj.voltage_CH2 = value;
                         obj.currentlimit_CH2 = limit;
                          obj.modeCH2 = 'voltage';
                           fprintf(obj.handler,'OUTPut2:OFF:MODE NORMal'); % normal off mode
                          fprintf(obj.handler,'SOURce2:FUNCtion:MODE VOLTage'); % voltage mode
                          fprintf(obj.handler,'SOURce2:VOLTage:MODE FIXed'); % fixed current mode
                          fprintf(obj.handler,['SENSe2:CURRent:DC:PROTection:LEVel ',num2str(obj.currentlimit_CH2)]);
                          fprintf(obj.handler,'OUTP2:ON:AUTO 0'); % disable auto on mode
                     case 'current'
                         obj.current_CH2 = value;
                         obj.voltagelimit_CH2 = limit;  
                         obj.modeCH2 = 'current';
                         fprintf(obj.handler,'OUTPut2:OFF:MODE NORMal'); % normal off mode
                          fprintf(obj.handler,'SOURce2:FUNCtion:MODE CURRent'); % current mode
                          fprintf(obj.handler,'SOURce2:CURRent:MODE FIXed'); % fixed current mode
                          fprintf(obj.handler,['SENSe2:VOLTage:DC:PROTection:LEVel ',num2str(obj.voltagelimit_CH2)]);
                          fprintf(obj.handler,'OUTP2:ON:AUTO 0'); % disable auto on mode
                 end
     end
end
     
 %-------------------------------------------------------------------------
 % Function WRITE
 % mode = 'on' to turn the source on. 'off' to turn it off.
 % PRECONDITION: limit values and channel configuration is done.
     function obj = WRITE(obj,mode)
         switch (mode)
             case 'on'
                switch (obj.modeCH1)
                    case 'voltage'
                         fprintf(obj.handler,['SOURce1:VOLTage:LEVel:IMMediate:AMPLitude ',num2str(obj.voltage_CH1)]);
                     case 'current'    
                          fprintf(obj.handler,['SOURce1:CURRent:LEVel:IMMediate:AMPLitude ',num2str(obj.current_CH1)]);
                end
                switch (obj.modeCH2)
                    case 'voltage'
                         fprintf(obj.handler,['SOURce2:VOLTage:LEVel:IMMediate:AMPLitude ',num2str(obj.voltage_CH2)]);
                     case 'current'    
                          fprintf(obj.handler,['SOURce2:CURRent:LEVel:IMMediate:AMPLitude ',num2str(obj.current_CH2)]);
                end
                fprintf(obj.handler,'OUTPut1:STATe ON');
                fprintf(obj.handler,'OUTPut2:STATe ON');
            case 'off'
                fprintf(obj.handler,'OUTPut1:STATe OFF');
                fprintf(obj.handler,'OUTPut2:STATe OFF');
                
         end
     end
%-------------------------------------------------------------------------
% Function READ
% mode = 'on' to turn the source on. 'off' to turn it off.
% PRECONDITION: limit values and channel configuration is done. 
     function obj = READ(obj)
            obj.measured_voltage_CH1=query(obj.handler,['MEASure:VOLTage:DC? (@1)']);
            obj.measured_voltage_CH2=query(obj.handler,['MEASure:VOLTage:DC? (@2)']);
            obj.measured_current_CH1=query(obj.handler,['MEASure:CURRent:DC? (@1)']);
            obj.measured_current_CH2=query(obj.handler,['MEASure:CURRent:DC? (@2)']);           
     end
    end
end