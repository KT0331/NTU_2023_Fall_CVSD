module alu #(
    parameter ADDR_WIDTH   = 32,
    parameter DATA_WIDTH   = 32,
    parameter OPCODE_WIDTH = 6
) (   
    input        [OPCODE_WIDTH-1:0] i_op_mode,
    input signed [  DATA_WIDTH-1:0] i_data_a,
    input signed [  DATA_WIDTH-1:0] i_data_b,
    output       [  DATA_WIDTH-1:0] o_data,
    output                          o_overflow //o_overflow high as o_data overflow
);

wire        [  DATA_WIDTH-1:0] add_o_w;
wire        [    DATA_WIDTH:0] add_result_w;
wire        [    DATA_WIDTH:0] add_result_inv_w;
reg  signed [  DATA_WIDTH-1:0] i_data_b_fx;
reg                            add_over_w;

wire        [  DATA_WIDTH-1:0] mul_o_w;
wire        [2*DATA_WIDTH-1:0] mul_result_w;
wire        [2*DATA_WIDTH-1:0] mul_result_inv_w;
reg                            mul_over_w;

wire        [  DATA_WIDTH-1:0] and_o_w;
wire        [  DATA_WIDTH-1:0] or_o_w;
wire        [  DATA_WIDTH-1:0] nor_o_w;

reg         [  DATA_WIDTH-1:0] equ_o_w;
reg         [  DATA_WIDTH-1:0] smaller_o_w;

reg         [  DATA_WIDTH-1:0] shift_o_w;

wire                           fp_inst_change;
wire signed [  DATA_WIDTH-1:0] i_data_b_fp;
wire        [  DATA_WIDTH-1:0] fp_adder_o;

wire        [  DATA_WIDTH-1:0] fp_mul_o;

reg         [  DATA_WIDTH-1:0] o_data_w;
reg                            o_overflow_w;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        Interface Circuit                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign o_data     = o_data_w;
assign o_overflow = o_overflow_w;

always @(*) begin
    case(i_op_mode)
        `OP_ADD: begin
            o_data_w     = add_o_w;
            o_overflow_w = add_over_w;
        end
        `OP_SUB: begin
            o_data_w     = add_o_w;
            o_overflow_w = add_over_w;
        end
        `OP_MUL: begin
            o_data_w     = mul_o_w;
            o_overflow_w = mul_over_w;
        end
        `OP_ADDI: begin
            o_data_w     = add_o_w;
            o_overflow_w = add_over_w;
        end
        `OP_AND: begin
            o_data_w     = and_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_OR: begin
            o_data_w     = or_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_NOR: begin
            o_data_w     = nor_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_BEQ: begin
            o_data_w     = equ_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_BNE: begin
            o_data_w     = ~equ_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_SLT: begin
            o_data_w     = smaller_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_FP_ADD: begin
            o_data_w     = fp_adder_o;
            o_overflow_w = 1'b0;
        end
        `OP_FP_SUB: begin
            o_data_w     = fp_adder_o;
            o_overflow_w = 1'b0;
        end
        `OP_FP_MUL: begin
            o_data_w     = fp_mul_o;
            o_overflow_w = 1'b0;
        end
        `OP_SLL: begin
            o_data_w     = shift_o_w;
            o_overflow_w = 1'b0;
        end
        `OP_SRL: begin
            o_data_w     = shift_o_w;
            o_overflow_w = 1'b0;
        end
        default: begin
            o_data_w     = {DATA_WIDTH{1'b0}};
            o_overflow_w = 1'b0;
        end
    endcase
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SUB circuit                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign and_o_w = i_data_a & i_data_b;
assign or_o_w  = i_data_a | i_data_b;
assign nor_o_w = ~(i_data_a | i_data_b);

//addition
assign add_o_w          = {add_result_w[DATA_WIDTH] ,add_result_w[DATA_WIDTH-2:0]};
assign add_result_w     = i_data_a + i_data_b_fx;
assign add_result_inv_w = ~add_result_w + 1'b1;

always @(*) begin
    if(i_op_mode == `OP_SUB) begin
        i_data_b_fx = ~i_data_b + 1'b1;
    end
    else begin
        i_data_b_fx = i_data_b;
    end
end

always @(*) begin
    if(!add_result_w[DATA_WIDTH]) begin //add_result_w is positive
        if(add_result_w[DATA_WIDTH-1]) begin //add_result_w is saturation
            add_over_w = 1'b1;
        end
        else begin //add_result_w is not saturation
            add_over_w = 1'b0;
        end
    end
    else begin //add_result_w is negative
        if((!add_result_inv_w[DATA_WIDTH]) && (add_result_inv_w[DATA_WIDTH-1])) begin //add_result_inv_w saturation
            add_over_w = 1'b1;
        end
        else if(add_result_inv_w[DATA_WIDTH]) begin //add_result_w is negative and saturation
            add_over_w = 1'b1;
        end
        else begin
            add_over_w = 1'b0;
        end
    end
end
//addition

//multiply
assign mul_o_w          = {mul_result_w[2*DATA_WIDTH-1] ,mul_result_w[DATA_WIDTH-2:0]};
assign mul_result_w     = i_data_a * i_data_b;
assign mul_result_inv_w = ~mul_result_w + 1'b1;

always @(*) begin
    if(!mul_result_w[2*DATA_WIDTH-1]) begin //mul_result_w is positive
        if(|mul_result_w[2*DATA_WIDTH-2:DATA_WIDTH-1]) begin //mul_result_w is saturation
            mul_over_w = 1'b1;
        end
        else begin //mul_result_w is not saturation
            mul_over_w = 1'b0;
        end
    end
    else begin //mul_result_w is negative
        //mul_result_inv_w saturation
        if((!mul_result_inv_w[2*DATA_WIDTH-1]) && (|mul_result_inv_w[2*DATA_WIDTH-2:DATA_WIDTH-1])) begin
            mul_over_w = 1'b1;
        end
        else if(mul_result_inv_w[2*DATA_WIDTH-1]) begin //mul_result_w is negative and saturation
            mul_over_w = 1'b1;
        end
        else begin
            mul_over_w = 1'b0;
        end
    end
end
//multiply

//BEQ & BNE
always @(*) begin
    if(i_data_a == i_data_b) begin
        equ_o_w = {DATA_WIDTH{1'b1}};
    end
    else begin
        equ_o_w = {DATA_WIDTH{1'b0}};
    end
end
//BEQ & BNE

//SLT
always @(*) begin
    if(i_data_a < i_data_b) begin
        smaller_o_w = {{(DATA_WIDTH-1){1'b0}} ,1'b1};
    end
    else begin
        smaller_o_w = {DATA_WIDTH{1'b0}};
    end
end
//SLT

//SLL & SRL
always @(*) begin
    if(i_op_mode == `OP_SLL) begin
        shift_o_w = i_data_a << i_data_b;
    end
    else begin
        shift_o_w = i_data_a >> i_data_b;
    end
end
//SLL & SRL

//fp addition
assign fp_inst_change = i_data_b[DATA_WIDTH-1] ^ (i_op_mode == `OP_FP_SUB); //both high change to low
assign i_data_b_fp = {fp_inst_change ,i_data_b[DATA_WIDTH-2:0]};

fp_adder #(
    .INT_W(9),
    .FRAC_W(23),
    .DATA_W(DATA_WIDTH),
    .MOST_EXP_DIFF(253)
) u_fp_adder (
    .i_data_a(i_data_a),
    .i_data_b(i_data_b_fp),
    .fp_adder_o(fp_adder_o)
);
//fp addition

//fp multiply
fp_mul #(
    .INT_W(9),
    .FRAC_W(23),
    .DATA_W(DATA_WIDTH)
) u_fp_mul (
    .i_data_a(i_data_a),
    .i_data_b(i_data_b),
    .fp_mul_o(fp_mul_o)
);
//fp multiply

endmodule
