wire signed [31:0] E_RS1_DATA_S = E_RS1_DATA;
wire signed [31:0] E_RS2_DATA_S = E_RS2_DATA;

assign E_VALID      = E_ALLOW;
assign E_EXC_EN     = 1'b0;
assign E_EXC_CODE   = 4'b0;

always @* begin
    casez (E_INST)
        INST_ADD: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA + E_RS2_DATA;
        end
        INST_ADDI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA + { { 20{ E_IMM[11] } }, E_IMM[11:0] };
        end
        INST_SUB: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA - E_RS2_DATA;
        end
        INST_AND: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA & E_RS2_DATA;
        end
        INST_ANDI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA & { { 20{ E_IMM[11] } }, E_IMM[11:0] };
        end
        INST_OR: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA | E_RS2_DATA;
        end
        INST_ORI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA | { { 20{ E_IMM[11] } }, E_IMM[11:0] };
        end
        INST_XOR: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA ^ E_RS2_DATA;
        end
        INST_XORI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA ^ { { 20{ E_IMM[11] } }, E_IMM[11:0] };
        end
        INST_SLL: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA << (E_RS2_DATA[4:0]);
        end
        INST_SLLI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA << (E_IMM[4:0]);
        end
        INST_SRA: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA_S >>> (E_RS2_DATA[4:0]);
        end
        INST_SRAI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA_S >>> (E_IMM[4:0]);
        end
        INST_SRL: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA >> (E_RS2_DATA[4:0]);
        end
        INST_SRLI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA >> (E_IMM[4:0]);
        end
        INST_LUI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= (E_IMM[31:12]) << 12;
        end
        INST_AUIPC: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_PC + ((E_IMM[31:12]) << 12);
        end
        INST_SLT: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA_S < E_RS2_DATA_S ? 32'b1 : 32'b0;
        end
        INST_SLTU: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA < E_RS2_DATA ? 32'b1 : 32'b0;
        end
        INST_SLTI: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA_S < $signed({ { 20{ E_IMM[11] } }, E_IMM[11:0] }) ? 32'b1 : 32'b0;
        end
        INST_SLTIU: begin
            E_REG_W_EN <= 1'b1;
            E_REG_W_RD <= E_RD;
            E_REG_W_DATA <= E_RS1_DATA < { { 20{ E_IMM[11] } }, E_IMM[11:0] } ? 32'b1 : 32'b0;
        end
        default: begin
            E_REG_W_EN <= 1'b0;
            E_REG_W_RD <= 5'b0;
            E_REG_W_DATA <= 32'b0;
        end
    endcase
end
