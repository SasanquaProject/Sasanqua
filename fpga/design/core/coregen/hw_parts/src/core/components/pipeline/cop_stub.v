module cop_stub #
    (
        parameter COP_NUMS = 32'd1
    )
    (
        /* ----- 制御 ----- */
        input wire                      CLK,
        input wire                      RST,
        input wire                      FLUSH,
        input wire                      STALL,
        input wire                      MEM_WAIT,

        /* ----- 前段との接続 ----- */
        input wire  [(32*COP_NUMS-1):0] PC,
        input wire  [( 5*COP_NUMS-1):0] RD,
        input wire  [( 5*COP_NUMS-1):0] RS1,
        input wire  [( 5*COP_NUMS-1):0] RS2,

        /* ----- 後段との接続 ----- */
        output reg  [(32*COP_NUMS-1):0] COP_STUB_PC,
        output reg  [( 5*COP_NUMS-1):0] COP_STUB_RD,
        output reg  [( 5*COP_NUMS-1):0] COP_STUB_RS1,
        output reg  [( 5*COP_NUMS-1):0] COP_STUB_RS2
    );

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            COP_STUB_PC <= 32'b0;
            COP_STUB_RD <= 5'b0;
            COP_STUB_RS1 <= 5'b0;
            COP_STUB_RS2 <= 5'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            COP_STUB_PC <= PC;
            COP_STUB_RD <= RD;
            COP_STUB_RS1 <= RS1;
            COP_STUB_RS2 <= RS2;
        end
    end

endmodule
