clear 
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
source=SOURCE_E3631A('GPIB0::7::INSTR');

%calculate the whole time of this program
tic 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dc_bias.vgs=0;
dc_bias.max_ig=0.04;
dc_bias.vds=0;
dc_bias.max_id=0.4;
WRITE(dc_bias,'on');

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define lists of Vds and Id
listVds=[];
listId=[];
    for j=0:7
        %define lists of Vgs, Id and time in the loop
        listVgs=[];
        listId1=[];
        %choose the range of vds
        vds=0.5*j;
        dc_bias.vds=vds;
        WRITE(dc_bias,'on');
        if vds>3
            vds=3.3;
            dc_bias.vds=vds;
            WRITE(dc_bias,'on');
        end
        %obtain the value of Vds
        READ(dc_bias);
        Vds=str2num(char(dc_bias.vds));
        listVds=[listVds Vds];
        %add legend to figure
        legend_str{j+1}=['Vds=',num2str(vds),'V'];
        
        for i=0:15
          %choose the range of vgs
          dc_bias.vgs = 0.1*i;
          WRITE(dc_bias,'on');
          READ(dc_bias);
          
          %obtain the value of Vgs
          Vgs=str2num(char(dc_bias.vgs));
          listVgs=[listVgs;Vgs];
          READ(dc_bias);
          %obtain the value of Id
          Id=str2num(char(dc_bias.id));
          listId1=[listId1;Id];
        end
        listId=[listId listId1];
    end
    
%plot Id/Vds
fig_Vgs_Id=figure;
plot(listVgs,listId)
xlabel('Vgs(V)')
ylabel('Id(A)')
xlim([listVgs(1) listVgs(end)])
title('Characteristic of Vgs and Id')
grid minor
legend(legend_str,'location','northwest')

%save figure
frame=getframe(fig_Vgs_Id);
img=frame2im(frame);
imwrite(img,'fig_Vgs_Id.jpg')
saveas(fig_Vgs_Id,'fig_Vgs_Id.fig')

%show the time of this program
toc

%save data
data_Vgs_Id=struct('time',toc,'Vgs',listVgs,'Id',listId,'Vds',listVds);
save 'data_Vgs_Id.mat';

WRITE(dc_bias,'off');
WRITE(source,'off');
