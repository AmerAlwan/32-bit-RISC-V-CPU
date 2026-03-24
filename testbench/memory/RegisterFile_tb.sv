`timescale 1ns/1ps

module RegisterFile_tb #(
    parameter int XLEN = 32,
    parameter int NREG = 32
)(
    input  logic clk_i,
    input  logic rst_i
);

    // -------------------------------------------------
    // DUT signals
    // -------------------------------------------------
    logic we_i;
    logic [4:0]        sel_rs1_i;
    logic [4:0]        sel_rs2_i;
    logic [4:0]        sel_rd_i;
    logic [XLEN-1:0]   rd_data_i;
    logic [XLEN-1:0]   rs1_data_o;
    logic [XLEN-1:0]   rs2_data_o;

    // -------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------
    RegisterFile #(
        .NREG(NREG),
        .XLEN(XLEN)
    ) dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .we_i(we_i),
        .sel_rs1_i(sel_rs1_i),
        .sel_rs2_i(sel_rs2_i),
        .sel_rd_i(sel_rd_i),
        .rd_data_i(rd_data_i),
        .rs1_data_o(rs1_data_o),
        .rs2_data_o(rs2_data_o)
    );

    // -------------------------------------------------
    // Test utilities
    // -------------------------------------------------
    task automatic check_eq(
        input logic [XLEN-1:0] got,
        input logic [XLEN-1:0] exp,
        input string msg
    );
        if (got !== exp) begin
            $error("FAIL: %s | got=0x%08x exp=0x%08x", msg, got, exp);
            $fatal;
        end else begin
            $display("PASS: %s", msg);
        end
    endtask

    task automatic write_reg(
        input int regnum,
        input logic [XLEN-1:0] value
    );
        @(negedge clk_i);
        we_i      = 1'b1;
        sel_rd_i  = regnum[4:0];
        rd_data_i = value;

        @(posedge clk_i);
        #1;
        we_i      = 1'b0;
    endtask

    task automatic read_regs(
        input int r1,
        input int r2
    );
        sel_rs1_i = r1[4:0];
        sel_rs2_i = r2[4:0];
        #1;
    endtask

    // -------------------------------------------------
    // Test sequence
    // -------------------------------------------------
    task start();
        $display("---- RegisterFile Testbench Start ----");

        we_i       = 0;
        sel_rs1_i  = 0;
        sel_rs2_i  = 0;
        sel_rd_i   = 0;
        rd_data_i  = 0;

        // Wait until reset fully released
        wait (!rst_i);
        repeat (2) @(posedge clk_i);

        // x0 always zero
        read_regs(0, 0);
        check_eq(rs1_data_o, '0, "x0 reads zero (rs1)");
        check_eq(rs2_data_o, '0, "x0 reads zero (rs2)");

        write_reg(0, 32'hDEADBEEF);
        read_regs(0, 0);
        check_eq(rs1_data_o, '0, "x0 ignores writes");

        // write + read
        write_reg(1, 32'h11111111);
        write_reg(2, 32'h22222222);
        write_reg(3, 32'h33333333);

        read_regs(1, 2);
        check_eq(rs1_data_o, 32'h11111111, "read r1");
        check_eq(rs2_data_o, 32'h22222222, "read r2");

        read_regs(3, 1);
        check_eq(rs1_data_o, 32'h33333333, "read r3");

        // reset clears registers
        @(posedge rst_i);   // reset asserted
        @(negedge rst_i);   // reset released
        repeat (2) @(posedge clk_i);

        read_regs(1, 2);
        check_eq(rs1_data_o, '0, "reset clears r1");
        check_eq(rs2_data_o, '0, "reset clears r2");

        $display("---- RegisterFile Testbench End ----");
    endtask

endmodule
