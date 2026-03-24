`timescale 1ns/1ps

module CPU_tb;

    // -------------------------------------------------
    // Parameters
    // -------------------------------------------------
    localparam int  XLEN     = 32;
    localparam int  NREG     = 32;
    localparam time CLK_HALF = 2.5ns;   // 200 MHz

    // -------------------------------------------------
    // Clock / Reset
    // -------------------------------------------------
    logic clk;
    logic rst;

    logic sys_clk_p;
    logic sys_clk_n;

    // Clock generation (200 MHz)
    initial begin
        clk = 0;
        forever #CLK_HALF clk = ~clk;
    end

    // Fake differential clock
    assign sys_clk_p = clk;
    assign sys_clk_n = ~clk;


    // -------------------------------------------------
    // DUT: CPU top
    // -------------------------------------------------
    cpu_top #(
        .XLEN(XLEN),
        .NREG(NREG),
        .SIMULATION(1'b1)
    ) dut (
        .sys_clk_p(sys_clk_p),
        .sys_clk_n(sys_clk_n),
        .rst(rst)
    );  


    // -------------------------------------------------
    // Block-level tests (DROP-IN STYLE)
    // -------------------------------------------------

    // Register File tests
    RegisterFile_tb #(
        .XLEN(XLEN),
        .NREG(NREG)
    ) rf_test (
        .clk_i(clk),
        .rst_i(rst)
    );

    Control_tb #(
        .XLEN(XLEN),
        .NREG(NREG)
    ) ctrl_test (
        .clk_i(clk),
        .rst_i(rst)
    );

    ImmGen_tb #(
        .XLEN(XLEN),
        .NREG(NREG)
    ) immgen_test (
        .clk_i(clk),
        .rst_i(rst)
    );

    ALU_tb #(
        .XLEN(XLEN),
        .NREG(NREG)
    ) alu_test (
        .clk_i(clk),
        .rst_i(rst)
    );


    // Future tests go here:
    // ALU_test        alu_test (.clk_i(clk), .rst_i(rst));
    // Decoder_test    dec_test (.clk_i(clk), .rst_i(rst));
    // Execute_test    exe_test (.clk_i(clk), .rst_i(rst));
    // CPU_core_test   cpu_test (.clk_i(clk), .rst_i(rst));

    // -------------------------------------------------
    // Simulation control
    // -------------------------------------------------
    initial begin
        $display("==========================================");
        $display(" CPU TESTBENCH START");
        $display("==========================================");

//         rst = 1;
//         #10;
//         rst = 0;

//     //     // Let tests run
//         rf_test.start();
//         #500;
// // 
//     //     // Second reset for reset tests
//         rst = 1;
//         #10;
//         rst = 0;

        ctrl_test.start();
        immgen_test.start();
        alu_test.start();

        $display("==========================================");
        $display(" ALL TESTS COMPLETED");
        $display("==========================================");
        $finish;
    end

endmodule
