module decode
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        input wire  [31:0]  PC,
        input wire  [31:0]  INST,

        /* ----- 後段との接続 ----- */
        output wire [31:0]  DECODE_PC,
        output wire [16:0]  DECODE_OPCODE,  // { opcode, funct3, funct7 }
        output wire [4:0]   DECODE_RD,
        output wire [4:0]   DECODE_RS1,
        output wire [4:0]   DECODE_RS2,
        output wire [31:0]  DECODE_RINST
    );

    /* ----- 入力取り込み ----- */
    reg [31:0] pc, inst;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            inst <= 32'h0000_0013;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            inst <= INST;
        end
    end

    /* ---- デコード ----- */
    assign DECODE_PC       = pc;
    assign DECODE_OPCODE   = { inst[6:0], inst[14:12], inst[31:25] };
    assign DECODE_RD       = inst[11:7];
    assign DECODE_RS1      = inst[19:15];
    assign DECODE_RS2      = inst[24:20];
    assign DECODE_RINST    = inst;

endmodule
