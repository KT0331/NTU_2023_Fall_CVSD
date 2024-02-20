clear; clc; close;

alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
         2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
K = 1;
for km = 1 : 9
    K = K * cosd(alpha(1,km));
end
K_fix = fi(K, 1, 7 ,6);
k = K_fix;

%d(i)   = -sign(x(i) * y(i))
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

x_y_type   = numerictype(true, 20, 16);

ix = fi(0.2785,x_y_type);
iy = fi(0.5468,x_y_type);
d_1 = [-1  1  1 -1 1 -1  1  1 -1];
d_2 = [-1 -1  1  1 1  1  1 -1 -1];
d_3 = [-1  1 -1 -1 1  1 -1 -1  1];

[ox ,oy] = fixed_rotation_mode(k ,ix ,iy ,d_1);
ox = fi(ox ,x_y_type);

[ox ,oy] = fixed_rotation_mode(k ,ix ,iy ,d_1);
ox = fi(ox ,x_y_type);

[ox ,oy] = fixed_rotation_mode(k ,ix ,iy ,d_1);
ox = fi(ox ,x_y_type);

[ox_out_0 ,ox_out_1] = fixed_rotation_mode(k ,ox ,ox ,d_2);
ox = fi(ox ,x_y_type);

[ox_out_0 ,ox_out_2] = fixed_rotation_mode(k ,ox_out_0 ,ox ,d_3);
ox = fi(ox ,x_y_type);

[oy_out_0 ,oy_out_1] = fixed_rotation_mode(k ,oy ,oy ,d_2);
ox = fi(ox ,x_y_type);

[oy_out_0 ,oy_out_2] = fixed_rotation_mode(k ,oy_out_0 ,oy ,d_3);
ox = fi(ox ,x_y_type);
hex(ox_out_0)
hex(ox_out_1)
hex(ox_out_2)
hex(oy_out_0)
hex(oy_out_1)
hex(oy_out_2)