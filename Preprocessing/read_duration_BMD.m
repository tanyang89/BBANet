% read the longest length of heart sound

clc;
clear;

l_max = 0;
folder_store = 'D:\Research\About4\data\BMD-HS-Dataset-main\BMD-HS-Dataset-main\seg\4\';
files= dir([folder_store, '*.wav']); %读取文件夹下的所有wav文件
for j = 1:length(files)
    file = [folder_store files(j).name];
    [y, Fs] = audioread(file);
    l = length(y);
    if l_max < l
        l_max = l;
    end
end

%1: 180
%2: 880
%3: 160
%4: 1960
%5: 2480