module reg_std_rv32i
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- レジスタアクセス ----- */
        // 読み
        input wire  [4:0]   A_RADDR,
        output wire         A_RVALID,
        output wire [31:0]  A_RDATA,

        input wire  [4:0]   B_RADDR,
        output wire         B_RVALID,
        output wire [31:0]  B_RDATA,

        input wire  [4:0]   C_RADDR,
        output wire         C_RVALID,
        output wire [31:0]  C_RDATA,

        input wire  [4:0]   D_RADDR,
        output wire         D_RVALID,
        output wire [31:0]  D_RDATA,

        // 書き
        input wire  [4:0]   WADDR,
        input wire  [31:0]  WDATA,

        /* ----- データフォワーディング ----- */
        input wire  [4:0]   FWD_REG_ADDR,

        input wire          FWD_EXEC_EN,
        input wire  [4:0]   FWD_EXEC_ADDR,
        input wire  [31:0]  FWD_EXEC_DATA,

        input wire          FWD_CUSHION_EN,
        input wire  [4:0]   FWD_CUSHION_ADDR,
        input wire  [31:0]  FWD_CUSHION_DATA
    );

    /* ----- 入力取り込み ----- */
    reg  [4:0]  a_raddr, b_raddr, c_raddr, d_raddr;
    reg  [4:0]  waddr, fwd_reg_addr, fwd_exec_addr, fwd_cushion_addr;
    reg  [31:0] wdata, fwd_exec_data, fwd_cushion_data;
    reg         fwd_exec_en, fwd_cushion_en;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            a_raddr <= 5'b0;
            b_raddr <= 5'b0;
            c_raddr <= 5'b0;
            d_raddr <= 5'b0;
            waddr <= 5'b0;
            wdata <= 32'b0;
            fwd_reg_addr <= 5'b0;
            fwd_exec_addr <= 5'b0;
            fwd_exec_data <= 32'b0;
            fwd_exec_en <= 1'b0;
            fwd_cushion_addr <= 5'b0;
            fwd_cushion_data <= 32'b0;
            fwd_cushion_en <= 1'b0;
        end
        else if (STALL) begin
            fwd_reg_addr <= 5'b0;
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
            a_raddr <= A_RADDR;
            b_raddr <= B_RADDR;
            c_raddr <= C_RADDR;
            d_raddr <= D_RADDR;
            waddr <= WADDR;
            wdata <= WDATA;
            fwd_reg_addr <= FWD_REG_ADDR;
            fwd_exec_addr <= FWD_EXEC_ADDR;
            fwd_exec_data <= FWD_EXEC_DATA;
            fwd_exec_en <= FWD_EXEC_EN;
            fwd_cushion_addr <= FWD_CUSHION_ADDR;
            fwd_cushion_data <= FWD_CUSHION_DATA;
            fwd_cushion_en <= FWD_CUSHION_EN;
        end
    end

    /* ----- レジスタアクセス(rv32i) ----- */
    reg [31:0] registers [0:31];

    // 読み
    assign A_RVALID = forwarding_check(a_raddr, fwd_reg_addr, fwd_exec_addr, fwd_exec_en, fwd_cushion_addr, fwd_cushion_en);
    assign A_RDATA  = forwarding(a_raddr, registers[a_raddr], fwd_exec_addr, fwd_exec_data, fwd_cushion_addr, fwd_cushion_data, waddr, wdata);

    assign B_RVALID = forwarding_check(b_raddr, fwd_reg_addr, fwd_exec_addr, fwd_exec_en, fwd_cushion_addr, fwd_cushion_en);
    assign B_RDATA  = forwarding(b_raddr, registers[b_raddr], fwd_exec_addr, fwd_exec_data, fwd_cushion_addr, fwd_cushion_data, waddr, wdata);

    assign C_RVALID = forwarding_check(c_raddr, fwd_reg_addr, fwd_exec_addr, fwd_exec_en, fwd_cushion_addr, fwd_cushion_en);
    assign C_RDATA  = forwarding(c_raddr, registers[c_raddr], fwd_exec_addr, fwd_exec_data, fwd_cushion_addr, fwd_cushion_data, waddr, wdata);

    assign D_RVALID = forwarding_check(d_raddr, fwd_reg_addr, fwd_exec_addr, fwd_exec_en, fwd_cushion_addr, fwd_cushion_en);
    assign D_RDATA  = forwarding(d_raddr, registers[d_raddr], fwd_exec_addr, fwd_exec_data, fwd_cushion_addr, fwd_cushion_data, waddr, wdata);

    function forwarding_check;
        input [4:0]     target_addr;
        input [4:0]     reg_addr;
        input [4:0]     exec_addr;
        input           exec_en;
        input [4:0]     cushion_addr;
        input           cushion_en;

        case (target_addr)
            5'b0:           forwarding_check = 1'b1;
            reg_addr:       forwarding_check = 1'b0;
            exec_addr:      forwarding_check = exec_en;
            cushion_addr:   forwarding_check = cushion_en;
            default:        forwarding_check = 1'b1;
        endcase
    endfunction

    function [31:0] forwarding;
        input [4:0]     target_addr;
        input [31:0]    target_data;
        input [4:0]     exec_addr;
        input [31:0]    exec_data;
        input [4:0]     cushion_addr;
        input [31:0]    cushion_data;
        input [4:0]     memr_addr;
        input [31:0]    memr_data;

        case (target_addr)
            5'b0:           forwarding = 32'b0;
            exec_addr:      forwarding = exec_data;
            cushion_addr:   forwarding = cushion_data;
            memr_addr:      forwarding = memr_data;
            default:        forwarding = target_data;
        endcase
    endfunction

    // 書き
    always @ (posedge CLK) begin
        if (RST)
            registers[0] <= 32'b0;
        else if (WADDR != 5'b0)
            registers[WADDR] <= WDATA;
    end

endmodule
