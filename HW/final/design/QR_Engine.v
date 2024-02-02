module QR_Engine (
    i_clk,
    i_rst,
    i_trig,
    i_data,
    o_rd_vld,
    o_last_data,
    o_y_hat,
    o_r
);

// IO description
input          i_clk;
input          i_rst;
input          i_trig;
input  [ 47:0] i_data;
output         o_rd_vld;
output         o_last_data;
output [159:0] o_y_hat;
output [319:0] o_r;

// ---------------------------------------------------------------------------
// FSM Parameter
// ---------------------------------------------------------------------------
parameter	IDLE 					  = 3'd0;
parameter	DATA_READY 			  	  = 3'd1;
parameter	SRAM_WRITE 			  	  = 3'd2;
parameter	OPERATION 			  	  = 3'd3;
parameter	OUTPUT_DATA 			  = 3'd4;

reg			[2:0] current_state;
reg			[2:0] next_state;

// ---------------------------------------------------------------------------
// SRAM Control
// ---------------------------------------------------------------------------
reg			sram_write;
wire		CEN;
wire		WEN;
reg	 [ 7:0]	A;
reg	 [ 7:0]	D_1;
reg	 [ 7:0]	D_2;
reg	 [ 7:0]	D_3;
reg	 [ 7:0]	D_4;
wire [ 7:0]	Q_1;
wire [ 7:0]	Q_2;
wire [ 7:0]	Q_3;
wire [ 7:0]	Q_4;
reg	 [ 7:0]	Q_1_r;
reg	 [ 7:0]	Q_2_r;
reg	 [ 7:0]	Q_3_r;
reg	 [ 7:0]	Q_4_r;
reg	 [11:0]	A_read;
reg			CEN_read;


// ---------------------------------------------------------------------------
// GG and DR
// ---------------------------------------------------------------------------
parameter INOUT_WIDRH = 16;
parameter ITER_NUM = 9;

reg 							GG_i_data_valid;
reg		[(2*INOUT_WIDRH)-1:0]	GG_i_data;
reg 							GG_i_first_in;
reg 							GG_i_last_in;
//wire							GG_i_data_valid;
//wire	[(2*INOUT_WIDRH)-1:0]	GG_i_data;
//wire							GG_i_first_in;
//wire							GG_i_last_in;
wire							GG_o_d_im2re_valid;
wire							GG_o_d_im2re;
wire							GG_o_d_re2re_valid;
wire							GG_o_d_re2re;
wire							GG_o_data_valid;
wire	[    INOUT_WIDRH-1:0]	GG_o_data;
wire							GG_o_data_1stage_valid;
wire	[    INOUT_WIDRH-1:0]	GG_o_data_1stage;  //R44 Output

reg 							GR_i_data_valid;
reg 	[(2*INOUT_WIDRH)-1:0]	GR_i_data;
wire 							GR_i_d_im2re_valid;
wire							GR_i_d_im2re;
wire							GR_i_d_re2re_valid;
wire							GR_i_d_re2re;
reg 							GR_i_first_in;
reg 							GR_i_last_in;
wire							GR_o_d_im2re_valid;
wire							GR_o_d_im2re;
wire							GR_o_d_re2re_valid;
wire							GR_o_d_re2re;
wire							GR_o_x_valid;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_im;
wire							GR_o_y_valid;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_re;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im;
wire							GR_o_data_1stage_valid;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_1stage;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_1stage;

reg 							GR_i_data_valid_2;
reg 	[(2*INOUT_WIDRH)-1:0]	GR_i_data_2;
wire 							GR_i_d_im2re_valid_2;
wire							GR_i_d_im2re_2;
wire							GR_i_d_re2re_valid_2;
wire							GR_i_d_re2re_2;
reg 							GR_i_first_in_2;
reg 							GR_i_last_in_2;
wire							GR_o_d_im2re_valid_2;
wire							GR_o_d_im2re_2;
wire							GR_o_d_re2re_valid_2;
wire							GR_o_d_re2re_2;
wire							GR_o_x_valid_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_im_2;
wire							GR_o_y_valid_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_re_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_2;
wire							GR_o_data_1stage_valid_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_1stage_2;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_1stage_2;

reg 							GR_i_data_valid_3;
reg 	[(2*INOUT_WIDRH)-1:0]	GR_i_data_3;
wire 							GR_i_d_im2re_valid_3;
wire							GR_i_d_im2re_3;
wire							GR_i_d_re2re_valid_3;
wire							GR_i_d_re2re_3;
reg 							GR_i_first_in_3;
reg 							GR_i_last_in_3;
wire							GR_o_d_im2re_valid_3;
wire							GR_o_d_im2re_3;
wire							GR_o_d_re2re_valid_3;
wire							GR_o_d_re2re_3;
wire							GR_o_x_valid_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_im_3;
wire							GR_o_y_valid_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_re_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_3;
wire							GR_o_data_1stage_valid_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_1stage_3;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_1stage_3;

reg 							GR_i_data_valid_4;
reg 	[(2*INOUT_WIDRH)-1:0]	GR_i_data_4;
wire 							GR_i_d_im2re_valid_4;
wire							GR_i_d_im2re_4;
wire							GR_i_d_re2re_valid_4;
wire							GR_i_d_re2re_4;
reg 							GR_i_first_in_4;
reg 							GR_i_last_in_4;
wire							GR_o_d_im2re_valid_4;
wire							GR_o_d_im2re_4;
wire							GR_o_d_re2re_valid_4;
wire							GR_o_d_re2re_4;
wire							GR_o_x_valid_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_im_4;
wire							GR_o_y_valid_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_re_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_4;
wire							GR_o_data_1stage_valid_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_x_re_1stage_4;
wire	[    INOUT_WIDRH-1:0]	GR_o_y_im_1stage_4;

reg		[    INOUT_WIDRH-1:0]	R22_imag_r;	//R22
reg		[    INOUT_WIDRH-1:0]	R22_imag_w;	//R22
reg		[    INOUT_WIDRH-1:0]	R33_imag_r;	//R33
reg		[    INOUT_WIDRH-1:0]	R33_imag_w;	//R33
reg		[    INOUT_WIDRH-1:0]	R44_imag_r;	//R44
reg		[    INOUT_WIDRH-1:0]	R44_imag_w;	//R44
//reg		[(2*INOUT_WIDRH)-1:0]	Y_imag_r;	//Y
//reg		[(2*INOUT_WIDRH)-1:0]	Y_imag_w;	//Y


reg		[6:0] op_counter_r;
reg		[6:0] op_counter_w;

// ---------------------------------------------------------------------------
// Output Register
// ---------------------------------------------------------------------------
reg		[159:0] o_y_hat_r;
reg		[319:0] o_r_r;

// ---------------------------------------------------------------------------
// Other Control Signal
// ---------------------------------------------------------------------------
reg				  o_last_data_r;
reg				  o_last_data_w;

reg			[7:0]sram_write_cnt_r;
reg			[7:0]sram_write_cnt_w;

reg			[3:0]RE_depth_r;
reg			[3:0]RE_depth_w;

//wire	[7:0] sram [0:255];
//assign sram = u_sram_1.mem;



assign o_rd_vld = (current_state == OUTPUT_DATA)? 1 : 0;
assign o_y_hat = o_y_hat_r;
assign o_r = o_r_r;

assign o_last_data = o_last_data_r;

//SRAM CEN && WEN signal
assign CEN = (sram_write)? 0 : CEN_read;
assign WEN = (sram_write)? 0 : 1;

assign GR_i_d_im2re_valid	 = GG_o_d_im2re_valid;
assign GR_i_d_im2re			 = GG_o_d_im2re;
assign GR_i_d_re2re_valid	 = GG_o_d_re2re_valid;
assign GR_i_d_re2re			 = GG_o_d_re2re;

assign GR_i_d_im2re_valid_2  = GR_o_d_im2re_valid;
assign GR_i_d_im2re_2		 = GR_o_d_im2re;
assign GR_i_d_re2re_valid_2  = GR_o_d_re2re_valid;
assign GR_i_d_re2re_2		 = GR_o_d_re2re;

assign GR_i_d_im2re_valid_3  = GR_o_d_im2re_valid_2;
assign GR_i_d_im2re_3		 = GR_o_d_im2re_2;
assign GR_i_d_re2re_valid_3  = GR_o_d_re2re_valid_2;
assign GR_i_d_re2re_3		 = GR_o_d_re2re_2;

assign GR_i_d_im2re_valid_4  = GR_o_d_im2re_valid_3;
assign GR_i_d_im2re_4		 = GR_o_d_im2re_3;
assign GR_i_d_re2re_valid_4  = GR_o_d_re2re_valid_3;
assign GR_i_d_re2re_4		 = GR_o_d_re2re_3;

// ---------------------------------------------------------------------------
// FSM Control
// ---------------------------------------------------------------------------

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

always @(*) begin
	if(i_rst)
		next_state = IDLE;
	else begin
		case(current_state)
			IDLE:begin
				if(RE_depth_r == 0)begin
					next_state = DATA_READY;
				end
				else begin
					next_state = OPERATION;
				end
			end
			DATA_READY:begin
				next_state = SRAM_WRITE;
			end
			SRAM_WRITE:begin
					if(sram_write_cnt_r == 8'd200)
						next_state = OPERATION;
					else
						next_state = current_state;
			end
			OPERATION:begin
				if(op_counter_r == 7'd125)
					next_state = OUTPUT_DATA;
				else
					next_state = current_state;
			end
			OUTPUT_DATA:begin
				next_state = IDLE;
			end
			default:begin
				next_state = IDLE;
			end
		endcase
	end
end

always @(posedge i_clk) begin
	o_last_data_r <= o_last_data_w;
end

always@(*)begin
	if(RE_depth_r == 9)begin
		if(op_counter_r == 34)begin
			o_last_data_w = 1;
		end
		else begin
			o_last_data_w = 0;
		end
	end
	else begin
		o_last_data_w = 0;
	end
end

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		sram_write_cnt_r <= 8'd0;
	end
	else begin
		sram_write_cnt_r <= sram_write_cnt_w;
	end
end

always@(*)begin
	if(i_trig)begin
		sram_write_cnt_w = sram_write_cnt_r + 8'd1;
	end
	else begin
		sram_write_cnt_w = 8'd0;
	end
end

// ---------------------------------------------------------------------------
// SRAM Control
// ---------------------------------------------------------------------------

always @(posedge i_clk) begin
	sram_write <= i_trig;
end

always@(posedge i_clk or posedge i_rst)begin
	if(i_rst)begin
		A <= 8'd0;
	end
	else begin
		if(i_trig)begin
			A <= sram_write_cnt_r;
		end
		else begin
			if(current_state == OPERATION  || current_state == IDLE)begin
				A <= A_read;
			end
			else begin
				A <= 8'd0;
			end
		end
	end
end

always@(*)begin
	if(current_state == OPERATION || current_state == IDLE)begin
		if(current_state == OPERATION)begin
			case(op_counter_r)
				0   : A_read = 8'd1  + 20*RE_depth_r;
				1   : A_read = 8'd2  + 20*RE_depth_r;
				2   : A_read = 8'd3  + 20*RE_depth_r;
				3   : A_read = 8'd4  + 20*RE_depth_r;
				//4   : A_read = 8'd5  + 20*RE_depth_r;
				9   : A_read = 8'd5  + 20*RE_depth_r;
				10  : A_read = 8'd6  + 20*RE_depth_r;
				11  : A_read = 8'd7  + 20*RE_depth_r;
				12  : A_read = 8'd8  + 20*RE_depth_r;
				13  : A_read = 8'd9  + 20*RE_depth_r;
				19  : A_read = 8'd10 + 20*RE_depth_r;
				20  : A_read = 8'd11 + 20*RE_depth_r;
				21  : A_read = 8'd12 + 20*RE_depth_r;
				22  : A_read = 8'd13 + 20*RE_depth_r;
				23  : A_read = 8'd14 + 20*RE_depth_r;
				29  : A_read = 8'd15 + 20*RE_depth_r;
				30  : A_read = 8'd16 + 20*RE_depth_r;
				31  : A_read = 8'd17 + 20*RE_depth_r;
				32  : A_read = 8'd18 + 20*RE_depth_r;
				33  : A_read = 8'd19 + 20*RE_depth_r;
				default : A_read = 11'd0;
			endcase
		end
		else begin
			A_read = 20*RE_depth_r;;
		end
	end
	else begin
		A_read = 11'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			0   : CEN_read = 1'd0;
			1   : CEN_read = 1'd0;
			2   : CEN_read = 1'd0;
			3   : CEN_read = 1'd0;
			4   : CEN_read = 1'd0;
			10  : CEN_read = 1'd0;
			11  : CEN_read = 1'd0;
			12  : CEN_read = 1'd0;
			13  : CEN_read = 1'd0;
			14  : CEN_read = 1'd0;
			20  : CEN_read = 1'd0;
			21  : CEN_read = 1'd0;
			22  : CEN_read = 1'd0;
			23  : CEN_read = 1'd0;
			24  : CEN_read = 1'd0;
			30  : CEN_read = 1'd0;
			31  : CEN_read = 1'd0;
			32  : CEN_read = 1'd0;
			33  : CEN_read = 1'd0;
			34  : CEN_read = 1'd0;
			/*40  : CEN_read = 1'd0;
			41  : CEN_read = 1'd0;
			42  : CEN_read = 1'd0;
			43  : CEN_read = 1'd0;
			50  : CEN_read = 1'd0;
			51  : CEN_read = 1'd0;
			52  : CEN_read = 1'd0;
			53  : CEN_read = 1'd0;
			60  : CEN_read = 1'd0;
			61  : CEN_read = 1'd0;
			62  : CEN_read = 1'd0;
			63  : CEN_read = 1'd0;
			80  : CEN_read = 1'd0;
			81  : CEN_read = 1'd0;
			82  : CEN_read = 1'd0;
			90  : CEN_read = 1'd0;
			91  : CEN_read = 1'd0;
			92  : CEN_read = 1'd0;
			110 : CEN_read = 1'd0;
			111 : CEN_read = 1'd0;*/
			default : CEN_read = 1'd1;
		endcase
	end
	else begin
		CEN_read = 1'd1;
	end
end

always@(posedge i_clk)begin
	D_1 <= {2'b00,i_data[47:42]};
	D_2 <= i_data[41:34];
	D_3 <= {2'b00,i_data[23:18]};
	D_4 <= i_data[17:10];
end

always@(posedge i_clk)begin
	Q_1_r <= Q_1;
	Q_2_r <= Q_2;
	Q_3_r <= Q_3;
	Q_4_r <= Q_4;
end

// ---------------------------------------------------------------------------
// Operation Counter : 0 - 121 Cycles
// ---------------------------------------------------------------------------

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		op_counter_r <= 7'd0;
	end
	else begin
		op_counter_r <= op_counter_w;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		if(op_counter_r == 7'd125)begin
			op_counter_w = 7'd0;
		end
		else begin
			op_counter_w = op_counter_r + 7'd1;
		end
	end
	else begin
		op_counter_w = 7'd0;
	end
end

// ---------------------------------------------------------------------------
// GG Control
// ---------------------------------------------------------------------------

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			2   : GG_i_data_valid = 1'd1;
			12  : GG_i_data_valid = 1'd1;
			22  : GG_i_data_valid = 1'd1;
			32  : GG_i_data_valid = 1'd1;
			42  : GG_i_data_valid = 1'd1;
			52  : GG_i_data_valid = 1'd1;
			62  : GG_i_data_valid = 1'd1;
			82  : GG_i_data_valid = 1'd1;
			92  : GG_i_data_valid = 1'd1;
			114 : GG_i_data_valid = 1'd1;
			default : GG_i_data_valid = 1'd0;
		endcase
	end
	else begin
		GG_i_data_valid = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			2   : GG_i_first_in = 1'd1;
			42  : GG_i_first_in = 1'd1;
			82  : GG_i_first_in = 1'd1;
			default : GG_i_first_in = 1'd0;
		endcase
	end
	else begin
		GG_i_first_in = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			32  : GG_i_last_in = 1'd1;
			62  : GG_i_last_in = 1'd1;
			92  : GG_i_last_in = 1'd1;
			114 : GG_i_last_in = 1'd1;
			default : GG_i_last_in = 1'd0;
		endcase
	end
	else begin
		GG_i_last_in = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			2   : GG_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			12  : GG_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			22  : GG_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			32  : GG_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			42  : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			52  : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			62  : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			82  : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			92  : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			114 : GG_i_data = {R22_imag_r,o_r_r[315:300]};
			default : GG_i_data = 36'd0;
		endcase
	end
	else begin
		GG_i_data = 36'd0;
	end
end

// ---------------------------------------------------------------------------
// GR Control
// ---------------------------------------------------------------------------

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			3   : GR_i_data_valid = 1'd1;
			13  : GR_i_data_valid = 1'd1;
			23  : GR_i_data_valid = 1'd1;
			33  : GR_i_data_valid = 1'd1;
			43  : GR_i_data_valid = 1'd1;
			53  : GR_i_data_valid = 1'd1;
			63  : GR_i_data_valid = 1'd1;
			83  : GR_i_data_valid = 1'd1;
			93  : GR_i_data_valid = 1'd1;
			115 : GR_i_data_valid = 1'd1;
			default : GR_i_data_valid = 1'd0;
		endcase
	end
	else begin
		GR_i_data_valid = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			4   : GR_i_data_valid_2 = 1'd1;
			14  : GR_i_data_valid_2 = 1'd1;
			24  : GR_i_data_valid_2 = 1'd1;
			34  : GR_i_data_valid_2 = 1'd1;
			44  : GR_i_data_valid_2 = 1'd1;
			54  : GR_i_data_valid_2 = 1'd1;
			64  : GR_i_data_valid_2 = 1'd1;
			84  : GR_i_data_valid_2 = 1'd1;
			94  : GR_i_data_valid_2 = 1'd1;
			default : GR_i_data_valid_2 = 1'd0;
		endcase
	end
	else begin
		GR_i_data_valid_2 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			5   : GR_i_data_valid_3 = 1'd1;
			15  : GR_i_data_valid_3 = 1'd1;
			25  : GR_i_data_valid_3 = 1'd1;
			35  : GR_i_data_valid_3 = 1'd1;
			45  : GR_i_data_valid_3 = 1'd1;
			55  : GR_i_data_valid_3 = 1'd1;
			65  : GR_i_data_valid_3 = 1'd1;
			default : GR_i_data_valid_3 = 1'd0;
		endcase
	end
	else begin
		GR_i_data_valid_3 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			6   : GR_i_data_valid_4 = 1'd1;
			16  : GR_i_data_valid_4 = 1'd1;
			26  : GR_i_data_valid_4 = 1'd1;
			36  : GR_i_data_valid_4 = 1'd1;
			default : GR_i_data_valid_4 = 1'd0;
		endcase
	end
	else begin
		GR_i_data_valid_4 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			3   : GR_i_first_in = 1'd1;
			43  : GR_i_first_in = 1'd1;
			83  : GR_i_first_in = 1'd1;
			default : GR_i_first_in = 1'd0;
		endcase
	end
	else begin
		GR_i_first_in = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			4   : GR_i_first_in_2 = 1'd1;
			44  : GR_i_first_in_2 = 1'd1;
			84  : GR_i_first_in_2 = 1'd1;
			default : GR_i_first_in_2 = 1'd0;
		endcase
	end
	else begin
		GR_i_first_in_2 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			5   : GR_i_first_in_3 = 1'd1;
			45  : GR_i_first_in_3 = 1'd1;
			default : GR_i_first_in_3 = 1'd0;
		endcase
	end
	else begin
		GR_i_first_in_3 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			6   : GR_i_first_in_4 = 1'd1;
			default : GR_i_first_in_4 = 1'd0;
		endcase
	end
	else begin
		GR_i_first_in_4 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			33  : GR_i_last_in = 1'd1;
			63  : GR_i_last_in = 1'd1;
			93  : GR_i_last_in = 1'd1;
			115 : GR_i_last_in = 1'd1;
			default : GR_i_last_in = 1'd0;
		endcase
	end
	else begin
		GR_i_last_in = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			34  : GR_i_last_in_2 = 1'd1;
			64  : GR_i_last_in_2 = 1'd1;
			94  : GR_i_last_in_2 = 1'd1;
			default : GR_i_last_in_2 = 1'd0;
		endcase
	end
	else begin
		GR_i_last_in_2 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			35  : GR_i_last_in_3 = 1'd1;
			65  : GR_i_last_in_3 = 1'd1;
			default : GR_i_last_in_3 = 1'd0;
		endcase
	end
	else begin
		GR_i_last_in_3 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			36  : GR_i_last_in_4 = 1'd1;
			default : GR_i_last_in_4 = 1'd0;
		endcase
	end
	else begin
		GR_i_last_in_4 = 1'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			3   : GR_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			13  : GR_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			23  : GR_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			33  : GR_i_data = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			43  : GR_i_data = {R33_imag_r,o_r_r[275:260]};
			53  : GR_i_data = {R33_imag_r,o_r_r[275:260]};
			63  : GR_i_data = {R33_imag_r,o_r_r[275:260]};
			83  : GR_i_data = {R33_imag_r,o_r_r[275:260]};
			93  : GR_i_data = {R33_imag_r,o_r_r[275:260]};
			115 : GR_i_data = o_y_hat_r[159:120];
			default : GR_i_data = 36'd0;
		endcase
	end
	else begin
		GR_i_data = 36'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			4   : GR_i_data_2 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			14  : GR_i_data_2 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			24  : GR_i_data_2 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			34  : GR_i_data_2 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			44  : GR_i_data_2 = {R44_imag_r,o_r_r[175:160]};
			54  : GR_i_data_2 = {R44_imag_r,o_r_r[175:160]};
			64  : GR_i_data_2 = {R44_imag_r,o_r_r[175:160]};
			84  : GR_i_data_2 = o_y_hat_r[119: 80];
			94  : GR_i_data_2 = o_y_hat_r[159:120];
			default : GR_i_data_2 = 36'd0;
		endcase
	end
	else begin
		GR_i_data_2 = 36'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			5   : GR_i_data_3 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			15  : GR_i_data_3 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			25  : GR_i_data_3 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			35  : GR_i_data_3 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			45  : GR_i_data_3 = o_y_hat_r[ 79: 40];
			55  : GR_i_data_3 = o_y_hat_r[119: 80];
			65  : GR_i_data_3 = o_y_hat_r[159:120];
			default : GR_i_data_3 = 36'd0;
		endcase
	end
	else begin
		GR_i_data_3 = 36'd0;
	end
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			6   : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			16  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			26  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			36  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0]};
			default : GR_i_data_4 = 36'd0;
		endcase
	end
	else begin
		GR_i_data_4 = 36'd0;
	end
end

/*always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			6   : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],2'b00,Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0],2'b00};
			16  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],2'b00,Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0],2'b00};
			26  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],2'b00,Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0],2'b00};
			36  : GR_i_data_4 = {Q_1_r[5],Q_1_r[5],Q_1_r[5],Q_1_r[4:0],Q_2_r[7:0],2'b00,Q_3_r[5],Q_3_r[5],Q_3_r[5],Q_3_r[4:0],Q_4_r[7:0],2'b00};
			default : GR_i_data_4 = 36'd0;
		endcase
	end
	else begin
		GR_i_data_4 = 36'd0;
	end
end*/


// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		o_r_r <= 0;
	end
	else begin
		case(op_counter_r)
			33  : begin o_r_r[319:300] <= GR_o_y_re;end
			34  : begin o_r_r[299:260] <= GR_o_y_re_2;end
			35  : begin o_r_r[179:160] <= GR_o_y_re_3;end
			43  : begin o_r_r[319:300] <= GR_o_y_re;end
			44  : begin o_r_r[299:260] <= GR_o_y_re_2;end
			45  : begin o_r_r[179:160] <= GR_o_y_re_3;end
			52  : begin o_r_r[ 19:  0] <= {GG_o_data,4'b0000};end//R11
			53  : begin o_r_r[319:300] <= GR_o_y_re;o_r_r[ 59: 20] <= {GR_o_x_im,4'b0000,GR_o_x_re,4'b0000};end//R12				*****
			54  : begin o_r_r[299:260] <= GR_o_y_re_2;o_r_r[119: 80] <= {GR_o_x_im_2,4'b0000,GR_o_x_re_2,4'b0000};end//R13			*****
			55  : begin o_r_r[179:160] <= GR_o_y_re_3;o_r_r[219:180] <= {GR_o_x_im_3,4'b0000,GR_o_x_re_3,4'b0000};end//R14			*****
			73  : begin o_r_r[319:300] <= GR_o_y_re;end
			74  : begin o_r_r[299:260] <= GR_o_y_re_2;end
			82  : begin o_r_r[ 79: 60] <= {GG_o_data,4'b0000};end//R22
			83  : begin o_r_r[319:300] <= GR_o_y_re;o_r_r[159:120] <= {GR_o_x_im,4'b0000,GR_o_x_re,4'b0000};end//R23				*****
			84  : begin o_r_r[299:260] <= GR_o_y_re_2;o_r_r[259:220] <= {GR_o_x_im_2,4'b0000,GR_o_x_re_2,4'b0000};end//R24			*****
			112 : begin o_r_r[179:160] <= {GG_o_data,4'b0000};end//R33
			113 : begin o_r_r[319:300] <= GR_o_y_re;o_r_r[299:260] <= {GR_o_x_im,4'b0000,GR_o_x_re,4'b0000};end//R34				*****
			124 : begin o_r_r[319:300] <= {GG_o_data_1stage,4'b0000};end//R44
			default : o_r_r <= o_r_r;
		endcase
	end
end

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		o_y_hat_r <= 0;
	end
	else begin
		case(op_counter_r)
			36  : begin o_y_hat_r[ 79: 40] <= {GR_o_y_im_4,GR_o_y_re_4};end
			46  : begin o_y_hat_r[119: 80] <= {GR_o_y_im_4,GR_o_y_re_4};end
			56  : begin o_y_hat_r[159:120] <= {GR_o_y_im_4,GR_o_y_re_4};o_y_hat_r[ 39:  0] <= {GR_o_x_im_4,4'b0000,GR_o_x_re_4,4'b0000};end//Y1
			75  : begin o_y_hat_r[119: 80] <= {GR_o_y_im_3,GR_o_y_re_3};end
			85  : begin o_y_hat_r[159:120] <= {GR_o_y_im_3,GR_o_y_re_3};o_y_hat_r[ 79: 40] <= {GR_o_x_im_3,4'b0000,GR_o_x_re_3,4'b0000};end//Y2
			114 : begin o_y_hat_r[159:120] <= {GR_o_y_im_2,GR_o_y_re_2};o_y_hat_r[119: 80] <= {GR_o_x_im_2,4'b0000,GR_o_x_re_2,4'b0000};end//Y3
			125 : begin o_y_hat_r[159:120] <= {GR_o_y_im_1stage,4'b0000,GR_o_x_re_1stage,4'b0000};end//Y4
			default : o_y_hat_r <= o_y_hat_r;
		endcase
	end
end

/*always @(posedge i_clk) begin
	Y_imag_r <= Y_imag_w;
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			36  : Y_imag_w = {GR_o_y_im_4,GR_o_y_re_4};
			46  : Y_imag_w = {GR_o_y_im_4,GR_o_y_re_4};
			56  : Y_imag_w = {GR_o_y_im_4,GR_o_y_re_4};
			75  : Y_imag_w = {GR_o_y_im_3,GR_o_y_re_3};
			85  : Y_imag_w = {GR_o_y_im_3,GR_o_y_re_3};
			114 : Y_imag_w = {GR_o_y_im_2,GR_o_y_re_2};
			default : Y_imag_w = Y_imag_r;
		endcase
	end
	else begin
		Y_imag_w = 1'd0;
	end
end*/

always @(posedge i_clk) begin
	R22_imag_r <= R22_imag_w;
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			33  : R22_imag_w = GR_o_y_im;
			43  : R22_imag_w = GR_o_y_im;
			53  : R22_imag_w = GR_o_y_im;
			73  : R22_imag_w = GR_o_y_im;
			83  : R22_imag_w = GR_o_y_im;
			113 : R22_imag_w = GR_o_y_im;
			default : R22_imag_w = R22_imag_r;
		endcase
	end
	else begin
		R22_imag_w = 1'd0;
	end
end

always @(posedge i_clk) begin
	R33_imag_r <= R33_imag_w;
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			34  : R33_imag_w = GR_o_y_im_2;
			44  : R33_imag_w = GR_o_y_im_2;
			54  : R33_imag_w = GR_o_y_im_2;
			74  : R33_imag_w = GR_o_y_im_2;
			84  : R33_imag_w = GR_o_y_im_2;
			default : R33_imag_w = R33_imag_r;
		endcase
	end
	else begin
		R33_imag_w = 1'd0;
	end
end

always @(posedge i_clk) begin
	R44_imag_r <= R44_imag_w;
end

always@(*)begin
	if(current_state == OPERATION)begin
		case(op_counter_r)
			35  : R44_imag_w = GR_o_y_im_3;
			45  : R44_imag_w = GR_o_y_im_3;
			55  : R44_imag_w = GR_o_y_im_3;
			default : R44_imag_w = R44_imag_r;
		endcase
	end
	else begin
		R44_imag_w = 1'd0;
	end
end

// ---------------------------------------------------------------------------
// RE Depth(RE0 - RE9)
// ---------------------------------------------------------------------------

always @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
		RE_depth_r <= 4'd0;
	end
	else begin
		RE_depth_r <= RE_depth_w;
	end
end

always@(*)begin
	if(current_state == OUTPUT_DATA)begin
		if(RE_depth_r == 4'd9)begin
			RE_depth_w = 4'd0;
		end
		else begin
			RE_depth_w = RE_depth_r + 7'd1;
		end
	end
	else begin
		RE_depth_w = RE_depth_r;
	end
end

// ---------------------------------------------------------------------------
// 5*SRAM_256x8
// ---------------------------------------------------------------------------

sram_256x8 u_sram_1(
		    .Q		(Q_1  ),
		    .CLK	(i_clk),
		    .CEN	(CEN  ),
		    .WEN	(WEN  ),
		    .A		(A    ),
		    .D		(D_1  )
);

sram_256x8 u_sram_2(
		    .Q		(Q_2  ),
		    .CLK	(i_clk),
		    .CEN	(CEN  ),
		    .WEN	(WEN  ),
		    .A		(A    ),
		    .D		(D_2  )
);

sram_256x8 u_sram_3(
		    .Q		(Q_3  ),
		    .CLK	(i_clk),
		    .CEN	(CEN  ),
		    .WEN	(WEN  ),
		    .A		(A    ),
		    .D		(D_3  )
);

sram_256x8 u_sram_4(
		    .Q		(Q_4  ),
		    .CLK	(i_clk),
		    .CEN	(CEN  ),
		    .WEN	(WEN  ),
		    .A		(A    ),
		    .D		(D_4  )
);

// ---------------------------------------------------------------------------
// GG and GR sub-module
// ---------------------------------------------------------------------------

GG #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_GG (
	.i_clk				(i_clk			   		),
    .i_rst				(i_rst			   		),
    .i_data_valid		(GG_i_data_valid   		),
    .i_data				(GG_i_data		   		),
    .i_first_in			(GG_i_first_in	   		),
    .i_last_in			(GG_i_last_in	   		),
    .o_d_im2re_valid	(GG_o_d_im2re_valid		),
    .o_d_im2re			(GG_o_d_im2re	   		),
    .o_d_re2re_valid	(GG_o_d_re2re_valid		),
    .o_d_re2re			(GG_o_d_re2re	   		),
    .o_data_valid		(GG_o_data_valid  		),
    .o_data				(GG_o_data		   		),
	.o_data_1stage_valid(GG_o_data_1stage_valid ),
	.o_data_1stage  	(GG_o_data_1stage  		)
);

GR #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_GR_1 (
	.i_clk				(i_clk			   		),
	.i_rst				(i_rst			   		),
	.i_data_valid		(GR_i_data_valid   		), //
	.i_data		 		(GR_i_data		   		), //
	.i_d_im2re_valid	(GR_i_d_im2re_valid		), //
	.i_d_im2re			(GR_i_d_im2re	   		), //
	.i_d_re2re_valid	(GR_i_d_re2re_valid		), //
	.i_d_re2re			(GR_i_d_re2re	   		), //
	.i_first_in	 		(GR_i_first_in	   		), //
	.i_last_in			(GR_i_last_in	   		), //
	.o_d_im2re_valid	(GR_o_d_im2re_valid		),
	.o_d_im2re			(GR_o_d_im2re	   		),
	.o_d_re2re_valid	(GR_o_d_re2re_valid		),
	.o_d_re2re			(GR_o_d_re2re	  		),
	.o_x_valid			(GR_o_x_valid	   		),
	.o_x_re		 		(GR_o_x_re		  		),
	.o_x_im		 		(GR_o_x_im		  		),
	.o_y_valid			(GR_o_y_valid	   		),
	.o_y_re		 		(GR_o_y_re		   		),
	.o_y_im				(GR_o_y_im		  		),
	.o_data_1stage_valid(GR_o_data_1stage_valid ),
	.o_x_re_1stage		(GR_o_x_re_1stage		),
	.o_y_im_1stage		(GR_o_y_im_1stage		)
);

GR #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_GR_2 (
	.i_clk				(i_clk			   		 ),
	.i_rst				(i_rst			   		 ),
	.i_data_valid		(GR_i_data_valid_2   	 ), //
	.i_data		 		(GR_i_data_2		   	 ), //
	.i_d_im2re_valid	(GR_i_d_im2re_valid_2	 ), //
	.i_d_im2re			(GR_i_d_im2re_2	   		 ), //
	.i_d_re2re_valid	(GR_i_d_re2re_valid_2	 ), //
	.i_d_re2re			(GR_i_d_re2re_2	   		 ), //
	.i_first_in	 		(GR_i_first_in_2	   	 ), //
	.i_last_in			(GR_i_last_in_2	   		 ), //
	.o_d_im2re_valid	(GR_o_d_im2re_valid_2	 ),
	.o_d_im2re			(GR_o_d_im2re_2	   		 ),
	.o_d_re2re_valid	(GR_o_d_re2re_valid_2	 ),
	.o_d_re2re			(GR_o_d_re2re_2	  		 ),
	.o_x_valid			(GR_o_x_valid_2	   		 ),
	.o_x_re		 		(GR_o_x_re_2		  	 ),
	.o_x_im		 		(GR_o_x_im_2		  	 ),
	.o_y_valid			(GR_o_y_valid_2	   		 ),
	.o_y_re		 		(GR_o_y_re_2		   	 ),
	.o_y_im				(GR_o_y_im_2		  	 ),
	.o_data_1stage_valid(GR_o_data_1stage_valid_2),
	.o_x_re_1stage		(GR_o_x_re_1stage_2		 ),
	.o_y_im_1stage		(GR_o_y_im_1stage_2		 )
);

GR #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_GR_3 (
	.i_clk				(i_clk			   		 ),
	.i_rst				(i_rst			   		 ),
	.i_data_valid		(GR_i_data_valid_3   	 ), //
	.i_data		 		(GR_i_data_3		   	 ), //
	.i_d_im2re_valid	(GR_i_d_im2re_valid_3	 ), //
	.i_d_im2re			(GR_i_d_im2re_3	   		 ), //
	.i_d_re2re_valid	(GR_i_d_re2re_valid_3	 ), //
	.i_d_re2re			(GR_i_d_re2re_3	   		 ), //
	.i_first_in	 		(GR_i_first_in_3	   	 ), //
	.i_last_in			(GR_i_last_in_3	   		 ), //
	.o_d_im2re_valid	(GR_o_d_im2re_valid_3	 ),
	.o_d_im2re			(GR_o_d_im2re_3	   		 ),
	.o_d_re2re_valid	(GR_o_d_re2re_valid_3	 ),
	.o_d_re2re			(GR_o_d_re2re_3	  		 ),
	.o_x_valid			(GR_o_x_valid_3	   		 ),
	.o_x_re		 		(GR_o_x_re_3		  	 ),
	.o_x_im		 		(GR_o_x_im_3		  	 ),
	.o_y_valid			(GR_o_y_valid_3	   		 ),
	.o_y_re		 		(GR_o_y_re_3		   	 ),
	.o_y_im				(GR_o_y_im_3		  	 ),
	.o_data_1stage_valid(GR_o_data_1stage_valid_3),
	.o_x_re_1stage		(GR_o_x_re_1stage_3		 ),
	.o_y_im_1stage		(GR_o_y_im_1stage_3		 )
);

GR #(
    .INOUT_WIDRH(INOUT_WIDRH),
    .ITER_NUM(ITER_NUM)
) u_GR_4 (
	.i_clk				(i_clk			   		 ),
	.i_rst				(i_rst			   		 ),
	.i_data_valid		(GR_i_data_valid_4   	 ), //
	.i_data		 		(GR_i_data_4		   	 ), //
	.i_d_im2re_valid	(GR_i_d_im2re_valid_4	 ), //
	.i_d_im2re			(GR_i_d_im2re_4	   		 ), //
	.i_d_re2re_valid	(GR_i_d_re2re_valid_4	 ), //
	.i_d_re2re			(GR_i_d_re2re_4	   		 ), //
	.i_first_in	 		(GR_i_first_in_4	   	 ), //
	.i_last_in			(GR_i_last_in_4	   		 ), //
	.o_d_im2re_valid	(GR_o_d_im2re_valid_4	 ),
	.o_d_im2re			(GR_o_d_im2re_4	   		 ),
	.o_d_re2re_valid	(GR_o_d_re2re_valid_4	 ),
	.o_d_re2re			(GR_o_d_re2re_4	  		 ),
	.o_x_valid			(GR_o_x_valid_4	   		 ),
	.o_x_re		 		(GR_o_x_re_4		  	 ),
	.o_x_im		 		(GR_o_x_im_4		  	 ),
	.o_y_valid			(GR_o_y_valid_4	   		 ),
	.o_y_re		 		(GR_o_y_re_4		   	 ),
	.o_y_im				(GR_o_y_im_4		  	 ),
	.o_data_1stage_valid(GR_o_data_1stage_valid_4),
	.o_x_re_1stage		(GR_o_x_re_1stage_4		 ),
	.o_y_im_1stage		(GR_o_y_im_1stage_4		 )
);

endmodule