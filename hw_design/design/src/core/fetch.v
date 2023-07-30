module fetch
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- メモリアクセス ----- */
        output reg          INST_RDEN,
        output reg  [31:0]  INST_RIADDR
    );

    always @ (posedge CLK) begin
        if (RST) begin
            INST_RDEN <= 1'b0;
            INST_RIADDR <= 32'hffff_fffc;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            INST_RDEN <= 1'b1;
            INST_RIADDR <= INST_RIADDR + 32'd4;
        end
    end

endmodule
