module fp_adder #(
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter INST_W = 4,
    parameter DATA_W = INT_W + FRAC_W,
    parameter MOST_EXP_DIFF = 11
)(
    input                     i_clk,
    input                     i_rst_n,
    input signed [DATA_W-1:0] i_data_a,
    input signed [DATA_W-1:0] i_data_b,
    output       [DATA_W-1:0] fp_adder_o
);

wire                      a_signed;
wire                      b_signed;
wire        [INT_W-2:0]   a_exp;
wire        [INT_W-2:0]   b_exp;
wire        [FRAC_W-1:0]  a_frac;
wire        [FRAC_W-1:0]  b_frac;

wire                      exp_compare; //a_exp > b_exp high, and vice versa
reg         [INT_W-2:0]   exp_diff;
reg         [INT_W-2:0]   large_exp;

wire        [FRAC_W:0]    a_add_integer;
wire        [FRAC_W:0]    b_add_integer;
reg signed  [FRAC_W+11:0] a_extension[0:11];
reg signed  [FRAC_W+11:0] b_extension[0:11];
reg signed  [FRAC_W+11:0] a_extension_sel;
reg signed  [FRAC_W+11:0] b_extension_sel;
reg signed  [FRAC_W+12:0] a_operation;
reg signed  [FRAC_W+12:0] b_operation;

wire signed [FRAC_W+13:0] operation_out;
reg         [FRAC_W+13:0] operation_out_2_unsigned;

wire        [4:0]         clz_w;
reg         [FRAC_W+13:0] clz_cal_r[0:FRAC_W+13];

wire        [FRAC_W+13:0] unsigned_out_shift;
wire                      out_sticky;
reg         [FRAC_W+1:0]  out_round;
reg         [FRAC_W-1:0]  operation_out_normalized_frac;
reg         [INT_W-2:0]   operation_out_normalized_exp;

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

genvar exp_exten;
generate
    always @(*) begin
        a_extension[0] = {a_add_integer ,{MOST_EXP_DIFF{1'd0}}};
        b_extension[0] = {b_add_integer ,{MOST_EXP_DIFF{1'd0}}};
    end
    for(exp_exten = 0; exp_exten < 11; exp_exten = exp_exten + 1) begin:exp_exten_for
        always @(*) begin
            a_extension[exp_exten+1] = {{(exp_exten+1){1'd0}} ,a_add_integer ,{(MOST_EXP_DIFF-exp_exten-1){1'd0}}};
            b_extension[exp_exten+1] = {{(exp_exten+1){1'd0}} ,b_add_integer ,{(MOST_EXP_DIFF-exp_exten-1){1'd0}}};
        end
    end
endgenerate

always @(*) begin
    if(!exp_compare) begin //a_exp > b_exp
        case(exp_diff)
            0  : begin a_extension_sel = a_extension[0]; end
            1  : begin a_extension_sel = a_extension[1]; end
            2  : begin a_extension_sel = a_extension[2]; end
            3  : begin a_extension_sel = a_extension[3]; end
            4  : begin a_extension_sel = a_extension[4]; end
            5  : begin a_extension_sel = a_extension[5]; end
            6  : begin a_extension_sel = a_extension[6]; end
            7  : begin a_extension_sel = a_extension[7]; end
            8  : begin a_extension_sel = a_extension[8]; end
            9  : begin a_extension_sel = a_extension[9]; end
            10 : begin a_extension_sel = a_extension[10]; end
            11 : begin a_extension_sel = a_extension[11]; end
            default : begin a_extension_sel = a_extension[0]; end
        endcase
    end
    else begin
        a_extension_sel = a_extension[0];
    end 
end

always @(*) begin
    if(exp_compare) begin //a_exp > b_exp
        case(exp_diff)
            0  : begin b_extension_sel = b_extension[0]; end
            1  : begin b_extension_sel = b_extension[1]; end
            2  : begin b_extension_sel = b_extension[2]; end
            3  : begin b_extension_sel = b_extension[3]; end
            4  : begin b_extension_sel = b_extension[4]; end
            5  : begin b_extension_sel = b_extension[5]; end
            6  : begin b_extension_sel = b_extension[6]; end
            7  : begin b_extension_sel = b_extension[7]; end
            8  : begin b_extension_sel = b_extension[8]; end
            9  : begin b_extension_sel = b_extension[9]; end
            10 : begin b_extension_sel = b_extension[10]; end
            11 : begin b_extension_sel = b_extension[11]; end
            default : begin b_extension_sel = b_extension[0]; end
        endcase
    end
    else begin
        b_extension_sel = b_extension[0];
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
    if(operation_out[FRAC_W+13]) begin
        operation_out_2_unsigned = ~operation_out + 1'b1;
    end
    else begin
        operation_out_2_unsigned = operation_out;
    end
end

//CLZ parameterized calculation
always @(*) begin
    clz_cal_r[0] = {{(FRAC_W+13){1'b0}} ,operation_out_2_unsigned[FRAC_W+13]};
end

genvar i;
generate
    for(i = 0; i < FRAC_W+13; i = i + 1) begin: lead_0_for_loop //caculate first 1 from left
        always @(*) begin
            if(|clz_cal_r[i]) begin
                clz_cal_r[i+1] = clz_cal_r[i] + 1;
            end
            else begin
                clz_cal_r[i+1] = {{(FRAC_W+13){1'b0}} ,operation_out_2_unsigned[FRAC_W-i+12]};
            end
        end
    end
endgenerate

assign clz_w = FRAC_W + 14 - clz_cal_r[FRAC_W+13];
//CLZ parameterized calculation

assign unsigned_out_shift = operation_out_2_unsigned << clz_w;
assign out_sticky         = |unsigned_out_shift[FRAC_W+1:0];

always @(*) begin
    if(!unsigned_out_shift[FRAC_W+2]) begin //R is 0
        out_round = {1'b0 ,unsigned_out_shift[FRAC_W+13:FRAC_W+3]};
    end
    else if(unsigned_out_shift[FRAC_W+2] && out_sticky) begin  //Both of R and S is 1
        out_round = unsigned_out_shift[FRAC_W+13:FRAC_W+3] + 1'b1;
    end
    else if(unsigned_out_shift[FRAC_W+3] && unsigned_out_shift[FRAC_W+2]) begin  //Both of G and R is 1
        out_round = unsigned_out_shift[FRAC_W+13:FRAC_W+3] + 1'b1;
    end
    else begin //GRS is 2'b010
        out_round = {1'b0 ,unsigned_out_shift[FRAC_W+13:FRAC_W+3]};
    end
end



always @(*) begin
    if(!out_round[FRAC_W+1]) begin
        operation_out_normalized_frac = out_round[FRAC_W-1:0];
        operation_out_normalized_exp  = large_exp - clz_w + 2; //large_exp - (clz_w - 2)
    end
    else begin
        operation_out_normalized_frac = out_round[FRAC_W:1];
        operation_out_normalized_exp  = large_exp - clz_w + 3; //large_exp - (clz_w - 3)
    end
end

assign fp_adder_o = {operation_out[FRAC_W+13] ,operation_out_normalized_exp ,operation_out_normalized_frac};

endmodule
