clear all;close all;clc
% GPS signal generation and acquisition
%% parameters
f_IF = 4.13e6; % intermediate frequency
sampling_rate = 5.714e6; % Sampling frequency 
ca_rate = 1.023e6; % C/A code chip rate
ca_period = 1e-3; % C/A code period in seconds (1 ms)
num_samples = ceil(sampling_rate * ca_period); % Number of samples for one C/A code period
doppler_range = -10000:250:10000; % Doppler frequency range
code_delay_range=0:0.5:1023; % Code delay range

%% load data
load("IncomingIF.mat"); % received signal within 1s

% extract the received signal within the first 1 ms
IncomingIF=reshape(IncomingIF,1000,5714);
incoming_1ms_IF=IncomingIF(1,:); % the signal within the first second
%% Analyze signal
% plot time series
figure(1)
T = length(incoming_1ms_IF) / sampling_rate;
t = linspace(0, T, length(incoming_1ms_IF));  % Linearly spaced time vector
plot(t*1000,incoming_1ms_IF);
xlabel('Time [ms]');
ylabel('Code Amplitude');
title('Time Series of Incoming IF Signal (within first 1 ms)');

% plot the Power Spectral Density
n = length(incoming_1ms_IF);
fft_signal = fft(incoming_1ms_IF); % Fourier transform 
fft_magnitude = abs(fft_signal / n).^2; % Normalization 
freq = (-n/2:n/2-1) * (1 / (n * T)); % frequency
fft_magnitude_shifted = fftshift(fft_magnitude); % shift frequency 
figure(2)
plot(freq / 1e6, 10 * log10(fft_magnitude_shifted));
xlabel('Frequency (MHz)');
ylabel('Power Spectral Density (dB)');
title('Power Spectral Density of Incoming IF Signal');
%% Signal acquisition: Time-Frequency space search
search_result = zeros(32,length(code_delay_range), length(doppler_range)); % Search result

% Time-search space search: calculate the correlation power (sum of components I and Q)
% sv: PRN number (1-32)
% code delay bin: 0.5 chip (0 to 1023 chip)
% Doppler shift bin: 250 Hz (-10 kHZ to +10 kHz)
for sv = 1:32
    % generate C/A code
    ca_code = ShiftedSampledCA(sv, 1 / sampling_rate, 0.5); % generate sampled C/A code with code delay (0.5 chip)
    samples_per_chip = sampling_rate / ca_rate;
    current_corr_power=zeros(length(code_delay_range), length(doppler_range));
    for code_idx = 1:length(code_delay_range)
        % code delay
        code_delay=code_delay_range(code_idx);
        shifted_code = circshift(ca_code, round(code_delay * samples_per_chip));
        
        for doppler_idx = 1:length(doppler_range)
            % Doppler shift 
            f_D = doppler_range(doppler_idx);
            f_NCO = f_IF + f_D;

            % generate sine and cosine waves
            t = (0:num_samples-1) / sampling_rate;
            sin_wave = sin(2 * pi * f_NCO * t);
            cos_wave = cos(2 * pi * f_NCO * t);

            % compute components I and Q 
            I_t = incoming_1ms_IF .* cos_wave;
            Q_t = incoming_1ms_IF .* sin_wave;

            % compute sum of squarred
            I_corr = sum(shifted_code.*I_t ); 
            Q_corr = sum(shifted_code.*Q_t  ); 
            corr_power = I_corr^2 + Q_corr^2;
            current_corr_power(code_idx,doppler_idx)=corr_power;
            search_result(sv,code_idx,doppler_idx)=corr_power;
        end
    end
    figure;
    gcf=surf(doppler_range,code_delay_range,current_corr_power);
    xlabel('Doppler Frequency (Hz)');
    ylabel('Code Phase (chips)');
    zlabel('Correlation Power');
    title(sprintf('Correlation Matrix for PRN %d', sv));
    colorbar;
    saveas(gcf,strcat(strcat('Signal power for PRN', num2str(sv)),".png"));
    close;
end

% find the maximum correlation value among all PRNs
[maxVal, linearIdx] = max(search_result(:)); 
[best_prn, best_code_idx, best_doppler_idx] = ind2sub(size(search_result), linearIdx);
best_code_delay=code_delay_range(best_code_idx);
best_doppler=doppler_range(best_doppler_idx);
fprintf('PRN %d: Best Doppler = %d Hz, Best Code Delay = %.2f chips\n', best_prn, best_doppler, best_code_delay);
