j=audioread('a.wav')

j=(abs(j))
size(j)



n = bit_time; % average every n values
av = reshape(cumsum(ones(n,10),2),[],1); % arbitrary data
b = round(arrayfun(@(i) mean(j(i:i+n-1)),1:n:length(j)-n+1)); % the averaged vector



str = char(bin2dec(reshape(char(b+'0'), 8,[]).'))'

