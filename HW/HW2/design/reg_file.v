module reg_file #(
    parameter ADDR_WIDTH   = 5,
    parameter DATA_WIDTH   = 32,
    parameter REG_AMOUNT   = 32
) (   
    input                     i_clk,
    input                     i_rst_n,
    input                     w_enable, //w_enable high means can write
    input  [  ADDR_WIDTH-1:0] w_addr,
    input  [  DATA_WIDTH-1:0] w_data,
    input  [  ADDR_WIDTH-1:0] r_addr,
    output [  DATA_WIDTH-1:0] r_data
);

reg  [DATA_WIDTH-1:0] data_store[0:REG_AMOUNT-1];

wire [DATA_WIDTH-1:0] r_data_w;
reg  [DATA_WIDTH-1:0] r_data_r;


assign r_data = r_data_w;

genvar reg_var;
generate
    for(reg_var = 0; reg_var < REG_AMOUNT; reg_var = reg_var + 1) begin: reg_file_loop
        always @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n) begin
                data_store[reg_var] <= {DATA_WIDTH{1'b0}};
            end
            else begin
                if(w_enable) begin
                    if(w_addr == reg_var) begin
                        data_store[reg_var] <= w_data;
                    end
                    else begin
                        data_store[reg_var] <= data_store[reg_var];
                    end
                end
                else begin
                    data_store[reg_var] <= data_store[reg_var];
                end
            end
        end
    end
endgenerate

assign r_data_w = data_store[r_addr];
/*
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_data_r <= {DATA_WIDTH{1'b0}};
    end
    else begin
        r_data_r <= r_data_w;
    end
end
*/
endmodule