%% adding the path of subfolders
clc;
addpath('functions/');
addpath('database/');
addpath('musics/');
addpath('test_musics/');

%% loading the created database
clear; close all; clc;

database = load('database/database.mat').database;

%% calculate the hash tags for the given song

% importing an audio
path = 'musics/'; % musics path
song_num_1 = 35; % music i
song_num_2 = 36;

format = '.mp3';
[downsampled_Fs_1, audioMono_1] = import_audio(path, song_num_1, format);
[downsampled_Fs_2, audioMono_2] = import_audio(path, song_num_2, format);

duration = 20;
Start_1 = floor(rand*(length(audioMono_1)));
audioSelected_1 = audioMono_1(max(Start_1,1):min(downsampled_Fs_1*duration,length(audioMono_1)) + Start_1,1);

Start_2 = floor(rand*(length(audioMono_2)));
audioSelected_2 = audioMono_2(max(Start_2,1):min(downsampled_Fs_2*duration,length(audioMono_2)) + Start_2,1);

alfa = 0.5;

audioMono = alfa*(audioSelected_1)+(1-alfa)*(audioSelected_2);

% creating the time-freq matrix of the audio using fft and an overlapping sliding window with the length of "window_time"
window_time = 0.1;
[time, freq, time_freq_mat] = STFT(audioMono, downsampled_Fs, window_time);

% a full screen figure for plots
figure('Units','normalized','Position',[0 0 1 1])

% plotting the stft
subplot(1,2,1);
pcolor(time, freq, time_freq_mat);
shading interp
colorbar;
xlabel('time(s)','interpreter','latex');
ylabel('frequency(Hz)','interpreter','latex');
title('STFT(dB)','interpreter','latex');

% finding the anchor points from time_freq_mat using a sliding window with the size of 2dt*2df
df = floor(0.1*size(time_freq_mat, 1)/4);
dt = 2/window_time;
% finding anchor points
anchor_points = find_anchor_points(time_freq_mat, dt, df);
% plotting the anchor points
subplot(1,2,2);
scatter(time(anchor_points(:, 2)), freq(anchor_points(:, 1)),'x');
xlabel('time(s)','interpreter','latex');
ylabel('frequency(Hz)','interpreter','latex');
title("anchor points",'interpreter','latex');
xlim([time(1) time(end)]);
ylim([freq(1) freq(end)]);
grid on; grid minor;

% creating the hash tags using a window with the size of dt*2df for each anchor point
df_hash = floor(0.1*size(time_freq_mat,1));
dt_hash = 20/window_time;
% creating hash-keys and hash-values for each pair of anchor points
% Key format: (f1*f2*(t2-t1)) 
% Value format: (song_name*time_from_start)
[hash_key, hash_value] = create_hash_tags(anchor_points, df_hash, dt_hash, 0);

%% searching hash tags
clc; close all;

list = []; 

% searching for found hash-keys in the database
for i = 1:length(hash_key)
    key_tag = [num2str(hash_key(i, 1)), '*', num2str(hash_key(i, 2)), '*', num2str(hash_key(i, 3))];
    if (isKey(database, key_tag))
        temp1 = split(database(key_tag),'+');
        for j = 1:length(temp1)
            temp2 = split(temp1{j},'*');
            list = [list; [str2num(temp2{1}),str2num(temp2{2}),hash_value(i,2)]];
        end
    end
end

%% scoring
clc; close all;

scoring(list);