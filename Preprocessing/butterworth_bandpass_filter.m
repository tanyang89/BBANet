% 心音分割带通滤波器函数

function bandpass_filtered_signal = butterworth_bandpass_filter(original_signal, low_cutoff, high_cutoff, order, sampling_frequency, figures)

if nargin < 6,
    figures = 0;
end

% 使用高通滤波器滤除低频信号
high_pass_filtered_signal = butterworth_high_pass_filter(original_signal,order,low_cutoff,sampling_frequency,0);

% 使用低通滤波器滤除高频信号
bandpass_filtered_signal = butterworth_low_pass_filter(high_pass_filtered_signal, order, high_cutoff, sampling_frequency,0);

if(figures)
    figure('Name','Original vs. bandpass filtered signal');
    plot(original_signal);
    hold on;
    plot(bandpass_filtered_signal,'r');
    legend('Original Signal', 'Bandpass filtered signal');
    pause();
end
