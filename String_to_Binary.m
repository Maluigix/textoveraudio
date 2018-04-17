%Converts inputted text to a usable binary output

bit_time = 100;% setting for samples / bit 

prompt = 'Type some text:\n';%prompt
string = input(prompt,'s');%input
bin_str = dec2bin(string,8)%convert to binary

bin_str = reshape(bin_str', [1, numel(bin_str)])%makes one long line of binary instead of matrix

bin_str = logical(bin_str - 48)%changes to logical array

bin_str= [1 0 1 0 1 0 1 0 bin_str]%for sync

for_kron = ones(1,bit_time)%sets up array for use with kronecker tensor product
out = kron(bin_str,for_kron)%kronecker tensor product, (stretches binary code)

q=size(out)


amp=10 %amplitude
fs= 8192  % sampling frequency
%duration=1
freq=440
values= 1/fs:1/fs:((q(1,2))/fs);
%values= out.*values
a=amp*sin(2*pi* freq*values)
a=a.*out
sound(a)
