% 4 components preprocessing file 
% for hss

clc;
close all;

springer_options = default_Springer_HSMM_options;
load('example_data.mat');

train_recordings = example_data.example_audio_data([1:5]);
train_annotations = example_data.example_annotations([1:5],:);

test_recordings = example_data.example_audio_data(6);
test_annotations = example_data.example_annotations(6,:);

[B_matrix, pi_vector, total_obs_distribution] = trainSpringerSegmentationAlgorithm(train_recordings,train_annotations,springer_options.audio_Fs, false);

% label_read = [];
% file_label_read = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\train.csv';
% label_read_temp = readtable(file_label_read);
% label_read_temp = label_read_temp(:,2).Var2;
% for i = 1:numel(label_read_temp)
%     label_read{i} = strsplit(label_read_temp{i}, ',');
% end
% opts = delimitedTextImportOptions("NumVariables", 2);
% opts.DataLines = [1, Inf];
% opts.Delimiter = "\t";
% opts.VariableNames = ["Var1", "Var2"];
% opts.VariableTypes = ["string", "double"];
% opts.ExtraColumnsRule = "ignore";
% opts.EmptyLineRule = "read";
% T = readtable(file_label_read, opts);
% wav_name_read = T(:, 1).Var1;
% label_read = T(:, 2).Var2;
% label_store = [];

% file_label_store = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\seg.csv';
folder_store = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\seg\';
folder_read = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\train\';

files= dir([folder_read, '*.wav']);

for i=1:length(files)
% for i=1:2
    % 加载数据并重新采样数据1000Hz
    file= [folder_read files(i).name];
%     number_parts = split(file, '_'); % 按下划线分割
%     number = str2double(parts{2}); % 提取第二部分
    [x, Fs1] = audioread(file);
    Fs = 1000;
    x = resample(x,Fs,Fs1); % resample to schmidt_options.audio_Fs (1000 Hz)
    x = butterworth_bandpass_filter(x,25,400,4,Fs,0); % BPF

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

        folder_s1 = strcat(folder_store, '1\');
        filename = strcat(folder_s1, files(i).name(1:14), '_', num2str(j), '.wav');
        audiowrite(filename,s1,Fs);

        folder_sys = strcat(folder_store, '2\');
        filename = strcat(folder_sys, files(i).name(1:14), '_', num2str(j), '.wav');
        audiowrite(filename,sys,Fs);

        folder_s2 = strcat(folder_store, '3\');
        filename = strcat(folder_s2, files(i).name(1:14), '_', num2str(j), '.wav');
        audiowrite(filename,s2,Fs);

        folder_dia = strcat(folder_store, '4\');
        filename = strcat(folder_dia, files(i).name(1:14), '_', num2str(j), '.wav');
        audiowrite(filename,dia,Fs);

        folder_cycle = strcat(folder_store, '5\');
        filename = strcat(folder_cycle, files(i).name(1:14), '_', num2str(j), '.wav');
        audiowrite(filename,cycle,Fs);
    end

%     l = label_read(number);
%     for k=1:5
%         l = l{1}{k};
%         if l == 1
%             label_temp = repmat(l, k, 1);
%             label_store = vertcat(label_store, label_temp);
%         end
%     end
% 
% 
%     if number == files(i).name(1:14)
%         l = label_read(i);
%         label_temp = repmat(l, j, 1);
%         label_store = vertcat(label_store, label_temp);
%     end
end

