// 入力取り込み
reg        allow_{DEC_ID};
reg [4:0]  rd_{DEC_ID};
reg [31:0] rs1_data_{DEC_ID};
reg [31:0] rs2_data_{DEC_ID};
reg [31:0] imm_{DEC_ID};
reg [31:0] pc_{DEC_ID}   [0:2];
reg [31:0] inst_{DEC_ID} [0:2];
reg [31:0] rinst_{DEC_ID} [0:2];

always @ (posedge CLK) begin
    if (RST || FLUSH) begin
        allow_{DEC_ID} <= 1'b0;
        rd_{DEC_ID} <= 5'b0;
        rs1_data_{DEC_ID} <= 32'b0;
        rs2_data_{DEC_ID} <= 32'b0;
        imm_{DEC_ID} <= 32'b0;
        pc_{DEC_ID}[2] <= 32'b0;    pc_{DEC_ID}[1] <= 32'b0;    pc_{DEC_ID}[0] <= 32'b0;
        inst_{DEC_ID}[2] <= 32'b0;  inst_{DEC_ID}[1] <= 32'b0;  inst_{DEC_ID}[0] <= 32'b0;
        rinst_{DEC_ID}[2] <= 32'b0; rinst_{DEC_ID}[1] <= 32'b0; rinst_{DEC_ID}[0] <= 32'b0;
    end
    else if (STALL || MEM_WAIT) begin
        // do nothing
    end
    else begin
        allow_{DEC_ID} <= E_I_ALLOW[(1*({DEC_ID}+1)-1):(1*{DEC_ID})];
        rd_{DEC_ID} <= E_I_RD[(5*({DEC_ID}+1)-1):(5*{DEC_ID})];
        rs1_data_{DEC_ID} <= E_I_RS1_DATA[(32*({DEC_ID}+1)-1):(32*{DEC_ID})];
        rs2_data_{DEC_ID} <= E_I_RS2_DATA[(32*({DEC_ID}+1)-1):(32*{DEC_ID})];
        imm_{DEC_ID} <= r_imm_{DEC_ID};
        pc_{DEC_ID}[2] <= pc_{DEC_ID}[1];       pc_{DEC_ID}[1] <= pc_{DEC_ID}[0];       pc_{DEC_ID}[0] <= C_I_PC[(32*({DEC_ID}+1)-1):(32*{DEC_ID})];
        inst_{DEC_ID}[2] <= inst_{DEC_ID}[1];   inst_{DEC_ID}[1] <= c_accept_{DEC_ID};  inst_{DEC_ID}[0] <= \{ 15'b0, C_I_OPCODE[(17*({DEC_ID}+1)-1):(17*{DEC_ID})] };
        rinst_{DEC_ID}[2] <= rinst_{DEC_ID}[1]; rinst_{DEC_ID}[1] <= rinst_{DEC_ID}[0]; rinst_{DEC_ID}[0] <= C_I_RINST[(32*({DEC_ID}+1)-1):(32*{DEC_ID})];
    end
end

// 接続
wire        e_o_allow_{DEC_ID}, e_o_valid_{DEC_ID}, e_o_reg_w_en_{DEC_ID}, e_o_exc_en_{DEC_ID};
wire [3:0]  e_o_exc_code_{DEC_ID};
wire [4:0]  e_o_reg_w_rd_{DEC_ID};
wire [31:0] e_o_pc_{DEC_ID}, e_o_reg_w_data{DEC_ID};
wire [31:0] c_accept_{DEC_ID}, r_imm_{DEC_ID};

assign c_o_accept_{DEC_ID} = c_accept_{DEC_ID} != 32'b0;
assign e_o_allow_{DEC_ID}  = allow_{DEC_ID};
assign e_o_pc_{DEC_ID}     = pc_{DEC_ID}[2];

cop_{DEC_ID} # (
    .COP_NUMS       (COP_NUMS)
) cop_{DEC_ID} (
    // 制御
    .CLK            (CLK),
    .RST            (RST),

    // Check 接続
    .C_OPCODE       (inst_{DEC_ID}[0][16:0]),
    .C_ACCEPT       (c_accept_{DEC_ID}),

    // Ready 接続
    .R_INST         (inst_{DEC_ID}[1]),
    .R_RINST        (rinst_{DEC_ID}[1]),
    .R_IMM          (r_imm_{DEC_ID}),

    // Exec 接続
    .E_ALLOW        (allow_{DEC_ID}),
    .E_PC           (pc_{DEC_ID}[2]),
    .E_INST         (inst_{DEC_ID}[2]),
    .E_RD           (rd_{DEC_ID}),
    .E_RS1_DATA     (rs1_data_{DEC_ID}),
    .E_RS2_DATA     (rs2_data_{DEC_ID}),
    .E_IMM          (imm_{DEC_ID}),
    .E_VALID        (e_o_valid_{DEC_ID}),
    .E_REG_W_EN     (e_o_reg_w_en_{DEC_ID}),
    .E_REG_W_RD     (e_o_reg_w_rd_{DEC_ID}),
    .E_REG_W_DATA   (e_o_reg_w_data_{DEC_ID}),
    .E_EXC_EN       (e_o_exc_en_{DEC_ID}),
    .E_EXC_CODE     (e_o_exc_code_{DEC_ID})
);