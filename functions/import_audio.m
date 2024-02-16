function [downsampled_Fs , audioDownsampled] = import_audio(path , song_num , format)

    [audio , Fs] = audioread([path , 'music' , num2str(song_num) , format]);
    
    audioMono = sum(audio , 2)./2;
   
    downsampled_Fs = 8000;
   [Num , Denom] = rat(downsampled_Fs/Fs);
    audioDownsampled = resample(audioMono,Num,Denom);
   
end