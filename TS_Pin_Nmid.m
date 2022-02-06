clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=Keysight_34401A('GPIB0::5::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
rf_signal=AgilentE4438C('TCPIP0::192.168.137.24::inst0::INSTR');
rsnrp=SOURCE_RSNRP('GPIB0::25::INSTR');
%calculate the whole time of this program
tic 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

dc_bias.vgs=0.89;
dc_bias.max_ig=0.04;
dc_bias.vds=3.3;
dc_bias.max_id=0.4;
WRITE(dc_bias,'on');
READ(dc_bias);

isen1b.vsen1b=2.51;
isen1b.max_i=0.5;
WRITE(isen1b,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
vtemp_th = 1.65 ;
list_pin=[];
list_freq=[];
list_vtemp=[];
list_pout=[];
list_N_min=[];
list_Id=[];
list_temp=[];
list_pwr1=[];
list_pwr2=[];
for i=1:1
    
    list_pin1=[];
	list_pout1=[];
	list_vtemp1=[];
	list_N_min1=[];
    list_Id1=[];
    list_temp1=[];
    list_1pwr1=[];
    list_1pwr2=[];
	
	freq = 100*i;
	N_min=120;
	list_freq=[list_freq;freq];
	legend_str{i}=['freq=',num2str(freq),'MHz'];

    
    for j=1:31
        
        pin=-21+j;
        rf_signal.CONFIGURE(freq,pin);
        WRITE(rf_signal,'on'); 
        
        list_pin1 = [list_pin1; pin];

		WRITE(ard,N_min);
		READ(tmp1);
		tmp1.voltage;
		
		Error_min = abs(tmp1.voltage - vtemp_th);
		N_DETECTED = 0 ;

		while (N_DETECTED == 0)           
			N_min = N_min + 1 ;
			WRITE(ard,N_min);
			READ(tmp1);
			vtempa = tmp1.voltage;
			Error = abs(vtempa-vtemp_th);
 			
			if (Error<Error_min)
				Error_min = Error;
			else
				N_DETECTED = 1;
				N_min = N_min-1;
				WRITE(ard,N_min);
				list_N_min1=[list_N_min1;N_min];
				
            end
                    
        end
        READ(tmp1);
        vtemp=tmp1.voltage;
	
        READ(rsnrp);
        pout=rsnrp.power;
        
        READ(dc_bias);
        Id=str2num(char(dc_bias.id));
        
        READ(ard)
        temp=ard.temperature;
        power_detector=ard.pwr1;
        power_detector2=ard.pwr2;
        
        list_Id1=[list_Id1;Id];
    	list_vtemp1=[list_vtemp1;vtemp];
        list_pout1=[list_pout1;pout];
        list_temp1=[list_temp1;temp];
        list_1pwr1=[list_1pwr1;power_detector];
        list_1pwr2=[list_1pwr2;power_detector2];
        
    end
    list_pin=[list_pin list_pin1];
    list_vtemp=[list_vtemp list_vtemp1];
    list_pout=[list_pout list_pout1];
    list_N_min=[list_N_min list_N_min1];
    list_Id=[list_Id list_Id1];
    list_temp=[list_temp list_temp1];
    list_pwr1=[list_pwr1 list_1pwr1];
    list_pwr2=[list_pwr2 list_1pwr2];
    list_gain=list_pin-list_pout;
end

Pin_Nmid=figure(1);
subplot(2,1,1)
plot(list_pin,list_N_min);
grid minor
xlabel('Pin(dBm)')
ylabel('N')
title('Caracteristic of Pin and Nmid')
legend(legend_str,'location','northwest')
	
subplot(2,1,2)
plot(list_pin,list_pout)
xlabel('Pin(dBm)')
ylabel('Pout(dBm)')
legend(legend_str,'location','northwest')

frame=getframe(Pin_Nmid);
img=frame2im(frame);
imwrite(img,'Pin_Nmid.jpg')
saveas(Pin_Nmid,'Pin_Nmid.fig')

toc
disp(['time of this program : ',num2str(toc)])

data_Pin_Nmid=struct('pin',list_pin,'freq',list_freq,'vtemp',list_vtemp,...
                    'pout',list_pout,'Nmid',list_N_min, 'time',toc,'ids',list_Id,...
                    'gain',list_gain,'temperature',list_temp,'pwr1',list_pwr1,'pwr2',list_pwr2);

save 'data_Pin_Nmid.mat';

WRITE(isen1b,'off');
WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
CLOSE(tmp1);
WRITE(source,'off');



