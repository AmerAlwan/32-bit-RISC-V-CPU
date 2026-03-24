package control_signals_pkg;
    typedef enum logic [1:0] {
        ALU_OP_ADD = 2'b00,
        ALU_OP_SUB = 2'b01,
        ALU_OP_R_TYPE = 2'b10,
        ALU_OP_I_TYPE = 2'b11
    } alu_op_t;

    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLL  = 4'b0101,
        ALU_SRL  = 4'b0110,
        ALU_SRA  = 4'b0111,
        ALU_SLT  = 4'b1000,
        ALU_SLTU = 4'b1001
    } alu_ctrl_t;

endpackage
