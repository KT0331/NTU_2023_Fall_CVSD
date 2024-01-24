function [Q ,R] = QR_cordic_func(M)

    % tan(alpha) table
    alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
             2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
    K = 1;
    for km = 1 : 12
        K = K * cosd(alpha(1,km));
    end

    M_real = real(M);
    M_imag = imag(M);

    I_real = eye(4);
    I_imag = zeros(4);

    e_im2re = 1; %end row, sub by 1 at each round beginning
    e_re = 2; %end row, sub by 1 at each round beginning

    for j = 1:4
        for i = 4:-1:e_im2re
            rotation_param = [M_real(i,j) M_imag(i,j)];
            [M_real(i,j) ,M_imag(i,j) ,d] = vectoring_mode(K ,rotation_param(1) ,rotation_param(2));
            if j < 4
                for j_1 = j+1 : 4
                    [M_real(i, j_1) ,M_imag(i, j_1)] = rotation_mode(K ,M_real(i, j_1) ,M_imag(i, j_1) ,d);
                end
            end
            for jj = 1 : 4
                [I_real(i, jj) ,I_imag(i, jj)] = rotation_mode(K ,I_real(i, jj) ,I_imag(i, jj) ,d);
            end
        end

        RQ = [M_real I_real];
        RQ_im = [M_imag I_imag];
        for i = 4:-1:e_re
            rotation_param = RQ(i-1:i, j);
            [RQ(i-1, j) ,RQ(i, j) ,d] = vectoring_mode(K ,rotation_param(1) ,rotation_param(2));
            for j_1 = j+1 : 8
                [RQ(i-1, j_1) ,RQ(i, j_1)] = rotation_mode(K ,RQ(i-1, j_1) ,RQ(i, j_1) ,d);
            end
            for j_1 = j+1 : 8
                [RQ_im(i-1, j_1) ,RQ_im(i, j_1)] = rotation_mode(K ,RQ_im(i-1, j_1) ,RQ_im(i, j_1) ,d);
            end
        end

        M_real = RQ(:,1:4);
        I_real = RQ(:,5:8);
        M_imag = RQ_im(:,1:4);
        I_imag = RQ_im(:,5:8);

        
        e_im2re = e_im2re + 1;
        e_re = e_re + 1;
    end
    
    e=1;
    for j = 1:4
        for i = 4:-1:e
            M_imag(i,j) = 0;
        end
        e=e+1;
    end

    R = M_real + M_imag*1i;
    Q = I_real + I_imag*1i;


end