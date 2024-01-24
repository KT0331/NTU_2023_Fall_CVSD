module median #(
    parameter DATA_WIDTH = 8
) (
	input                   i_clk,
	input                   i_rst_n,
	input                   i_clear,
	input  [           3:0] addr,
	input                   i_hold,
	input  [DATA_WIDTH-1:0] i_in_data,
	output [DATA_WIDTH-1:0] o_out_data_ul,
	output [DATA_WIDTH-1:0] o_out_data_ur,
	output [DATA_WIDTH-1:0] o_out_data_ll,
	output [DATA_WIDTH-1:0] o_out_data_lr
);

reg  [DATA_WIDTH-1:0]  ul_data_r[0:4];
reg  [DATA_WIDTH-1:0]  ur_data_r[0:4];
reg  [DATA_WIDTH-1:0]  ll_data_r[0:4];
reg  [DATA_WIDTH-1:0]  lr_data_r[0:4];

reg  [DATA_WIDTH-1:0]  ul_data_w[0:4];
reg  [DATA_WIDTH-1:0]  ur_data_w[0:4];
reg  [DATA_WIDTH-1:0]  ll_data_w[0:4];
reg  [DATA_WIDTH-1:0]  lr_data_w[0:4];

wire                   ul_valid;
wire                   ur_valid;
wire                   ll_valid;
wire                   lr_valid;

wire                   ul_less[0:4];
wire                   ur_less[0:4];
wire                   ll_less[0:4];
wire                   lr_less[0:4];

assign o_out_data_ul = ul_data_r[4];
assign o_out_data_ur = ur_data_r[4];
assign o_out_data_ll = ll_data_r[4];
assign o_out_data_lr = lr_data_r[4];

assign ul_valid = !((addr == 4'd14) || (addr == 4'd2) || (addr == 4'd6)
				  || (addr == 4'd7) || (addr == 4'd8) || (addr == 4'd9)
				  || (addr == 4'd10));
assign ur_valid = !((addr == 4'd11) || (addr == 4'd15) || (addr == 4'd3)
				  || (addr == 4'd7) || (addr == 4'd8) || (addr == 4'd9)
				  || (addr == 4'd10));
assign ll_valid = !((addr == 4'd11) || (addr == 4'd12) || (addr == 4'd13)
				  || (addr == 4'd14) || (addr == 4'd2) || (addr == 4'd6)
				  || (addr == 4'd10));
assign lr_valid = !((addr == 4'd11) || (addr == 4'd12) || (addr == 4'd13)
				  || (addr == 4'd14) || (addr == 4'd15) || (addr == 4'd3)
				  || (addr == 4'd7));

genvar less_var;
generate
	for(less_var = 0; less_var < 5; less_var = less_var + 1) begin:less_loop
		assign ul_less[less_var] = i_in_data > ul_data_r[less_var];
		assign ur_less[less_var] = i_in_data > ur_data_r[less_var];
		assign ll_less[less_var] = i_in_data > ll_data_r[less_var];
		assign lr_less[less_var] = i_in_data > lr_data_r[less_var];
	end
endgenerate

genvar reg_loop;
generate
	for(reg_loop = 0; reg_loop < 5; reg_loop = reg_loop + 1) begin:storage_loop
		always @(posedge i_clk or negedge i_rst_n) begin
			if (!i_rst_n) begin
				ul_data_r[reg_loop] <= {DATA_WIDTH{1'b0}};
				ur_data_r[reg_loop] <= {DATA_WIDTH{1'b0}};
				ll_data_r[reg_loop] <= {DATA_WIDTH{1'b0}};
				lr_data_r[reg_loop] <= {DATA_WIDTH{1'b0}};
			end
			else begin
				ul_data_r[reg_loop] <= ul_data_w[reg_loop];
				ur_data_r[reg_loop] <= ur_data_w[reg_loop];
				ll_data_r[reg_loop] <= ll_data_w[reg_loop];
				lr_data_r[reg_loop] <= lr_data_w[reg_loop];
			end
		end
	end
endgenerate

always @(*) begin
	if(i_clear) begin
		ul_data_w[0] = {DATA_WIDTH{1'b0}};
		ul_data_w[1] = {DATA_WIDTH{1'b0}};
		ul_data_w[2] = {DATA_WIDTH{1'b0}};
		ul_data_w[3] = {DATA_WIDTH{1'b0}};
		ul_data_w[4] = {DATA_WIDTH{1'b0}};
	end
	else if(ul_valid && (~i_hold)) begin
		if(ul_less[0]) begin
			ul_data_w[0] = i_in_data;
			ul_data_w[1] = ul_data_r[0];
			ul_data_w[2] = ul_data_r[1];
			ul_data_w[3] = ul_data_r[2];
			ul_data_w[4] = ul_data_r[3];
		end
		else if(ul_less[1]) begin
			ul_data_w[0] = ul_data_r[0];
			ul_data_w[1] = i_in_data;
			ul_data_w[2] = ul_data_r[1];
			ul_data_w[3] = ul_data_r[2];
			ul_data_w[4] = ul_data_r[3];
		end
		else if(ul_less[2]) begin
			ul_data_w[0] = ul_data_r[0];
			ul_data_w[1] = ul_data_r[1];
			ul_data_w[2] = i_in_data;
			ul_data_w[3] = ul_data_r[2];
			ul_data_w[4] = ul_data_r[3];
		end
		else if(ul_less[3]) begin
			ul_data_w[0] = ul_data_r[0];
			ul_data_w[1] = ul_data_r[1];
			ul_data_w[2] = ul_data_r[2];
			ul_data_w[3] = i_in_data;
			ul_data_w[4] = ul_data_r[3];
		end
		else if(ul_less[4]) begin
			ul_data_w[0] = ul_data_r[0];
			ul_data_w[1] = ul_data_r[1];
			ul_data_w[2] = ul_data_r[2];
			ul_data_w[3] = ul_data_r[3];
			ul_data_w[4] = i_in_data;
		end
		else begin
			ul_data_w[0] = ul_data_r[0];
			ul_data_w[1] = ul_data_r[1];
			ul_data_w[2] = ul_data_r[2];
			ul_data_w[3] = ul_data_r[3];
			ul_data_w[4] = ul_data_r[4];
		end
	end
	else begin
		ul_data_w[0] = ul_data_r[0];
		ul_data_w[1] = ul_data_r[1];
		ul_data_w[2] = ul_data_r[2];
		ul_data_w[3] = ul_data_r[3];
		ul_data_w[4] = ul_data_r[4];
	end
end

always @(*) begin
	if(i_clear) begin
		ur_data_w[0] = {DATA_WIDTH{1'b0}};
		ur_data_w[1] = {DATA_WIDTH{1'b0}};
		ur_data_w[2] = {DATA_WIDTH{1'b0}};
		ur_data_w[3] = {DATA_WIDTH{1'b0}};
		ur_data_w[4] = {DATA_WIDTH{1'b0}};
	end
	else if(ur_valid && (~i_hold)) begin
		if(ur_less[0]) begin
			ur_data_w[0] = i_in_data;
			ur_data_w[1] = ur_data_r[0];
			ur_data_w[2] = ur_data_r[1];
			ur_data_w[3] = ur_data_r[2];
			ur_data_w[4] = ur_data_r[3];
		end
		else if(ur_less[1]) begin
			ur_data_w[0] = ur_data_r[0];
			ur_data_w[1] = i_in_data;
			ur_data_w[2] = ur_data_r[1];
			ur_data_w[3] = ur_data_r[2];
			ur_data_w[4] = ur_data_r[3];
		end
		else if(ur_less[2]) begin
			ur_data_w[0] = ur_data_r[0];
			ur_data_w[1] = ur_data_r[1];
			ur_data_w[2] = i_in_data;
			ur_data_w[3] = ur_data_r[2];
			ur_data_w[4] = ur_data_r[3];
		end
		else if(ur_less[3]) begin
			ur_data_w[0] = ur_data_r[0];
			ur_data_w[1] = ur_data_r[1];
			ur_data_w[2] = ur_data_r[2];
			ur_data_w[3] = i_in_data;
			ur_data_w[4] = ur_data_r[3];
		end
		else if(ur_less[4]) begin
			ur_data_w[0] = ur_data_r[0];
			ur_data_w[1] = ur_data_r[1];
			ur_data_w[2] = ur_data_r[2];
			ur_data_w[3] = ur_data_r[3];
			ur_data_w[4] = i_in_data;
		end
		else begin
			ur_data_w[0] = ur_data_r[0];
			ur_data_w[1] = ur_data_r[1];
			ur_data_w[2] = ur_data_r[2];
			ur_data_w[3] = ur_data_r[3];
			ur_data_w[4] = ur_data_r[4];
		end
	end
	else begin
		ur_data_w[0] = ur_data_r[0];
		ur_data_w[1] = ur_data_r[1];
		ur_data_w[2] = ur_data_r[2];
		ur_data_w[3] = ur_data_r[3];
		ur_data_w[4] = ur_data_r[4];
	end
end

always @(*) begin
	if(i_clear) begin
		ll_data_w[0] = {DATA_WIDTH{1'b0}};
		ll_data_w[1] = {DATA_WIDTH{1'b0}};
		ll_data_w[2] = {DATA_WIDTH{1'b0}};
		ll_data_w[3] = {DATA_WIDTH{1'b0}};
		ll_data_w[4] = {DATA_WIDTH{1'b0}};
	end
	else if(ll_valid && (~i_hold)) begin
		if(ll_less[0]) begin
			ll_data_w[0] = i_in_data;
			ll_data_w[1] = ll_data_r[0];
			ll_data_w[2] = ll_data_r[1];
			ll_data_w[3] = ll_data_r[2];
			ll_data_w[4] = ll_data_r[3];
		end
		else if(ll_less[1]) begin
			ll_data_w[0] = ll_data_r[0];
			ll_data_w[1] = i_in_data;
			ll_data_w[2] = ll_data_r[1];
			ll_data_w[3] = ll_data_r[2];
			ll_data_w[4] = ll_data_r[3];
		end
		else if(ll_less[2]) begin
			ll_data_w[0] = ll_data_r[0];
			ll_data_w[1] = ll_data_r[1];
			ll_data_w[2] = i_in_data;
			ll_data_w[3] = ll_data_r[2];
			ll_data_w[4] = ll_data_r[3];
		end
		else if(ll_less[3]) begin
			ll_data_w[0] = ll_data_r[0];
			ll_data_w[1] = ll_data_r[1];
			ll_data_w[2] = ll_data_r[2];
			ll_data_w[3] = i_in_data;
			ll_data_w[4] = ll_data_r[3];
		end
		else if(ll_less[4]) begin
			ll_data_w[0] = ll_data_r[0];
			ll_data_w[1] = ll_data_r[1];
			ll_data_w[2] = ll_data_r[2];
			ll_data_w[3] = ll_data_r[3];
			ll_data_w[4] = i_in_data;
		end
		else begin
			ll_data_w[0] = ll_data_r[0];
			ll_data_w[1] = ll_data_r[1];
			ll_data_w[2] = ll_data_r[2];
			ll_data_w[3] = ll_data_r[3];
			ll_data_w[4] = ll_data_r[4];
		end
	end
	else begin
		ll_data_w[0] = ll_data_r[0];
		ll_data_w[1] = ll_data_r[1];
		ll_data_w[2] = ll_data_r[2];
		ll_data_w[3] = ll_data_r[3];
		ll_data_w[4] = ll_data_r[4];
	end
end

always @(*) begin
	if(i_clear) begin
		lr_data_w[0] = {DATA_WIDTH{1'b0}};
		lr_data_w[1] = {DATA_WIDTH{1'b0}};
		lr_data_w[2] = {DATA_WIDTH{1'b0}};
		lr_data_w[3] = {DATA_WIDTH{1'b0}};
		lr_data_w[4] = {DATA_WIDTH{1'b0}};
	end
	else if(lr_valid && (~i_hold)) begin
		if(lr_less[0]) begin
			lr_data_w[0] = i_in_data;
			lr_data_w[1] = lr_data_r[0];
			lr_data_w[2] = lr_data_r[1];
			lr_data_w[3] = lr_data_r[2];
			lr_data_w[4] = lr_data_r[3];
		end
		else if(lr_less[1]) begin
			lr_data_w[0] = lr_data_r[0];
			lr_data_w[1] = i_in_data;
			lr_data_w[2] = lr_data_r[1];
			lr_data_w[3] = lr_data_r[2];
			lr_data_w[4] = lr_data_r[3];
		end
		else if(lr_less[2]) begin
			lr_data_w[0] = lr_data_r[0];
			lr_data_w[1] = lr_data_r[1];
			lr_data_w[2] = i_in_data;
			lr_data_w[3] = lr_data_r[2];
			lr_data_w[4] = lr_data_r[3];
		end
		else if(lr_less[3]) begin
			lr_data_w[0] = lr_data_r[0];
			lr_data_w[1] = lr_data_r[1];
			lr_data_w[2] = lr_data_r[2];
			lr_data_w[3] = i_in_data;
			lr_data_w[4] = lr_data_r[3];
		end
		else if(lr_less[4]) begin
			lr_data_w[0] = lr_data_r[0];
			lr_data_w[1] = lr_data_r[1];
			lr_data_w[2] = lr_data_r[2];
			lr_data_w[3] = lr_data_r[3];
			lr_data_w[4] = i_in_data;
		end
		else begin
			lr_data_w[0] = lr_data_r[0];
			lr_data_w[1] = lr_data_r[1];
			lr_data_w[2] = lr_data_r[2];
			lr_data_w[3] = lr_data_r[3];
			lr_data_w[4] = lr_data_r[4];
		end
	end
	else begin
		lr_data_w[0] = lr_data_r[0];
		lr_data_w[1] = lr_data_r[1];
		lr_data_w[2] = lr_data_r[2];
		lr_data_w[3] = lr_data_r[3];
		lr_data_w[4] = lr_data_r[4];
	end
end

endmodule