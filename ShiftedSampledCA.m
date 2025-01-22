function shifted_sampled_code=ShiftedSampledCA(PRN,Ts, code_delay)
% Generate the sampled C/A code sequence
% Input:
%   prn: PRN number (1-32)
%   Ts: Sampling interval of ADC
% Output:
%   Sampled_code: 1023-length C/A code sequence

ca_code=CA_generator(PRN);
fs = 1 / Ts;  % Sampling frequency
chips_per_second = 1.023e6;  % C/A code chip rate
samples_per_chip = fs / chips_per_second;  % Number of samples per chip

% Upsample the PRN code to match the sampling frequency
upsampled_code = repelem(ca_code, round(samples_per_chip));

% Truncate to 1 ms duration
num_samples = round(1023 * samples_per_chip);
upsampled_code = upsampled_code(1:num_samples);

% Apply fractional delay using interpolation
fractional_delay = mod(code_delay, 1) * samples_per_chip;
integer_delay = floor(code_delay * samples_per_chip);
shifted_sampled_code = circshift(upsampled_code, [0, integer_delay]);
if fractional_delay > 0
    shifted_sampled_code = interp1(1:length(shifted_sampled_code), shifted_sampled_code, ...
                          (1:length(shifted_sampled_code)) - fractional_delay, ...
                          'linear', 0);
end
end