module sasanqua_cop
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- Check 接続 ----- */
        // Core -> Cop
        input wire  [31:0]  PC,
        input wire  [16:0]  OPCODE,
        input wire  [4:0]   RD,
        input wire  [4:0]   RS1,
        input wire  [4:0]   RS2,
        input wire  [31:0]  IMM,

        // Cop -> Core
        output wire         COP_C_ACCEPT,
        output wire [31:0]  COP_C_PC,
        output wire [4:0]   COP_C_RD,
        output wire [4:0]   COP_C_RS1,
        output wire [4:0]   COP_C_RS2,

        /* ----- Exec 接続 ----- */
        // Core -> Cop
        input wire          ALLOW,
        input wire  [31:0]  RS1_DATA,
        input wire  [31:0]  RS2_DATA,

        // Cop -> Core
        output wire         COP_E_ALLOW,
        output wire         COP_E_VALID,
        output wire [31:0]  COP_E_PC,
        output wire         COP_E_REG_W_EN,
        output wire [4:0]   COP_E_REG_W_RD,
        output wire [31:0]  COP_E_REG_W_DATA,
        output wire         COP_E_EXC_EN,
        output wire [3:0]   COP_E_EXC_CODE
    );

    /* ----- Cop #1 (rv32i_mini) ----- */
    // 入力取り込み
    reg        allow;
    reg [31:0] rs1_data, rs2_data;
    reg [31:0] pc       [0:2];
    reg [16:0] opcode   [0:2];
    reg [4:0]  rd       [0:2];
    reg [4:0]  rs1      [0:2];
    reg [4:0]  rs2      [0:2];
    reg [31:0] imm      [0:2];

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            allow <= 1'b0;
            rs1_data <= 32'b0;
            rs2_data <= 32'b0;
            pc[2] <= 32'b0;     pc[1] <= 32'b0;    pc[0] <= 32'b0;
            rd[2] <= 5'b0;      rd[1] <= 5'b0;     rd[0] <= 5'b0;
            rs1[2] <= 5'b0;     rs1[1] <= 5'b0;    rs1[0] <= 5'b0;
            rs2[2] <= 5'b0;     rs2[1] <= 5'b0;    rs2[0] <= 5'b0;
            imm[2] <= 32'b0;    imm[1] <= 32'b0;   imm[0] <= 32'b0;
            opcode[2] <= 17'b0; opcode[1] <= 17'b0; opcode[0] <= 17'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            allow <= ALLOW;
            rs1_data <= RS1_DATA;
            rs2_data <= RS2_DATA;
            pc[2] <= pc[1];         pc[1] <= pc[0];         pc[0] <= PC;
            rd[2] <= rd[1];         rd[1] <= rd[0];         rd[0] <= RD;
            rs1[2] <= rs1[1];       rs1[1] <= rs1[0];       rs1[0] <= RS1;
            rs2[2] <= rs2[1];       rs2[1] <= rs2[0];       rs2[0] <= RS2;
            imm[2] <= imm[1];       imm[1] <= imm[0];       imm[0] <= IMM;
            opcode[2] <= opcode[1]; opcode[1] <= opcode[0]; opcode[0] <= OPCODE;
        end
    end

    // 接続
    assign COP_C_PC    = pc[0];
    assign COP_C_RD    = rd[0];
    assign COP_C_RS1   = rs1[0];
    assign COP_C_RS2   = rs2[0];
    assign COP_E_ALLOW = allow;
    assign COP_E_PC    = pc[2];

    cop_rv32i_mini cop1 (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // Check 接続
        .C_OPCODE       (opcode[0]),
        .C_ACCEPT       (COP_C_ACCEPT),

        // Ready 接続
        .R_OPCODE       (opcode[1]),
        .R_RD           (rd[1]),
        .R_RS1          (rs1[1]),
        .R_RS2          (rs2[1]),
        .R_IMM          (imm[1]),

        // Exec 接続
        .E_ALLOW        (allow),
        .E_PC           (pc[2]),
        .E_OPCODE       (opcode[2]),
        .E_RD           (rd[2]),
        .E_RS1          (rs1[2]),
        .E_RS1_DATA     (rs1_data),
        .E_RS2          (rs2[2]),
        .E_RS2_DATA     (rs2_data),
        .E_IMM          (imm[2]),
        .E_VALID        (COP_E_VALID),
        .E_REG_W_EN     (COP_E_REG_W_EN),
        .E_REG_W_RD     (COP_E_REG_W_RD),
        .E_REG_W_DATA   (COP_E_REG_W_DATA),
        .E_EXC_EN       (COP_E_EXC_EN),
        .E_EXC_CODE     (COP_E_EXC_CODE)
    );

endmodule
