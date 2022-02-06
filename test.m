% stress_time=60; %second
% t = timer('TimerFcn', 'stat=false; disp(''Time over!'')',... 
%                  'StartDelay',stress_time); 
%              
% start(t)
% stat=true;
% while(stat==true)
%     pause(10)
%     disp('come on')
% end
% disp('Done!')

run('file1.m')
run('file2.m')