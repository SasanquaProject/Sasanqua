module trap
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          MEM_WAIT,

        /* ----- 待機部との接続 ----- */
        input wire  [31:0]  CUSHION_PC,
        input wire          CUSHION_EXC_EN,
        input wire  [3:0]   CUSHION_EXC_CODE,

        /* ----- Trap情報 ----- */
        input wire  [1:0]   TRAP_VEC_MODE,
        input wire  [31:0]  TRAP_VEC_BASE,
        output wire [31:0]  TRAP_PC,
        output wire         TRAP_EN,
        output wire [31:0]  TRAP_CODE,
        output wire [31:0]  TRAP_JMP_TO
    );

    /* ----- 入力取り込み ----- */
    reg         cushion_exc_en;
    reg [1:0]   trap_vec_mode;
    reg [3:0]   cushion_exc_code;
    reg [31:0]  cushion_pc, trap_vec_base;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            cushion_pc <= 32'b0;
            cushion_exc_en <= 1'b0;
            cushion_exc_code <= 4'b0;
            trap_vec_mode <= 2'b0;
            trap_vec_base <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            cushion_pc <= CUSHION_PC;
            cushion_exc_en <= CUSHION_EXC_EN;
            cushion_exc_code <= CUSHION_EXC_CODE;
            trap_vec_mode <= TRAP_VEC_MODE;
            trap_vec_base <= TRAP_VEC_BASE;
        end
    end

    /* ---- Trap情報出力 ----- */
    assign TRAP_PC     = cushion_pc;
    assign TRAP_EN     = cushion_exc_en;
    assign TRAP_CODE   = { 28'b0, cushion_exc_code };
    assign TRAP_JMP_TO = trap_vec_mode == 2'b0 ? trap_vec_base : trap_vec_base + { 26'b0, cushion_exc_code, 2'b0 };

endmodule
