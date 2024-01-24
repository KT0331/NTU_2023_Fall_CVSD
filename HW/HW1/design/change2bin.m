clear all
close all
clc

a = 0.044921875;
b = 0.7978515625;
c = 0.5;
a_bin = 0;
b_bin = 0;
c_bin = 0;
a_times = 0;
b_times = 0;
c_times = 0;

fid = fopen('bin_format.txt','wt');

fprintf(fid ,'bin(%d) = 0.' ,a);

while a ~= 0
    a = a * 2;
    a_int = floor(a);
    a = a - a_int;
    a_bin = (a_bin * 10) + a_int;
    a_times = a_times + 1;
    if mod(a_times ,4) == 0
        fprintf(fid ,'%d_' ,a_int);
    else
        fprintf(fid ,'%d' ,a_int);
    end
    a_int = 0;
end

fprintf(fid ,'\nbin(%d) = 0.' ,b);

while b ~= 0
    b = b * 2;
    b_int = floor(b);
    b = b - b_int;
    b_bin = (b_bin * 10) + b_int;
    b_times = b_times + 1;
    if mod(b_times ,4) == 0
        fprintf(fid ,'%d_' ,b_int);
    else
        fprintf(fid ,'%d' ,b_int);
    end
    b_int = 0;
end

fprintf(fid ,'\nbin(%d) = 0.' ,c);

while c ~= 0
    c = c * 2;
    c_int = floor(c);
    c = c - c_int;
    c_bin = (c_bin * 10) + c_int;
    c_times = c_times + 1;
    if mod(c_times ,4) == 0
        fprintf(fid ,'%d_' ,c_int);
    else
        fprintf(fid ,'%d' ,c_int);
    end
    c_int = 0;
end

fclose(fid);