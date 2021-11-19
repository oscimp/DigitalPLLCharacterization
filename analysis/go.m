l=dir('*bin');

for k=1:length(l)
% for k=1:1
   f=fopen(l(k).name);
   freq(k)=str2num(l(k).name(6:13));
   d=fread(f,inf,'int16');
   fclose(f);

   if ((1010000 < freq(k)) && (freq(k)  < 11000000))
	   freqfast(k)=freq(k);
    	   d1=d(1:6:end);d1=d1(1:8000);d1=d1-mean(d1); %fast error signal open loop
           d2=d(2:6:end);d2=d2(1:8000);d2=d2-mean(d2); %fast perturbation open loop
           f1=(fft(d1));f1=f1(1:floor(length(f1)/2));  %fft of fast error signal open loop
           f2=(fft(d2));f2=f2(1:floor(length(f2)/2));  %fft of fast perturbation open loop
           [m,n]=max(abs(f2)); %find the frequency of the perturbation in the fft units 
           qf=f1(n)/f2(n);     % at perturbation frequency, error/perturbation
           modfast(k)=20*log10(abs(qf)); % get amplitude in dB
           alphafast(k)=angle(qf); % get phase in rad
   endif
 
   if ((1000 < freq(k)) && (freq(k) < 99500))
	   freqslow(k)=freq(k);
    	   d3=d(3:6:end);d3=d3(1:8000);d3=d3-mean(d3); %slow error signal open loop
           d4=d(4:6:end);d4=d4(1:8000);d4=d4-mean(d4); %slow perturbation open loop
           f3=(fft(d3));f3=f3(1:floor(length(f3)/2));  %fft of slow error signal open loop
           f4=(fft(d4));f4=f4(1:floor(length(f4)/2));  %fft of slow perturbation open loop
           [m,n]=max(abs(f4));           % find frequency of the perturbation in the fft units 
           qf=f3(n)/f4(n); 
           modslow(k)=20*log10(abs(qf)); % amplitude in dB
           alphaslow(k)=angle(qf);       % phase in rad
   endif 
   
   if ((99500 < freq(k)) && (freq(k) < 1010000))
	   freqmid(k)=freq(k);
    	   d5=d(5:6:end);d5=d5(1:8000);d5=d5-mean(d5); %mid error signal open loop
           d6=d(6:6:end);d6=d6(1:8000);d6=d6-mean(d6); %mid perturbation open loop
           f5=(fft(d5));f5=f5(1:floor(length(f5)/2)); %fft of mid error signal open loop
           f6=(fft(d6));f6=f6(1:floor(length(f6)/2)); %fft of mid perturbation open loop
           [m,n]=max(abs(f6)); %find the frequency of the perturbation in the fft units 
           qf=f5(n)/f6(n); 
           modmid(k)=20*log10(abs(qf)); % amplitude in dB
           alphamid(k)=angle(qf);       % phase in rad
   endif 
end

%Plotting
subplot(211)
k=find(freqfast>0);
semilogx(freqfast(k),modfast(k),'x-'); hold on

k=find(freqslow>0);
semilogx(freqslow(k),modslow(k),'x-');
k=find(freqmid>0);
semilogx(freqmid(k),modmid(k),'x-');
axis tight
ylabel('|e/p| (dB)');xlabel('disturbance signal (p) frequency (Hz)')
grid

subplot(212)
k=find(freqfast>0);
semilogx(freqfast(k),abs(alphafast(k)),'x-');
hold on
k=find(freqslow>0);
semilogx(freqslow(k),abs(alphaslow(k)),'x-');
k=find(freqmid>0);
semilogx(freqmid(k),abs(alphamid(k)),'x-');
axis tight
ylabel('arg(e/p)');xlabel('disturbance signal (p) frequency (Hz)')
grid
