module fetch
    # (
        parameter START_ADDR = 32'h2000_0000
    )
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,

        // パイプライン
        input wire          FLUSH,
        input wire  [31:0]  FLUSH_PC,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- MMUとの接続 ----- */
        output wire         INST_RDEN,
        output wire [31:0]  INST_RIADDR,
        input  wire         INST_RVALID,
        input  wire [31:0]  INST_ROADDR,
        input  wire [31:0]  INST_RDATA,

        /* ----- 後段との接続 ----- */
        output wire [31:0]  FETCH_PC,
        output wire [31:0]  FETCH_INST
    );

    /* ----- PC ----- */
    reg  [31:0] pc;

    always @ (posedge CLK) begin
        if (RST)
            pc <= START_ADDR;
        else if (FLUSH)
            pc <= FLUSH_PC;
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else
            pc <= pc + 32'd4;
    end

    /* ----- MMUとの接続 ----- */
    reg [31:0] cache_pc, cache_inst;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            cache_pc <= FLUSH_PC;
            cache_inst <= 32'h0000_0013;
        end
        else if (INST_RVALID) begin
            cache_pc <= INST_ROADDR;
            cache_inst <= INST_RDATA;
        end
    end

    assign INST_RDEN    = !(FLUSH || STALL || MEM_WAIT);
    assign INST_RIADDR  = pc;
    assign FETCH_PC     = INST_RVALID ? INST_ROADDR : cache_pc;
    assign FETCH_INST   = INST_RVALID ? INST_RDATA : cache_inst;

endmodule
