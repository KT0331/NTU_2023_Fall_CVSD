clear
close all
clc

alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
         2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
K = 1;
for km = 1 : 9
    K = K * cosd(alpha(1,km));
end
K_fix = fi(K, 1, 7 ,6);

k = K_fix;

%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

F = fimath('RoundingMethod','Floor');
x_y_computing_type = numerictype(true, 19, 14);
x_y_type   = numerictype(true, 18, 14);

% ix = fi(0.2785,x_y_type ,F);
% iy = fi(0.5468,x_y_type ,F);

ix = fi(hex2dec('000be')/2^14,x_y_type ,F);
iy = fi(hex2dec('3f2e8')/2^14,x_y_type ,F);

d = [-1 1 1 -1 1 -1 1 1 -1];

%Initialize
% F = fimath('RoundingMethod','Nearest','OverflowAction','Wrap');
ox = fi(ix ,x_y_computing_type ,F);
oy = fi(iy ,x_y_computing_type ,F);

for i = 1 : 9
    ox_temp = ox;
    oy_temp = oy;
    dx_computing = - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    dx = fi(dx_computing ,x_y_computing_type ,F);
    ox = ox_temp + dx;
    dy_computing = d(1 ,i) * 2^(-(i-1)) * ox_temp;
    dy = fi(dy_computing ,x_y_computing_type ,F);
    oy = oy_temp + dy;
    ox = fi(ox ,x_y_computing_type ,F);
    oy = fi(oy ,x_y_computing_type ,F);
end

ox = ox * k;
oy = oy * k;
ox = fi(ox ,x_y_type ,F);
oy = fi(oy ,x_y_type ,F);
hex(ox)
hex(oy)