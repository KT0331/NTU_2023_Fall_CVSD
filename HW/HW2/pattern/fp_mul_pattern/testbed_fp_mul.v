`timescale 1ns/100ps
`define CYCLE       10.0
`define HCYCLE      (`CYCLE/2)
`define RST_DELAY   2
`define MAX_CYCLE   1000000
`define PAT_NUM     40000

`define I_DATA   "../00_TESTBED/fp_mul_I.dat"
`define O_DATA   "../00_TESTBED/fp_mul_O.dat"

module testbed;

	reg  clk, rst_n;
	reg  [ 31 : 0 ] i_data_a;
	reg  [ 31 : 0 ] i_data_b;
	wire [ 31 : 0 ] fp_mul_o;

	reg  [ 63 : 0 ] in_data[0:`PAT_NUM-1];
	reg  [ 31 : 0 ] out_data[0:`PAT_NUM-1];
	reg  [ 31 : 0 ] golden_data[0:`PAT_NUM-1];

	integer i;
	integer j;
	integer j_d;
	integer ending;
	integer error_status;
	integer error_data;

	initial begin
		$readmemb (`I_DATA, in_data);
		$readmemb (`O_DATA, golden_data);
	end

	fp_mul #(
    .INT_W(9),
    .FRAC_W(23),
    .DATA_W(32)
)(
    .i_data_a(i_data_a),
    .i_data_b(i_data_b),
    .fp_mul_o(fp_mul_o)
);

	initial begin
		clk = 0;
	end
	always #(`HCYCLE) clk = ~clk;

	initial begin
       $fsdbDumpfile("fp_mul.fsdb");
       $fsdbDumpvars(0, testbed, "+mda");
    end 

    initial begin
    	rst_n        = 1;
    	i            = 0;
    	j            = 0;
    	j_d          = 0;
    	error_data   = 0;

    	forever @(negedge clk) begin
			if (i < `PAT_NUM) begin
				out_data[i] = fp_mul_o;
				if(out_data[i] !== fp_mul_o) begin
					$display ("out_data[%d]: Error! Golden=%b ,Yours=%b", i, out_data[i], fp_mul_o);
					$finish;
				end
				i = i+1;
			end
		end
	end

	always @(negedge clk) begin
		if (i < `PAT_NUM) begin
			{i_data_a,i_data_b} = in_data[i];
		end
	end

	initial begin
		wait(i == `PAT_NUM);
		#(`HCYCLE)

		// test data
		for(j_d = 0; j_d < `PAT_NUM; j_d = j_d + 1) begin
			if(golden_data[j_d] !== out_data[j_d]) begin
				$display ("out_data[%d]: Error! Golden=%b ,Yours=%b", j_d, out_data[j_d], fp_mul_o); 
				error_data = error_data + 1;
			end
		end

		if(error_data === 0) begin
       	   	$display ("------------------------------------------------------------------");
  			$display ("            ~(￣▽￣)~(＿△＿)~(￣▽￣)~(＿△＿)~(￣▽￣)~              ");
  			$display ("                        Congratulations!                          -");
  			$display ("                You have passed this patterns!!                   -");
  			$display ("-------------------------------------------------------------------");
		end
		else begin
			$display ("--------------------------------------------------------------------");
  			$display ("                           So Sad(╥﹏╥)                             ");
  			$display ("                    You cannot pass this pattern                    ");
  			$display ("--------------------------------------------------------------------");
		end
		$finish;
    end

    initial begin
        # (`MAX_CYCLE * `CYCLE);
        $display("----------------------------------------------");
        $display("                    (`へ´≠)                    ");
        $display("Latency of your design is over 120000 cycles!!");
        $display("----------------------------------------------");
        $finish;
    end
//================================================================
// task
//================================================================
    /*task reset_task; begin
        # ( 0.20 * `CYCLE);
        rst_n = 0;    
        # ( 0.05 * `CYCLE);
        if((imem_addr !== 0)||(dmem_we !== 0)||(dmem_addr !== 0)
        	||(dmem_wdata !== 0)||(mips_status !== 0)||(mips_status_valid !== 0)) begin
  			$display("**************************************************************");
  			$display("*   Output signal should be 0 after initial RESET at %4t     *",$time);
  			$display("**************************************************************");
  			$finish;
  		end
        # ((`RST_DELAY) * `CYCLE);
        rst_n = 1;    
    end endtask*/

endmodule
