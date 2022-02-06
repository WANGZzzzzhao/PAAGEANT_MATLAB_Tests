clear 
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
source=SOURCE_E3631A('GPIB0::7::INSTR');
rf_signal=SOURCE_E4438C('TCPIP0::192.168.137.24::inst0::INSTR');
rspm=SOURCE_RSNRP('GPIB0::25::INSTR');
%calculate the whole time of this program
tic  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dc_bias.vgs=0.89;
dc_bias.max_ig=0.09;
dc_bias.vds=3.3;
dc_bias.max_id=0.09;
WRITE(dc_bias,'on');

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define lists of Id, Pout and Freq
listId=[];
listPout=[];
listFreq=[];
listPin=[];
for i=1:2
    %define lists of Pin, Pout Id and time in the loop
    listId1=[];
    listPout1=[]; 
    listPin1=[];

    %choose freq range and obtain freq list
    freq=100*i; 
    rf_signal.freq=freq;
    WRITE(rf_signal,'on');
    listFreq=[listFreq freq];
    %add legend to figure
    legend_str{i}=['Freq=',num2str(freq),'MHz'];
    pause(0.5);
    
   for j=0:30  

       %choose pin range and obtain Pin list
       pin=-20+j;
       rf_signal.power=pin;
       WRITE(rf_signal,'on');
       listPin1=[listPin1;pin];
       
       %obtain Id values
       READ(dc_bias);
       Id=str2num(char(dc_bias.id));
       listId1=[listId1;Id];
       %obtain Pout values
       READ(rspm);
       Pout=rspm.power;
       listPout1=[listPout1;Pout];
       
   end
   
   listId=[listId listId1];
   listPout=[listPout listPout1];
   listPin=[listPin listPin1];
   listGain=listPout-listPin;
end


%plot Pout and Pin
fig_Comp_Point=figure(1);

subplot(2,2,1)
line(listPin,listPout)
str = {'Vgs=0.89V','Vds=3.3V'};
text(-12,-10,str)

xlabel('Pin(dBm)')
ylabel('Pout(dBm)')
title('Compression point 1dB with Pout and Pin')
grid minor
legend(legend_str,'location','northwest')

%plot Pout and Id
subplot(2,2,2)
line(listPin,listId)
str = {'Vgs=0.89V','Vds=3.3V'};
text(-19,0.013,str)
xlabel('Pin(dBm)')
ylabel('Id(A)')
title('Compression point 1dB with Ids and Pin')
grid minor
legend(legend_str,'location','northwest')

subplot(2,2,3)
line(listPin,listGain)
xlabel('Pin(dBm)')
ylabel('Gain(dB)')
title('Compression point 1dB with Gain and Pin')
grid minor
legend(legend_str,'location','northwest')

%save figure
frame=getframe(fig_Comp_Point);
img=frame2im(frame);
imwrite(img,'fig_Comp_Point.jpg')
saveas(fig_Comp_Point,'fig_Comp_Point.fig')

%show the time of this program
toc

%save data
data_comp_point=struct('time',toc,'Pin',listPin,'Id',listId,...
                        'Pout',listPout,'Freq',listFreq,'Gain',listGain);
save 'data_comp_point.mat';

WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
WRITE(source,'off');
