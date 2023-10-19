module pool
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire [31:0]   PC,
        input wire [16:0]   OPCODE,
        input wire [4:0]    RD,
        input wire [4:0]    RS1,
        input wire [4:0]    RS2,
        input wire [31:0]   IMM,

        /* ----- スケジューラ1との接続 ----- */
        output wire [31:0]  POOL_PC,
        output wire [16:0]  POOL_OPCODE,
        output wire [4:0]   POOL_RD,
        output wire [4:0]   POOL_RS1,
        output wire [4:0]   POOL_RS2,
        output wire [11:0]  POOL_CSR,
        output wire [31:0]  POOL_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] pc, imm;
    reg  [16:0] opcode;
    reg  [4:0]  rd, rs1, rs2;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            opcode <= 17'b0;
            rd <= 5'b0;
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            opcode <= OPCODE;
            rd <= RD;
            rs1 <= RS1;
            rs2 <= RS2;
            imm <= IMM;
        end
    end

    /* ----- デコード ----- */
    assign POOL_PC     = pc;
    assign POOL_OPCODE = opcode;
    assign POOL_RD     = rd;
    assign POOL_RS1    = rs1;
    assign POOL_RS2    = rs2;
    assign POOL_CSR    = imm[11:0];
    assign POOL_IMM    = imm;

endmodule
