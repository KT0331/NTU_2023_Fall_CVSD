module p_c #(
    parameter ADDR_WIDTH = 32
) (   
    input                   i_clk,
    input                   i_rst_n,
    input                   i_change_sig,
    input  [ADDR_WIDTH-1:0] i_change_addr,
    output [ADDR_WIDTH-1:0] o_i_addr,
    output                  o_i_addr_overflow
);

reg [ADDR_WIDTH-1:0] pc_addr_n_w;
reg [ADDR_WIDTH-1:0] pc_count_r;
reg [ADDR_WIDTH-1:0] pc_addr_overflow_w;
reg [ADDR_WIDTH-1:0] pc_count_overflow_r;

assign o_i_addr          = pc_count_r;
assign o_i_addr_overflow = pc_count_overflow_r;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        {pc_count_overflow_r ,pc_count_r} <= {1'b0 ,{ADDR_WIDTH{1'b0}}};
    end
    else begin
        {pc_count_overflow_r ,pc_count_r} <= {pc_addr_overflow_w ,pc_addr_n_w};
    end
end

always @(*) begin
    if(i_change_sig) begin
        pc_addr_overflow_w = |pc_addr_n_w[ADDR_WIDTH-1:12];
        pc_addr_n_w = pc_count_r + i_change_addr;
    end
    else begin
        pc_addr_overflow_w = pc_count_overflow_r;
        pc_addr_n_w        = pc_count_r;
    end
end

endmodule