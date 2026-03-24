import control_signals_pkg::*;

module ALU #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a,
    input  logic [XLEN-1:0] b,
    input  alu_ctrl_t       alu_ctrl_i,

    output logic [XLEN-1:0] result,
    output logic            zero,
    output logic            sign,
    output logic            carry,
    output logic            overflow
);

    logic [XLEN:0] sum;
    logic [XLEN:0] diff;

    always_comb begin
        // defaults
        result   = '0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (alu_ctrl_i)

            ALU_ADD: begin
                sum      = {1'b0, a} + {1'b0, b};
                result   = sum[XLEN-1:0];
                carry    = sum[XLEN];
                overflow = (~(a[XLEN-1] ^ b[XLEN-1])) &
                           (result[XLEN-1] ^ a[XLEN-1]);
            end

            ALU_SUB: begin
                diff     = {1'b0, a} - {1'b0, b};
                result   = diff[XLEN-1:0];
                carry    = ~diff[XLEN]; // NOT borrow
                overflow = (a[XLEN-1] ^ b[XLEN-1]) &
                           (result[XLEN-1] ^ a[XLEN-1]);
            end

            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_XOR: result = a ^ b;

            ALU_SLL: result = a << b[4:0];
            ALU_SRL: result = a >> b[4:0];
            ALU_SRA: result = $signed(a) >>> b[4:0];

            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;

            default: result = '0;

        endcase
    end

    // flags
    assign zero = (result == '0);
    assign sign = result[XLEN-1];

endmodule