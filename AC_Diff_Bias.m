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
dc_bias.max_ig=0.05;
dc_bias.vds=3.3;
dc_bias.max_id=0.09;
WRITE(dc_bias,'on');

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

rf_signal.freq = 100;
WRITE(rf_signal,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define lists of Id, Pout and Freq
listId=[];
listPout=[];
listvgs=[];
listGain=[];
listPin=[];
for i=0:6
    %define lists of Pin, Pout Id and time in the loop
    listId1=[];
    listPout1=[]; 
    listGain1=[];
    listPin1=[];
    
    %choose vgs range and obtain vgs list
    vgs=0.74+0.05*i; 
    dc_bias.vgs=vgs;
    WRITE(dc_bias,'on');
    listvgs=[listvgs vgs];
    %add legend to figure
    legend_str{i+1}=['Vgs=',num2str(vgs),'V'];
    
   for j=0:30
       %choose pin range and obtain Pin list
       Pin=-20+j;
       rf_signal.power=Pin;
       WRITE(rf_signal,'on');
       listPin1=[listPin1;Pin];
       
       %obtain Id values
       READ(dc_bias);
       Id=str2num(char(dc_bias.id));
       listId1=[listId1;Id];
       
       %obtain Pout values and list
       READ(rspm);
       Pout=rspm.power;
       listPout1=[listPout1;Pout];
       
       %obtain gain values and list
       Gain=Pout-Pin;
       listGain1=[listGain1;Gain];

   end
   
   listId=[listId listId1];
   listPout=[listPout listPout1];
   listGain=[listGain listGain1];
   listPin=[listPin listPin1];
   
end

%plot pin/gain
fig_Diff_Bias=figure(1);
subplot(2,2,1)
line(listPin,listGain)

xlabel('Pin(dBm)')
ylabel('Gain(dB)')
title('Characteristic of Pin and Gain')
grid minor
legend(legend_str,'location','west')

%plot pin/Ids
subplot(2,2,2)
line(listPin,listId)

xlabel('Pin(dBm)')
ylabel('Id(A)')
title('Characteristic of Pin and Id')
grid minor
legend(legend_str,'location','northwest')

subplot(2,2,3)
plot(listPin,listPout)
xlabel('Pin(dBm)')
ylabel('Pout(dBm)')
title('Characteristic of Pin and Pout')
grid minor
legend(legend_str,'location','northwest')

%save figure
frame=getframe(fig_Diff_Bias);
img=frame2im(frame);
imwrite(img,'fig_Diff_Bias.jpg')
saveas(fig_Diff_Bias,'fig_Diff_Bias.fig')

%show the time of this program
toc

%save data
data_Diff_Bias=struct('time',toc,'Pin',listPin,'Gain',listGain,...
                    'Id',listId,'Pout',listPout,'Vgs',listvgs);
save 'data_Diff_Bias.mat';


WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
WRITE(source,'off');





