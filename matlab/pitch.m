function [ treklang ] = pitch(audio, first_pitch, second_pitch )

    base_audio = audio/(max(abs(audio)));

    n = 512; %number of samples to process at a time
    n2 = n*first_pitch;

    w_size = 2048; %window size
    w = hanningz(w_size); %Hanning window
    L = length(audio); %total length of audio

    %extend audio for proper window and interpolation
    audio = [ zeros(w_size,1); audio; zeros(w_size-mod(L,n),1)] / max(abs(audio));

    % Linear interpolation
    f_lx = floor(w_size*1/first_pitch);
    f_x = 1+(0:f_lx-1)'*w_size/f_lx;
    f_ix = floor(f_x);
    f_ix1 = f_ix+1;
    f_dx = f_x-f_ix;
    f_dx1 = 1-f_dx;

    % Linear interpolation
    s_lx = floor(w_size*1/second_pitch);
    s_x = 1+(0:s_lx-1)'*w_size/s_lx;
    s_ix = floor(s_x);
    s_ix1 = s_ix+1;
    s_dx = s_x-s_ix;
    s_dx1 = 1-s_dx;


    first_tone = zeros(f_lx+length(audio),1);  %initialize output for first tone
    second_tone = zeros(s_lx+length(audio),1); %initialize output for second tone

    omega = 2*pi*n*[0:w_size-1]'/w_size;
    phi0 = zeros(w_size,1);
    first_psi = zeros(w_size,1);
    second_psi = zeros(w_size,1);

    pin = 0;
    pout = 0;
    pend = length(audio)-w_size;

    while pin < pend
        grain = audio(pin+1:pin+w_size).* w;
        f = fft(fftshift(grain));
        r = abs(f);
        phi = angle(f);

        delta_phi = omega + princarg(phi-phi0-omega);
        phi0 = phi;

        first_psi = princarg(first_psi+delta_phi*first_pitch);
        second_psi = princarg(second_psi+delta_phi*second_pitch);

        first_ft = (r.* exp(i*first_psi));
        second_ft = (r.* exp(i*second_psi));

        % convolution for delay goes here

        f_grain= fftshift(real(ifft(first_ft))).* w;
        s_grain = fftshift(real(ifft(second_ft))).* w;

        %interpolation
        f_grain2 = [f_grain;0]; % add a zero
        f_grain3 = f_grain2(f_ix) .* f_dx1 + f_grain2(f_ix1).*f_dx;

        s_grain2 = [s_grain;0];
        s_grain3 = s_grain2(s_ix) .* s_dx1 + s_grain2(s_ix1).*s_dx;

        first_tone(pout+1:pout+f_lx) = first_tone(pout+1:pout+f_lx) + f_grain3;
        second_tone(pout+1:pout+s_lx) = second_tone(pout+1:pout+s_lx) + s_grain3;
        pin = pin + n;
        pout = pout + n;
    end

    first_tone = first_tone(w_size+1:w_size+L);
    second_tone = second_tone(w_size+1:w_size+L);
    
    

    treklang = base_audio+first_tone+second_tone;
end

