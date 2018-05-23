%********Audio Recorder****************************************************
% 
% Description:
% Takes a BASK modulated audio input from 'Modified Sender' and outputs a
% text message with a synthesised voice.
% 
% Developed by:
% Rhys Baldwin and Rory Fahey 
% with Swinburne University.
% 
% Date:
% 23/05/2018
% 
% Settings: 
% system volume 80%, requires good microphone otherwise need to reduce 
% speed via 'n'
% *************************************************************************
% 
clear;clc;                          %clear previous inputs
poweron=1;                          %setting for ending while loop
freq=900;                           %for 400hz sine wave
n = 200;                            %length of bits( n/fs = fraction of second)
sensitivity1=5;                     %division of maximum filtered signal strength
smoothing=20;                       %for 'clean1'
recstage=0;                         %setting for keeping track of what the stage of recording is
sense2=0.2;                         %initial pulse sensitivity

fs = 8000;                          % Sampling Frequency (Hz)
fn = fs/2;                          % Nyquist Frequency (Hz)
Wp = [freq*.8 freq*1.2]/fn;         % Passband Frequencies (Normalised)
Ws = [freq*.78 freq*1.22]/fn;       % Stopband Frequencies (Normalised)
Rp = 10;                            % Passband Ripple (dB)  (10)
Rs = 50;                            % Stopband Ripple (dB)  (50)
[nf,Ws] = cheb2ord(Wp,Ws,Rp,Rs);    % Filter Order
[z,p,k] = cheby2(nf,Rs,Ws);         % Filter Design
[sosbp,gbp] = zp2sos(z,p,k);        % Convert To Second-Order-Section For Stability

while poweron ==1
                                              
    if recstage == 0                          %check for 400hz
        recheck = audiorecorder(fs,8,1,-1);   %
        recordblocking(recheck,((n/fs)*6));   %record obj 'rec' for #seconds
        data3 = getaudiodata(recheck);        %raw data
        filt3=filtfilt(sosbp,gbp,data3);      %filtered
        clc;                                  %clear user feedback
        fprintf('listening for %iHz\n',freq)  %display user feedback
    end
    
    if  recstage == 0 && max(filt3) > sense2  %if signal was detected then;
                                              %record something
        pause((n/fs)*12);                     %for timing....wait 
        rec = audiorecorder(fs,8,1,-1);       %
        record(rec);                          %record message 
        clc;                                  %clear user feedback
        fprintf('found %iHz\n',freq)          %display user feedback
        
        recstage=1;                           %advance to stage 1
    end
    
    if recstage == 1                          %check for end of message        
        recheck = audiorecorder(fs,8,1,-1);   %
        recordblocking(recheck,((n/fs)*30));  %record obj 'rec' for seconds
        data2 = getaudiodata(recheck);        %raw data
        filt3=filtfilt(sosbp,gbp,data2);      %filtered
        filt3=abs(filt3);                     %make absolute
        clc;                                  %clear user feedback
        fprintf('receiving message\n')        %display user feedback
    end
    
    if  recstage == 1 && mean(filt3) < (sense2/4)%if signal no longer detected then;
        stop(rec);                            %stop recording main message
        recstage = 2;                         %advance recording stage to 2
        clc;                                  %clear user feedback
        fprintf('found end of message\n')     %display user feedback
    end
    

    
    if recstage==2                          %process raw data for output
        clc;                                %clear user feedback
        fprintf('generating message\n')     %display user feedback
        data1 = getaudiodata(rec);          %get what was recorded in data

        values= 1/fs:1/fs:(1/fs)*20;        %for convulution
        a=2*sin(2*pi*freq*values);          %for convulution filter

        filt1 = conv(data1,a);              % Filter Signal

        clean1=abs(filt1);                  %make absolute
        average=max(filt1/sensitivity1);    %find nominated threshold
        clean1(clean1<average)=0;           %everything under theshold becomes 0
        clean1(clean1>average)=1;           %everything over theshold becomes 1
        a=ones(1,smoothing);                %create array for smoothing

        clean1 = conv(clean1,a);            %smooth using convulution

        trim1=clean1;                               %start trimming signal
        delay=find(clean1>0.001, 1, 'first');       %find first non zero
        trim1(1:(delay-n))=[];                      %deletes blank space which also syncronises
        finishcode=find(clean1>0.001, 1, 'last');   %find last non zero
        trim1(finishcode:length(trim1))=[];         %deletes blank space
        digitizer = (max(statelevels(trim1)))/(5/3);%estimates state levels
        trim1(trim1<digitizer)=0;                   %again make less than state level 0
        trim1(trim1>digitizer)=1;                   %and make more than state level 1

        subplot(3,2,1)                      %plot original data
        plot(data1)                         %plot original data
        subplot(3,2,2)                      %plot filtered and 'sync?' data
        plot(filt1)                         %plot filtered and 'sync?' data
        subplot(3,2,4)                      %plot clean
        plot(clean1)                        %plot clean
        subplot(3,2,5)                      %plot trimmed
        plot(trim1)
        subplot(3,2,6)                      %plot trimmed
        plot(data3)
%         RecordedReciever(trim1');
       
        clc;                                %Voice Sythesizer block and output text
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
