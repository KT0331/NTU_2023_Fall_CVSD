
module core (                       //Don't modify interface
	input         i_clk,
	input         i_rst_n,
	input         i_op_valid,
	input  [ 3:0] i_op_mode,
    output        o_op_ready,
	input         i_in_valid,
	input  [ 7:0] i_in_data,
	output        o_in_ready,
	output        o_out_valid,
	output [13:0] o_out_data
);

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
parameter DATA_WIDTH  		  = 8;
parameter OUT_DATA_W  		  = 14;
parameter NUM_SRAM    		  = 8;

localparam IDLE       		  = 3'b000;
localparam LOAD_MODE  		  = 3'b001;
localparam WAIT       		  = 3'b010;
localparam LOAD_DATA  		  = 3'b011;
localparam OPER       		  = 3'b100;
localparam OUT        		  = 3'b101;

localparam OP_LOAD    		  = 4'b0000;
localparam OP_RS      		  = 4'b0001;
localparam OP_LS      		  = 4'b0010;
localparam OP_US      		  = 4'b0011;
localparam OP_DS      		  = 4'b0100;
localparam OP_RED_DEP 		  = 4'b0101;
localparam OP_INC_DEP 		  = 4'b0110;
localparam OP_OUT_PIX 		  = 4'b0111;
localparam OP_CONV    		  = 4'b1000;
localparam OP_MF      		  = 4'b1001;
localparam OP_SG_NMS  		  = 4'b1010;

localparam OPER_IDLE   		  = 3'b000;
localparam OPER_LOAD_0 		  = 3'b001;
localparam OPER_LOAD_1 		  = 3'b010;
localparam OPER_LOAD_2 		  = 3'b011;
localparam OPER_LOAD_3 		  = 3'b100;
localparam OPER_LY_ADD 		  = 3'b101;
localparam OPER_SB_NMS 		  = 3'b110;

// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// ---- Add your own wires and registers here if needed ---- //
reg                           o_op_ready_r;
reg                           o_in_ready_r;
reg                           o_out_valid_r;
reg     [  OUT_DATA_W-1:0]    o_out_data_r;
reg     [  OUT_DATA_W-1:0]    o_out_data_w;

reg     [             2:0]    c_state;
reg     [             2:0]    n_state;

reg                           idle_sig_w;
reg                           load_mode_sig_w;
reg                           wait_sig_w;
reg                           load_data_sig_w;
reg                           oper_sig_w;
reg                           out_sig_w;

reg     [             2:0]    oper_c_state;
reg     [             2:0]    oper_n_state;

wire                          median_oper_w;

reg     [             3:0]    mode_r;
reg     [             3:0]    mode_w;
reg     [             1:0]    oper_depth_r;
reg     [             1:0]    oper_depth_w;

wire    [  DATA_WIDTH-1:0]    SRAM_q[0:NUM_SRAM-1];
wire                          SRAM_wen[0:NUM_SRAM-1];
wire    [             7:0]    SRAM_a;
reg     [             7:0]    SRAM_a_w;
wire    [  DATA_WIDTH-1:0]    SRAM_d;
reg                           SRAM_cen_r;

reg     [             2:0]    disp_addr_x_r;
reg     [             2:0]    disp_addr_y_r;
reg     [             4:0]    disp_addr_z_r;
reg     [             2:0]    disp_addr_x_w;
reg     [             2:0]    disp_addr_y_w;
reg     [             4:0]    disp_addr_z_w;

wire                          disp_x_0;
wire                          disp_x_6;
wire                          disp_y_0;
wire                          disp_y_6;

reg     [             6:0]    counter_r;
reg     [             6:0]    counter_w;
reg     [             5:0]    counter_oper_w;
reg     [             6:0]    counter_control_r;
reg     [             6:0]    counter_control_w;
reg     [             3:0]    counter_control_16_w;

wire    [             5:0]    oper_addr_0;
wire    [             5:0]    oper_addr_1;
wire    [             5:0]    oper_addr_2;
wire    [             5:0]    oper_addr_3;
wire    [             5:0]    oper_addr_4;
wire    [             5:0]    oper_addr_5;
wire    [             5:0]    oper_addr_6;
wire    [             5:0]    oper_addr_7;
wire    [             5:0]    oper_addr_8;
wire    [             5:0]    oper_addr_9;
wire    [             5:0]    oper_addr_10;
wire    [             5:0]    oper_addr_11;
wire    [             5:0]    oper_addr_12;
wire    [             5:0]    oper_addr_13;
wire    [             5:0]    oper_addr_14;
wire    [             5:0]    oper_addr_15;

//14bits integer and 4bits frac. but we only need to consider 13bits unsigned or 11 bits signed and frac.
reg     [  DATA_WIDTH-1:0]    adder_in_data_g1[0:(NUM_SRAM/2)-1];
reg     [  DATA_WIDTH-1:0]    adder_in_data_g2[0:(NUM_SRAM/2)-1];


wire    [OUT_DATA_W+3-1:0]    o_adder_ul_g1_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_ul_g2_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_ur_g1_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_ur_g2_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_ll_g1_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_ll_g2_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_lr_g1_w[0:(NUM_SRAM/2)-1];
wire    [OUT_DATA_W+3-1:0]    o_adder_lr_g2_w[0:(NUM_SRAM/2)-1];
//14bits integer and 4bits frac. but we only need to consider 13bits unsigned or 11 bits signed and frac.

wire                          adder_oper_w;
wire                          adder_oper_temp;

wire    [  DATA_WIDTH-1:0]    median_out_data_ul[0:3];
wire    [  DATA_WIDTH-1:0]    median_out_data_ur[0:3];
wire    [  DATA_WIDTH-1:0]    median_out_data_ll[0:3];
wire    [  DATA_WIDTH-1:0]    median_out_data_lr[0:3];
reg     [  DATA_WIDTH-1:0]    median_in_w[0:3];

reg     [OUT_DATA_W+3-1:0]    conv2ly_ul_r[0:3];
reg     [OUT_DATA_W+3-1:0]    conv2ly_ur_r[0:3];
reg     [OUT_DATA_W+3-1:0]    conv2ly_ll_r[0:3];
reg     [OUT_DATA_W+3-1:0]    conv2ly_lr_r[0:3];
wire    [OUT_DATA_W+3-1:0]    conv2ly_ul_w[0:3];
wire    [OUT_DATA_W+3-1:0]    conv2ly_ur_w[0:3];
wire    [OUT_DATA_W+3-1:0]    conv2ly_ll_w[0:3];
wire    [OUT_DATA_W+3-1:0]    conv2ly_lr_w[0:3];
reg     [OUT_DATA_W+3-1:0]    convresult_ul_r;
reg     [OUT_DATA_W+3-1:0]    convresult_ur_r;
reg     [OUT_DATA_W+3-1:0]    convresult_ll_r;
reg     [OUT_DATA_W+3-1:0]    convresult_lr_r;
wire    [OUT_DATA_W+3-1:0]    convresult_ul_w;
wire    [OUT_DATA_W+3-1:0]    convresult_ur_w;
wire    [OUT_DATA_W+3-1:0]    convresult_ll_w;
wire    [OUT_DATA_W+3-1:0]    convresult_lr_w;

wire    [            10:0]    sobel_gx_ul_in_w[0:3];
wire    [            10:0]    sobel_gy_ul_in_w[0:3];
wire    [            10:0]    sobel_gx_ur_in_w[0:3];
wire    [            10:0]    sobel_gy_ur_in_w[0:3];
wire    [            10:0]    sobel_gx_ll_in_w[0:3];
wire    [            10:0]    sobel_gy_ll_in_w[0:3];
wire    [            10:0]    sobel_gx_lr_in_w[0:3];
wire    [            10:0]    sobel_gy_lr_in_w[0:3];
wire    [            10:0]    sobel_g_ul_out_w[0:3];
wire    [            10:0]    sobel_g_ur_out_w[0:3];
wire    [            10:0]    sobel_g_ll_out_w[0:3];
wire    [            10:0]    sobel_g_lr_out_w[0:3];

// ---------------------------------------------------------------------------
// FSM Blocks
// ---------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		c_state <= 3'b000;
	end
	else begin
		c_state <= n_state;
	end
end

always @(*) begin
	case(c_state)
		IDLE: begin
			n_state = LOAD_MODE;
		end
		LOAD_MODE: begin
			n_state = WAIT;
		end
		WAIT: begin
			if(i_op_valid) begin
				if(!i_op_mode[3]) begin
					if(~(|i_op_mode[2:0])) begin //OP_LOAD
						n_state = LOAD_DATA;
					end
					else begin
						if(&i_op_mode[2:0]) begin //OP_OUT_PIX
							n_state = OUT;
						end
						else begin
							n_state = LOAD_MODE;
						end
					end
				end
				else begin
					//n_state = OPER_BUFF;
					n_state = OPER;
				end
			end
			else begin
				n_state = WAIT;
			end
		end
		LOAD_DATA: begin
			if(!i_in_valid) begin
				n_state = LOAD_MODE;
			end
			else begin
				n_state = LOAD_DATA;
			end
		end
		OPER: begin
			if(~(|mode_r[1:0])) begin //OP_CONV
				if((oper_c_state == OPER_LY_ADD) && counter_control_r[0]) begin
					n_state = OUT;
				end
				else begin
					n_state = OPER;
				end
			end
			else if (mode_r[0]) begin //OP_MF
				if(&counter_control_r[3:0]) begin
					n_state = OUT;
				end
				else if(disp_x_0) begin
					if(((disp_y_0) && (counter_control_r[3:0] == 4'd10))
						|| (counter_control_r[3:0] == 4'd14)) begin
						
						n_state = OUT;
					end
					else begin
						n_state = OPER;
					end
				end
				else begin
					n_state = OPER;
				end
			end 
			else begin //OP_SG_NMS
				if((oper_c_state == OPER_SB_NMS) && counter_control_r[2]) begin
					n_state = OUT;
				end
				else begin
					n_state = OPER;
				end
			end
		end
		OUT: begin
			case(mode_r)
				OP_OUT_PIX: begin
					case(oper_depth_r)
						2'b00: begin
							if(&counter_control_r[4:0]) begin
								n_state = LOAD_MODE;
							end
							else begin
								n_state = OUT;
							end
						end
						2'b01: begin
							if(&counter_control_r[5:0]) begin
								n_state = LOAD_MODE;
							end
							else begin
								n_state = OUT;
							end
						end
						2'b10: begin
							if(&counter_control_r[6:0]) begin
								n_state = LOAD_MODE;
							end
							else begin
								n_state = OUT;
							end
						end
						default: begin
							n_state = IDLE;
						end
					endcase
				end
				OP_CONV: begin
					if(&counter_control_r[1:0]) begin
						n_state = LOAD_MODE;
					end
					else begin
						n_state = OUT;
					end
				end
				OP_MF: begin
					if(&counter_control_r[3:0]) begin
						n_state = LOAD_MODE;
					end
					else begin
						n_state = OUT;
					end
				end
				OP_SG_NMS: begin
					if(&counter_control_r[3:0]) begin
						n_state = LOAD_MODE;
					end
					else begin
						n_state = OUT;
					end
				end
				default: begin
					n_state = IDLE;
				end
			endcase
		end
		default: begin
			n_state = IDLE;
		end
	endcase
end

always @(*) begin
	case(c_state)
		IDLE: begin
			idle_sig_w	    = 1'b1;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b0;
			
		end
		LOAD_MODE: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b1;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b0;
		end
		WAIT: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b1;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b0;
		end
		LOAD_DATA: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b1;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b0;
		end
		OPER: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b1;
			out_sig_w       = 1'b0;
		end
		OUT: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b1;
		end
		default: begin
			idle_sig_w	    = 1'b0;
			load_mode_sig_w = 1'b0;
			wait_sig_w      = 1'b0;
			load_data_sig_w = 1'b0;
			oper_sig_w      = 1'b0;
			out_sig_w       = 1'b0;
		end
	endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		oper_c_state <= OPER_IDLE;
	end
	else begin
		oper_c_state <= oper_n_state;
	end
end

always @(*) begin
	case(oper_c_state)
		OPER_IDLE: begin
			if(wait_sig_w && i_op_valid) begin
				if(i_op_mode[3] && (~i_op_mode[0])) begin //OP_CONV or OP_SG_NMS
					oper_n_state = OPER_LOAD_0;
				end
				else begin
					oper_n_state = OPER_IDLE;
				end
			end
			else begin
				oper_n_state = OPER_IDLE;
			end
		end
		OPER_LOAD_0: begin
			if(&counter_control_r[3:0]) begin
				if(!mode_r[1]) begin
					if(~(|oper_depth_r)) begin //oper_depth_r == 2'b00, depth == 8
						oper_n_state = OPER_LY_ADD;
					end
					else begin
						oper_n_state = OPER_LOAD_1;
					end
				end
				else begin
					oper_n_state = OPER_SB_NMS;
				end
			end
			else if(disp_x_0) begin
				if(((disp_y_0) && (counter_control_r[3:0] == 4'd10))
					|| (counter_control_r[3:0] == 4'd14)) begin
					
					if(!mode_r[1]) begin
						if(~(|oper_depth_r)) begin //oper_depth_r == 2'b00, depth == 8
							oper_n_state = OPER_LY_ADD;
						end
						else begin
							oper_n_state = OPER_LOAD_1;
						end
					end
					else begin
						oper_n_state = OPER_SB_NMS;
					end
				end
				else begin
					oper_n_state = OPER_LOAD_0;
				end
			end
			else begin
				oper_n_state = OPER_LOAD_0;
			end
		end
		OPER_LOAD_1: begin
			if(&counter_control_r[3:0]) begin
				if(oper_depth_r[0]) begin //oper_depth_r == 2'b01, depth == 16
					oper_n_state = OPER_LY_ADD;
				end
				else begin
					oper_n_state = OPER_LOAD_2;
				end
			end
			else if(disp_x_0) begin
				if(((disp_y_0) && (counter_control_r[3:0] == 4'd10))
					|| (counter_control_r[3:0] == 4'd14)) begin
					
					if(oper_depth_r[0]) begin //oper_depth_r == 2'b01, depth == 16
						oper_n_state = OPER_LY_ADD;
					end
					else begin
						oper_n_state = OPER_LOAD_2;
					end
				end
				else begin
					oper_n_state = OPER_LOAD_1;
				end
			end
			else begin
				oper_n_state = OPER_LOAD_1;
			end
		end
		OPER_LOAD_2: begin //oper_depth_r == 2'b10, depth == 32
			if(&counter_control_r[3:0]) begin
				oper_n_state = OPER_LOAD_3;
			end
			else if(disp_x_0) begin
				if(((disp_y_0) && (counter_control_r[3:0] == 4'd10))
					|| (counter_control_r[3:0] == 4'd14)) begin
					
					oper_n_state = OPER_LOAD_3;
				end
				else begin
					oper_n_state = OPER_LOAD_2;
				end
			end
			else begin
				oper_n_state = OPER_LOAD_2;
			end
		end
		OPER_LOAD_3: begin
			if(&counter_control_r[3:0]) begin
				if(mode_r == OP_CONV) begin
					oper_n_state = OPER_LY_ADD;
				end
				else begin
					oper_n_state = OPER_SB_NMS;
				end
			end
			else if(disp_x_0) begin
				if(((disp_y_0) && (counter_control_r[3:0] == 4'd10))
					|| (counter_control_r[3:0] == 4'd14)) begin
					
					oper_n_state = OPER_LY_ADD;
				end
				else begin
					oper_n_state = OPER_LOAD_3;
				end
			end
			else begin
				oper_n_state = OPER_LOAD_3;
			end
		end
		OPER_LY_ADD: begin
			if(counter_control_r[0]) begin
				oper_n_state = OPER_IDLE;
			end
			else begin
				oper_n_state = OPER_LY_ADD;
			end
		end
		OPER_SB_NMS: begin
			if(counter_control_r[2]) begin
				oper_n_state = OPER_IDLE;
			end
			else begin
				oper_n_state = OPER_SB_NMS;
			end
		end
		default: begin
			oper_n_state = OPER_IDLE;
		end
	endcase
end

// ---------------------------------------------------------------------------
// Control Blocks
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
assign o_op_ready = o_op_ready_r;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_op_ready_r <= 1'b0;
	end
	else begin
		o_op_ready_r <= load_mode_sig_w;
	end
end

assign o_in_ready = o_in_ready_r;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_in_ready_r <= 1'b0;
	end
	else begin
		o_in_ready_r <= 1'b1;
	end
end

assign o_out_valid = o_out_valid_r;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_out_valid_r <= 1'b0;
	end
	else begin
		o_out_valid_r <= out_sig_w;
	end
end

assign o_out_data = o_out_data_r;

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_out_data_r <= {OUT_DATA_W{1'b0}};
	end
	else begin
		o_out_data_r <= o_out_data_w;
	end
end

always @(*) begin
	if(out_sig_w) begin
		case(mode_r)
			OP_OUT_PIX: begin
				o_out_data_w = {6'd0 ,SRAM_q[counter_control_r[4:2]]};
			end
			OP_CONV: begin
				case(counter_control_r[1:0])
					2'b00: begin
						o_out_data_w = {1'b0 ,convresult_ul_r[OUT_DATA_W+3-1:4]} + convresult_ul_r[3];
					end
					2'b01: begin
						o_out_data_w = {1'b0 ,convresult_ur_r[OUT_DATA_W+3-1:4]} + convresult_ur_r[3];
					end
					2'b10: begin
						o_out_data_w = {1'b0 ,convresult_ll_r[OUT_DATA_W+3-1:4]} + convresult_ll_r[3];
					end
					2'b11: begin
						o_out_data_w = {1'b0 ,convresult_lr_r[OUT_DATA_W+3-1:4]} + convresult_lr_r[3];
					end
					default: begin
						o_out_data_w = {OUT_DATA_W{1'b0}};
					end
				endcase
			end
			OP_MF: begin
				case(counter_control_r[1:0])
					2'b00: begin
						o_out_data_w = {6'd0 ,median_out_data_ul[counter_control_r[3:2]]};
					end
					2'b01: begin
						o_out_data_w = {6'd0 ,median_out_data_ur[counter_control_r[3:2]]};
					end
					2'b10: begin
						o_out_data_w = {6'd0 ,median_out_data_ll[counter_control_r[3:2]]};
					end
					2'b11: begin
						o_out_data_w = {6'd0 ,median_out_data_lr[counter_control_r[3:2]]};
					end
					default: begin
						o_out_data_w = {OUT_DATA_W{1'b0}};
					end
				endcase
			end
			OP_SG_NMS: begin
				case(counter_control_r[1:0])
					2'b00: begin
						o_out_data_w = {3'd0 ,sobel_g_ul_out_w[counter_control_r[3:2]]};
					end
					2'b01: begin
						o_out_data_w = {3'd0 ,sobel_g_ur_out_w[counter_control_r[3:2]]};
					end
					2'b10: begin
						o_out_data_w = {3'd0 ,sobel_g_ll_out_w[counter_control_r[3:2]]};
					end
					2'b11: begin
						o_out_data_w = {3'd0 ,sobel_g_lr_out_w[counter_control_r[3:2]]};
					end
					default: begin
						o_out_data_w = {OUT_DATA_W{1'b0}};
					end
				endcase
			end
			default: begin
				o_out_data_w = {OUT_DATA_W{1'b0}};
			end
		endcase
	end
	else begin
		o_out_data_w = {OUT_DATA_W{1'b0}};
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		mode_r <= 4'd0;
	end
	else begin
		mode_r <= mode_w;
	end
end

always @(*) begin
	if(wait_sig_w && i_op_valid) begin
		mode_w = i_op_mode;
	end
	else begin
		mode_w = mode_r;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		disp_addr_x_r <= 3'b000;
		disp_addr_y_r <= 3'b000;
		disp_addr_z_r <= 5'b0000_0;
	end
	else begin
		disp_addr_x_r <= disp_addr_x_w;
		disp_addr_y_r <= disp_addr_y_w;
		disp_addr_z_r <= disp_addr_z_w;
	end
end

always @(*) begin
	case(mode_r)
		OP_LOAD: begin
			if(load_data_sig_w) begin
				{disp_addr_z_w ,disp_addr_y_w ,disp_addr_x_w} 
				  = {disp_addr_z_r ,disp_addr_y_r ,disp_addr_x_r} + (i_in_valid & o_in_ready);
			end
			else begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
		end
		OP_RS: begin
			if(load_mode_sig_w && ~(&disp_addr_x_r)) begin
				disp_addr_x_w = disp_addr_x_r + 1'b1;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
			else begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
		end
		OP_LS: begin
			if(load_mode_sig_w && (|disp_addr_x_r)) begin
				disp_addr_x_w = disp_addr_x_r - 1'b1;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
			else begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
		end
		OP_US: begin
			if(load_mode_sig_w && (|disp_addr_y_r)) begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r - 1'b1;
				disp_addr_z_w = disp_addr_z_r;
			end
			else begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
		end
		OP_DS: begin
			if(load_mode_sig_w && (disp_addr_y_r != 3'b110)) begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r + 1'b1;
				disp_addr_z_w = disp_addr_z_r;
			end
			else begin
				disp_addr_x_w = disp_addr_x_r;
				disp_addr_y_w = disp_addr_y_r;
				disp_addr_z_w = disp_addr_z_r;
			end
		end
		default: begin
			disp_addr_x_w = disp_addr_x_r;
			disp_addr_y_w = disp_addr_y_r;
			disp_addr_z_w = disp_addr_z_r;
		end
	endcase
end

assign disp_x_0 = ~|disp_addr_x_r;
assign disp_x_6 = (&disp_addr_x_r[2:1]) & (~disp_addr_x_r[0]);
assign disp_y_0 = ~|disp_addr_y_r;
assign disp_y_6 = (&disp_addr_y_r[2:1]) & (~disp_addr_y_r[0]);

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		counter_r <= 7'd0;
	end
	else begin
		counter_r <= counter_w;
	end
end

always @(*) begin
	if(oper_c_state != OPER_SB_NMS) begin
		case({disp_x_0 ,disp_x_6 ,disp_y_0 ,disp_y_6})
			4'b1010: begin
				if(counter_r[3:0] == 4'd10) begin
					counter_oper_w = {counter_r[5:4] ,4'b0} + 6'b01_0000;
				end
				else begin
					if(counter_r[1:0] == 2'b10) begin
						counter_oper_w = counter_r[5:0] + 2'b10;
					end
					else begin
						counter_oper_w = counter_r[5:0] + 1'b1;
					end
				end
			end
			4'b0110: begin
				if(counter_r[3:0] == 4'd9) begin
					counter_oper_w = {counter_r[5:4] ,4'd15};
				end
				else begin
					if(counter_r[1:0] == 2'b01) begin
						counter_oper_w = counter_r[5:0] + 2'b10;
					end
					else begin
						counter_oper_w = counter_r[5:0] + 1'b1;
					end
				end
			end
			4'b1001: begin
				if(counter_r[3:0] == 4'd6) begin
					counter_oper_w = {counter_r[5:4] ,4'd12};
				end
				else begin
					if(counter_r[1:0] == 2'b10) begin
						counter_oper_w = counter_r[5:0] + 2'b10;
					end
					else begin
						counter_oper_w = counter_r[5:0] + 1'b1;
					end
				end
			end
			4'b0101: begin
				if(counter_r[3:0] == 4'd5) begin
					counter_oper_w = {counter_r[5:4] ,4'd11};
				end
				else begin
					if(counter_r[1:0] == 2'b01) begin
						counter_oper_w = counter_r[5:0] + 2'b10;
					end
					else begin
						counter_oper_w = counter_r[5:0] + 1'b1;
					end
				end
			end
			4'b1000: begin
				if(counter_r[1:0] == 2'b10) begin
					counter_oper_w = counter_r[5:0] + 2'b10;
				end
				else begin
					counter_oper_w = counter_r[5:0] + 1'b1;
				end
			end
			4'b0100: begin
				if(counter_r[1:0] == 2'b01) begin
					counter_oper_w = counter_r[5:0] + 2'b10;
				end
				else begin
					counter_oper_w = counter_r[5:0] + 1'b1;
				end
			end
			4'b0010: begin
				if(counter_r[3:0] == 4'd10) begin
					counter_oper_w = {counter_r[5:4] ,4'd15};
				end
				else begin
					counter_oper_w = counter_r[5:0] + 1'b1;
				end
			end
			4'b0001: begin
				if(counter_r[3:0] == 4'd6) begin
					counter_oper_w = {counter_r[5:4] ,4'd11};
				end
				else begin
					counter_oper_w = counter_r[5:0] + 1'b1;
				end
			end
			default: begin
				counter_oper_w = counter_r[5:0] + 1'b1;
			end
		endcase
	end
	else begin
		counter_oper_w = counter_r[5:0] + 1'b1;
	end
end

always @(*) begin
	if(load_mode_sig_w || idle_sig_w) begin
		counter_w = 7'd0;
	end
	else begin
		if(wait_sig_w /*&& (~i_op_mode[3])*/) begin
			counter_w = 7'd0 + i_op_valid;
		end
		else if(oper_sig_w) begin
			case(mode_r)
				OP_CONV: begin
					if((oper_c_state != OPER_LY_ADD) && (oper_n_state == OPER_LY_ADD)) begin
						counter_w = 7'd0;
					end
					else if(oper_c_state == OPER_LY_ADD) begin
						counter_w = {6'd0 ,~counter_r[0]}; //counter == 1 or 0
					end
					else begin
						counter_w = {1'b0 ,counter_oper_w};
					end
				end
				OP_MF: begin
					counter_w = {3'd0 ,counter_oper_w[3:0]};
				end
				OP_SG_NMS: begin
					if((oper_c_state == OPER_SB_NMS) && counter_r[1]) begin
						counter_w = 7'd0;
					end
					else begin
						counter_w = {1'b0 ,counter_oper_w};
					end
				end
				default: begin
					counter_w = 7'd0;
				end
			endcase
		end
		else if(out_sig_w) begin
			counter_w = counter_r + 1'b1;
		end
		else begin
			counter_w = counter_r;
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		counter_control_r <= 7'd0;
	end
	else begin
		counter_control_r <= counter_control_w;
	end
end


always @(*) begin
	if(oper_c_state != OPER_SB_NMS) begin
		case({disp_x_0 ,disp_x_6 ,disp_y_0 ,disp_y_6})
			4'b1010: begin
				if(counter_control_r[3:0] == 4'd10) begin
					counter_control_16_w = 4'b0;
				end
				else begin
					if(counter_control_r[1:0] == 2'b10) begin
						counter_control_16_w = counter_control_r[3:0] + 2'b10;
					end
					else begin
						counter_control_16_w = counter_control_r[3:0] + 1'b1;
					end
				end
			end
			4'b0110: begin
				if(counter_control_r[3:0] == 4'd9) begin
					counter_control_16_w = 4'd15;
				end
				else begin
					if(counter_control_r[1:0] == 2'b01) begin
						counter_control_16_w = counter_control_r[3:0] + 2'b10;
					end
					else begin
						counter_control_16_w = counter_control_r[3:0] + 1'b1;
					end
				end
			end
			4'b1001: begin
				if(counter_control_r[3:0] == 4'd6) begin
					counter_control_16_w = 4'd12;
				end
				else begin
					if(counter_control_r[1:0] == 2'b10) begin
						counter_control_16_w = counter_control_r[3:0] + 2'b10;
					end
					else begin
						counter_control_16_w = counter_control_r[3:0] + 1'b1;
					end
				end
			end
			4'b0101: begin
				if(counter_control_r[3:0] == 4'd5) begin
					counter_control_16_w = 4'd11;
				end
				else begin
					if(counter_control_r[1:0] == 2'b01) begin
						counter_control_16_w = counter_control_r[3:0] + 2'b10;
					end
					else begin
						counter_control_16_w = counter_control_r[3:0] + 1'b1;
					end
				end
			end
			4'b1000: begin
				if(counter_control_r[1:0] == 2'b10) begin
					counter_control_16_w = counter_control_r[3:0] + 2'b10;
				end
				else begin
					counter_control_16_w = counter_control_r[3:0] + 1'b1;
				end
			end
			4'b0100: begin
				if(counter_control_r[1:0] == 2'b01) begin
					counter_control_16_w = counter_control_r[3:0] + 2'b10;
				end
				else begin
					counter_control_16_w = counter_control_r[3:0] + 1'b1;
				end
			end
			4'b0010: begin
				if(counter_control_r[3:0] == 4'd10) begin
					counter_control_16_w = 4'd15;
				end
				else begin
					counter_control_16_w = counter_control_r[3:0] + 1'b1;
				end
			end
			4'b0001: begin
				if(counter_control_r[3:0] == 4'd6) begin
					counter_control_16_w = 4'd11;
				end
				else begin
					counter_control_16_w = counter_control_r[3:0] + 1'b1;
				end
			end
			default: begin
				counter_control_16_w = counter_control_r[3:0] + 1'b1;
			end
		endcase
	end
	else begin
		counter_control_16_w = counter_control_r[3:0] + 1'b1;
	end
end


always @(*) begin
	if(load_mode_sig_w || idle_sig_w) begin
		counter_control_w = 7'd0;
	end
	else begin
		if(wait_sig_w) begin
			counter_control_w = 7'd0;
		end
		else if(oper_sig_w) begin
			case(mode_r)
				OP_CONV: begin
					if((oper_c_state != OPER_LY_ADD) && (oper_n_state == OPER_LY_ADD)) begin
						counter_control_w = 7'd0;
					end
					else if(oper_c_state == OPER_LY_ADD) begin
						counter_control_w = {6'd0 ,~counter_control_r[0]}; //counter == 1 or 0
					end
					else begin
						counter_control_w = {3'd0 ,counter_control_16_w};
					end
				end
				OP_MF: begin
					counter_control_w = {3'd0 ,counter_control_16_w};
				end
				OP_SG_NMS: begin
					if((oper_c_state == OPER_SB_NMS) && counter_control_r[2]) begin
						counter_control_w = 7'd0;
					end
					else begin
						counter_control_w = {3'd0 ,counter_control_16_w};
					end
				end
				default: begin
					counter_control_w = 7'd0;
				end
			endcase
		end
		else if(out_sig_w) begin
			counter_control_w = counter_control_r + 1'b1;
		end
		else begin
			counter_control_w = counter_control_r;
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		oper_depth_r <= 2'b10;
	end
	else begin
		oper_depth_r <= oper_depth_w;
	end
end

always @(*) begin
	if(load_mode_sig_w) begin
		if((mode_r == OP_RED_DEP) && |oper_depth_r) begin //oper_depth_r != 2'b00
			oper_depth_w = oper_depth_r - 1'b1;
		end
		else if((mode_r == OP_INC_DEP) && (oper_depth_r != 2'b10)) begin
			oper_depth_w = oper_depth_r + 1'b1;
		end
		else begin
			oper_depth_w = oper_depth_r;
		end
	end
	else begin
		oper_depth_w = oper_depth_r;
	end
end

assign oper_addr_0  = {disp_addr_y_r ,disp_addr_x_r} - 6'd9;
assign oper_addr_1  = {disp_addr_y_r ,disp_addr_x_r} - 6'd8;
assign oper_addr_2  = {disp_addr_y_r ,disp_addr_x_r} - 6'd7;
assign oper_addr_3  = {disp_addr_y_r ,disp_addr_x_r} - 6'd6;

assign oper_addr_4  = {disp_addr_y_r ,disp_addr_x_r} - 6'd1;
assign oper_addr_5  = {disp_addr_y_r ,disp_addr_x_r};
assign oper_addr_6  = {disp_addr_y_r ,disp_addr_x_r} + 6'd1;
assign oper_addr_7  = {disp_addr_y_r ,disp_addr_x_r} + 6'd2;

assign oper_addr_8  = {disp_addr_y_r ,disp_addr_x_r} + 6'd7;
assign oper_addr_9  = {disp_addr_y_r ,disp_addr_x_r} + 6'd8;
assign oper_addr_10 = {disp_addr_y_r ,disp_addr_x_r} + 6'd9;
assign oper_addr_11 = {disp_addr_y_r ,disp_addr_x_r} + 6'd10;

assign oper_addr_12 = {disp_addr_y_r ,disp_addr_x_r} + 6'd15;
assign oper_addr_13 = {disp_addr_y_r ,disp_addr_x_r} + 6'd16;
assign oper_addr_14 = {disp_addr_y_r ,disp_addr_x_r} + 6'd17;
assign oper_addr_15 = {disp_addr_y_r ,disp_addr_x_r} + 6'd18;


// ---------------------------------------------------------------------------
// Operation Blocks
// ---------------------------------------------------------------------------
// ---- Write your operation block design here ---- //

genvar conv2ly_var;
generate
	for(conv2ly_var = 0; conv2ly_var < 4; conv2ly_var = conv2ly_var + 1) begin:conv2ly_loop
		assign conv2ly_ul_w[conv2ly_var] = o_adder_ul_g1_w[conv2ly_var] + o_adder_ul_g2_w[conv2ly_var];
		assign conv2ly_ur_w[conv2ly_var] = o_adder_ur_g1_w[conv2ly_var] + o_adder_ur_g2_w[conv2ly_var];
		assign conv2ly_ll_w[conv2ly_var] = o_adder_ll_g1_w[conv2ly_var] + o_adder_ll_g2_w[conv2ly_var];
		assign conv2ly_lr_w[conv2ly_var] = o_adder_lr_g1_w[conv2ly_var] + o_adder_lr_g2_w[conv2ly_var];
		
		always @(posedge i_clk or negedge i_rst_n) begin
			if (!i_rst_n) begin
				conv2ly_ul_r[conv2ly_var] <= {(OUT_DATA_W+3){1'b0}};
				conv2ly_ur_r[conv2ly_var] <= {(OUT_DATA_W+3){1'b0}};
				conv2ly_ll_r[conv2ly_var] <= {(OUT_DATA_W+3){1'b0}};
				conv2ly_lr_r[conv2ly_var] <= {(OUT_DATA_W+3){1'b0}};
			end
			else begin
				conv2ly_ul_r[conv2ly_var] <= conv2ly_ul_w[conv2ly_var];
				conv2ly_ur_r[conv2ly_var] <= conv2ly_ur_w[conv2ly_var];
				conv2ly_ll_r[conv2ly_var] <= conv2ly_ll_w[conv2ly_var];
				conv2ly_lr_r[conv2ly_var] <= conv2ly_lr_w[conv2ly_var];
			end
		end
	end
endgenerate

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		convresult_ul_r <= {(OUT_DATA_W+3){1'b0}};
		convresult_ur_r <= {(OUT_DATA_W+3){1'b0}};
		convresult_ll_r <= {(OUT_DATA_W+3){1'b0}};
		convresult_lr_r <= {(OUT_DATA_W+3){1'b0}};
	end
	else begin
		convresult_ul_r <= convresult_ul_w;
		convresult_ur_r <= convresult_ur_w;
		convresult_ll_r <= convresult_ll_w;
		convresult_lr_r <= convresult_lr_w;
	end
end

assign convresult_ul_w = (conv2ly_ul_r[0] + conv2ly_ul_r[1]) + (conv2ly_ul_r[2] + conv2ly_ul_r[3]);
assign convresult_ur_w = (conv2ly_ur_r[0] + conv2ly_ur_r[1]) + (conv2ly_ur_r[2] + conv2ly_ur_r[3]);
assign convresult_ll_w = (conv2ly_ll_r[0] + conv2ly_ll_r[1]) + (conv2ly_ll_r[2] + conv2ly_ll_r[3]);
assign convresult_lr_w = (conv2ly_lr_r[0] + conv2ly_lr_r[1]) + (conv2ly_lr_r[2] + conv2ly_lr_r[3]);

// ---------------------------------------------------------------------------
// Instantiation
// ---------------------------------------------------------------------------
// ---- Add your instantiation here if needed ---- //
assign SRAM_wen[0] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b000));
assign SRAM_wen[1] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b001));
assign SRAM_wen[2] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b010));
assign SRAM_wen[3] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b011));
assign SRAM_wen[4] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b100));
assign SRAM_wen[5] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b101));
assign SRAM_wen[6] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b110));
assign SRAM_wen[7] = ~(i_in_valid && (disp_addr_z_r[2:0] == 3'b111));

assign SRAM_a = SRAM_a_w;
assign SRAM_d = i_in_data;

always @(*) begin
	if(oper_sig_w) begin
		case(counter_r[3:0])
			4'd0: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_5};
			end
			4'd1: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_6};
			end
			4'd2: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_7};
			end
			4'd3: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_8};
			end
			4'd4: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_9};
			end
			4'd5: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_10};
			end
			4'd6: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_11};
			end
			4'd7: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_12};
			end
			4'd8: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_13};
			end
			4'd9: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_14};
			end
			4'd10: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_15};
			end
			4'd11: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_0};
			end
			4'd12: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_1};
			end
			4'd13: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_2};
			end
			4'd14: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_3};
			end
			4'd15: begin
				SRAM_a_w = {counter_r[5:4], oper_addr_4};
			end
			default: begin
				SRAM_a_w = {disp_addr_z_r[4:3] ,disp_addr_y_r ,disp_addr_x_r};
			end
		endcase
	end
	else if(out_sig_w) begin
		case(counter_r[1:0])
			2'd0: begin
				SRAM_a_w = {counter_r[6:5] ,oper_addr_5};
			end
			2'd1: begin
				SRAM_a_w = {counter_r[6:5] ,oper_addr_6};
			end
			2'd2: begin
				SRAM_a_w = {counter_r[6:5] ,oper_addr_9};
			end
			2'd3: begin
				SRAM_a_w = {counter_r[6:5] ,oper_addr_10};
			end
			default: begin
				SRAM_a_w = {disp_addr_z_r[4:3] ,disp_addr_y_r ,disp_addr_x_r};
			end
		endcase
	end
	else begin
		SRAM_a_w = {disp_addr_z_r[4:3] ,disp_addr_y_r ,disp_addr_x_r};
	end
end

always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		SRAM_cen_r <= 1'b1;
	end
	else begin
		SRAM_cen_r <= 1'b0;
	end
end

genvar SRAM_inst;
generate
	for(SRAM_inst = 0; SRAM_inst < NUM_SRAM; SRAM_inst = SRAM_inst + 1) begin:SRAM_inst_loop
		sram_256x8 u_sram (
			.Q(SRAM_q[SRAM_inst]),
			.CLK(i_clk),
			.CEN(SRAM_cen_r),
			.WEN(SRAM_wen[SRAM_inst]),
			.A(SRAM_a),
			.D(SRAM_d)
			);
	end
endgenerate

assign adder_oper_w = ~((oper_sig_w || out_sig_w) && mode_r[3] && (~mode_r[0]));
assign adder_oper_temp = (oper_c_state == OPER_LOAD_0)
						|| (oper_c_state == OPER_LOAD_1)
						|| (oper_c_state == OPER_LOAD_2)
						|| (oper_c_state == OPER_LOAD_3);

genvar adder_in_var;
generate
	for(adder_in_var = 0; adder_in_var < 4; adder_in_var = adder_in_var + 1) begin:a_in_loop
		always @(*) begin
			if((mode_r == OP_CONV) && adder_oper_temp) begin
				adder_in_data_g1[adder_in_var] = SRAM_q[adder_in_var];
				adder_in_data_g2[adder_in_var] = SRAM_q[adder_in_var+(NUM_SRAM/2)];
			end
			else if((mode_r == OP_SG_NMS) && adder_oper_temp) begin
				adder_in_data_g1[adder_in_var] = SRAM_q[adder_in_var];
				adder_in_data_g2[adder_in_var] = SRAM_q[adder_in_var];
			end
			else begin
				adder_in_data_g1[adder_in_var] = {DATA_WIDTH{1'b0}};
				adder_in_data_g2[adder_in_var] = {DATA_WIDTH{1'b0}};
			end
		end
	end
endgenerate

genvar adder_inst_g1;
generate
	for(adder_inst_g1 = 0; adder_inst_g1 < (NUM_SRAM/2); adder_inst_g1 = adder_inst_g1 + 1) begin:adder_g1
		adder_unit_g1 #(
		    .DATA_WIDTH(DATA_WIDTH),
		    .OUT_DATA_W(OUT_DATA_W-1),
			.NUM_OPER_PERLAYER(NUM_SRAM/2)
		) u_adder_unit_g1 (
			.i_clk(i_clk),
			.i_rst_n(i_rst_n),
			.i_clear(adder_oper_w),
			.i_in_data(adder_in_data_g1[adder_inst_g1]),

			//[4] high means conv and low means sobel, [3:0] address
			.i_coe_mode_addr({mode_r[1] ,counter_control_r[3:0]}),
			.o_out_data_ul(o_adder_ul_g1_w[adder_inst_g1]),
			.o_out_data_ur(o_adder_ur_g1_w[adder_inst_g1]),
			.o_out_data_ll(o_adder_ll_g1_w[adder_inst_g1]),
			.o_out_data_lr(o_adder_lr_g1_w[adder_inst_g1])
		);
	end
endgenerate

genvar adder_inst_g2;
generate
	for(adder_inst_g2 = 0; adder_inst_g2 < (NUM_SRAM/2); adder_inst_g2 = adder_inst_g2 + 1) begin:adder_g2
		adder_unit_g2 #(
		    .DATA_WIDTH(DATA_WIDTH),
		    .OUT_DATA_W(OUT_DATA_W-1),
			.NUM_OPER_PERLAYER(NUM_SRAM/2)
		) u_adder_unit_g2 (
			.i_clk(i_clk),
			.i_rst_n(i_rst_n),
			.i_clear(adder_oper_w),
			.i_in_data(adder_in_data_g2[adder_inst_g2]),

			//[4] high means conv and low means sobel, [3:0] address
			.i_coe_mode_addr({mode_r[1] ,counter_control_r[3:0]}),
			.o_out_data_ul(o_adder_ul_g2_w[adder_inst_g2]),
			.o_out_data_ur(o_adder_ur_g2_w[adder_inst_g2]),
			.o_out_data_ll(o_adder_ll_g2_w[adder_inst_g2]),
			.o_out_data_lr(o_adder_lr_g2_w[adder_inst_g2])
		);
	end
endgenerate

genvar median_in_var;
generate
	for(median_in_var = 0; median_in_var < 4; median_in_var = median_in_var + 1) begin:m_in_loop
		always @(*) begin
			if(oper_sig_w) begin
				median_in_w[median_in_var] = SRAM_q[median_in_var];
			end
			else begin
				median_in_w[median_in_var] = {DATA_WIDTH{1'b0}};
			end
		end
	end
endgenerate

assign median_oper_w = ~((oper_sig_w || out_sig_w) && (mode_r == OP_MF));

genvar median_var;
generate
	for(median_var = 0; median_var < 4; median_var = median_var + 1) begin: median_loop
		median #(
    		.DATA_WIDTH(DATA_WIDTH)
		) u_median (
			.i_clk(i_clk),
			.i_rst_n(i_rst_n),
			.i_clear(median_oper_w),
			.addr(counter_control_r[3:0]),
			.i_hold(out_sig_w),
			.i_in_data(median_in_w[median_var]),
			.o_out_data_ul(median_out_data_ul[median_var]),
			.o_out_data_ur(median_out_data_ur[median_var]),
			.o_out_data_ll(median_out_data_ll[median_var]),
			.o_out_data_lr(median_out_data_lr[median_var])
		);
	end
endgenerate

genvar sobel_in_var;
generate
	for(sobel_in_var = 0; sobel_in_var < 4; sobel_in_var = sobel_in_var+ 1) begin:sobel_in_loop
		assign sobel_gx_ul_in_w[sobel_in_var] = o_adder_ul_g1_w[sobel_in_var];
		assign sobel_gy_ul_in_w[sobel_in_var] = o_adder_ul_g2_w[sobel_in_var];
		assign sobel_gx_ur_in_w[sobel_in_var] = o_adder_ur_g1_w[sobel_in_var];
		assign sobel_gy_ur_in_w[sobel_in_var] = o_adder_ur_g2_w[sobel_in_var];
		assign sobel_gx_ll_in_w[sobel_in_var] = o_adder_ll_g1_w[sobel_in_var];
		assign sobel_gy_ll_in_w[sobel_in_var] = o_adder_ll_g2_w[sobel_in_var];
		assign sobel_gx_lr_in_w[sobel_in_var] = o_adder_lr_g1_w[sobel_in_var];
		assign sobel_gy_lr_in_w[sobel_in_var] = o_adder_lr_g2_w[sobel_in_var];
	end
endgenerate

genvar sobel_var;
generate
	for(sobel_var = 0; sobel_var < 4; sobel_var = sobel_var + 1) begin:sobel_loop
		sobel_nms_unit #(
		    .DATA_WIDTH(11),
		    .OUT_DATA_W(11)
		) u_sobel_nms_unit (
			.i_clk(i_clk),
			.i_rst_n(i_rst_n),
			.i_in_gx_ul(sobel_gx_ul_in_w[sobel_var]),
			.i_in_gy_ul(sobel_gy_ul_in_w[sobel_var]),
			.i_in_gx_ur(sobel_gx_ur_in_w[sobel_var]),
			.i_in_gy_ur(sobel_gy_ur_in_w[sobel_var]),
			.i_in_gx_ll(sobel_gx_ll_in_w[sobel_var]),
			.i_in_gy_ll(sobel_gy_ll_in_w[sobel_var]),
			.i_in_gx_lr(sobel_gx_lr_in_w[sobel_var]),
			.i_in_gy_lr(sobel_gy_lr_in_w[sobel_var]),
			.o_out_data_ul(sobel_g_ul_out_w[sobel_var]),
			.o_out_data_ur(sobel_g_ur_out_w[sobel_var]),
			.o_out_data_ll(sobel_g_ll_out_w[sobel_var]),
			.o_out_data_lr(sobel_g_lr_out_w[sobel_var])
		);
	end
endgenerate


endmodule
