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
        // A (main stream)
        output wire         SCHEDULE_A_ALLOW,
        output wire [31:0]  SCHEDULE_A_PC,
        output wire [16:0]  SCHEDULE_A_OPCODE,
        output wire [4:0]   SCHEDULE_A_RD,
        output wire [4:0]   SCHEDULE_A_RS1,
        output wire [4:0]   SCHEDULE_A_RS2,
        output wire [11:0]  SCHEDULE_A_CSR,
        output wire [31:0]  SCHEDULE_A_IMM,

        // B (cop)
        output wire         SCHEDULE_B_ALLOW,
        output wire [4:0]   SCHEDULE_B_RD
    );

    /* ----- 入力取り込み ----- */
    reg         a_accept;
    reg  [31:0] a_pc, a_imm;
    reg  [11:0] a_csr;
    reg  [16:0] a_opcode;
    reg  [4:0]  a_rd, a_rs1, a_rs2;

    reg         b_accept;
    reg  [31:0] b_pc;
    reg  [4:0]  b_rd, b_rs1, b_rs2;

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
            b_accept <= 1'b0;
            b_pc <= 32'b0;
            b_rd <= 5'b0;
            b_rs1 <= 5'b0;
            b_rs2 <= 5'b0;
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
            b_accept <= B_ACCEPT;
            b_pc <= B_PC;
            b_rd <= B_RD;
            b_rs1 <= B_RS1;
            b_rs2 <= B_RS2;
        end
    end

    /* ----- 出力(仮) ----- */
    // A (main stream)
    assign SCHEDULE_A_ALLOW     = !b_accept && a_accept;
    assign SCHEDULE_A_PC        = a_pc;
    assign SCHEDULE_A_OPCODE    = a_opcode;
    assign SCHEDULE_A_RD        = a_rd;
    assign SCHEDULE_A_RS1       = a_rs1;
    assign SCHEDULE_A_RS2       = a_rs2;
    assign SCHEDULE_A_CSR       = a_csr;
    assign SCHEDULE_A_IMM       = a_imm;

    // B (cop)
    assign SCHEDULE_B_ALLOW     = b_accept;
    assign SCHEDULE_B_RD        = b_rd;

endmodule
