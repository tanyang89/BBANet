clc;
clear;

folder_name = ['a','b','c','d','e','f']; 

for i=1:length(folder_name)
    folder_name_temp = folder_name(i);
    folder_store = strcat('D:\Research\About toolkit\databases\physionet_seg_repeat\', folder_name_temp, '\1\');
    files= dir([folder_store, '*.wav']); %读取文件夹下的所有wav文件
    for j=1:3
        file = [folder_store files(j).name];
        [y, Fs] = audioread(file);
        n = ceil(max_l / numel(y));
        extendedSignal = repmat(y, 1, n);
        extendedSignal = extendedSignal(1:max_l);
        filename = [file(1:49), '_repeat_figs', file(50:end-4), '.png'];

        imwrite(A, fullpath);
    end
end




