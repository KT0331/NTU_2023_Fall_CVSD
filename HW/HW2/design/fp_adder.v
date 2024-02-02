module fp_adder #(
    parameter INT_W  = 9,
    parameter FRAC_W = 23,
    parameter DATA_W = INT_W + FRAC_W,
    parameter MOST_EXP_DIFF = 253
)(
    input        [DATA_W-1:0] i_data_a,
    input        [DATA_W-1:0] i_data_b,
    output       [DATA_W-1:0] fp_adder_o
);

wire                                   a_signed;
wire                                   b_signed;
wire        [INT_W-2:0]                a_exp;
wire        [INT_W-2:0]                b_exp;
wire        [FRAC_W-1:0]               a_frac;
wire        [FRAC_W-1:0]               b_frac;

wire                                   exp_compare; //a_exp > b_exp high, and vice versa
reg         [FRAC_W+MOST_EXP_DIFF+2:0] exp_diff;
reg         [FRAC_W+MOST_EXP_DIFF+2:0] large_exp;

wire        [FRAC_W:0]                 a_add_integer;
wire        [FRAC_W:0]                 b_add_integer;
reg signed  [FRAC_W+MOST_EXP_DIFF:0]   a_extension;
reg signed  [FRAC_W+MOST_EXP_DIFF:0]   b_extension;
reg signed  [FRAC_W+MOST_EXP_DIFF:0]   a_extension_sel;
reg signed  [FRAC_W+MOST_EXP_DIFF:0]   b_extension_sel;
reg signed  [FRAC_W+MOST_EXP_DIFF+1:0] a_operation;
reg signed  [FRAC_W+MOST_EXP_DIFF+1:0] b_operation;

wire signed [FRAC_W+MOST_EXP_DIFF+2:0] operation_out;
reg         [FRAC_W+MOST_EXP_DIFF+2:0] operation_out_2_unsigned;

wire        [                    10:0] clz_w;
reg         [                    10:0] clz_cal_r[0:FRAC_W+MOST_EXP_DIFF+2];

wire        [FRAC_W+MOST_EXP_DIFF+2:0] unsigned_out_shift;
wire                                   out_sticky;
reg         [FRAC_W+1:0]               out_round;
reg         [FRAC_W-1:0]               operation_out_normalized_frac;
reg         [INT_W-2:0]                operation_out_normalized_exp;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign a_signed      = i_data_a[DATA_W-1];
assign b_signed      = i_data_b[DATA_W-1];
assign a_exp         = i_data_a[DATA_W-2:FRAC_W];
assign b_exp         = i_data_b[DATA_W-2:FRAC_W];
assign a_frac        = i_data_a[FRAC_W-1:0];
assign b_frac        = i_data_b[FRAC_W-1:0];
assign a_add_integer = {1'b1 ,a_frac};
assign b_add_integer = {1'b1 ,b_frac};

assign exp_compare = a_exp > b_exp;

always @(*) begin
    if(exp_compare) begin //a_exp > b_exp
        exp_diff  = a_exp - b_exp;
        large_exp = a_exp;
    end
    else begin
        exp_diff  = b_exp - a_exp;
        large_exp = b_exp;
    end
end


always @(*) begin
    a_extension = {a_add_integer ,{MOST_EXP_DIFF{1'd0}}};
    b_extension = {b_add_integer ,{MOST_EXP_DIFF{1'd0}}};
end

always @(*) begin
    if(!exp_compare) begin //a_exp > b_exp
        a_extension_sel = a_extension >> exp_diff;
    end
    else begin
        a_extension_sel = a_extension;
    end 
end

always @(*) begin
    if(exp_compare) begin //a_exp > b_exp
        b_extension_sel = b_extension >> exp_diff;
    end
    else begin
        b_extension_sel = b_extension;
    end 
end

always @(*) begin
    if(!(|i_data_a[DATA_W-2:FRAC_W])) begin
        a_operation = 0;
    end
    else if(a_signed) begin
        a_operation = ~{1'b0 ,a_extension_sel} + 1'b1;
    end
    else begin
        a_operation = {1'b0 ,a_extension_sel};
    end
end

always @(*) begin
    if(!(|i_data_b[DATA_W-2:FRAC_W])) begin
        b_operation = 0;
    end
    else if(b_signed) begin
        b_operation = ~{1'b0 ,b_extension_sel} + 1'b1;
    end
    else begin
        b_operation = {1'b0 ,b_extension_sel};
    end
end

assign operation_out = a_operation + b_operation;

always @(*) begin
    if(operation_out[FRAC_W+MOST_EXP_DIFF+2]) begin
        operation_out_2_unsigned = ~operation_out + 1'b1;
    end
    else begin
        operation_out_2_unsigned = operation_out;
    end
end

//CLZ parameterized calculation
always @(*) begin
    clz_cal_r[0] = {{(FRAC_W+MOST_EXP_DIFF+2){1'b0}} ,operation_out_2_unsigned[FRAC_W+MOST_EXP_DIFF+2]};
end

genvar i;
generate
    for(i = 0; i < FRAC_W+MOST_EXP_DIFF+2; i = i + 1) begin: lead_0_for_loop //caculate first 1 from left
        always @(*) begin
            if(|clz_cal_r[i]) begin
                clz_cal_r[i+1] = clz_cal_r[i] + 1;
            end
            else begin
                clz_cal_r[i+1] = {{(FRAC_W+MOST_EXP_DIFF+2){1'b0}} 
                                  ,operation_out_2_unsigned[FRAC_W+MOST_EXP_DIFF+1-i]};
            end
        end
    end
endgenerate

assign clz_w = (FRAC_W+MOST_EXP_DIFF+2) + 1 - clz_cal_r[FRAC_W+MOST_EXP_DIFF+2];
//CLZ parameterized calculation

assign unsigned_out_shift = operation_out_2_unsigned << clz_w;
assign out_sticky         = |unsigned_out_shift[MOST_EXP_DIFF:0];

always @(*) begin
    if(!unsigned_out_shift[MOST_EXP_DIFF+1]) begin //R is 0
        out_round = {1'b0 ,unsigned_out_shift[FRAC_W+MOST_EXP_DIFF+2:MOST_EXP_DIFF+2]};
    end
    //Both of R and S is 1
    else if(unsigned_out_shift[MOST_EXP_DIFF+1] && out_sticky) begin
        out_round = unsigned_out_shift[FRAC_W+MOST_EXP_DIFF+2:MOST_EXP_DIFF+2] + 1'b1;
    end
    //Both of G and R is 1
    else if(unsigned_out_shift[MOST_EXP_DIFF+2] && unsigned_out_shift[MOST_EXP_DIFF+1]) begin
        out_round = unsigned_out_shift[FRAC_W+MOST_EXP_DIFF+2:MOST_EXP_DIFF+2] + 1'b1;
    end
    //GRS is 2'b010
    else begin
        out_round = {1'b0 ,unsigned_out_shift[FRAC_W+MOST_EXP_DIFF+2:MOST_EXP_DIFF+2]};
    end
end



always @(*) begin
    if(!out_round[FRAC_W+1]) begin
        operation_out_normalized_exp  = large_exp - clz_w + 2; //large_exp - (clz_w - 2)
        operation_out_normalized_frac = out_round[FRAC_W-1:0];
    end
    else begin
        operation_out_normalized_exp  = large_exp - clz_w + 3; //large_exp - (clz_w - 3)
        operation_out_normalized_frac = out_round[FRAC_W:1];
    end
end

assign fp_adder_o = {operation_out[FRAC_W+MOST_EXP_DIFF+2]
                     ,operation_out_normalized_exp ,operation_out_normalized_frac};

endmodule
