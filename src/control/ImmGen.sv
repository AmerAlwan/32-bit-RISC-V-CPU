module ImmGen #(
    parameter int NREG = 32,
    parameter int XLEN = 32
)
(
    input  logic [XLEN-1:0] instr_i,
    input  logic [2:0]      immtype_i,
    output logic [XLEN-1:0] imm_o
);

    logic [XLEN-1:0] itype, stype, btype, utype, jal;

    always_comb begin
        itype = {{20{instr_i[XLEN-1]}}, instr_i[XLEN-1:20]};
        stype = {{20{instr_i[XLEN-1]}}, instr_i[XLEN-1:25], instr_i[11:7]};
        btype = {{19{instr_i[XLEN-1]}}, instr_i[XLEN-1], instr_i[7],
                 instr_i[30:25], instr_i[11:8], 1'b0};
        utype = {{12{1'b0}}, instr_i[XLEN-1:12]} << 12;
        jal   = {{11{instr_i[XLEN-1]}}, instr_i[XLEN-1],
                 instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};

        imm_o =
            (immtype_i == 3'b001) ? {32{1'b0}} :
            (immtype_i == 3'b010) ? stype :
            (immtype_i == 3'b011) ? btype :
            (immtype_i == 3'b100) ? utype :
            (immtype_i == 3'b101) ? jal   :
                                    itype;
    end

endmodule
