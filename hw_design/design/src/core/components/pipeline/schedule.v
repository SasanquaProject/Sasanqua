module schedule
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire  [31:0]  PC,
        input wire  [16:0]  OPCODE,
        input wire  [4:0]   RD,
        input wire  [11:0]  CSR,
        input wire  [31:0]  IMM,

        /* ----- 実行部との接続 ----- */
        output wire [31:0]  SCHEDULE_PC,
        output wire [16:0]  SCHEDULE_OPCODE,
        output wire [4:0]   SCHEDULE_RD,
        output wire [11:0]  SCHEDULE_CSR,
        output wire [31:0]  SCHEDULE_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] pc, imm;
    reg  [11:0] csr;
    reg  [16:0] opcode;
    reg  [4:0]  rd;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            opcode <= 17'b0;
            rd <= 5'b0;
            csr <= 12'b0;
            imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            opcode <= OPCODE;
            rd <= RD;
            csr <= CSR;
            imm <= IMM;
        end
    end

    /* ----- 出力(仮) ----- */
    assign SCHEDULE_PC      = pc;
    assign SCHEDULE_OPCODE  = opcode;
    assign SCHEDULE_RD      = rd;
    assign SCHEDULE_CSR     = csr;
    assign SCHEDULE_IMM     = imm;

endmodule
