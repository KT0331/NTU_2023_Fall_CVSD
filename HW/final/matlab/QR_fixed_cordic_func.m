function [Y_HAT ,R] = QR_fixed_cordic_func(M ,Y)
    
    iter_num = 9;

    % tan(alpha) table
    alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
             2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
    K = 1;
    for km = 1 : iter_num
        K = K * cosd(alpha(1,km));
    end
    K_fix = fi(K, 1, 7 ,6);
    
    F = fimath('RoundingMethod','Floor');

    % M_real = fi(real(M) ,1 ,20 ,16 ,F);
    % M_imag = fi(imag(M) ,1 ,20 ,16 ,F);

    % M_real = fi(real(M) ,1 ,18 ,14 ,F);
    % M_imag = fi(imag(M) ,1 ,18 ,14 ,F);

    % M_real = fi(real(M) ,1 ,16 ,12 ,F);
    % M_imag = fi(imag(M) ,1 ,16 ,12 ,F);

    M_real = fi(real(M) ,1 ,14 ,10 ,F);
    M_imag = fi(imag(M) ,1 ,14 ,10 ,F);

    % I_real = fi(  eye(4) ,1 ,14 ,12);
    % I_imag = fi(zeros(4) ,1 ,14 ,12);

    % Y_real = fi(real(Y) ,1 ,18 ,14 ,F);
    % Y_imag = fi(imag(Y) ,1 ,18 ,14 ,F);

    % Y_real = fi(real(Y) ,1 ,16 ,12 ,F);
    % Y_imag = fi(imag(Y) ,1 ,16 ,12 ,F);

    Y_real = fi(real(Y) ,1 ,14 ,10 ,F);
    Y_imag = fi(imag(Y) ,1 ,14 ,10 ,F);

    e_im2re = 1; %end row, sub by 1 at each round beginning
    e_re = 2; %end row, sub by 1 at each round beginning

    for j = 1:4
        for i = e_im2re:4
            rotation_param = [M_real(i,j) M_imag(i,j)];
            [M_real(i,j) ,M_imag(i,j) ,d] = fixed_vectoring_mode(K_fix ,rotation_param(1) ,rotation_param(2),iter_num);
            if j < 4
                for j_1 = j+1 : 4
                    [M_real(i, j_1) ,M_imag(i, j_1)] = fixed_rotation_mode(K_fix ,M_real(i, j_1) ,M_imag(i, j_1) ,d,iter_num);
                end
            end
            [Y_real(i, 1) ,Y_imag(i, 1)] = fixed_rotation_mode(K_fix ,Y_real(i, 1) ,Y_imag(i, 1) ,d,iter_num);
        end

        RQ = [M_real Y_real];
        RQ_im = [M_imag Y_imag];
        if j < 4
            for i = e_re:4
                rotation_param = [RQ(j, j) RQ(i, j)];
                [RQ(j, j) ,RQ(i, j) ,d] = fixed_vectoring_mode(K_fix ,rotation_param(1) ,rotation_param(2),iter_num);
                for j_1 = j+1 : 5
                    [RQ(j, j_1) ,RQ(i, j_1)] = fixed_rotation_mode(K_fix ,RQ(j, j_1) ,RQ(i, j_1) ,d,iter_num);
                end
                for j_1 = j+1 : 5
                    [RQ_im(j, j_1) ,RQ_im(i, j_1)] = fixed_rotation_mode(K_fix ,RQ_im(j, j_1) ,RQ_im(i, j_1) ,d,iter_num);
                end
            end
        end

        M_real = RQ(:,1:4);
        Y_real = RQ(:,5);
        M_imag = RQ_im(:,1:4);
        Y_imag = RQ_im(:,5);

        
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
    R = fi(R ,1 ,20 ,16 ,F);
    % Q = I_real + I_imag*1i;
    % Q = fi(Q,1 ,14 ,12);
    Y_HAT = Y_real + Y_imag*1i;
    Y_HAT = fi(Y_HAT ,1 ,20 ,16 ,F);


end