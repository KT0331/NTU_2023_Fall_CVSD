function [ox ,oy ,d] = vectoring_mode(k ,ix ,iy)
%d(i)   = -sign(x(i) * y(i))
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

%Initialize
ox = ix;
oy = iy;

%History of d ,x ,y
d = zeros(1 ,12);
x = zeros(1 ,13);
x(1 ,1) = ox;
y = zeros(1 ,13);
y(1 ,1) = oy;

for i = 1 : 12
    %Decide rotation direction : -1 means clockwise and +1 means counterclockwise
    if ox * oy > 0
        d(1 ,i) = -1;
    elseif ox * oy < 0
        d(1 ,i) = +1;
    elseif or((ox > 0) ,(oy > 0))
        d(1 ,i) = -1;
    else
        d(1 ,i) = +1;
    end
    ox_temp = ox;
    oy_temp = oy;
    ox = ox_temp - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    oy = oy_temp + d(1 ,i) * 2^(-(i-1)) * ox_temp;
    x(1 ,i+1) = ox;
    y(1 ,i+1) = oy;
end

ox = k * ox;
oy = k * oy;