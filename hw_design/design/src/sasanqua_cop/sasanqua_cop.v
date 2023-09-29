module sasanqua_cop
    (
        /* ----- クロック・リセット ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- Check 接続 ----- */
        // Core -> Cop
        input wire  [31:0]  PC,
        input wire  [16:0]  OPCODE,
        input wire  [4:0]   RD,
        input wire  [4:0]   RS1,
        input wire  [4:0]   RS2,
        input wire  [31:0]  IMM,

        // Cop -> Core
        output wire         COP_C_ACCEPT,
        output wire [31:0]  COP_C_PC,
        output wire [4:0]   COP_C_RD,
        output wire [4:0]   COP_C_RS1,
        output wire [4:0]   COP_C_RS2,

        /* ----- Exec 接続 ----- */
        // Core -> Cop
        input wire          ALLOW,
        input wire  [31:0]  RS1_DATA,
        input wire  [31:0]  RS2_DATA,

        // Cop -> Core
        output wire [31:0]  COP_E_PC,
        output wire         COP_E_REG_W_EN,
        output wire [4:0]   COP_E_REG_W_RD,
        output wire [31:0]  COP_E_REG_W_DATA,
        output wire         COP_E_MEM_R_EN,
        output wire [4:0]   COP_E_MEM_R_RD,
        output wire [31:0]  COP_E_MEM_R_ADDR,
        output wire [3:0]   COP_E_MEM_R_STRB,
        output wire         COP_E_MEM_R_SIGNED,
        output wire         COP_E_MEM_W_EN,
        output wire [31:0]  COP_E_MEM_W_ADDR,
        output wire [3:0]   COP_E_MEM_W_STRB,
        output wire [31:0]  COP_E_MEM_W_DATA,
        output wire         COP_E_EXC_EN,
        output wire [3:0]   COP_E_EXC_CODE
    );

    /* ----- Check ----- */
    assign COP_C_ACCEPT     = 1'b0;
    assign COP_C_PC         = 32'b0;
    assign COP_C_RD         = 5'b0;
    assign COP_C_RS1        = 5'b0;
    assign COP_C_RS2        = 5'b0;

    /* ----- Ready ----- */
    // ...

    /* ----- Exec ----- */
    assign COP_E_PC           = 32'b0;

    assign COP_E_REG_W_EN     = 1'b0;
    assign COP_E_REG_W_RD     = 5'b0;
    assign COP_E_REG_W_DATA   = 32'b0;

    assign COP_E_MEM_R_EN     = 1'b0;
    assign COP_E_MEM_R_RD     = 5'b0;
    assign COP_E_MEM_R_ADDR   = 32'b0;
    assign COP_E_MEM_R_STRB   = 4'b0;
    assign COP_E_MEM_R_SIGNED = 1'b0;

    assign COP_E_MEM_W_EN     = 1'b0;
    assign COP_E_MEM_W_ADDR   = 32'b0;
    assign COP_E_MEM_W_STRB   = 4'b0;
    assign COP_E_MEM_W_DATA   = 32'b0;

    assign COP_E_EXC_EN       = 1'b0;
    assign COP_E_EXC_CODE     = 4'b0;

endmodule
