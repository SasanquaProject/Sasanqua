module fetch
    # (
        parameter START_ADDR = 32'h2000_0000
    )
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire  [31:0]  NEW_PC,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- MMUとの接続 ----- */
        output wire         INST_RDEN,
        output wire [31:0]  INST_RIADDR,
        input  wire         INST_RVALID,
        input  wire [31:0]  INST_ROADDR,
        input  wire [31:0]  INST_RDATA,

        /* ----- 後段との接続 ----- */
        output wire [31:0]  INST_PC,
        output wire [31:0]  INST_DATA
    );

    /* ----- PC ----- */
    reg         rden;
    reg  [31:0] pc;

    always @* begin
        if (STALL)
            rden <= 1'b0;
        else
            rden <= 1'b1;
    end

    always @ (posedge CLK) begin
        if (RST)
            pc <= START_ADDR;
        else if (FLUSH)
            pc <= NEW_PC;
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else
            pc <= pc + 32'd4;
    end

    /* ----- MMUとの接続 ----- */
    reg [31:0] cache_pc, cache_data;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            cache_pc <= 32'b0;
            cache_data <= 32'h0000_0013;
        end
        else if (INST_RVALID) begin
            cache_pc <= INST_ROADDR;
            cache_data <= INST_RDATA;
        end
    end

    assign INST_RDEN    = FLUSH ? 1'b0 : rden;
    assign INST_RIADDR  = FLUSH ? 32'b0 : pc;
    assign INST_PC      = INST_RVALID ? INST_ROADDR : cache_pc;
    assign INST_DATA    = INST_RVALID ? INST_RDATA : cache_data;

endmodule
