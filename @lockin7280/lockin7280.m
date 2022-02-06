classdef lockin7280 < handle
    %Wide bandwidth lock-in amplifier
    
    properties
        % Communication with the equipment
        address = 'GPIB0::26::INSTR'
        handler = []
        
        % To configure the equipment.
        vmode = '1'  %A Input only.
        cp = '1' %Slow input coupling mode. 
        float = '1' % Input connected to ground via a 1 kohm resistor
        refchannel = '2' %External. Front panel.
        TC = '17'  % 500ms time constant.
        autosens = 1 % 1 for autosensitivity. 0 for user choice
        sens = '20' % When user choice. 5 mV full sensitivity.
        autogain = 1 % 1 for auto gain selection. 0 for not.
        gain = '1' % 6dB gain. Only when no auto gain is selected.
        
        state = 'close'
        
        %Data to given by the lock-in
        samples = 10  %Number of samples taken
        mag  % magnitude value
        freq  % lock frequency
        ph      % phase value
        status   %STate of the equipment
    end
    
    methods
        %-----------------------------------------------------       
        % Class Constructor
        % POST1: the function stablishes connection with the device.
        % POST2: Updates internal state
        function obj = lockin7280(physical_address)
           if nargin > 0 
               % Addess assigned to object property
                obj.address = physical_address; 
           else    % Else the default value is keept.
            disp('Default GPIB Address for the lock-in is used')
           end
           
                try
                 % Let's try to connect with the device
                    obj.handler=visa('agilent', obj.address);
                    %obj.handler.OutputBufferSize = 1024;
                    %obj.handler.InputBufferSize = 102400;
                    fopen(obj.handler);
                 % Source is set to reset state. Refer to user manual to see
                 % all implications
                  obj.state = 'init';
                  disp('Conection with LockIn Stablished. You can measure!')
                  % Configure default device settings
                  % Commented the ones that are already start up situation
                  % of the lockin.
                  %fprintf(obj.handler,['VMODE ',obj.vmode]);
                  %fprintf(obj.handler,['CP ',obj.cp]);
                  %fprintf(obj.handler,['FLOAT ',obj.float]);
                  %fprintf(obj.handler,'REFMODE 0');
                  
                  % Reference channel
                  fprintf(obj.handler,['IE ',obj.refchannel]);  
                  % Full scale sensitivity
                  %if(obj.autosens == 1)
                  fprintf(obj.handler,'AS');
                  wait_five_tau(obj);
                  %else
                  %  fprintf(obj.handler,['SEN ',obj.sens]);
                  %end
                  % Gain
                  %if(obj.autogain == 1)
                  %  fprintf(obj.handler,'AUTOMATIC 1');
                  %else
                  %  fprintf(obj.handler,['ACGAIN ',obj.gain]);
                  %end
                  % Time constant
                  fprintf(obj.handler,['TC ',obj.TC]);
                  wait_five_tau(obj);
                  % Output filter slope: 12dB/dec
                  %fprintf(obj.handler,'SLOPE 1');
                catch
                   % If error... then inform to the user
                    disp('visa connection error with the LockIn. Please, check connection');
                end
            end
%--------------------------------------------------------------------------        
        % function CLOSE
        % Input parameter: 
        % the function closes connection with device.
        % POST: state is close
        function obj = CLOSE(obj)
            % Function to close the connection with lock in.
           % assume VISA connection (gpib or ethernet)
            %visa & fopen
            if (strcmp(obj.state,'close'))
                disp('Error closing LockIn: device already closed');
            else
                try
                 fclose(obj.handler);
                 %delete(obj.handler);
                 obj.state = 'close';
                 disp('Lockin: device closed. The brokil is over!');
                catch
                 disp('Lockin:visa connection error');
                end
            end
            
        end
% ------------------------------------------------------------------------
        % Class destructor
        % Post: file is closed.
        % Post: State is close.
            function obj = delete(obj)
                 fclose(obj.handler);
                 %delete(obj.handler);
                 obj.state = 'close';
            end
            
            
          % -------------------------------------------------------------
         % READ
         
         function obj = READ(obj)
        
            % Updates frequency, status, magnitude and phase
            % Frequency update
            
            obj.freq = str2double(query(obj.handler,'FRQ.'));
              if (obj.freq == 0)
                    disp('lockin without reference frequency')
                    return;
              end
            %obj.TC = query(obj.handler,'TC');
            % Auto Sensitivity before measurement
            fprintf(obj.handler,'AS');
            %Waiting 5 time constant.
            wait_five_tau(obj);
             % Status update
            st = query(obj.handler,'ST');
            obj.status=str2num(st);
             if (obj.status ~= 1)
%                 %If error, automatic sensitivity update
               fprintf(obj.handler,'AS');
               wait_five_tau(obj);
               disp('new sensitivity adjustement due status incorrect');
             end
            st = query(obj.handler,'ST');
            obj.status=str2num(st); 
            disp(['status of lock before measurements in is: ',st]);
            obj.mag=0;
            obj.ph=0;

                for i=1:obj.samples
                    % read phase and magnitude
                    obj.ph=str2double(query(obj.handler,'PHA.'))/obj.samples + obj.ph;
                    obj.mag=str2double(query(obj.handler,'MAG.'))/obj.samples + obj.mag;
                end
            st = query(obj.handler,'ST');
            obj.status=str2num(st);
            disp(['status of lock in after measurements is: ',st]);
         end
         
%          function obj = READ(obj)
%         
%             % Updates frequency, status, magnitude and phase
%             % Frequency update
%             new_freq = str2double(query(obj.handler,'FRQ.'));
%             % Flag variable
%             wait_5_tau = 0;
%             % Status update
%             st = query(obj.handler,'ST');
%             obj.status=str2num(st);
%             %disp(['status of lock in is: ',st]);
%             if (obj.freq == 0)
%                 disp('lockin without reference frequency')
%                 return;
%             end
%             %If new frequency, we need to wait for 5 tau.
%             if (obj.freq ~= new_freq)
%                 obj.freq = new_freq;
%                 wait_5_tau = 1;
%             end
% 
%             if (obj.status ~= 1)
%                 %If error, automatic sensitivity update
%                 fprintf(obj.handler,'AS');
%                 pause(2);
%                 %disp(['Once the sensitivity is adjunsted, status = ',query(obj.handler,'ST')]);
%                 obj.sens = query(obj.handler,'SEN');
%                 obj.TC = query(obj.handler,'TC');
%                 %disp(['la constant de temps es ',obj.TC])
%                 % Waiting 5 times the time constant.
%                 wait_5_tau = 1;
%                     
%             end
%             
%             %if the flag wait_5_tau is active, either sensitivity or
%             %frequency is new. For safety, waiting five tau before
%             %performing measurements.
%             if (wait_5_tau == 1)
%                 wait_five_tau(obj);
%                 wait_5_tau = 0;
%             end
%             % Status update
%             st = query(obj.handler,'ST');
%             obj.status=str2num(st);
%             %disp(['status of lock in is: ',st]);
%             obj.mag=0;
%             obj.ph=0;
% 
%                 for i=1:obj.samples
%                     % read phase and magnitude
%                     obj.ph=str2double(query(obj.handler,'PHA.'))/obj.samples + obj.ph;
%                     obj.mag=str2double(query(obj.handler,'MAG.'))/obj.samples + obj.mag;
%                 end
%          end
         
         %----------------------------------------------------------------
         % Configure: 
         function obj = CONFIGURE(obj, tc)
         % Used to change the time constant and to perform an
         % autosensitivty adjustment. Status is updated.
             if nargin > 1 
               % Change TIME CONSTANT if passed as parameter
                obj.TC = tc;
                fprintf(obj.handler,['TC ',obj.TC]);
             end
             % Frequency update
             obj.freq = str2double(query(obj.handler,'FRQ.'));
             % AutoSensitivity Adjunstement
             fprintf(obj.handler,'AS');
             % Wait for five tau for the equipment to setle for the new
             % freq of the new sensitivity.
             wait_five_tau(obj);
             % Status update
             obj.sens = query(obj.handler,'SEN');
             st = query(obj.handler,'ST');
             obj.status=str2num(st);
             %disp(['status of lock in CONFIGURE is: ',st]);
         end
     % ---------------------------------------------------------------
     % wait_five_tau(tau) 
     % pause the program five time constants.
     function obj = wait_five_tau(obj)
         % pauses the program five time constants.
         switch (obj.TC)
                    case '18'
                        pause(7);
                        %disp('18');
                    case '19'
                        pause(14);
                        %disp('19');
                    case '20'
                        pause(35);
                        %disp('20');
                    case '21'
                        pause(70);
                        %disp('21');
                    case '22'
                        pause(140);
                        %disp('22');
                    case '23'
                        pause(350);
                        %disp('23');

                    otherwise
                        pause(4);
                        %disp('Otherwise');
         end
     end
         
    end
end

