module rom_dualport
    # (
        // サイズ
        parameter ADDR_WIDTH = 10,
        parameter SIZE = 1 << ADDR_WIDTH,

        // データ幅
        parameter DATA_WIDTH_2POW = 0,
        parameter DATA_WIDTH = 32 * (1 << DATA_WIDTH_2POW)
    )
    (
        /* ----- 制御 ------ */
        input wire                       CLK,
        input wire                       RST,

        /* ----- アクセスポート ----- */
        // ポートA
        input wire                       A_SELECT,
        input wire                       A_RDEN,
        input wire  [(ADDR_WIDTH-1+2):0] A_RIADDR,
        output reg  [(ADDR_WIDTH-1+2):0] A_ROADDR,
        output reg                       A_RVALID,
        output reg  [(DATA_WIDTH-1):0]   A_RDATA,

        // ポートB
        input wire                       B_SELECT,
        input wire                       B_RDEN,
        input wire  [(ADDR_WIDTH-1+2):0] B_RIADDR,
        output reg  [(ADDR_WIDTH-1+2):0] B_ROADDR,
        output reg                       B_RVALID,
        output reg  [(DATA_WIDTH-1):0]   B_RDATA
    );

    (* rom_style = "block" *)
    reg [(DATA_WIDTH-1):0] rom [0:(SIZE-1)];

    initial begin
        $readmemh("bootrom.mem", rom);
    end

    always @ (posedge CLK) begin
        A_RVALID <= A_SELECT && A_RDEN;
        A_ROADDR <= A_RIADDR;
        A_RDATA <= rom[A_RIADDR[(ADDR_WIDTH-1+2):2]];

        B_RVALID <= B_SELECT && B_RDEN;
        B_ROADDR <= B_RIADDR;
        B_RDATA <= rom[B_RIADDR[(ADDR_WIDTH-1+2):2]];
    end

endmodule
