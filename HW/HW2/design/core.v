module core #( // DO NOT MODIFY!!!
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (   
    input                    i_clk,
    input                    i_rst_n,
    output  [ADDR_WIDTH-1:0] o_i_addr,
    input   [INST_WIDTH-1:0] i_i_inst,
    output                   o_d_we,
    output  [ADDR_WIDTH-1:0] o_d_addr,
    output  [DATA_WIDTH-1:0] o_d_wdata,
    input   [DATA_WIDTH-1:0] i_d_rdata,
    output  [           1:0] o_status,
    output                   o_status_valid
);


reg [ ADDR_WIDTH-1:0] o_i_addr_r;
reg                   o_d_we_r;
reg [ ADDR_WIDTH-1:0] o_d_addr_r;
wire                  o_d_addr_over_w;
reg [ DATA_WIDTH-1:0] o_d_wdata_r;
reg [            1:0] o_status_r;
reg [            1:0] o_status_w;
reg                   o_status_valid_r;
wire                  o_status_valid_w;

reg                   start_r;
reg                   start_comb;

reg  [           2:0] c_state;
reg  [           2:0] n_state;
reg                   idle_sig;
reg                   out_sig;
reg                   g_inst_sig;
reg                   get_a_sig;
reg                   get_b_sig;
reg                   compute_sig;
reg                   write_sig;

wire                  r_type_sig_w;
wire                  i_type_sig_w;

reg  [           4:0] rg1_addr_w;
reg  [           4:0] rg2_addr_w;
reg  [           4:0] rg3_addr_w;
wire [DATA_WIDTH-1:0] im;

reg  [DATA_WIDTH-1:0] data_a_w;
reg  [DATA_WIDTH-1:0] data_b_w;
reg  [DATA_WIDTH-1:0] data_a_r;
reg  [DATA_WIDTH-1:0] data_b_r;

wire                  pc_i_change_sig;
reg  [ADDR_WIDTH-1:0] pc_i_change_addr;
wire [ADDR_WIDTH-1:0] pc_o_i_addr;
wire                  pc_o_i_addr_overflow;

reg  [DATA_WIDTH-1:0] alu_i_data_a_w;
reg  [DATA_WIDTH-1:0] alu_i_data_b_w;
wire [DATA_WIDTH-1:0] alu_o_data_w;
wire                  alu_o_overflow_w;

reg                   reg_file_i_w_enable_w;
wire [           4:0] reg_file_i_w_addr_w;
reg  [DATA_WIDTH-1:0] reg_file_i_w_data_w;
reg  [           4:0] reg_file_i_r_addr_w;
wire [DATA_WIDTH-1:0] reg_file_o_data_w;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               Parameters                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           FSM Parameters                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE     = 3'd0;
localparam OUT      = 3'd1;
localparam GET_INST = 3'd2;
localparam GET_A    = 3'd3;
localparam GET_B    = 3'd4;
localparam COMPUTE  = 3'd5;
localparam WRITE    = 3'd6;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                FSM                                                          //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        c_state <= IDLE;
    end
    else begin
        c_state <= n_state;
    end
end

always @(*) begin
    case(c_state)
        IDLE: begin
            n_state = OUT;
        end
        OUT: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                n_state = GET_INST;
            end
        end
        GET_INST: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                n_state = GET_A;
            end
        end
        GET_A: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                if(i_i_inst[31:26] == `OP_ADDI) begin
                    n_state = COMPUTE;
                end
                else begin
                    n_state = GET_B;
                end
            end
        end
        GET_B: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                n_state = COMPUTE;
            end
        end
        COMPUTE: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                n_state = WRITE;
            end
        end
        WRITE: begin
            if(o_status_r[1]) begin
                n_state = IDLE;
            end
            else begin
                n_state = OUT;
            end
        end
        default: begin
            n_state = IDLE;
        end
    endcase
end

always @(*) begin
    case(c_state)
        IDLE: begin
            idle_sig    = 1'b1;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
        OUT: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b1;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
        GET_INST: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b1;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
        GET_A: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b1;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
        GET_B: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b1;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
        COMPUTE: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b1;
            write_sig   = 1'b0;
        end
        WRITE: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b1;
        end
        default: begin
            idle_sig    = 1'b0;
            out_sig     = 1'b0;
            g_inst_sig  = 1'b0;
            get_a_sig   = 1'b0;
            get_b_sig   = 1'b0;
            compute_sig = 1'b0;
            write_sig   = 1'b0;
        end
    endcase
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         Control Circuit                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign r_type_sig_w = ((i_i_inst[31:26] == `OP_ADD)
                       || (i_i_inst[31:26] == `OP_SUB)
                       || (i_i_inst[31:26] == `OP_MUL)
                       || (i_i_inst[31:26] == `OP_AND)
                       || (i_i_inst[31:26] == `OP_OR)
                       || (i_i_inst[31:26] == `OP_NOR)
                       || (i_i_inst[31:26] == `OP_SLT)
                       || (i_i_inst[31:26] == `OP_FP_ADD)
                       || (i_i_inst[31:26] == `OP_FP_SUB)
                       || (i_i_inst[31:26] == `OP_FP_MUL)
                       || (i_i_inst[31:26] == `OP_SLL)
                       || (i_i_inst[31:26] == `OP_SRL));

assign i_type_sig_w = ((i_i_inst[31:26] == `OP_ADDI)
                       || (i_i_inst[31:26] == `OP_LW)
                       || (i_i_inst[31:26] == `OP_SW)
                       || (i_i_inst[31:26] == `OP_BEQ)
                       || (i_i_inst[31:26] == `OP_BNE));

always @(*) begin
    if(r_type_sig_w) begin
        rg1_addr_w = i_i_inst[15:11];
    end
    else if(i_type_sig_w) begin
        rg1_addr_w = i_i_inst[20:16];
    end
    else begin
        rg1_addr_w = 5'b0_0000;
    end
end

always @(*) begin
    rg2_addr_w = i_i_inst[25:21];
end

always @(*) begin
    rg3_addr_w = i_i_inst[20:16];
end

assign im = {{(DATA_WIDTH/2){i_i_inst[15]}} ,i_i_inst[15:0]};

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        data_a_r <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if(idle_sig) begin
            data_a_r <= {DATA_WIDTH{1'b0}};
        end
        else begin
            data_a_r <= data_a_w;
        end
    end
end

always @(*) begin
    if(get_a_sig) begin
        data_a_w = reg_file_o_data_w;
    end
    else begin
        data_a_w = data_a_r;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        data_b_r <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if(idle_sig) begin
            data_b_r <= {DATA_WIDTH{1'b0}};
        end
        else begin
            data_b_r <= data_b_w;
        end
    end
end

always @(*) begin
    if(get_b_sig) begin
        data_b_w = reg_file_o_data_w;
    end
    else begin
        data_b_w = data_b_r;
    end
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        Interface Circuit                                                    //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign o_i_addr = o_i_addr_r;
assign o_d_we = o_d_we_r;
assign o_d_addr = o_d_addr_r;
assign o_d_wdata = o_d_wdata_r;
assign o_status = o_status_r;
assign o_status_valid = o_status_valid_r;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_i_addr_r <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if(idle_sig) begin
            o_i_addr_r <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            o_i_addr_r <= pc_o_i_addr;
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_d_we_r <= 1'b0;
    end
    else begin
        if(idle_sig) begin
            o_d_we_r <= 1'b0;
        end
        else begin
            if((i_i_inst[31:26] == `OP_SW) && write_sig && (~o_d_addr_over_w)) begin //add (~o_d_addr_over_w)//
                o_d_we_r <= 1'b1;
            end
            else begin
                o_d_we_r <= 1'b0;
            end
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_d_addr_r <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if(idle_sig) begin
            o_d_addr_r <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            o_d_addr_r <= data_a_w + im;
        end
    end
end

assign o_d_addr_over_w = |o_d_addr_r[ADDR_WIDTH-1:8];

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_d_wdata_r <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if(idle_sig) begin
            o_d_wdata_r <= {DATA_WIDTH{1'b0}};
        end
        else begin
            o_d_wdata_r <= data_b_r;
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_status_r <= 2'b00;
    end
    else begin
        if(idle_sig) begin
            o_status_r <= 2'b00;
        end
        else begin
            o_status_r <= o_status_w;
        end
    end
end

always @(*) begin
    if(i_i_inst[31:26] == `OP_EOF) begin
        o_status_w = 2'b11;
    end
    else if(out_sig) begin
        if(pc_o_i_addr_overflow) begin
            o_status_w = 2'b10;
        end
        else if(((i_i_inst[31:26] == `OP_ADD) || (i_i_inst[31:26] == `OP_SUB)
                || (i_i_inst[31:26] == `OP_MUL)|| (i_i_inst[31:26] == `OP_ADDI))
                && alu_o_overflow_w) begin
                o_status_w = 2'b10;
        end
        else if(((i_i_inst[31:26] == `OP_LW) || (i_i_inst[31:26] == `OP_SW))
                && o_d_addr_over_w) begin
                o_status_w = 2'b10;
        end
        else begin
            o_status_w = (~r_type_sig_w) & i_type_sig_w;
        end
    end
    else begin
        o_status_w = o_status_r;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_status_valid_r <= 0;
    end
    else begin
        if(idle_sig) begin
            o_status_valid_r <= 0;
        end
        else if(i_i_inst[31:26] == `OP_EOF) begin
            o_status_valid_r <= 1'b1;
        end
        else begin
            o_status_valid_r <= o_status_valid_w;
        end
    end
end

assign o_status_valid_w = out_sig & start_r;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_r <= 0;
    end
    else begin
        if(idle_sig) begin
            start_r <= 0;
        end
        else begin
            start_r <= start_comb;
        end
    end
end

always @(*) begin
    if(start_r) begin
        start_comb = 1;
    end
    else begin
        start_comb = out_sig;
    end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SUB circuit                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Program Counter
assign pc_i_change_sig = write_sig;

always @(*) begin
    if((i_i_inst[31:26] == `OP_BEQ) || (i_i_inst[31:26] == `OP_BNE)) begin
        if(|alu_o_data_w) begin
            pc_i_change_addr = im;
        end
        else begin
            pc_i_change_addr = 4;
        end
    end
    else begin
        pc_i_change_addr = 4;
    end
end

p_c #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_p_c (   
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_change_sig(pc_i_change_sig),
    .i_change_addr(pc_i_change_addr),
    .o_i_addr(pc_o_i_addr),
    .o_i_addr_overflow(pc_o_i_addr_overflow)
);

//ALU
always @(*) begin
    alu_i_data_a_w = data_a_r;
end

always @(*) begin
    if(r_type_sig_w) begin
        alu_i_data_b_w = data_b_r;
    end
    else if ((i_i_inst[31:26] == `OP_ADDI)
            || (i_i_inst[31:26] == `OP_LW)
            || (i_i_inst[31:26] == `OP_SW)) begin
        alu_i_data_b_w = im;
    end
    else begin
        alu_i_data_b_w = data_b_r;
    end
end

alu #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .OPCODE_WIDTH(6)
) u_alu (   
    .i_op_mode(i_i_inst[31:26]),
    .i_data_a(alu_i_data_a_w),
    .i_data_b(alu_i_data_b_w),
    .o_data(alu_o_data_w),
    .o_overflow(alu_o_overflow_w) //o_overflow high as o_data overflow
);

//Register file
always @(*) begin
    if(write_sig) begin
        if((i_i_inst[31:26] == `OP_SW)
            || (i_i_inst[31:26] == `OP_BEQ)
            || (i_i_inst[31:26] == `OP_BNE)) begin
            reg_file_i_w_enable_w = 1'b0;
        end
        else begin
            reg_file_i_w_enable_w = 1'b1;
        end
    end
    else begin
        reg_file_i_w_enable_w = 1'b0;
    end
end

assign reg_file_i_w_addr_w = rg1_addr_w;

always @(*) begin
    if(i_i_inst[31:26] == `OP_LW) begin
        reg_file_i_w_data_w = i_d_rdata;
    end
    else begin
        reg_file_i_w_data_w = alu_o_data_w;
    end
end

always @(*) begin
    if(get_a_sig) begin
        reg_file_i_r_addr_w = rg2_addr_w;
    end
    else if (get_b_sig) begin
        if((i_i_inst[31:26] == `OP_SW)
            || (i_i_inst[31:26] == `OP_BEQ)
            || (i_i_inst[31:26] == `OP_BNE)) begin
            reg_file_i_r_addr_w = rg1_addr_w;
        end
        else begin
            reg_file_i_r_addr_w = rg3_addr_w;
        end
    end
    else begin
        reg_file_i_r_addr_w = {ADDR_WIDTH{1'b0}};
    end
end

reg_file #(
    .ADDR_WIDTH(5),
    .DATA_WIDTH(DATA_WIDTH),
    .REG_AMOUNT(32)
) u_reg_file (   
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .w_enable(reg_file_i_w_enable_w), //w_enable high means can write
    .w_addr(reg_file_i_w_addr_w),
    .w_data(reg_file_i_w_data_w),
    .r_addr(reg_file_i_r_addr_w),
    .r_data(reg_file_o_data_w)
);


endmodule
