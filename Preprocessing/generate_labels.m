clc;
close all;

springer_options = default_Springer_HSMM_options;
load('example_data.mat');

train_recordings = example_data.example_audio_data([1:5]);
train_annotations = example_data.example_annotations([1:5],:);

test_recordings = example_data.example_audio_data(6);
test_annotations = example_data.example_annotations(6,:);

[B_matrix, pi_vector, total_obs_distribution] = trainSpringerSegmentationAlgorithm(train_recordings,train_annotations,springer_options.audio_Fs, false);

file_label_read = 'Z:\ZCHSound\ZCHSound\Clean Heartsound Data Details.csv';
label_read_temp = readtable(file_label_read);
label_read_temp = label_read_temp.diagnosis;
% 转为 categorical
labels_cat = categorical(label_read_temp, {'NORMAL','ASD','PDA','PFO','VSD'});
% 转换为 One-Hot
label_read = dummyvar(labels_cat);
label_store = [];

folder_read = 'Z:\ZCHSound\ZCHSound\clean Heartsound Data\';
folder_store = 'D:\Research\About4\data\ZCHSound\data_seg\';

files= dir([folder_read, '*.wav']);

for i=1:length(files)
% for i=1:2
    % 加载数据并重新采样数据1000Hz
    file= [folder_read files(i).name];
    [x, Fs1] = audioread(file);
    Fs = 1000;
    x = resample(x,Fs,Fs1); % resample to schmidt_options.audio_Fs (1000 Hz)
    x = butterworth_bandpass_filter(x,25,400,4,Fs,0); % BPF
    label = label_read(i, :);

    % 下采样和分割
    [assigned_states] = runSpringerSegmentationAlgorithm(x, springer_options.audio_Fs, B_matrix, pi_vector, total_obs_distribution, true);
    % features = extractFeaturesFromHsIntervals(assigned_states, y)
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

    for j=1:size(A,1)-1
        s1 = x(A(j,1):A(j,2)-1);    %s1
%         Sys=x(A(j,2):A(j,3));
        sys = x(A(j,2):A(j,3)-1);    %收缩期
        s2 = x(A(j,3):A(j,4)-1);    %s2
%         Dia=x(A(j,1):A(j+1,1));
        dia = x(A(j,4):A(j+1,1)-1);  %舒张期
        cycle = x(A(j,1):A(j+1,1)-1);

        s1 = x(A(j,1):A(j,2)-1);    %s1
        Sys=x(A(j,2):A(j,3));
        s2 = x(A(j,3):A(j,4)-1);    %s2
        Dia=x(A(j,1):A(j+1,1));
        cycle = x(A(j,1):A(j+1,1)-1);

        parts = split(files(i).name, '.');
        audio_name = parts{1};

        folder_s1 = strcat(folder_store, '1\');
        filename = strcat(folder_s1, audio_name, '_', num2str(j), '.wav');
        audiowrite(filename,s1,Fs);

        folder_sys = strcat(folder_store, '2\');
        filename = strcat(folder_sys, audio_name, '_', num2str(j), '.wav');
        audiowrite(filename,sys,Fs);

        folder_s2 = strcat(folder_store, '3\');
        filename = strcat(folder_s2, audio_name, '_', num2str(j), '.wav');
        audiowrite(filename,s2,Fs);

        folder_dia = strcat(folder_store, '4\');
        filename = strcat(folder_dia, audio_name, '_', num2str(j), '.wav');
        audiowrite(filename,dia,Fs);

        folder_cycle = strcat(folder_store, '5\');
        filename = strcat(folder_cycle, audio_name, '_', num2str(j), '.wav');
        audiowrite(filename,cycle,Fs);
        label_store = [label_store; label];
    end
end
writematrix(label_store, 'D:\\labels.csv');

