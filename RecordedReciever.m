j=audioread('a6.wav');

%plot(j);
j=[zeros(41,1);j]
size(j);
j=abs(j);
n = bit_time; % average every n values
av = reshape(cumsum(ones(n,10),2),[],1); % arbitrary data
b = (arrayfun(@(i) mean(j(i:i+n-1)),1:n:length(j)-n+1)); % the averaged vector


    I=find(b<mean(b))
    J=find(b>mean(b))
b(I)=0
b(J)=1
str = char(bin2dec(reshape(char(b+'0'), 8,[]).'))'
