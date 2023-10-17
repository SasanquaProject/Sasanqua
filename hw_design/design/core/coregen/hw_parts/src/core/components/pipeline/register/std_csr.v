module reg_std_csr
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,

        // パイプライン
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        // Trap
        input wire          TRAP_EN,
        input wire  [31:0]  TRAP_CODE,
        input wire  [31:0]  TRAP_PC,
        output wire [1:0]   TRAP_VEC_MODE,
        output wire [31:0]  TRAP_VEC_BASE,

        // 割り込み
        output wire         INT_ALLOW,

        /* ----- レジスタアクセス ----- */
        // 読み
        input wire  [11:0]  RADDR,
        output reg          RVALID,
        output reg  [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [11:0]  WADDR,
        input wire  [31:0]  WDATA,

        /* ----- データフォワーディング ----- */
        input wire  [11:0]  FWD_CSR_ADDR,

        input wire          FWD_EXEC_EN,
        input wire  [11:0]  FWD_EXEC_ADDR,
        input wire  [31:0]  FWD_EXEC_DATA,

        input wire          FWD_CUSHION_EN,
        input wire  [11:0]  FWD_CUSHION_ADDR,
        input wire  [31:0]  FWD_CUSHION_DATA
    );

    /* ----- 他モジュールへの制御信号 ----- */
    assign TRAP_VEC_MODE = mtvec[1:0];
    assign TRAP_VEC_BASE = { mtvec[31:2], 2'b0 };
    assign INT_ALLOW     = mstatus[3];

    /* ----- 入力取り込み ----- */
    reg  [11:0] raddr, waddr, fwd_csr_addr, fwd_exec_addr, fwd_cushion_addr;
    reg  [31:0] wdata, fwd_exec_data, fwd_cushion_data;
    reg         fwd_exec_en, fwd_cushion_en;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            raddr <= 12'b0;
            waddr <= 12'b0;
            wdata <= 32'b0;
            fwd_csr_addr <= 12'b0;
            fwd_exec_addr <= 12'b0;
            fwd_exec_data <= 32'b0;
            fwd_exec_en <= 1'b0;
            fwd_cushion_addr <= 12'b0;
            fwd_cushion_data <= 32'b0;
            fwd_cushion_en <= 1'b0;
        end
        else if (STALL) begin
            fwd_csr_addr <= 12'b0;
            fwd_exec_addr <= FWD_EXEC_ADDR;
            fwd_exec_data <= FWD_EXEC_DATA;
            fwd_exec_en <= FWD_EXEC_EN;
            fwd_cushion_addr <= FWD_CUSHION_ADDR;
            fwd_cushion_data <= FWD_CUSHION_DATA;
            fwd_cushion_en <= FWD_CUSHION_EN;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            raddr <= RADDR;
            waddr <= WADDR;
            wdata <= WDATA;
            fwd_csr_addr <= FWD_CSR_ADDR;
            fwd_exec_addr <= FWD_EXEC_ADDR;
            fwd_exec_data <= FWD_EXEC_DATA;
            fwd_exec_en <= FWD_EXEC_EN;
            fwd_cushion_addr <= FWD_CUSHION_ADDR;
            fwd_cushion_data <= FWD_CUSHION_DATA;
            fwd_cushion_en <= FWD_CUSHION_EN;
        end
    end

    /* ----- レジスタアクセス ----- */
    // レジスタ群
    reg [31:0] mstatus, mtvec, mscratch, mepc, mcause;

    // 読み
    always @* begin
        case (raddr)
            12'b0:              RVALID <= 1'b1;
            fwd_csr_addr:       RVALID <= 1'b0;
            fwd_exec_addr:      RVALID <= fwd_exec_en;
            fwd_cushion_addr:   RVALID <= fwd_cushion_en;
            default:            RVALID <= 1'b1;
        endcase
    end

    always @* begin
        case (raddr)
            // Fowarding
            12'b0:              RDATA <= 32'b0;
            fwd_exec_addr:      RDATA <= fwd_exec_data;
            fwd_cushion_addr:   RDATA <= fwd_cushion_data;
            waddr:              RDATA <= wdata;

            // CSR
            12'h300:            RDATA <= mstatus;
            12'h305:            RDATA <= mtvec;
            12'h340:            RDATA <= mscratch;
            12'h341:            RDATA <= mepc;
            12'h342:            RDATA <= mcause;
            default:            RDATA <= 32'b0;
        endcase
    end

    // 書き
    always @ (posedge CLK) begin
        if (RST) begin
            mstatus <= 32'b0;
            mtvec <= 32'b0;
            mscratch <= 32'b0;
            mepc <= 32'b0;
            mcause <= 32'b0;
        end
        else if (TRAP_EN) begin
            mstatus <= { 24'b0, mstatus[3], 7'b0 };
            mcause <= TRAP_CODE;
            mepc <= TRAP_PC;
        end
        else begin
            case (WADDR)
                12'h300: mstatus <= WDATA;
                12'h305: mtvec <= WDATA;
                12'h340: mscratch <= WDATA;
                12'h341: mepc <= WDATA;
                12'h342: mcause <= WDATA;
                default: ;
            endcase
        end
    end

endmodule
