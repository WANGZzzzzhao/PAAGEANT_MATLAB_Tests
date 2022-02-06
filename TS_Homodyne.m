clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=SOURCE_34401A('GPIB0::5::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
rf_signal=SOURCE_E4438C('TCPIP0::192.168.137.24::inst0::INSTR');
rsnrp=SOURCE_RSNRP('GPIB0::25::INSTR');
%calculate the whole time of this program
tic 

N_init=30;
N_number=170;

%%%%%%%%%%%%%%%%%%%%%%%%%%%   non bias  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values% 
%%%%%%%%%%%%%%%%%%%

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

isen1b.vsen1b=2.51;
isen1b.max_i=0.2;
WRITE(isen1b,'on');

WRITE(ard,0);

%%%%%%%%%%%%%%%%%%
%start of program% 
%%%%%%%%%%%%%%%%%%

list_vtemp_non_bias=[];
list_N=[];

for i=1:N_number
   N=N_init+i;
   WRITE(ard,N);
   READ(tmp1);
   READ(ard);
   vtemp_non_bias=tmp1.vtemp;
   
   list_vtemp_non_bias=[list_vtemp_non_bias;vtemp_non_bias];
   list_N=[list_N;N];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  bias  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values% 
%%%%%%%%%%%%%%%%%%%

dc_bias.vgs=0.89;
dc_bias.max_ig=0.04;
dc_bias.vds=3.3;
dc_bias.max_id=0.4;
WRITE(dc_bias,'on');
READ(dc_bias);

WRITE(ard,0);

%%%%%%%%%%%%%%%%%%
%start of program% 
%%%%%%%%%%%%%%%%%%

list_vtemp_bias=[];
list_N2=[];
   
for j=1:N_number
   N2=N_init+j;
   WRITE(ard,N2);
   READ(tmp1);
   READ(ard);
   vtemp_bias=tmp1.vtemp;
   
   list_vtemp_bias=[list_vtemp_bias;vtemp_bias];
   list_N2=[list_N2;N2];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%  bias + rf  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values% 
%%%%%%%%%%%%%%%%%%%
rf_signal.freq = 50;
rf_signal.power = -20;
WRITE(rf_signal,'on');

WRITE(ard,0);

%%%%%%%%%%%%%%%%%%
%start of program% 
%%%%%%%%%%%%%%%%%%

list_freq=[];
list_pin=[];
list_vtemp_rf=[];
list_temp=[];
list_pwr1=[];
list_pwr2=[];
list_pout=[];
list_ids=[];

for i=1:1 
    
	list_pin1=[];
	list_vtemp2_rf=[];
    list_temp2=[];
    list_2pwr1=[];
    list_2pwr2=[];
    list_pout1=[];
    list_ids1=[];

    
    freq=100*j;
    rf_signal.freq=freq;
    WRITE(rf_signal,'on');
	list_freq=[list_freq; freq];
    
    
	for j=1:3 %0:30

		list_vtemp1_rf=[];
        list_temp1=[];
        list_1pwr1=[];
        list_1pwr2=[];
		list_N3=[];

		pin=-30+10*i;
        rf_signal.power=pin;
        WRITE(rf_signal,'on');
	    list_pin1=[list_pin1; pin];
		
        %legend_str2{j+1}=['Pin=',num2str(pin),'dBm'];
        
		for k=1:N_number 
            
			N3=N_init+k;
			WRITE(ard,N3);
			READ(tmp1);
			READ(ard);
			vtemp_rf=tmp1.vtemp;
            temp=ard.temperature;
            power_detector=ard.pwr1;
            power_detector2=ard.pwr2;
			list_N3=[list_N3;N3];
			list_vtemp1_rf=[list_vtemp1_rf; vtemp_rf];
            list_temp1=[list_temp1;temp];
            list_1pwr1=[list_1pwr1;power_detector];
            list_1pwr2=[list_1pwr2;power_detector2];
        end
        READ(rsnrp);
        pout=rsnrp.power;
        list_pout1=[list_pout1; pout];
        READ(dc_bias);
        ids=str2num(char(dc_bias.id));
        list_ids1=[list_ids1;ids];
		list_vtemp2_rf=[list_vtemp2_rf list_vtemp1_rf];
        list_temp2=[list_temp2;list_temp1];
        list_2pwr1=[list_2pwr1;list_1pwr1];
        list_2pwr2=[list_2pwr2;list_1pwr2];
    end
    
	list_vtemp_rf=[list_vtemp_rf list_vtemp2_rf];
    list_temp=[list_temp;list_temp2];
    list_pwr1=[list_pwr1;list_2pwr1];
	list_pin=[list_pin list_pin1];
    list_pout=[list_pout list_pout1];
    list_ids=[list_ids list_ids1];
    list_gain=list_pout-list_pin;
end


fig_TS_Homodyne=figure(1);
plot(list_N,list_vtemp_non_bias,'--');
hold on
plot(list_N2,list_vtemp_bias,'k-.');
hold on
plot(list_N3,list_vtemp_rf,':');
hold off

grid minor
xlabel('N')
ylabel('Vtemp(V)')
xlim([list_N(1) list_N(end)])
str={'Freq=',num2str(freq)};
text(60,2,str)
title('TS_Homodyne')
legend('non bias','bias','with rf signal','location','southwest')

frame=getframe(fig_TS_Homodyne);
img=frame2im(frame);
imwrite(img,'fig_TS_Homodyne.jpg');
saveas(fig_TS_Homodyne,'fig_TS_Homodyne.fig')

%show the time of this program
toc

data_TS_Homodyne=struct('vtemp_bias',list_vtemp_bias,'vtemp_non_bias',list_vtemp_non_bias,...
                        'N',list_N,'N2',list_N2,'N3',list_N3,'pin',list_pin,...
                       'freq',list_freq,'pout',list_pout,'ids',list_ids,'time',toc,...
                       'temperature',list_temp,'pwr1',list_pwr1,'pwr2',list_pwr2,'vtemp_rf',list_vtemp_rf);
save 'data_TS_Homodyne.mat';

WRITE(isen1b,'off');
WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
CLOSE(tmp1);
WRITE(source,'off');