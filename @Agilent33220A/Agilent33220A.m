classdef Agilent33220A < handle
    % Low Frequency Arbitrary function generator.
    % Basic class just to be used as reference of the lock-in
    
    properties
        %genera la senyal de referència per al lock in amplifier
        %instrument='Agilent 33220A';
        address='TCPIP0::192.168.137.23::inst0::INSTR'
        handler=[]
        %name='Arbitrary Waveform Signal Generator'
        state='close'
        freq=1013   %HZ
        amplitude=0.1
        shape='SQUare'
        dcycle=50
    end
    
    methods
          %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = Agilent33220A(physical_address)
           if nargin > 0 
               % Addess assigned to object property
                obj.address = physical_address; 
           else    % Else the default value is keept.
            disp('Default GPIB Address for the Arbitrary Function Generator used')
           end
           
                try
                 % Let's try to connect with the device
                    obj.handler=visa('agilent', obj.address);
                    %obj.handler.OutputBufferSize = 1024;
                    %obj.handler.InputBufferSize = 102400;
                    fopen(obj.handler);
               
                  obj.state = 'init';
                  disp('Conection with AWG!. Dance with me!')
                  
                  % Default settings sent to the equipment
                  fprintf(obj.handler,'*RST'); %reset (manually set state to off)
                  fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.amplitude)]);
                    fprintf(obj.handler,['SOURce:FREQuency:CW ', num2str(obj.freq)]);
                    fprintf(obj.handler,['SOURce:FUNCtion:SHAPe ', obj.shape]);
                    fprintf(obj.handler,['SOURce:FUNCtion:SHAPe:SQUare:DCYCle ', num2str(obj.dcycle)]);
                  % 
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the AWG. Please, check connection');
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
         % frequency = frequency of the output signal
         % amplitude 
         % shape / square,sin,triang. Just works for square.
         % Duty
         
         %function obj = CONFIGURE(obj,frequency,ampl,shape,duty)
         function obj = CONFIGURE(obj,frequency)
             obj.freq=frequency;   %1013
           % obj.amplitude=ampl;
            %obj.shape='SQUare'; % To change: other shapes.
            %obj.dcycle=duty;
            
            fprintf(obj.handler,'*RST'); %reset (manually set state to off)
            fprintf(obj.handler,['SOURce:VOLTage:LEVel:IMMediate:AMPLitude ', num2str(obj.amplitude)]);
            fprintf(obj.handler,['SOURce:FREQuency:CW ', num2str(obj.freq)]);
            fprintf(obj.handler,['SOURce:FUNCtion:SHAPe ', obj.shape]);
            fprintf(obj.handler,['SOURce:FUNCtion:SHAPe:SQUare:DCYCle ', num2str(obj.dcycle)]);
            
         end
         
         %-------------------------------------------------------------------------
         % Function WRITE
         % mode = 'on' to turn the source on. 'off' to turn it off.
         % PRECONDITION: limit values and channel configuration is done.
             function obj = WRITE(obj,mode)
                 switch (mode)
                        case 'on'
                            fprintf(obj.handler,['OUTPut:STATe ON']);
                            obj.state = 'running';
                         case 'off'
                            fprintf(obj.handler,'OUTPut1:STATe OFF');
                            obj.state = 'init';
                 end
             end

        
        
    end
end

