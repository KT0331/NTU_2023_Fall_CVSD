function [ox ,oy ,d] = fixed_vectoring_mode(k ,ix ,iy,iter_num)
%d(i)   = -sign(x(i) * y(i))
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

%History of d ,x ,y
d = zeros(1 ,iter_num);
x = zeros(1 ,iter_num+1);
x(1 ,1) = ox;
y = zeros(1 ,iter_num+1);
y(1 ,1) = oy;

for i = 1 : iter_num
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
    dx = fi(dx_computing ,x_y_computing_type ,F);
    ox = ox_temp + dx;
    dy_computing = d(1 ,i) * 2^(-(i-1)) * ox_temp;
    dy = fi(dy_computing ,x_y_computing_type ,F);
    oy = oy_temp + dy;
    ox = fi(ox ,x_y_computing_type ,F);
    oy = fi(oy ,x_y_computing_type ,F);
    x(1 ,i+1) = ox;
    y(1 ,i+1) = oy;
end

ox = k * ox;
oy = k * oy;
ox = fi(ox ,x_y_type,F);
oy = fi(oy ,x_y_type,F);
oy = fi(oy ,x_y_type,F);