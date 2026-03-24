module RegisterFile #(
    parameter int NREG = 32,
    parameter int XLEN = 32
)
(
    input  logic              clk_i,
    input  logic              rst_i,        // async reset input
    input  logic              we_i,
    input  logic [4:0]        sel_rs1_i,
    input  logic [4:0]        sel_rs2_i,
    input  logic [4:0]        sel_rd_i,
    input  logic [XLEN-1:0]   rd_data_i,
    output logic [XLEN-1:0]   rs1_data_o,
    output logic [XLEN-1:0]   rs2_data_o
);

    // -------------------------------------------------
    // Reset synchronizer (async assert, sync release)
    // -------------------------------------------------
    logic rst_sync1, rst_sync2;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            rst_sync1 <= 1'b1;
            rst_sync2 <= 1'b1;
        end else begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= rst_sync1;
        end
    end

    // Clean, synchronous reset used internally
    logic rst;
    assign rst = rst_sync2;

    // -------------------------------------------------
    // Register storage
    // -------------------------------------------------
    logic [XLEN-1:0] regs [0:NREG-1];

    // -------------------------------------------------
    // Combinational read
    // -------------------------------------------------
    always_comb begin
        if (sel_rs1_i == 5'd0)
            rs1_data_o = '0;
        else
            rs1_data_o = regs[sel_rs1_i];

        if (sel_rs2_i == 5'd0)
            rs2_data_o = '0;
        else
            rs2_data_o = regs[sel_rs2_i];
    end

    // -------------------------------------------------
    // Sequential write / reset
    // -------------------------------------------------
    integer i;
    always_ff @(posedge clk_i) begin
        if (rst) begin
            for (i = 0; i < NREG; i++)
                regs[i] <= '0;
        end else if (we_i && sel_rd_i != 5'd0) begin
            regs[sel_rd_i] <= rd_data_i;
        end
    end

endmodule
