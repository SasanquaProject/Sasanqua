// 入力取り込み
reg        allow_{%DEC_ID%};
reg [31:0] rs1_data_{%DEC_ID%};
reg [31:0] s2_data_{%DEC_ID%};
reg [31:0] pc_{%DEC_ID%}   [0:2];
reg [31:0] inst_{%DEC_ID%} [0:2];
reg [4:0]  rd_{%DEC_ID%}   [0:2];
reg [4:0]  rs1_{%DEC_ID%}  [0:2];
reg [4:0]  rs2_{%DEC_ID%}  [0:2];
reg [31:0] imm_{%DEC_ID%}  [0:2];

always @ (posedge CLK) begin
    if (RST || FLUSH) begin
        allow_{%DEC_ID%} <= 1'b0;
        rs1_data_{%DEC_ID%} <= 32'b0;
        rs2_data_{%DEC_ID%} <= 32'b0;
        pc_{%DEC_ID%}[2] <= 32'b0;   pc_{%DEC_ID%}[1] <= 32'b0;   pc_{%DEC_ID%}[0] <= 32'b0;
        rd_{%DEC_ID%}[2] <= 5'b0;    rd_{%DEC_ID%}[1] <= 5'b0;    rd_{%DEC_ID%}[0] <= 5'b0;
        rs1_{%DEC_ID%}[2] <= 5'b0;   rs1_{%DEC_ID%}[1] <= 5'b0;   rs1_{%DEC_ID%}[0] <= 5'b0;
        rs2_{%DEC_ID%}[2] <= 5'b0;   rs2_{%DEC_ID%}[1] <= 5'b0;   rs2_{%DEC_ID%}[0] <= 5'b0;
        imm_{%DEC_ID%}[2] <= 32'b0;  imm_{%DEC_ID%}[1] <= 32'b0;  imm_{%DEC_ID%}[0] <= 32'b0;
        inst_{%DEC_ID%}[2] <= 32'b0; inst_{%DEC_ID%}[1] <= 32'b0; inst_{%DEC_ID%}[0] <= 32'b0;
    end
    else if (STALL || MEM_WAIT) begin
        // do nothing
    end
    else begin
        allow_{%DEC_ID%} <= E_I_ALLOW;
        rs1_data_{%DEC_ID%} <= E_I_RS1_DATA;
        rs2_data_{%DEC_ID%} <= E_I_RS2_DATA;
        pc_{%DEC_ID%}[2] <= pc_{%DEC_ID%}[1];     pc_{%DEC_ID%}[1] <= pc_{%DEC_ID%}[0];      pc_{%DEC_ID%}[0] <= C_I_PC;
        rd_{%DEC_ID%}[2] <= rd_{%DEC_ID%}[1];     rd_{%DEC_ID%}[1] <= rd_{%DEC_ID%}[0];      rd_{%DEC_ID%}[0] <= C_I_RD;
        rs1_{%DEC_ID%}[2] <= rs1_{%DEC_ID%}[1];   rs1_{%DEC_ID%}[1] <= rs1_{%DEC_ID%}[0];    rs1_{%DEC_ID%}[0] <= C_I_RS1;
        rs2_{%DEC_ID%}[2] <= rs2_{%DEC_ID%}[1];   rs2_{%DEC_ID%}[1] <= rs2_{%DEC_ID%}[0];    rs2_{%DEC_ID%}[0] <= C_I_RS2;
        imm_{%DEC_ID%}[2] <= imm_{%DEC_ID%}[1];   imm_{%DEC_ID%}[1] <= imm_{%DEC_ID%}[0];    imm_{%DEC_ID%}[0] <= C_I_IMM;
        inst_{%DEC_ID%}[2] <= inst_{%DEC_ID%}[1]; inst_{%DEC_ID%}[1] <= c_accept;            inst_{%DEC_ID%}[0] <= { 15'b0, C_I_OPCODE };
    end
end

// 接続
wire [31:0] c_accept_{%DEC_ID%};

assign C_O_ACCEPT = c_accept_{%DEC_ID%} != 32'b0;
assign C_O_PC     = pc_{%DEC_ID%}[0];
assign C_O_RD     = rd_{%DEC_ID%}[0];
assign C_O_RS1    = rs1_{%DEC_ID%}[0];
assign C_O_RS2    = rs2_{%DEC_ID%}[0];
assign E_O_ALLOW  = allow_{%DEC_ID%};
assign E_O_PC     = pc_{%DEC_ID%}[2];

{%DEC_NAME%} cop_{%DEC_ID%} (
    // 制御
    .CLK            (CLK),
    .RST            (RST),

    // Check 接続
    .C_OPCODE       (inst_{%DEC_ID%}[0][16:0]),
    .C_ACCEPT       (c_accept_{%DEC_ID%}),

    // Ready 接続
    .R_INST         (inst_{%DEC_ID%}[1]),
    .R_RD           (rd_{%DEC_ID%}[1]),
    .R_RS1          (rs1_{%DEC_ID%}[1]),
    .R_RS2          (rs2_{%DEC_ID%}[1]),
    .R_IMM          (imm_{%DEC_ID%}[1]),

    // Exec 接続
    .E_ALLOW        (allow_{%DEC_ID%}),
    .E_PC           (pc_{%DEC_ID%}[2]),
    .E_INST         (inst_{%DEC_ID%}[2]),
    .E_RD           (rd_{%DEC_ID%}[2]),
    .E_RS1          (rs1_{%DEC_ID%}[2]),
    .E_RS1_DATA     (rs1_data_{%DEC_ID%}),
    .E_RS2          (rs2_{%DEC_ID%}[2]),
    .E_RS2_DATA     (rs2_data_{%DEC_ID%}),
    .E_IMM          (imm_{%DEC_ID%}[2]),
    .E_VALID        (E_O_VALID),
    .E_REG_W_EN     (E_O_REG_W_EN),
    .E_REG_W_RD     (E_O_REG_W_RD),
    .E_REG_W_DATA   (E_O_REG_W_DATA),
    .E_EXC_EN       (E_O_EXC_EN),
    .E_EXC_CODE     (E_O_EXC_CODE)
);
