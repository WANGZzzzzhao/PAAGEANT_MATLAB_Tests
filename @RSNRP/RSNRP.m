classdef RSNRP < handle
    %Rode $ Schwars NRP Power Metter
    %   Detailed explanation goes here
    
    properties
        %instrument='R&S NRP-Z11';  % Commented are all properties that
        %appear in Quique's programm to save data to file.
        address='GPIB0::25::INSTR'
        handler=[]
        %INSTR.name='RF_powermeter';
        state='close'
        %INSTR.inp1.name='rfout';
        freq =200e6  % Hz
        power  % Value that is measured.
    end
    
    methods
                 %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = RSNRP(physical_address)
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
                  disp('Conection with Power Metter!. Do not get burnt!')
                % init configuration mode
                fprintf(obj.handler,'*RST'); %reset (manually set state to off)

                % reduce adquisition time (maybe not needed when using MEAS for reading results
                fprintf(obj.handler,'SENSe:AVERage:COUNt:AUTO OFF');
                fprintf(obj.handler,'SENSe:AVERage:COUNt:AUTO:MTIMe 1');
                fprintf(obj.handler,'SENSe:AVERage:COUNt:AUTO:RESolution 1');
                % set output freq/power to the default value. Can be
                % changed in CONFIGURE
                fprintf(obj.handler,['SENSe:FREQuency ', num2str(obj.freq), ' Hz']);                  
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
         % -------------------------------------------------------------
         % CONFIGURE
         % Set the frequency. Instructions in the class constructor can be
         % moved here in further versions of the class.
         function obj = CONFIGURE(obj,frequency)
             obj.freq = frequency;
              fprintf(obj.handler,['SENSe:FREQuency ', num2str(obj.freq), ' Hz']); 
         end
         
         % -------------------------------------------------------------
         % READ
         function obj = READ(obj)
             % read 256 samples
                fprintf(obj.handler,'MEAS:XTIMe? (256), 10 ms');
                read_power=str2double(split(fscanf(obj.handler,'%s',256),','));

            % save data

                obj.power = mean(read_power);
         end

    end
end

