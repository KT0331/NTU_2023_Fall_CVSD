clear all
clc
format long g

qd = quantizer('float','convergent',[32,8]);
qi = quantizer('fixed','nearest',[4,0]);

PAT_NUM = 40000;

i_data_a_temp = zeros([PAT_NUM 1]);
i_data_b_temp = zeros([PAT_NUM 1]);
o_data_temp = zeros([PAT_NUM 1]);
i_inst_temp = zeros([PAT_NUM 1]);

for i=1:PAT_NUM
    i_data_a_temp(i) = single(randi([1 2^53-1]) * rand());
    i_data_b_temp(i) = single(randi([1 2^53-1]) * rand());
    
%生成i_data_a     
    looptime = randi([1 15]);
    for j=1:looptime
        sign = randi([1 2]) - 1;
        if sign==1
            i_data_a_temp(i) = i_data_a_temp(i) * rand() * (-1);
        else
            i_data_a_temp(i) = i_data_a_temp(i) * rand();
        end
    end
 
%生成i_data_b
    looptime = randi([1 15]);
    for k=1:looptime
        sign = randi([1 2]) - 1;
        if sign==1
            i_data_b_temp(i) = i_data_b_temp(i) * rand() * (-1);
        else
            i_data_b_temp(i) = i_data_b_temp(i) * rand();
        end
    end
    
    o_data_temp(i) = single(i_data_a_temp(i)) * single(i_data_b_temp(i));
    o_data_temp(i) = single(o_data_temp(i));
end

i_data_a = num2bin(qd,i_data_a_temp,PAT_NUM);
i_data_b = num2bin(qd,i_data_b_temp,PAT_NUM);
o_data = num2bin(qd,o_data_temp,PAT_NUM);

for i=1:PAT_NUM
    INST8p_I(i,[1:64])=strcat(i_data_a(i,[1:32]), i_data_b(i,[1:32]));
    INST8p_O=o_data;
end

for i=1:PAT_NUM
    fp1_e = bin2dec(i_data_a(i,[2:9]));
    fp2_e = bin2dec(i_data_b(i,[2:9]));
    fpo_e = bin2dec(o_data(i,[2:9]));
    if ((fpo_e == 0) | (fpo_e > 254))
        INST8p_I(i,[1:64]) = char('0000000000000000000000000000000000000000000000000000000000000000');
        INST8p_O(i,[1:32]) = char('00000000000000000000000000000000');
    end
end

filename = 'fp_mult.xlsx';
writematrix(INST8p_I,filename,'Sheet',1,'Range','A1:A40000')
writematrix(INST8p_O,filename,'Sheet',1,'Range','B1:B40000')

char('ok')
