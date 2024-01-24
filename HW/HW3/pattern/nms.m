function [out_ul ,out_ur ,out_ll ,out_lr] = nms(ifmap ,y ,x ,z)
    out_ul_x = sobel_x(ifmap ,y   ,x   ,z);
    out_ul_y = sobel_y(ifmap ,y   ,x   ,z);
    out_ur_x = sobel_x(ifmap ,y   ,x+1 ,z);
    out_ur_y = sobel_y(ifmap ,y   ,x+1 ,z);
    out_ll_x = sobel_x(ifmap ,y+1 ,x   ,z);
    out_ll_y = sobel_y(ifmap ,y+1 ,x   ,z);
    out_lr_x = sobel_x(ifmap ,y+1 ,x+1 ,z);
    out_lr_y = sobel_y(ifmap ,y+1 ,x+1 ,z);
    
    G_ul = abs(out_ul_x) + abs(out_ul_y);
    G_ur = abs(out_ur_x) + abs(out_ur_y);
    G_ll = abs(out_ll_x) + abs(out_ll_y);
    G_lr = abs(out_lr_x) + abs(out_lr_y);
    
    angle_ul = out_ul_y/out_ul_x;
    angle_ur = out_ur_y/out_ur_x;
    angle_ll = out_ll_y/out_ll_x;
    angle_lr = out_lr_y/out_lr_x;

    if abs(angle_ul) > 2.4141
        d_ul = 90;
    elseif abs(angle_ul) < 0.4141
        d_ul = 0;
    elseif angle_ul > 0
        d_ul = 45;
    else
        d_ul = 135;
    end

    if abs(angle_ur) > 2.4141
        d_ur = 90;
    elseif abs(angle_ur) < 0.4141
        d_ur = 0;
    elseif angle_ur > 0
        d_ur = 45;
    else
        d_ur = 135;
    end

    if abs(angle_ll) > 2.4141
        d_ll = 90;
    elseif abs(angle_ll) < 0.4141
        d_ll = 0;
    elseif angle_ll > 0
        d_ll = 45;
    else
        d_ll = 135;
    end

    if abs(angle_lr) > 2.4141
        d_lr = 90;
    elseif abs(angle_lr) < 0.4141
        d_lr = 0;
    elseif angle_lr > 0
        d_lr = 45;
    else
        d_lr = 135;
    end

    
    if d_ul == 90
        if G_ul >= G_ll
            out_ul = G_ul;
        else
            out_ul = 0;
        end
    elseif d_ul == 0
        if G_ul >= G_ur
            out_ul = G_ul;
        else
            out_ul = 0;
        end
    elseif d_ul == 45
        if G_ul >= G_lr
            out_ul = G_ul;
        else
            out_ul = 0;
        end
    else
        out_ul = G_ul;
    end

    if d_ur == 90
        if G_ur >= G_lr
            out_ur = G_ur;
        else
            out_ur = 0;
        end
    elseif d_ur == 0
        if G_ur >= G_ul
            out_ur = G_ur;
        else
            out_ur = 0;
        end
    elseif d_ur == 135
        if G_ur >= G_ll
            out_ur = G_ur;
        else
            out_ur = 0;
        end
    else
        out_ur = G_ur;
    end

    if d_ll == 90
        if G_ll >= G_ul
            out_ll = G_ll;
        else
            out_ll = 0;
        end
    elseif d_ll == 0
        if G_ll >= G_lr
            out_ll = G_ll;
        else
            out_ll = 0;
        end
    elseif d_ll == 135
        if G_ll >= G_ur
            out_ll = G_ll;
        else
            out_ll = 0;
        end
    else
        out_ll = G_ll;
    end

   if d_lr == 90
        if G_lr >= G_ur
            out_lr = G_lr;
        else
            out_lr = 0;
        end
    elseif d_lr == 0
        if G_lr >= G_ll
            out_lr = G_lr;
        else
            out_lr = 0;
        end
    elseif d_lr == 45
        if G_lr >= G_ul
            out_lr = G_lr;
        else
            out_lr = 0;
        end
    else
        out_lr = G_lr;
    end


    end


















