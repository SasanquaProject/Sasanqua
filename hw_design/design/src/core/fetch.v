module fetch
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire  [31:0]  NEW_PC,
        input wire          STALL,

        /* ----- メモリアクセス ----- */
        output wire         INST_RDEN,
        output wire [31:0]  INST_RIADDR
    );

    /* ----- PC ----- */
    reg         rden;
    reg  [31:0] pc;

    always @ (posedge CLK) begin
        if (RST) begin
            rden <= 1'b0;
            pc <= 32'hffff_fffc;
        end
        else if (FLUSH) begin
            rden <= 1'b1;
            pc <= NEW_PC;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            rden <= 1'b1;
            pc <= pc + 32'd4;
        end
    end

    /* ----- 出力 ----- */
    assign INST_RDEN    = FLUSH ? 1'b0 : rden;
    assign INST_RIADDR  = FLUSH ? 32'b0 : pc;

endmodule
