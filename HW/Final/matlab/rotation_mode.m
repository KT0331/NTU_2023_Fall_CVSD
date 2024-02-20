function [ox ,oy] = rotation_mode(k ,ix ,iy ,d)
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

%Initialize
ox = ix;
oy = iy;

for i = 1 : 12
    ox_temp = ox;
    oy_temp = oy;
    ox = ox_temp - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    oy = oy_temp + d(1 ,i) * 2^(-(i-1)) * ox_temp;
end

ox = ox * k;
oy = oy * k;