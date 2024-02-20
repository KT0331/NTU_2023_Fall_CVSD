clear
close all
clc

K_error = zeros(25, 1);
alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03 0.01 0.007 0.003 0.002;
         2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11) 2^(-12)...
         2^(-13) 2^(-14) 2^(-15)];
K_floating = 1;
for km = 1 : 9
    K_floating = K_floating * cosd(alpha(1,km));
end

for i = 2 : 7
    K_fix = fi(K_floating, 1, i ,i-1);
    % disp(i);
    % disp(bin(K_fix));
    % disp(K_fix);
    K_error(i) = sum(abs(K_floating - double(K_fix))) * 100;
end


% figure(1);
% plot(K_error);
% xlabel('i');
% ylabel('K_error');