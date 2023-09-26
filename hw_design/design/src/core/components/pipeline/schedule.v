module schedule
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire  [31:0]  CHECK_PC,
        input wire  [6:0]   CHECK_OPCODE,
        input wire  [4:0]   CHECK_RD,
        input wire  [11:0]  CHECK_CSR,
        input wire  [2:0]   CHECK_FUNCT3,
        input wire  [6:0]   CHECK_FUNCT7,
        input wire  [31:0]  CHECK_IMM,

        /* ----- 実行部との接続 ----- */
        output wire [31:0]  SCHEDULE_PC,
        output wire [6:0]   SCHEDULE_OPCODE,
        output wire [4:0]   SCHEDULE_RD,
        output wire [11:0]  SCHEDULE_CSR,
        output wire [2:0]   SCHEDULE_FUNCT3,
        output wire [6:0]   SCHEDULE_FUNCT7,
        output wire [31:0]  SCHEDULE_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] check_pc, check_imm;
    reg  [11:0] check_csr;
    reg  [6:0]  check_opcode, check_funct7;
    reg  [4:0]  check_rd;
    reg  [2:0]  check_funct3;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            check_pc <= 32'b0;
            check_opcode <= 7'b0;
            check_rd <= 5'b0;
            check_csr <= 12'b0;
            check_funct3 <= 3'b0;
            check_funct7 <= 7'b0;
            check_imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            check_pc <= CHECK_PC;
            check_opcode <= CHECK_OPCODE;
            check_rd <= CHECK_RD;
            check_csr <= CHECK_CSR;
            check_funct3 <= CHECK_FUNCT3;
            check_funct7 <= CHECK_FUNCT7;
            check_imm <= CHECK_IMM;
        end
    end

    /* ----- 出力(仮) ----- */
    assign SCHEDULE_PC      = check_pc;
    assign SCHEDULE_OPCODE  = check_opcode;
    assign SCHEDULE_RD      = check_rd;
    assign SCHEDULE_CSR     = check_csr;
    assign SCHEDULE_FUNCT3  = check_funct3;
    assign SCHEDULE_FUNCT7  = check_funct7;
    assign SCHEDULE_IMM     = check_imm;

endmodule
