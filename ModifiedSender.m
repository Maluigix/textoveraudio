while true
    %Converts inputted text to a usable binary output
    freq=400;
    n = 800;% setting for samples / bit 

    prompt = 'Type some text: (''x'' ends function)\n';%prompt
    string = input(prompt,'s');%input
    if string == 'x'
        break;
    end
    
    bin_str = dec2bin(string,8);%convert to binary

    bin_str = reshape(bin_str', [1, numel(bin_str)]);%makes one long line of binary instead of matrix

    bin_str = logical(bin_str - 48);%changes to logical array

    delay16bit=zeros(1,16);

    bin_str= [delay16bit 1 1 1 1 delay16bit 1 0 1 0 1 0 1 0 bin_str delay16bit];%for sync and delays

    for_kron = ones(1,n);%sets up array for use with kronecker tensor product
    out = kron(bin_str,for_kron);%kronecker tensor product, (stretches binary code)

    q=size(out);%don't really need this, shows up in 'values' calculation below


    amp=1; %amplitude
    %fs= 8192;  % sampling frequency
    fs= 8000;  % new sampling frequency

    values= 1/fs:1/fs:(((q(1,2))/fs));
    a=amp*sin(2*pi*freq*values);
    a=a.*out;
    %sound(a)
%     save('a.mat','a')
%     filename = 'a.wav';
%     audiowrite(filename,a,fs);
%     [a,fs] = audioread(filename);
    sound(a,fs)
%     wait(length(a)/8000)
    
end
save('a.mat','a')
filename = 'a.wav';
audiowrite(filename,a,fs);
% [a,fs] = audioread(filename);
% sound(a,fs)
% recObj = audiorecorder;
% recordblocking(recObj, 3);
% y = getaudiodata(recObj);
plot(a)