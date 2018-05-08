
fs= 8000;                           %for 400hz sine wave
freq=400;                           %for 400hz sine wave

                                    %record something
rec = audiorecorder(8000,8,1,-1);   %all values are defaults
recordblocking(rec,2);              %record obj 'rec' for seconds 
data1 = getaudiodata(rec);          %get what was recorded in data

subplot(3,1,1)                      %plot original data
plot(filt1)                         %plot original data

sync=[1 0 1 0 1 0 1 0];             %sync code
for_kron = ones(1,200);             %sets up array for use with kronecker tensor product
sync = kron(sync,for_kron);         %kronecker tensor product
q=size(sync);                       %for 'values' calculation below
values= 1/fs:1/fs:(((q(1,1))/fs));  
a=1*sin(2*pi*freq*values);          

delay = finddelay(a,data1);         %attempt at syncing
data1(1:delay)=[];                  %attempt at syncing, deletes elements until sync code

values= 1/fs:1/fs:(1/fs)*20;        %for convulution, not sure if this is correct
a=2*sin(2*pi*freq*values);          %for convulution filter

filt1 = conv(data1,a);              % Filter Signal


subplot(3,1,2)                      %plot filtered and 'sync?' data
plot(filt1)                         %plot filtered and 'sync?' data


clean1=abs(filt1);                  %attempt at cleaning up the data
average=1.5;                        %maybe replace with mean() function, not sure yet
clean1(clean1<average)=0;             
clean1(clean1>average)=1;
q=size(clean1);
values= 1/fs:1/fs:(((q(1,1))/fs));
a=1*sin(2*pi*freq*values);
clean1=clean1'.*a;                  %multiply by 1 or 0


subplot(3,1,3)                      %plot clean
plot(clean1)                        %plot clean




