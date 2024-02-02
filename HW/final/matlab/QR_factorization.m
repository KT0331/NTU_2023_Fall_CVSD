clear
close all
clc

% Define fixed point numerictype
Input_type = numerictype(true, 24, 22);
% Q_fixed = numerictype(true, 20, 16);
% R_fixed = numerictype(true, 20, 16);
% Q_computing_fixed = numerictype(true, 25, 22);
% R_computing_fixed = numerictype(true, 25, 22);
Output_type = numerictype(true, 20, 16);

% for test_nummmm = 1:1

% USECORE = 6;
% parfor (test_nummmm = 1:26 ,USECORE)
    % if test_nummmm == 1
    %     packet_no = 2;
    % elseif test_nummmm == 2
    %     packet_no = 6;
    % elseif test_nummmm == 3
    %     packet_no = 15;
    % else
    %     packet_no = 26;
    % end
    packet_no = 1;

    [indata ,fid_R ,fid_y] = ReadData(packet_no);
    
    in_imag = extractBefore(indata,7);
    in_real = extractAfter(indata,6);
    in_imag = hex2dec(in_imag);
    in_real = hex2dec(in_real);
    
    for change = 1 : 20000
        if in_imag(change,1) >= 2^23
            in_imag(change,1) = in_imag(change,1) - 2^24;
        else
            in_imag(change,1) = in_imag(change,1);
        end
        if in_real(change,1) >= 2^23
            in_real(change,1) = in_real(change,1) - 2^24;
        else
            in_real(change,1) = in_real(change,1);
        end
    end
    
    in_imag = in_imag / 2^22;
    in_real = in_real / 2^22;
    
    H_real = zeros(4,4,1000);
    H_imag = zeros(4,4,1000);
    y_real = zeros(4,1,1000);
    y_imag = zeros(4,1,1000);
    read_var = 1;
    while read_var < 1001
        r = (read_var - 1)*20+1;
        H_imag(:,:,read_var) = [in_imag(r:r+3,1).';in_imag(r+5:r+8,1).';in_imag(r+10:r+13,1).';in_imag(r+15:r+18,1).'];
        H_real(:,:,read_var) = [in_real(r:r+3,1).';in_real(r+5:r+8,1).';in_real(r+10:r+13,1).';in_real(r+15:r+18,1).'];
        y_imag(:,:,read_var) = [in_imag(r+4,1);in_imag(r+9,1);in_imag(r+14,1);in_imag(r+19,1)];
        y_real(:,:,read_var) = [in_real(r+4,1);in_real(r+9,1);in_real(r+14,1);in_real(r+19,1)];
        read_var = read_var + 1;
    end
    
    % Define test number
    test_number = 1000;
    
    % delta_R = zeros(test_number ,1);
    % delta_Q = zeros(test_number ,1);
    
    
    
    % err = zeros(1000,1);
    
    for k = 1 : 10
        
        % H_R = (-2) + (2+2) * rand(4 ,4);
        % H_I = (-2) + (2+2) * rand(4 ,4);
        % y_R = (-2) + (2+2) * rand(4 ,4);
        % y_I = (-2) + (2+2) * rand(4 ,4);
        H_R = H_real(:,:,k);
        H_I = H_imag(:,:,k);
        y_R = y_real(:,:,k);
        y_I = y_imag(:,:,k);
        H_R_fix = fi(H_R ,Input_type);
        H_I_fix = fi(H_I ,Input_type);
        y_R_fix = fi(y_R ,Input_type);
        y_I_fix = fi(y_I ,Input_type);
    
        H_fix = H_R_fix + (H_I_fix*1i);
        H_fix = fi(H_fix ,Input_type);
        y_fix = y_R_fix + (y_I_fix*1i);
        y_fix = fi(y_fix ,Input_type);
    
        % Verify answer
        % [Q ,R] = qr(double(H_fix))
        % R_m_fix = fi(R ,Output_type);
        % y_m_fix = Q' * y_fix;
        % y_m_fix = fi(y_m_fix ,Output_type);
    
        % [Q_d ,R_d] = QR_desire_func(double(H_fix))
        
        % QR decomposition by cordic
        % [Q_c ,R_c] = QR_cordic_func(double(H_fix));
        % R_m_fix = fi(R_c ,Output_type);
        % y_m_fix = Q_c * y_fix;
        % y_m_fix = fi(y_m_fix ,Output_type);
    
        % QR decomposition by fixed-point cordic
        [Y_c_fixed ,R_c_fixed] = QR_fixed_cordic_func(H_fix ,y_fix);
        R_m_fix = fi(R_c_fixed ,Output_type);
        % Q_m_fix = fi(Q_c_fixed ,1 ,14,12);
        % y_fix   = fi(y_fix ,1 ,16 ,12);
        % y_m_fix = Q_c_fixed * y_fix;
        % y_m_fix = fi(y_m_fix ,Output_type);
        y_m_fix = fi(Y_c_fixed ,Output_type);
    
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(4,4))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(3,4))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(3,4))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(2,4))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(2,4))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(1,4))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(1,4))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(3,3))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(2,3))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(2,3))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(1,3))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(1,3))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(2,2))));
            fprintf(fid_R ,'%s' ,hex(imag(R_m_fix(1,2))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(1,2))));
            fprintf(fid_R ,'%s' ,hex(real(R_m_fix(1,1))));
            fprintf(fid_R ,'\n');
            fprintf(fid_y ,'%s' ,hex(imag(y_m_fix(4,1))));
            fprintf(fid_y ,'%s' ,hex(real(y_m_fix(4,1))));
            fprintf(fid_y ,'%s' ,hex(imag(y_m_fix(3,1))));
            fprintf(fid_y ,'%s' ,hex(real(y_m_fix(3,1))));
            fprintf(fid_y ,'%s' ,hex(imag(y_m_fix(2,1))));
            fprintf(fid_y ,'%s' ,hex(real(y_m_fix(2,1))));
            fprintf(fid_y ,'%s' ,hex(imag(y_m_fix(1,1))));
            fprintf(fid_y ,'%s' ,hex(real(y_m_fix(1,1))));
            fprintf(fid_y ,'\n');
    
    end
    
    
    fclose(fid_R);
    fclose(fid_y);

% end
