function [ox ,oy] = fixed_rotation_mode(k ,ix ,iy ,d,iter_num)
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

% x_y_computing_type = numerictype(true, 20, 16);
% x_y_type   = numerictype(true, 21, 16);

% x_y_computing_type = numerictype(true, 19, 14);
% x_y_type   = numerictype(true, 18, 14);

% x_y_computing_type = numerictype(true, 17, 12);
% x_y_type   = numerictype(true, 16, 12);

x_y_computing_type = numerictype(true, 15, 10);
x_y_type   = numerictype(true, 14, 10);

%Initialize
F = fimath('RoundingMethod','Floor');
ox = fi(ix ,x_y_computing_type ,F);
oy = fi(iy ,x_y_computing_type ,F);

for i = 1 : iter_num
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
end

ox = ox * k;
oy = oy * k;
ox = fi(ox ,x_y_type,F);
oy = fi(oy ,x_y_type,F);