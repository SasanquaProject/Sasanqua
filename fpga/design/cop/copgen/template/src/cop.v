module sasanqua_cop #
    (
        parameter COP_NUMS = 32'd1,
        parameter PNUMS    = COP_NUMS+1
    )
    (
        /* ----- 制御 ----- */
        input wire                      CLK,
        input wire                      RST,
        input wire                      FLUSH,
        input wire                      STALL,
        input wire                      MEM_WAIT,

        /* ----- Check 接続 ----- */
        // Core -> Cop
        input wire  [(32*PNUMS-1):0]    C_I_PC,
        input wire  [(16*PNUMS-1):0]    C_I_OPCODE,
        input wire  [(32*PNUMS-1):0]    C_I_RINST,

        // Cop -> Core
        output wire [( 1*PNUMS-1):0]    C_O_ACCEPT,

        /* -----  Exec 接続 ----- */
        // Core -> Cop
        input wire  [( 1*COP_NUMS-1):0] E_I_ALLOW,
        input wire  [( 5*COP_NUMS-1):0] E_I_RD,
        input wire  [(32*COP_NUMS-1):0] E_I_RS1_DATA,
        input wire  [(32*COP_NUMS-1):0] E_I_RS2_DATA,

        // Cop -> Core
        output wire [( 1*COP_NUMS-1):0] E_O_ALLOW,
        output wire [( 1*COP_NUMS-1):0] E_O_VALID,
        output wire [(32*COP_NUMS-1):0] E_O_PC,
        output wire [( 1*COP_NUMS-1):0] E_O_REG_W_EN,
        output wire [( 5*COP_NUMS-1):0] E_O_REG_W_RD,
        output wire [(32*COP_NUMS-1):0] E_O_REG_W_DATA,
        output wire [( 1*COP_NUMS-1):0] E_O_EXC_EN,
        output wire [( 4*COP_NUMS-1):0] E_O_EXC_CODE
    );

    {MODULE_DECLARES}

endmodule
