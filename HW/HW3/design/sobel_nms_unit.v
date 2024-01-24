module sobel_nms_unit #(
    parameter DATA_WIDTH        = 11,
    parameter OUT_DATA_W        = 11
) (
	input                   i_clk,
	input                   i_rst_n,
	input  [DATA_WIDTH-1:0] i_in_gx_ul,
	input  [DATA_WIDTH-1:0] i_in_gy_ul,
	input  [DATA_WIDTH-1:0] i_in_gx_ur,
	input  [DATA_WIDTH-1:0] i_in_gy_ur,
	input  [DATA_WIDTH-1:0] i_in_gx_ll,
	input  [DATA_WIDTH-1:0] i_in_gy_ll,
	input  [DATA_WIDTH-1:0] i_in_gx_lr,
	input  [DATA_WIDTH-1:0] i_in_gy_lr,
	output [OUT_DATA_W-1:0] o_out_data_ul,
	output [OUT_DATA_W-1:0] o_out_data_ur,
	output [OUT_DATA_W-1:0] o_out_data_ll,
	output [OUT_DATA_W-1:0] o_out_data_lr
);

localparam angle_0   = 2'b00;
localparam angle_45  = 2'b01;
localparam angle_90  = 2'b10;
localparam angle_135 = 2'b11;

reg  [    OUT_DATA_W-1:0] out_data_ul_r;
reg  [    OUT_DATA_W-1:0] out_data_ul_w;
reg  [    OUT_DATA_W-1:0] out_data_ur_r;
reg  [    OUT_DATA_W-1:0] out_data_ur_w;
reg  [    OUT_DATA_W-1:0] out_data_ll_r;
reg  [    OUT_DATA_W-1:0] out_data_ll_w;
reg  [    OUT_DATA_W-1:0] out_data_lr_r;
reg  [    OUT_DATA_W-1:0] out_data_lr_w;

reg  [    DATA_WIDTH-1:0] i_in_gx_ul_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gy_ul_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gx_ur_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gy_ur_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gx_ll_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gy_ll_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gx_lr_abs_w;
reg  [    DATA_WIDTH-1:0] i_in_gy_lr_abs_w;

reg  [    OUT_DATA_W-1:0] g_ul_r;
wire [    OUT_DATA_W-1:0] g_ul_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ul_22_r;
wire [DATA_WIDTH+4+7-1:0] gx_ul_22_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ul_22_f_r;
wire [DATA_WIDTH+4+7-1:0] gx_ul_22_f_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ul_22_b_r;
wire [DATA_WIDTH+4+7-1:0] gx_ul_22_b_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ul_67_r;
wire [DATA_WIDTH+4+7-1:0] gx_ul_67_w;
reg  [DATA_WIDTH+4+7-1:0] gy_ul_r;
wire [DATA_WIDTH+4+7-1:0] gy_ul_w;

reg  [    OUT_DATA_W-1:0] g_ur_r;
wire [    OUT_DATA_W-1:0] g_ur_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ur_22_r;
wire [DATA_WIDTH+4+7-1:0] gx_ur_22_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ur_22_f_r;
wire [DATA_WIDTH+4+7-1:0] gx_ur_22_f_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ur_22_b_r;
wire [DATA_WIDTH+4+7-1:0] gx_ur_22_b_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ur_67_r;
wire [DATA_WIDTH+4+7-1:0] gx_ur_67_w;
reg  [DATA_WIDTH+4+7-1:0] gy_ur_r;
wire [DATA_WIDTH+4+7-1:0] gy_ur_w;

reg  [    OUT_DATA_W-1:0] g_ll_r;
wire [    OUT_DATA_W-1:0] g_ll_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ll_22_r;
wire [DATA_WIDTH+4+7-1:0] gx_ll_22_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ll_22_f_r;
wire [DATA_WIDTH+4+7-1:0] gx_ll_22_f_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ll_22_b_r;
wire [DATA_WIDTH+4+7-1:0] gx_ll_22_b_w;
reg  [DATA_WIDTH+4+7-1:0] gx_ll_67_r;
wire [DATA_WIDTH+4+7-1:0] gx_ll_67_w;
reg  [DATA_WIDTH+4+7-1:0] gy_ll_r;
wire [DATA_WIDTH+4+7-1:0] gy_ll_w;

reg  [    OUT_DATA_W-1:0] g_lr_r;
wire [    OUT_DATA_W-1:0] g_lr_w;
reg  [DATA_WIDTH+4+7-1:0] gx_lr_22_r;
wire [DATA_WIDTH+4+7-1:0] gx_lr_22_w;
reg  [DATA_WIDTH+4+7-1:0] gx_lr_22_f_r;
wire [DATA_WIDTH+4+7-1:0] gx_lr_22_f_w;
reg  [DATA_WIDTH+4+7-1:0] gx_lr_22_b_r;
wire [DATA_WIDTH+4+7-1:0] gx_lr_22_b_w;
reg  [DATA_WIDTH+4+7-1:0] gx_lr_67_r;
wire [DATA_WIDTH+4+7-1:0] gx_lr_67_w;
reg  [DATA_WIDTH+4+7-1:0] gy_lr_r;
wire [DATA_WIDTH+4+7-1:0] gy_lr_w;

wire [DATA_WIDTH+4+7-1:0] gx_ul_pos1_w;
wire [DATA_WIDTH+4+7-1:0] gx_ul_neg2_w;
wire [DATA_WIDTH+4+7-1:0] gx_ul_neg3_w;
wire [DATA_WIDTH+4+7-1:0] gx_ul_neg5_w;
wire [DATA_WIDTH+4+7-1:0] gx_ul_neg7_w;
wire [DATA_WIDTH+4+7-1:0] gx_ur_pos1_w;
wire [DATA_WIDTH+4+7-1:0] gx_ur_neg2_w;
wire [DATA_WIDTH+4+7-1:0] gx_ur_neg3_w;
wire [DATA_WIDTH+4+7-1:0] gx_ur_neg5_w;
wire [DATA_WIDTH+4+7-1:0] gx_ur_neg7_w;
wire [DATA_WIDTH+4+7-1:0] gx_ll_pos1_w;
wire [DATA_WIDTH+4+7-1:0] gx_ll_neg2_w;
wire [DATA_WIDTH+4+7-1:0] gx_ll_neg3_w;
wire [DATA_WIDTH+4+7-1:0] gx_ll_neg5_w;
wire [DATA_WIDTH+4+7-1:0] gx_ll_neg7_w;
wire [DATA_WIDTH+4+7-1:0] gx_lr_pos1_w;
wire [DATA_WIDTH+4+7-1:0] gx_lr_neg2_w;
wire [DATA_WIDTH+4+7-1:0] gx_lr_neg3_w;
wire [DATA_WIDTH+4+7-1:0] gx_lr_neg5_w;
wire [DATA_WIDTH+4+7-1:0] gx_lr_neg7_w;

reg  [               1:0] ul_region_w;
reg  [               1:0] ur_region_w;
reg  [               1:0] ll_region_w;
reg  [               1:0] lr_region_w;

reg  [               1:0] d_ul_r;
reg  [               1:0] d_ul_w;
reg  [               1:0] d_ur_r;
reg  [               1:0] d_ur_w;
reg  [               1:0] d_ll_r;
reg  [               1:0] d_ll_w;
reg  [               1:0] d_lr_r;
reg  [               1:0] d_lr_w;

assign o_out_data_ul = out_data_ul_r;
assign o_out_data_ur = out_data_ur_r;
assign o_out_data_ll = out_data_ll_r;
assign o_out_data_lr = out_data_lr_r;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		out_data_ul_r <= {OUT_DATA_W{1'b0}};
		out_data_ur_r <= {OUT_DATA_W{1'b0}};
		out_data_ll_r <= {OUT_DATA_W{1'b0}};
		out_data_lr_r <= {OUT_DATA_W{1'b0}};
	end
	else begin
		out_data_ul_r <= out_data_ul_w;
		out_data_ur_r <= out_data_ur_w;
		out_data_ll_r <= out_data_ll_w;
		out_data_lr_r <= out_data_lr_w;
	end
end

//G must be a positive number or zero, if both neighbors is zero, output is itself//
always @(*) begin
	case(d_ul_r)
		angle_0: begin
			if(g_ul_r < g_ur_r) begin
				out_data_ul_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ul_w = g_ul_r;
			end
		end
		angle_45: begin
			if(g_ul_r < g_lr_r) begin
				out_data_ul_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ul_w = g_ul_r;
			end
		end
		angle_90: begin
			if(g_ul_r < g_ll_r) begin
				out_data_ul_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ul_w = g_ul_r;
			end
		end
		default: begin
			out_data_ul_w = g_ul_r;
		end
	endcase
end

always @(*) begin
	case(d_ur_r)
		angle_0: begin
			if(g_ur_r < g_ul_r) begin
				out_data_ur_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ur_w = g_ur_r;
			end
		end
		angle_90: begin
			if(g_ur_r < g_lr_r) begin
				out_data_ur_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ur_w = g_ur_r;
			end
		end
		angle_135: begin
			if(g_ur_r < g_ll_r) begin
				out_data_ur_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ur_w = g_ur_r;
			end
		end
		default: begin
			out_data_ur_w = g_ur_r;
		end
	endcase
end

always @(*) begin
	case(d_ll_r)
		angle_0: begin
			if(g_ll_r < g_lr_r) begin
				out_data_ll_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ll_w = g_ll_r;
			end
		end
		angle_90: begin
			if(g_ll_r < g_ul_r) begin
				out_data_ll_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ll_w = g_ll_r;
			end
		end
		angle_135: begin
			if(g_ll_r < g_ur_r) begin
				out_data_ll_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_ll_w = g_ll_r;
			end
		end
		default: begin
			out_data_ll_w = g_ll_r;
		end
	endcase
end

always @(*) begin
	case(d_lr_r)
		angle_0: begin
			if(g_lr_r < g_ll_r) begin
				out_data_lr_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_lr_w = g_lr_r;
			end
		end
		angle_45: begin
			if(g_lr_r < g_ul_r) begin
				out_data_lr_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_lr_w = g_lr_r;
			end
		end
		angle_90: begin
			if(g_lr_r < g_ur_r) begin
				out_data_lr_w = {OUT_DATA_W{1'b0}};
			end
			else begin
				out_data_lr_w = g_lr_r;
			end
		end
		default: begin
			out_data_lr_w = g_lr_r;
		end
	endcase
end
//G must be a positive number or zero, if both neighbors is zero, output is itself//

always @(*) begin
	if(i_in_gx_ul[DATA_WIDTH-1]) begin //i_in_gx_ul is negative
		i_in_gx_ul_abs_w = ~i_in_gx_ul + 1'b1;
	end
	else begin
		i_in_gx_ul_abs_w = i_in_gx_ul;
	end
end

always @(*) begin
	if(i_in_gy_ul[DATA_WIDTH-1]) begin //i_in_gy_ul is negative
		i_in_gy_ul_abs_w = ~i_in_gy_ul + 1'b1;
	end
	else begin
		i_in_gy_ul_abs_w = i_in_gy_ul;
	end
end

always @(*) begin
	if(i_in_gx_ur[DATA_WIDTH-1]) begin //i_in_gx_ur is negative
		i_in_gx_ur_abs_w = ~i_in_gx_ur + 1'b1;
	end
	else begin
		i_in_gx_ur_abs_w = i_in_gx_ur;
	end
end

always @(*) begin
	if(i_in_gy_ur[DATA_WIDTH-1]) begin //i_in_gy_ur is negative
		i_in_gy_ur_abs_w = ~i_in_gy_ur + 1'b1;
	end
	else begin
		i_in_gy_ur_abs_w = i_in_gy_ur;
	end
end

always @(*) begin
	if(i_in_gx_ll[DATA_WIDTH-1]) begin //i_in_gx_ll is negative
		i_in_gx_ll_abs_w = ~i_in_gx_ll + 1'b1;
	end
	else begin
		i_in_gx_ll_abs_w = i_in_gx_ll;
	end
end

always @(*) begin
	if(i_in_gy_ll[DATA_WIDTH-1]) begin //i_in_gy_ll is negative
		i_in_gy_ll_abs_w = ~i_in_gy_ll + 1'b1;
	end
	else begin
		i_in_gy_ll_abs_w = i_in_gy_ll;
	end
end

always @(*) begin
	if(i_in_gx_lr[DATA_WIDTH-1]) begin //i_in_gx_lr is negative
		i_in_gx_lr_abs_w = ~i_in_gx_lr + 1'b1;
	end
	else begin
		i_in_gx_lr_abs_w = i_in_gx_lr;
	end
end

always @(*) begin
	if(i_in_gy_lr[DATA_WIDTH-1]) begin //i_in_gy_lr is negative
		i_in_gy_lr_abs_w = ~i_in_gy_lr + 1'b1;
	end
	else begin
		i_in_gy_lr_abs_w = i_in_gy_lr;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		gx_ul_22_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ul_22_f_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ul_22_b_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ul_67_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gy_ul_r      <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ur_22_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ur_22_f_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ur_22_b_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ur_67_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gy_ur_r      <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ll_22_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ll_22_f_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ll_22_b_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_ll_67_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gy_ll_r      <= {(DATA_WIDTH+4+7){1'b0}};
		gx_lr_22_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gx_lr_22_f_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_lr_22_b_r <= {(DATA_WIDTH+4+7){1'b0}};
		gx_lr_67_r   <= {(DATA_WIDTH+4+7){1'b0}};
		gy_lr_r      <= {(DATA_WIDTH+4+7){1'b0}};
	end
	else begin
		gx_ul_22_r   <= gx_ul_22_w;
		gx_ul_22_f_r <= gx_ul_22_f_w;
		gx_ul_22_b_r <= gx_ul_22_b_w;
		gx_ul_67_r   <= gx_ul_67_w;
		gy_ul_r      <= gy_ul_w;
		gx_ur_22_r   <= gx_ur_22_w;
		gx_ur_22_f_r <= gx_ur_22_f_w;
		gx_ur_22_b_r <= gx_ur_22_b_w;
		gx_ur_67_r   <= gx_ur_67_w;
		gy_ur_r      <= gy_ur_w;
		gx_ll_22_r   <= gx_ll_22_w;
		gx_ll_22_f_r <= gx_ll_22_f_w;
		gx_ll_22_b_r <= gx_ll_22_b_w;
		gx_ll_67_r   <= gx_ll_67_w;
		gy_ll_r      <= gy_ll_w;
		gx_lr_22_r   <= gx_lr_22_w;
		gx_lr_22_f_r <= gx_lr_22_f_w;
		gx_lr_22_b_r <= gx_lr_22_b_w;
		gx_lr_67_r   <= gx_lr_67_w;
		gy_lr_r      <= gy_lr_w;
	end
end

assign gx_ul_22_w = gx_ul_22_f_r + gx_ul_22_b_r;
assign gx_ul_22_f_w = gx_ul_neg2_w + gx_ul_neg3_w;
assign gx_ul_22_b_w = gx_ul_neg5_w + gx_ul_neg7_w;
assign gx_ul_67_w = gx_ul_pos1_w + gx_ul_22_r;
assign gy_ul_w    = {4'd0 ,i_in_gy_ul_abs_w ,7'd0};
assign gx_ur_22_w = gx_ur_22_f_r + gx_ur_22_b_r;
assign gx_ur_22_f_w = gx_ur_neg2_w + gx_ur_neg3_w;
assign gx_ur_22_b_w = gx_ur_neg5_w + gx_ur_neg7_w;
assign gx_ur_67_w = gx_ur_pos1_w + gx_ur_22_r;
assign gy_ur_w    = {4'd0 ,i_in_gy_ur_abs_w ,7'd0};
assign gx_ll_22_w = gx_ll_22_f_r + gx_ll_22_b_r;
assign gx_ll_22_f_w = gx_ll_neg2_w + gx_ll_neg3_w;
assign gx_ll_22_b_w = gx_ll_neg5_w + gx_ll_neg7_w;
assign gx_ll_67_w = gx_ll_pos1_w + gx_ll_22_r;
assign gy_ll_w    = {4'd0 ,i_in_gy_ll_abs_w ,7'd0};
assign gx_lr_22_w = gx_lr_22_f_r + gx_lr_22_b_r;
assign gx_lr_22_f_w = gx_lr_neg2_w + gx_lr_neg3_w;
assign gx_lr_22_b_w = gx_lr_neg5_w + gx_lr_neg7_w;
assign gx_lr_67_w = gx_lr_pos1_w + gx_lr_22_r;
assign gy_lr_w    = {4'd0 ,i_in_gy_lr_abs_w ,7'd0};

assign gx_ul_pos1_w = {3'd0 ,i_in_gx_ul_abs_w ,8'd0};
assign gx_ul_neg2_w = {6'd0 ,i_in_gx_ul_abs_w ,5'd0};
assign gx_ul_neg3_w = {7'd0 ,i_in_gx_ul_abs_w ,4'd0};
assign gx_ul_neg5_w = {9'd0 ,i_in_gx_ul_abs_w ,2'd0};
assign gx_ul_neg7_w = {11'd0 ,i_in_gx_ul_abs_w};

assign gx_ur_pos1_w = {3'd0 ,i_in_gx_ur_abs_w ,8'd0};
assign gx_ur_neg2_w = {6'd0 ,i_in_gx_ur_abs_w ,5'd0};
assign gx_ur_neg3_w = {7'd0 ,i_in_gx_ur_abs_w ,4'd0};
assign gx_ur_neg5_w = {9'd0 ,i_in_gx_ur_abs_w ,2'd0};
assign gx_ur_neg7_w = {11'd0 ,i_in_gx_ur_abs_w};

assign gx_ll_pos1_w = {3'd0 ,i_in_gx_ll_abs_w ,8'd0};
assign gx_ll_neg2_w = {6'd0 ,i_in_gx_ll_abs_w ,5'd0};
assign gx_ll_neg3_w = {7'd0 ,i_in_gx_ll_abs_w ,4'd0};
assign gx_ll_neg5_w = {9'd0 ,i_in_gx_ll_abs_w ,2'd0};
assign gx_ll_neg7_w = {11'd0 ,i_in_gx_ll_abs_w};

assign gx_lr_pos1_w = {3'd0 ,i_in_gx_lr_abs_w ,8'd0};
assign gx_lr_neg2_w = {6'd0 ,i_in_gx_lr_abs_w ,5'd0};
assign gx_lr_neg3_w = {7'd0 ,i_in_gx_lr_abs_w ,4'd0};
assign gx_lr_neg5_w = {9'd0 ,i_in_gx_lr_abs_w ,2'd0};
assign gx_lr_neg7_w = {11'd0 ,i_in_gx_lr_abs_w};

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		g_ul_r <= {(OUT_DATA_W){1'b0}};
		g_ur_r <= {(OUT_DATA_W){1'b0}};
		g_ll_r <= {(OUT_DATA_W){1'b0}};
		g_lr_r <= {(OUT_DATA_W){1'b0}};
	end
	else begin
		g_ul_r <= g_ul_w;
		g_ur_r <= g_ur_w;
		g_ll_r <= g_ll_w;
		g_lr_r <= g_lr_w;
	end
end

assign g_ul_w = i_in_gx_ul_abs_w[10:0] + i_in_gy_ul_abs_w[10:0];
assign g_ur_w = i_in_gx_ur_abs_w[10:0] + i_in_gy_ur_abs_w[10:0];
assign g_ll_w = i_in_gx_ll_abs_w[10:0] + i_in_gy_ll_abs_w[10:0];
assign g_lr_w = i_in_gx_lr_abs_w[10:0] + i_in_gy_lr_abs_w[10:0];

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		d_ul_r <= 2'b00;
		d_ur_r <= 2'b00;
		d_ll_r <= 2'b00;
		d_lr_r <= 2'b00;
	end
	else begin
		d_ul_r <= d_ul_w;
		d_ur_r <= d_ur_w;
		d_ll_r <= d_ll_w;
		d_lr_r <= d_lr_w;
	end
end

always @(*) begin
	if(gy_ul_r < gx_ul_22_r) begin
		ul_region_w = angle_0;
	end
	else if(gy_ul_r > gx_ul_67_r) begin
		ul_region_w = angle_90;
	end
	else begin
		ul_region_w = 2'b01;
	end
end

always @(*) begin
	if(ul_region_w == 2'b01) begin
		if(i_in_gx_ul[DATA_WIDTH-1] ^ i_in_gy_ul[DATA_WIDTH-1]) begin //neg
			d_ul_w = angle_135;
		end
		else begin
			d_ul_w = angle_45;
		end
	end
	else begin
		d_ul_w = ul_region_w;
	end
end

always @(*) begin
	if(gy_ur_r < gx_ur_22_r) begin
		ur_region_w = angle_0;
	end
	else if(gy_ur_r > gx_ur_67_r) begin
		ur_region_w = angle_90;
	end
	else begin
		ur_region_w = 2'b01;
	end
end

always @(*) begin
	if(ur_region_w == 2'b01) begin
		if(i_in_gx_ur[DATA_WIDTH-1] ^ i_in_gy_ur[DATA_WIDTH-1]) begin //neg
			d_ur_w = angle_135;
		end
		else begin
			d_ur_w = angle_45;
		end
	end
	else begin
		d_ur_w = ur_region_w;
	end
end

always @(*) begin
	if(gy_ll_r < gx_ll_22_r) begin
		ll_region_w = angle_0;
	end
	else if(gy_ll_r > gx_ll_67_r) begin
		ll_region_w = angle_90;
	end
	else begin
		ll_region_w = 2'b01;
	end
end

always @(*) begin
	if(ll_region_w == 2'b01) begin
		if(i_in_gx_ll[DATA_WIDTH-1] ^ i_in_gy_ll[DATA_WIDTH-1]) begin //neg
			d_ll_w = angle_135;
		end
		else begin
			d_ll_w = angle_45;
		end
	end
	else begin
		d_ll_w = ll_region_w;
	end
end

always @(*) begin
	if(gy_lr_r < gx_lr_22_r) begin
		lr_region_w = angle_0;
	end
	else if(gy_lr_r > gx_lr_67_r) begin
		lr_region_w = angle_90;
	end
	else begin
		lr_region_w = 2'b01;
	end
end

always @(*) begin
	if(lr_region_w == 2'b01) begin
		if(i_in_gx_lr[DATA_WIDTH-1] ^ i_in_gy_lr[DATA_WIDTH-1]) begin //neg
			d_lr_w = angle_135;
		end
		else begin
			d_lr_w = angle_45;
		end
	end
	else begin
		d_lr_w = lr_region_w;
	end
end


endmodule