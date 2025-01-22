function sampled_code = SampledCA(PRN,Ts)
% Generate the sampled C/A code sequence
% Input:
%   prn: PRN number (1-32)
%   Ts: Sampling interval of ADC
% Output:
%   Sampled_code: 1023-length C/A code sequence

% Generate original C/A code
ca_code = CA_generator(PRN); 
chips_per_ms = 1023; 
fs = 1 / Ts; % sampling rate
num_samples = round(fs * 1e-3); % sampling numbers within 1ms
t = linspace(0, 1, num_samples); % sampling time
sampled_code = interp1(linspace(0, 1, chips_per_ms), ca_code, t, 'nearest');
end