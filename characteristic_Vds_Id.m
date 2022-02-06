clear 
dc_bias=SOURCE_B2912A('TCPIP0::192.168.137.30::hislip0::INSTR');
source=SOURCE_E3631A('GPIB0::7::INSTR');

%calculate the whole time of this program
tic 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialise values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dc_bias.vgs=0;
dc_bias.max_ig=0.01;
dc_bias.vds=0;
dc_bias.max_id=0.1;
WRITE(dc_bias,'on');

source.v_pv6=3.3;
source.i_pv6=0.05;
WRITE(source,'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start of the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define lists of Vds and Id
listVgs=[];
listId=[];
    for j=0:5
        %define lists of Vds, Id and time in the loop
        listVds=[];
        listId1=[];

        %choose the range of vgs
        vgs=0.1*j+0.6;
        dc_bias.vgs=vgs;
        WRITE(dc_bias,'on');
        
        %obtain the value of Vgs
        READ(dc_bias);
        Vgs=str2num(char(dc_bias.vgs));
        listVgs=[listVgs Vgs];
        %add legend to figure
        legend_str{j+1}=['Vgs=',num2str(vgs),'V'];
        
        for i=0:33
          %choose the range of vds
          dc_bias.vds = 0.1*i;
          WRITE(dc_bias,'on');
          READ(dc_bias);
          
          %obtain the value of Vds
          Vds=str2num(char(dc_bias.vds));
          listVds=[listVds;Vds];
          READ(dc_bias);
          %obtain the value of Id
          Id=str2num(char(dc_bias.id));
          listId1=[listId1;Id];
        end
        listId=[listId listId1];
    end

%plot Id/Vds
fig_Vds_Id=figure;
line(listVds,listId)

xlabel('Vds(V)')
xlim([listVds(1) listVds(end)])
ylabel('Id(A)')
title('Characteristic of Vds and Id')
grid minor
legend(legend_str,'location','northwest')

%save figure
frame=getframe(fig_Vds_Id);
img=frame2im(frame);
imwrite(img,'fig_Vds_Id.jpg')
saveas(fig_Vds_Id,'fig_Vds_Id.fig')

%show the time of this program
toc

%save data
data_Vds_Id=struct('time',toc,'Vds',listVds,'Ids',listId,'Vgs',listVgs);
save 'data_Vds_Id.mat';

WRITE(dc_bias,'off')
WRITE(source,'off');


