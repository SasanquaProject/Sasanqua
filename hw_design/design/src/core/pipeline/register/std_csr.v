module reg_std_csr
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- レジスタアクセス ----- */
        // 読み
        input wire  [11:0]  RIADDR,
        output wire         RVALID,
        output wire [11:0]  ROADDR,
        output wire [31:0]  RDATA,

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

    /* ----- 入力取り込み ----- */
    reg  [11:0] riaddr, waddr, fwd_csr_addr, fwd_exec_addr, fwd_cushion_addr;
    reg  [31:0] wdata, fwd_exec_data, fwd_cushion_data;
    reg         fwd_exec_en, fwd_cushion_en;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            riaddr <= 12'b0;
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
            riaddr <= RIADDR;
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
    wire [32:0] mvendorid, marchid, mimpid, mhartid;

    assign mvendorid    = 32'b0;
    assign marchid      = 32'b0;
    assign mimpid       = 32'b0;
    assign mhartid      = 32'b0;

    // 読み
    reg  [31:0] rdata;

    always @* begin
        case (riaddr)
            12'hf11: rdata <= mvendorid;
            12'hf12: rdata <= marchid;
            12'hf13: rdata <= mimpid;
            12'hf14: rdata <= mhartid;
            default: rdata <= 32'b0;
        endcase
    end

    assign ROADDR = riaddr;
    assign RVALID = forwarding_check(riaddr, fwd_csr_addr, fwd_exec_addr, fwd_exec_en, fwd_cushion_addr, fwd_cushion_en);
    assign RDATA  = forwarding(riaddr, rdata, fwd_exec_addr, fwd_exec_data, fwd_cushion_addr, fwd_cushion_data, waddr, wdata);

    function forwarding_check;
        input [11:0]    target_addr;
        input [11:0]    csr_addr;
        input [11:0]    exec_addr;
        input           exec_en;
        input [11:0]    cushion_addr;
        input           cushion_en;

        case (target_addr)
            12'b0:          forwarding_check = 1'b1;
            csr_addr:       forwarding_check = 1'b0;
            exec_addr:      forwarding_check = exec_en;
            cushion_addr:   forwarding_check = cushion_en;
            default:        forwarding_check = 1'b1;
        endcase
    endfunction

    function [31:0] forwarding;
        input [11:0]    target_addr;
        input [31:0]    target_data;
        input [11:0]    exec_addr;
        input [31:0]    exec_data;
        input [11:0]    cushion_addr;
        input [31:0]    cushion_data;
        input [11:0]    memr_addr;
        input [31:0]    memr_data;

        case (target_addr)
            12'b0:          forwarding = 32'b0;
            exec_addr:      forwarding = exec_data;
            cushion_addr:   forwarding = cushion_data;
            memr_addr:      forwarding = memr_data;
            default:        forwarding = target_data;
        endcase
    endfunction

endmodule
