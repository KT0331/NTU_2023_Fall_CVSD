module alu #(
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter INST_W = 4,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                     i_clk,
    input                     i_rst_n,
    input signed [DATA_W-1:0] i_data_a,
    input signed [DATA_W-1:0] i_data_b,
    input        [INST_W-1:0] i_inst,
    output                    o_valid,
    output                    o_busy,
    output       [DATA_W-1:0] o_data
);

wire                                  o_valid_w;
reg                                   o_valid_r;
reg                                   o_busy_r;
reg        [DATA_W-1:0]               o_data_r;
reg        [DATA_W-1:0]               o_data_stay_r;
reg        [DATA_W-1:0]               o_data_sel_r;

reg        [1:0]                      c_state;
reg        [1:0]                      n_state;
reg                                   start_r;
reg                                   start_comb;
reg                                   idle_sig;
reg                                   wait_sig;
reg                                   oper_sig;
reg                                   out_sig;

wire signed [DATA_W:0]                add_fx_w;
wire signed [DATA_W:0]                add_fx_w_inv;
reg         [DATA_W-1:0]              add_fx_w_o;

wire signed [DATA_W:0]                sub_fx_w;
wire signed [DATA_W:0]                sub_fx_w_inv;
reg         [DATA_W-1:0]              sub_fx_w_o;

wire signed [2*DATA_W - 1:0]          mul_fx_w;
wire signed [2*DATA_W - 1:0]          mul_fx_w_inv;
wire        [2*DATA_W-1-(FRAC_W-1):0] mul_fx_w_nearest_inv;
reg         [2*DATA_W-1-(FRAC_W-1):0] mul_fx_w_nearest;
reg         [DATA_W-1:0]              mul_fx_w_o;

wire signed [2*DATA_W - 1:0]          odata_exten_w;
wire signed [2*DATA_W:0]              mac_fx_w;
wire signed [2*DATA_W:0]              mac_fx_w_inv;
wire        [2*DATA_W-(FRAC_W-1):0]   mac_fx_w_nearest_inv;
reg         [2*DATA_W-(FRAC_W-1):0]   mac_fx_w_nearest;
reg         [DATA_W-1:0]              mac_fx_w_o;

wire        [DATA_W-1:0]              clz_w;
reg         [DATA_W-1:0]              clz_cal_r[0:DATA_W-1];

wire        [5:0]                     cpop_w;
reg                                   lrcw_r_lead_inv[0:DATA_W-1];
reg         [5:0]                     cpop_r[0:DATA_W-1]; //highest value is 16
reg         [DATA_W-1:0]              lrcw_s_r[0:16];
reg         [DATA_W-1:0]              lrcw_r[0:16];
reg         [DATA_W-1:0]              lrcw_r_sel;

wire                                  lfsr_lsb[0:7];
wire                                  lfsr_lsb_15[0:6];
wire                                  lfsr_lsb_13[0:6];
wire                                  lfsr_lsb_12[0:6];
wire                                  lfsr_lsb_10[0:6];
wire        [DATA_W-1:0]              lfsr_w;
wire        [3:0]                     lfsr_shift_nmuber_w;
reg         [DATA_W-1:0]              lfsr_r[0:8];
reg         [DATA_W-2:0]              lfsr_r_shift[0:8];

wire signed [DATA_W-1:0]              gelu_w;

wire                                  fp_inst_change;
wire signed [DATA_W-1:0]              i_data_b_fp;
wire signed [DATA_W-1:0]              fp_adder_w;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               parameters                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam ADD_FX = 4'b0000;
localparam SUB_FX = 4'b0001;
localparam MUL_FX = 4'b0010;
localparam MAC    = 4'b0011;
localparam GELU   = 4'b0100;
localparam CLZ    = 4'b0101;
localparam LRCW   = 4'b0110;
localparam LFSR   = 4'b0111;
localparam ADD_FP = 4'b1000;
localparam SUB_FP = 4'b1001;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           FSM parameters                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE_STATE  = 2'b00; //at circuit rst
localparam WAIT_STATE  = 2'b01; //wait input data
localparam OPER_STATE  = 2'b10; //operation result
localparam OUT_STATE   = 2'b11; //output data and require new input data
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                FSM                                                          //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        c_state <= IDLE_STATE;
    end
    else begin
        c_state <= n_state;
    end
end

always @(*) begin
    case(c_state)
        IDLE_STATE: begin
            n_state = WAIT_STATE;
        end
        WAIT_STATE: begin
            n_state = OPER_STATE;
        end
        OPER_STATE: begin
            n_state = OUT_STATE;
        end
        OUT_STATE: begin
            n_state = WAIT_STATE;
        end
        default : begin
            n_state = IDLE_STATE;
        end
    endcase
end

always @(*) begin
    case(c_state)
        IDLE_STATE: begin
            idle_sig = 1'b1;
            wait_sig = 1'b0;
            oper_sig = 1'b0;
            out_sig  = 1'b0;
        end
        WAIT_STATE: begin
            idle_sig = 1'b0;
            wait_sig = 1'b1;
            oper_sig = 1'b0;
            out_sig  = 1'b0;
        end
        OPER_STATE: begin
            idle_sig = 1'b0;
            wait_sig = 1'b0;
            oper_sig = 1'b1;
            out_sig  = 1'b0;
        end
        OUT_STATE: begin
            idle_sig = 1'b0;
            wait_sig = 1'b0;
            oper_sig = 1'b0;
            out_sig  = 1'b1;
        end
        default : begin
            idle_sig = 1'b0;
            wait_sig = 1'b0;
            oper_sig = 1'b0;
            out_sig  = 1'b0;
        end
    endcase
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         control circuit                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign o_busy  = o_busy_r;
assign o_valid = o_valid_r;
assign o_data  = o_data_r;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_r <= 0;
    end
    else begin
        start_r <= start_comb;
    end
end

always @(*) begin
    if(start_r) begin
        start_comb = 1;
    end
    else begin
        start_comb = ~o_busy_r;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_busy_r <= ~(idle_sig & i_rst_n);
    end
    else begin
        o_busy_r <= ~out_sig;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_valid_r <= 1'b0;
    end
    else begin
        o_valid_r <= o_valid_w;
    end
end

assign o_valid_w = out_sig & start_r;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_data_r <= 0;
    end
    else begin
        o_data_r <= o_data_stay_r;
    end
end

always @(*) begin
    if(out_sig) begin
        o_data_stay_r = o_data_sel_r;
    end
    else begin
        o_data_stay_r = o_data_r;
    end
end

always @(*) begin
    case(i_inst)
        ADD_FX  : begin
            o_data_sel_r = add_fx_w_o;
        end
        SUB_FX  : begin
            o_data_sel_r = sub_fx_w_o;
        end
        MUL_FX  : begin
            o_data_sel_r = mul_fx_w_o;
        end
        MAC     : begin
            o_data_sel_r = mac_fx_w_o;
        end
        GELU    : begin
            o_data_sel_r = gelu_w;
        end
        CLZ     : begin
            o_data_sel_r = clz_w;
        end
        LRCW    : begin
            o_data_sel_r = lrcw_r_sel;
        end
        LFSR    : begin
            o_data_sel_r = lfsr_w;
        end
        ADD_FP  : begin
            o_data_sel_r = fp_adder_w;
        end
        SUB_FP  : begin
            o_data_sel_r = fp_adder_w;
        end
        default : begin
            o_data_sel_r = 16'h0000;
        end
    endcase
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        operation circuit                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign add_fx_w             = i_data_a + i_data_b;
assign add_fx_w_inv         = ~add_fx_w + 1'b1;

assign sub_fx_w             = i_data_a - i_data_b;
assign sub_fx_w_inv         = ~sub_fx_w + 1'b1;

assign mul_fx_w             = i_data_a * i_data_b;
assign mul_fx_w_inv         = ~mul_fx_w + 1'b1;
assign mul_fx_w_nearest_inv = ~mul_fx_w_nearest + 1'b1;

assign odata_exten_w        = {{6{o_data[DATA_W-1]}} ,o_data ,10'd0};
assign mac_fx_w             = mul_fx_w + odata_exten_w;
assign mac_fx_w_inv         = ~mac_fx_w + 1'b1;
assign mac_fx_w_nearest_inv = ~mac_fx_w_nearest + 1'b1;

//////FX adder//////
//saturation or not
always @(*) begin
    if(!add_fx_w[DATA_W]) begin //add_fx_w is positive
        if(add_fx_w[DATA_W-1]) begin //add_fx_w is saturation
            add_fx_w_o = {1'b0 ,{15{1'b1}}};
        end
        else begin //add_fx_w is not saturation
            add_fx_w_o = {add_fx_w[DATA_W] ,add_fx_w[DATA_W-2:0]};
        end
    end
    else begin //add_fx_w is negative
        if((!add_fx_w_inv[DATA_W]) && (add_fx_w_inv[DATA_W-1])) begin //add_fx_w_inv saturation
            add_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else if(add_fx_w_inv[DATA_W]) begin //add_fx_w is negative and saturation
            add_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else begin
            add_fx_w_o = ~{add_fx_w_inv[DATA_W] ,add_fx_w_inv[DATA_W-2:0]} + 1'b1;
        end
    end
end
//////FX adder//////

//////FX sub//////
//saturation or not
always @(*) begin
    if(!sub_fx_w[DATA_W]) begin //sub_fx_w is positive
        if(sub_fx_w[DATA_W-1]) begin //sub_fx_w is saturation
            sub_fx_w_o = {1'b0 ,{15{1'b1}}};
        end
        else begin //sub_fx_w is not saturation
            sub_fx_w_o = {sub_fx_w[DATA_W] ,sub_fx_w[DATA_W-2:0]};
        end
    end
    else begin //sub_fx_w is negative
        if((!sub_fx_w_inv[DATA_W]) && (sub_fx_w_inv[DATA_W-1])) begin //sub_fx_w_inv saturation
            sub_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else if(sub_fx_w_inv[DATA_W]) begin //sub_fx_w is negative and saturation
            sub_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else begin
            sub_fx_w_o = ~{sub_fx_w_inv[DATA_W] ,sub_fx_w_inv[DATA_W-2:0]} + 1'b1;
        end
    end
end
//////FX sub//////

//////FX MUL//////
always @(*) begin
    mul_fx_w_nearest = {mul_fx_w[2*DATA_W - 1] ,mul_fx_w[2*DATA_W - 1:FRAC_W]} + mul_fx_w[FRAC_W-1];
end

//saturation or not
always @(*) begin
    if(!mul_fx_w_nearest[2*DATA_W - 10]) begin //mul_fx_w_nearest is positive
        if(|mul_fx_w_nearest[(2*DATA_W - 11):(DATA_W-1)]) begin //mul_fx_w_nearest is saturation
            mul_fx_w_o = {1'b0 ,{15{1'b1}}};
        end
        else begin //mul_fx_w_nearest is not saturation
            mul_fx_w_o = {mul_fx_w_nearest[2*DATA_W - 10] ,mul_fx_w_nearest[DATA_W-2:0]};
        end
    end
    else begin //mul_fx_w_nearest is negative
        //mul_fx_w_nearest_inv saturation
        if((!mul_fx_w_nearest_inv[2*DATA_W - 10]) && (|mul_fx_w_nearest_inv[(2*DATA_W - 11):(DATA_W-1)])) begin
            mul_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else if(mul_fx_w_nearest_inv[2*DATA_W - 10]) begin //mul_fx_w is negative and saturation
            mul_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else begin
            mul_fx_w_o = ~{mul_fx_w_nearest_inv[2*DATA_W - 10] ,mul_fx_w_nearest_inv[DATA_W-2:0]} + 1'b1;
        end
    end
end
//////FX MUL//////

//////FX MAC//////
always @(*) begin
    mac_fx_w_nearest = {mac_fx_w[2*DATA_W] ,mac_fx_w[2*DATA_W:FRAC_W]} + mac_fx_w[FRAC_W-1];
end

//saturation or not
always @(*) begin
    if(!mac_fx_w_nearest[2*DATA_W-(FRAC_W-1)]) begin //mac_fx_w_nearest is positive
        if(|mac_fx_w_nearest[2*DATA_W-(FRAC_W-1)-1:(DATA_W-1)]) begin //mac_fx_w_nearest is saturation
            mac_fx_w_o = {1'b0 ,{15{1'b1}}};
        end
        else begin //mac_fx_w_nearest is not saturation
            mac_fx_w_o = {mac_fx_w_nearest[2*DATA_W-(FRAC_W-1)] ,mac_fx_w_nearest[DATA_W-2:0]};
        end
    end
    else begin //mac_fx_w_nearest is negative
        //mac_fx_w_nearest_inv saturation
        if((!mac_fx_w_nearest_inv[2*DATA_W-(FRAC_W-1)]) && (|mac_fx_w_nearest_inv[2*DATA_W-(FRAC_W-1)-1:(DATA_W-1)])) begin
            mac_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else if(mac_fx_w_nearest_inv[2*DATA_W-(FRAC_W-1)]) begin //mac_fx_w is negative and saturation
            mac_fx_w_o = {1'b1 ,{15{1'b0}}};
        end
        else begin
            mac_fx_w_o = ~{mac_fx_w_nearest_inv[2*DATA_W-(FRAC_W-1)] ,mac_fx_w_nearest_inv[DATA_W-2:0]} + 1'b1;
        end
    end
end
//////FX MAC//////

//////CLZ parameterized calculation//////
always @(*) begin
    clz_cal_r[0] = {{(DATA_W-1){1'b0}} ,i_data_a[DATA_W-1]};
end

genvar i;
generate
    for(i = 0; i < DATA_W-1; i = i + 1) begin: lead_0_for_loop //caculate first 1 from left
        always @(*) begin
            if(|clz_cal_r[i]) begin
                clz_cal_r[i+1] = clz_cal_r[i] + 1;
            end
            else begin
                clz_cal_r[i+1] = {{(DATA_W-1){1'b0}} ,i_data_a[DATA_W-i-2]}; //clz_cal_r[i+1] = i_data_a[DATA_W-1-(i+1)];
            end
        end
    end
endgenerate

assign clz_w = DATA_W - clz_cal_r[DATA_W-1];
//////CLZ parameterized calculation//////

//////LRCW//////
//CPOP cparameterized calculation
always @(*) begin
    cpop_r[0] = {{(5){1'b0}} ,i_data_a[0]};
end

genvar w;
generate
    for(w = 0; w < DATA_W-1; w = w + 1) begin: cpop_for_loop //caculate how many bit is 1 from right
        always @(*) begin
            cpop_r[w+1] = i_data_a[w+1] + cpop_r[w];
        end
    end
endgenerate

assign cpop_w = cpop_r[DATA_W-1];
//CPOP parameterized calculation

genvar lrcw_r_lead_inv_var;
generate
    for(lrcw_r_lead_inv_var = 0; lrcw_r_lead_inv_var < DATA_W; lrcw_r_lead_inv_var = lrcw_r_lead_inv_var + 1) begin: lrcw_r_lead_inv_var_for_loop
        always @(*) begin
            lrcw_r_lead_inv[lrcw_r_lead_inv_var] = ~lrcw_r[lrcw_r_lead_inv_var][DATA_W-1];
        end
    end
endgenerate

//LRCW calculation
always @(*) begin
    lrcw_s_r[0] = i_data_b; //using logical shift
    lrcw_r[0]   = lrcw_s_r[0];
end

genvar lrcw_var;
generate
    for(lrcw_var = 0; lrcw_var < 16; lrcw_var = lrcw_var + 1) begin:lrcw_var_for
        always @(*) begin
            lrcw_s_r[lrcw_var+1] = lrcw_r[lrcw_var] << 1; //using logical shift
            lrcw_r[lrcw_var+1]   = lrcw_s_r[lrcw_var+1] + lrcw_r_lead_inv[lrcw_var]; //shift at least 1 bit
        end
    end
endgenerate

always @(*) begin
    case(cpop_w)
        0  : begin lrcw_r_sel = lrcw_r[0]; end
        1  : begin lrcw_r_sel = lrcw_r[1]; end
        2  : begin lrcw_r_sel = lrcw_r[2]; end
        3  : begin lrcw_r_sel = lrcw_r[3]; end
        4  : begin lrcw_r_sel = lrcw_r[4]; end
        5  : begin lrcw_r_sel = lrcw_r[5]; end
        6  : begin lrcw_r_sel = lrcw_r[6]; end
        7  : begin lrcw_r_sel = lrcw_r[7]; end
        8  : begin lrcw_r_sel = lrcw_r[8]; end
        9  : begin lrcw_r_sel = lrcw_r[9]; end
        10 : begin lrcw_r_sel = lrcw_r[10]; end
        11 : begin lrcw_r_sel = lrcw_r[11]; end
        12 : begin lrcw_r_sel = lrcw_r[12]; end
        13 : begin lrcw_r_sel = lrcw_r[13]; end
        14 : begin lrcw_r_sel = lrcw_r[14]; end
        15 : begin lrcw_r_sel = lrcw_r[15]; end
        16 : begin lrcw_r_sel = lrcw_r[16]; end
        default : begin lrcw_r_sel = lrcw_r[0]; end
    endcase
end
//LRCW calculation
//////LRCW//////

//////LFSR calculation//////
assign lfsr_lsb[0] = (i_data_a[15] ^ i_data_a[13]) ^ (i_data_a[12] ^ i_data_a[10]); //shift 1 bit
genvar lfsr_lsb_var;
generate
    //shift (1 + lfsr_lsb_var) bit
    for(lfsr_lsb_var = 0; lfsr_lsb_var < 7; lfsr_lsb_var = lfsr_lsb_var + 1) begin: lfsr_lsb_loop
        assign lfsr_lsb_15[lfsr_lsb_var] = lfsr_r[lfsr_lsb_var+1][15];
        assign lfsr_lsb_13[lfsr_lsb_var] = lfsr_r[lfsr_lsb_var+1][13];
        assign lfsr_lsb_12[lfsr_lsb_var] = lfsr_r[lfsr_lsb_var+1][12];
        assign lfsr_lsb_10[lfsr_lsb_var] = lfsr_r[lfsr_lsb_var+1][10];
        assign lfsr_lsb[lfsr_lsb_var + 1] =  (lfsr_lsb_15[lfsr_lsb_var] ^ lfsr_lsb_13[lfsr_lsb_var])
                                            ^(lfsr_lsb_12[lfsr_lsb_var] ^ lfsr_lsb_10[lfsr_lsb_var]);
    end
endgenerate

genvar lfsr_r_shift_var;
generate
    for(lfsr_r_shift_var = 0; lfsr_r_shift_var < 9; lfsr_r_shift_var = lfsr_r_shift_var + 1) begin: lfsr_r_shift_for_loop
        always @(*) begin
            lfsr_r_shift[lfsr_r_shift_var] = lfsr_r[lfsr_r_shift_var][DATA_W-2:0];
        end
    end
endgenerate

always @(*) begin
    lfsr_r[0] = i_data_a;
end

genvar lfsr_var;
generate
    for(lfsr_var = 0; lfsr_var < 8; lfsr_var = lfsr_var + 1) begin: lfsr_for_loop
        always @(*) begin
            lfsr_r[lfsr_var+1] = {lfsr_r_shift[lfsr_var][DATA_W-2:0] ,lfsr_lsb[lfsr_var]};
        end
    end
endgenerate

assign lfsr_shift_nmuber_w = i_data_b[3:0];
assign lfsr_w = lfsr_r[lfsr_shift_nmuber_w];
//////LFSR calculation//////

//////GELU function//////
gelu #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W),
    .INST_W(INST_W),
    .DATA_W(DATA_W)
) u_gelu_function (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data_a(i_data_a),
    .gelu_o_data(gelu_w)
);
//////GELU function//////

//////FP add and sub//////
assign fp_inst_change = i_data_b[DATA_W-1] ^ (|i_inst[INST_W-2:0]); //both negtive change to positive
assign i_data_b_fp = {fp_inst_change ,i_data_b[DATA_W-2:0]};

fp_adder #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W),
    .INST_W(INST_W),
    .DATA_W(DATA_W),
    .MOST_EXP_DIFF(11)
) u_fp_adder (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data_a(i_data_a),
    .i_data_b(i_data_b_fp),
    .fp_adder_o(fp_adder_w)
);
//////FP add and sub//////

endmodule
