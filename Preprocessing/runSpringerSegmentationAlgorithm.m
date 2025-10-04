
% function assigned_states = runSpringerSegmentationAlgorithm(audio_data, Fs, B_matrix, pi_vector, total_observation_distribution, figures)
%
% A function to assign states to a PCG recording using a duration dependant
% logisitic regression-based HMM, using the trained B_matrix and pi_vector
% trained in "trainSpringerSegmentationAlgorithm.m". Developed for use in
% the paper:
% D. Springer et al., "Logistic Regression-HSMM-based Heart Sound
% Segmentation," IEEE Trans. Biomed. Eng., In Press, 2015.
%
%% INPUTS:
% audio_data: The audio data from the PCG recording
% Fs: the sampling frequency of the audio recording
% B_matrix: the observation matrix for the HMM, trained in the 
% "trainSpringerSegmentationAlgorithm.m" function
% pi_vector: the initial state distribution, also trained in the 
% "trainSpringerSegmentationAlgorithm.m" function
% total_observation_distribution, the observation probabilities of all the
% data, again, trained in trainSpringerSegmentationAlgorithm.
% figures: (optional) boolean variable for displaying figures
%
%% OUTPUTS:
% assigned_states: the array of state values assigned to the original分配给原始状态值的数组 
% audio_data (in the original sampling frequency).
%
%% Copyright (C) 2016  David Springer
% dave.springer@gmail.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function assigned_states = runSpringerSegmentationAlgorithm(audio_data, Fs, B_matrix, pi_vector, total_observation_distribution, figures)

%% Preliminary
if(nargin < 6)
    figures = false;
end

%% Get PCG Features:

[PCG_Features, featuresFs] = getSpringerPCGFeatures(audio_data, Fs);

%% Get PCG heart rate

[heartRate, systolicTimeInterval] = getHeartRateSchmidt(audio_data, Fs);

[~, ~, qt] = viterbiDecodePCG_Springer(PCG_Features, pi_vector, B_matrix, total_observation_distribution, heartRate, systolicTimeInterval, featuresFs);

assigned_states = expand_qt(qt, featuresFs, Fs, length(audio_data));

% if(figures)
%    figure('Name','Derived state sequence');
%    t1 = (1:length(audio_data))./Fs;
%    plot(t1,normalise_signal(audio_data),'k');
%    hold on;
%    plot(t1,assigned_states,'r--');
%    xlabel('Time (s)');
%    legend('Audio data', 'Derived states');
% end

% if(figures)
%    figure('Name','Derived state sequence');
%    set(gcf, 'Position', [100, 100, 1200, 300]);  % [left, bottom, width, height]
%  
%    % 创建第一个子图（上图），显示 audio_data 和 derived states
%    subplot(1, 2, 2);  % 2行1列的第一个子图
%    t1 = (1:length(audio_data)) ./ Fs;  % 时间向量t1
%    plot(t1, normalise_signal(audio_data), 'k');  % 绘制音频数据
%    hold on;
%    plot(t1, assigned_states, 'r--');  % 绘制状态序列
%    xlabel('Time (s)');
%    legend('Audio data', 'Derived states', 'FontSize', 12);
%    % 设置纵轴最大值为8
%    ylim([-8 13]);  % 设置纵轴的范围，从0到8
%    xlim([0 2]);
%    set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
%    
%    % 创建第二个子图（下图），显示 PCG_Features
%    subplot(1, 2, 1);  % 2行1列的第二个子图
%    t1 = (1:length(audio_data)) ./ Fs;  % 时间向量t1
%    plot(t1, normalise_signal(audio_data), 'k');  % 绘制音频数据
%    hold on;
%    t2 = (1:length(PCG_Features)) ./ featuresFs;  % 时间向量t2
%    plot(t2, PCG_Features, 'b-');  % 绘制 PCG 特征
%    xlabel('Time (s)');
%    legend('Audio data', 'Audio features', 'FontSize', 12);
%    % 设置纵轴最大值为8
%    ylim([-8 13]);  % 设置纵轴的范围，从0到8
%    xlim([0 2]);
%    set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);
% 
%    % 保存当前图形为紧凑的PDF图片
%    saveas(gcf, 'A.emf', 'emf');
% end


