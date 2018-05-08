%Converts inputted text to a usable binary output
freq=400;
bit_time = 200;% setting for samples / bit 

prompt = 'Type some text:\n';%prompt
string = input(prompt,'s');%input
bin_str = dec2bin(string,8);%convert to binary

bin_str = reshape(bin_str', [1, numel(bin_str)]);%makes one long line of binary instead of matrix

bin_str = logical(bin_str - 48);%changes to logical array

bin_str= [1 0 1 0 1 0 1 0 bin_str];%for sync

for_kron = ones(1,bit_time);%sets up array for use with kronecker tensor product
out = kron(bin_str,for_kron);%kronecker tensor product, (stretches binary code)

q=size(out);%don't really need this, shows up in 'values' calculation below


amp=1; %amplitude
%fs= 8192;  % sampling frequency
fs= 8000;  % new sampling frequency

values= 1/fs:1/fs:(((q(1,2))/fs));
a=amp*sin(2*pi*freq*values);
a=a.*out;
%sound(a)
save('a.mat','a')
filename = 'a.wav';
audiowrite(filename,a,fs);
[a,fs] = audioread(filename);
sound(a,fs)
recObj = audiorecorder;
recordblocking(recObj, 3);
y = getaudiodata(recObj);
plot(a)