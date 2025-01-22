clear all;close all;clc

% Generate C/A code of PRN#1 and PRN#2
code_prn1=CA_generator(1);
code_prn2=CA_generator(2);

% Initialize correlation arrays
auto_corr = zeros(1, 1023);
cross_corr = zeros(1, 1023);

% Compute auto-correlation for PRN#1
for shift = 0:1022
    shifted_code = [code_prn1(shift+1:end), code_prn1(1:shift)];
    auto_corr(shift+1) = (shifted_code * code_prn1') / 1023;
end

% Compute cross-correlation between PRN#1 and PRN#2
for shift = 0:1022
    shifted_code = [code_prn2(shift+1:end), code_prn2(1:shift)];
    cross_corr(shift+1) = (shifted_code * code_prn1') / 1023;
end

% Plot auto-correlation of PRN#1
figure(1);
plot(auto_corr, 'b', 'LineWidth', 1.5);
title('Auto-Correlation of PRN1');
xlabel('Code delay (chips)');
ylabel('Correlation');

% Plot cross-correlation of PRN#1 and PRN#2
figure(2);
plot(cross_corr, 'r', 'LineWidth', 1.5);
title('Cross-Correlation of PRN1 and PRN2');
xlabel('Code delay (chips)');
ylabel('Correlation');

% Sampling Code
shifted_sampled_code_prn1=ShiftedSampledCA(1,1 / 5.714e6,0.5);
shifted_sampled_code_prn2=ShiftedSampledCA(2,1 / 5.714e6,0.5);

% Initialize correlation arrays
auto_corr2 = zeros(1, 5714);
cross_corr2 = zeros(1, 5714);

% Compute auto-correlation for PRN#1
for shift = 0:5713
    shifted_code = [shifted_sampled_code_prn1(shift+1:end), shifted_sampled_code_prn1(1:shift)];
    auto_corr2(shift+1) = (shifted_code * shifted_sampled_code_prn1') / 5714;
end

% Compute cross-correlation between PRN#1 and PRN#2
for shift = 0:5713
    shifted_code = [shifted_sampled_code_prn2(shift+1:end), shifted_sampled_code_prn2(1:shift)];
    cross_corr2(shift+1) = (shifted_code * shifted_sampled_code_prn1') / 5714;
end

% Plot auto-correlation of PRN#1
figure(3);
plot(auto_corr2, 'b', 'LineWidth', 1.5);
title('Auto-Correlation of Sampled Code of PRN1');
xlabel('Code delay (chips)');
ylabel('Correlation');

% Plot cross-correlation of PRN#1 and PRN#2
figure(4);
plot(cross_corr2, 'r', 'LineWidth', 1.5);
title('Cross-Correlation of Sampled Code of PRN1 and PRN2');
xlabel('Code delay (chips)');
ylabel('Correlation');