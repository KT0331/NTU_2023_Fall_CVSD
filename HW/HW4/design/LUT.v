module LUT(
input   [5:0] S0_in,
input   [5:0] S1_in,
input   [5:0] S2_in,
input   [5:0] S3_in,
input   [5:0] S4_in,
input   [5:0] S5_in,
input   [5:0] S6_in,
input   [5:0] S7_in,
output  [3:0] S0_out,
output  [3:0] S1_out,
output  [3:0] S2_out,
output  [3:0] S3_out,
output  [3:0] S4_out,
output  [3:0] S5_out,
output  [3:0] S6_out,
output  [3:0] S7_out);

reg     [3:0] S0_out_r;
reg     [3:0] S1_out_r;
reg     [3:0] S2_out_r;
reg     [3:0] S3_out_r;
reg     [3:0] S4_out_r;
reg     [3:0] S5_out_r;
reg     [3:0] S6_out_r;
reg     [3:0] S7_out_r;

assign S0_out = S0_out_r;
assign S1_out = S1_out_r;
assign S2_out = S2_out_r;
assign S3_out = S3_out_r;
assign S4_out = S4_out_r;
assign S5_out = S5_out_r;
assign S6_out = S6_out_r;
assign S7_out = S7_out_r;

always @(*) begin
	case(S0_in[4:1])
		0: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 14;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 0;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 4;
			end
			else begin
				S0_out_r = 15;
			end
		end
		1: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 4;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 15;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 1;
			end
			else begin
				S0_out_r = 12;
			end
		end
		2: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 13;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 7;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 14;
			end
			else begin
				S0_out_r = 8;
			end
		end
		3: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 1;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 4;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 8;
			end
			else begin
				S0_out_r = 2;
			end
		end
		4: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 2;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 14;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 13;
			end
			else begin
				S0_out_r = 4;
			end
		end
		5: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 15;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 2;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 6;
			end
			else begin
				S0_out_r = 9;
			end
		end
		6: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 11;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 13;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 2;
			end
			else begin
				S0_out_r = 1;
			end
		end
		7: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 8;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 1;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 11;
			end
			else begin
				S0_out_r = 7;
			end
		end
		8: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 3;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 10;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 15;
			end
			else begin
				S0_out_r = 5;
			end
		end
		9: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 10;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 6;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 12;
			end
			else begin
				S0_out_r = 11;
			end
		end
		10: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 6;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 12;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 9;
			end
			else begin
				S0_out_r = 3;
			end
		end
		11: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 12;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 11;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 7;
			end
			else begin
				S0_out_r = 14;
			end
		end
		12: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 5;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 9;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 3;
			end
			else begin
				S0_out_r = 10;
			end
		end
		13: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 9;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 5;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 10;
			end
			else begin
				S0_out_r = 0;
			end
		end
		14: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 0;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 3;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 5;
			end
			else begin
				S0_out_r = 6;
			end
		end
		15: begin
			if({S0_in[5] ,S0_in[0]} == 2'b00) begin
				S0_out_r = 7;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b01) begin
				S0_out_r = 8;
			end
			else if({S0_in[5] ,S0_in[0]} == 2'b10) begin
				S0_out_r = 0;
			end
			else begin
				S0_out_r = 13;
			end
		end
		default: begin
			S0_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S1_in[4:1])
		0: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 15;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 3;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 0;
			end
			else begin
				S1_out_r = 13;
			end
		end
		1: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 1;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 13;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 14;
			end
			else begin
				S1_out_r = 8;
			end
		end
		2: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 8;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 4;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 7;
			end
			else begin
				S1_out_r = 10;
			end
		end
		3: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 14;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 7;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 11;
			end
			else begin
				S1_out_r = 1;
			end
		end
		4: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 6;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 15;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 10;
			end
			else begin
				S1_out_r = 3;
			end
		end
		5: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 11;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 2;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 4;
			end
			else begin
				S1_out_r = 15;
			end
		end
		6: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 3;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 8;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 13;
			end
			else begin
				S1_out_r = 4;
			end
		end
		7: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 4;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 14;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 1;
			end
			else begin
				S1_out_r = 2;
			end
		end
		8: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 9;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 12;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 5;
			end
			else begin
				S1_out_r = 11;
			end
		end
		9: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 7;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 0;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 8;
			end
			else begin
				S1_out_r = 6;
			end
		end
		10: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 2;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 1;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 12;
			end
			else begin
				S1_out_r = 7;
			end
		end
		11: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 13;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 10;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 6;
			end
			else begin
				S1_out_r = 12;
			end
		end
		12: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 12;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 6;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 9;
			end
			else begin
				S1_out_r = 0;
			end
		end
		13: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 0;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 9;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 3;
			end
			else begin
				S1_out_r = 5;
			end
		end
		14: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 5;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 11;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 2;
			end
			else begin
				S1_out_r = 14;
			end
		end
		15: begin
			if({S1_in[5] ,S1_in[0]} == 2'b00) begin
				S1_out_r = 10;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b01) begin
				S1_out_r = 5;
			end
			else if({S1_in[5] ,S1_in[0]} == 2'b10) begin
				S1_out_r = 15;
			end
			else begin
				S1_out_r = 9;
			end
		end
		default: begin
			S1_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S2_in[4:1])
		0: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 10;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 13;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 13;
			end
			else begin
				S2_out_r = 1;
			end
		end
		1: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 0;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 7;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 6;
			end
			else begin
				S2_out_r = 10;
			end
		end
		2: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 9;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 0;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 4;
			end
			else begin
				S2_out_r = 13;
			end
		end
		3: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 14;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 9;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 9;
			end
			else begin
				S2_out_r = 0;
			end
		end
		4: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 6;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 3;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 8;
			end
			else begin
				S2_out_r = 6;
			end
		end
		5: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 3;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 4;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 15;
			end
			else begin
				S2_out_r = 9;
			end
		end
		6: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 15;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 6;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 3;
			end
			else begin
				S2_out_r = 8;
			end
		end
		7: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 5;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 10;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 0;
			end
			else begin
				S2_out_r = 7;
			end
		end
		8: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 1;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 2;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 11;
			end
			else begin
				S2_out_r = 4;
			end
		end
		9: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 13;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 8;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 1;
			end
			else begin
				S2_out_r = 15;
			end
		end
		10: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 12;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 5;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 2;
			end
			else begin
				S2_out_r = 14;
			end
		end
		11: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 7;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 14;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 12;
			end
			else begin
				S2_out_r = 3;
			end
		end
		12: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 11;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 12;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 5;
			end
			else begin
				S2_out_r = 11;
			end
		end
		13: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 4;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 11;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 10;
			end
			else begin
				S2_out_r = 5;
			end
		end
		14: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 2;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 15;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 14;
			end
			else begin
				S2_out_r = 2;
			end
		end
		15: begin
			if({S2_in[5] ,S2_in[0]} == 2'b00) begin
				S2_out_r = 8;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b01) begin
				S2_out_r = 1;
			end
			else if({S2_in[5] ,S2_in[0]} == 2'b10) begin
				S2_out_r = 7;
			end
			else begin
				S2_out_r = 12;
			end
		end
		default: begin
			S2_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S3_in[4:1])
		0: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 7;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 13;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 10;
			end
			else begin
				S3_out_r = 3;
			end
		end
		1: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 13;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 8;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 6;
			end
			else begin
				S3_out_r = 15;
			end
		end
		2: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 14;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 11;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 9;
			end
			else begin
				S3_out_r = 0;
			end
		end
		3: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 3;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 5;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 0;
			end
			else begin
				S3_out_r = 6;
			end
		end
		4: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 0;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 6;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 12;
			end
			else begin
				S3_out_r = 10;
			end
		end
		5: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 6;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 15;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 11;
			end
			else begin
				S3_out_r = 1;
			end
		end
		6: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 9;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 0;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 7;
			end
			else begin
				S3_out_r = 13;
			end
		end
		7: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 10;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 3;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 13;
			end
			else begin
				S3_out_r = 8;
			end
		end
		8: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 1;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 4;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 15;
			end
			else begin
				S3_out_r = 9;
			end
		end
		9: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 2;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 7;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 1;
			end
			else begin
				S3_out_r = 4;
			end
		end
		10: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 8;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 2;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 3;
			end
			else begin
				S3_out_r = 5;
			end
		end
		11: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 5;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 12;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 14;
			end
			else begin
				S3_out_r = 11;
			end
		end
		12: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 11;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 1;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 5;
			end
			else begin
				S3_out_r = 12;
			end
		end
		13: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 12;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 10;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 2;
			end
			else begin
				S3_out_r = 7;
			end
		end
		14: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 4;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 14;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 8;
			end
			else begin
				S3_out_r = 2;
			end
		end
		15: begin
			if({S3_in[5] ,S3_in[0]} == 2'b00) begin
				S3_out_r = 15;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b01) begin
				S3_out_r = 9;
			end
			else if({S3_in[5] ,S3_in[0]} == 2'b10) begin
				S3_out_r = 4;
			end
			else begin
				S3_out_r = 14;
			end
		end
		default: begin
			S3_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S4_in[4:1])
		0: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 2;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 14;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 4;
			end
			else begin
				S4_out_r = 11;
			end
		end
		1: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 12;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 11;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 2;
			end
			else begin
				S4_out_r = 8;
			end
		end
		2: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 4;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 2;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 1;
			end
			else begin
				S4_out_r = 12;
			end
		end
		3: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 1;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 12;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 11;
			end
			else begin
				S4_out_r = 7;
			end
		end
		4: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 7;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 4;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 10;
			end
			else begin
				S4_out_r = 1;
			end
		end
		5: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 10;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 7;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 13;
			end
			else begin
				S4_out_r = 14;
			end
		end
		6: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 11;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 13;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 7;
			end
			else begin
				S4_out_r = 2;
			end
		end
		7: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 6;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 1;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 8;
			end
			else begin
				S4_out_r = 13;
			end
		end
		8: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 8;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 5;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 15;
			end
			else begin
				S4_out_r = 6;
			end
		end
		9: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 5;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 0;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 9;
			end
			else begin
				S4_out_r = 15;
			end
		end
		10: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 3;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 15;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 12;
			end
			else begin
				S4_out_r = 0;
			end
		end
		11: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 15;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 10;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 5;
			end
			else begin
				S4_out_r = 9;
			end
		end
		12: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 13;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 3;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 6;
			end
			else begin
				S4_out_r = 10;
			end
		end
		13: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 0;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 9;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 3;
			end
			else begin
				S4_out_r = 4;
			end
		end
		14: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 14;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 8;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 0;
			end
			else begin
				S4_out_r = 5;
			end
		end
		15: begin
			if({S4_in[5] ,S4_in[0]} == 2'b00) begin
				S4_out_r = 9;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b01) begin
				S4_out_r = 6;
			end
			else if({S4_in[5] ,S4_in[0]} == 2'b10) begin
				S4_out_r = 14;
			end
			else begin
				S4_out_r = 3;
			end
		end
		default: begin
			S4_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S5_in[4:1])
		0: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 12;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 10;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 9;
			end
			else begin
				S5_out_r = 4;
			end
		end
		1: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 1;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 15;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 14;
			end
			else begin
				S5_out_r = 3;
			end
		end
		2: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 10;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 4;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 15;
			end
			else begin
				S5_out_r = 2;
			end
		end
		3: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 15;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 2;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 5;
			end
			else begin
				S5_out_r = 12;
			end
		end
		4: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 9;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 7;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 2;
			end
			else begin
				S5_out_r = 9;
			end
		end
		5: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 2;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 12;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 8;
			end
			else begin
				S5_out_r = 5;
			end
		end
		6: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 6;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 9;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 12;
			end
			else begin
				S5_out_r = 15;
			end
		end
		7: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 8;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 5;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 3;
			end
			else begin
				S5_out_r = 10;
			end
		end
		8: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 0;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 6;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 7;
			end
			else begin
				S5_out_r = 11;
			end
		end
		9: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 13;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 1;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 0;
			end
			else begin
				S5_out_r = 14;
			end
		end
		10: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 3;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 13;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 4;
			end
			else begin
				S5_out_r = 1;
			end
		end
		11: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 4;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 14;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 10;
			end
			else begin
				S5_out_r = 7;
			end
		end
		12: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 14;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 0;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 1;
			end
			else begin
				S5_out_r = 6;
			end
		end
		13: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 7;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 11;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 13;
			end
			else begin
				S5_out_r = 0;
			end
		end
		14: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 5;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 3;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 11;
			end
			else begin
				S5_out_r = 8;
			end
		end
		15: begin
			if({S5_in[5] ,S5_in[0]} == 2'b00) begin
				S5_out_r = 11;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b01) begin
				S5_out_r = 8;
			end
			else if({S5_in[5] ,S5_in[0]} == 2'b10) begin
				S5_out_r = 6;
			end
			else begin
				S5_out_r = 13;
			end
		end
		default: begin
			S5_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S6_in[4:1])
		0: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 4;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 13;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 1;
			end
			else begin
				S6_out_r = 6;
			end
		end
		1: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 11;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 0;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 4;
			end
			else begin
				S6_out_r = 11;
			end
		end
		2: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 2;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 11;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 11;
			end
			else begin
				S6_out_r = 13;
			end
		end
		3: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 14;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 7;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 13;
			end
			else begin
				S6_out_r = 8;
			end
		end
		4: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 15;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 4;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 12;
			end
			else begin
				S6_out_r = 1;
			end
		end
		5: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 0;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 9;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 3;
			end
			else begin
				S6_out_r = 4;
			end
		end
		6: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 8;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 1;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 7;
			end
			else begin
				S6_out_r = 10;
			end
		end
		7: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 13;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 10;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 14;
			end
			else begin
				S6_out_r = 7;
			end
		end
		8: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 3;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 14;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 10;
			end
			else begin
				S6_out_r = 9;
			end
		end
		9: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 12;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 3;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 15;
			end
			else begin
				S6_out_r = 5;
			end
		end
		10: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 9;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 5;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 6;
			end
			else begin
				S6_out_r = 0;
			end
		end
		11: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 7;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 12;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 8;
			end
			else begin
				S6_out_r = 15;
			end
		end
		12: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 5;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 2;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 0;
			end
			else begin
				S6_out_r = 14;
			end
		end
		13: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 10;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 15;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 5;
			end
			else begin
				S6_out_r = 2;
			end
		end
		14: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 6;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 8;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 9;
			end
			else begin
				S6_out_r = 3;
			end
		end
		15: begin
			if({S6_in[5] ,S6_in[0]} == 2'b00) begin
				S6_out_r = 1;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b01) begin
				S6_out_r = 6;
			end
			else if({S6_in[5] ,S6_in[0]} == 2'b10) begin
				S6_out_r = 2;
			end
			else begin
				S6_out_r = 12;
			end
		end
		default: begin
			S6_out_r = 0;
		end
	endcase
end

always @(*) begin
	case(S7_in[4:1])
		0: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 13;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 1;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 7;
			end
			else begin
				S7_out_r = 2;
			end
		end
		1: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 2;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 15;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 11;
			end
			else begin
				S7_out_r = 1;
			end
		end
		2: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 8;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 13;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 4;
			end
			else begin
				S7_out_r = 14;
			end
		end
		3: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 4;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 8;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 1;
			end
			else begin
				S7_out_r = 7;
			end
		end
		4: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 6;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 10;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 9;
			end
			else begin
				S7_out_r = 4;
			end
		end
		5: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 15;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 3;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 12;
			end
			else begin
				S7_out_r = 10;
			end
		end
		6: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 11;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 7;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 14;
			end
			else begin
				S7_out_r = 8;
			end
		end
		7: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 1;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 4;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 2;
			end
			else begin
				S7_out_r = 13;
			end
		end
		8: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 10;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 12;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 0;
			end
			else begin
				S7_out_r = 15;
			end
		end
		9: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 9;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 5;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 6;
			end
			else begin
				S7_out_r = 12;
			end
		end
		10: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 3;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 6;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 10;
			end
			else begin
				S7_out_r = 9;
			end
		end
		11: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 14;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 11;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 13;
			end
			else begin
				S7_out_r = 0;
			end
		end
		12: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 5;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 0;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 15;
			end
			else begin
				S7_out_r = 3;
			end
		end
		13: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 0;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 14;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 3;
			end
			else begin
				S7_out_r = 5;
			end
		end
		14: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 12;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 9;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 5;
			end
			else begin
				S7_out_r = 6;
			end
		end
		15: begin
			if({S7_in[5] ,S7_in[0]} == 2'b00) begin
				S7_out_r = 7;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b01) begin
				S7_out_r = 2;
			end
			else if({S7_in[5] ,S7_in[0]} == 2'b10) begin
				S7_out_r = 8;
			end
			else begin
				S7_out_r = 11;
			end
		end
		default: begin
			S7_out_r = 0;
		end
	endcase
end

endmodule