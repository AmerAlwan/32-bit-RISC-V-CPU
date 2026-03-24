`timescale 1ns/1ps
import control_signals_pkg::*;

module ALU_tb #(
    parameter int XLEN = 32,
    parameter int NREG = 32
)(
    input  logic clk_i,
    input  logic rst_i
);

    // -------------------------
    // DUT signals
    // -------------------------
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [31:0] a, b;

    alu_op_t    aluop;
    alu_ctrl_t  alu_ctrl;

    logic [31:0] result;
    logic zero, sign, carry, overflow;

    // -------------------------
    // Instantiate DUTs
    // -------------------------
    Control u_ctrl (
        .opcode_i   (opcode),
        .branch_o   (),
        .memread_o (),
        .wb_src_o(),
        .alusrc_o  (),
        .regwrite_o(),
        .memwrite_o(),
        .aluop_o   (aluop),
        .pcsrc_o   (),
        .immtype_o ()
    );

    ALUCtrl u_aluctrl (
        .aluop_i    (aluop),
        .funct3_i   (funct3),
        .funct7_i   (funct7),
        .alu_ctrl_o (alu_ctrl)
    );

    ALU u_alu (
        .a          (a),
        .b          (b),
        .alu_ctrl_i (alu_ctrl),
        .result     (result),
        .zero       (zero),
        .sign       (sign),
        .carry      (carry),
        .overflow   (overflow)
    );

    // -------------------------
    // Test helpers
    // -------------------------
    task automatic check(
        string name,
        alu_ctrl_t exp_ctrl,
        logic [31:0] exp_result
    );
        #1;
        if (alu_ctrl !== exp_ctrl) begin
            $error("%s: ALU CTRL mismatch exp=%0d got=%0d",
                   name, exp_ctrl, alu_ctrl);
        end
        if (result !== exp_result) begin
            $error("%s: RESULT mismatch exp=%h got=%h",
                   name, exp_result, result);
        end
        else begin
            $display("PASS: %s", name);
        end
    endtask

    // -------------------------
    // Test sequence
    // -------------------------
    task start();
        $display("---- ALU Testbench Start ----");

        // ========= R-TYPE =========
        opcode = 7'b0110011;

        a = 32'd20; b = 32'd5;
        funct7 = 7'b0000000; funct3 = 3'b000; // ADD
        check("ADD", ALU_ADD, 25);

        funct7 = 7'b0100000; funct3 = 3'b000; // SUB
        check("SUB", ALU_SUB, 15);

        funct7 = 0; funct3 = 3'b111; // AND
        check("AND", ALU_AND, 20 & 5);

        funct7 = 0; funct3 = 3'b110; // OR
        check("OR", ALU_OR, 20 | 5);

        funct7 = 0; funct3 = 3'b100; // XOR
        check("XOR", ALU_XOR, 20 ^ 5);

        funct7 = 0; funct3 = 3'b001; // SLL
        check("SLL", ALU_SLL, 20 << 5);

        funct7 = 0; funct3 = 3'b101; // SRL
        check("SRL", ALU_SRL, 20 >> 5);

        funct7 = 7'b0100000; funct3 = 3'b101; // SRA
        a = -32'sd20; b = 5;
        check("SRA", ALU_SRA, $signed(a) >>> b[4:0]);

        funct7 = 0; funct3 = 3'b010; // SLT
        a = -1; b = 1;
        check("SLT", ALU_SLT, 32'd1);

        funct7 = 0; funct3 = 3'b011; // SLTU
        a = 32'hFFFFFFFF; b = 1;
        check("SLTU", ALU_SLTU, 32'd0);

        // ========= I-TYPE =========
        opcode = 7'b0010011;
        funct7 = 0;

        funct3 = 3'b000; a = 10; b = 3; // ADDI
        check("ADDI", ALU_ADD, 13);

        funct3 = 3'b111; // ANDI
        check("ANDI", ALU_AND, 10 & 3);

        funct3 = 3'b110; // ORI
        check("ORI", ALU_OR, 10 | 3);

        funct3 = 3'b100; // XORI
        check("XORI", ALU_XOR, 10 ^ 3);

        funct3 = 3'b001; // SLLI
        check("SLLI", ALU_SLL, 10 << 3);

        funct3 = 3'b101; funct7 = 0; // SRLI
        check("SRLI", ALU_SRL, 10 >> 3);

        funct3 = 3'b101; funct7 = 7'b0100000; // SRAI
        a = -32'sd16; b = 2;
        check("SRAI", ALU_SRA, $signed(a) >>> b[4:0]);

        funct3 = 3'b010; // SLTI
        a = -1; b = 1;
        check("SLTI", ALU_SLT, 32'd1);

        funct3 = 3'b011; // SLTIU
        a = 32'hFFFFFFFF; b = 1;
        check("SLTIU", ALU_SLTU, 32'd0);

        // ========= BRANCH =========
        opcode = 7'b1100011;
        funct3 = 3'b000; // BEQ → SUB
        a = 10; b = 10;
        check("BEQ-sub", ALU_SUB, 32'd0);

        $display("---- ALU Testbench End ----\n");
    endtask

endmodule
