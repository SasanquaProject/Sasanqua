module exec_std_rv32i_s
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        input wire  [31:0]  PC,
        input wire  [16:0]  OPCODE,
        input wire  [4:0]   RD_ADDR,
        input wire  [4:0]   RS1_ADDR,
        input wire  [31:0]  RS1_DATA,
        input wire  [4:0]   RS2_ADDR,
        input wire  [31:0]  RS2_DATA,
        input wire  [11:0]  CSR_ADDR,
        input wire  [31:0]  CSR_DATA,
        input wire  [31:0]  IMM,

        /* ----- 後段との接続 ----- */
        // PC
        output wire [31:0]  EXEC_PC,

        // レジスタ(rv32i:W)
        output reg          EXEC_REG_W_EN,
        output reg  [4:0]   EXEC_REG_W_RD,
        output reg  [31:0]  EXEC_REG_W_DATA,

        // レジスタ(csrs:W)
        output reg          EXEC_CSR_W_EN,
        output reg  [11:0]  EXEC_CSR_W_ADDR,
        output reg  [31:0]  EXEC_CSR_W_DATA,

        // メモリ(R)
        output reg          EXEC_MEM_R_EN,
        output reg  [4:0]   EXEC_MEM_R_RD,
        output reg  [31:0]  EXEC_MEM_R_ADDR,
        output reg  [3:0]   EXEC_MEM_R_STRB,
        output reg          EXEC_MEM_R_SIGNED,

        // メモリ(W)
        output reg          EXEC_MEM_W_EN,
        output reg  [31:0]  EXEC_MEM_W_ADDR,
        output reg  [3:0]   EXEC_MEM_W_STRB,
        output reg  [31:0]  EXEC_MEM_W_DATA,

        // PC更新
        output reg          EXEC_JMP_DO,
        output reg  [31:0]  EXEC_JMP_PC,

        // 例外
        output reg          EXEC_EXC_EN,
        output reg  [3:0]   EXEC_EXC_CODE
    );

    /* ----- 入力取り込み ----- */
    reg         [31:0] pc, imm, rs1_data, rs2_data, csr_data;
    reg         [11:0] csr_addr;
    reg         [16:0] opcode;
    reg         [4:0]  rd_addr, rs1_addr, rs2_addr;

    wire signed [31:0] rs1_data_s, rs2_data_s;

    assign rs1_data_s = rs1_data;
    assign rs2_data_s = rs2_data;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            opcode <= 17'b0;
            rd_addr <= 5'b0;
            rs1_addr <= 5'b0;
            rs1_data <= 32'b0;
            rs2_addr <= 5'b0;
            rs2_data <= 32'b0;
            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            imm <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else if (STALL) begin
            pc <= 32'b0;
            opcode <= 17'b0;
            rd_addr <= 5'b0;
            rs1_addr <= 5'b0;
            rs1_data <= 32'b0;
            rs2_addr <= 5'b0;
            rs2_data <= 32'b0;
            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            imm <= 32'b0;
        end
        else begin
            pc <= PC;
            opcode <= OPCODE;
            rd_addr <= RD_ADDR;
            rs1_addr <= RS1_ADDR;
            rs1_data <= RS1_DATA;
            rs2_addr <= RS2_ADDR;
            rs2_data <= RS2_DATA;
            csr_addr <= CSR_ADDR;
            csr_data <= CSR_DATA;
            imm <= IMM;
        end
    end

    /* ----- 実行 ----- */
    assign EXEC_PC = pc;

    // 整数演算
    always @* begin
        casez (opcode)
            17'b0110011_000_0000000: begin  // add
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data + rs2_data;
            end
            17'b0010011_000_zzzzzzz: begin  // addi
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data + { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_000_0100000: begin  // sub
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data - rs2_data;
            end
            17'b0110011_111_0000000: begin  // and
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data & rs2_data;
            end
            17'b0010011_111_zzzzzzz: begin  // andi
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data & { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_110_0000000: begin  // or
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data | rs2_data;
            end
            17'b0010011_110_zzzzzzz: begin  // ori
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data | { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_100_0000000: begin  // xor
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data ^ rs2_data;
            end
            17'b0010011_100_zzzzzzz: begin  // xori
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data ^ { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_001_0000000: begin  // sll
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data << (rs2_data[4:0]);
            end
            17'b0010011_001_0000000: begin  // slli
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data << (imm[4:0]);
            end
            17'b0110011_101_0100000: begin  // sra
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data_s >>> (rs2_data[4:0]);
            end
            17'b0010011_101_0100000: begin  // srai
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data_s >>> (imm[4:0]);
            end
            17'b0110011_101_0000000: begin  // srl
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data >> (rs2_data[4:0]);
            end
            17'b0010011_101_0000000: begin  // srli
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data >> (imm[4:0]);
            end
            17'b0110111_zzz_zzzzzzz: begin  // lui
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= (imm[31:12]) << 12;
            end
            17'b0010111_zzz_zzzzzzz: begin  // auipc
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= pc + ((imm[31:12]) << 12);
            end
            17'b0110011_010_0000000: begin  // slt
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data_s < rs2_data_s ? 32'b1 : 32'b0;
            end
            17'b0110011_011_0000000: begin  // sltu
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data < rs2_data ? 32'b1 : 32'b0;
            end
            17'b0010011_010_zzzzzzz: begin  // slti
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data_s < $signed({ { 20{ imm[11] } }, imm[11:0] }) ? 32'b1 : 32'b0;
            end
            17'b0010011_011_zzzzzzz: begin  // sltiu
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= rs1_data < { { 20{ imm[11] } }, imm[11:0] } ? 32'b1 : 32'b0;
            end
            17'b1101111_zzz_zzzzzzz: begin  // jal
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= pc + 32'd4;
            end
            17'b1100111_000_zzzzzzz: begin  // jalr
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= pc + 32'd4;
            end
            17'b0000011_000_zzzzzzz: begin  // lb
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_100_zzzzzzz: begin  // lbus
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_001_zzzzzzz: begin  // lh
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_fff;
            end
            17'b0000011_101_zzzzzzz: begin  // lhu
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_010_zzzzzzz: begin  // lw
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_000_zzzzzzz: begin  // sb
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_001_zzzzzzz: begin  // sh
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_010_zzzzzzz: begin  // sw
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= 32'hffff_ffff;
            end
            17'b1110011_011_zzzzzzz: begin // csrrc
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            17'b1110011_111_zzzzzzz: begin // csrrci
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            17'b1110011_010_zzzzzzz: begin // csrrs
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            17'b1110011_110_zzzzzzz: begin // csrrsi
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            17'b1110011_001_zzzzzzz: begin // csrrw
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            17'b1110011_101_zzzzzzz: begin // csrrwi
                EXEC_REG_W_EN <= 1'b1;
                EXEC_REG_W_RD <= rd_addr;
                EXEC_REG_W_DATA <= csr_data;
            end
            default: begin
                EXEC_REG_W_EN <= 1'b0;
                EXEC_REG_W_RD <= 5'b0;
                EXEC_REG_W_DATA <= 32'b0;
            end
        endcase
    end

    // メモリ操作
    always @* begin
        casez (opcode[16:7])
            10'b0000011_000: begin  // lb
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= rd_addr;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0001;
                EXEC_MEM_R_SIGNED <= 1'b1;
            end
            10'b0000011_100: begin  // lbu
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= rd_addr;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0001;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            10'b0000011_001: begin  // lh
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= rd_addr;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0011;
                EXEC_MEM_R_SIGNED <= 1'b1;
            end
            10'b0000011_101: begin  // lhu
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= rd_addr;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0011;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            10'b0000011_010: begin  // lw
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= rd_addr;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b1111;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            10'b0100011_000: begin  // sb
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= 5'b0;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0001;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            10'b0100011_001: begin  // sh
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= 5'b0;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b0011;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            10'b0100011_010: begin  // sw
                EXEC_MEM_R_EN <= 1'b1;
                EXEC_MEM_R_RD <= 5'b0;
                EXEC_MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_R_STRB <= 4'b1111;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
            default: begin
                EXEC_MEM_R_EN <= 1'b0;
                EXEC_MEM_R_RD <= 5'b0;
                EXEC_MEM_R_ADDR <= 32'b0;
                EXEC_MEM_R_STRB <= 4'b0;
                EXEC_MEM_R_SIGNED <= 1'b0;
            end
        endcase
    end

    always @* begin
        casez (opcode[16:7])
            10'b0100011_000: begin  // sb
                EXEC_MEM_W_EN <= 1'b1;
                EXEC_MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_W_STRB <= 4'b0001;
                EXEC_MEM_W_DATA <= rs2_data;
            end
            10'b0100011_001: begin  // sh
                EXEC_MEM_W_EN <= 1'b1;
                EXEC_MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_W_STRB <= 4'b0011;
                EXEC_MEM_W_DATA <= rs2_data;
            end
            10'b0100011_010: begin  // sw
                EXEC_MEM_W_EN <= 1'b1;
                EXEC_MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                EXEC_MEM_W_STRB <= 4'b1111;
                EXEC_MEM_W_DATA <= rs2_data;
            end
            default: begin
                EXEC_MEM_W_EN <= 1'b0;
                EXEC_MEM_W_ADDR <= 32'b0;
                EXEC_MEM_W_STRB <= 4'b0;
                EXEC_MEM_W_DATA <= 32'b0;
            end
        endcase
    end

    // PC更新
    always @* begin
        casez (opcode[16:7])
            10'b1100011_000: begin  // beq
                EXEC_JMP_DO <= rs1_data == rs2_data;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100011_001: begin  // bne
                EXEC_JMP_DO <= rs1_data != rs2_data;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100011_101: begin  // bge
                EXEC_JMP_DO <= rs1_data_s >= rs2_data_s;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100011_111: begin  // bgeu
                EXEC_JMP_DO <= rs1_data >= rs2_data;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100011_100: begin  // blt
                EXEC_JMP_DO <= rs1_data_s < rs2_data_s;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100011_110: begin  // bltu
                EXEC_JMP_DO <= rs1_data < rs2_data;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1101111_zzz: begin  // jal
                EXEC_JMP_DO <= 1'b1;
                EXEC_JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            10'b1100111_000: begin  // jalr
                EXEC_JMP_DO <= 1'b1;
                EXEC_JMP_PC <= (rs1_data + { { 20{ imm[11] } }, imm[11:0] }) & (~32'b1);
            end
            default: begin
                EXEC_JMP_DO <= 1'b0;
                EXEC_JMP_PC <= 32'b0;
            end
        endcase
    end

    // CSRs
    always @* begin
        casez (opcode[16:7])
            10'b1110011_011: begin // csrrc
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= csr_data & (~rs1_data);
            end
            10'b1110011_111: begin // csrrci
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= csr_data & { 27'h1ff_ffff, (~rs1_addr) };
            end
            10'b1110011_010: begin // csrrs
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= csr_data | rs1_data;
            end
            10'b1110011_110: begin // csrrsi
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= csr_data | { 27'b0, rs1_addr };
            end
            10'b1110011_001: begin // csrrw
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= rs1_data;
            end
            10'b1110011_101: begin // csrrwi
                EXEC_CSR_W_EN <= 1'b1;
                EXEC_CSR_W_ADDR <= csr_addr;
                EXEC_CSR_W_DATA <= csr_data | { 27'b0, rs1_addr };
            end
            default: begin
                EXEC_CSR_W_EN <= 1'b0;
                EXEC_CSR_W_ADDR <= 12'b0;
                EXEC_CSR_W_DATA <= 32'b0;
            end
        endcase
    end

    // 例外
    always @* begin
        if (imm == 32'hffff_ffff) begin // Illegal instruction
            EXEC_EXC_EN <= 1'b1;
            EXEC_EXC_CODE <= 4'd2;
        end
        else if (opcode == 17'b1110011_000_0000000) begin // Environment break or call
            EXEC_EXC_EN <= 1'b1;
            EXEC_EXC_CODE <= imm[11:0] == 12'b0 ? 4'd11 : 4'd3;
        end
        else begin
            EXEC_EXC_EN <= 1'b0;
            EXEC_EXC_CODE <= 4'b0;
        end
    end

    // その他
    // always @* begin
        // fence
        // fence.i
    // end

endmodule
