% expand

clc;
clear;

max_l = 2480;

folder_read = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\seg\5\';
folder_store = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\seg_re\5\';
files= dir([folder_read, '*.wav']); %读取文件夹下的所有wav文件
for j = 1:length(files)
    file = [folder_read files(j).name];
    [y, fs] = audioread(file);
    n = ceil(max_l / numel(y));
    extendedSignal = repmat(y, 1, n);
    extendedSignal = extendedSignal(1:max_l);
    file_store = [folder_store files(j).name];
    audiowrite(file_store, extendedSignal, fs);  
end

%1: 180
%2: 880
%3: 160
%4: 1960
%5: 2480
  