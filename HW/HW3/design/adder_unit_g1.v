module adder_unit_g1 #(
    parameter DATA_WIDTH        = 8,
    parameter OUT_DATA_W        = 13,
	parameter NUM_OPER_PERLAYER = 4
) (
	input                   i_clk,
	input                   i_rst_n,
	input                   i_clear,
	//input  [DATA_WIDTH-1:0] i_in_data_ul,
	//input  [DATA_WIDTH-1:0] i_in_data_ur,
	//input  [DATA_WIDTH-1:0] i_in_data_ll,
	//input  [DATA_WIDTH-1:0] i_in_data_lr,
	input  [DATA_WIDTH-1:0] i_in_data,
	input  [           4:0] i_coe_mode_addr, //[4] high means sobel and low means conv, [3:0] address
	output [OUT_DATA_W+3:0] o_out_data_ul,
	output [OUT_DATA_W+3:0] o_out_data_ur,
	output [OUT_DATA_W+3:0] o_out_data_ll,
	output [OUT_DATA_W+3:0] o_out_data_lr
);

reg     [OUT_DATA_W+3:0]    operator_ul_w;
reg     [OUT_DATA_W+3:0]    operator_ur_w;
reg     [OUT_DATA_W+3:0]    operator_ll_w;
reg     [OUT_DATA_W+3:0]    operator_lr_w;

reg     [OUT_DATA_W+3:0]    adder_ul_r;
reg     [OUT_DATA_W+3:0]    adder_ur_r;
reg     [OUT_DATA_W+3:0]    adder_ll_r;
reg     [OUT_DATA_W+3:0]    adder_lr_r;

reg     [OUT_DATA_W+3:0]    adder_ul_w;
reg     [OUT_DATA_W+3:0]    adder_ur_w;
reg     [OUT_DATA_W+3:0]    adder_ll_w;
reg     [OUT_DATA_W+3:0]    adder_lr_w;

wire    [OUT_DATA_W+3:0]    conv_operator_4;
wire    [OUT_DATA_W+3:0]    conv_operator_8;
wire    [OUT_DATA_W+3:0]    conv_operator_16;

wire    [OUT_DATA_W+3:0]    sobel_operator_pos1;
wire    [OUT_DATA_W+3:0]    sobel_operator_pos2;
wire    [OUT_DATA_W+3:0]    sobel_operator_neg1;
wire    [OUT_DATA_W+3:0]    sobel_operator_neg2;


assign o_out_data_ul       = adder_ul_r;
assign o_out_data_ur       = adder_ur_r;
assign o_out_data_ll       = adder_ll_r;
assign o_out_data_lr       = adder_lr_r;

assign conv_operator_4     = {{(OUT_DATA_W-DATA_WIDTH+2){1'b0}} ,i_in_data ,2'b00};
assign conv_operator_8     = {{(OUT_DATA_W-DATA_WIDTH+3){1'b0}} ,i_in_data ,1'b0};
assign conv_operator_16    = {{(OUT_DATA_W-DATA_WIDTH+4){1'b0}} ,i_in_data};

assign sobel_operator_pos1 = {{(OUT_DATA_W-DATA_WIDTH+4){1'b0}} ,i_in_data};
assign sobel_operator_pos2 = {{(OUT_DATA_W-DATA_WIDTH-3){1'b0}} ,i_in_data ,1'b0};
assign sobel_operator_neg1 = ~{{(OUT_DATA_W-DATA_WIDTH+4){1'b0}} ,i_in_data} + 1'b1;
assign sobel_operator_neg2 = ~{{(OUT_DATA_W-DATA_WIDTH-3){1'b0}} ,i_in_data ,1'b0} + 1'b1;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		adder_ul_r <= {(OUT_DATA_W+4){1'b0}};
		adder_ur_r <= {(OUT_DATA_W+4){1'b0}};
		adder_ll_r <= {(OUT_DATA_W+4){1'b0}};
		adder_lr_r <= {(OUT_DATA_W+4){1'b0}};
	end
	else begin
		adder_ul_r <= adder_ul_w;
		adder_ur_r <= adder_ur_w;
		adder_ll_r <= adder_ll_w;
		adder_lr_r <= adder_lr_w;
	end
end

always @(*) begin
	if (i_clear) begin
		adder_ul_w = {(OUT_DATA_W+4){1'b0}};
		adder_ur_w = {(OUT_DATA_W+4){1'b0}};
		adder_ll_w = {(OUT_DATA_W+4){1'b0}};
		adder_lr_w = {(OUT_DATA_W+4){1'b0}};
	end
	else begin
		adder_ul_w = adder_ul_r + operator_ul_w;
		adder_ur_w = adder_ur_r + operator_ur_w;
		adder_ll_w = adder_ll_r + operator_ll_w;
		adder_lr_w = adder_lr_r + operator_lr_w;
	end
end

always @(*) begin
	if(i_coe_mode_addr[4]) begin //sobel
		case(i_coe_mode_addr[3:0])
			4'd11: begin
				operator_ul_w = sobel_operator_neg1;
			end
			4'd13: begin
				operator_ul_w = sobel_operator_pos1;
			end
			4'd15: begin
				operator_ul_w = sobel_operator_neg2;
			end
			4'd1: begin
				operator_ul_w = sobel_operator_pos2;
			end
			4'd3: begin
				operator_ul_w = sobel_operator_neg1;
			end
			4'd5: begin
				operator_ul_w = sobel_operator_pos1;
			end
			default: begin
				operator_ul_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
	else begin //conv
		case(i_coe_mode_addr[3:0])
			4'd11: begin
				operator_ul_w = conv_operator_16;
			end
			4'd12: begin
				operator_ul_w = conv_operator_8;
			end
			4'd13: begin
				operator_ul_w = conv_operator_16;
			end
			4'd15: begin
				operator_ul_w = conv_operator_8;
			end
			4'd0: begin
				operator_ul_w = conv_operator_4;
			end
			4'd1: begin
				operator_ul_w = conv_operator_8;
			end
			4'd3: begin
				operator_ul_w = conv_operator_16;
			end
			4'd4: begin
				operator_ul_w = conv_operator_8;
			end
			4'd5: begin
				operator_ul_w = conv_operator_16;
			end
			default: begin
				operator_ul_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
end

always @(*) begin
	if(i_coe_mode_addr[4]) begin //sobel
		case(i_coe_mode_addr[3:0])
			4'd12: begin
				operator_ur_w = sobel_operator_neg1;
			end
			4'd14: begin
				operator_ur_w = sobel_operator_pos1;
			end
			4'd0: begin
				operator_ur_w = sobel_operator_neg2;
			end
			4'd2: begin
				operator_ur_w = sobel_operator_pos2;
			end
			4'd4: begin
				operator_ur_w = sobel_operator_neg1;
			end
			4'd6: begin
				operator_ur_w = sobel_operator_pos1;
			end
			default: begin
				operator_ur_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
	else begin //conv
		case(i_coe_mode_addr[3:0])
			4'd12: begin
				operator_ur_w = conv_operator_16;
			end
			4'd13: begin
				operator_ur_w = conv_operator_8;
			end
			4'd14: begin
				operator_ur_w = conv_operator_16;
			end
			4'd0: begin
				operator_ur_w = conv_operator_8;
			end
			4'd1: begin
				operator_ur_w = conv_operator_4;
			end
			4'd2: begin
				operator_ur_w = conv_operator_8;
			end
			4'd4: begin
				operator_ur_w = conv_operator_16;
			end
			4'd5: begin
				operator_ur_w = conv_operator_8;
			end
			4'd6: begin
				operator_ur_w = conv_operator_16;
			end
			default: begin
				operator_ur_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
end

always @(*) begin
	if(i_coe_mode_addr[4]) begin //sobel
		case(i_coe_mode_addr[3:0])
			4'd15: begin
				operator_ll_w = sobel_operator_neg1;
			end
			4'd1: begin
				operator_ll_w = sobel_operator_pos1;
			end
			4'd3: begin
				operator_ll_w = sobel_operator_neg2;
			end
			4'd5: begin
				operator_ll_w = sobel_operator_pos2;
			end
			4'd7: begin
				operator_ll_w = sobel_operator_neg1;
			end
			4'd9: begin
				operator_ll_w = sobel_operator_pos1;
			end
			default: begin
				operator_ll_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
	else begin //conv
		case(i_coe_mode_addr[3:0])
			4'd15: begin
				operator_ll_w = conv_operator_16;
			end
			4'd0: begin
				operator_ll_w = conv_operator_8;
			end
			4'd1: begin
				operator_ll_w = conv_operator_16;
			end
			4'd3: begin
				operator_ll_w = conv_operator_8;
			end
			4'd4: begin
				operator_ll_w = conv_operator_4;
			end
			4'd5: begin
				operator_ll_w = conv_operator_8;
			end
			4'd7: begin
				operator_ll_w = conv_operator_16;
			end
			4'd8: begin
				operator_ll_w = conv_operator_8;
			end
			4'd9: begin
				operator_ll_w = conv_operator_16;
			end
			default: begin
				operator_ll_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
end

always @(*) begin
	if(i_coe_mode_addr[4]) begin //sobel
		case(i_coe_mode_addr[3:0])
			4'd0: begin
				operator_lr_w = sobel_operator_neg1;
			end
			4'd2: begin
				operator_lr_w = sobel_operator_pos1;
			end
			4'd4: begin
				operator_lr_w = sobel_operator_neg2;
			end
			4'd6: begin
				operator_lr_w = sobel_operator_pos2;
			end
			4'd8: begin
				operator_lr_w = sobel_operator_neg1;
			end
			4'd10: begin
				operator_lr_w = sobel_operator_pos1;
			end
			default: begin
				operator_lr_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
	else begin //conv
		case(i_coe_mode_addr[3:0])
			4'd0: begin
				operator_lr_w = conv_operator_16;
			end
			4'd1: begin
				operator_lr_w = conv_operator_8;
			end
			4'd2: begin
				operator_lr_w = conv_operator_16;
			end
			4'd4: begin
				operator_lr_w = conv_operator_8;
			end
			4'd5: begin
				operator_lr_w = conv_operator_4;
			end
			4'd6: begin
				operator_lr_w = conv_operator_8;
			end
			4'd8: begin
				operator_lr_w = conv_operator_16;
			end
			4'd9: begin
				operator_lr_w = conv_operator_8;
			end
			4'd10: begin
				operator_lr_w = conv_operator_16;
			end
			default: begin
				operator_lr_w = {(OUT_DATA_W+4){1'b0}};
			end
		endcase
	end
end


endmodule