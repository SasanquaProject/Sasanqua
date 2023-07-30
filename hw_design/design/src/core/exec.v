module exec
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- データフォワーディング ----- */
        input wire  [4:0]   REG_FWD_A,
        input wire  [31:0]  REG_FWD_AV,
        input wire  [4:0]   REG_FWD_B,
        input wire  [31:0]  REG_FWD_BV,
        input wire  [4:0]   REG_FWD_C,
        input wire  [31:0]  REG_FWD_CV,

        /* ----- 前段との接続 ----- */
        input wire          VALID,
        input wire  [31:0]  PC,
        input wire  [6:0]   OPCODE,
        input wire  [4:0]   RD,
        input wire  [4:0]   RS1,
        input wire  [31:0]  RS1_V,
        input wire  [4:0]   RS2,
        input wire  [31:0]  RS2_V,
        input wire  [2:0]   FUNCT3,
        input wire  [6:0]   FUNCT7,
        input wire  [31:0]  IMM,

        /* ----- 後段との接続 ----- */
        // レジスタ(W)
        output reg  [4:0]   REG_W_RD,
        output reg  [31:0]  REG_W_DATA,

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
    reg                 valid;
    reg         [31:0]  pc, imm, rs1_v_nf, rs2_v_nf;
    reg         [6:0]   opcode, funct7;
    reg         [4:0]   rd, rs1, rs2;
    reg         [2:0]   funct3;

    always @ (posedge CLK) begin
        if (RST) begin
            valid <= 1'b0;
            pc <= 32'b0;
            opcode <= 7'b0;
            rd <= 5'b0;
            rs1 <= 5'b0;
            rs1_v_nf <= 32'b0;
            rs2 <= 5'b0;
            rs2_v_nf <= 32'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
            imm <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            valid <= VALID;
            pc <= PC;
            opcode <= OPCODE;
            rd <= RD;
            rs1 <= RS1;
            rs1_v_nf <= RS1_V;
            rs2 <= RS2;
            rs2_v_nf <= RS2_V;
            funct3 <= FUNCT3;
            funct7 <= FUNCT7;
            imm <= IMM;
        end
    end

    /* ----- データフォワーディング ----- */
    wire        [31:0]  rs1_v, rs2_v;
    wire signed [31:0]  rs1_v_s, rs2_v_s;

    assign      rs1_v   = forwarding(rs1, rs1_v_nf, REG_FWD_A, REG_FWD_AV, REG_FWD_B, REG_FWD_BV, REG_FWD_C, REG_FWD_CV);
    assign      rs2_v   = forwarding(rs2, rs2_v_nf, REG_FWD_A, REG_FWD_AV, REG_FWD_B, REG_FWD_BV, REG_FWD_C, REG_FWD_CV);
    assign      rs1_v_s = rs1_v;
    assign      rs2_v_s = rs2_v;

    function [31:0] forwarding;
        input [4:0]     target;
        input [31:0]    target_v;
        input [4:0]     reg_a;
        input [31:0]    reg_a_v;
        input [4:0]     reg_b;
        input [31:0]    reg_b_v;
        input [4:0]     reg_c;
        input [31:0]    reg_c_v;

        case (target)
            reg_a:   forwarding = reg_a_v;
            reg_b:   forwarding = reg_b_v;
            reg_c:   forwarding = reg_c_v;
            default: forwarding = target_v;
        endcase
    endfunction

    /* ----- 実行 ----- */
    // 整数演算
    always @* begin
        casez ({opcode, funct3, funct7})
            17'b0110011_000_0000000: begin  // add
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v + rs2_v;
            end
            17'b0010011_000_zzzzzzz: begin  // addi
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v + { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_000_0100000: begin  // sub
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v - rs2_v;
            end
            17'b0110011_111_0000000: begin  // and
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v & rs2_v;
            end
            17'b0010011_111_zzzzzzz: begin  // andi
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v & { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_110_0000000: begin  // or
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v | rs2_v;
            end
            17'b0010011_110_zzzzzzz: begin  // ori
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v | { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_100_0000000: begin  // xor
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v ^ rs2_v;
            end
            17'b0010011_100_zzzzzzz: begin  // xori
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v ^ { { 20{ imm[11] } }, imm[11:0] };
            end
            17'b0110011_001_0000000: begin  // sll
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v << (rs2_v[4:0]);
            end
            17'b0010011_001_0000000: begin  // slli
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v << (imm[4:0]);
            end
            17'b0110011_101_0100000: begin  // sra
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v_s >>> (rs2_v[4:0]);
            end
            17'b0010011_101_0100000: begin  // srai
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v_s >>> (imm[4:0]);
            end
            17'b0110011_101_0000000: begin  // srl
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v >> (rs2_v[4:0]);
            end
            17'b0010011_101_0000000: begin  // srli
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v >> (imm[4:0]);
            end
            17'b0110111_zzz_zzzzzzz: begin  // lui
                REG_W_RD <= rd;
                REG_W_DATA <= (imm[31:12]) << 12;
            end
            17'b0010111_zzz_zzzzzzz: begin  // auipc
                REG_W_RD <= rd;
                REG_W_DATA <= pc + ((imm[31:12]) << 12);
            end
            17'b0110011_010_0000000: begin  // slt
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v_s < rs2_v_s ? 32'b1 : 32'b0;
            end
            17'b0110011_011_0000000: begin  // swltuq
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v < rs2_v ? 32'b1 : 32'b0;
            end
            17'b0010011_010_zzzzzzz: begin  // slti
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v_s < { { 20{ imm[11] } }, imm[11:0] } ? 32'b1 : 32'b0;
            end
            17'b0010011_011_zzzzzzz: begin  // sltiu
                REG_W_RD <= rd;
                REG_W_DATA <= rs1_v < { { 20{ imm[11] } }, imm[11:0] } ? 32'b1 : 32'b0;
            end
            17'b1101111_zzz_zzzzzzz: begin  // jal
                REG_W_RD <= rd;
                REG_W_DATA <= pc + 32'd4;
            end
            17'b1100111_000_zzzzzzz: begin  // jalr
                REG_W_RD <= rd;
                REG_W_DATA <= pc + 32'd4;
            end
            default: begin
                REG_W_RD <= 5'b0;
                REG_W_DATA <= 32'b0;
            end
        endcase
    end

    // メモリ操作
    always @* begin
        casez ({opcode, funct3, funct7})
            17'b0000011_000_zzzzzzz: begin  // lb
                MEM_R_VALID <= valid;
                MEM_R_RD <= rd;
                MEM_R_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:2], 2'b0 };
                MEM_R_STRB <= 4'b0001 << (imm[1:0]);
                MEM_R_SIGNED <= 1'b1;
            end
            17'b0000011_100_zzzzzzz: begin  // lbu
                MEM_R_VALID <= valid;
                MEM_R_RD <= rd;
                MEM_R_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:0], 2'b0 };
                MEM_R_STRB <= 4'b0001 << (imm[1:0]);
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0000011_001_zzzzzzz: begin  // lh
                MEM_R_VALID <= valid;
                MEM_R_RD <= rd;
                MEM_R_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:0], 2'b0 };
                MEM_R_STRB <= 4'b0011 << (imm[1:0]);
                MEM_R_SIGNED <= 1'b1;
            end
            17'b0000011_101_zzzzzzz: begin  // lhu
                MEM_R_VALID <= valid;
                MEM_R_RD <= rd;
                MEM_R_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:0], 2'b0 };
                MEM_R_STRB <= 4'b0011 << (imm[1:0]);
                MEM_R_SIGNED <= 1'b0;
            end
            17'b0000011_010_zzzzzzz: begin  // lw
                MEM_R_VALID <= valid;
                MEM_R_RD <= rd;
                MEM_R_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:0], 2'b0 };
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
                MEM_W_VALID <= valid;
                MEM_W_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:2], 2'b0 };
                MEM_W_STRB <= 4'b0001 << (imm[1:0]);
                MEM_W_DATA <= rs2_v << ({ imm[1:0], 3'b0 });
            end
            17'b0100011_001_zzzzzzz: begin  // sh
                MEM_W_VALID <= valid;
                MEM_W_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:2], 2'b0 };
                MEM_W_STRB <= 4'b0011 << (imm[1:0]);
                MEM_W_DATA <= rs2_v << ({ imm[1:0], 3'b0 });
            end
            17'b0100011_010_zzzzzzz: begin  // sw
                MEM_W_VALID <= valid;
                MEM_W_ADDR <= rs1_v + { { 20{ imm[11] } }, imm[11:2], 2'b0 };
                MEM_W_STRB <= 4'b1111;
                MEM_W_DATA <= rs2_v;
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
                JMP_DO <= rs1_v == rs2_v;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_001_zzzzzzz: begin  // bne
                JMP_DO <= rs1_v != rs2_v;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_101_zzzzzzz: begin  // bge
                JMP_DO <= rs1_v_s >= rs2_v_s;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_111_zzzzzzz: begin  // bgeu
                JMP_DO <= rs1_v >= rs2_v;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_100_zzzzzzz: begin  // blt
                JMP_DO <= rs1_v_s < rs2_v_s;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100011_110_zzzzzzz: begin  // bltu
                JMP_DO <= rs1_v < rs2_v;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1101111_zzz_zzzzzzz: begin  // jal
                JMP_DO <= 1'b1;
                JMP_PC <= pc + { { 19{ imm[12] } }, imm[12:1], 1'b0 };
            end
            17'b1100111_000_zzzzzzz: begin  // jalr
                JMP_DO <= 1'b1;
                JMP_PC <= (rs1_v + { { 20{ imm[11] } }, imm[11:0] }) & (~32'b1);
            end
            default: begin
                JMP_DO <= 1'b0;
                JMP_PC <= 32'b0;
            end
        endcase
    end

    // その他
    always @* begin
        // fence
        // fence.i
        // ebreak
        // ecall
        // csrrc
        // csrrci
        // csrrs
        // csrrsi
        // csrrw
        // csrrwi
    end

endmodule
