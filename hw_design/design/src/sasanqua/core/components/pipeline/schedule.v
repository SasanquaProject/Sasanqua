module schedule
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        // A(main)
        input wire          A_ACCEPT,
        input wire  [31:0]  A_PC,
        input wire  [16:0]  A_OPCODE,
        input wire  [4:0]   A_RD,
        input wire  [4:0]   A_RS1,
        input wire  [4:0]   A_RS2,
        input wire  [11:0]  A_CSR,
        input wire  [31:0]  A_IMM,

        // B(cop)
        input wire          B_ACCEPT,
        input wire  [31:0]  B_PC,
        input wire  [4:0]   B_RD,
        input wire  [4:0]   B_RS1,
        input wire  [4:0]   B_RS2,

        /* ----- 後段との接続 ----- */
        output wire [31:0]  SCHEDULE_PC,
        output wire [16:0]  SCHEDULE_OPCODE,
        output wire [4:0]   SCHEDULE_RD,
        output wire [4:0]   SCHEDULE_RS1,
        output wire [4:0]   SCHEDULE_RS2,
        output wire [11:0]  SCHEDULE_CSR,
        output wire [31:0]  SCHEDULE_IMM
    );

    /* ----- 入力取り込み ----- */
    reg         a_accept;
    reg  [31:0] a_pc, a_imm;
    reg  [11:0] a_csr;
    reg  [16:0] a_opcode;
    reg  [4:0]  a_rd, a_rs1, a_rs2;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            a_accept <= 1'b0;
            a_pc <= 32'b0;
            a_opcode <= 17'b0;
            a_rd <= 5'b0;
            a_rs1 <= 5'b0;
            a_rs2 <= 5'b0;
            a_csr <= 12'b0;
            a_imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            a_accept <= A_ACCEPT;
            a_pc <= A_PC;
            a_opcode <= A_OPCODE;
            a_rd <= A_RD;
            a_rs1 <= A_RS1;
            a_rs2 <= A_RS2;
            a_csr <= A_CSR;
            a_imm <= A_IMM;
        end
    end

    /* ----- 出力(仮) ----- */
    assign SCHEDULE_PC      = a_pc;
    assign SCHEDULE_OPCODE  = a_accept ? a_opcode : 7'b1101111;
    assign SCHEDULE_RD      = a_accept ? a_rd : 5'b0;
    assign SCHEDULE_RS1     = a_accept ? a_rs1 : 5'b0;
    assign SCHEDULE_RS2     = a_accept ? a_rs2 : 5'b0;
    assign SCHEDULE_CSR     = a_accept ? a_csr : 5'b0;
    assign SCHEDULE_IMM     = a_accept ? a_imm : 32'b00;

endmodule
