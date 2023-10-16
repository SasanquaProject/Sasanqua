module sasanqua_cop
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- Check 接続 ----- */
        // Core -> Cop
        input wire  [31:0]  C_I_PC,
        input wire  [16:0]  C_I_OPCODE,
        input wire  [4:0]   C_I_RD,
        input wire  [4:0]   C_I_RS1,
        input wire  [4:0]   C_I_RS2,
        input wire  [31:0]  C_I_IMM,

        // Cop -> Core
        output wire         C_O_ACCEPT,
        output wire [31:0]  C_O_PC,
        output wire [4:0]   C_O_RD,
        output wire [4:0]   C_O_RS1,
        output wire [4:0]   C_O_RS2,

        /* ----- Exec 接続 ----- */
        // Core -> Cop
        input wire          E_I_ALLOW,
        input wire  [31:0]  E_I_RS1_DATA,
        input wire  [31:0]  E_I_RS2_DATA,

        // Cop -> Core
        output wire         E_O_ALLOW,
        output wire         E_O_VALID,
        output wire [31:0]  E_O_PC,
        output wire         E_O_REG_W_EN,
        output wire [4:0]   E_O_REG_W_RD,
        output wire [31:0]  E_O_REG_W_DATA,
        output wire         E_O_EXC_EN,
        output wire [3:0]   E_O_EXC_CODE
    );

    {%COP_DECLARE_MODULES%}

endmodule
