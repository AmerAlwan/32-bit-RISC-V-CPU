`timescale 1ns/1ps

module Control_tb#(
    parameter int XLEN = 32,
    parameter int NREG = 32
)(
    input  logic clk_i,
    input  logic rst_i
);

    logic [6:0] opcode_i;
    logic       branch_o;
    logic       memread_o;
    logic [1:0] wb_src_o; // Updated
    logic       alusrc_o;
    logic       regwrite_o;
    logic       memwrite_o;
    alu_op_t    aluop_o;  // Use the package type
    logic [1:0] pcsrc_o;
    logic [2:0] immtype_o;

    Control dut (.*); // Use dot-star for cleaner mapping if names match

    task check(
        input [6:0] opcode,
        input branch,
        input memread,
        input [1:0] wb_src, // Updated
        input alusrc,
        input regwrite,
        input memwrite,
        input alu_op_t aluop,
        input [1:0] pcsrc,
        input [2:0] immtype
    );
        begin
            opcode_i = opcode;
            #1; 
            assert(branch_o   == branch)   else $error("branch_o fail for %b", opcode);
            assert(memread_o  == memread)  else $error("memread_o fail for %b", opcode);
            assert(wb_src_o   == wb_src)   else $error("wb_src_o fail for %b", opcode);
            assert(alusrc_o   == alusrc)   else $error("alusrc_o fail for %b", opcode);
            assert(regwrite_o == regwrite) else $error("regwrite_o fail for %b", opcode);
            assert(memwrite_o == memwrite) else $error("memwrite_o fail for %b", opcode);
            assert(aluop_o    == aluop)    else $error("aluop_o fail for %b", opcode);
            assert(pcsrc_o    == pcsrc)    else $error("pcsrc_o fail for %b", opcode);
            assert(immtype_o  == immtype)  else $error("immtype_o fail for %b", opcode);
            $display("PASS opcode=%b", opcode);
        end
    endtask

    task start();
        $display("---- Control Testbench Start ----");

        // check(opcode, branch, memread, wb_src, alusrc, regwrite, memwrite, aluop, pcsrc, immtype)
        
        // Load (wb_src = 01)
        check(7'b0000011, 0, 1, 2'b01, 1, 1, 0, ALU_OP_ADD, 2'b00, 3'b000);

        // Store (wb_src = 00 - ALU result used for address, but RegWrite is 0)
        check(7'b0100011, 0, 0, 2'b00, 1, 0, 1, ALU_OP_ADD, 2'b00, 3'b010);

        // JAL (wb_src = 10 - PC+4)
        check(7'b1101111, 1, 0, 2'b10, 0, 1, 0, ALU_OP_ADD, 2'b10, 3'b101);

        // LUI (wb_src = 11 - Immediate)
        check(7'b0110111, 0, 0, 2'b11, 1, 1, 0, ALU_OP_ADD, 2'b00, 3'b100);

        $display("---- Control Testbench End ----\n");
    endtask
endmodule