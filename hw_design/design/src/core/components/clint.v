module clint
    # (
        parameter BASE_ADDR = 32'h1000_0000,
        parameter TICK_CNT = 32'd1
    )
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- CPUとの接続 ----- */
        input wire          RDEN,
        input wire  [31:0]  RIADDR,
        output reg  [31:0]  ROADDR,
        output reg          RVALID,
        output reg  [31:0]  RDATA,
        input wire          WREN,
        input wire  [31:0]  WADDR,
        input wire  [31:0]  WDATA,

        /* ----- 割り込み信号 ----- */
        output reg          INT_EN,
        output reg  [3:0]   INT_CODE
    );

    assign clint_rden = RIADDR >= BASE_ADDR && RIADDR < BASE_ADDR + 32'h0001_0000 && RDEN;
    assign clint_wren = WADDR >= BASE_ADDR && WADDR < BASE_ADDR + 32'h0001_0000 && WREN;

    /* ----- 内部タイマ ----- */
    reg [31:0] itimer;

    wire itimer_ok = itimer == (TICK_CNT-32'd1);

    always @ (posedge CLK) begin
        if (RST)
            itimer <= 32'b0;
        else
            itimer <= itimer_ok ? 32'b0 : itimer + 32'b1;
    end

    /* ----- レジスタアクセス ----- */
    reg  [31:0] msip;
    reg  [31:0] mtimecmp [1:0];  // [high:low]
    reg  [31:0] mtime    [1:0];  // [high:low]

    wire [63:0] mtimecmp64 = { mtimecmp[1], mtimecmp[0] };
    wire [63:0] mtime64    = { mtime[1], mtime[0] };

    // 読み
    always @ (posedge CLK) begin
        if (RST) begin
            ROADDR <= 32'b0;
            RVALID <= 1'b1;
            RDATA <= 32'b0;
        end
        else if (clint_rden) begin
            casez (RIADDR[15:0])
                16'h0000: begin  // msip
                    ROADDR <= RIADDR;
                    RVALID <= 1'b1;
                    RDATA <= msip;
                end

                16'h400z: begin  // mtimecmp
                    ROADDR <= RIADDR;
                    RVALID <= 1'b1;
                    RDATA <= mtimecmp[RIADDR[2]];
                end

                16'hbffz: begin  // mtime
                    ROADDR <= RIADDR;
                    RVALID <= 1'b1;
                    RDATA <= mtime[RIADDR[2]];
                end
            endcase
        end
        else begin
            ROADDR <= 32'b0;
            RVALID <= 1'b0;
            RDATA <= 32'b0;
        end
    end

    // 書き
    always @ (posedge CLK) begin
        if (RST) begin
            msip <= 32'b0;
            mtimecmp[1] <= 32'b0;
            mtimecmp[0] <= 32'b0;
            mtime[1] <= 32'b0;
            mtime[0] <= 32'b0;
        end
        else if (clint_wren) begin
            casez (WADDR[15:0])
                16'h400z: mtimecmp[WADDR[2]] <= WDATA;
                16'hbffz: mtime[WADDR[2]] <= WDATA;
            endcase
        end
        else if (itimer_ok) begin
            mtime[0] <= mtime[0] + 32'b1;
            mtime[1] <= mtime[0] == 32'hffff_ffff ? mtime[1] + 32'b1 : mtime[1];
        end
    end

    /* ----- 割り込み ----- */
    always @ (posedge CLK) begin
        if (RST) begin
            INT_EN <= 1'b0;
            INT_CODE <= 4'b0;
        end
        else if (clint_wren && WADDR[15:0] == 16'b0) begin  // Software interrupt
            INT_EN <= WDATA[0];
            INT_CODE <= 4'd3;
        end
        else if (itimer_ok && (mtime64+32'd1) >= mtimecmp64) begin  // Timer interrupt
            INT_EN <= 1'b1;
            INT_CODE <= 4'd7;
        end
        else begin
            INT_EN <= 1'b0;
            INT_CODE <= 4'b0;
        end
    end

endmodule
