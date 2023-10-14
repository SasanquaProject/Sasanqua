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
        input wire  [31:0]  C_I_PC,
        input wire  [16:0]  C_I_OPCODE,
        input wire  [4:0]   C_I_RD,
        input wire  [4:0]   C_I_RS1,
        input wire  [4:0]   C_I_RS2,
        input wire  [31:0]  C_I_IMM,

        // Cop -> Core
        output wire         C_O_ACCEPT,
        output wire [31:0]  C_O_PC,
        output wire [4:0]   C_O_RD,
        output wire [4:0]   C_O_RS1,
        output wire [4:0]   C_O_RS2,

        /* ----- Exec 接続 ----- */
        // Core -> Cop
        input wire          E_I_ALLOW,
        input wire  [31:0]  E_I_RS1_DATA,
        input wire  [31:0]  E_I_RS2_DATA,

        // Cop -> Core
        output wire         E_O_ALLOW,
        output wire         E_O_VALID,
        output wire [31:0]  E_O_PC,
        output wire         E_O_REG_W_EN,
        output wire [4:0]   E_O_REG_W_RD,
        output wire [31:0]  E_O_REG_W_DATA,
        output wire         E_O_EXC_EN,
        output wire [3:0]   E_O_EXC_CODE
    );

    /* ----- Cop #1 (rv32i_mini) ----- */
    // 入力取り込み
    reg        allow;
    reg [31:0] rs1_data, rs2_data;
    reg [31:0] pc   [0:2];
    reg [31:0] inst [0:2];
    reg [4:0]  rd   [0:2];
    reg [4:0]  rs1  [0:2];
    reg [4:0]  rs2  [0:2];
    reg [31:0] imm  [0:2];

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
            inst[2] <= 32'b0;   inst[1] <= 32'b0;  inst[0] <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            allow <= E_I_ALLOW;
            rs1_data <= E_I_RS1_DATA;
            rs2_data <= E_I_RS2_DATA;
            pc[2] <= pc[1];     pc[1] <= pc[0];      pc[0] <= C_I_PC;
            rd[2] <= rd[1];     rd[1] <= rd[0];      rd[0] <= C_I_RD;
            rs1[2] <= rs1[1];   rs1[1] <= rs1[0];    rs1[0] <= C_I_RS1;
            rs2[2] <= rs2[1];   rs2[1] <= rs2[0];    rs2[0] <= C_I_RS2;
            imm[2] <= imm[1];   imm[1] <= imm[0];    imm[0] <= C_I_IMM;
            inst[2] <= inst[1]; inst[1] <= c_accept; inst[0] <= { 15'b0, C_I_OPCODE };
        end
    end

    // 接続
    wire [31:0] c_accept;

    assign C_O_ACCEPT = c_accept != 32'b0;
    assign C_O_PC     = pc[0];
    assign C_O_RD     = rd[0];
    assign C_O_RS1    = rs1[0];
    assign C_O_RS2    = rs2[0];
    assign E_O_ALLOW  = allow;
    assign E_O_PC     = pc[2];

    cop_rv32i_mini cop1 (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // Check 接続
        .C_OPCODE       (inst[0][16:0]),
        .C_ACCEPT       (c_accept),

        // Ready 接続
        .R_INST         (inst[1]),
        .R_RD           (rd[1]),
        .R_RS1          (rs1[1]),
        .R_RS2          (rs2[1]),
        .R_IMM          (imm[1]),

        // Exec 接続
        .E_ALLOW        (allow),
        .E_PC           (pc[2]),
        .E_INST         (inst[2]),
        .E_RD           (rd[2]),
        .E_RS1          (rs1[2]),
        .E_RS1_DATA     (rs1_data),
        .E_RS2          (rs2[2]),
        .E_RS2_DATA     (rs2_data),
        .E_IMM          (imm[2]),
        .E_VALID        (E_O_VALID),
        .E_REG_W_EN     (E_O_REG_W_EN),
        .E_REG_W_RD     (E_O_REG_W_RD),
        .E_REG_W_DATA   (E_O_REG_W_DATA),
        .E_EXC_EN       (E_O_EXC_EN),
        .E_EXC_CODE     (E_O_EXC_CODE)
    );

endmodule
