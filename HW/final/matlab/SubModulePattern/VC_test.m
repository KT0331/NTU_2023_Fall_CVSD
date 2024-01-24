clear
close all
clc

alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
         2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
K = 1;
for km = 1 : 9
    K = K * cosd(alpha(1,km));
end
K_fix = fi(K, 0, 6 ,6);

k = K_fix;
F = fimath('RoundingMethod','Floor');
%d(i)   = -sign(x(i) * y(i))
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

x_y_computing_type = numerictype(true, 19, 14);
x_y_type   = numerictype(true, 18, 14);

% ix = fi(0.6324,x_y_type ,F);
iy = fi(0.0975,x_y_type ,F);

ix = fi(bin2dec('10000011101101')/2^14,x_y_type ,F);
iy = fi(bin2dec('111111011110101111')/2^14,x_y_type ,F);

%Initialize
% F = fimath('RoundingMethod','Nearest','OverflowAction','Wrap');
ox = fi(ix ,x_y_computing_type ,F);
oy = fi(iy ,x_y_computing_type ,F);

%History of d ,x ,y
d = zeros(1 ,9);
x = zeros(1 ,10);
x(1 ,1) = ox;
y = zeros(1 ,10);
y(1 ,1) = oy;

for i = 1 : 9
    %Decide rotation direction : -1 means clockwise and +1 means counterclockwise
    if ox * oy > 0
        d(1 ,i) = -1;
    elseif ox * oy < 0
        d(1 ,i) = +1;
    else
        d(1 ,i) = -1;
    end
    ox_temp = ox;
    oy_temp = oy;
    dx_computing = - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    dx = fi(dx_computing ,x_y_computing_type,F);
    ox = ox_temp + dx;
    dy_computing = d(1 ,i) * 2^(-(i-1)) * ox_temp;
    dy = fi(dy_computing ,x_y_computing_type,F);
    oy = oy_temp + dy;
    ox = fi(ox ,x_y_computing_type,F);
    oy = fi(oy ,x_y_computing_type,F);
    % hex(ox)
    % hex(oy)
    x(1 ,i+1) = ox;
    y(1 ,i+1) = oy;
end

ox = k * ox;
oy = k * oy;
ox = fi(ox ,x_y_type,F);
oy = fi(oy ,x_y_type,F);
oy = fi(oy ,x_y_type,F);
hex(ox)