module schedule #
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

        /* ----- 前段との接続 ----- */
        // Main
        input wire  [( 1*PNUMS-1):0]    MAIN_ACCEPT,
        input wire  [(32*PNUMS-1):0]    MAIN_PC,
        input wire  [(17*PNUMS-1):0]    MAIN_OPCODE,
        input wire  [( 5*PNUMS-1):0]    MAIN_RD,
        input wire  [( 5*PNUMS-1):0]    MAIN_RS1,
        input wire  [( 5*PNUMS-1):0]    MAIN_RS2,
        input wire  [(12*PNUMS-1):0]    MAIN_CSR,
        input wire  [(32*PNUMS-1):0]    MAIN_IMM,

        // Cop
        input wire  [( 1*PNUMS-1):0]    COP_ACCEPT,
        input wire  [(32*PNUMS-1):0]    COP_PC,
        input wire  [( 5*PNUMS-1):0]    COP_RD,
        input wire  [( 5*PNUMS-1):0]    COP_RS1,
        input wire  [( 5*PNUMS-1):0]    COP_RS2,

        /* ----- 後段との接続 ----- */
        // A (main stream)
        output wire                     SCHEDULE_MAIN_ALLOW,
        output wire [31:0]              SCHEDULE_MAIN_PC,
        output wire [16:0]              SCHEDULE_MAIN_OPCODE,
        output wire [4:0]               SCHEDULE_MAIN_RD,
        output wire [4:0]               SCHEDULE_MAIN_RS1,
        output wire [4:0]               SCHEDULE_MAIN_RS2,
        output wire [11:0]              SCHEDULE_MAIN_CSR,
        output wire [31:0]              SCHEDULE_MAIN_IMM,

        // B (cop)
        output wire [( 1*COP_NUMS-1):0] SCHEDULE_COP_ALLOW,
        output wire [( 5*COP_NUMS-1):0] SCHEDULE_COP_RD
    );

    /* ----- 入力取り込み ----- */
    reg [( 1*PNUMS-1):0] main_accept;
    reg [(32*PNUMS-1):0] main_pc, main_imm;
    reg [(12*PNUMS-1):0] main_csr;
    reg [(17*PNUMS-1):0] main_opcode;
    reg [( 5*PNUMS-1):0] main_rd, main_rs1, main_rs2;

    reg [( 1*PNUMS-1):0] cop_accept;
    reg [(32*PNUMS-1):0] cop_pc;
    reg [( 5*PNUMS-1):0] cop_rd, cop_rs1, cop_rs2;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            main_accept <= 'b0;
            main_pc <= 'b0;
            main_opcode <= 'b0;
            main_rd <= 'b0;
            main_rs1 <= 'b0;
            main_rs2 <= 'b0;
            main_csr <= 'b0;
            main_imm <= 'b0;
            cop_accept <= 'b0;
            cop_pc <= 'b0;
            cop_rd <= 'b0;
            cop_rs1 <= 'b0;
            cop_rs2 <= 'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            main_accept <= MAIN_ACCEPT;
            main_pc <= MAIN_PC;
            main_opcode <= MAIN_OPCODE;
            main_rd <= MAIN_RD;
            main_rs1 <= MAIN_RS1;
            main_rs2 <= MAIN_RS2;
            main_csr <= MAIN_CSR;
            main_imm <= MAIN_IMM;
            cop_accept <= COP_ACCEPT;
            cop_pc <= COP_PC;
            cop_rd <= COP_RD;
            cop_rs1 <= COP_RS1;
            cop_rs2 <= COP_RS2;
        end
    end

    /* ----- 出力(仮) ----- */
    // Main
    assign SCHEDULE_MAIN_ALLOW  = !cop_accept[0] && main_accept[0];
    assign SCHEDULE_MAIN_PC     = main_pc[31:0];
    assign SCHEDULE_MAIN_OPCODE = main_opcode[16:0];
    assign SCHEDULE_MAIN_RD     = main_rd[4:0];
    assign SCHEDULE_MAIN_RS1    = main_rs1[4:0];
    assign SCHEDULE_MAIN_RS2    = main_rs2[4:0];
    assign SCHEDULE_MAIN_CSR    = main_csr[11:0];
    assign SCHEDULE_MAIN_IMM    = main_imm[31:0];

    // Cop
    assign SCHEDULE_COP_ALLOW   = cop_accept[0];
    assign SCHEDULE_COP_RD      = cop_rd[4:0];

endmodule
