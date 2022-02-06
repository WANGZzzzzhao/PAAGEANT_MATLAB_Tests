clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
rf_signal=AgilentE4438C('TCPIP0::192.168.137.24::inst0::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
rsnrp=SOURCE_RSNRP('GPIB0::25::INSTR');

%%%% set stress time %%%%
stress_time=60; %second
t = timer('TimerFcn', 'stat=false; disp(''Time over!'')',... 
                 'StartDelay',stress_time); 
%%%% set the stress value %%%%
source.v_pv6=3.3;
source.i_pv6=0.05;
    
pin=-10;
freq=100;
rf_signal.CONFIGURE(freq,pin);

%dc_bias.vgs=0.89;
%dc_bias.max_ig=0.04;
%dc_bias.vds=3.3;
%dc_bias.max_id=0.4;

%isen1b.vsen1b=2.51;
%isen1b.max_i=0.5;

WRITE(source,'on');
WRITE(rf_signal,'on');
%WRITE(dc_bias,'on');
%WRITE(isen1b,'on');

%%%% start stress %%%%
list_ids=[];
list_gain=[];
list_pout=[];

start(t)
stat=true;
while(stat==true)
    pause(10)
    READ(rsnrp);
    pout=rsnrp.power;
    gain=pout-pin;
        
    READ(dc_bias);
    ids=str2num(char(dc_bias.id));
       
    list_pout=[list_pout;pout];
    list_ids=[list_ids;ids];
    list_gain=[list_gain;gain];  
end
disp('Done!')
WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
WRITE(isen1b,'off');
WRITE(source,'off');

data_stress=struct('pout',list_pout,'ids',list_ids,...
                    'gain',list_gain,'time',stress_time);
save 'data_stress.mat';


