module cpu_top #(
    parameter int XLEN = 32,
    parameter int NREG = 32,
    parameter bit SIMULATION = 1'b1   // <<< KEY PARAM
)(
    // KC705-style clock inputs
    input  logic sys_clk_p,
    input  logic sys_clk_n,

    // Reset (active high)
    input  logic rst
);

    // -------------------------------------------------
    // Internal clocks
    // -------------------------------------------------
    logic clk_ibuf;
    logic clk_mmcm;
    logic clk_core;

    // -------------------------------------------------
    // Differential clock buffer (KC705)
    // -------------------------------------------------
    IBUFDS #(
        .DIFF_TERM("TRUE"),
        .IBUF_LOW_PWR("FALSE")
    ) u_ibufds (
        .I (sys_clk_p),
        .IB(sys_clk_n),
        .O (clk_ibuf)
    );

    // -------------------------------------------------
    // MMCM (bypassed in simulation)
    // -------------------------------------------------
    generate
        if (SIMULATION) begin : gen_sim_clk
            // In simulation: bypass MMCM entirely
            assign clk_core = clk_ibuf;
        end else begin : gen_mmcm_clk
            // In hardware: proper MMCM + BUFG
            MMCME2_BASE #(
                .CLKIN1_PERIOD(5.0),    // 200 MHz input
                .CLKFBOUT_MULT_F(5.0),  // VCO = 1000 MHz
                .CLKOUT0_DIVIDE_F(5.0)  // 200 MHz output
            ) u_mmcm (
                .CLKIN1   (clk_ibuf),
                .CLKFBIN  (clk_mmcm),
                .CLKFBOUT (clk_mmcm),
                .CLKOUT0  (clk_core),
                .LOCKED   ()
            );
        end
    endgenerate

    // -------------------------------------------------
    // CPU INTERNAL LOGIC CLOCK DOMAIN
    // -------------------------------------------------

    // Register File signals (temporary bring-up)
    logic               rf_we;
    logic [4:0]         rf_rs1;
    logic [4:0]         rf_rs2;
    logic [4:0]         rf_rd;
    logic [XLEN-1:0]    rf_wdata;
    logic [XLEN-1:0]    rf_rdata1;
    logic [XLEN-1:0]    rf_rdata2;

    RegisterFile #(
        .XLEN(XLEN),
        .NREG(NREG)
    ) regfile (
        .clk_i      (clk_core),
        .rst_i      (rst),
        .we_i       (rf_we),
        .sel_rs1_i  (rf_rs1),
        .sel_rs2_i  (rf_rs2),
        .sel_rd_i   (rf_rd),
        .rd_data_i  (rf_wdata),
        .rs1_data_o (rf_rdata1),
        .rs2_data_o (rf_rdata2)
    );

    // -------------------------------------------------
    // CPU logic (to be implemented later)
    // -------------------------------------------------
    // Decoder, ALU, pipeline, etc.

endmodule
