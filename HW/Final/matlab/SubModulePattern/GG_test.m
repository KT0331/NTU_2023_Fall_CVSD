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

ix = fi(0.6324,x_y_type);
iy = fi(0.0975,x_y_type);
d_his = zeros([9,5]);

[ox ,oy ,d] = fixed_vectoring_mode(k ,ix ,iy);
ox = fi(ox ,x_y_type);
d_his(:,1) = d;

[ox ,oy ,d] = fixed_vectoring_mode(k ,ix ,iy);
ox = fi(ox ,x_y_type);
d_his(:,2) = d;

[ox ,oy ,d] = fixed_vectoring_mode(k ,ix ,iy);
ox = fi(ox ,x_y_type);
d_his(:,3) = d;

[ox_out ,oy ,d] = fixed_vectoring_mode(k ,ox ,ox);
ox = fi(ox ,x_y_type);
d_his(:,4) = d;

[ox ,oy ,d] = fixed_vectoring_mode(k ,ox_out ,ox);
ox = fi(ox ,x_y_type);
d_his(:,5) = d;
hex(ox)