module rom_dualport
    # (
        parameter WIDTH = 10,
        parameter SIZE  = 1024
    )
    (
        /* ----- 制御 ------ */
        input wire                  CLK,
        input wire                  RST,

        /* ----- アクセスポート ----- */
        // ポートA
        input wire                  A_RDEN,
        input wire  [(WIDTH-1):0]   A_RIADDR,
        output reg  [(WIDTH-1):0]   A_ROADDR,
        output reg                  A_RVALID,
        output reg  [31:0]          A_RDATA,

        // ポートB
        input wire                  B_RDEN,
        input wire  [(WIDTH-1):0]   B_RIADDR,
        output reg  [(WIDTH-1):0]   B_ROADDR,
        output reg                  B_RVALID,
        output reg  [31:0]          B_RDATA
    );

    (* rom_style = "block" *)
    reg [31:0] rom [0:(SIZE-1)];

    initial begin
        $readmemh("bootrom.binhex", rom);
    end

    always @ (posedge CLK) begin
        A_RVALID <= A_RDEN;
        A_ROADDR <= A_RIADDR;
        A_RDATA <= rom[A_RIADDR];

        B_RVALID <= B_RDEN;
        B_ROADDR <= B_RIADDR;
        B_RDATA <= rom[B_RIADDR];
    end

endmodule
