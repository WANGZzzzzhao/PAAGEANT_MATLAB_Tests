%%%%%%%%%%%%%%%%%%%%%%%%%
%  list of the program  %
%%%%%%%%%%%%%%%%%%%%%%%%%

% All the figures are saved as .fig and .jpg.
% All the data are saved as .mat.
% All the figures and datas are saved automatically every execution.

%%% characteristic of the transistor %%%

% 1. characteristic_Vgs_Id.m
    % fig_Vds_Id.fig
    % data_Vds_Id.mat
    % 2 mins
% 2. characteristic_Vds_Id.m
    % fig_Vgs_Id.fig
    % data_Vgs_Id.mat
    % 3 mins
% 3. AC_Freq_Resp.m
    % This program represent the frequency response of the amplifier
    % fig_Freq_Resp.fig
    % data_Freq_Resp.mat
    % 5 mins
% 4. AC_Comp_Point.m
    % This program represent 1dB compression point
    % fig_Comp_Point.fig
    % data_comp_point.mat
    % 3 mins
% 5. AC_Diff_Bias.m
    % This program is for AC measurements with different bias points
    % fig_Diff_Bias.fig
    % data_Diff_Bias.mat
    % 3 mins

run('characteristic_Vgs_Id.m')
run('characteristic_Vds_Id.m')
run('AC_Freq_Resp.m')
run('AC_Comp_Point.m')
run('AC_Diff_Bias.m')

%%% characteristic of temperature sensor %%%

%%% homodyne %%%
% 1. TS_characteristic_Vtemp_N_non_bias.m  
    % This program is for observing Vtemp(N) with PA no biased
    % fig_Vtemp_N_non_bias.fig
    % data_Vtemp_N_non_bias.mat
    % 3 mins
% 2. TS_characteristic_Vtemp_N_bias.m
    % This program is for observing Vtemp(N) with PA biased
    % fig_Vtemp_N_bias.fig
    % data_Vtemp_N_bias.mat
    % 3 mins
% 3. TS_Homodyne.m
    % This program gathers 3 plots together : no biased, biased and with rf signal
    % fig_TS_Homodyne.fig
    % data_TS_Homodyne.mat
    % 30 mins
% 4. TS_Pin_Nmid.m
    % This program can quicly find out N which makes Vtemp closest to 1.65V with the change of pin
    % Pin_Nmid.fig
    % data_Pin_Nmid.mat
    % 20 mins
% 5. TS_Diff_Bias.m
    % This program shows the influence of the choise of different bias points
    % fig_TS_Diff_Bias.fig
    % data_TS_Diff_Bias.mat
    % 30 mins 

run('TS_characteristic_Vtemp_N_non_bias.m')
run('TS_characteristic_Vtemp_N_bias.m')
run('TS_Homodyne.m')
run('TS_Pin_Nmid.m')
run('TS_Diff_Bias.m')


%%% heterodyne %%%   
% 1. TS_2T_Pin_Vtemp.m  
    % This program can quicly find out N which makes Vtemp closest to 1.65V with the change of pin and mesure Vtemp power 
    % fig_TS_2T_Pin_Vtemp.fig
    % data_TS_2T_Pin_Vtemp.mat
    % 20 mins
% 2. TS_2T_Diff_Bias.m  
    % This program shows the influence of the choise of different bias points with 2 tones
    % fig_TS_2T_Diff_Bias.fig
    % data_TS_2T_Diff_Bias.mat
    % 30 mins

run('TS_2T_Pin_Vtemp.m')    
run('TS_2T_Diff_Bias.m')   







    
    
    
    

