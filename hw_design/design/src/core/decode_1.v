module decode_1
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- フェッチ部との接続 ----- */
        input wire          INST_VALID,
        input wire  [31:0]  INST_PC,
        input wire  [31:0]  INST_DATA,

        /* ----- デコード部2との接続 ----- */
        output wire         DECODE1_VALID,
        output wire [31:0]  DECODE1_PC,
        output wire [6:0]   DECODE1_OPCODE,
        output wire [4:0]   DECODE1_RD,
        output wire [4:0]   DECODE1_RS1,
        output wire [4:0]   DECODE1_RS2,
        output wire [2:0]   DECODE1_FUNCT3,
        output wire [6:0]   DECODE1_FUNCT7,
        output wire [31:0]  DECODE1_IMM_I,
        output wire [31:0]  DECODE1_IMM_S,
        output wire [31:0]  DECODE1_IMM_B,
        output wire [31:0]  DECODE1_IMM_U,
        output wire [31:0]  DECODE1_IMM_J
    );

    /* ----- 入力取り込み ----- */
    reg         inst_valid;
    reg [31:0]  inst_pc, inst_data;

    always @ (posedge CLK) begin
        inst_pc <= INST_PC;
        inst_valid <= INST_VALID;
        inst_data <= INST_DATA;
    end

    /* ---- デコード ----- */
    assign DECODE1_VALID    = inst_valid;
    assign DECODE1_PC       = inst_pc;
    assign DECODE1_OPCODE   = inst_data[6:0];
    assign DECODE1_RD       = inst_data[11:7];
    assign DECODE1_RS1      = inst_data[19:15];
    assign DECODE1_RS2      = inst_data[24:20];
    assign DECODE1_FUNCT3   = inst_data[14:12];
    assign DECODE1_FUNCT7   = inst_data[31:25];
    assign DECODE1_IMM_I    = { 20'b0, inst_data[31:20] };
    assign DECODE1_IMM_S    = { 20'b0, inst_data[31:25], inst_data[11:7] };
    assign DECODE1_IMM_B    = { 19'b0, inst_data[31], inst_data[7], inst_data[30:25], inst_data[11:8], 1'b0 };
    assign DECODE1_IMM_U    = { inst_data[31:12], 12'b0 };
    assign DECODE1_IMM_J    = { 11'b0, inst_data[31], inst_data[19:12], inst_data[20], inst_data[30:21], 1'b0 };

endmodule
