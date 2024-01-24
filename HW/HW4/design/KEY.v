module KEY(
input          clk,
input   [63:0] key_in,
input    [1:0] func,
input    [1:0] key_sel,
output  [47:0] key_out);

wire    [55:0] cip_key;
wire    [55:0] key_in_shift;
wire    [55:0] key_shift_l_1;
wire    [55:0] key_shift_l_2;
wire    [55:0] key_shift_r_1;
wire    [55:0] key_shift_r_2;
reg     [55:0] key_pc2_in;
wire    [47:0] key;
reg     [55:0] key_buff;

assign key_out = key;

assign cip_key = {key_in[7]  ,key_in[15] ,key_in[23] ,key_in[31]
				 ,key_in[39] ,key_in[47] ,key_in[55] ,key_in[63]
				 ,key_in[6]  ,key_in[14] ,key_in[22] ,key_in[30]
				 ,key_in[38] ,key_in[46] ,key_in[54] ,key_in[62]
				 ,key_in[5]  ,key_in[13] ,key_in[21] ,key_in[29]
				 ,key_in[37] ,key_in[45] ,key_in[53] ,key_in[61]
				 ,key_in[4]  ,key_in[12] ,key_in[20] ,key_in[28]
				 ,key_in[1]  ,key_in[9]  ,key_in[17] ,key_in[25]
				 ,key_in[33] ,key_in[41] ,key_in[49] ,key_in[57]
				 ,key_in[2]  ,key_in[10] ,key_in[18] ,key_in[26]
				 ,key_in[34] ,key_in[42] ,key_in[50] ,key_in[58]
				 ,key_in[3]  ,key_in[11] ,key_in[19] ,key_in[27]
				 ,key_in[35] ,key_in[43] ,key_in[51] ,key_in[59]
				 ,key_in[36] ,key_in[44] ,key_in[52] ,key_in[60]};

assign key_in_shift = {cip_key[54:28] ,cip_key[55]
					  ,cip_key[26:0]  ,cip_key[27]};

assign key_shift_l_1 = {key_buff[54:28] ,key_buff[55]
					   ,key_buff[26:0]  ,key_buff[27]};

assign key_shift_l_2 = {key_buff[53:28] ,key_buff[55:54]
					   ,key_buff[25:0]  ,key_buff[27:26]};

assign key_shift_r_1 = {key_buff[28] ,key_buff[55:29]
					   ,key_buff[0]  ,key_buff[27:1]};

assign key_shift_r_2 = {key_buff[29:28] ,key_buff[55:30]
					   ,key_buff[1:0]   ,key_buff[27:2]};

always @(posedge clk) begin
	key_buff <= key_pc2_in;
end

always @(*) begin
	if(func[0]) begin
		if(key_sel == 2'b00) begin
			key_pc2_in = key_in_shift;
		end
		else if(key_sel == 2'b11) begin
			key_pc2_in = key_shift_l_1;
		end
		else begin
			key_pc2_in = key_shift_l_2;
		end
	end
	else if(func[1]) begin
		if(key_sel == 2'b00) begin
			key_pc2_in = cip_key;
		end
		else if(key_sel == 2'b11) begin
			key_pc2_in = key_shift_r_1;
		end
		else begin
			key_pc2_in = key_shift_r_2;
		end
	end
	else begin
		key_pc2_in = key_buff;
	end
end

assign key = {key_pc2_in[42] ,key_pc2_in[39]
			 ,key_pc2_in[45] ,key_pc2_in[32]
			 ,key_pc2_in[55] ,key_pc2_in[51]
			 ,key_pc2_in[53] ,key_pc2_in[28]
			 ,key_pc2_in[41] ,key_pc2_in[50]
			 ,key_pc2_in[35] ,key_pc2_in[46]
			 ,key_pc2_in[33] ,key_pc2_in[37]
			 ,key_pc2_in[44] ,key_pc2_in[52]
			 ,key_pc2_in[30] ,key_pc2_in[48]
			 ,key_pc2_in[40] ,key_pc2_in[49]
			 ,key_pc2_in[29] ,key_pc2_in[36]
			 ,key_pc2_in[43] ,key_pc2_in[54]
			 ,key_pc2_in[15] ,key_pc2_in[4] 
			 ,key_pc2_in[25] ,key_pc2_in[19]
			 ,key_pc2_in[9]  ,key_pc2_in[1] 
			 ,key_pc2_in[26] ,key_pc2_in[16]
			 ,key_pc2_in[5]  ,key_pc2_in[11]
			 ,key_pc2_in[23] ,key_pc2_in[8]
			 ,key_pc2_in[12] ,key_pc2_in[7] 
			 ,key_pc2_in[17] ,key_pc2_in[0]
			 ,key_pc2_in[22] ,key_pc2_in[3] 
			 ,key_pc2_in[10] ,key_pc2_in[14]
			 ,key_pc2_in[6]  ,key_pc2_in[20]
			 ,key_pc2_in[27] ,key_pc2_in[24]};





endmodule