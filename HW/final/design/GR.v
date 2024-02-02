module GR #(
    parameter INOUT_WIDRH = 16,
    parameter ITER_NUM = 9
) (
    input                             i_clk,
    input                             i_rst,
    input                             i_data_valid,
    input       [(2*INOUT_WIDRH)-1:0] i_data,
    input                             i_d_im2re_valid,
    input                             i_d_im2re,
    input                             i_d_re2re_valid,
    input                             i_d_re2re,
    input                             i_first_in,
    input                             i_last_in,
    output                            o_d_im2re_valid,
    output                            o_d_im2re,
    output                            o_d_re2re_valid,
    output                            o_d_re2re,
    output                            o_x_valid,
    output      [    INOUT_WIDRH-1:0] o_x_re,
    output      [    INOUT_WIDRH-1:0] o_x_im,
    output                            o_y_valid,
    output      [    INOUT_WIDRH-1:0] o_y_re,
    output      [    INOUT_WIDRH-1:0] o_y_im,
    output                            o_data_1stage_valid,
    output      [    INOUT_WIDRH-1:0] o_x_re_1stage,
    output      [    INOUT_WIDRH-1:0] o_y_im_1stage
);

// ---------------------------------------------------------------------------
// Signal Declaration
// ---------------------------------------------------------------------------

reg  [INOUT_WIDRH-1:0] first_data_buff_re_r; //Store Real Part
reg  [INOUT_WIDRH-1:0] first_data_buff_re_w;
reg  [INOUT_WIDRH-1:0] first_data_buff_im_r; //Store Imaginary Part
reg  [INOUT_WIDRH-1:0] first_data_buff_im_w;
reg  [            1:0] first_data_flag_r;
reg  [            1:0] first_data_flag_w;
reg  [            1:0] last_data_flag_r;
reg  [            1:0] last_data_flag_w;

reg  [INOUT_WIDRH-1:0] x_in_re2re_sel_w;
reg  [INOUT_WIDRH-1:0] x_in_im2im_sel_w;

wire [INOUT_WIDRH-1:0] data_in_im_w;
wire [INOUT_WIDRH-1:0] data_in_re_w;


// ---------------------------------------------------------------------------
// Sub-Module Interface Signal Declaration
// ---------------------------------------------------------------------------

wire                   data_in_valid_im2re_w;
wire [INOUT_WIDRH-1:0] x_in_im2re_w;
wire [INOUT_WIDRH-1:0] y_in_im2re_w;
wire                   d_in_valid_im2re_w;
wire                   d_in_im2re_w;
wire                   d_out_valid_im2re_w;
wire                   d_out_im2re_w;
wire                   data_out_im2re_valid_w;
wire [INOUT_WIDRH-1:0] x_out_im2re_w;
wire [INOUT_WIDRH-1:0] y_out_im2re_w;

wire                   data_in_valid_re2re_w;
wire [INOUT_WIDRH-1:0] x_in_re2re_w;
wire [INOUT_WIDRH-1:0] y_in_re2re_w;
wire                   d_in_valid_re2re_w;
wire                   d_in_re2re_w;
wire                   d_out_valid_re2re_w;
wire                   d_out_re2re_w;
wire                   data_out_re2re_valid_w;
wire [INOUT_WIDRH-1:0] x_out_re2re_w;
wire [INOUT_WIDRH-1:0] y_out_re2re_w;

wire                   data_in_valid_im2im_w;
wire [INOUT_WIDRH-1:0] x_in_im2im_w;
wire [INOUT_WIDRH-1:0] y_in_im2im_w;
wire                   d_in_valid_im2im_w;
wire                   d_in_im2im_w;
wire                   d_out_valid_im2im_w;
wire                   d_out_im2im_w;
wire                   data_out_im2im_valid_w;
wire [INOUT_WIDRH-1:0] x_out_im2im_w;
wire [INOUT_WIDRH-1:0] y_out_im2im_w;

// ---------------------------------------------------------------------------
// Control Block
// ---------------------------------------------------------------------------

assign o_data_1stage_valid = data_out_im2re_valid_w;
assign o_x_re_1stage       = x_out_im2re_w;
assign o_y_im_1stage       = y_out_im2re_w;
assign o_d_im2re_valid     = d_out_valid_im2re_w;
assign o_d_im2re           = d_out_im2re_w;
assign o_d_re2re_valid     = d_out_valid_re2re_w;
assign o_d_re2re           = d_out_re2re_w;
assign o_x_valid           = data_out_re2re_valid_w && last_data_flag_r[1];
assign o_x_re              = x_out_re2re_w;
assign o_x_im              = x_out_im2im_w;
assign o_y_valid           = data_out_re2re_valid_w;
assign o_y_re              = y_out_re2re_w;
assign o_y_im              = y_out_im2im_w;

assign data_in_im_w = i_data[(2*INOUT_WIDRH)-1:INOUT_WIDRH];
assign data_in_re_w = i_data[INOUT_WIDRH-1:0];

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        first_data_flag_r <= 2'b00;
    end
    else begin
        first_data_flag_r <= first_data_flag_w;
    end
end

always @(*) begin
    if(i_first_in) begin
        first_data_flag_w = 2'b01;
    end
    else if(first_data_flag_r[0] && data_out_im2re_valid_w) begin
        first_data_flag_w = 2'b10;
    end
    else if(first_data_flag_r[1] && data_out_im2re_valid_w) begin
        first_data_flag_w = 2'b00;
    end
    else begin
        first_data_flag_w = first_data_flag_r;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        last_data_flag_r <= 2'b00;
    end
    else begin
        last_data_flag_r <= last_data_flag_w;
    end
end

always @(*) begin
    if(i_last_in) begin
        last_data_flag_w = 2'b01;
    end
    else if(last_data_flag_r[0] && data_out_im2re_valid_w) begin
        last_data_flag_w = 2'b10;
    end
    else if(last_data_flag_r[1] && data_out_re2re_valid_w) begin
        last_data_flag_w = 2'b00;
    end
    else begin
        last_data_flag_w = last_data_flag_r;
    end
end

always @(posedge i_clk) begin
    first_data_buff_re_r <= first_data_buff_re_w;
end

always @(*) begin
    if(first_data_flag_r && data_out_im2re_valid_w) begin
        first_data_buff_re_w = x_out_im2re_w;
    end
    else if((!last_data_flag_r[1]) && data_out_re2re_valid_w) begin
        first_data_buff_re_w = x_out_re2re_w;
    end
    else begin
        first_data_buff_re_w = first_data_buff_re_r;
    end
end

always @(posedge i_clk) begin
    first_data_buff_im_r <= first_data_buff_im_w;
end

always @(*) begin
    if(first_data_flag_r && data_out_im2re_valid_w) begin
        first_data_buff_im_w = y_out_im2re_w;
    end
    else if((!last_data_flag_r[1]) && data_out_re2re_valid_w) begin
        first_data_buff_im_w = x_out_im2im_w;
    end
    else begin
        first_data_buff_im_w = first_data_buff_im_r;
    end
end

always @(*) begin
    if(first_data_flag_r[1] || (!data_out_re2re_valid_w)) begin
        x_in_re2re_sel_w = first_data_buff_re_r;
    end
    else begin
        x_in_re2re_sel_w = x_out_re2re_w;
    end
end

always @(*) begin
    if(first_data_flag_r[1] || (!data_out_re2re_valid_w)) begin
        x_in_im2im_sel_w = first_data_buff_im_r;
    end
    else begin
        x_in_im2im_sel_w = x_out_im2im_w;
    end
end

// ---------------------------------------------------------------------------
// Sub-Module Interface Signal Control
// ---------------------------------------------------------------------------

assign data_in_valid_im2re_w  = i_data_valid;
assign x_in_im2re_w           = data_in_re_w;
assign y_in_im2re_w           = data_in_im_w;
assign d_in_valid_im2re_w     = i_d_im2re_valid;
assign d_in_im2re_w           = i_d_im2re;

assign data_in_valid_re2re_w  = ((first_data_flag_r[1] || (!first_data_flag_r[0]))
                                && data_out_im2re_valid_w);
assign x_in_re2re_w           = x_in_re2re_sel_w;
assign y_in_re2re_w           = x_out_im2re_w;
assign d_in_valid_re2re_w     = i_d_re2re_valid;
assign d_in_re2re_w           = i_d_re2re;

assign data_in_valid_im2im_w  = ((first_data_flag_r[1] || (!first_data_flag_r[0]))
                                && data_out_im2re_valid_w);
assign x_in_im2im_w           = x_in_im2im_sel_w;
assign y_in_im2im_w           = y_out_im2re_w;
assign d_in_valid_im2im_w     = i_d_re2re_valid;
assign d_in_im2im_w           = i_d_re2re;

// ---------------------------------------------------------------------------
// Sub-Module Instantiation
// ---------------------------------------------------------------------------

//Rotation mode Imaginary part and Real part
RO_mode #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_RO_mode_im2re (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(data_in_valid_im2re_w),
    .i_data_x(x_in_im2re_w),               //[INOUT_WIDRH-1:0]
    .i_data_y(y_in_im2re_w),               //[INOUT_WIDRH-1:0]
    .i_d_valid(d_in_valid_im2re_w),
    .i_d(d_in_im2re_w),                    //[ITER_NUM-1:0]
    .o_d_valid(d_out_valid_im2re_w),
    .o_d(d_out_im2re_w),                   //[ITER_NUM-1:0]
    .o_data_valid(data_out_im2re_valid_w), //[INOUT_WIDRH-1:0]
    .o_x(x_out_im2re_w),                   //[INOUT_WIDRH-1:0]
    .o_y(y_out_im2re_w)                    //[INOUT_WIDRH-1:0]
);

//Rotation mode Real part and Real part
RO_mode #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_RO_mode_re2re (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(data_in_valid_re2re_w),
    .i_data_x(x_in_re2re_w),               //[INOUT_WIDRH-1:0]
    .i_data_y(y_in_re2re_w),               //[INOUT_WIDRH-1:0]
    .i_d_valid(d_in_valid_re2re_w),
    .i_d(d_in_re2re_w),                    //[ITER_NUM-1:0]
    .o_d_valid(d_out_valid_re2re_w),
    .o_d(d_out_re2re_w),                   //[ITER_NUM-1:0]
    .o_data_valid(data_out_re2re_valid_w), //[INOUT_WIDRH-1:0]
    .o_x(x_out_re2re_w),                   //[INOUT_WIDRH-1:0]
    .o_y(y_out_re2re_w)                    //[INOUT_WIDRH-1:0]
);

//Rotation mode Imaginary part and Imaginary part
RO_mode #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_RO_mode_im2im (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data_valid(data_in_valid_im2im_w),
    .i_data_x(x_in_im2im_w),               //[INOUT_WIDRH-1:0]
    .i_data_y(y_in_im2im_w),               //[INOUT_WIDRH-1:0]
    .i_d_valid(d_in_valid_im2im_w),
    .i_d(d_in_im2im_w),                    //[ITER_NUM-1:0]
    .o_d_valid(d_out_valid_im2im_w),
    .o_d(d_out_im2im_w),                   //[ITER_NUM-1:0]
    .o_data_valid(data_out_im2im_valid_w), //[INOUT_WIDRH-1:0]
    .o_x(x_out_im2im_w),                   //[INOUT_WIDRH-1:0]
    .o_y(y_out_im2im_w)                    //[INOUT_WIDRH-1:0]
);

endmodule