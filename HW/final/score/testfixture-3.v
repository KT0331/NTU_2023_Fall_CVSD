`timescale 1ns/1ps
`define CYCLE 5.0

// NO_10RE 100 (function check)
// NO_10RE 1   (power analysis)
`define NO_10RE 100 // 1 packet = 1000RE

module testfixture;

    // ============================ //
    // ======== MODULE I/O ======== //
    // ============================ //

    // module input
    reg          i_clk;
    reg          i_rst;
    reg          i_trig;
    reg  [ 47:0] i_data;

    // moduel output
    wire         o_rd_vld;
    wire         o_last_data;
    wire [159:0] o_y_hat;
    wire [319:0] o_r;

    // ============================= //
    // ======== PATTERN REG ======== //
    // ============================= //

    // input pattern reg
    reg [ 47:0] PAT_in_H_and_y [0:(`NO_10RE*200-1)];

    // output patter reg
    reg [319:0] PAT_out_R      [0:(`NO_10RE*10-1)];
    reg [159:0] PAT_out_y_hat  [0:(`NO_10RE*10-1)];

    // ========================= //
    // ======== SDFFILE ======== //
    // ========================= //

    `ifdef GSIM
        `define SDFFILE     "../02_SYN/Netlist/QR_Engine_syn.sdf" // Modify your gsim sdf file name
    `elsif POST
        `define SDFFILE     "../04_APR/QR_Engine_pr.sdf"          // Modify your pr sdf file name
    `endif

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, u_dut);
    `endif

    // ================================= //
    // ======== PATTERN LOADING ======== //
    // ================================= //

    initial begin
        `ifdef P1
            $readmemh ("../01_RTL/PATTERN/packet_1/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_1/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_1/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_1 (SNR10dB)!----#");
        `elsif P2
            $readmemh ("../01_RTL/PATTERN/packet_2/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_2/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_2/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_2 (SNR10dB)!----#");
        `elsif P3
            $readmemh ("../01_RTL/PATTERN/packet_3/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_3/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_3/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_3 (SNR10dB)!----#");
        `elsif P4
            $readmemh ("../01_RTL/PATTERN/packet_4/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_4/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_4/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_4 (SNR15dB)!----#");
        `elsif P5
            $readmemh ("../01_RTL/PATTERN/packet_5/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_5/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_5/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_5 (SNR15dB)!----#");
        `elsif P6
            $readmemh ("../01_RTL/PATTERN/packet_6/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_6/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_6/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_6 (SNR15dB)!----#");
        `else
            $readmemh ("../01_RTL/PATTERN/packet_1/input_H_and_y.dat", PAT_in_H_and_y);
            $readmemh ("../01_RTL/PATTERN/packet_1/output_R.dat", PAT_out_R);
            $readmemh ("../01_RTL/PATTERN/packet_1/output_y_hat.dat", PAT_out_y_hat);
            $display  ("#----Pattern used in this testbench is packet_1 (SNR10dB)!----#");
        `endif
    end

    // ======================== //
    // ======== DESIGN ======== //
    // ======================== //

    QR_Engine u_dut (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_trig      (i_trig),
        .i_data      (i_data),
        .o_rd_vld    (o_rd_vld),
        .o_last_data (o_last_data),
        .o_y_hat     (o_y_hat),
        .o_r         (o_r)    
    );

    // ================================== //
    // ======== CLOCK GENERATION ======== //
    // ================================== //

    initial i_clk = 0;
    always #(`CYCLE/2.0) i_clk = ~i_clk;

    // =========================== //
    // ======== FSDB DUMP ======== //
    // =========================== //

    //initial begin
    //    $fsdbDumpfile("testfixture.fsdb");
    //    $fsdbDumpvars(0, testfixture, "+mda");
    //end

    // ================================== //
    // ======== OTHER PARAMETERS ======== //
    // ================================== //

    reg [319:0] golden_r;
    reg [159:0] golden_y_hat;
    reg [319:0] output_r;
    reg [159:0] output_y_hat;

    reg flag = 0;
    integer i, j;

    // ================================= //
    // ======== WRITE OUT FILES ======== //
    // ================================= //
    integer file_out_y_hat;
    integer file_out_R;
    real out_y_hat;
    real out_R;

    // ============================ //
    // ======== SEND INPUT ======== //
    // ============================ //

    initial begin

        $display("==================================================\n");
        $display("================ Simulation Start ================\n");
        $display("==================================================\n");

        // write out files
        `ifdef P1
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR10_P1_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR10_P1_result.txt", "w");
        `elsif P2
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR10_P2_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR10_P2_result.txt", "w");
        `elsif P3
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR10_P3_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR10_P3_result.txt", "w");
        `elsif P4
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR15_P4_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR15_P4_result.txt", "w");
        `elsif P5
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR15_P5_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR15_P5_result.txt", "w");
        `elsif P6
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR15_P6_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR15_P6_result.txt", "w");
        `else
            out_y_hat = $fopen("./RESULT/out_y_hat_SNR10_P1_result.txt", "w");
            out_R = $fopen("./RESULT/out_R_SNR10_P1_result.txt", "w");
        `endif

        // module input
        i_rst     = 0;
        i_trig    = 0;
        i_data    = 0;

        // other parameter
        golden_r     = 0;
        golden_y_hat = 0;
        output_r     = 0;
        output_y_hat = 0;

        // start reset
        @(posedge i_clk) #(1.0);
        i_rst = 1;
        repeat (3) @(posedge i_clk);
        @(posedge i_clk) #(1.0);
        i_rst = 0;

        // input signal
        for (i = 0; i < `NO_10RE*200; i = i + 1) begin

            @(posedge i_clk) #(1.0);
            i_trig  = 1;
            i_data = PAT_in_H_and_y [i];

            if ( ( (i+1) % 200 ) == 0 ) begin

                #(`CYCLE-2.0);
                if ( ~o_last_data ) begin

                    @(posedge i_clk) #(1.0);
                    i_trig = 0;
                    #(`CYCLE-2.0);
                    
                end

                while ( ~o_last_data ) begin

                    @(posedge i_clk) #(`CYCLE-1.0);
            
                end
            end

        end
        
    end

    // =============================== //
    // ======== DETECT OUTPUT ======== //
    // =============================== //

    initial begin
        j = 0;
    end

    always @(posedge i_clk) begin
        #(`CYCLE-1.0)
        if (o_rd_vld) begin
            golden_r     = PAT_out_R[j];
            golden_y_hat = PAT_out_y_hat[j];
            output_r     = o_r;
            output_y_hat = o_y_hat;

            if (j < 30) begin
                j = j + 1;
                $display ("Pattern %4d#: Golden_r = %h", j, golden_r);
                $display ("Pattern %4d#: Output_r = %h", j, output_r);
                $display ("Pattern %4d#: Golden_y_hat = %h", j, golden_y_hat);
                $display ("Pattern %4d#: Output_y_hat = %h", j, output_y_hat);
            end else begin
                j = j + 1;
                if ( ( j % 100 ) == 0 ) begin
                    $display ("Pattern %4d# ~ %4d# are written", j-99, j);
                end
            end

            $fwrite(out_R, "%h\n", output_r);
            $fwrite(out_y_hat, "%h\n", output_y_hat);
        end

        if (j == `NO_10RE*10) begin
            $finish;
        end
    end

endmodule