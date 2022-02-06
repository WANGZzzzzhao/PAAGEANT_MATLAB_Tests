%Vtemp(N) with PA non biased
clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=SOURCE_34401A('GPIB0::5::INSTR');
%calculate the whole time of this program
tic 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
source.v_pv6=3.3;
source.i_pv6=0.5;
WRITE(source,'on');

isen1b.vsen1b=0;
isen1b.max_i=0.2;
WRITE(isen1b,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program with PA non biased
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

list_vtemp=[];
list_vsen1b=[];
for j=0:1
    list_vtemp1=[];
    list_N=[];
    time=[];
 
    vsen1b=2.51-0.2*j;
    isen1b.vsen1b=vsen1b;
    WRITE(isen1b,'on');
    legend_str{j+1}=['Vsen1b=',num2str(vsen1b),'V'];
    
    for i=0:140 
        N=20+i;
        WRITE(ard,N);
        READ(tmp1);
        vtemp=tmp1.vtemp;
        list_vtemp1=[list_vtemp1;vtemp];
        list_N=[list_N;N];
    end
    list_vtemp=[list_vtemp list_vtemp1];
    list_vsen1b=[list_vsen1b vsen1b];
end

% figure of Vtemp and N with PA non biased
fig_Vtemp_N_non_bias=figure(1);
plot(list_N,list_vtemp)
grid minor
xlabel('N')
ylabel('Vtemp(V)')
xlim([list_N(1) list_N(end)])
title('Characteristic of Vtemp and N with PA non bias')
legend(legend_str,'location','northeast')


frame=getframe(fig_Vtemp_N_non_bias);
img=frame2im(frame);
imwrite(img,'fig_Vtemp_N_non_bias.jpg')
saveas(fig_Vtemp_N_non_bias,'fig_Vtemp_N_non_bias.fig')

%show the time of this program
toc

%save data
data_Vtemp_N_non_bias=struct('time',toc,'vtemp',list_vtemp,'N',list_N);
save 'data_Vtemp_N_non_bias.mat';

WRITE(isen1b,'off');
WRITE(source,'off');
CLOSE(tmp1);
