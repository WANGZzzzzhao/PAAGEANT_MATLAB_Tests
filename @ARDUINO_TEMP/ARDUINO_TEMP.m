classdef ARDUINO_TEMP < handle
    %ARDUINO_TEMP: 
    % Function WRITE to set a new N valude to the current bleeding
    % Function READ to read the value of the ADC and Temperature.
    
    properties (Constant)
        %instrument='Arduino Due';
        address='COM4'
        digitalPINs=[32:2:40,22:2:30] % MSB to LSB. Pins that are used to configure the digital number in the 
        %current bliding.
        dac_min=0
        dac_max=1023
        temp_address='0x48'
        adc_tmp1='A0'
        adc_tmp2='A1'
        % Power sensor connected to PA3
        adc_pwr_IN_PA3='A4'  %Input
        adc_pwr_OUT_PA3='A5'  %Output

        % Power sensor connected to PA2
        adc_pwr_IN_PA2='A6'  %Input
        adc_pwr_OUT_PA2='A7'  %Input
        
        %Libraries needed to connect the external absolute temperature
        %sensor.
        libraries='I2C'
    end
    properties
        handler=[]
        %name='arduinodue'
        state='close'
        %dac.name='dac' Value of N (10 bits);
        %dac_value {mustBeNonnegative(dac_value),mustBeLessThan(dac_value,1024)}=0
        dac_value = 0
        %temp.name='temp'
        temp_handler=[]
        % To store the analog value read in the ADC
        temp1
        temp2
        temp
        pwr1
        pwr2
        temps1
        temps2
        % to store the temperature of the external sensor
        temperature
        % Which Popwer amplifier is being measured?
        PA_measured {mustBeMember(PA_measured,{'PA1','PA2','PA3'})}='PA1' 
        % Error when the DAC search for a voltage value at the output
        error = 0
    end
    
    methods
        %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = ARDUINO_TEMP(PA_NUMBER)
           if nargin > 0 
               % Addess assigned to object property
                obj.PA_measured = PA_NUMBER; 
           else    % Else the default value is keept.
            disp('Default Com port assumed in the Arduino')
           end
           try
                obj.handler=arduino(obj.address,'due','Libraries',obj.libraries);
            catch
                disp('arduinodue connection error');
           end
            try
                obj.temp_handler=device(obj.handler,'I2CAddress',obj.temp_address); % tmp102
            catch
                disp('I2C connection error');
            end
             % change state
             obj.state='init';
              % init pins definitions
            for PIN=obj.digitalPINs
                % Pins used to give the code N to the current bleeding.
             configurePin(obj.handler,['D',num2str(PIN)],'DigitalOutput'); % enable pins as output
            end
            % Configuration of analog pins.
            configurePin(obj.handler,obj.adc_tmp1,'AnalogInput');
            configurePin(obj.handler,obj.adc_tmp2,'AnalogInput');
            configurePin(obj.handler,obj.adc_pwr_IN_PA3,'AnalogInput');
            configurePin(obj.handler,obj.adc_pwr_OUT_PA3,'AnalogInput');
            
            configurePin(obj.handler,obj.adc_pwr_IN_PA2,'AnalogInput');
            configurePin(obj.handler,obj.adc_pwr_OUT_PA2,'AnalogInput');
            
                
            % write configuration to the tempeature sensor
            write(obj.temp_handler, '0x0', 'uint8');
        end
             
      % ---------------------------------------------------------------------
      % WRITE: To set a N value to the DAC. 
      % Further improvements: to generate clock for the counter.
      % PRE: arduino is connected
      function set.dac_value(obj,value)
            value=max(value,obj.dac_min);
            value=min(value,obj.dac_max);
            obj.dac_value = value;
      end

      function obj = WRITE(obj,N)
          obj.dac_value = N;

          dac = obj.dac_value;

            % convert to binary
            dacb10=dec2bin(dac,10);

            % write dac value
            % from MSB to LSB
            i=1;
            for PIN=obj.digitalPINs
                writeDigitalPin(obj.handler,['D',num2str(PIN)],str2num(dacb10(i)));
                i=i+1;
            end
      end
        
      %-------------------------------------------------------------------
      % READ
      % READS from the four ADCs and external temperature sensor.
      % POST: updates the properties: obj.temperature, obj.temp1, obj.temp2
      %     obj.pwr1 and obj.pwr2
      % If this function is slow, we can select wich magnitude to read.
      function obj = READ(obj)
         
        % read data from external sensor and convert to celsius
        data=read(obj.temp_handler, 2, 'uint8');
        obj.temperature=(double(bitshift(int16(data(1)), 4)) + double(bitshift(int16(data(2)), -4))) * 0.0625;
        
        
        % Reading from ADC. Temp and PWD
        
        
        % Read the output of the selected temperature sensor
        AVG=10;
        obj.temp1=0;
        obj.temp2=0;
        obj.temps1 = zeros(1,AVG);
        obj.temps2 = zeros(1,AVG);
        if (strcmp(obj.PA_measured,'PA1'))
            for i=1:AVG
                % read tmp & average (too noisy)
                obj.temps1(i)=readVoltage(obj.handler,obj.adc_tmp1);
                obj.temp1=obj.temps1(i)/AVG + obj.temp1;
            end
            
            obj.temp = obj.temp1;
        elseif (strcmp(obj.PA_measured,'PA3'))
             for i=1:AVG
               % read tmp & average (too noisy)
                obj.temps2(i)=readVoltage(obj.handler,obj.adc_tmp2);
                obj.temp2=obj.temps2(i)/AVG + obj.temp2;
             end
            
            obj.temp = obj.temp2;
        else
            obj.temp = Nan;
        end
        
        % read pwr
         if (strcmp(obj.PA_measured,'PA2'))
            obj.pwr1=readVoltage(obj.handler,obj.adc_pwr_IN_PA2);
            obj.pwr2=readVoltage(obj.handler,obj.adc_pwr_OUT_PA2);
        elseif (strcmp(obj.PA_measured,'PA3'))
            obj.pwr1=readVoltage(obj.handler,obj.adc_pwr_IN_PA3);
            obj.pwr2=readVoltage(obj.handler,obj.adc_pwr_OUT_PA3);
        else
            obj.pwr1=Nan;
            obj.pwr2=Nan;
         end
      
      end
      
      %----------------------------------------------------------------
      % SEARCH_DAC
      % POST: The DAC has the value N that provides a DC sensor output
      % close to the desired_voltage passed as parameter
      function obj=SEARCH_DAC(obj,desired_voltage,type)
        %CENTER_DAC find best DAC value for TMP
        %   CONF = CENTER_DAC(CONF,DAC,TMP,type)
        %     "desired_voltage" : value to achive for temp
        %     "type" : full|close to search

         % print text
         c=fprintf('Searching DAC ...\n');

        %% DAC %%

        switch type

            case 'full' % search all posible values in three steps (100,10,1)

                % init ranges
                dacmin=obj.dac_min;
                dacmax=obj.dac_max;
                dacstep=100;
                

                for loop=1:3

                    % DAC values vector
                    dacrange=dacmin:dacstep:dacmax;
                    N = size(dacrange,2);
                    data = zeros(1,N); %Prealocation of memory for speed
                    
                    for i=1:N
                        %Writing the value to the DAC
                        obj.WRITE(dacrange(i));
                        pause(0.5);

                        % read TSENSOR, depending on PA measured
                        obj.READ;
                        switch obj.PA_measured
                            case 'PA1'
                                data(i) = obj.temp1;
                            case 'PA2'
                                data(i) = obj.temp2;
                        end

                    end

                    % find best value
                    [obj.error,index]=min(abs(data-desired_voltage));

                    % new center value
                    obj.dac_value=dacrange(index);
                    dacmin=obj.dac_value-dacstep;
                    dacmax=obj.dac_value+dacstep;
                    dacstep=dacstep/10;
                    % obj.dac_value contains the N whose vout is the closest to the target.                            
                end

                 

            case 'close' % search around current DAC

                % init ranges
                range=10;
                dacmin=obj.dac_value-range;
                dacmax=obj.dac_value+range;
                dacstep=1;

                % DAC values vector
                dacrange=dacmin:dacstep:dacmax;
                N = size(dacrange,2);
                data = zeros(1,N); %Prealocation of memory for speed
                
                
                 for i=1:N
                        %Writing the value to the DAC
                        obj.WRITE(dacrange(i));
                        pause(0.5);

                        % read TSENSOR, depending on PA measured
                        obj.READ;
                        switch obj.PA_measured
                            case 'PA1'
                                data(i) = obj.temp1;
                            case 'PA2'
                                data(i) = obj.temp2;
                        end

                 end

                    % find best value
                    [obj.error,index]=min(abs(data-desired_voltage));

                    % new center value
                    obj.dac_value=dacrange(index);
                    % obj.dac_value contains the N whose vout is the closest to the target.                            
        end
                  % write final value back to DAC
                obj.WRITE(obj.dac_value);
                obj.READ;

                % delete text
                fprintf(repmat('\b', 1, c));
               
      end
    end    
end

            


