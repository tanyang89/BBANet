% BBANet hss file 

clc;
close all;

springer_options = default_Springer_HSMM_options;
load('example_data.mat');

train_recordings = example_data.example_audio_data([1:5]);
train_annotations = example_data.example_annotations([1:5],:);

test_recordings = example_data.example_audio_data(6);
test_annotations = example_data.example_annotations(6,:);

[B_matrix, pi_vector, total_obs_distribution] = trainSpringerSegmentationAlgorithm(train_recordings,train_annotations,springer_options.audio_Fs, false);

folder_name = 'c'; % when the folder_name = 'e', use the following cod
file_label_read = strcat('D:\Research\About toolkit\databases\physionet_origin\labels\', folder_name, '.csv');
label_cont_read = readtable(file_label_read);
wav_name_read = label_cont_read(:, 1).Var1;
% when the folder_name = 'e', use the following code
% for k=1:2141
%     wav_name_read{k}(2)='';
% end
%
label_read = label_cont_read(:, 2).Var2;
label_store = [];
file_label_store = strcat('D:\Research\About toolkit\databases\physionet_seg\labels\', folder_name, '.csv');
folder_store = strcat('D:\Research\About toolkit\databases\physionet_seg\', folder_name, '\');
folder_read = strcat('D:\Research\About toolkit\databases\physionet_origin\', folder_name, '\');
files= dir([folder_read, '*.wav']); %读取文件夹下的所有wav文件

% for i=1:length(files)
for i=7
    % 加载数据并重新采样数据1000Hz
    file= [folder_read files(i).name];
    [y,Fs1] = audioread(file);
    Fs = 1000;
    y = resample(y,Fs,Fs1); % resample to schmidt_options.audio_Fs (1000 Hz)

    % 剪切为1s-4s=3s
%     start_time = 0.3;
%     end_time = 5.3;
%     x=y((Fs*start_time+1):Fs*end_time,1); %取心音信号的前5s
    x = y;

    % 带通滤波器
    x=butterworth_bandpass_filter(x,25,400,4,Fs,0)
    subplot(1, 2, 1);
    imshow(image1);
    title('Photo 1');

    % 下采样和分割
    [assigned_states] = runSpringerSegmentationAlgorithm(x, springer_options.audio_Fs, B_matrix, pi_vector, total_obs_distribution, true);
    %features = extractFeaturesFromHsIntervals(assigned_states, y)
    indx = find(abs(diff(assigned_states))>0); % find the locations with changed states

    if assigned_states(1)>0   % for some recordings, there are state zeros at the beginning of assigned_states
        switch assigned_states(1)
            case 4
                K=1;
            case 3
                K=2;
            case 2
                K=3;
            case 1
                K=4;
        end
    else
        switch assigned_states(indx(1)+1)
            case 4
                K=1;
            case 3
                K=2;
            case 2
                K=3;
            case 1
                K=0;
        end
        K=K+1;
    end

    indx2                = indx(K:end);
    rem                  = mod(length(indx2),4);
    indx2(end-rem+1:end) = [];
    A                    = reshape(indx2,4,length(indx2)/4)'; %每个心音周期S1, systole, S2 and diastole开始的前一个点位置
%    %% Feature calculation
%     S_s1 = [];
%     S_sys= [];
%     S_s2 = [];
%     S_dia =[];
%     s1_sys=[];
%     s2_dia=[];
%     heart_cycle=[];
% 
%     m_RR=round(mean(diff(A(:,1)))); %一个心音周期的平均样点数
%     mean_S1  = round(mean(A(:,2)-A(:,1))); %S1期的平均样点数
%     mean_S2  = round(mean(A(:,4)-A(:,3))); %S2期的平均样点数
%     mean_Sys = round(mean(A(:,3)-A(:,2))); %Sys期的平均样点数
%     mean_Dia = round(mean(A(2:end,1)-A(1:end-1,4))); %Dia期的平均样点数

    for j=1:size(A,1)-1
        s1 = x(A(j,1):A(j,2)-1);    %s1
%         Sys=x(A(j,2):A(j,3));
        sys = x(A(j,2):A(j,3)-1);    %收缩期
        s2 = x(A(j,3):A(j,4)-1);    %s2
%         Dia=x(A(j,1):A(j+1,1));
        dia = x(A(j,4):A(j+1,1)-1);  %舒张期
        cycle = x(A(j,1):A(j+1,1)-1);

        folder_s1 = strcat(folder_store, '1\');
        filename = strcat(folder_s1, files(i).name(1:5), '_', num2str(j), '.wav');
        audiowrite(filename,s1,Fs);

        folder_sys = strcat(folder_store, '2\');
        filename = strcat(folder_sys, files(i).name(1:5), '_', num2str(j), '.wav');
        audiowrite(filename,sys,Fs);

        folder_s2 = strcat(folder_store, '3\');
        filename = strcat(folder_s2, files(i).name(1:5), '_', num2str(j), '.wav');
        audiowrite(filename,s2,Fs);

        folder_dia = strcat(folder_store, '4\');
        filename = strcat(folder_dia, files(i).name(1:5), '_', num2str(j), '.wav');
        audiowrite(filename,dia,Fs);

        folder_cycle = strcat(folder_store, '5\');
        filename = strcat(folder_cycle, files(i).name(1:5), '_', num2str(j), '.wav');
        audiowrite(filename,cycle,Fs);

        
%         S_s1=[S_s1;S1];    %一段音频的所有S1的拼接
%         %S_sys=[S_sys;Sys]; %一段音频的所有sys拼接
%         S_s2=[S_s2;S2];     %一段音频的所有S2的拼接
%         %S_dia=[S_dia;Dia];  %一段音频的所有Dia拼接
%         s1_sys=[s1_sys;S1_sys]; %一段音频的所有S1_sys拼接
%         s2_dia=[s2_dia;S2_Dia]; %一段音频的所有S2_Dia拼接
%         heart_cycle=[heart_cycle;s1_sys_s2_dia];%一段音频的所有s1_sys_s2_dia拼接
    end

%     str1='D:\trainingb\s1\';
%     filename=[str1 files(i).name];
%     audiowrite(filename,S_s1,Fs); %将拼接的S_s1重新保存为wav文件
%     
%     str2='D:\trainingb\sys\';
%     filename=[str2 files(i).name];
%     audiowrite(filename,s1_sys,Fs); %将拼接的s1_sys重新保存为wav文件
% 
%     str3='D:\trainingb\s2\';
%     filename=[str3 files(i).name];
%     audiowrite(filename,S_s2,Fs); %将拼接的S_s2重新保存为wav文件
%     
%     str4='D:\trainingb\dia\'; 
%     filename=[str4 files(i).name];
%     audiowrite(filename,s2_dia,Fs); %将拼接的s2_dia重新保存为wav文件
%     
%     str5='D:\trainingb\cycle\';
%     filename=[str5 files(i).name];
%     audiowrite(filename,heart_cycle,Fs); %将拼接的S_s1重新保存为wav文件
    if wav_name_read{i} == files(i).name(1:5)
        l = label_read(i);
        label_temp = repmat(l, j, 1);
        label_store = vertcat(label_store, label_temp);
    else
        error('程序已终止');
    end
end

