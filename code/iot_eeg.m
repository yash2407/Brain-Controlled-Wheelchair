clear all;
clc;
delete(instrfind({'Port'},{'COM4'}));
s = serial('COM4', 'BaudRate', 115200);
fopen(s);
tots = 1995;
data1 = zeros(tots,1);
 % track the current voltage index
 voltageIdx  = 0;
 % communicate with Arduino

 while voltageIdx < tots
     % get the voltage data
     voltValue = fscanf(s,'%f');
     % save it to the array
     voltageIdx  = voltageIdx + 1;
     data1(voltageIdx) = voltValue;
     disp(voltageIdx);
 end

 fs = 475; 
 data1 = data1 - mean(data1);
% voltageData = detrend(voltageData,'constant');
 y1 = lowpass(data1,30,fs);
 y1 = highpass(y1,2,fs);
 %figure(1);
 %plot(y1);

 window = hamming(tots);
 psd = 2*periodogram(data1,window,0:fs/2,fs);


 figure(1);
 %subplot(5,1,1);
 
 %x = linspace(0,50);
 plot(psd);
 xlim([0 50]);
 
 filename = ['testfile1.txt'];
 filename;
 fid = fopen(filename,'a');
 %fprintf(fid,'delta,theta,alpha,beta,op\n');
 
hdr=lowpass_filter();
hda=alpha_band_filter();
hdb=beta_band_filter();


 ts=(length(psd)/fs);
 Wp = [1 4]/(fs/2); 
 Ws = [0.5 4.5]/(fs/2);
 Rp = 3; Rs = 40;
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[z, p, k] = butter(n,Wn,'bandpass');
              [sos,g] = zp2sos(z,p,k);
              filt = dfilt.df2sos(sos,g);
              fd1 = filter(filt,data1);
              avpow1 = norm(fd1,2)^2/numel(fd1);

              % %  theta band      
              Wp = [4 8]/(fs/2); Ws = [3.5 8.5]/(fs/2);
              [n,Wn] = buttord(Wp,Ws,Rp,Rs);
              [z, p, k] = butter(n,Wn,'bandpass');
              [sos,g] = zp2sos(z,p,k);
              filt = dfilt.df2sos(sos,g);
              fd2 = filter(filt,data1);
              avpow2 = norm(fd2,2)^2/numel(fd2);

              % %   alpha band
              Wp = [8 13]/(fs/2); Ws = [7.5 13.5]/(fs/2);
              [n,Wn] = buttord(Wp,Ws,Rp,Rs);
              [z, p, k] = butter(n,Wn,'bandpass');
              [sos,g] = zp2sos(z,p,k);
              filt = dfilt.df2sos(sos,g);
              fd3 = filter(filt,data1);
              fd3= filtfilt(hda.Numerator,1,data1);
              avpow3 = norm(fd3,2)^2/numel(fd3);

              % % beta band
              Wp = [13 30]/(fs/2); Ws = [12.5 30.5]/(fs/2);
              [n,Wn] = buttord(Wp,Ws,Rp,Rs);
              [z, p, k] = butter(n,Wn,'bandpass');
              [sos,g] = zp2sos(z,p,k);
              filt = dfilt.df2sos(sos,g);
              fd4 = filter(filt,data1);
              fd4= filtfilt(hdb.Numerator,1,data1);
              avpow4 = norm(fd4,2)^2/numel(fd4);
 
  sumpow=avpow1+avpow2+avpow3+avpow4;
  d_bpr=log10(avpow1/sumpow);
  t_bpr=log10(avpow2/sumpow);
  a_bpr=log10(avpow3/sumpow);
  b_bpr=log10(avpow4/sumpow);

fprintf(fid,'\r\n');  
fprintf(fid,'%.3f,%.3f,%.3f,%.3f',d_bpr,t_bpr,a_bpr,b_bpr);


fclose(fid);

 