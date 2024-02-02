`timescale 1ns/100ps
`define CYCLE       10.0
`define HCYCLE      (`CYCLE/2)
`define RST_DELAY   2
`define MAX_CYCLE   120000

`ifdef p0
    `define Inst   "../00_TESTBED/PATTERN/p0/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p0/data.dat"
    `define Status "../00_TESTBED/PATTERN/p0/status.dat"
`endif
`ifdef p1
    `define Inst   "../00_TESTBED/PATTERN/p1/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p1/data.dat"
    `define Status "../00_TESTBED/PATTERN/p1/status.dat"
`endif
`ifdef p2
    `define Inst   "../00_TESTBED/PATTERN/p2/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p2/data.dat"
    `define Status "../00_TESTBED/PATTERN/p2/status.dat"
`endif
`ifdef p3
    `define Inst   "../00_TESTBED/PATTERN/p3/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p3/data.dat"
    `define Status "../00_TESTBED/PATTERN/p3/status.dat"
`endif
`ifdef p4
    `define Inst   "../00_TESTBED/PATTERN/p4/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p4/data.dat"
    `define Status "../00_TESTBED/PATTERN/p4/status.dat"
`endif
`ifdef p5
    `define Inst   "../00_TESTBED/PATTERN/p5/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p5/data.dat"
    `define Status "../00_TESTBED/PATTERN/p5/status.dat"
`endif
`ifdef p6
    `define Inst   "../00_TESTBED/PATTERN/p6/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p6/data.dat"
    `define Status "../00_TESTBED/PATTERN/p6/status.dat"
`endif
`ifdef p7
    `define Inst   "../00_TESTBED/PATTERN/p7/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p7/data.dat"
    `define Status "../00_TESTBED/PATTERN/p7/status.dat"
`endif
`ifdef p8
    `define Inst   "../00_TESTBED/PATTERN/p8/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p8/data.dat"
    `define Status "../00_TESTBED/PATTERN/p8/status.dat"
`endif
`ifdef p9
    `define Inst   "../00_TESTBED/PATTERN/p9/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p9/data.dat"
    `define Status "../00_TESTBED/PATTERN/p9/status.dat"
`endif
`ifdef p10
    `define Inst   "../00_TESTBED/PATTERN/p10/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p10/data.dat"
    `define Status "../00_TESTBED/PATTERN/p10/status.dat"
`endif
`ifdef p11
    `define Inst   "../00_TESTBED/PATTERN/p11/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p11/data.dat"
    `define Status "../00_TESTBED/PATTERN/p11/status.dat"
`endif
`ifdef p12
    `define Inst   "../00_TESTBED/PATTERN/p12/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p12/data.dat"
    `define Status "../00_TESTBED/PATTERN/p12/status.dat"
`endif
`ifdef p13
    `define Inst   "../00_TESTBED/PATTERN/p13/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p13/data.dat"
    `define Status "../00_TESTBED/PATTERN/p13/status.dat"
`endif
`ifdef p14
    `define Inst   "../00_TESTBED/PATTERN/p14/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p14/data.dat"
    `define Status "../00_TESTBED/PATTERN/p14/status.dat"
`endif
`ifdef p15
    `define Inst   "../00_TESTBED/PATTERN/p15/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p15/data.dat"
    `define Status "../00_TESTBED/PATTERN/p15/status.dat"
`endif
`ifdef p16
    `define Inst   "../00_TESTBED/PATTERN/p16/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p16/data.dat"
    `define Status "../00_TESTBED/PATTERN/p16/status.dat"
`endif
`ifdef p17
    `define Inst   "../00_TESTBED/PATTERN/p17/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p17/data.dat"
    `define Status "../00_TESTBED/PATTERN/p17/status.dat"
`endif
`ifdef p18
    `define Inst   "../00_TESTBED/PATTERN/p18/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p18/data.dat"
    `define Status "../00_TESTBED/PATTERN/p18/status.dat"
`endif
`ifdef p19
    `define Inst   "../00_TESTBED/PATTERN/p19/inst.dat"
    `define Data   "../00_TESTBED/PATTERN/p19/data.dat"
    `define Status "../00_TESTBED/PATTERN/p19/status.dat"
`endif
`ifdef h10
    `define STR "H10"
    `define Inst "../00_TESTBED/PATTERN/h10/inst.dat"
    `define Status "../00_TESTBED/PATTERN/h10/status.dat"
    `define Data "../00_TESTBED/PATTERN/h10/data.dat"
`endif

module testbed;

	reg  clk, rst_n;
	wire [ 31 : 0 ] imem_addr;
	wire [ 31 : 0 ] imem_inst;
	wire            dmem_we;
	wire [ 31 : 0 ] dmem_addr;
	wire [ 31 : 0 ] dmem_wdata;
	wire [ 31 : 0 ] dmem_rdata;
	wire [  1 : 0 ] mips_status;
	wire            mips_status_valid;

	reg  [ 31 : 0 ] golden_data[0:63];
	reg  [  1 : 0 ] golden_status[0:1023];
	reg  [  1 : 0 ] output_status[0:1023];

	integer i;
	integer j;
	integer j_d;
	integer ending;
	integer error_status;
	integer error_data;

	initial begin
		$readmemb (`Inst, u_inst_mem.mem_r);
		$readmemb (`Data, golden_data);
		$readmemb (`Status, golden_status);
	end

	core u_core (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.o_i_addr(imem_addr),
		.i_i_inst(imem_inst),
		.o_d_we(dmem_we),
		.o_d_addr(dmem_addr),
		.o_d_wdata(dmem_wdata),
		.i_d_rdata(dmem_rdata),
		.o_status(mips_status),
		.o_status_valid(mips_status_valid)
	);

	inst_mem  u_inst_mem (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.i_addr(imem_addr),
		.o_inst(imem_inst)
	);

	data_mem  u_data_mem (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.i_we(dmem_we),
		.i_addr(dmem_addr),
		.i_wdata(dmem_wdata),
		.o_rdata(dmem_rdata)
	);

	initial begin
		clk = 0;
	end
	always #(`HCYCLE) clk = ~clk;

	initial begin
       $fsdbDumpfile("core.fsdb");
       $fsdbDumpvars(0, testbed, "+mda");
    end 

    initial begin
    	rst_n        = 1;
    	i            = 0;
    	j            = 0;
    	j_d          = 0;
    	ending       = 0;
    	error_status = 0;
    	error_data   = 0;
    	reset_task;

    	forever @(negedge clk) begin
			if (i < 1024 && mips_status !== 2'd2 && mips_status !== 2'd3 && !ending) begin
				if(mips_status_valid)begin
					output_status[i] = mips_status;
					if(golden_status[i] !== mips_status) begin
						$display ("Status[%d]: Error! Golden=%b ,Yours=%b", i, golden_status[i], mips_status);
						$finish;
					end
					i = i+1;
					ending = 0;
				end
			end
			if ((mips_status === 2'd2 || mips_status === 2'd3) && !ending) begin
				output_status[i] = mips_status;
				if(golden_status[i] !== mips_status) begin
					$display ("Status[%d]: Error! Golden=%b ,Yours=%b", i, golden_status[i], mips_status);
					$finish;
				end
				i = i+1;
				ending = 1;
			end
		end
	end

	initial begin
		wait(ending);
		#(`HCYCLE)

		// test golden
		for(j = 0; j < i; j = j + 1) begin
			if(golden_status[j] !== output_status[j]) begin
				$display ("Status[%d]: Error! Golden=%b ,Yours=%b", j, golden_status[j], output_status[j]);
				error_status = error_status + 1; 
			end
		end

		// test data
		for(j_d = 0; j_d < 64; j_d = j_d + 1) begin
			if(golden_data[j_d] !== u_data_mem.mem_r[j_d]) begin
				$display ("Data[%d]: Error! Golden=%b ,Yours=%b", j_d, golden_data[j_d], u_data_mem.mem_r[j_d]); 
				error_data = error_data + 1;
			end
		end

		if(error_data === 0 && error_status === 0) begin
       	   	$display ("------------------------------------------------------------------");
  			$display ("            ~(￣▽￣)~(＿△＿)~(￣▽￣)~(＿△＿)~(￣▽￣)~              ");
  			$display ("                        Congratulations!                          -");
  			$display ("                You have passed this patterns!!                   -");
  			$display ("-------------------------------------------------------------------");
		end
		else begin
			$display ("--------------------------------------------------------------------");
  			$display ("                           Oops! (╥﹏╥)                             ");
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
    task reset_task; begin
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
    end endtask

endmodule
