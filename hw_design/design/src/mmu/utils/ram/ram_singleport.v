module ram_singleport
    # (
        parameter WIDTH = 10,
        parameter SIZE  = 1024
    )
    (
        /* ----- 制御 ------ */
        input wire          CLK,
        input wire          RST,

        /* ----- アクセスポート ----- */
        input wire                  RDEN,
        input wire  [(WIDTH-1):0]   RADDR,
        output wire [31:0]          RDATA,
        input wire                  WREN,
        input wire  [(WIDTH-1):0]   WADDR,
        input wire  [31:0]          WDATA,
    );

    (* ram_style = "block" *)
    reg [31:0] ram [0:(SIZE-1)];

    reg         cache_wren;
    reg  [31:0] rdata, cache_wdata;

    assign RDATA = cache_wren ? cache_wdata : rdata;

    always @ (posedge CLK) begin
        cache_wren <= WREN;
        cache_wdata <= WDATA;
        rdata <= ram[RADDR];
        if (WREN)
            ram[WADDR] <= WDATA;
    end

endmodule
