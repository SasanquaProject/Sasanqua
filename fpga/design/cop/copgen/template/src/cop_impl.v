module cop_{ID} #
    (
        parameter COP_NUMS = 32'd1,
        parameter PNUMS    = COP_NUMS
    )
    (
        /* ----- クロック・リセット ----- */
        input wire                      CLK,
        input wire                      RST,

        /* ----- Check 接続 ----- */
        input wire  [(17*PNUMS-1):0]    C_OPCODE,
        output wire [(32*PNUMS-1):0]    C_ACCEPT,

        /* ----- Ready 接続 ----- */
        input wire  [31:0]              R_INST,
        input wire  [31:0]              R_RINST,
        output wire [31:0]              R_IMM,

        /* ----- Exec 接続 ----- */
        input wire                      E_ALLOW,
        input wire  [31:0]              E_PC,
        input wire  [31:0]              E_INST,
        input wire  [4:0]               E_RD,
        input wire  [31:0]              E_RS1_DATA,
        input wire  [31:0]              E_RS2_DATA,
        input wire  [31:0]              E_IMM,
        output wire                     E_VALID,
        output reg                      E_REG_W_EN,
        output reg  [4:0]               E_REG_W_RD,
        output reg  [31:0]              E_REG_W_DATA,
        output wire                     E_EXC_EN,
        output wire [3:0]               E_EXC_CODE
    );

    /* ----- Check ----- */
    assign C_ACCEPT = \{ 1'b0, check_inst(C_OPCODE[16:0]) };

    {INST_PARAMETERS}

    function [31:0] check_inst;
        input [16:0] OPCODE;
        casez (OPCODE)
            {INST_CHECK_CONDS}
            default: check_inst = 32'b0;
        endcase
    endfunction

    /* ----- Ready ----- */
    {READY_HDL}

    /* ----- Exec ----- */
    {EXEC_HDL}

endmodule
