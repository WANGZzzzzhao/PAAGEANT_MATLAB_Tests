%creation of the object
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
dc_bias.max_ig=0.004;
dc_bias.vds=3.3;
dc_bias.max_id=0.02;
WRITE(dc_bias,'on');

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define lists of Pin, Pout and Id
listpin=[];
listId_tot=[];
listPout=[];
for i=0:2 
    
    %define lists of freq, Pout, Id and time in loops
    listId=[];
    listfreq=[];
    listPout1=[]; 
    %choose the range of Pin -20 - -10
    pin=-20+5*i;
    rf_signal.power=pin;
    %add legend to figure
    legend_str{i+1}=['Pin=',num2str(pin),'dBm'];
    
    for j=1:28
       %choose the range of freq 25-700
       freq=25*j;
       rf_signal.freq=freq;
       WRITE(rf_signal,'on');
       %obtain the list of freq values 
       listfreq=[listfreq;freq];
       
       %obtain the list of Id values for every loop
       pause(0.5)
       READ(dc_bias);
       Id=str2num(char(dc_bias.id));
       listId=[listId;Id];
       
       %obtain the list of Pout values for every loop
       READ(rspm);
       Pout=rspm.power;
       listPout1=[listPout1;Pout];

    end
    
    %obtain the list of pin and the final list of Id ,Pout
    listpin=[listpin;pin];
    listId_tot=[listId_tot listId];
    listPout=[listPout listPout1];
   
end

%plot freq/id
fig_Freq_Resp=figure(1);

subplot(2,1,1)
plot(listfreq,listId_tot)
str = {'Vgs=0.89V','Vds=3.3V'};
text(550,0.011,str)
xlabel('freq(MHz)')
xlim([listfreq(1) listfreq(end)])
ylabel('Id(A)')
title('Characteristic of freq and Id')
grid minor
legend(legend_str,'location','northeast')


%plot freq/Pout
subplot(2,1,2)
plot(listfreq,listPout)
str = {'Vgs=0.89V','Vds=3.3V'};
text(500,-2.5,str)
xlabel('freq(MHz)')
xlim([listfreq(1) listfreq(end)])
ylabel('Pout(dBm)')
title('Characteristic of freq and Pout')
grid minor
legend(legend_str,'location','northeast')


%save figure
frame=getframe(fig_Freq_Resp);
img=frame2im(frame);
imwrite(img,'fig_Freq_Resp.jpg')
saveas(fig_Freq_Resp,'fig_Freq_Resp.fig')

%show the time of this program
toc

%save this tab to file
data_Freq_Resp=strcut('time',toc,'freq',listfreq,'Pin',listpin,...
                        'Id',listId_tot,'Pout',listPout);
save 'data_Freq_Resp.mat';


WRITE(dc_bias,'off');
WRITE(rf_signal,'off');
WRITE(source,'off');



