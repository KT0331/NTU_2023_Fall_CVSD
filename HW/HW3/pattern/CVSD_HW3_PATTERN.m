%CVSD_HW3
clear
close
clc

patnum = 1;
%ifmap[y,x,z]

fid_ifmap  = fopen('ifmap01.txt','wt');
fid_indata = fopen('indata01.dat','wt');
fid_opmode = fopen('opmode01.dat','wt');
fid_golden = fopen('golden01.dat','wt');
fprintf(fid_opmode ,'%d\n' ,patnum);

for pat_w = 1 : patnum
    ifmap = randi([0,255],8,8,32);
    % ifmap = zeros([8,8,32]);
    % if pat_w == 2
    %     ifmap(:,:) = 255;
    % elseif pat_w == 3
    %     for k = 1 : 32
    %         for j = 1 : 8
    %             for i = 1 : 8
    %                 if mod(i+j+k,2) ~= 0
    %                     ifmap(i,j,k) = 255;
    %                 end
    %             end
    %         end
    %     end
    % end

    fprintf(fid_ifmap ,'PATTERN:%3d\n' ,pat_w-1);
    for x_z = 1 : 32
        fprintf(fid_ifmap ,'\n\tChannel:%2d\n\n' ,x_z);
        for y_x = 0 : 63
            w_y = 1+floor(y_x/8);
            w_x = 1+mod(y_x,8);
            if w_x == 1
                fprintf(fid_ifmap ,'\t\t');
            end
            fprintf(fid_ifmap ,'%3d\t' ,ifmap(w_y,w_x,x_z));
            fprintf(fid_indata ,'%d\n' ,ifmap(w_y,w_x,x_z));
            if w_x == 8
                fprintf(fid_ifmap ,'\n');
            end
        end
    end

    % % include conv, median, and sobel_nms
    % oper_mode_m = zeros(144,1);
    % for oper_mode_m_num = 1:144
    %     if mod(oper_mode_m_num,3) == 1
    %         oper_mode_m(oper_mode_m_num,1) = 8;
    %     elseif mod(oper_mode_m_num,3) == 2
    %         oper_mode_m(oper_mode_m_num,1) = 9;
    %     else
    %         oper_mode_m(oper_mode_m_num,1) = 10;
    %     end
    % end
    
    % including display region shift
    % shift_mode_m = zeros(48,1);
    % for shift_mode_m_index = 1 : 48
    %     if mod(shift_mode_m_index ,14) == 0
    %         shift_mode_m(shift_mode_m_index,1) = 4;
    %     elseif mod(shift_mode_m_index ,14) <= 6
    %         shift_mode_m(shift_mode_m_index,1) = 1;
    %     elseif mod(shift_mode_m_index ,14) == 7
    %         shift_mode_m(shift_mode_m_index,1) = 4;
    %     else
    %         shift_mode_m(shift_mode_m_index,1) = 2;
    %     end
    % end

    shift_mode_m = zeros(52,1);
    for shift_mode_m_index = 1 : 26
        if shift_mode_m_index <= 7
            shift_mode_m(2*shift_mode_m_index - 1,1) = 3;
            shift_mode_m(2*shift_mode_m_index,1) = 1;
        elseif shift_mode_m_index <= 13
            shift_mode_m(2*shift_mode_m_index - 1,1) = 4;
            shift_mode_m(2*shift_mode_m_index,1) = 1;
        elseif shift_mode_m_index <= 20
            shift_mode_m(2*shift_mode_m_index - 1,1) = 4;
            shift_mode_m(2*shift_mode_m_index,1) = 2;
        else
            shift_mode_m(2*shift_mode_m_index - 1,1) = 3;
            shift_mode_m(2*shift_mode_m_index,1) = 2;
        end
    end
    
    % shift_oper_m = zeros(192,1);
    % for comb_shift_oper = 1 : 48
    %     shift_oper_m(4*(comb_shift_oper-1)+1:4*(comb_shift_oper-1)+4,1) ...
    %         = [oper_mode_m(3*(comb_shift_oper-1)+1,1);
    %            oper_mode_m(3*(comb_shift_oper-1)+2,1);
    %            oper_mode_m(3*(comb_shift_oper-1)+3,1);
    %            shift_mode_m(comb_shift_oper,1)];
    % end

    i = 1;
    shift_oper_m = zeros(105,1);
    for comb_shift_oper = 1 : 105
        if mod(comb_shift_oper ,2) == 1
            shift_oper_m(comb_shift_oper,1) = 7;
        else
            shift_oper_m(comb_shift_oper,1) = shift_mode_m(i,1);
            i = i + 1;
        end
    end

    shift_oper_m(106:109,1) = [1 4 1 4]';
    
    opmode_matrix = [shift_oper_m;
                     6;6;7;
                     5;5;5;
                     5;7;6;
                     1;4;6;
                     7];

    % insert_scale = sort(randi([3,188],6,1));
    % 
    % opmode_matrix = [shift_oper_m(1:insert_scale(1,1),1);
    %                  6;7;
    %                  shift_oper_m(insert_scale(1,1)+1:insert_scale(2,1),1);
    %                  5;
    %                  shift_oper_m(insert_scale(2,1)+1:insert_scale(3,1),1);
    %                  5;
    %                  shift_oper_m(insert_scale(3,1)+1:insert_scale(4,1),1);
    %                  5;
    %                  7;
    %                  shift_oper_m(insert_scale(4,1)+1:insert_scale(5,1),1);
    %                  6;
    %                  shift_oper_m(insert_scale(5,1)+1:insert_scale(6,1),1);
    %                  6;
    %                  shift_oper_m(insert_scale(6,1)+1:192,1);
    %                  7];
    
    
    
    
    
    
    
    out_index = 1;
    disp_posi_x = 1;
    disp_posi_y = 1;
    depth = 32;
    % for i = 1 : 201
    for i = 1 : 122
        if (opmode_matrix(i,1) == 1) && (disp_posi_x ~= 7)
           disp_posi_x = disp_posi_x + 1;
        elseif (opmode_matrix(i,1) == 2) && (disp_posi_x ~= 1)
            disp_posi_x = disp_posi_x - 1;
        elseif (opmode_matrix(i,1) == 3) && (disp_posi_y ~= 1)
           disp_posi_y = disp_posi_y - 1;
        elseif (opmode_matrix(i,1) == 4) && (disp_posi_y ~= 7)
            disp_posi_y = disp_posi_y + 1;
        elseif (opmode_matrix(i,1) ==  5) && (depth ~= 8)
            depth = depth/2;
        elseif (opmode_matrix(i,1) ==  6) && (depth ~= 32)
            depth = depth*2;
        elseif opmode_matrix(i,1) ==  7
            for oo = 1 : depth
                out_data(out_index,1) = ifmap(disp_posi_y   ,disp_posi_x,oo);
                out_index = out_index + 1;
                out_data(out_index,1) = ifmap(disp_posi_y   ,disp_posi_x+1,oo);
                out_index = out_index + 1;
                out_data(out_index,1) = ifmap(disp_posi_y+1 ,disp_posi_x,oo);
                out_index = out_index + 1;
                out_data(out_index,1) = ifmap(disp_posi_y+1 ,disp_posi_x+1,oo);
                out_index = out_index + 1;
            end
        elseif opmode_matrix(i,1) ==  8
                out_data(out_index,1) = conv(ifmap ,disp_posi_y   ,disp_posi_x   ,depth);
                out_index = out_index + 1;
                out_data(out_index,1) = conv(ifmap ,disp_posi_y   ,disp_posi_x+1 ,depth);
                out_index = out_index + 1;
                out_data(out_index,1) = conv(ifmap ,disp_posi_y+1 ,disp_posi_x   ,depth);
                out_index = out_index + 1;
                out_data(out_index,1) = conv(ifmap ,disp_posi_y+1 ,disp_posi_x+1 ,depth);
                out_index = out_index + 1;
        elseif opmode_matrix(i,1) ==  9
            for mm = 1 : 4
                out_data(out_index,1) = median(ifmap ,disp_posi_y   ,disp_posi_x   ,mm);
                out_index = out_index + 1;
                out_data(out_index,1) = median(ifmap ,disp_posi_y   ,disp_posi_x+1 ,mm);
                out_index = out_index + 1;
                out_data(out_index,1) = median(ifmap ,disp_posi_y+1 ,disp_posi_x   ,mm);
                out_index = out_index + 1;
                out_data(out_index,1) = median(ifmap ,disp_posi_y+1 ,disp_posi_x+1 ,mm);
                out_index = out_index + 1;
            end
        elseif opmode_matrix(i,1) ==  10
            for nn = 1 : 4
                [out_ul ,out_ur ,out_ll ,out_lr] = nms(ifmap ,disp_posi_y ,disp_posi_x ,nn);
                out_data(out_index,1) = out_ul;
                out_index = out_index + 1;
                out_data(out_index,1) = out_ur;
                out_index = out_index + 1;
                out_data(out_index,1) = out_ll;
                out_index = out_index + 1;
                out_data(out_index,1) = out_lr;
                out_index = out_index + 1;
            end
        end
            
    end
    
    
    
    % fprintf(fid_opmode ,'%d\n' ,201);
    fprintf(fid_opmode ,'%d\n' ,122);
    fprintf(fid_opmode ,'%d\n' ,out_index-1);
    fprintf(fid_opmode ,'0\n');
    % for i = 1 : 201
    for i = 1 : 122
        fprintf(fid_opmode ,'%d\n' ,opmode_matrix(i,1));
    end
    for j = 1 : out_index-1
        fprintf(fid_golden ,'%d\n' ,out_data(j,1));
    end
    
end

fclose(fid_ifmap);
fclose(fid_indata);
fclose(fid_opmode);
fclose(fid_golden);

% make sure dimension
% x=infmap(1,5,1);
% y=infmap(3,1,1);
% z=infmap(1,1,2);