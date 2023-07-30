module fetch
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input               CLK,
        input               RST,

        /* ----- メモリアクセス ----- */
        input wire          MEM_WAIT,
        output reg          INST_RDEN,
        output reg  [31:0]  INST_RIADDR
    );

    always @ (posedge CLK) begin
        if (RST) begin
            INST_RDEN <= 1'b0;
            INST_RIADDR <= 32'hffff_fffc;
        end
        else if (!MEM_WAIT) begin
            INST_RDEN <= 1'b1;
            INST_RIADDR <= INST_RIADDR + 32'd4;
        end
    end

endmodule
