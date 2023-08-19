module exec
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- データフォワーディング ----- */
        // RV32i
        input wire  [4:0]   REG_FWD_A,
        input wire  [31:0]  REG_FWD_AV,
        input wire  [4:0]   REG_FWD_B,
        input wire  [31:0]  REG_FWD_BV,
        input wire  [4:0]   REG_FWD_C,
        input wire  [31:0]  REG_FWD_CV,

        // CSRs
        input wire  [11:0]  CSR_FWD_A,
        input wire  [31:0]  CSR_FWD_AV,
        input wire  [11:0]  CSR_FWD_B,
        input wire  [31:0]  CSR_FWD_BV,
        input wire  [11:0]  CSR_FWD_C,
        input wire  [31:0]  CSR_FWD_CV,

        /* ----- 前段との接続 ----- */
        input wire  [31:0]  PC,
        input wire  [6:0]   OPCODE,
        input wire  [4:0]   RD_ADDR,
        input wire  [4:0]   RS1_ADDR,
        input wire  [31:0]  RS1_DATA,
        input wire  [4:0]   RS2_ADDR,
        input wire  [31:0]  RS2_DATA,
        input wire  [31:0]  CSR_DATA,
        input wire  [2:0]   FUNCT3,
        input wire  [6:0]   FUNCT7,
        input wire  [31:0]  IMM,

        /* ----- 後段との接続 ----- */
        // レジスタ(rv32i:W)
        output reg          REG_W_VALID,
        output reg  [4:0]   REG_W_RD,
        output reg  [31:0]  REG_W_DATA,

        // レジスタ(csrs:W)
        output reg          CSR_W_VALID,
        output reg  [11:0]  CSR_W_ADDR,
        output reg  [31:0]  CSR_W_DATA,

        // メモリ(R)
        output reg          MEM_R_VALID,
        output reg  [4:0]   MEM_R_RD,
        output reg  [31:0]  MEM_R_ADDR,
        output reg  [3:0]   MEM_R_STRB,
        output reg          MEM_R_SIGNED,

        // メモリ(W)
        output reg          MEM_W_VALID,
        output reg  [31:0]  MEM_W_ADDR,
        output reg  [3:0]   MEM_W_STRB,
        output reg  [31:0]  MEM_W_DATA,

        // PC更新
        output reg          JMP_DO,
        output reg  [31:0]  JMP_PC
    );

    /* ----- 入力取り込み ----- */
    reg         [31:0] pc, imm, rs1_data, rs2_data, csr_data;
    reg         [6:0]  opcode, funct7;
    reg         [4:0]  rd_addr, rs1_addr, rs2_addr;
    reg         [2:0]  funct3;

    wire signed [31:0] rs1_data_s, rs2_data_s;

    assign rs1_data_s = rs1_data;
    assign rs2_data_s = rs2_data;

    always @ (posedge CLK) begin
        if (RST || FLUSH || STALL) begin
            pc <= 32'b0;
            opcode <= 7'b0;
            rd_addr <= 5'b0;
            rs1_addr <= 5'b0;
            rs1_data <= 32'b0;
            rs2_addr <= 5'b0;
            rs2_data <= 32'b0;
            csr_data <= 32'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
            imm <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            opcode <= OPCODE;
            rd_addr <= RD_ADDR;
            rs1_addr <= RS1_ADDR;
            rs1_data <= RS1_DATA;
            rs2_addr <= RS2_ADDR;
            rs2_data <= RS2_DATA;
            csr_data <= CSR_DATA;
            funct3 <= FUNCT3;
            funct7 <= FUNCT7;
            imm <= IMM;
        end
    end

    /* ----- 実行 ----- */
    // 整数演算
    always @* begin
        casez ({opcode, funct3, funct7})
            17'b0110011_000_0000000: begin  // add
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data + rs2_data;
            end
            17'b0010011_000_zzzzzzz: begin  // addi
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data + { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_000_0100000: begin  // sub
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data - rs2_data;
            end
            17'b0110011_111_0000000: begin  // and
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data & rs2_data;
            end
            17'b0010011_111_zzzzzzz: begin  // andi
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data & { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_110_0000000: begin  // or
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data | rs2_data;
            end
            17'b0010011_110_zzzzzzz: begin  // ori
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data | { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_100_0000000: begin  // xor
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data ^ rs2_data;
            end
            17'b0010011_100_zzzzzzz: begin  // xori
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data ^ { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_001_0000000: begin  // sll
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data << (rs2_data[4:0]);
            end
            17'b0010011_001_0000000: begin  // slli
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data << (imm[4:0]);
            end
            17'b0110011_101_0100000: begin  // sra
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data_s >>> (rs2_data[4:0]);
            end
            17'b0010011_101_0100000: begin  // srai
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data_s >>> (imm[4:0]);
            end
            17'b0110011_101_0000000: begin  // srl
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data >> (rs2_data[4:0]);
            end
            17'b0010011_101_0000000: begin  // srli
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data >> (imm[4:0]);
            end
            17'b0110111_zzz_zzzzzzz: begin  // lui
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= (imm[31:12]) << 12;
            end
            17'b0010111_zzz_zzzzzzz: begin  // auipc
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= pc + ((imm[31:12]) << 12);
            end
            17'b0110011_010_0000000: begin  // slt
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data_s < rs2_data_s ? 32'b1 : 32'b0;
            end
            17'b0110011_011_0000000: begin  // sltu
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data < rs2_data ? 32'b1 : 32'b0;
            end
            17'b0010011_010_zzzzzzz: begin  // slti
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data_s < $signed({ { 20{ imm[11] } }, imm[11:0] }) ? 32'b1 : 32'b0;
            end
            17'b0010011_011_zzzzzzz: begin  // sltiu
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= rs1_data < { { 20{ imm[11] } }, imm[11:0] } ? 32'b1 : 32'b0;
            end
            17'b1101111_zzz_zzzzzzz: begin  // jal
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= pc + 32'd4;
            end
            17'b1100111_000_zzzzzzz: begin  // jalr
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= pc + 32'd4;
            end
            17'b0000011_000_zzzzzzz: begin  // lb
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_100_zzzzzzz: begin  // lbus
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_001_zzzzzzz: begin  // lh
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_fff;
            end
            17'b0000011_101_zzzzzzz: begin  // lhu
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0000011_010_zzzzzzz: begin  // lw
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_000_zzzzzzz: begin  // sb
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_001_zzzzzzz: begin  // sh
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b0100011_010_zzzzzzz: begin  // sw
                REG_W_VALID <= 1'b0;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= 32'hffff_ffff;
            end
            17'b1110011_011_zzzzzzz: begin // csrrc
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            17'b1110011_111_zzzzzzz: begin // csrrci
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            17'b1110011_010_zzzzzzz: begin // csrrs
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            17'b1110011_110_zzzzzzz: begin // csrrsi
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            17'b1110011_001_zzzzzzz: begin // csrrw
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            17'b1110011_101_zzzzzzz: begin // csrrwi
                REG_W_VALID <= 1'b1;
                REG_W_RD <= rd_addr;
                REG_W_DATA <= csr_data;
            end
            default: begin
                REG_W_VALID <= 1'b0;
                REG_W_RD <= 5'b0;
                REG_W_DATA <= 32'b0;
            end
        endcase
    end

    // メモリ操作
    always @* begin
        casez ({opcode, funct3, funct7})
            17'b0000011_000_zzzzzzz: begin  // lb
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= rd_addr;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0001;
                MEM_R_SIGNED <= 1'b1;
            end
            17'b0000011_100_zzzzzzz: begin  // lbu
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= rd_addr;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0001;
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0000011_001_zzzzzzz: begin  // lh
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= rd_addr;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0011;
                MEM_R_SIGNED <= 1'b1;
            end
            17'b0000011_101_zzzzzzz: begin  // lhu
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= rd_addr;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0011;
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0000011_010_zzzzzzz: begin  // lw
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= rd_addr;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b1111;
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0100011_000_zzzzzzz: begin  // sb
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= 5'b0;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0001;
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0100011_001_zzzzzzz: begin  // sh
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= 5'b0;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b0011;
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0100011_010_zzzzzzz: begin  // sw
                MEM_R_VALID <= 1'b1;
                MEM_R_RD <= 5'b0;
                MEM_R_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_R_STRB <= 4'b1111;
                MEM_R_SIGNED <= 1'b0;
            end
            default: begin
                MEM_R_VALID <= 1'b0;
                MEM_R_RD <= 5'b0;
                MEM_R_ADDR <= 32'b0;
                MEM_R_STRB <= 4'b0;
                MEM_R_SIGNED <= 1'b0;
            end
        endcase
    end

    always @* begin
        casez ({opcode, funct3, funct7})
            17'b0100011_000_zzzzzzz: begin  // sb
                MEM_W_VALID <= 1'b1;
                MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_W_STRB <= 4'b0001;
                MEM_W_DATA <= rs2_data;
            end
            17'b0100011_001_zzzzzzz: begin  // sh
                MEM_W_VALID <= 1'b1;
                MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_W_STRB <= 4'b0011;
                MEM_W_DATA <= rs2_data;
            end
            17'b0100011_010_zzzzzzz: begin  // sw
                MEM_W_VALID <= 1'b1;
                MEM_W_ADDR <= rs1_data_s + $signed({ { 20{ imm[11] } }, imm[11:0] });
                MEM_W_STRB <= 4'b1111;
                MEM_W_DATA <= rs2_data;
            end
            default: begin
                MEM_W_VALID <= 1'b0;
                MEM_W_ADDR <= 32'b0;
                MEM_W_STRB <= 4'b0;
                MEM_W_DATA <= 32'b0;
            end
        endcase
    end

    // PC更新
    always @* begin
        casez ({opcode, funct3, funct7})
            17'b1100011_000_zzzzzzz: begin  // beq
                JMP_DO <= rs1_data == rs2_data;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_001_zzzzzzz: begin  // bne
                JMP_DO <= rs1_data != rs2_data;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_101_zzzzzzz: begin  // bge
                JMP_DO <= rs1_data_s >= rs2_data_s;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_111_zzzzzzz: begin  // bgeu
                JMP_DO <= rs1_data >= rs2_data;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_100_zzzzzzz: begin  // blt
                JMP_DO <= rs1_data_s < rs2_data_s;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_110_zzzzzzz: begin  // bltu
                JMP_DO <= rs1_data < rs2_data;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1101111_zzz_zzzzzzz: begin  // jal
                JMP_DO <= 1'b1;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100111_000_zzzzzzz: begin  // jalr
                JMP_DO <= 1'b1;
                JMP_PC <= (rs1_data + { { 20{ imm[11] } }, imm[11:0] }) & (~32'b1);
            end
            17'b1110011_000_0000000: begin // ecall
                JMP_DO <= 1'b1;
                JMP_PC <= 32'h0000_0004;
            end
            default: begin
                JMP_DO <= 1'b0;
                JMP_PC <= 32'b0;
            end
        endcase
    end

    // CSRs
    always @* begin
        casez ({opcode, funct3})
            10'b1110011_011: begin // csrrc
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= csr_data & (~rs1_data);
            end
            10'b1110011_111: begin // csrrci
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= csr_data & { 27'h1ff_ffff, (~rs1_addr) };
            end
            10'b1110011_010: begin // csrrs
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= csr_data | rs1_data;
            end
            10'b1110011_110: begin // csrrsi
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= csr_data | { 27'b0, rs1_addr };
            end
            10'b1110011_001: begin // csrrw
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= rs1_data;
            end
            10'b1110011_101: begin // csrrwi
                CSR_W_VALID <= 1'b1;
                CSR_W_ADDR <= imm[11:0];
                CSR_W_DATA <= csr_data | { 27'b0, rs1_addr };
            end
            default: begin
                CSR_W_VALID <= 1'b0;
                CSR_W_ADDR <= 12'b0;
                CSR_W_DATA <= 32'b0;
            end
        endcase
    end

    // その他
    always @* begin
        // fence
        // fence.i
        // ebreak
        // ecall
    end

endmodule
