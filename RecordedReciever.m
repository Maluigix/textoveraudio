function [str] = RecordedReciever(j)
    % j=audioread('a.wav');
    % j=data1;
    % j=filt1;
    % j=clean1';
    %j=trim1';

    %plot(j);
    %j=[zeros(41,1);j];
%     size(j);
    j=abs(j);
    n = 800; %bit_time; % average every n values
    % av = reshape(cumsum(ones(n,10),2),[],1); % arbitrary data
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
    b(1:8)=[]; %remove sync bit
    str = char(bin2dec(reshape(char(b+'0'), 8,[]).'))';
    fprintf('Message; %s\n',str)
end
 
