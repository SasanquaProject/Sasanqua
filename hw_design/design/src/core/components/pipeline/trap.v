module trap
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        input wire  [31:0]  INST_PC,
        input wire  [31:0]  DECODE_PC,
        input wire  [31:0]  CHECK_PC,
        input wire  [31:0]  SCHEDULE_1ST_PC,
        input wire  [31:0]  EXEC_PC,
        input wire  [31:0]  CUSHION_PC,
        input wire          CUSHION_EXC_EN,
        input wire  [3:0]   CUSHION_EXC_CODE,

        /* ----- 割り込み ----- */
        input wire          INT_ALLOW,
        input wire          INT_EN,
        input wire  [3:0]   INT_CODE,

        /* ----- Trap情報 ----- */
        input wire  [1:0]   TRAP_VEC_MODE,
        input wire  [31:0]  TRAP_VEC_BASE,
        output wire [31:0]  TRAP_PC,
        output wire         TRAP_EN,
        output wire [31:0]  TRAP_CODE,
        output wire [31:0]  TRAP_JMP_TO
    );

    /* ----- 入力取り込み ----- */
    reg         cushion_exc_en, int_allow, int_en;
    reg [1:0]   trap_vec_mode;
    reg [3:0]   cushion_exc_code, int_code;
    reg [31:0]  inst_pc, decode_pc, check_pc, schedule_1st_pc, exec_pc, cushion_pc, trap_vec_base;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            inst_pc <= 32'b0;
            decode_pc <= 32'b0;
            check_pc <= 32'b0;
            schedule_1st_pc <= 32'b0;
            exec_pc <= 32'b0;
            cushion_pc <= 32'b0;
            cushion_exc_en <= 1'b0;
            cushion_exc_code <= 4'b0;
            int_allow <= 1'b0;
            int_en <= 1'b0;
            int_code <= 4'b0;
            trap_vec_mode <= 2'b0;
            trap_vec_base <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            inst_pc <= INST_PC;
            decode_pc <= DECODE_PC;
            check_pc <= CHECK_PC;
            schedule_1st_pc <= SCHEDULE_1ST_PC;
            exec_pc <= EXEC_PC;
            cushion_pc <= CUSHION_PC;
            cushion_exc_en <= CUSHION_EXC_EN;
            cushion_exc_code <= CUSHION_EXC_CODE;
            int_allow <= INT_ALLOW;
            int_en <= INT_EN;
            int_code <= INT_CODE;
            trap_vec_mode <= TRAP_VEC_MODE;
            trap_vec_base <= TRAP_VEC_BASE;
        end
    end

    /* ---- Trap情報出力 ----- */
    assign TRAP_PC     = cushion_pc      != 32'b0 ? cushion_pc : (
                         exec_pc         != 32'b0 ? exec_pc : (
                         schedule_1st_pc != 32'b0 ? schedule_1st_pc : (
                         check_pc        != 32'b0 ? exec_pc : (
                         decode_pc       != 32'b0 ? decode_pc : inst_pc ))));
    assign TRAP_EN     = cushion_exc_en || (int_en && int_allow);
    assign TRAP_CODE   = cushion_exc_en ? { 28'b0, cushion_exc_code } : { 1'b0, 27'b0, int_code };
    assign TRAP_JMP_TO = cushion_exc_en ? calc_jmp_to(trap_vec_mode, trap_vec_base, cushion_exc_code) :
                                          calc_jmp_to(trap_vec_mode, trap_vec_base, int_code);

    function [31:0] calc_jmp_to;
        input [1:0]  TRAP_VEC_MODE;
        input [31:0] TRAP_VEC_BASE;
        input [3:0]  TRAP_CODE;

        if (TRAP_VEC_MODE == 2'b0)
            calc_jmp_to = TRAP_VEC_BASE;
        else
            calc_jmp_to = TRAP_VEC_BASE + { 26'b0, TRAP_CODE, 2'b0 };
    endfunction

endmodule
