module fp_mul #(
    parameter INT_W  = 9,
    parameter FRAC_W = 23,
    parameter DATA_W = INT_W + FRAC_W
)(
    input  [DATA_W-1:0] i_data_a,
    input  [DATA_W-1:0] i_data_b,
    output [DATA_W-1:0] fp_mul_o
);

wire                a_signed_w;
wire                b_signed_w;
wire [   INT_W-2:0] a_exp_w;
wire [   INT_W-2:0] b_exp_w;
wire [  FRAC_W-1:0] a_frac_w;
wire [  FRAC_W-1:0] b_frac_w;
wire                fp_mul_o_signed_w;
wire [   INT_W-2:0] exp_temp_w;
wire [    FRAC_W:0] a_add_integer_w;
wire [    FRAC_W:0] b_add_integer_w;

wire [2*FRAC_W+1:0] frac_mul_w;

reg  [  2*FRAC_W:0] frac_mul_shift_w;
wire [   INT_W-2:0] exp_temp_shift_w;

reg  [    FRAC_W:0] frac_mul_nearest_w;
wire                frac_mul_sticky_w;

reg  [  FRAC_W-1:0] frac_mul_out_w;
reg  [   INT_W-2:0] exp_out_w;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign a_signed_w      = i_data_a[DATA_W-1];
assign b_signed_w      = i_data_b[DATA_W-1];
assign a_exp_w         = i_data_a[DATA_W-2:FRAC_W];
assign b_exp_w         = i_data_b[DATA_W-2:FRAC_W];
assign a_frac_w        = i_data_a[FRAC_W-1:0];
assign b_frac_w        = i_data_b[FRAC_W-1:0];

assign fp_mul_o_signed_w = a_signed_w ^ b_signed_w;
assign exp_temp_w        = (a_exp_w-127) + (b_exp_w-127) + 127;

assign a_add_integer_w = {1'b1 ,a_frac_w};
assign b_add_integer_w = {1'b1 ,b_frac_w};

assign frac_mul_w = a_add_integer_w * b_add_integer_w;

always @(*) begin
    if(frac_mul_w[2*FRAC_W+1]) begin //MSB is 1
        frac_mul_shift_w = frac_mul_w[2*FRAC_W:0];
    end
    else begin //LSB is 0
        frac_mul_shift_w = {frac_mul_w[2*FRAC_W-1:0] ,1'b0};
    end
end

assign exp_temp_shift_w = exp_temp_w + frac_mul_w[2*FRAC_W+1];

assign frac_mul_sticky_w = |frac_mul_shift_w[FRAC_W-1:0];

always @(*) begin
    //R is 0
    if(!frac_mul_shift_w[FRAC_W]) begin
        frac_mul_nearest_w = {1'b0 ,frac_mul_shift_w[2*FRAC_W:FRAC_W+1]};
    end
    //Both of R and S is 1
    else if(frac_mul_shift_w[FRAC_W] && frac_mul_sticky_w) begin
        frac_mul_nearest_w = frac_mul_shift_w[2*FRAC_W:FRAC_W+1] + 1'b1;
    end
    //Both of G and R is 1
    else if(frac_mul_shift_w[FRAC_W+1] && frac_mul_shift_w[FRAC_W]) begin
        frac_mul_nearest_w = frac_mul_shift_w[2*FRAC_W:FRAC_W+1] + 1'b1;
    end
    //GRS is 2'b010
    else begin
        frac_mul_nearest_w = {1'b0 ,frac_mul_shift_w[2*FRAC_W:FRAC_W+1]};
    end
end

always @(*) begin
    if(frac_mul_nearest_w[FRAC_W]) begin
        frac_mul_out_w = frac_mul_nearest_w[FRAC_W:1];
        exp_out_w      = exp_temp_shift_w + 1;
    end
    else begin
        frac_mul_out_w = frac_mul_nearest_w[FRAC_W-1:0];
        exp_out_w      = exp_temp_shift_w;
    end
end

assign fp_mul_o = {fp_mul_o_signed_w ,exp_out_w ,frac_mul_out_w};

endmodule
