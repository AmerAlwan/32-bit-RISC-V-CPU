`timescale 1ns/1ps

module ImmGen_tb #(
    parameter int XLEN = 32,
    parameter int NREG = 32
)(
    input  logic clk_i,
    input  logic rst_i
);
    // DUT signals
    logic [XLEN-1:0] instr_i;
    logic [2:0]      immtype_i;
    logic [XLEN-1:0] imm_o;

    // DUT instantiation
    ImmGen #(
        .XLEN(XLEN)
    ) dut (
        .instr_i   (instr_i),
        .immtype_i (immtype_i),
        .imm_o     (imm_o)
    );

    // Task to apply stimulus
    task automatic run_test(
        input logic [31:0] instr,
        input logic [2:0]  immtype,
        input logic [31:0] expected,
        input string       name
    );
        begin
            instr_i   = instr;
            immtype_i = immtype;
            #1; // allow combinational settle

            if (imm_o !== expected) begin
                $error("FAIL [%s] instr=0x%08h immtype=%b exp=0x%08h got=0x%08h",
                       name, instr, immtype, expected, imm_o);
            end else begin
                $display("PASS [%s] imm=0x%08h", name, imm_o);
            end
        end
    endtask

    task start();
        $display("---- ImmGen Testbench Start ----");

        // -------------------------------
        // I-type (default)
        // imm[11:0] = instr[31:20]
        // -------------------------------
        run_test(
            32'hFFF00093,   // addi x1,x0,-1
            3'b000,
            32'hFFFFFFFF,
            "I-type (-1)"
        );

        // -------------------------------
        // S-type
        // imm = instr[31:25] + instr[11:7]
        // -------------------------------
        run_test(
            32'b1111111_00010_00001_010_00011_0100011,
            3'b010,
            32'hFFFFFFE3,
            "S-type"
        );

        // -------------------------------
        // B-type (branch)
        // Note: no <<1 in your design
        // -------------------------------
        run_test(
            32'b1_000000_00010_00001_000_0001_0_1100011,
            3'b011,
            32'hFFFFF002,
            "B-type"
        );

        // -------------------------------
        // U-type (LUI/AUIPC)
        // imm = instr[31:12] << 12
        // -------------------------------
        run_test(
            32'h12345037,
            3'b100,
            32'h12345000,
            "U-type"
        );

        // -------------------------------
        // J-type (JAL)
        // -------------------------------
        run_test(
            32'b0_0000001000_0_0000000001_1101111,
            3'b101,
            32'h00000002,
            "J-type"
        );

        // -------------------------------
        // immtype == 001 → zero
        // -------------------------------
        run_test(
            32'hFFFFFFFF,
            3'b001,
            32'h00000000,
            "ZERO"
        );

        $display("---- ImmGen Testbench End ----\n");
    endtask

endmodule
