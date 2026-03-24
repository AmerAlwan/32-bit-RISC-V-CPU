module BranchPredictor #(
    parameter int XLEN = 32
) (
    input  logic [XLEN-1:0] alu_result_i, // Result from ALU (used for JALR)
    input  logic [XLEN-1:0] rs1_data_i,   // rs1 value
    input  logic [XLEN-1:0] imm_i,        // Already shifted/extended immediate
    input  logic [XLEN-1:0] pc_i,         // Current PC of the branch/jump instruction
    input  logic [2:0]      funct3_i,     // To distinguish BEQ, BNE, BLT, etc.
    input  logic [1:0]      pcsrc_i,      // From your Control unit: 01=Branch, 10=JAL, 11=JALR
    input  logic            zero_i,       // ALU Flag
    input  logic            sign_i,       // ALU Flag (Negative)
    input  logic            carry_i,      // ALU Flag (Unsigned)
    input  logic            overflow_i,   // ALU Flag
    output logic [XLEN-1:0] target_pc_o,
    output logic            jump_o
);

    logic branch_taken;
    logic [XLEN-1:0] pc_plus_imm;

    assign pc_plus_imm = pc_i + imm_i;

    always_comb begin
        case (pcsrc_i)
            2'b10:   target_pc_o = pc_plus_imm;      // JAL: PC + offset
            2'b11:   target_pc_o = rs1_data_i + imm_i; // JALR: rs1 + offset
            default: target_pc_o = pc_plus_imm;      // Branch: PC + offset
        endcase
    end

    // 2. Branch Condition Logic (funct3 decoding)
    always_comb begin
        case (funct3_i)
            3'b000:  branch_taken = zero_i;                  // BEQ
            3'b001:  branch_taken = ~zero_i;                 // BNE
            3'b100:  branch_taken = (sign_i != overflow_i);  // BLT (Signed)
            3'b101:  branch_taken = (sign_i == overflow_i);  // BGE (Signed)
            3'b110:  branch_taken = ~carry_i;                // BLTU (Unsigned)
            3'b111:  branch_taken = carry_i;                 // BGEU (Unsigned)
            default: branch_taken = 1'b0;
        endcase
    end

    // 3. Final Jump Decision
    // Jump if it's an unconditional JAL/JALR OR if it's a branch that met its condition.
    assign jump_o = (pcsrc_i == 2'b10) || (pcsrc_i == 2'b11) || 
                    ((pcsrc_i == 2'b01) && branch_taken);

endmodule