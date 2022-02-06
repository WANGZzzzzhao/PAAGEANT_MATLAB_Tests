clear
% New bias point: Vgs=0.89V,0.8114V,0.7593V 
% with pout decreases 2dBm every time

source=SOURCE_E3631A('GPIB0::7::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=Keysight_34401A('GPIB0::5::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
rf_2t=AgilentE4438C('TCPIP0::192.168.137.24::inst0::INSTR');
rsnrp=SOURCE_RSNRP('GPIB0::25::INSTR');
lockin=lockin7280('GPIB0::26::INSTR');
sg=Agilent33220A('TCPIP0::192.168.137.23::inst0::INSTR');

def_frequency = 10013;
%calculate the whole time of this program
tic 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

dc_bias.vgs=0.89;
dc_bias.max_ig=0.1;
dc_bias.vds=3.3;
dc_bias.max_id=0.4;
WRITE(dc_bias,'on');
READ(dc_bias);

WRITE(ard,0);

rf_2t.CONFIGURE(100,-20,2,def_frequency);
WRITE(rf_2t,'on');

sg.CONFIGURE(def_frequency);
%WRITE(sg,'on');

isen1b.vsen1b=2.51;
isen1b.max_i=0.5;
WRITE(isen1b,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Bias_Vgs=[0.89 0.8114 0.7593];
vtemp_th=1.65;
  

list_freq=[];
list_vtemp=[];
list_vp=[];
list_ph=[];
list_ids=[];
list_pout=[];
list_pin=[];
list_N_min=[];
list_temp=[];
list_pwr1=[];
list_pwr2=[];
list_vgs=[];

for i=1:7
    %definition of tables in the loop
    list_pin1=[];
    list_vtemp2=[];
    list_vp2=[];
    list_ph2=[];
    list_pout1=[];
    list_ids1=[];
    list_N_min1=[];
    list_temp1=[];
    list_1pwr1=[];
    list_1pwr2=[];
    
    N_min=110;
    vgs=0.69+0.05*i;
    dc_bias.vgs=vgs;
    WRITE(dc_bias,'on');
    list_vgs=[list_vgs;vgs];
    
    legend_str{i}=['vgs=',num2str(vgs),'V'];
    for j=1:31 % 31
       % definition of tables in the loop
        list_vtemp1=[];
        
        pin=-21+j;%-21+j
        rf_2t.CONFIGURE(100,pin,2,def_frequency);
        WRITE(rf_2t,'on');
        
        list_pin1=[list_pin1;pin];
        pause(1);        
             
        WRITE(ard,N_min);
        pause(0.5);
		READ(tmp1);
		tmp1.voltage
        Error_min = abs(tmp1.voltage - vtemp_th);
		N_DETECTED = 0 ;

		while (N_DETECTED == 0)           
			N_min = N_min + 1 ;
			WRITE(ard,N_min);
            pause(0.5);
			READ(tmp1);
			vtempa = tmp1.voltage;
			Error = abs(vtempa-vtemp_th);
 			
			if (Error <= Error_min)
				Error_min = Error;
			else
				N_DETECTED = 1;
				N_min = N_min-1;
				WRITE(ard,N_min);
				list_N_min1=[list_N_min1;N_min];
				
            end
        end
        pause(1);
        % read data
        READ(rsnrp);
        pout=rsnrp.power;
        list_pout1=[list_pout1; pout];
        
        READ(dc_bias);
        ids=str2num(char(dc_bias.id));
        list_ids1=[list_ids1;ids];
        
        READ(tmp1);
        vtemp=tmp1.voltage;
        list_vtemp2=[list_vtemp2;vtemp];
        
        READ(lockin);
        vtemp_power=lockin.mag;
        phase=lockin.ph;        
        list_vp2=[list_vp2;vtemp_power];
        list_ph2=[list_ph2;phase];
        
        READ(ard);
        temp=ard.temperature;
        power_detector=ard.pwr1;
        power_detector2=ard.pwr2;
        list_temp1=[list_temp1;temp];
        list_1pwr1=[list_1pwr1;power_detector];
        list_1pwr2=[list_1pwr2;power_detector2];
    end
    
    list_pout=[list_pout list_pout1];
    list_ids=[list_ids list_ids1];
    list_vtemp=[list_vtemp list_vtemp2];
    list_vp=[list_vp list_vp2];
    list_ph=[list_ph list_ph2];
    list_pin=[list_pin1 list_pin];
    list_N_min=[list_N_min list_N_min1];
    list_temp=[list_temp list_temp1];
    list_pwr1=[list_pwr1 list_1pwr1];
    list_pwr2=[list_pwr2 list_1pwr2];
    list_gain=list_pin-list_pout;
end

%plot and save figure
fig_TS_2T_Diff_Bias=figure(1);

subplot(2,1,1)
plot(list_pin,list_N_min);

grid minor
xlabel('Pin(dBm)')
ylabel('N')
xlim([list_pin(1) list_pin(end)])
legend(legend_str,'location','southwest')
title('2tones : Characteristic of Pin and N with different bias points')

subplot(2,1,2)
plot(list_pin,list_pout);
xlabel('Pin(dBm)')
ylabel('Pout(dBm)')
title('Pin/Pout')

frame=getframe(fig_TS_2T_Diff_Bias);
img=frame2im(frame);
imwrite(img,'fig_TS_2T_Diff_Bias.jpg')
saveas(fig_TS_2T_Diff_Bias,'fig_TS_2T_Diff_Bias.fig')

%show the time of this program
toc
disp(['time of program: ',num2str(toc)])

%save all the data
data_TS_2T_Diff_Bias=struct('vtemp',list_vtemp,'gain',list_gain,'time',toc,...
                                'pin',list_pin,'freq',list_freq,'Ids',list_ids,...
                                'Nmid',list_N_min,'Vgs',list_vgs,'temperature',list_temp,...
                                'phase',list_ph,'pwr1',list_pwr1,'pwr2',list_pwr2);
                                

save 'data_TS_2T_Diff_Bias.mat';
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
WRITE(isen1b,'off');
WRITE(dc_bias,'off');
WRITE(rf_2t,'off');
WRITE(sg,'off');
CLOSE(lockin);
CLOSE(tmp1);
WRITE(source,'off');





