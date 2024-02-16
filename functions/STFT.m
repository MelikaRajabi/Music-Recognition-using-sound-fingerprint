function [time,frequency,time_frequency_matrix] = STFT(audio,Fs,window_time)

    window_length = Fs*window_time;
    window_num = floor(length(audio)/(window_length/2));
    time_frequency_matrix = zeros(1+floor(window_length/2),window_num-1);
   
    if length(audio)<(window_num-1)+(window_num-1)*floor(window_length/2)
        audio(length(audio):(window_num-1)+(window_num-1)*floor(window_length/2),1) = 0;
    end
          
    for i = 1:window_num-1
             audioSelected = audio(i+(i-1)*floor(window_length/2):i+i*floor(window_length/2),1);
             time_frequency_matrix(:,i) = FFT(audioSelected);
    end
    
    for j = 1:size(time_frequency_matrix,1)
        time_frequency_matrix(j,:) = time_frequency_matrix(j,:) + (rand/1000)*ones(1,size(time_frequency_matrix,2));       
    end
    
    time = (window_time/2)*(1:(window_num-1));
    frequency = Fs*(0:floor(window_length/2))/window_length;
    
end
