%********Modified Sender***************************************************
% 
% Description:
% User inputs string which is converted to BASK modulated audio output.
% Saves file 'a.wav' for testing purposes.
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
while true
    freq=900;   % carrier signal frequency
    n = 200;    % setting for samples / bit 
    %We have found 200 is the lowest samples/bit that still reliably sends
    %information

    prompt = 'Type some text: (''x'' ends function)\n';%prompt
    string = input(prompt,'s'); % user input
    if string == 'x'            % x will exit the loop and end program
        break;
    end
    
    bin_str = dec2bin(string,8);                        %convert to binary

    bin_str = reshape(bin_str', [1, numel(bin_str)]);   %makes one long line of binary instead of matrix

    bin_str = logical(bin_str - 48);                    %changes to logical array

    delay16bit=zeros(1,16);
    %for n=800, 1 1 1 1 
    syncpulse= (ones(1,round((800/n)*4)));              % Adjusts the initial pulse (to start the reciever recording) depending on n

    bin_str= [delay16bit syncpulse delay16bit bin_str delay16bit];%for sync and delays

    for_kron = ones(1,n);                               %sets up array for use with kronecker tensor product
    out = kron(bin_str,for_kron);                       %kronecker tensor product, (stretches binary code)

    q=size(out);                                        %don't really need this, shows up in 'values' calculation below


    amp=1;                              %amplitude of output
    %fs= 8192;                          % sampling frequency
    fs= 8000;                           % new sampling frequency

    values= 1/fs:1/fs:(((q(1,2))/fs));  %make carrier signal
    a=amp*sin(2*pi*freq*values);
    a=a.*out;                           %multiply with binary code to make BASK

    sound(a,fs)                         %output sound
   
    fprintf('please wait for end of transmission \nbefore sending another message...\n')
end
save('a.mat','a')
filename = 'a.wav';
audiowrite(filename,a,fs);
plot(a)