clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
rf_2t=AgilentE4438C('TCPIP0::192.168.137.24::inst0::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=Keysight_34401A('GPIB0::5::INSTR');
sg=Agilent33220A('TCPIP0::192.168.137.23::inst0::INSTR');
lockin=lockin7280('GPIB0::26::INSTR');
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

lockin.CONFIGURE('18');

def_frequence = [1013 10013 100013];
freq=100;
vtemp_th=1.65;

list_N_min=[];
list_freq=[];
list_vp=[];
list_ph=[];
list_pin=[];
list_vtemp=[];
list_pout=[];
list_Error=[];
list_ids=[];
list_temp=[];
list_pwr1=[];
list_pwr2=[];
for i=1:3
    list_N_min1=[];
    list_vp1=[];
    list_ph1=[];
    list_pin1=[];
    list_vtemp1=[];
    list_pout1=[];
    list_Error2=[];
    list_ids1=[];
    list_temp1=[];
    list_1pwr1=[];
    list_1pwr2=[];
    
    df = def_frequence(i);
    N_min=120;
    
    legend_str{i}=['freq=',num2str(df),'Hz'];   
    sg.CONFIGURE(df);

    for j=1:31
        list_Error1=[];
        pin=-21+j;
        rf_2t.CONFIGURE(freq,pin,2,df);
        WRITE(rf_2t,'on');       
        list_pin1=[list_pin1;pin];
        pause(1);
        WRITE(ard, N_min);
        pause(0.5);
        disp('Err_min before while');
        READ(tmp1);
        tmp1.voltage
        Error_min = abs(tmp1.voltage - vtemp_th);
        N_DETECTED = 0;
        
        while (N_DETECTED == 0)
            N_min = N_min +1;
            WRITE(ard,N_min);
            pause(0.5);
            READ(tmp1);
            disp('Error Calculation');
            vtempa=tmp1.voltage;
            Error = abs(vtempa - vtemp_th);
            list_Error1=[list_Error1;Error];
                if (Error < Error_min)  % This means that we are getting closer to the good value
                    Error_min = Error;
                else
                    N_DETECTED = 1;
                    N_min = N_min-1 ;  % the best N value was the previous one
                    WRITE(ard,N_min);
                    list_N_min1=[list_N_min1; N_min];
                    %pause(1);   
                end  
        end 
        
        READ(dc_bias);
        ids=str2num(char(dc_bias.id));
        
        READ(ard)
        temp=ard.temperature;
        power_detector=ard.pwr1;
        power_detector2=ard.pwr2;
        
        pause(1);
        READ(tmp1);
        vtemp=tmp1.voltage;
      
        READ(lockin);
        vtemp_power=lockin.mag;
        phase=lockin.ph;
        
        READ(rsnrp);
        pout=rsnrp.power;
        
        list_ids1=[list_ids1;ids];
        list_temp1=[list_temp1;temp];
        list_1pwr1=[list_1pwr1;power_detector];
        list_1pwr2=[list_1pwr2;power_detector2];
        list_pout1=[list_pout1; pout];
        list_vtemp1=[list_vtemp1;vtemp];
        list_vp1=[list_vp1;vtemp_power];
        list_ph1=[list_ph1;phase];
        list_Error2=[list_Error2;list_Error1];
        
%         pause(10);
%         disp('the values after 10 seconds are: ');
%         READ(lockin);
%         vtemp_powerb=lockin.mag
%         phaseb=lockin.ph
          
    end
    list_N_min=[list_N_min list_N_min1];
    list_vp=[list_vp list_vp1];
    list_ph=[list_ph list_ph1];
    list_pin=[list_pin list_pin1];
    list_vtemp=[list_vtemp list_vtemp1];
    list_pout=[list_pout list_pout1];
%     list_Error=[list_Error list_Error2];
    list_ids=[list_ids;list_ids1];
    list_temp=[list_temp list_temp1];
    list_pwr1=[list_pwr1 list_1pwr1];
    list_pwr2=[list_pwr2 list_1pwr2];
    list_gain=list_pout-list_pin;
end

fig_TS_2T_Pin_Vtemp=figure(1);

subplot(2,2,1)

semilogy(list_pin,list_vp)
grid minor
xlabel('Pin(dBm)')
ylabel('Vtemp Power')
title('2 tones : Characteristic of Pin and Vtemp Power')
legend(legend_str,'location','northwest')

subplot(2,2,2)
plot(list_pin,list_vtemp)
xlabel('Pin(dBm)')
ylabel('Vtemp')
legend(legend_str,'location','northwest')

subplot(2,2,3)
plot(list_pin,list_pout)
xlabel('Pin(dBm)')
ylabel('Pout(dBm)')
legend(legend_str,'location','northwest')

subplot(2,2,4)
plot(list_pin,list_N_min)
xlabel('Pin(dBm)')
ylabel('N')
legend(legend_str,'location','northwest')


frame=getframe(fig_TS_2T_Pin_Vtemp);
img=frame2im(frame);
imwrite(img,'fig_TS_2T_Pin_Vtemp.jpg')
saveas(fig_TS_2T_Pin_Vtemp,'fig_TS_2T_Pin_Vtemp.fig')

%show the time of this program
toc
disp(['time of program: ',num2str(toc)])

data_TS_2T_Pin_Vtemp=struct('pin',list_pin,'freq',list_freq,'vtemp',list_vtemp,...
                    'Nmid',list_N_min,'vtemp_power',list_vp,'ids',list_ids,'gain',list_gain,...
                    'phase',list_ph,'time',toc,'pout',list_pout,'deltaF',def_frequence,...
                    'temperature',list_temp,'pwr1',list_pwr1,'pwr2',list_pwr2);
                    
save 'data_TS_2T_Pin_Vtemp.mat';


WRITE(isen1b,'off');
WRITE(dc_bias,'off');
WRITE(rf_2t,'off');
WRITE(sg,'off');
CLOSE(lockin);
CLOSE(tmp1);
WRITE(source,'off');



