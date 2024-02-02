module gelu #(
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter INST_W = 4,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                     i_clk,
    input                     i_rst_n,
    input signed [DATA_W-1:0] i_data_a,
    output       [DATA_W-1:0] gelu_o_data
);

wire signed [2*DATA_W - 1:0]  i_data_a_squ; //total 32 bits
wire signed [2*DATA_W + 9:0]  tanh_backward_backward; //total 42 bits
wire signed [2*DATA_W + 10:0] tanh_backward; //total 43 bits
wire signed [DATA_W + 10:0]   tanh_forward;  //total 27 bits
wire signed [3*DATA_W + 21:0] tanh_x;        //total 70 bits, 1 bit signed 20 bits integer 49 fraction bits
wire        [3*DATA_W + 21:0] tanh_x_inv;    //2's complement of tanh_x
wire        [3*DATA_W - 17:0] tanh_x_nearest_inv; //2's complement of tanh_x_nearest
wire        [DATA_W-1:0]      tanh_x_in_inv; //2's complement of tanh_x_in
//tanh_x rounded to the nearest and ties to even total 32 (signed integer will increase 1 bit)
reg signed [3*DATA_W - 17:0]  tanh_x_nearest;
reg signed [DATA_W-1:0]       tanh_x_in; //Saturation or not

wire signed [DATA_W:0]        tanh_x_shift; //using at 2nd and 4th segment
wire signed [DATA_W+1:0]      tanh_x_shift_half;
wire signed [DATA_W+2:0]      tanh_y_shift;
wire signed [DATA_W+2:0]      tanh_y_shift_inv;
reg         [DATA_W-1:0]      tanh_x_in_abs; //2's complement of tanh_x_in
reg signed  [DATA_W-1:0]      tanh_y_shift_nearest;
reg signed  [DATA_W-1:0]      tanh_out;

wire signed [DATA_W:0]       tanh_out_plus_one;
wire signed [DATA_W:0]       i_data_a_half;
wire signed [2*DATA_W + 1:0] gelu_o_no_round;
wire signed [2*DATA_W - 9:0] gelu_o_round_inv; //14 signed integer and 10 fraction
reg signed  [2*DATA_W - 9:0] gelu_o_round; //14 signed integer and 10 fraction
reg signed  [DATA_W-1:0]     gelu_o_data_r;

wire signed [30:0]           ones; //1 signed bit, 1 integer bit and 29 fraction
wire signed [DATA_W-1:0]     ones_tanh_o;
wire signed [DATA_W-1:0]     zero_point_five;
wire signed [DATA_W+1:0]     zero_point_five_1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                parameters                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam GELU_1st_coe  = 10'sb0_0000_1011_1;  //1 signed bit and 9 bits fraction
localparam GELU_2st_coe  = 11'sb0_1100_1100_01; //1 signed bit and 10 bits fraction

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign ones = {2'b01 ,29'b0};

//1st operation
assign i_data_a_squ           = i_data_a * i_data_a;
assign tanh_backward_backward = i_data_a_squ * GELU_1st_coe;
assign tanh_backward          = ones + tanh_backward_backward;
assign tanh_forward           = i_data_a * GELU_2st_coe;
assign tanh_x                 = tanh_forward * tanh_backward;

assign tanh_x_inv         = ~tanh_x + 1'b1;
assign tanh_x_nearest_inv = ~tanh_x_nearest + 1'b1;

//Round to nearest
always @(*) begin
    tanh_x_nearest = {tanh_x[69] ,tanh_x[69:49] ,tanh_x[48:39]} + tanh_x[38];
end

//saturation or not
always @(*) begin
    if(!tanh_x_nearest[31]) begin //tanh_x_nearest is positive
        if(|tanh_x_nearest[30:15]) begin //tanh_x_nearest is saturation
            tanh_x_in = {1'b0 ,{15{1'b1}}};
        end
        else begin //tanh_x_nearest is not saturation
            tanh_x_in = {tanh_x_nearest[31] ,tanh_x_nearest[14:10] ,tanh_x_nearest[9:0]};
        end
    end
    else begin //tanh_x_nearest is negative
        if((!tanh_x_nearest_inv[31]) && (|tanh_x_nearest_inv[30:15])) begin //tanh_x_nearest_inv saturation
            tanh_x_in = {1'b1 ,{15{1'b0}}};
        end
        else if(tanh_x_nearest_inv[31]) begin //tanh_x is negative and saturation
            tanh_x_in = {1'b1 ,{15{1'b0}}};
        end
        else begin
            tanh_x_in = ~{tanh_x_nearest_inv[31] ,tanh_x_nearest_inv[14:10] ,tanh_x_nearest_inv[9:0]} + 1'b1;
        end
    end
end

//2nd operation
assign zero_point_five   = {{INT_W{1'b0}} ,1'b1 ,{(FRAC_W-1){1'b0}}};
assign zero_point_five_1 = {{(INT_W+1){1'b0}} ,1'b1 ,{(FRAC_W){1'b0}}};
assign ones_tanh_o       = {{(INT_W-1){1'b0}} ,1'b1 ,{(FRAC_W){1'b0}}};

assign tanh_x_in_inv     = ~tanh_x_in + 1'b1;
assign tanh_x_shift      = tanh_x_in_abs - zero_point_five;
assign tanh_x_shift_half = {1'b0 ,tanh_x_shift};
assign tanh_y_shift      = tanh_x_shift_half + zero_point_five_1; //tanh_y_shift must be a positive
assign tanh_y_shift_inv  = ~tanh_y_shift + 1'b1;

always @(*) begin
    if(!tanh_x_in[DATA_W-1]) begin
        tanh_x_in_abs = tanh_x_in;
    end
    else begin
        tanh_x_in_abs = tanh_x_in_inv;
    end
end

//Round to nearest
always @(*) begin
    if(!tanh_x_in[DATA_W-1]) begin //tanh_x_in is positive
        tanh_y_shift_nearest = {tanh_y_shift[DATA_W+2] ,tanh_y_shift[DATA_W-1:1]} + tanh_y_shift[0];
    end
    else begin //tanh_x_in is negative
        tanh_y_shift_nearest = {tanh_y_shift_inv[DATA_W+2] ,tanh_y_shift_inv[DATA_W-1:1]} + tanh_y_shift_inv[0];
    end
end

always @(*) begin
    if(!tanh_x_in[DATA_W-1]) begin //tanh_x_in is positive
        //greater than 1.5 or equal to 1.5
        if((|tanh_x_in[DATA_W-1:FRAC_W+1]) || (&tanh_x_in[FRAC_W:FRAC_W-1])) begin
            tanh_out = ones_tanh_o;
        end
        //less than 0.5 or equal to 0.5
        else if ((~(|tanh_x_in[DATA_W-1:FRAC_W-1]))
                 || ((tanh_x_in[FRAC_W-1]) && (~(|tanh_x_in[FRAC_W-2:0])))) begin
            tanh_out = tanh_x_in;
        end
        else begin
            tanh_out = tanh_y_shift_nearest;
        end
    end
    else begin //tanh_x_in is negative
        //less than -1.5 or equal to -1.5
        if((|tanh_x_in_inv[DATA_W-1:FRAC_W+1]) || (&tanh_x_in_inv[FRAC_W:FRAC_W-1])) begin
            tanh_out = ~ones_tanh_o + 1'b1;
        end
        //greater than -0.5 or equal to -0.5
        else if ((~(|tanh_x_in_inv[DATA_W-1:FRAC_W-1])
                  || ((tanh_x_in_inv[FRAC_W-1]) && (~(|tanh_x_in_inv[FRAC_W-2:0]))))) begin
            tanh_out = tanh_x_in;
        end
        else begin
            tanh_out = tanh_y_shift_nearest;
        end
    end
end

//3rd operation
assign tanh_out_plus_one   = tanh_out + ones_tanh_o;
assign i_data_a_half       = {i_data_a[DATA_W-1] ,i_data_a};
assign gelu_o_no_round     = tanh_out_plus_one * i_data_a_half;
assign gelu_o_round_inv    = ~gelu_o_round + 1'b1;

//Round to nearest
always @(*) begin
    gelu_o_round = {gelu_o_no_round[2*DATA_W + 1] ,gelu_o_no_round[2*DATA_W + 1:11]} + gelu_o_no_round[10];
end

//saturation or not
always @(*) begin
    if(!gelu_o_round[23]) begin //gelu_o_round is positive
        if(|gelu_o_round[22:15]) begin //gelu_o_round is saturation
            gelu_o_data_r = {1'b0 ,{15{1'b1}}};
        end
        else begin //gelu_o_round is not saturation
            gelu_o_data_r = {gelu_o_round[23] ,gelu_o_round[14:10] ,gelu_o_round[9:0]};
        end
    end
    else begin //gelu_o_round is negative
        if((!gelu_o_round_inv[23]) && (|gelu_o_round_inv[22:15])) begin //gelu_o_round_inv saturation
            gelu_o_data_r = {1'b1 ,{15{1'b0}}};
        end
        else if(gelu_o_round_inv[23]) begin //tanh_x is negative and saturation
            gelu_o_data_r = {1'b1 ,{15{1'b0}}};
        end
        else begin
            gelu_o_data_r = ~{gelu_o_round_inv[23] ,gelu_o_round_inv[14:10] ,gelu_o_round_inv[9:0]} + 1'b1;
        end
    end
end

assign gelu_o_data = gelu_o_data_r;

endmodule
