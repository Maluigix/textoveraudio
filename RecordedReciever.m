%********Recorded Reciever*************************************************
% 
% Description:
% Converts output from 'Audio Recorder' to a readable string.
% 
% Developed by:
% Rhys Baldwin and Rory Fahey 
% with Swinburne University.
% 
% Date:
% 23/05/2018
% 
% *************************************************************************
% 
function [str] = RecordedReciever(j)
    j=abs(j);
    n = 200; %bit_time; % average every n values
    b = (arrayfun(@(i) mean(j(i:i+n-1)),1:n:length(j)-n+1)); % the averaged vector

    div8=rem(length(b),8);  %just incase not divisable by 8
    if div8 ~= 0
        div8= zeros(1,8-div8);
        b=cat(2,b,div8);
    end

        I=b<mean(b);
        J=b>mean(b);
    b(I)=0;
    b(J)=1;
    str = char(bin2dec(reshape(char(b+'0'), 8,[]).'))';
    fprintf('Message; %s\nMessage Length; %i characters\n',str,(length(str)))
end
 
