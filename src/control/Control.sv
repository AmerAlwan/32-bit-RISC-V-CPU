import control_signals_pkg::*;

module Control
#(
    parameter int NREG = 32,
    parameter int XLEN = 32
)
(
    input  logic [6:0] opcode_i,
    output logic       branch_o,
    output logic       memread_o,
    output logic [1:0] wb_src_o,   // Replaced memtoreg_o
    output logic       alusrc_o,
    output logic       regwrite_o,
    output logic       memwrite_o,
    output alu_op_t    aluop_o,
    output logic [1:0] pcsrc_o,
    output logic [2:0] immtype_o
);
    logic load, store, branch, rtype, itype, auipc, lui, jal, jalr;

    always_comb begin
        load   = (opcode_i == 7'b0000011);
        store  = (opcode_i == 7'b0100011);
        branch = (opcode_i == 7'b1100011);
        rtype  = (opcode_i == 7'b0110011);
        itype  = (opcode_i == 7'b0010011);
        auipc  = (opcode_i == 7'b0010111);
        lui    = (opcode_i == 7'b0110111);
        jal    = (opcode_i == 7'b1101111);
        jalr   = (opcode_i == 7'b1100111);

        branch_o   = branch || jalr || jal;
        memread_o  = load;
        memwrite_o = store;
        regwrite_o = jalr || lui || load || itype || rtype || auipc || jal;
        alusrc_o   = lui || load || store || auipc || itype || jalr;
        
        // Writeback Source Selection
        // 00: ALU, 01: Memo, 10: PC+4, 11: LUI Imm
        if (load)          wb_src_o = 2'b01;
        else if (jal || jalr) wb_src_o = 2'b10;
        else if (lui)      wb_src_o = 2'b11;
        else               wb_src_o = 2'b00;

        aluop_o    = branch ? ALU_OP_SUB : 
                     rtype  ? ALU_OP_R_TYPE : 
                     itype  ? ALU_OP_I_TYPE : ALU_OP_ADD;

        immtype_o  = rtype             ? 3'b001 : 
                     store             ? 3'b010 :  
                     branch            ? 3'b011 : 
                     (auipc || lui)    ? 3'b100 : 
                     jal               ? 3'b101 : 3'b000;

        pcsrc_o    = branch ? 2'b01 : jal ? 2'b10 : jalr ? 2'b11 : 2'b00;
    end
endmodule