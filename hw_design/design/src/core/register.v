module register
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- レジスタアクセス(rv32i) ----- */
        // 読み
        input wire  [4:0]   REG_IR_I_A,
        input wire  [4:0]   REG_IR_I_B,
        output wire [4:0]   REG_IR_O_A,
        output wire [31:0]  REG_IR_O_AV,
        output wire [4:0]   REG_IR_O_B,
        output wire [31:0]  REG_IR_O_BV,

        // 書き
        input wire  [4:0]   REG_IW_I_A,
        input wire  [31:0]  REG_IW_I_AV
    );

    /* ----- 入力取り込み ----- */
    reg  [4:0]  reg_ir_i_a, reg_ir_i_b;

    always @ (posedge CLK) begin
        if (RST) begin
            reg_ir_i_a <= 5'b0;
            reg_ir_i_b <= 5'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            reg_ir_i_a <= REG_IR_I_A;
            reg_ir_i_b <= REG_IR_I_B;
        end
    end

    /* ----- レジスタアクセス(rv32i) ----- */
    reg [31:0]  register [0:31];

    assign REG_IR_O_A   = reg_ir_i_a;
    assign REG_IR_O_AV  = register[reg_ir_i_a];
    assign REG_IR_O_B   = reg_ir_i_b;
    assign REG_IR_O_BV  = register[reg_ir_i_b];

    always @ (posedge CLK) begin
        if (RST) begin
            register[0] <= 32'b0;
            register[1] <= 32'b0;
            register[2] <= 32'b0;
            register[3] <= 32'b0;
            register[4] <= 32'b0;
            register[5] <= 32'b0;
            register[6] <= 32'b0;
            register[7] <= 32'b0;
            register[8] <= 32'b0;
            register[9] <= 32'b0;
            register[10] <= 32'b0;
            register[11] <= 32'b0;
            register[12] <= 32'b0;
            register[13] <= 32'b0;
            register[14] <= 32'b0;
            register[15] <= 32'b0;
            register[16] <= 32'b0;
            register[17] <= 32'b0;
            register[18] <= 32'b0;
            register[19] <= 32'b0;
            register[20] <= 32'b0;
            register[21] <= 32'b0;
            register[22] <= 32'b0;
            register[23] <= 32'b0;
            register[24] <= 32'b0;
            register[25] <= 32'b0;
            register[26] <= 32'b0;
            register[27] <= 32'b0;
            register[28] <= 32'b0;
            register[29] <= 32'b0;
            register[30] <= 32'b0;
            register[31] <= 32'b0;
        end
        else if (REG_IW_I_A != 5'b0)
            register[REG_IW_I_A] <= REG_IW_I_AV;
    end

endmodule
