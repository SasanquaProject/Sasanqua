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
        input wire  [4:0]   REG_W_RD,
        input wire  [31:0]  REG_W_DATA,
        input wire          CSR_W_EN,
        input wire  [11:0]  CSR_W_ADDR,
        input wire  [31:0]  CSR_W_DATA,
        input wire          MEM_R_EN,
        input wire  [4:0]   MEM_R_RD,
        input wire  [31:0]  MEM_R_ADDR,
        input wire  [3:0]   MEM_R_STRB,
        input wire          MEM_R_SIGNED,
        input wire          MEM_W_EN,
        input wire  [31:0]  MEM_W_ADDR,
        input wire  [3:0]   MEM_W_STRB,
        input wire  [31:0]  MEM_W_DATA,
        input wire          JMP_DO,
        input wire  [31:0]  JMP_PC,

        /* ----- メモリアクセス(w)部との接続 ----- */
        output wire [4:0]   MEMR_REG_W_RD,
        output wire [31:0]  MEMR_REG_W_DATA,
        output wire         MEMR_CSR_W_EN,
        output wire [11:0]  MEMR_CSR_W_ADDR,
        output wire [31:0]  MEMR_CSR_W_DATA,
        output wire         MEMR_MEM_W_EN,
        output wire [3:0]   MEMR_MEM_W_STRB,
        output wire [31:0]  MEMR_MEM_W_ADDR,
        output wire [31:0]  MEMR_MEM_W_DATA,
        output wire         MEMR_JMP_DO,
        output wire [31:0]  MEMR_JMP_PC
    );

    /* ----- MMUとの接続 ----- */
    assign DATA_RDEN    = MEM_R_EN;
    assign DATA_RIADDR  = MEM_R_ADDR;

    /* ----- 入力取り込み ----- */
    reg         csr_w_en, mem_r_en, mem_r_signed, mem_w_en, jmp_do;
    reg [31:0]  reg_w_data, csr_w_data, mem_r_addr, mem_w_addr, mem_w_data, jmp_pc;
    reg [11:0]  csr_w_addr;
    reg [4:0]   reg_w_rd, mem_r_rd;
    reg [3:0]   mem_r_strb, mem_w_strb;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            reg_w_rd <= 5'b0;
            reg_w_data <= 32'b0;
            csr_w_en <= 1'b0;
            csr_w_addr <= 12'b0;
            csr_w_data <= 32'b0;
            mem_r_en <= 1'b0;
            mem_r_rd <= 5'b0;
            mem_r_addr <= 32'b0;
            mem_r_strb <= 4'b0;
            mem_r_signed <= 1'b0;
            mem_w_en <= 1'b0;
            mem_w_addr <= 32'b0;
            mem_w_strb <= 4'b0;
            mem_w_data <= 32'b0;
            jmp_do <= 1'b0;
            jmp_pc <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            reg_w_rd <= REG_W_RD;
            reg_w_data <= REG_W_DATA;
            csr_w_en <= CSR_W_EN;
            csr_w_addr <= CSR_W_ADDR;
            csr_w_data <= CSR_W_DATA;
            mem_r_en <= MEM_R_EN;
            mem_r_rd <= MEM_R_RD;
            mem_r_addr <= MEM_R_ADDR;
            mem_r_strb <= MEM_R_STRB;
            mem_r_signed <= MEM_R_SIGNED;
            mem_w_en <= MEM_W_EN;
            mem_w_addr <= MEM_W_ADDR;
            mem_w_strb <= MEM_W_STRB;
            mem_w_data <= MEM_W_DATA;
            jmp_do <= JMP_DO;
            jmp_pc <= JMP_PC;
        end
    end

    /* ----- 出力 ----- */
    assign MEMR_REG_W_RD     = mem_r_en ? mem_r_rd : reg_w_rd;
    assign MEMR_REG_W_DATA   = mem_r_en ? gen_rdata(DATA_RDATA, mem_r_addr, mem_r_strb, mem_r_signed) : reg_w_data;
    assign MEMR_CSR_W_EN     = csr_w_en;
    assign MEMR_CSR_W_ADDR   = csr_w_addr;
    assign MEMR_CSR_W_DATA   = csr_w_data;
    assign MEMR_MEM_W_EN     = mem_w_en;
    assign MEMR_MEM_W_STRB   = mem_w_strb;
    assign MEMR_MEM_W_ADDR   = mem_w_addr;
    assign MEMR_MEM_W_DATA   = mem_w_data;
    assign MEMR_JMP_DO       = jmp_do;
    assign MEMR_JMP_PC       = jmp_pc;

    function [31:0] gen_rdata;
        input [31:0]    DATA;
        input [31:0]    ADDR;
        input [3:0]     STRB;
        input           SIGNED;

        case ((STRB << ADDR[1:0]))
            4'b0001: gen_rdata = SIGNED ? { { 24{ DATA[ 7] } }, DATA[ 7: 0] } : { 24'b0, DATA[ 7: 0] };
            4'b0010: gen_rdata = SIGNED ? { { 24{ DATA[15] } }, DATA[15: 8] } : { 24'b0, DATA[15: 8] };
            4'b0100: gen_rdata = SIGNED ? { { 24{ DATA[23] } }, DATA[23:16] } : { 24'b0, DATA[23:16] };
            4'b1000: gen_rdata = SIGNED ? { { 24{ DATA[31] } }, DATA[31:24] } : { 24'b0, DATA[31:24] };
            4'b0011: gen_rdata = SIGNED ? { { 16{ DATA[15] } }, DATA[15: 0] } : { 15'b0, DATA[15: 0] };
            4'b0110: gen_rdata = SIGNED ? { { 16{ DATA[23] } }, DATA[23: 8] } : { 15'b0, DATA[23: 8] };
            4'b1100: gen_rdata = SIGNED ? { { 16{ DATA[31] } }, DATA[31:16] } : { 15'b0, DATA[31:16] };
            default: gen_rdata = DATA;
        endcase
    endfunction

endmodule
