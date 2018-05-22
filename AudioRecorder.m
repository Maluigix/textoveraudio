%settings - groove music volume 80%, system volume 80%
clear;clc;
poweron=1;
freq=1000;                           %for 400hz sine wave
n = 800;                           %length of bits
sensitivity1=5;                     %division of maximum filtered signal strength
smoothing=5;                       %for 'clean1'
recstage=0;
sense2=0.23;

fs = 8000;                          % Sampling Frequency (Hz)
fn = fs/2;                          % Nyquist Frequency (Hz)
Wp = [freq*.8 freq*1.2]/fn;         % Passband Frequencies (Normalised)
Ws = [freq*.78 freq*1.22]/fn;       % Stopband Frequencies (Normalised)
Rp = 10;                             % Passband Ripple (dB)%was10
Rs = 50;                            % Stopband Ripple (dB)%was50
[nf,Ws] = cheb2ord(Wp,Ws,Rp,Rs);     % Filter Order
[z,p,k] = cheby2(nf,Rs,Ws);          % Filter Design
[sosbp,gbp] = zp2sos(z,p,k);        % Convert To Second-Order-Section For Stability

while poweron ==1
    %check for 400hz
    if recstage == 0
        recheck = audiorecorder(fs,8,1,-1);   %all values are defaults
        recordblocking(recheck,((n/fs)*6));              %record obj 'rec' for seconds
        data3 = getaudiodata(recheck);
        filt3=filtfilt(sosbp,gbp,data3);
        clc;
        fprintf('listening for %iHz\n',freq)
    end
    
    if recstage == 1
        recheck = audiorecorder(fs,8,1,-1);   %all values are defaults
        recordblocking(recheck,((n/fs)*30));              %record obj 'rec' for seconds
        data2 = getaudiodata(recheck);
        filt3=filtfilt(sosbp,gbp,data2);
        filt3=abs(filt3);
        clc;
        fprintf('receiving message\n')
    end
    
    if  recstage == 1 && mean(filt3) < (sense2/4)
        stop(rec);
        recstage = 2;
        clc;
        fprintf('found end of message\n')
    end
    
    if  recstage == 0 && max(filt3) > sense2
        %record something
        pause((n/fs)*12);
        rec = audiorecorder(fs,8,1,-1);   %all values are defaults
        record(rec);              %record obj 'rec' for seconds 
        clc;
        fprintf('found %iHz\n',freq)
        
        recstage=1;
    end
    
    if recstage==2
        clc;
        fprintf('generating message\n')
        data1 = getaudiodata(rec);          %get what was recorded in data
       

        values= 1/fs:1/fs:(1/fs)*20;        %for convulution, not sure if this is correct
        a=2*sin(2*pi*freq*values);          %for convulution filter

        filt1 = conv(data1,a);              % Filter Signal


%         filt2=filtfilt(sosbp,gbp,data1);


        clean1=abs(filt1);                  %attempt at cleaning up the data
        average=max(filt1/sensitivity1);                        %maybe replace with mean() function, not sure yet
        clean1(clean1<average)=0;             
        clean1(clean1>average)=1;
        a=ones(1,smoothing);

        clean1 = conv(clean1,a); 
        % clean1(clean1>average/2)=1;

%         sync=[1 0 1 0 1 0 1 0];             %sync code             
%         for_kron = ones(1,n);               %sets up array for use with kronecker tensor product
%         sync = kron(sync,for_kron);         %kronecker tensor product

%         delay = finddelay(sync,clean1);      %attempt at syncing
        trim1=clean1;
        delay=find(clean1>0.001, 1, 'first');
        trim1(1:(delay-n))=[];                  %attempt at syncing, deletes elements until sync code
        finishcode=find(clean1>0.001, 1, 'last');
        trim1(finishcode:length(trim1))=[];
        %trim1(1:n:length(trim1))=0;
        
%         q=size(clean1);
%         values= 1/fs:1/fs:(((q(1,1))/fs));
%         a=1*sin(2*pi*freq*values);
%         clean2=clean1'.*a;                  %multiply by 1 or 0

        
        subplot(3,2,1)                      %plot original data
        plot(data1)                         %plot original data
        subplot(3,2,2)                      %plot filtered and 'sync?' data
        plot(filt1)                         %plot filtered and 'sync?' data
%         subplot(3,2,3)
%         plot(filt2)
        subplot(3,2,4)                      %plot clean
        plot(clean1)                        %plot clean
        subplot(3,2,5)                      %plot trimmed
        plot(trim1)
        subplot(3,2,6)                      %plot trimmed
        plot(data3)
%         RecordedReciever(trim1');
       
        clc;
        speak = RecordedReciever(trim1');
        if isempty(speak)
            return;
        end                                 % Bail out if nothing.
        speak = char(speak);                 % Convert from cell to string.
        NET.addAssembly('System.Speech');
        obj = System.Speech.Synthesis.SpeechSynthesizer;
        obj.Volume = 100;
        Speak(obj, speak);
        
        poweron=0;
        
    end
end
