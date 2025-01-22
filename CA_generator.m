function code = CA_generator(PRN)
% Generate the C/A code for a given PRN (1-32)
% Input:
%   prn: PRN number (1-32)
% Output:
%   code: 1023-length C/A code sequence

% Initial states for Linear feedback shift register (LFSR) of length G1 and G2
G1 = ones(1, 10); 
G2 = ones(1, 10);

% PRN taps (satellite-specific tap positions)
prn_taps_table = [
    2, 6;   % PRN1
    3, 7;   % PRN2
    4, 8;   % PRN3
    5, 9;   % PRN4
    1, 9;   % PRN5
    2, 10;  % PRN6
    1, 8;   % PRN7
    2, 9;   % PRN8
    3, 10;  % PRN9
    2, 3;   % PRN10
    3, 4;   % PRN11
    5, 6;   % PRN12
    6, 7;   % PRN13
    7, 8;   % PRN14
    8, 9;   % PRN15
    9, 10;  % PRN16
    1, 4;   % PRN17
    2, 5;   % PRN18
    3, 6;   % PRN19
    4, 7;   % PRN20
    5, 8;   % PRN21
    6, 9;   % PRN22
    1, 3;   % PRN23
    4, 6;   % PRN24
    5, 7;   % PRN25
    6, 8;   % PRN26
    7, 9;   % PRN27
    8, 10;  % PRN28
    1, 6;   % PRN29
    2, 7;   % PRN30
    3, 8;   % PRN31
    4, 9;   % PRN32
];

offset_table=[
    5;
    6;
    7;
    8;
    17;
    18;
    139;
    140;
    141;
    251;
    252;
    254;
    255;
    256;
    257;
    258;
    469;
    470;
    471;
    472;
    473;
    474;
    509;
    512;
    513;
    514;
    515;
    516;
    859;
    860;
    861;
    862;
];

% Validate PRN input
if PRN < 1 || PRN > 32
    error('PRN must be between 1 and 32.');
end

% Get the taps for the given PRN
selector = prn_taps_table(PRN, :);
select1 = selector(1);
select2 = selector(2);

% Get the offset
offset=offset_table(PRN,:);

% Generate the C/A code sequence
code = zeros(1, 1023);

for i = 1:1023
    % Generate the code bit (modulo-2 addition of selected G2 taps)
    G1_output = G1(10);
    G2_output = xor(G2(select1), G2(select2)); % Adjust G2 output by offset
    
    % Shift G2
    feedback2 = xor(G2(2), xor(G2(3), xor(G2(6), xor(G2(8), xor(G2(9), G2(10))))));
    G2 = [feedback2, G2(1:end-1)];

    % Apply offset to G2
    G2_shifted = circshift(G2_output, [0, offset]);

    code(i) = xor(G1_output, G2_shifted); % Generate C/A code

    % Shift G1
    feedback1 = xor(G1(3), G1(10));
    G1 = [feedback1, G1(1:end-1)];
    
end

% Convert 0 to -1 for numerical representation
code = 1 - 2 * code; % Change logic value 0 to +1 and 1 to -1
end
