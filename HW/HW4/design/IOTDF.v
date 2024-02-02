`timescale 1ns/10ps
module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
localparam FN_ENC = 3'b001;
localparam FN_DEC = 3'b010;
localparam FN_CRC = 3'b011;
localparam FN_B2G = 3'b100;
localparam FN_G2B = 3'b101;

// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
wire           fn_enc;
wire           fn_dec;
wire           fn_crc;
wire           fn_b2g;
wire           fn_g2b;

wire    [15:0] load_w;

wire    [63:0] key_in_r_out;
reg     [63:0] key_in_w;
wire    [47:0] k_w;

reg     [31:0] R_w;
wire    [31:0] R_r_out;
reg     [31:0] L_w;
wire    [31:0] L_r_out;

reg    [127:0] iot_in_buff;
reg    [127:0] iot_in_buff_w;

reg     [63:0] init_p_in;
wire    [63:0] init_p_out;
reg     [31:0] f_p_in;
wire    [31:0] f_p_out;
reg     [63:0] final_p_in;
wire    [63:0] final_p_out;
reg     [31:0] expan_in;
wire    [47:0] expan_out;

reg      [5:0] S0_in_w;
reg      [5:0] S1_in_w;
reg      [5:0] S2_in_w;
reg      [5:0] S3_in_w;
reg      [5:0] S4_in_w;
reg      [5:0] S5_in_w;
reg      [5:0] S6_in_w;
reg      [5:0] S7_in_w;
wire     [3:0] S0_out_w;
wire     [3:0] S1_out_w;
wire     [3:0] S2_out_w;
wire     [3:0] S3_out_w;
wire     [3:0] S4_out_w;
wire     [3:0] S5_out_w;
wire     [3:0] S6_out_w;
wire     [3:0] S7_out_w;

reg      [3:0] counter_state;

wire           data_converter_enable;

wire           iot_conver_buff_r_out;
reg            iot_conver_buff_w;
wire     [6:0] iot_conver_sel_sub_w;
wire     [6:0] iot_conver_sel_w;

reg    [127:0] iot_out_r;
reg    [127:0] iot_out_w;
reg            busy_r;
reg            valid_r;
reg            valid_w;
reg            valid_des_buff_r;
reg            valid_des_buff_w;

reg      [2:0] crc_xor_ina_w[0:7];
reg      [2:0] crc_xor_inb_w[0:7];
wire     [2:0] crc_xor_out_w[0:7];

reg      [2:0] crc_xor_last_ina_w[0:2];
reg      [2:0] crc_xor_last_inb_w[0:2];
wire     [2:0] crc_xor_last_out_w[0:2];

reg     [47:0] logic_xor_ina_w;
reg     [47:0] logic_xor_inb_w;
wire    [47:0] logic_xor_out_w;

reg            xor_a_w[0:7];
reg            xor_b_w[0:7];
wire           logic_xor_w[0:7];

wire    [31:0] L_R_xor_out_w;
wire    [31:0] L_R_xor_ina_w;
reg     [31:0] L_R_xor_inb_w;

// ---------------------------------------------------------------------------
// FSM Blocks
// ---------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
	if (rst) begin
		counter_state <= 4'b0000;
	end
	else begin
		counter_state <= counter_state + in_en;
	end
end

assign load_w[0]  = counter_state == 0;
assign load_w[1]  = counter_state == 1;
assign load_w[2]  = counter_state == 2;
assign load_w[3]  = counter_state == 3;
assign load_w[4]  = counter_state == 4;
assign load_w[5]  = counter_state == 5;
assign load_w[6]  = counter_state == 6;
assign load_w[7]  = counter_state == 7;
assign load_w[8]  = counter_state == 8;
assign load_w[9]  = counter_state == 9;
assign load_w[10] = counter_state == 10;
assign load_w[11] = counter_state == 11;
assign load_w[12] = counter_state == 12;
assign load_w[13] = counter_state == 13;
assign load_w[14] = counter_state == 14;
assign load_w[15] = counter_state == 15;

// ---------------------------------------------------------------------------
// Output Assignment Blocks
// ---------------------------------------------------------------------------
assign iot_out = iot_out_r;
assign busy    = busy_r;
assign valid   = valid_r;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		busy_r <= 1'b1;
	end
	else begin
		busy_r <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		valid_r <= 1'b0;
	end
	else begin
		valid_r <= valid_w;
	end
end

always @(*) begin
	case(fn_sel)
		FN_ENC: begin
			valid_w = valid_des_buff_r & load_w[15];
		end
		FN_DEC: begin
			valid_w = valid_des_buff_r & load_w[15];
		end
		FN_CRC: begin
			valid_w = valid_des_buff_r & load_w[0];
		end
		FN_B2G: begin
			valid_w = valid_des_buff_r & load_w[0];
		end
		FN_G2B: begin
			valid_w = valid_des_buff_r & load_w[0];
		end
		default: begin
			valid_w = 1'b0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		valid_des_buff_r <= 1'b0;
	end
	else begin
		valid_des_buff_r <= valid_des_buff_w;
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[15]) begin
		valid_des_buff_w = 1'b1;
	end
	else if((fn_crc || fn_b2g || fn_g2b) && load_w[1]) begin
		valid_des_buff_w = 1'b1;
	end
	else begin
		valid_des_buff_w = valid_des_buff_r;
	end
end

always @(posedge clk) begin
	iot_out_r <= iot_out_w;
end

always @(*) begin
	if(fn_dec || fn_enc) begin
		if(load_w[15]) begin
			iot_out_w = {key_in_w ,final_p_out};
		end
		else begin
			iot_out_w = {key_in_w ,L_w ,R_w};
		end
	end
	else if(fn_crc && load_w[0]) begin
		iot_out_w = {125'd0 ,crc_xor_last_out_w[0]};
	end
	else if(fn_b2g || fn_g2b) begin
		case(load_w)
			16'b1000_0000_0000_0000: begin
				iot_out_w = {iot_out_r[127:16] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[7:0]};
			end
			16'b0100_0000_0000_0000: begin
				iot_out_w = {iot_out_r[127:24] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[15:0]};
			end
			16'b0010_0000_0000_0000: begin
				iot_out_w = {iot_out_r[127:32] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[23:0]};
			end
			16'b0001_0000_0000_0000: begin
				iot_out_w = {iot_out_r[127:40] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[31:0]};
			end
			16'b0000_1000_0000_0000: begin
				iot_out_w = {iot_out_r[127:48] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[39:0]};
			end
			16'b0000_0100_0000_0000: begin
				iot_out_w = {iot_out_r[127:56] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[47:0]};
			end
			16'b0000_0010_0000_0000: begin
				iot_out_w = {iot_out_r[127:64] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[55:0]};
			end
			16'b0000_0001_0000_0000: begin
				iot_out_w = {iot_out_r[127:72] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[63:0]};
			end
			16'b0000_0000_1000_0000: begin
				iot_out_w = {iot_out_r[127:80] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[71:0]};
			end
			16'b0000_0000_0100_0000: begin
				iot_out_w = {iot_out_r[127:88] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[79:0]};
			end
			16'b0000_0000_0010_0000: begin
				iot_out_w = {iot_out_r[127:96] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							   ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							   ,logic_xor_w[0] ,iot_out_r[87:0]};
			end
			16'b0000_0000_0001_0000: begin
				iot_out_w = {iot_out_r[127:104] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							    ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							    ,logic_xor_w[0] ,iot_out_r[95:0]};
			end
			16'b0000_0000_0000_1000: begin
				iot_out_w = {iot_out_r[127:112] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							    ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							    ,logic_xor_w[0] ,iot_out_r[103:0]};
			end
			16'b0000_0000_0000_0100: begin
				iot_out_w = {iot_out_r[127:120] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							    ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							    ,logic_xor_w[0] ,iot_out_r[111:0]};
			end
			16'b0000_0000_0000_0010: begin
				iot_out_w = {iot_in_buff[7] ,logic_xor_w[6] ,logic_xor_w[5]
							,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2]
							,logic_xor_w[1] ,logic_xor_w[0] ,iot_out_r[119:0]};
			end
			16'b0000_0000_0000_0001: begin
				iot_out_w = {iot_out_r[127:8] ,logic_xor_w[7] ,logic_xor_w[6] ,logic_xor_w[5]
							  ,logic_xor_w[4] ,logic_xor_w[3] ,logic_xor_w[2] ,logic_xor_w[1]
							  ,logic_xor_w[0]};
			end
			default: begin
				iot_out_w = 128'd0;
			end
		endcase
	end
	else begin
		iot_out_w = iot_out_r;
	end
end

// ---------------------------------------------------------------------------
// Input Buffer Blocks
// ---------------------------------------------------------------------------
assign fn_enc = (fn_sel == FN_ENC);
assign fn_dec = (fn_sel == FN_DEC);
assign fn_crc = (fn_sel == FN_CRC);
assign fn_b2g = (fn_sel == FN_B2G);
assign fn_g2b = (fn_sel == FN_G2B);

always @(posedge clk) begin
	iot_in_buff <= iot_in_buff_w;
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[0]) begin
		iot_in_buff_w[127:120] = iot_in;
	end
	else begin
		iot_in_buff_w[127:120] = iot_in_buff[127:120];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[1]) begin
		iot_in_buff_w[119:112] = iot_in;
	end
	else begin
		iot_in_buff_w[119:112] = iot_in_buff[119:112];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[2]) begin
		iot_in_buff_w[111:104] = iot_in;
	end
	else begin
		iot_in_buff_w[111:104] = iot_in_buff[111:104];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[3]) begin
		iot_in_buff_w[103:96] = iot_in;
	end
	else begin
		iot_in_buff_w[103:96] = iot_in_buff[103:96];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[4]) begin
		iot_in_buff_w[95:88] = iot_in;
	end
	else begin
		iot_in_buff_w[95:88] = iot_in_buff[95:88];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[5]) begin
		iot_in_buff_w[87:80] = iot_in;
	end
	else begin
		iot_in_buff_w[87:80] = iot_in_buff[87:80];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[6]) begin
		iot_in_buff_w[79:72] = iot_in;
	end
	else begin
		iot_in_buff_w[79:72] = iot_in_buff[79:72];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[7]) begin
		iot_in_buff_w[71:64] = iot_in;
	end
	else begin
		iot_in_buff_w[71:64] = iot_in_buff[71:64];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[8]) begin
		iot_in_buff_w[63:56] = iot_in;
	end
	else begin
		iot_in_buff_w[63:56] = iot_in_buff[63:56];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[9]) begin
		iot_in_buff_w[55:48] = iot_in;
	end
	else begin
		iot_in_buff_w[55:48] = iot_in_buff[55:48];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[10]) begin
		iot_in_buff_w[47:40] = iot_in;
	end
	else begin
		iot_in_buff_w[47:40] = iot_in_buff[47:40];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[11]) begin
		iot_in_buff_w[39:32] = iot_in;
	end
	else begin
		iot_in_buff_w[39:32] = iot_in_buff[39:32];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[12]) begin
		iot_in_buff_w[31:24] = iot_in;
	end
	else begin
		iot_in_buff_w[31:24] = iot_in_buff[31:24];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[13]) begin
		iot_in_buff_w[23:16] = iot_in;
	end
	else begin
		iot_in_buff_w[23:16] = iot_in_buff[23:16];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[14]) begin
		iot_in_buff_w[15:8] = iot_in;
	end
	else if(fn_crc) begin
		iot_in_buff_w[15:8] = {5'b0_0000 ,crc_xor_out_w[0]};
	end
	else if(data_converter_enable) begin
		iot_in_buff_w[15:8] = {7'b0_0000 ,iot_conver_buff_w};
	end
	else begin
		iot_in_buff_w[15:8] = iot_in_buff[15:8];
	end
end

always @(*) begin
	if((fn_dec || fn_enc) && load_w[15]) begin
		iot_in_buff_w[7:0] = iot_in;
	end
	else if(data_converter_enable) begin
		iot_in_buff_w[7:0] = iot_in;
	end
	else if(fn_crc) begin
		iot_in_buff_w[7:0] = iot_in;
	end
	else begin
		iot_in_buff_w[7:0] = iot_in_buff[7:0];
	end
end

// ---------------------------------------------------------------------------
// XOR Blocks
// ---------------------------------------------------------------------------
assign logic_xor_out_w = logic_xor_ina_w ^ logic_xor_inb_w;

always @(*) begin
	if(fn_enc || fn_dec) begin
		logic_xor_ina_w = expan_out;
	end
	else if(fn_crc) begin
		logic_xor_ina_w = {15'd0 ,crc_xor_last_ina_w[2] ,crc_xor_last_ina_w[1] ,crc_xor_last_ina_w[0]
								 ,crc_xor_ina_w[7] ,crc_xor_ina_w[6] ,crc_xor_ina_w[5] ,crc_xor_ina_w[4]
								 ,crc_xor_ina_w[3] ,crc_xor_ina_w[2] ,crc_xor_ina_w[1] ,crc_xor_ina_w[0]};
	end
	else if(data_converter_enable) begin
		logic_xor_ina_w = {40'd0 ,xor_a_w[7] ,xor_a_w[6] ,xor_a_w[5] ,xor_a_w[4]
								 ,xor_a_w[3] ,xor_a_w[2] ,xor_a_w[1] ,xor_a_w[0]};
	end
	else begin
		logic_xor_ina_w = 48'd0;
	end
end

always @(*) begin
	if(fn_enc || fn_dec) begin
		logic_xor_inb_w = k_w;
	end
	else if(fn_crc) begin
		logic_xor_inb_w = {15'd0 ,crc_xor_last_inb_w[2] ,crc_xor_last_inb_w[1] ,crc_xor_last_inb_w[0]
								 ,crc_xor_inb_w[7] ,crc_xor_inb_w[6] ,crc_xor_inb_w[5] ,crc_xor_inb_w[4]
								 ,crc_xor_inb_w[3] ,crc_xor_inb_w[2] ,crc_xor_inb_w[1] ,crc_xor_inb_w[0]};
	end
	else if(data_converter_enable) begin
		logic_xor_inb_w = {40'd0 ,xor_b_w[7] ,xor_b_w[6] ,xor_b_w[5] ,xor_b_w[4]
								 ,xor_b_w[3] ,xor_b_w[2] ,xor_b_w[1] ,xor_b_w[0]};
	end
	else begin
		logic_xor_inb_w = 48'd0;
	end
end

// ---------------------------------------------------------------------------
// DES Blocks
// ---------------------------------------------------------------------------
always @(*) begin
	if((fn_dec || fn_enc) && load_w[0]) begin
		init_p_in = iot_in_buff;
	end
	else begin
		init_p_in = 64'd0;
	end
end

assign init_p_out = {init_p_in[6]  ,init_p_in[14] ,init_p_in[22] ,init_p_in[30]
					,init_p_in[38] ,init_p_in[46] ,init_p_in[54] ,init_p_in[62]
					,init_p_in[4]  ,init_p_in[12] ,init_p_in[20] ,init_p_in[28]
					,init_p_in[36] ,init_p_in[44] ,init_p_in[52] ,init_p_in[60]
					,init_p_in[2]  ,init_p_in[10] ,init_p_in[18] ,init_p_in[26]
					,init_p_in[34] ,init_p_in[42] ,init_p_in[50] ,init_p_in[58]
					,init_p_in[0]  ,init_p_in[8]  ,init_p_in[16] ,init_p_in[24]
					,init_p_in[32] ,init_p_in[40] ,init_p_in[48] ,init_p_in[56]
					,init_p_in[7]  ,init_p_in[15] ,init_p_in[23] ,init_p_in[31]
					,init_p_in[39] ,init_p_in[47] ,init_p_in[55] ,init_p_in[63]
					,init_p_in[5]  ,init_p_in[13] ,init_p_in[21] ,init_p_in[29]
					,init_p_in[37] ,init_p_in[45] ,init_p_in[53] ,init_p_in[61]
					,init_p_in[3]  ,init_p_in[11] ,init_p_in[19] ,init_p_in[27]
					,init_p_in[35] ,init_p_in[43] ,init_p_in[51] ,init_p_in[59]
					,init_p_in[1]  ,init_p_in[9]  ,init_p_in[17] ,init_p_in[25]
					,init_p_in[33] ,init_p_in[41] ,init_p_in[49] ,init_p_in[57]};

always @(*) begin
	if(fn_dec || fn_enc) begin
		f_p_in = {S0_out_w ,S1_out_w ,S2_out_w ,S3_out_w ,S4_out_w ,S5_out_w ,S6_out_w ,S7_out_w};
	end
	else begin
		f_p_in = 32'd0;
	end
end

assign f_p_out = {f_p_in[16] ,f_p_in[25] ,f_p_in[12] ,f_p_in[11]
				 ,f_p_in[3]  ,f_p_in[20] ,f_p_in[4]  ,f_p_in[15]
				 ,f_p_in[31] ,f_p_in[17] ,f_p_in[9]  ,f_p_in[6]
				 ,f_p_in[27] ,f_p_in[14] ,f_p_in[1]  ,f_p_in[22]
				 ,f_p_in[30] ,f_p_in[24] ,f_p_in[8]  ,f_p_in[18]
				 ,f_p_in[0]  ,f_p_in[5]  ,f_p_in[29] ,f_p_in[23]
				 ,f_p_in[13] ,f_p_in[19] ,f_p_in[2]  ,f_p_in[26]
				 ,f_p_in[10] ,f_p_in[21] ,f_p_in[28] ,f_p_in[7]};

always @(*) begin
	if((fn_dec || fn_enc) && load_w[15]) begin
		final_p_in = {L_w ,R_w};
	end
	else begin
		final_p_in = 64'd0;
	end
end

assign final_p_out = {final_p_in[24]  ,final_p_in[56] ,final_p_in[16] ,final_p_in[48]
					 ,final_p_in[8]   ,final_p_in[40] ,final_p_in[0]  ,final_p_in[32]
					 ,final_p_in[25]  ,final_p_in[57] ,final_p_in[17] ,final_p_in[49]
					 ,final_p_in[9]   ,final_p_in[41] ,final_p_in[1]  ,final_p_in[33]
					 ,final_p_in[26]  ,final_p_in[58] ,final_p_in[18] ,final_p_in[50]
					 ,final_p_in[10]  ,final_p_in[42] ,final_p_in[2]  ,final_p_in[34]
					 ,final_p_in[27]  ,final_p_in[59] ,final_p_in[19] ,final_p_in[51]
					 ,final_p_in[11]  ,final_p_in[43] ,final_p_in[3]  ,final_p_in[35]
					 ,final_p_in[28]  ,final_p_in[60] ,final_p_in[20] ,final_p_in[52]
					 ,final_p_in[12]  ,final_p_in[44] ,final_p_in[4]  ,final_p_in[36]
					 ,final_p_in[29]  ,final_p_in[61] ,final_p_in[21] ,final_p_in[53]
					 ,final_p_in[13]  ,final_p_in[45] ,final_p_in[5]  ,final_p_in[37]
					 ,final_p_in[30]  ,final_p_in[62] ,final_p_in[22] ,final_p_in[54]
					 ,final_p_in[14]  ,final_p_in[46] ,final_p_in[6]  ,final_p_in[38]
					 ,final_p_in[31]  ,final_p_in[63] ,final_p_in[23] ,final_p_in[55]
					 ,final_p_in[15]  ,final_p_in[47] ,final_p_in[7]  ,final_p_in[39]};

always @(*) begin
	if((fn_enc || fn_dec) && load_w[0]) begin
		expan_in = init_p_out[31:0];
	end
	else if(fn_enc || fn_dec) begin
		expan_in = R_r_out;
	end
	else begin
		expan_in = 32'd0;
	end
end

assign expan_out = {expan_in[0]  ,expan_in[31] ,expan_in[30] ,expan_in[29]
				   ,expan_in[28] ,expan_in[27] ,expan_in[28] ,expan_in[27]
				   ,expan_in[26] ,expan_in[25] ,expan_in[24] ,expan_in[23]
				   ,expan_in[24] ,expan_in[23] ,expan_in[22] ,expan_in[21]
				   ,expan_in[20] ,expan_in[19] ,expan_in[20] ,expan_in[19]
				   ,expan_in[18] ,expan_in[17] ,expan_in[16] ,expan_in[15]
				   ,expan_in[16] ,expan_in[15] ,expan_in[14] ,expan_in[13]
				   ,expan_in[12] ,expan_in[11] ,expan_in[12] ,expan_in[11]
				   ,expan_in[10] ,expan_in[9]  ,expan_in[8]  ,expan_in[7]
				   ,expan_in[8]  ,expan_in[7]  ,expan_in[6]  ,expan_in[5]
				   ,expan_in[4]  ,expan_in[3]  ,expan_in[4]  ,expan_in[3]
				   ,expan_in[2]  ,expan_in[1]  ,expan_in[0]  ,expan_in[31]};

assign key_in_r_out = iot_out_r[127:64];

always @(*) begin
	if((fn_enc || fn_dec) && load_w[0]) begin
		key_in_w = iot_in_buff[127:64];
	end
	else begin
		key_in_w = key_in_r_out;
	end
end

KEY u_KEY (
	.clk(clk),
	.key_in(key_in_w),
	.func({fn_dec ,fn_enc}),
	.key_sel({~load_w[0] ,(load_w[1] || load_w[8] || load_w[15])}),
	.key_out(k_w));

assign L_R_xor_out_w = L_R_xor_ina_w ^ L_R_xor_inb_w;
assign L_R_xor_ina_w = f_p_out;

always @(*) begin
	if((fn_enc || fn_dec) && load_w[0]) begin
		L_R_xor_inb_w = init_p_out[63:32];
	end
	else begin
		L_R_xor_inb_w = L_r_out;
	end
end

assign R_r_out = iot_out_r[31:0];

always @(*) begin
	if((fn_enc || fn_dec) && load_w[0]) begin
		R_w = L_R_xor_out_w;
	end
	else if((fn_enc || fn_dec) && (!load_w[15])) begin
		R_w = L_R_xor_out_w;
	end
	else begin
		R_w = R_r_out;
	end
end

assign L_r_out = iot_out_r[63:32];

always @(*) begin
	if((fn_enc || fn_dec) && load_w[0]) begin
		L_w = init_p_out[31:0];
	end
	else if((fn_enc || fn_dec) && load_w[15]) begin
		L_w = L_R_xor_out_w;
	end
	else if(fn_enc || fn_dec) begin
		L_w = R_r_out;
	end
	else begin
		L_w = L_r_out;
	end
end

always @(*) begin
	if(fn_enc || fn_dec) begin
		S0_in_w = logic_xor_out_w[47:42];
		S1_in_w = logic_xor_out_w[41:36];
		S2_in_w = logic_xor_out_w[35:30];
		S3_in_w = logic_xor_out_w[29:24];
		S4_in_w = logic_xor_out_w[23:18];
		S5_in_w = logic_xor_out_w[17:12];
		S6_in_w = logic_xor_out_w[11:6];
		S7_in_w = logic_xor_out_w[5:0];
	end
	else begin
		S0_in_w = 6'd0;
		S1_in_w = 6'd0;
		S2_in_w = 6'd0;
		S3_in_w = 6'd0;
		S4_in_w = 6'd0;
		S5_in_w = 6'd0;
		S6_in_w = 6'd0;
		S7_in_w = 6'd0;
	end
end

LUT u_LUT(
	.S0_in(S0_in_w),
	.S1_in(S1_in_w),
	.S2_in(S2_in_w),
	.S3_in(S3_in_w),
	.S4_in(S4_in_w),
	.S5_in(S5_in_w),
	.S6_in(S6_in_w),
	.S7_in(S7_in_w),
	.S0_out(S0_out_w),
	.S1_out(S1_out_w),
	.S2_out(S2_out_w),
	.S3_out(S3_out_w),
	.S4_out(S4_out_w),
	.S5_out(S5_out_w),
	.S6_out(S6_out_w),
	.S7_out(S7_out_w));

// ---------------------------------------------------------------------------
// CRC Generate Blocks
// ---------------------------------------------------------------------------
assign crc_xor_out_w[7] = logic_xor_out_w[23:21];
assign crc_xor_out_w[6] = logic_xor_out_w[20:18];
assign crc_xor_out_w[5] = logic_xor_out_w[17:15];
assign crc_xor_out_w[4] = logic_xor_out_w[14:12];
assign crc_xor_out_w[3] = logic_xor_out_w[11:9];
assign crc_xor_out_w[2] = logic_xor_out_w[8:6];
assign crc_xor_out_w[1] = logic_xor_out_w[5:3];
assign crc_xor_out_w[0] = logic_xor_out_w[2:0];

always @(*) begin
	if(load_w[1]) begin
		crc_xor_ina_w[7] = 3'b000;
		crc_xor_inb_w[7] = 3'b000;
	end
	else begin
		crc_xor_ina_w[7] = iot_in_buff[9:7];
		if(iot_in_buff[10]) begin
			crc_xor_inb_w[7] = 3'b011;
		end
		else begin
			crc_xor_inb_w[7] = 3'b000;
		end
	end
end

always @(*) begin
	crc_xor_ina_w[6] = {crc_xor_out_w[7][1:0] ,iot_in_buff[6]};
	if(crc_xor_out_w[7][2]) begin
		crc_xor_inb_w[6] = 3'b011;
	end
	else begin
		crc_xor_inb_w[6] = 3'b000;
	end
end

always @(*) begin
	crc_xor_ina_w[5] = {crc_xor_out_w[6][1:0] ,iot_in_buff[5]};
	if(crc_xor_out_w[6][2]) begin
		crc_xor_inb_w[5] = 3'b011;
	end
	else begin
		crc_xor_inb_w[5] = 3'b000;
	end
end

always @(*) begin
	if(load_w[1]) begin
		crc_xor_ina_w[4] = iot_in_buff[6:4];
		if(iot_in_buff[7]) begin
			crc_xor_inb_w[4] = 3'b011;
		end
		else begin
			crc_xor_inb_w[4] = 3'b000;
		end
	end
	else begin
		crc_xor_ina_w[4] = {crc_xor_out_w[5][1:0] ,iot_in_buff[4]};
		if(crc_xor_out_w[5][2]) begin
			crc_xor_inb_w[4] = 3'b011;
		end
		else begin
			crc_xor_inb_w[4] = 3'b000;
		end
	end
end

always @(*) begin
	crc_xor_ina_w[3] = {crc_xor_out_w[4][1:0] ,iot_in_buff[3]};
	if(crc_xor_out_w[4][2]) begin
		crc_xor_inb_w[3] = 3'b011;
	end
	else begin
		crc_xor_inb_w[3] = 3'b000;
	end
end

always @(*) begin
	crc_xor_ina_w[2] = {crc_xor_out_w[3][1:0] ,iot_in_buff[2]};
	if(crc_xor_out_w[3][2]) begin
		crc_xor_inb_w[2] = 3'b011;
	end
	else begin
		crc_xor_inb_w[2] = 3'b000;
	end
end

always @(*) begin
	crc_xor_ina_w[1] = {crc_xor_out_w[2][1:0] ,iot_in_buff[1]};
	if(crc_xor_out_w[2][2]) begin
		crc_xor_inb_w[1] = 3'b011;
	end
	else begin
		crc_xor_inb_w[1] = 3'b000;
	end
end

always @(*) begin
	crc_xor_ina_w[0] = {crc_xor_out_w[1][1:0] ,iot_in_buff[0]};
	if(crc_xor_out_w[1][2]) begin
		crc_xor_inb_w[0] = 3'b011;
	end
	else begin
		crc_xor_inb_w[0] = 3'b000;
	end
end

assign crc_xor_last_out_w[2] = logic_xor_out_w[32:30];
assign crc_xor_last_out_w[1] = logic_xor_out_w[29:27];
assign crc_xor_last_out_w[0] = logic_xor_out_w[26:24];

always @(*) begin
	if(load_w[0]) begin
		crc_xor_last_ina_w[2] = {crc_xor_out_w[0][1:0] ,1'b0};
		crc_xor_last_ina_w[1] = {crc_xor_last_out_w[2][1:0] ,1'b0};
		crc_xor_last_ina_w[0] = {crc_xor_last_out_w[1][1:0] ,1'b0};
	end
	else begin
		crc_xor_last_ina_w[2] = {3'b000};
		crc_xor_last_ina_w[1] = {3'b000};
		crc_xor_last_ina_w[0] = {3'b000};
	end
end

always @(*) begin
	if(load_w[0]) begin
		if(crc_xor_out_w[0][2]) begin
			crc_xor_last_inb_w[2] = 3'b011;
		end
		else begin
			crc_xor_last_inb_w[2] = 3'b000;
		end
	end
	else begin
		crc_xor_last_inb_w[2] = {3'b000};
	end
end

always @(*) begin
	if(load_w[0]) begin
		if(crc_xor_last_out_w[2][2]) begin
			crc_xor_last_inb_w[1] = 3'b011;
		end
		else begin
			crc_xor_last_inb_w[1] = 3'b000;
		end
	end
	else begin
		crc_xor_last_inb_w[1] = {3'b000};
	end
end

always @(*) begin
	if(load_w[0]) begin
		if(crc_xor_last_out_w[1][2]) begin
			crc_xor_last_inb_w[0] = 3'b011;
		end
		else begin
			crc_xor_last_inb_w[0] = 3'b000;
		end
	end
	else begin
		crc_xor_last_inb_w[0] = {3'b000};
	end
end

// ---------------------------------------------------------------------------
// Data Converter Blocks
// ---------------------------------------------------------------------------
assign data_converter_enable = fn_b2g | fn_g2b;

assign logic_xor_w[7] = logic_xor_out_w[7];
assign logic_xor_w[6] = logic_xor_out_w[6];
assign logic_xor_w[5] = logic_xor_out_w[5];
assign logic_xor_w[4] = logic_xor_out_w[4];
assign logic_xor_w[3] = logic_xor_out_w[3];
assign logic_xor_w[2] = logic_xor_out_w[2];
assign logic_xor_w[1] = logic_xor_out_w[1];
assign logic_xor_w[0] = logic_xor_out_w[0];

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[7] = iot_conver_buff_r_out;
		xor_b_w[7] = iot_in_buff[7];
	end
	else begin
		xor_a_w[7] = iot_conver_buff_r_out;
		xor_b_w[7] = iot_in_buff[7];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[6] = iot_in_buff[7];
		xor_b_w[6] = iot_in_buff[6];
	end
	else begin
		if(load_w[1]) begin
			xor_a_w[6] = iot_in_buff[7];
		end
		else begin
			xor_a_w[6] = logic_xor_w[7];
		end
		xor_b_w[6] = iot_in_buff[6];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[5] = iot_in_buff[6];
		xor_b_w[5] = iot_in_buff[5];
	end
	else begin
		xor_a_w[5] = logic_xor_w[6];
		xor_b_w[5] = iot_in_buff[5];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[4] = iot_in_buff[5];
		xor_b_w[4] = iot_in_buff[4];
	end
	else begin
		xor_a_w[4] = logic_xor_w[5];
		xor_b_w[4] = iot_in_buff[4];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[3] = iot_in_buff[4];
		xor_b_w[3] = iot_in_buff[3];
	end
	else begin
		xor_a_w[3] = logic_xor_w[4];
		xor_b_w[3] = iot_in_buff[3];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[2] = iot_in_buff[3];
		xor_b_w[2] = iot_in_buff[2];
	end
	else begin
		xor_a_w[2] = logic_xor_w[3];
		xor_b_w[2] = iot_in_buff[2];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[1] = iot_in_buff[2];
		xor_b_w[1] = iot_in_buff[1];
	end
	else begin
		xor_a_w[1] = logic_xor_w[2];
		xor_b_w[1] = iot_in_buff[1];
	end
end

always @(*) begin
	if(fn_b2g) begin
		xor_a_w[0] = iot_in_buff[1];
		xor_b_w[0] = iot_in_buff[0];
	end
	else begin
		xor_a_w[0] = logic_xor_w[1];
		xor_b_w[0] = iot_in_buff[0];
	end
end

assign iot_conver_buff_r_out = iot_in_buff[8];

always @(*) begin
	if(fn_b2g) begin
		iot_conver_buff_w = iot_in_buff[0];
	end
	else if(fn_g2b) begin
		iot_conver_buff_w = logic_xor_w[0];
	end
	else begin
		iot_conver_buff_w = iot_conver_buff_r_out;
	end
end

endmodule
