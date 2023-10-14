module cop_void
    (
        /* ----- クロック・リセット ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- Check 接続 ----- */
        input wire  [16:0]  C_OPCODE,
        output wire         C_ACCEPT,

        /* ----- Ready 接続 ----- */
        input wire  [16:0]  R_OPCODE,
        input wire  [4:0]   R_RD,
        input wire  [4:0]   R_RS1,
        input wire  [4:0]   R_RS2,
        input wire  [31:0]  R_IMM,

        /* ----- Exec 接続 ----- */
        input wire          E_ALLOW,
        input wire  [31:0]  E_PC,
        input wire  [16:0]  E_OPCODE,
        input wire  [4:0]   E_RD,
        input wire  [4:0]   E_RS1,
        input wire  [31:0]  E_RS1_DATA,
        input wire  [4:0]   E_RS2,
        input wire  [31:0]  E_RS2_DATA,
        input wire  [31:0]  E_IMM,
        output wire         E_VALID,
        output wire         E_REG_W_EN,
        output wire [4:0]   E_REG_W_RD,
        output wire [31:0]  E_REG_W_DATA,
        output wire         E_EXC_EN,
        output wire [3:0]   E_EXC_CODE
    );

    /* ----- Check ----- */
    assign C_ACCEPT = 1'b0;

    /* ----- Ready ----- */
    // ...

    /* ----- Exec ----- */
    assign E_VALID      = 1'b0;
    assign E_REG_W_EN   = 1'b0;
    assign E_REG_E_RD   = 5'b0;
    assign E_REG_W_DATA = 32'b0;
    assign E_EXC_EN     = 1'b0;
    assign E_EXC_CODE   = 4'b0;

endmodule
