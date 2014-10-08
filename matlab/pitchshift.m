clear;
[audio, fs] = wavread('x2.wav'); % Read audio
tic
[treklang] = pitch(audio, 0.75, 0.5);
toc
soundsc(treklang,fs) % play new audio


%%
while 1
    tempAudioObj = audiorecorder(44000,16,1);
    
    recordblocking(tempAudioObj, .4);
    
    ljud = getaudiodata(tempAudioObj);
    
    [treklang] = pitch(ljud, 1.25, 1.5);
    
    soundsc(treklang,fs);
    
    
end


%%  OLD METHOD


for n = 1:1;
    tempAudioObj = audiorecorder(44000,16,1);
    
    recordblocking(tempAudioObj, 1);
    
    ljud = getaudiodata(tempAudioObj);
    
    Fs = 44000;      %# Samples per second
    toneFreq = 300;  %# Tone frequency, in Hertz
    nSeconds = 2;   %# Duration of the sound
    y = sin(linspace(0, nSeconds*toneFreq*2*pi, round(nSeconds*Fs)));
    y= ljud
    F1 = fft(y);
    N = numel(F1);
    mean_value = mean(abs(F1))
    threshold  =mean_value*1.1;
    F1(abs(F1) < threshold) = 0;
    F1a = F1(1:N/2);   % the lower half of the fft
    % F1b = F1(end:-1:half+1);
    F1b = F1((N/2)+1:1:end);  % the upper half of the fft - flipped "the right way around"
    stem(abs(F1))
    xlim([0,1000])
    hold on
    t1 = 1:N/2;              % indices of the lower half
    tkvint = 1 + (t1-1) / (1.5); % finer sampling... will make peaks appear higher
    tters = 1 + (t1-1) / (1.25); % finer sampling... will make peaks appear higher
    F2a = interp1(t1, F1a, tkvint); % perform sampling of lower half
    F2b = interp1(t1, F1b, tkvint); % resample upper half
    F2 = [F2a F2b];   % put the two together again
	stem(abs(F2),'r')
    F3a = interp1(t1, F1a, tters); % perform sampling of lower half
    F3b = interp1(t1, F1b, tters); % resample upper half
    F3 = [F3a F3b];   % put the two together again
    stem(abs(F3),'g')
    fres = F1+F2'+F3';
    
    shiftedf2 = ifft(F2);   % and do the inverse FFT
    shiftedf2 = shiftedf2';

    shiftedf3 = ifft(F3);   % and do the inverse FFT
    shiftedf3 = shiftedf3';

    kvint= real(shiftedf2);
    ters = real(shiftedf3);
    
    wavwrite(ljud, 44000, 'grund.wav');
    wavwrite(ters, 44000,'ters.wav');
    wavwrite(kvint, 44000,'kvint.wav');
    
    soundsc(ljud, 44000);
    soundsc(ters, 44000);
    soundsc(kvint, 44000);
    
    
end