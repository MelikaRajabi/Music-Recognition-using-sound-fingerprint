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

alfa = [0:0.1:1];
score_1 = [];
score_2 = [];

for n = 1:11
    
audioMono = alfa(n)*(audioSelected_1)+(1-alfa(n))*(audioSelected_2);

% creating the time-freq matrix of the audio using fft and an overlapping sliding window with the length of "window_time"
window_time = 0.1;
[time, freq, time_freq_mat] = STFT(audioMono, downsampled_Fs, window_time);

% finding the anchor points from time_freq_mat using a sliding window with the size of 2dt*2df
df = floor(0.1*size(time_freq_mat, 1)/4);
dt = 2/window_time;

% finding anchor points
anchor_points = find_anchor_points(time_freq_mat, dt, df);

% creating the hash tags using a window with the size of dt*2df for each anchor point
df_hash = floor(0.1*size(time_freq_mat,1));
dt_hash = 20/window_time;

% creating hash-keys and hash-values for each pair of anchor points
% Key format: (f1*f2*(t2-t1)) 
% Value format: (song_name*time_from_start)
[hash_key, hash_value] = create_hash_tags(anchor_points, df_hash, dt_hash, 0);

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

if ~isempty(list) 
     score = scoring2(list);
     score_1 = [score_1 score(35,2)];
     score_2 = [score_2 score(36,2)];
end

end

figure('Units','normalized','Position',[0 0 1 1]);

plot(alfa , score_1,'color',[0.2,0.8,0.99],'linewidth',2);
xlabel('$\alpha\$','interpreter','latex');

hold on;
plot(alfa , score_2,'color',[0.99,0.4,0.6],'linewidth',2);
xlabel('$\alpha$','interpreter','latex');
legend('Probability of music 1','Probability of music 2','interpreter','latex');

%% Function 

function score = scoring2(list)
    if ~isempty(list) % similarity length != 0
        matched_musics = unique(list(:,1)); % musics which for similarity is found
        score = zeros(length(matched_musics),2); % music name - repetition num
        eps = 0.1;
        for i = 1:length(matched_musics)
            temp = list(list(:,1) == matched_musics(i),:); 
            num = length(temp); % number of repeats for music i
            standard_dev = std(temp(:,2)-temp(:,3))/max(temp(:,2)-temp(:,3));
            score(i, 1) = matched_musics(i); % music name
            % score formula (using repetition num and std of delta ts)
            score(i, 2) = log10(num)*(1-exp((1-num)/10))*(1/(standard_dev+eps)); 
        end
        % applying softmax function to get probability distribution
        score(:, 2) = exp(score(:,2))./sum(exp(score(:,2)));
    end
end
