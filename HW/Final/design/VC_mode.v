module VC_mode #(
    parameter INOUT_WIDRH = 16,
    parameter ITER_NUM = 9
) (
    input                         i_clk,
    input                         i_rst,
    input                         i_data_valid,
    input       [INOUT_WIDRH-1:0] i_data_x,
    input       [INOUT_WIDRH-1:0] i_data_y,
    output                        o_d_valid,
    output                        o_d,
    output                        o_x_valid,
    output      [INOUT_WIDRH-1:0] o_x
);

// ---------------------------------------------------------------------------
// Signal Declaration
// ---------------------------------------------------------------------------

wire                          rotation_computing_w;
wire                          multiply_computing_w;

reg  signed [  INOUT_WIDRH:0] x_buff_r;
reg  signed [  INOUT_WIDRH:0] x_buff_w;
reg  signed [  INOUT_WIDRH:0] y_buff_r;
reg  signed [  INOUT_WIDRH:0] y_buff_w;

reg                           d_r;
reg                           d_w;

reg                           o_d_valid_r;
reg                           o_x_valid_r;

reg         [            3:0] iter_num_r;
reg         [            3:0] iter_num_w;

reg  signed [  INOUT_WIDRH:0] x_rota_in_w;
reg  signed [  INOUT_WIDRH:0] y_rota_in_w;
reg  signed [INOUT_WIDRH+1:0] x_stage_out_w;
reg  signed [INOUT_WIDRH+1:0] y_stage_out_w;
reg  signed [  INOUT_WIDRH:0] x_rota_out_w;
reg  signed [  INOUT_WIDRH:0] y_rota_out_w;

wire                    [4:0] shift_num_w;

reg  signed [ INOUT_WIDRH:0] dx_rota_in_shift_w;
reg  signed [ INOUT_WIDRH:0] dy_rota_in_shift_w;

wire signed [  INOUT_WIDRH:0] x_rota_in_shift_floor_w;
wire signed [  INOUT_WIDRH:0] y_rota_in_shift_floor_w;

reg  signed [  INOUT_WIDRH:0] x_shift_w;
reg  signed [  INOUT_WIDRH:0] y_shift_w;

wire signed [            6:0] k;     //7bits constant
reg  signed [  INOUT_WIDRH:0] y_k_in_w;
wire signed [INOUT_WIDRH+7:0] k_out_w; //7+21
wire        [INOUT_WIDRH-1:0] k_out_floor_w;

// ---------------------------------------------------------------------------
// Output Signal Assignment
// ---------------------------------------------------------------------------

assign o_d = d_r;
assign o_d_valid = o_d_valid_r;
assign o_x = x_buff_r[INOUT_WIDRH-1:0];
assign o_x_valid = o_x_valid_r;

// ---------------------------------------------------------------------------
// Control Block
// ---------------------------------------------------------------------------

assign rotation_computing_w = (i_data_valid || (iter_num_r != 4'b0000)) && (!multiply_computing_w);
assign multiply_computing_w = (iter_num_r == ITER_NUM);

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        iter_num_r <= 4'b0000;
    end
    else begin
        iter_num_r <= iter_num_w;
    end
end

always @(*) begin
    if(rotation_computing_w) begin
        iter_num_w = iter_num_r + 1'b1;
    end
    else if(multiply_computing_w) begin
        iter_num_w = 4'b0000;
    end
    else begin
        iter_num_w = iter_num_r;
    end
end

always @(posedge i_clk /*or posedge i_rst*/) begin
    //if(i_rst) begin
    //    x_buff_r <= {(INOUT_WIDRH+1){1'd0}};
    //    y_buff_r <= {(INOUT_WIDRH+1){1'd0}};
    //end
    //else begin
        x_buff_r <= x_buff_w;
        y_buff_r <= y_buff_w;
    //end
end

always @(*) begin
    if(rotation_computing_w) begin
        x_buff_w = x_rota_out_w;
        y_buff_w = y_rota_out_w;
    end
    else if(multiply_computing_w) begin
        x_buff_w = {1'b0 ,k_out_floor_w};
        y_buff_w = y_buff_r;
    end
    else begin
        x_buff_w = x_buff_r;
        y_buff_w = y_buff_r;
    end
end

always @(posedge i_clk /*or posedge i_rst*/) begin
    //if(i_rst) begin
    //    d_r <= 1'd0;
    //end
    //else begin
        d_r <= d_w;
    //end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        o_d_valid_r <= 1'b0;
    end
    else begin
        o_d_valid_r <= rotation_computing_w;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        o_x_valid_r <= 1'b0;
    end
    else begin
        o_x_valid_r <= multiply_computing_w;
    end
end

// ---------------------------------------------------------------------------
// Shift and Add Stage
// ---------------------------------------------------------------------------

always @(*) begin
    if(i_data_valid) begin
        x_rota_in_w = {i_data_x[INOUT_WIDRH-1] ,i_data_x};
        y_rota_in_w = {i_data_y[INOUT_WIDRH-1] ,i_data_y};
    end
    else begin
        if(rotation_computing_w) begin
            x_rota_in_w = x_buff_r;
            y_rota_in_w = y_buff_r;
        end
        else begin
            x_rota_in_w = {(INOUT_WIDRH+1){1'd0}};
            y_rota_in_w = {(INOUT_WIDRH+1){1'd0}};
        end
    end
end

always @(*) begin
    if(x_rota_in_w[INOUT_WIDRH] ^ y_rota_in_w[INOUT_WIDRH]) begin
        d_w = 1'b1;
    end
    else begin
        d_w = 1'b0;
    end
end

always @(*) begin
    if(!d_w) begin
        dx_rota_in_shift_w = ~x_rota_in_w + 1'b1;
    end
    else begin
        dx_rota_in_shift_w = x_rota_in_w;
    end
end

always @(*) begin
    if(!d_w) begin
        dy_rota_in_shift_w = y_rota_in_w;
    end
    else begin
        dy_rota_in_shift_w = ~y_rota_in_w + 1'b1;
    end
end

assign shift_num_w = iter_num_r;

assign x_rota_in_shift_floor_w = dx_rota_in_shift_w >>> shift_num_w;
assign y_rota_in_shift_floor_w = dy_rota_in_shift_w >>> shift_num_w;

always @(*) begin
    x_shift_w = y_rota_in_shift_floor_w;
    y_shift_w = x_rota_in_shift_floor_w;
end

always @(*) begin
    x_stage_out_w = x_rota_in_w + x_shift_w;
    y_stage_out_w = y_rota_in_w + y_shift_w;
end

always @(*) begin
    x_rota_out_w = {x_stage_out_w[INOUT_WIDRH+1] ,x_stage_out_w[INOUT_WIDRH-1:0]};
    y_rota_out_w = {y_stage_out_w[INOUT_WIDRH+1] ,y_stage_out_w[INOUT_WIDRH-1:0]};
end

// ---------------------------------------------------------------------------
// Multiply Stage
// ---------------------------------------------------------------------------

assign k = 7'b0100_111;

assign k_out_w = k * y_k_in_w;

always @(*) begin
    if(multiply_computing_w) begin
        y_k_in_w = x_buff_r;
    end
    else begin
        y_k_in_w = {(INOUT_WIDRH+1){1'd0}};
    end
end

assign k_out_floor_w = {k_out_w[INOUT_WIDRH+7]
                       ,k_out_w[INOUT_WIDRH+4:INOUT_WIDRH+2]
                       ,k_out_w[INOUT_WIDRH+1:6]};

endmodule