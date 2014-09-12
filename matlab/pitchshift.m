load('piano1.mat')

F1 = fft(y1);
N = numel(F1);
F1a = F1(1:N/2);         % the lower half of the fft
F1b = F1(end:-1:N/2+1);  % the upper half of the fft - flipped "the right way around"

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

soundsc(y1);
soundsc(kvint);
soundsc(ters);

wavwrite(y1,'g.wav');
wavwrite(ters,'t.wav');
wavwrite(kvint,'k.wav');
