% function [B_matrix, pi_matrix] = trainSchmidtSegmentationAlgorithm(PCGCellArray, annotationsArray, Fs, figures)
%
% Training the emissions matrix, B_matrix, and initial distribution,
% pi_vector, for the Schmidt HMM segmentation algorithm.
%
% PCGCellArray：N 个音频信号的 1XN 单元阵列。 出于评估目的，这些信号应来自不同的训练记录集，
% 而算法应在单独的记录测试集上进行评估，这些记录集是从完全不同的患者集记录的（例如，如果有来自 每个病人）。
% annotationsArray：一个 Nx2 单元阵列：位置 (n,1) = R 峰的位置和位置 (n,2) = 末端 T 波的位置
% （都在样本中）
% Fs：采样频率
% 数字（可选）：指示数字显示的布尔变量。 
% % Inputs:
% PCGCellArray: A 1XN cell array of the N audio signals. For evaluation
% purposes, these signals should be from a distinct training set of
% recordings, while the algorithm should be evaluated on a separate test
% set of recordings, which are recorded from a completely different set of
% patients (for example, if there are numerous recordings from each
% patient).
% annotationsArray: a Nx2 cell array: position (n,1) = the positions of the
% R-peaks and postion (n,2) = the positions of the end-T-waves
% (both in SAMPLES)
% Fs: The sampling frequency
% figures (optional): boolean variable dictating the disaplay of figures.
%
%% Outputs:
% HMM 的 B_matrix 和 pi 数组 - 由于 Schmidt 等人的算法是依赖于持续时间的 HMM，
% 因此无需计算 A_matrix，因为状态之间的转换仅取决于状态持续时间。
% The B_matrix and pi arrays for an HMM - as Schmidt et al's algorithm is a
% duration dependant HMM, there is no need to calculate the A_matrix, as
% the transition between states is only dependant on the state durations.
%
% This code is derived from the paper:
% S. E. Schmidt et al., "Segmentation of heart sound recordings by a 
% duration-dependent hidden Markov model," Physiol. Meas., vol. 31,
% no. 4, pp. 513-29, Apr. 2010.
% 
% Developed by David Springer for comparison purposes in the paper:
% D. Springer et al., ?Logistic Regression-HSMM-based Heart Sound 
% Segmentation,? IEEE Trans. Biomed. Eng., In Press, 2015.
% 
% % Copyright (C) 2016  David Springer
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

function [B_matrix, pi_vector] = trainSchmidtSegmentationAlgorithm(PCGCellArray, annotationsArray, Fs, figures)


if(nargin < 4)
    figures = false;
end


%% Options

numberOfStates = 4;
numberOfPCGs = length(PCGCellArray); %返回PCGCellArray的行和列较大的数，音频信号的个数？

% 每个 PCG 记录中每个状态的值的矩阵：
% A matrix of the values from each state in each of the PCG recordings:
state_observation_values = cell(numberOfPCGs,numberOfStates);


for PCGi = 1:numberOfPCGs
    
    PCG_audio = PCGCellArray{PCGi};
    
    S1_locations = annotationsArray{PCGi,1};
    S2_locations = annotationsArray{PCGi,2};
    
    [PCG_Features, featuresFs] = getSchmidtPCGFeatures(PCG_audio, Fs);
    
    PCG_states = labelPCGStates(PCG_Features(:,1),S1_locations, S2_locations, featuresFs);
    
    
    %% Plotting assigned states:
    if(figures)
        figure('Name','Assigned states to PCG');
        
        t1 = (1:length(PCG_audio))./Fs;
        t2 = (1:length(PCG_Features))./featuresFs;
        
        plot(t1, PCG_audio, 'k-');
        hold on;
        plot(t2, PCG_Features, 'b-');
        plot(t2, PCG_states, 'r-');
        
        legend('Audio','Features','States');
        pause();
    end
    
    
    
    %% Group together all observations from the same state in the PCG recordings:
    for state_i = 1:numberOfStates
        state_observation_values{PCGi,state_i} = PCG_Features(PCG_states == state_i,:);
    end
end

% This line saves the "state_observation_values" variable in the main
% matlab workspace so that it can be investigated at a later time.
assignin('base', 'state_observation_values', state_observation_values)

%% Train the B and pi matrices after all the PCG recordings have been labelled:
[B_matrix, pi_vector] = trainBandPiMatricesSchmidt(state_observation_values);

