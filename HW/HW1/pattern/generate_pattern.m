% For I0~I3
clear
close all
clc

Pattern_number = 100000;
inst_his = randi([0,3],Pattern_number,1);
Z_doub = zeros(Pattern_number,1);
A_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');
B_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');
Ans_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');
j = 0;

for i = 1:Pattern_number
    inst = inst_his(i,1);
    a = 64*rand(1)-32;
    b = 64*rand(1)-32;
    A = fi(a,1,16,10,'RoundingMethod','Nearest');
    B = fi(b,1,16,10,'RoundingMethod','Nearest');
    A_his(i,1) = A;
    B_his(i,1) = B;
    A_his = fi(A_his,1,16,10,'RoundingMethod','Nearest');
    B_his = fi(B_his,1,16,10,'RoundingMethod','Nearest');
    if inst == 0
        opera_ans = fi(A+B,1,16,10,'RoundingMethod','Nearest');
    elseif inst == 1
        opera_ans = fi(A-B,1,16,10,'RoundingMethod','Nearest');
    elseif inst == 2
        opera_ans = fi(A*B,1,16,10,'RoundingMethod','Nearest');
    else
        if j == 0
            opera_ans = fi(A*B,1,16,10,'RoundingMethod','Nearest');
        else
            opera_ans = fi(A*B+Ans_his(j,1),1,16,10,'RoundingMethod','Nearest');
        end
    end
    Ans_his(i,1) = opera_ans;
    Ans_his = fi(Ans_his,1,16,10,'RoundingMethod','Nearest');
    j = j + 1;
end

%Write pattern file
fid = fopen('INST_10W_MIX_I.dat','wt');
for w = 1:Pattern_number
    inst_print = dec2bin(inst_his(w,1));
    fprintf(fid ,'%04s' ,inst_print);
    fprintf(fid ,'%s' ,bin(A_his(w,1)));
    fprintf(fid ,'%s' ,bin(B_his(w,1)));
    fprintf(fid ,'\n');
end
fclose(fid);
fid = fopen('INST_10W_MIX_O.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'%s' ,bin(Ans_his(w,1)));
    fprintf(fid ,'\n');
end
fclose(fid);

%% GELU test
clear
close all
clc

Pattern_number = 100000;
a = 0.044921875;
b = 0.7978515625;
Z_doub = zeros(Pattern_number,1);
X_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');
gelu_out_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');

for i = 1:Pattern_number
    x = 64*rand(1)-32;
    X_fix = fi(x,1,16,10);
    X_his(i,1) = X_fix;
    tanh_in = b*X_fix*(1+a*X_fix*X_fix);
    tanh_in_fix = fi(tanh_in,1,16,10,'RoundingMethod','Nearest');

    if tanh_in_fix >= 1.5
        tanh_out = 1;
    elseif tanh_in_fix <= -1.5
        tanh_out = -1;
    elseif (tanh_in_fix < 1.5) && (tanh_in_fix >= 0.5)
        tanh_out = 0.5*(tanh_in_fix - 0.5) + 0.5;
    elseif (tanh_in_fix > -1.5) && (tanh_in_fix <= -0.5)
        tanh_out = 0.5*(tanh_in_fix + 0.5) - 0.5;
    else
        tanh_out = tanh_in_fix;
    end

    tanh_out_fix = fi(tanh_out,1,16,10,'RoundingMethod','Nearest');
    gelu_out = 0.5*X_fix*(1+tanh_out_fix);
    gelu_out_fix=fi(gelu_out,1,16,10,'RoundingMethod','Nearest');
    gelu_out_his(i,1) = gelu_out_fix;
end

fid = fopen('INST10W_gelu_I.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'0100');
    fprintf(fid ,'%s' ,bin(X_his(w,1)));
    fprintf(fid ,'0000000000000000');
    fprintf(fid ,'\n');
end
fclose(fid);
fid = fopen('INST10W_gelu_O.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'%s' ,bin(gelu_out_his(w,1)));
    fprintf(fid ,'\n');
end
fclose(fid);

%% Count leading 0
clear
clc

Pattern_number = 100000;
Z_doub = zeros(Pattern_number,1);
A_his = fi(Z_doub,1,16,10,'RoundingMethod','Nearest');
CLZ_out_his = zeros(Pattern_number,1);
AA_test = zeros(17,1);

for i = 1:Pattern_number
    a = 64*rand(1)-32;
    A = fi(a,1,16,10);
    A_his(i,1) = A;
    if bitget(A,16) == 1
        CLZ_out = 0;
    elseif bitget(A,15) == 1
        CLZ_out = 1;
    elseif bitget(A,14) == 1
        CLZ_out = 2;
    elseif bitget(A,13) == 1
        CLZ_out = 3;
    elseif bitget(A,12) == 1
        CLZ_out = 4;
    elseif bitget(A,11) == 1
        CLZ_out = 5;
    elseif bitget(A,10) == 1
        CLZ_out = 6;
    elseif bitget(A,9) == 1
        CLZ_out = 7;
    elseif bitget(A,8) == 1
        CLZ_out = 8;
    elseif bitget(A,7) == 1
        CLZ_out = 9;
    elseif bitget(A,6) == 1
        CLZ_out = 10;
    elseif bitget(A,5) == 1
        CLZ_out = 11;
    elseif bitget(A,4) == 1
        CLZ_out = 12;
    elseif bitget(A,3) == 1
        CLZ_out = 13;
    elseif bitget(A,2) == 1
        CLZ_out = 14;
    elseif bitget(A,1) == 1
        CLZ_out = 15;
    else
        CLZ_out = 16;
    end
    CLZ_out_his(i,1) = CLZ_out;
    AA_test(CLZ_out+1,1) = 1;
end

fid = fopen('INST10W_clz_I.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'0101');
    fprintf(fid ,'%s' ,bin(A_his(w,1)));
    fprintf(fid ,'0000000000000000');
    fprintf(fid ,'\n');
end
fclose(fid);
fid = fopen('INST10W_clz_O.dat','wt');
for w = 1:Pattern_number
    CLZ_OUT = dec2bin(CLZ_out_his(w,1));
    fprintf(fid ,'%016s' ,CLZ_OUT);
    fprintf(fid ,'\n');
end
fclose(fid);

%% For LRCW
clear
clc

Pattern_number = 1;
Z_doub = zeros(Pattern_number,1);
A_his = fi(Z_doub,0,16,0,'RoundingMethod','Nearest');
B_his = fi(Z_doub,0,16,0,'RoundingMethod','Nearest');
LRCW_out = fi(zeros(1,16),1,16,10,'RoundingMethod','Nearest');
LRCW_out_his = zeros(Pattern_number,16);
AA_test = zeros(17,1);

for i = 1:Pattern_number
    % a = randi([0,65535]);
    a = 65535;
    A = fi(a,0,16,0);
    A_his(i,1) = A;
    b = randi([0,65535]);
    % b = 3538;
    B = fi(b,0,16,0);
    B_his(i,1) = B;
    A_sperate = [bitget(A,16:-1:1)];
    B_sperate = [bitget(B,1:1:16)];
    count_1 = sum(A_sperate(1, : ));
    B_inv = ~B_sperate;
    if count_1 == 0
        LRCW_out = B_sperate;
    elseif  count_1 == 1
        LRCW_out(1, 16:-1:2) = B_sperate(1 ,15:-1:1);
        LRCW_out(1, 1:-1:1) = B_inv(1, 16:-1:16);
    elseif  count_1 == 2
        LRCW_out(1, 16:-1:3) = B_sperate(1 ,14:-1:1);
        LRCW_out(1, 2:-1:1) = B_inv(1, 16:-1:15);
    elseif  count_1 == 3
        LRCW_out(1, 16:-1:4) = B_sperate(1 ,13:-1:1);
        LRCW_out(1, 3:-1:1) = B_inv(1, 16:-1:14);
    elseif  count_1 == 4
        LRCW_out(1, 16:-1:5) = B_sperate(1 ,12:-1:1);
        LRCW_out(1, 4:-1:1) = B_inv(1, 16:-1:13);
    elseif  count_1 == 5
        LRCW_out(1, 16:-1:6) = B_sperate(1 ,11:-1:1);
        LRCW_out(1, 5:-1:1) = B_inv(1, 16:-1:12);
    elseif  count_1 == 6
        LRCW_out(1, 16:-1:7) = B_sperate(1 ,10:-1:1);
        LRCW_out(1, 6:-1:1) = B_inv(1, 16:-1:11);
    elseif  count_1 == 7
        LRCW_out(1, 16:-1:8) = B_sperate(1 ,9:-1:1);
        LRCW_out(1, 7:-1:1) = B_inv(1, 16:-1:10);
    elseif  count_1 == 8
        LRCW_out(1, 16:-1:9) = B_sperate(1 ,8:-1:1);
        LRCW_out(1, 8:-1:1) = B_inv(1, 16:-1:9);
    elseif  count_1 == 9
        LRCW_out(1, 16:-1:10) = B_sperate(1 ,7:-1:1);
        LRCW_out(1, 9:-1:1) = B_inv(1, 16:-1:8);
    elseif  count_1 == 10
        LRCW_out(1, 16:-1:11) = B_sperate(1 ,6:-1:1);
        LRCW_out(1, 10:-1:1) = B_inv(1, 16:-1:7);
    elseif  count_1 == 11
        LRCW_out(1, 16:-1:12) = B_sperate(1 ,5:-1:1);
        LRCW_out(1, 11:-1:1) = B_inv(1, 16:-1:6);
    elseif  count_1 == 12
        LRCW_out(1, 16:-1:13) = B_sperate(1 ,4:-1:1);
        LRCW_out(1, 12:-1:1) = B_inv(1, 16:-1:5);
    elseif  count_1 == 13
        LRCW_out(1, 16:-1:14) = B_sperate(1 ,3:-1:1);
        LRCW_out(1, 13:-1:1) = B_inv(1, 16:-1:4);
    elseif  count_1 == 14
        LRCW_out(1, 16:-1:15) = B_sperate(1 ,2:-1:1);
        LRCW_out(1, 14:-1:1) = B_inv(1, 16:-1:3);
    elseif  count_1 == 15
        LRCW_out(1, 16:-1:16) = B_sperate(1 ,1:-1:1);
        LRCW_out(1, 15:-1:1) = B_inv(1, 16:-1:2);
    else
        LRCW_out = B_inv;
    end
    LRCW_out_his(i,:) = LRCW_out;
    AA_test(count_1+1,1) = 1;
end

fid = fopen('INST10W_lrcw_I.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'0110');
    fprintf(fid ,'%s' ,bin(A_his(w,1)));
    fprintf(fid ,'%s' ,bin(B_his(w,1)));
    fprintf(fid ,'\n');
end
fclose(fid);
fid = fopen('INST10W_lrcw_O.dat','wt');
for w = 1:Pattern_number
    for i = 16:-1:1
        fprintf(fid ,'%d' ,LRCW_out_his(w,i));
    end
    fprintf(fid ,'\n');
end
fclose(fid);

%% For LFSR
clear
clc

Pattern_number = 10000;
Z_doub = zeros(Pattern_number,1);
A_his = fi(Z_doub,0,16,0);
B_his = Z_doub;
AA_test = zeros(9,1);
lfsr_his = zeros(Pattern_number,16);

for i = 1:Pattern_number
    a = randi([0,65535]);
    % a = 41442;
    A = fi(a,0,16,0);
    A_his(i,1) = A;
    b = randi([0,8]);
    % b = 1;
    B_his(i,1) = b;
    AA_test(b+1,1) = 1;
    A_sperate = bitget(A,16:-1:1);
    while b ~= 0
        feed_b = xor(xor(A_sperate(1,1) ,A_sperate(1,3)) ,xor(A_sperate(1,4) ,A_sperate(1,6)));
        A_sperate = [A_sperate(1,2:1:16) feed_b];
        b = b - 1;
    end
    lfsr_his(i,1:1:16) = A_sperate;
end

fid = fopen('INST1W_lfsr_I.dat','wt');
for w = 1:Pattern_number
    fprintf(fid ,'0111');
    fprintf(fid ,'%s' ,bin(A_his(w,1)));
    fprintf(fid ,'%016s' ,dec2bin(B_his(w,1)));
    fprintf(fid ,'\n');
end
fclose(fid);
fid = fopen('INST1W_lfsr_O.dat','wt');
for w = 1:Pattern_number
    for i = 1:1:16
        fprintf(fid ,'%d' ,lfsr_his(w,i));
    end
    fprintf(fid ,'\n');
end
fclose(fid);