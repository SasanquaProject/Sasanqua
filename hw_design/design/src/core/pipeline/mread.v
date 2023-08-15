module mread
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          MEM_WAIT,

        /* ----- MMUとの接続 ----- */
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RIADDR,
        input wire  [31:0]  DATA_ROADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,

        /* ----- 待機部との接続 ----- */
        // レジスタ(rv32i:W)
        input wire  [4:0]   CUSHION_REG_W_RD,
        input wire  [31:0]  CUSHION_REG_W_DATA,

        // レジスタ(csrs:W)
        input wire  [11:0]  CUSHION_CSR_W_ADDR,
        input wire  [31:0]  CUSHION_CSR_W_DATA,

        // メモリ(R)
        input wire          CUSHION_MEM_R_VALID,
        input wire  [4:0]   CUSHION_MEM_R_RD,
        input wire  [31:0]  CUSHION_MEM_R_ADDR,
        input wire  [3:0]   CUSHION_MEM_R_STRB,
        input wire          CUSHION_MEM_R_SIGNED,

        // メモリ(W)
        input wire          CUSHION_MEM_W_VALID,
        input wire  [31:0]  CUSHION_MEM_W_ADDR,
        input wire  [3:0]   CUSHION_MEM_W_STRB,
        input wire  [31:0]  CUSHION_MEM_W_DATA,

        // PC更新
        input wire          CUSHION_JMP_DO,
        input wire  [31:0]  CUSHION_JMP_PC,

        /* ----- メモリアクセス(w)部との接続 ----- */
        // レジスタ(rv32i:W)
        output wire [4:0]   MEMR_REG_W_RD,
        output wire [31:0]  MEMR_REG_W_DATA,

        // レジスタ(csrs:W)
        output wire [11:0]  MEMR_CSR_W_ADDR,
        output wire [31:0]  MEMR_CSR_W_DATA,

        // メモリ(W)
        output wire         MEMR_MEM_W_VALID,
        output wire [31:0]  MEMR_MEM_W_ADDR,
        output wire [3:0]   MEMR_MEM_W_STRB,
        output wire [31:0]  MEMR_MEM_W_DATA,

        // PC更新
        output wire         MEMR_JMP_DO,
        output wire [31:0]  MEMR_JMP_PC
    );

    /* ----- MMUとの接続 ----- */
    assign DATA_RDEN    = CUSHION_MEM_R_VALID;
    assign DATA_RIADDR  = CUSHION_MEM_R_ADDR;

    /* ----- 入力取り込み ----- */
    reg         cushion_mem_r_valid, cushion_mem_r_signed, cushion_mem_w_valid, cushion_jmp_do;
    reg [31:0]  cushion_reg_w_data, cushion_csr_w_data, cushion_mem_r_addr, cushion_mem_w_addr, cushion_mem_w_data, cushion_jmp_pc;
    reg [11:0]  cushion_csr_w_addr;
    reg [4:0]   cushion_reg_w_rd, cushion_mem_r_rd;
    reg [3:0]   cushion_mem_r_strb, cushion_mem_w_strb;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            cushion_reg_w_rd <= 5'b0;
            cushion_reg_w_data <= 32'b0;
            cushion_csr_w_addr <= 12'b0;
            cushion_csr_w_data <= 32'b0;
            cushion_mem_r_valid <= 1'b0;
            cushion_mem_r_rd <= 5'b0;
            cushion_mem_r_addr <= 32'b0;
            cushion_mem_r_strb <= 4'b0;
            cushion_mem_r_signed <= 1'b0;
            cushion_mem_w_valid <= 1'b0;
            cushion_mem_w_addr <= 32'b0;
            cushion_mem_w_strb <= 4'b0;
            cushion_mem_w_data <= 32'b0;
            cushion_jmp_do <= 1'b0;
            cushion_jmp_pc <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            cushion_reg_w_rd <= CUSHION_REG_W_RD;
            cushion_reg_w_data <= CUSHION_REG_W_DATA;
            cushion_csr_w_addr <= CUSHION_CSR_W_ADDR;
            cushion_csr_w_data <= CUSHION_CSR_W_DATA;
            cushion_mem_r_valid <= CUSHION_MEM_R_VALID;
            cushion_mem_r_rd <= CUSHION_MEM_R_RD;
            cushion_mem_r_addr <= CUSHION_MEM_R_ADDR;
            cushion_mem_r_strb <= CUSHION_MEM_R_STRB;
            cushion_mem_r_signed <= CUSHION_MEM_R_SIGNED;
            cushion_mem_w_valid <= CUSHION_MEM_W_VALID;
            cushion_mem_w_addr <= CUSHION_MEM_W_ADDR;
            cushion_mem_w_strb <= CUSHION_MEM_W_STRB;
            cushion_mem_w_data <= CUSHION_MEM_W_DATA;
            cushion_jmp_do <= CUSHION_JMP_DO;
            cushion_jmp_pc <= CUSHION_JMP_PC;
        end
    end

    /* ----- 出力 ----- */
    wire [31:0] rddata, wrdata;

    assign rddata            = gen_rddata(DATA_RDATA, cushion_mem_r_addr, cushion_mem_r_strb, cushion_mem_r_signed);
    assign wrdata            = gen_wrdata(cushion_mem_w_addr, cushion_mem_w_strb, DATA_RDATA, cushion_mem_w_data);

    assign MEMR_REG_W_RD     = cushion_mem_r_valid ? cushion_mem_r_rd : cushion_reg_w_rd;
    assign MEMR_REG_W_DATA   = cushion_mem_r_valid ? rddata : cushion_reg_w_data;
    assign MEMR_CSR_W_ADDR   = cushion_csr_w_addr;
    assign MEMR_CSR_W_DATA   = cushion_csr_w_data;
    assign MEMR_MEM_W_VALID  = cushion_mem_w_valid;
    assign MEMR_MEM_W_ADDR   = cushion_mem_w_addr;
    assign MEMR_MEM_W_STRB   = cushion_mem_w_strb;
    assign MEMR_MEM_W_DATA   = wrdata;
    assign MEMR_JMP_DO       = cushion_jmp_do;
    assign MEMR_JMP_PC       = cushion_jmp_pc;

    function [31:0] gen_rddata;
        input [31:0]    DATA;
        input [31:0]    ADDR;
        input [3:0]     STRB;
        input           SIGNED;

        case ((STRB << ADDR[1:0]))
            4'b0001: gen_rddata = SIGNED ? { { 24{ DATA[ 7] } }, DATA[ 7: 0] } : { 24'b0, DATA[ 7: 0] };
            4'b0010: gen_rddata = SIGNED ? { { 24{ DATA[15] } }, DATA[15: 8] } : { 24'b0, DATA[15: 8] };
            4'b0100: gen_rddata = SIGNED ? { { 24{ DATA[23] } }, DATA[23:16] } : { 24'b0, DATA[23:16] };
            4'b1000: gen_rddata = SIGNED ? { { 24{ DATA[31] } }, DATA[31:24] } : { 24'b0, DATA[31:24] };
            4'b0011: gen_rddata = SIGNED ? { { 16{ DATA[15] } }, DATA[15: 0] } : { 15'b0, DATA[15: 0] };
            4'b0110: gen_rddata = SIGNED ? { { 16{ DATA[23] } }, DATA[23: 8] } : { 15'b0, DATA[23: 8] };
            4'b1100: gen_rddata = SIGNED ? { { 16{ DATA[31] } }, DATA[31:16] } : { 15'b0, DATA[31:16] };
            default: gen_rddata = DATA;
        endcase
    endfunction

    function [31:0] gen_wrdata;
        input [31:0]    ADDR;
        input [3:0]     STRB;
        input [31:0]    DST;
        input [31:0]    SRC;

        case ((STRB << ADDR[1:0]))
            4'b0001: gen_wrdata = (DST & 32'hffff_ff00) | { 24'b0, SRC[7:0] };
            4'b0010: gen_wrdata = (DST & 32'hffff_00ff) | { 16'b0, SRC[7:0], 8'b0 };
            4'b0100: gen_wrdata = (DST & 32'hff00_ffff) | { 8'b0, SRC[7:0], 16'b0 };
            4'b1000: gen_wrdata = (DST & 32'h00ff_ffff) | { SRC[7:0], 24'b0 };
            4'b0011: gen_wrdata = (DST & 32'hffff_0000) | { 16'b0, SRC[15:0] };
            4'b0110: gen_wrdata = (DST & 32'hff00_00ff) | { 8'b0, SRC[15:0], 8'b0 };
            4'b1100: gen_wrdata = (DST & 32'h0000_ffff) | { SRC[15:0], 16'b0 };
            default: gen_wrdata = SRC;
        endcase
    endfunction

endmodule
