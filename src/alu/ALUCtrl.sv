import control_signals_pkg::*;

module ALUCtrl 
(
    input  alu_op_t aluop_i,
    input  logic [2:0] funct3_i,
    input  logic [6:0] funct7_i,
    output logic [3:0] alu_ctrl_o
);

    always_comb begin
        // default to ADD
        alu_ctrl_o = ALU_ADD;

        case (aluop_i)

            // Loads / stores / addi
            ALU_OP_ADD: alu_ctrl_o = ALU_ADD;

            // Branches
            ALU_OP_SUB: alu_ctrl_o = ALU_SUB;

            // R-type & I-type
            ALU_OP_R_TYPE, ALU_OP_I_TYPE: begin
                case (funct3_i)
                    3'b000: alu_ctrl_o = (funct7_i[5] && aluop_i == 2'b10) ? ALU_SUB : ALU_ADD;
                    3'b111: alu_ctrl_o = ALU_AND;
                    3'b110: alu_ctrl_o = ALU_OR;
                    3'b100: alu_ctrl_o = ALU_XOR;
                    3'b001: alu_ctrl_o = ALU_SLL;
                    3'b101: alu_ctrl_o = funct7_i[5] ? ALU_SRA : ALU_SRL;
                    3'b010: alu_ctrl_o = ALU_SLT;
                    3'b011: alu_ctrl_o = ALU_SLTU;
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            default: alu_ctrl_o = ALU_ADD;

        endcase
    end

endmodule
