for n = 1:5;
    tempAudioObj = audiorecorder(44000,16,1);
    
    disp('Recording part');
    disp(n)
    recordblocking(tempAudioObj, 1);
    disp('Done with part');
    disp(n)
    
    tempAudioData = getaudiodata(tempAudioObj);
    
    F1 = fft(tempAudioData);
    N = numel(F1);
%     half = int32(N/2);
    mean_value = mean(abs(F1));
    threshold  = 1.1*mean_value;
    F1[abs(F1) < threshold] = 0;
    F1a = F1(1:N/2);   % the lower half of the fft
    % F1b = F1(end:-1:half+1);
    F1b = F1((N/2)+1:1:end);  % the upper half of the fft - flipped "the right way around"

    t1 = 1:N/2;              % indices of the lower half
    tkvint = 1 + (t1-1) / (1.5); % finer sampling... will make peaks appear higher
    tters = 1 + (t1-1) / (1.25); % finer sampling... will make peaks appear higher
    F2a = interp1(t1, F1a, tkvint); % perform sampling of lower half
    F2b = interp1(t1, F1b, tkvint); % resample upper half
    F2 = [F2a F2b];   % put the two together again

    F3a = interp1(t1, F1a, tters); % perform sampling of lower half
    F3b = interp1(t1, F1b, tters); % resample upper half
    F3 = [F3a F3b];   % put the two together again

    shiftedf2 = ifft(F2);   % and do the inverse FFT
    shiftedf2 = shiftedf2';

    shiftedf3 = ifft(F3);   % and do the inverse FFT
    shiftedf3 = shiftedf3';

    kvint= real(shiftedf2);
    ters = real(shiftedf3);

    soundsc(tempAudioData, 44000);
    soundsc(ters, 44000);
    %soundsc(kvint, 44000);
    
    
end