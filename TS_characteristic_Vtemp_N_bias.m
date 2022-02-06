clear
source=SOURCE_E3631A('GPIB0::7::INSTR');
isen1b=SOURCE_B2902A('GPIB0::23::INSTR');
ard=ARDUINO_TEMP('PA1');
tmp1=SOURCE_34401A('GPIB0::5::INSTR');
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
%calculate the whole time of this program
tic 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
source.v_pv6=3.3;
source.i_pv6=0.9;
WRITE(source,'on');

isen1b.max_i=0.6;
WRITE(isen1b,'on');

dc_bias.vgs=0.89;
dc_bias.max_ig=0.04;
dc_bias.vds=3.3;
dc_bias.max_id=0.4;
WRITE(dc_bias,'on');
READ(dc_bias);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program with PA biased
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
    for i=0:180 
        N=1+i;
        WRITE(ard,N);
         READ(tmp1);
        % READ(source);
         vtemp=tmp1.vtemp;
        list_vtemp1=[list_vtemp1;vtemp];
        list_N=[list_N;N];

    end
    list_vtemp=[list_vtemp list_vtemp1];
    list_vsen1b=[list_vsen1b vsen1b];
end

% figure of Vtemp and N with PA biased
fig_Vtemp_N_bias=figure(1);
plot(list_N,list_vtemp)
grid minor
xlabel('N')
ylabel('Vtemp(V)')
xlim([list_N(1) list_N(end)])

title('Characteristic of Vtemp and N with PA bias')
legend(legend_str,'location','northeast')

frame=getframe(fig_Vtemp_N_bias);
img=frame2im(frame);
imwrite(img,'fig_Vtemp_N_bias.jpg')
saveas(fig_Vtemp_N_bias,'fig_Vtemp_N_bias.fig')

%show the time of this program
toc

%table_tot
data_Vtemp_N_bias=struct('time',toc,'vtemp',list_vtemp,'N',list_N);
save 'data_Vtemp_N_bias.mat'

WRITE(isen1b,'off');
WRITE(dc_bias,'off');
CLOSE(tmp1)
WRITE(source,'off');